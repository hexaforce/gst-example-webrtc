
import sys
import logging
import http
import json
import asyncio
import websockets
import argparse
import concurrent


class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if hasattr(obj, "__str__"):
            return str(obj)
        return super().default(obj)


class WebRTCSimpleServer(object):

    def __init__(self, options):
        self.peers = dict()
        self.sessions = dict()

        self.options = options

    async def health_check(self, path, request_headers):
        if path == self.options.health:
            return http.HTTPStatus.OK, [], b"OK\n"
        return None

    async def recv_msg_ping(self, ws, remote_address):
        msg = None
        while msg is None:
            try:
                msg = await asyncio.wait_for(ws.recv(), self.options.keepalive_timeout)
            except (asyncio.TimeoutError, concurrent.futures._base.TimeoutError):
                print('Sending keepalive ping to {!r} in recv'.format(remote_address))
                await ws.ping()
        return msg

    async def cleanup_session(self, uid):
        if uid in self.sessions:
            other_id = self.sessions[uid]
            del self.sessions[uid]
            print("Cleaned up {} session".format(uid))
            if other_id in self.sessions:
                del self.sessions[other_id]
                print("Also cleaned up {} session".format(other_id))
                # If there was a session with this peer, also close the connection to reset its state.
                if other_id in self.peers:
                    print("Closing connection to {}".format(other_id))
                    wso, _, _ = self.peers[other_id]
                    del self.peers[other_id]
                    await wso.close()

    async def remove_peer(self, uid):
        await self.cleanup_session(uid)
        if uid in self.peers:
            ws, remote_address, _ = self.peers[uid]
            del self.peers[uid]
            await ws.close()
            print("Disconnected from peer {!r} at {!r}".format(uid, remote_address))

    ############### Handler functions ###############

    async def connection_handler(self, ws, uid):
        peer_status = None
        self.peers[uid] = [ws, ws.remote_address, peer_status]
        print("Registered peer {!r} at {!r}".format(uid, ws.remote_address))
        while True:

            # Receive command, wait forever if necessary
            msg = await self.recv_msg_ping(ws, ws.remote_address)

            # Update current status
            peer_status = self.peers[uid][2]

            # We are in a session or a room, messages must be relayed
            if peer_status is not None:

                # We're in a session, route message to connected peer
                if peer_status == 'session':
                    other_id = self.sessions[uid]
                    wso, _, status = self.peers[other_id]
                    assert(status == 'session')

                    try:
                        parsed_msg = json.loads(msg)
                    except json.JSONDecodeError:
                        print(f"{uid} -> {other_id}: {msg}")
                        return
                    if "sdp" in parsed_msg:
                        type = parsed_msg["sdp"].get("type", "")
                        print(f"{uid} -> {other_id}: SDP Message: {type}")
                        sdp = parsed_msg["sdp"].get("sdp", "")
                        print("\n".join(sdp.split("\\r\\n")))
                    else:
                        print(f"{uid} -> {other_id}: {msg}")
                    await wso.send(msg)
                else:
                    raise AssertionError('Unknown peer status {!r}'.format(peer_status))

            # Requested a session with a specific peer
            elif msg.startswith('SESSION'):
                print("{!r} command {!r}".format(uid, msg))
                _, callee_id = msg.split(maxsplit=1)
                if callee_id not in self.peers:
                    await ws.send('ERROR peer {!r} not found'.format(callee_id))
                    continue
                if peer_status is not None:
                    await ws.send('ERROR you are already in a session, reconnect to the server to start a new session, or use a ROOM for multi-peer sessions')
                    continue
                callee_status = self.peers[callee_id][2]
                if callee_status is not None:
                    await ws.send('ERROR peer {!r} busy'.format(callee_id))
                    continue
                await ws.send('SESSION_OK')
                wsc = self.peers[callee_id][0]
                print('Session from {!r} ({!r}) to {!r} ({!r})'.format(uid, ws.remote_address, callee_id, wsc.remote_address))

                # Register session
                self.peers[uid][2] = peer_status = 'session'
                self.sessions[uid] = callee_id
                self.peers[callee_id][2] = 'session'
                self.sessions[callee_id] = uid

                try:
                    print("Peers:")
                    print(json.dumps(self.peers, cls=CustomEncoder, indent=4))
                    print("\n")
                    print("Sessions:")
                    print(json.dumps(self.sessions, cls=CustomEncoder, indent=4))
                    print("\n")
                except Exception as e:
                    print(f"Error during JSON dump: {e}")

            else:
                print('Ignoring unknown message {!r} from {!r}'.format(msg, uid))

    async def hello_peer(self, ws):
        hello = await ws.recv()
        hello, uid = hello.split(maxsplit=1)

        if hello != 'HELLO':
            await ws.close(code=1002, reason='invalid protocol')
            raise Exception("Invalid hello from {!r}".format(ws.remote_address))
        if not uid or uid in self.peers or uid.split() != [uid]:  # no whitespace
            await ws.close(code=1002, reason='invalid peer uid')
            raise Exception("Invalid uid {!r} from {!r}".format(uid, ws.remote_address))
        
        # Send back a HELLO
        await ws.send('HELLO')
        return uid

    async def run(self):
        async def handler(ws, path):
            print("Connected to {!r}".format(ws.remote_address))
            peer_id = await self.hello_peer(ws)
            try:
                await self.connection_handler(ws, peer_id)
            except websockets.ConnectionClosed:
                print("Connection to peer {!r} closed, exiting handler".format(ws.remote_address))
            finally:
                await self.remove_peer(peer_id)

        print("Listening on https://{}:{}".format(self.options.addr, self.options.port))

        # Websocket server
        wsd = websockets.serve(
            handler, 
            self.options.addr, 
            self.options.port, 
            ssl=None, 
            process_request=self.health_check,
            max_queue=16)

        logger = logging.getLogger('websockets')
        logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        logger.addHandler(handler)

        try:
            self.exit_future = asyncio.Future()
            # Run the server
            async with wsd:
                await self.exit_future
                self.exit_future = None
            print('Stopped.')

        finally:
            logger.removeHandler(handler)
            self.peers = dict()
            self.sessions = dict()

    def stop(self):
        if self.exit_future:
            print('Stopping server... ', end='')
            self.exit_future.set_result(None)


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--addr', default='0.0.0.0', help='Address to listen on (default: all interfaces, both ipv4 and ipv6)')
    parser.add_argument('--port', default=8443, type=int, help='Port to listen on')
    parser.add_argument('--keepalive-timeout', dest='keepalive_timeout', default=30, type=int, help='Timeout for keepalive (in seconds)')
    parser.add_argument('--health', default='/health', help='Health check route')

    options = parser.parse_args(sys.argv[1:])

    print('Starting server...')
    while True:
        r = WebRTCSimpleServer(options)
        asyncio.run(r.run())
        print('Restarting server...')

if __name__ == "__main__":
    main()
