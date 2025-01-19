const WebSocket = require('ws');
const http = require('http');
const url = require('url');
const fs = require('fs');

class WebRTCSimpleServer {
    constructor(options) {
        this.peers = {}; // Connected peers
        this.sessions = {}; // Active sessions
        this.options = options;
    }

    // Helper functions

    async healthCheck(path) {
        if (path === this.options.health) {
            return { status: 200, body: 'OK\n' };
        }
        return null;
    }

    async recvMsgPing(ws, raddr) {
        let msg = null;
        while (msg === null) {
            try {
                msg = await new Promise((resolve, reject) => {
                    ws.once('message', resolve);
                    setTimeout(() => reject(new Error('Timeout')), this.options.keepalive_timeout * 1000);
                });
            } catch (err) {
                console.log(`Sending keepalive ping to ${raddr}`);
                ws.ping();
            }
        }
        return msg;
    }

    async cleanupSession(uid) {
        if (this.sessions[uid]) {
            const otherId = this.sessions[uid];
            delete this.sessions[uid];
            console.log(`Cleaned up ${uid} session`);

            if (this.sessions[otherId]) {
                delete this.sessions[otherId];
                console.log(`Also cleaned up ${otherId} session`);
                if (this.peers[otherId]) {
                    console.log(`Closing connection to ${otherId}`);
                    const [ws] = this.peers[otherId];
                    delete this.peers[otherId];
                    ws.close();
                }
            }
        }
    }

    async removePeer(uid) {
        await this.cleanupSession(uid);
        if (this.peers[uid]) {
            const [ws, raddr] = this.peers[uid];
            delete this.peers[uid];
            ws.close();
            console.log(`Disconnected from peer ${uid} at ${raddr}`);
        }
    }

    // Handler functions

    async connectionHandler(ws, uid) {
        const raddr = ws._socket.remoteAddress;
        let peerStatus = null;
        this.peers[uid] = [ws, raddr, peerStatus];
        console.log(`Registered peer ${uid} at ${raddr}`);

        while (true) {
            const msg = await this.recvMsgPing(ws, raddr);

            peerStatus = this.peers[uid][2];

            if (peerStatus !== null) {
                if (peerStatus === 'session') {
                    const otherId = this.sessions[uid];
                    const [wso] = this.peers[otherId];
                    console.log(`${uid} -> ${otherId}: ${msg}`);
                    wso.send(msg);
                } else {
                    throw new Error(`Unknown peer status ${peerStatus}`);
                }
            } else if (msg.startsWith('SESSION')) {
                const [cmd, calleeId] = msg.split(' ');

                if (!(calleeId in this.peers)) {
                    ws.send(`ERROR peer ${calleeId} not found`);
                    continue;
                }

                if (peerStatus !== null) {
                    ws.send('ERROR you are already in a session');
                    continue;
                }

                const calleeStatus = this.peers[calleeId][2];
                if (calleeStatus !== null) {
                    ws.send(`ERROR peer ${calleeId} busy`);
                    continue;
                }

                ws.send('SESSION_OK');
                const wsc = this.peers[calleeId][0];
                console.log(`Session from ${uid} to ${calleeId}`);
                
                this.peers[uid][2] = 'session';
                this.sessions[uid] = calleeId;
                this.peers[calleeId][2] = 'session';
                this.sessions[calleeId] = uid;
            } else {
                console.log(`Ignoring unknown message ${msg} from ${uid}`);
            }
        }
    }

    async helloPeer(ws) {
        const raddr = ws._socket.remoteAddress;
        const hello = await new Promise((resolve, reject) => {
            ws.once('message', resolve);
            setTimeout(() => reject(new Error('Timeout')), 5000);
        });

        const [cmd, uid] = hello.split(' ');

        if (cmd !== 'HELLO') {
            ws.close(1002, 'invalid protocol');
            throw new Error(`Invalid hello from ${raddr}`);
        }

        if (!uid || uid in this.peers || uid.includes(' ')) {
            ws.close(1002, 'invalid peer uid');
            throw new Error(`Invalid uid ${uid} from ${raddr}`);
        }

        ws.send('HELLO');
        return uid;
    }

    async run() {
        const server = http.createServer((req, res) => {
            const { path } = url.parse(req.url, true);
            const healthResponse = this.healthCheck(path);
            if (healthResponse) {
                res.statusCode = healthResponse.status;
                res.end(healthResponse.body);
            } else {
                res.statusCode = 404;
                res.end('Not Found');
            }
        });

        const wss = new WebSocket.Server({ server });

        wss.on('connection', (ws) => {
            ws.on('message', async (message) => {
              console.log(message)
                try {
                    const peerId = await this.helloPeer(ws);
                    await this.connectionHandler(ws, peerId);
                } catch (err) {
                    console.error(`Connection handler error: ${err.message}`);
                }
            });
        });

        console.log(`Listening on http://${this.options.addr}:${this.options.port}`);

        server.listen(this.options.port, this.options.addr, () => {
            console.log('Server is running...');
        });
    }

    stop() {
        if (this.exitFuture) {
            console.log('Stopping server...');
            this.exitFuture = null;
        }
    }
}

function main() {
    const args = process.argv.slice(2);
    const options = {
        addr: '0.0.0.0',
        port: 8443,
        keepalive_timeout: 30,
        health: '/health'
    };

    const server = new WebRTCSimpleServer(options);

    server.run().catch(console.error);
}

if (require.main === module) {
    main();
}
