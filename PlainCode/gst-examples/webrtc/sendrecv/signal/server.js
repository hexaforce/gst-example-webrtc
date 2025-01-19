const fs = require('fs');
const http = require('http');
const https = require('https');
const WebSocket = require('ws');
const { program } = require('commander');

class WebRTCSimpleServer {
  constructor(options) {
    this.peers = new Map(); // {uid: {ws, address, status}}
    this.sessions = new Map(); // {callerUid: calleeUid, calleeUid: callerUid}
    this.rooms = new Map(); // {roomId: Set(peerIds)}
    this.options = options;
  }

  getSSLCredentials() {
    const chainPath = `${this.options.certPath}/fullchain.pem`;
    const keyPath = `${this.options.certPath}/privkey.pem`;
    return {
      cert: fs.readFileSync(chainPath),
      key: fs.readFileSync(keyPath),
    };
  }

  createServer() {
    if (this.options.disableSsl) {
      return http.createServer();
    }
    const sslCredentials = this.getSSLCredentials();
    return https.createServer(sslCredentials);
  }

  async handleConnection(ws, req) {
    const address = req.socket.remoteAddress;
    console.log(`New connection from ${address}`);
    try {
      const uid = await this.exchangeHello(ws);
      this.peers.set(uid, { ws, address, status: null });

      ws.on('message', (message) => this.handleMessage(ws, uid, message.toString()));
      ws.on('close', () => this.removePeer(uid));
    } catch (error) {
      console.error('Connection error:', error.message);
      ws.close();
    }
  }

  async exchangeHello(ws) {
    return new Promise((resolve, reject) => {
      ws.once('message', (message) => {
        const parts = message.toString().split(' ');
        if (parts[0] !== 'HELLO' || parts.length !== 2) {
          reject(new Error('Invalid HELLO message'));
          return;
        }
        const uid = parts[1];
        if (this.peers.has(uid)) {
          reject(new Error('UID already in use'));
          return;
        }
        ws.send('HELLO');
        resolve(uid);
      });
    });
  }

  handleMessage(ws, uid, message) {
    console.log(`Received message from ${uid}: ${message}`);
    const peerData = this.peers.get(uid);

    if (!peerData) {
      ws.send('ERROR: Unknown peer');
      return;
    }

    // Handle commands like 'SESSION', 'ROOM', etc.
    const [command, ...args] = message.split(' ');

    switch (command) {
      case 'SESSION':
        this.handleSessionCommand(uid, args);
        break;
      case 'ROOM':
        this.handleRoomCommand(uid, args);
        break;
      default:
        ws.send(`ERROR: Unknown command '${command}'`);
    }
  }

  handleSessionCommand(uid, args) {
    if (args.length !== 1) {
      this.peers.get(uid).ws.send('ERROR: Invalid SESSION command');
      return;
    }
    const calleeId = args[0];
    if (!this.peers.has(calleeId)) {
      this.peers.get(uid).ws.send(`ERROR: Peer ${calleeId} not found`);
      return;
    }
    if (this.sessions.has(uid) || this.sessions.has(calleeId)) {
      this.peers.get(uid).ws.send('ERROR: Already in a session');
      return;
    }

    this.sessions.set(uid, calleeId);
    this.sessions.set(calleeId, uid);
    this.peers.get(uid).status = 'session';
    this.peers.get(calleeId).status = 'session';

    this.peers.get(uid).ws.send('SESSION_OK');
    console.log(`Session established between ${uid} and ${calleeId}`);
  }

  handleRoomCommand(uid, args) {
    if (args.length !== 1) {
      this.peers.get(uid).ws.send('ERROR: Invalid ROOM command');
      return;
    }
    const roomId = args[0];

    if (!this.rooms.has(roomId)) {
      this.rooms.set(roomId, new Set());
    }
    const room = this.rooms.get(roomId);
    if (room.has(uid)) {
      this.peers.get(uid).ws.send('ERROR: Already in the room');
      return;
    }

    room.add(uid);
    this.peers.get(uid).status = roomId;

    const peersInRoom = Array.from(room).filter((peerId) => peerId !== uid);
    this.peers.get(uid).ws.send(`ROOM_OK ${peersInRoom.join(' ')}`);

    peersInRoom.forEach((peerId) => {
      const peer = this.peers.get(peerId);
      if (peer) {
        peer.ws.send(`ROOM_PEER_JOINED ${uid}`);
      }
    });

    console.log(`Peer ${uid} joined room ${roomId}`);
  }

  async removePeer(uid) {
    if (!this.peers.has(uid)) return;
    const { status } = this.peers.get(uid);

    if (status === 'session') {
      const calleeId = this.sessions.get(uid);
      if (calleeId && this.peers.has(calleeId)) {
        this.peers.get(calleeId).ws.send('ERROR: Session ended');
        this.peers.get(calleeId).status = null;
      }
      this.sessions.delete(uid);
      this.sessions.delete(calleeId);
    } else if (status) {
      const room = this.rooms.get(status);
      if (room) {
        room.delete(uid);
        room.forEach((peerId) => {
          this.peers.get(peerId)?.ws.send(`ROOM_PEER_LEFT ${uid}`);
        });
      }
    }

    this.peers.delete(uid);
    console.log(`Peer ${uid} disconnected`);
  }

  run() {
    const server = this.createServer();
    const wss = new WebSocket.Server({ server });

    wss.on('connection', (ws, req) => this.handleConnection(ws, req));

    server.listen(this.options.port, this.options.addr, () => {
      console.log(`WebRTC Simple Server running at ${this.options.addr}:${this.options.port}`);
    });
  }
}

program
  .option('--addr <address>', 'Address to listen on', '0.0.0.0')
  .option('--port <port>', 'Port to listen on', 8443)
  .option('--keepalive-timeout <timeout>', 'Keepalive timeout in seconds', 30)
  .option('--cert-path <path>', 'Path to SSL certificates', './certs')
  .option('--disable-ssl', 'Disable SSL', true)
  .option('--health <path>', 'Health check path', '/health');

program.parse(process.argv);

const options = program.opts();
const server = new WebRTCSimpleServer(options);
server.run();
