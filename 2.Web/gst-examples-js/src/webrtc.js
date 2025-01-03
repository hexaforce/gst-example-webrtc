// Override with your own STUN servers if you want
export const rtc_configuration = {
  iceServers: [{ urls: 'stun:stun.l.google.com:19302' }],
}

// The default constraints that will be attempted. Can be overriden by the user.
export const default_constraints = { video: true, audio: true }

export const initialValue = {
  status: 'unknown',
  status_error: null,
  text: '',
  'peer-connect': '',
  'peer-connect-button': 'Connect',
  'remote-offerer': false,
  'peer-id': 'unknown',

  startTimestamp: 0,

  // keep track of some negotiation state to prevent races and errors
  callCreateTriggered: false,
  makingOffer: false,
  isSettingRemoteAnswerPending: false,
}

const ws_protocol = 'wss'
const ws_server = 'gst-examples-signalling.hexaforce.io'
const ws_port = null
const use_peer_id = null

// const ws_protocol = 'ws'
// const ws_server = window.location.hostname
// const ws_port = '8443'
// const use_peer_id = 1

export const websocketServerURL = () => {
  if (ws_port) return `${ws_protocol}://${ws_server}:${ws_port}`
  return `${ws_protocol}://${ws_server}`
}

export const generatePeerId = () => {
  return use_peer_id || Math.floor(Math.random() * (9000 - 10) + 10).toString()
}

export const trackStop = (stream) => {
  if (stream) {
    for (const track of stream.getTracks()) {
      track.stop()
    }
  }
}

const send = WebSocket.prototype.send
WebSocket.prototype.send = function (data) {
  if (typeof data === 'object' && data !== null) {
    console.log('send >>> : ', data)
    send.call(this, JSON.stringify(data))
  } else if (typeof data === 'string') {
    console.log(`send >>> : ${data}`)
    send.call(this, data)
  } else {
    console.error('Data is of unsupported type:', typeof data)
  }
}

export const parseMessage = (data) => {
  if (data.startsWith('ERROR')) {
    console.error(data)
    return null
  }
  try {
    const msg = JSON.parse(data)
    if (msg.sdp != null && msg.ice != null) {
      console.error('Unknown incoming JSON: ' + msg)
      return null
    }
    return { sdp: msg.sdp, ice: msg.ice }
  } catch (err) {
    if (err instanceof SyntaxError) {
      console.error(err)
    } else {
      console.error(err)
    }
    return null
  }
}

export const throughputMeasurement = (stats,setStatsData)=>{
  let totalBytes = 0
  let totalFrames = 0
  let latestTimestamp = 0
  stats.forEach((report) => {
    const { type, kind } = report
    if (type === 'inbound-rtp' && kind === 'video') {
      const { bytesReceived, framesDecoded, timestamp } = report
      totalBytes += bytesReceived
      totalFrames += framesDecoded
      latestTimestamp = Math.max(latestTimestamp, timestamp)
    }
    // if (type === 'outbound-rtp' && kind === 'video') {
    //   const { bytesSent, framesEncoded, timestamp } = report
    //   totalBytes += bytesSent
    //   totalFrames += framesEncoded
    //   latestTimestamp = Math.max(latestTimestamp, timestamp)
    // }
  })
  setStatsData((prev) => {
    const timeDiff = latestTimestamp - prev.latestTimestamp
    if (timeDiff <= 0) return prev
    const bytesDiff = totalBytes - prev.totalBytes
    const framesDiff = totalFrames - prev.totalFrames
    const bitrate = (bytesDiff * 8) / (timeDiff / 1000) // bps
    const fps = framesDiff / (timeDiff / 1000) // frames per second
    return { fps, bitrate, totalBytes, totalFrames, latestTimestamp }
  })
}