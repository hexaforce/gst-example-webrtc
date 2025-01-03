import { createRoot } from 'react-dom/client'
import { useState, useRef, useEffect } from 'react'
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import { initialValue, rtc_configuration, default_constraints, websocketServerURL, generatePeerId, parseMessage, trackStop, throughputMeasurement } from './webrtc'
import './output.css'

import { PhoneArrowDownLeftIcon, PhoneArrowUpRightIcon, PhoneXMarkIcon, PhoneIcon } from '@heroicons/react/16/solid'
import { Field, Label, Switch } from '@headlessui/react'

const App = () => {
  const [state, setState] = useState({ ...initialValue })
  function inputChange(event) {
    const { id, type, value, checked } = event.target
    setState({ ...state, [id]: 'checkbox' == type ? checked : value })
  }

  const ws_conn = useRef(null)
  const peer_conn = useRef(new RTCPeerConnection(rtc_configuration))
  const receive_video_tag = useRef(null)
  const send_video_stream = useRef(null)

  useEffect(() => {
    websocketServerConnect()
    return () => {
      if (ws_conn.current) ws_conn.current.close()
      if (peer_conn.current) peer_conn.current.close()
    }
  }, [])

  const [statsData, setStatsData] = useState({ fps: null, bitrate: null, totalBytes: 0, totalFrames: 0, latestTimestamp: 0 })
  const intervalRef = useRef()
  useEffect(() => {
    if (!peer_conn.current) return
    const updateStats = async () => {
      if (peer_conn.current.iceConnectionState !== 'connected') return
      const stats = await peer_conn.current.getStats()
      throughputMeasurement(stats, setStatsData)
    }
    intervalRef.current = setInterval(updateStats, 1000)
    return () => clearInterval(intervalRef.current)
  }, [peer_conn.current])

  const websocketServerConnect = (connect_attempts = 0, isReconnecting = false) => {
    if (connect_attempts > 3) {
      console.error('Too many connection attempts, aborting. Refresh page to try again')
      return
    }

    // Fetch the peer id to use
    let peer_id = generatePeerId()

    ws_conn.current = new WebSocket(websocketServerURL())

    ws_conn.current.onopen = () => {
      ws_conn.current.send('HELLO ' + peer_id)
      // Reset connection attempts because we connected successfully
      setState((prevState) => ({ ...prevState, 'peer-id': peer_id, 'peer-connect-button': 'Connect' }))
      connect_attempts = 0
      isReconnecting = false
    }

    ws_conn.current.onmessage = async ({ type, data }) => {
      switch (data) {
        case 'HELLO':
          console.log(`receive <<< : ${data}`)
          return
        case 'SESSION_OK':
          console.log(`receive <<< : ${data}`)
          if (state['remote-offerer']) {
            ws_conn.current.send('OFFER_REQUEST')
            return
          }
          if (!state.callCreateTriggered) {
            createCall()
          }
          return
        case 'OFFER_REQUEST':
          console.log(`receive <<< : ${data}`)
          // The peer wants us to set up and then send an offer
          if (!state.callCreateTriggered) createCall()
          return
        default: {
          // Handle incoming JSON SDP and ICE messages
          const { sdp, ice } = parseMessage(data)
          if (sdp != null && ice != null) {
            console.error(`Unknown incoming JSON: ${type} <<< ${data}`)
            ws_conn.current.close()
            return
          }
          // Incoming JSON signals the beginning of a call
          if (!state.callCreateTriggered) createCall(sdp, ice)
          if (sdp != null) {
            console.log('receive <<< : ', sdp)

            // An offer may come in while we are busy processing SRD(answer).
            // In this case, we will be in "stable" by the time the offer is processed so it is safe to chain it on our Operations Chain now.
            const readyForOffer = !state.makingOffer && (peer_conn.current.signalingState == 'stable' || state.isSettingRemoteAnswerPending)
            const offerCollision = sdp.type == 'offer' && !readyForOffer
            if (offerCollision) {
              return
            }

            setState((prevState) => ({ ...prevState, isSettingRemoteAnswerPending: sdp.type == 'answer' }))
            await peer_conn.current.setRemoteDescription(sdp)
            setState((prevState) => ({ ...prevState, isSettingRemoteAnswerPending: false }))

            try {
              if (sdp.type == 'offer') {
                send_video_stream.current = await navigator.mediaDevices.getUserMedia(default_constraints)
                for (const track of send_video_stream.current.getTracks()) {
                  peer_conn.current.addTrack(track, send_video_stream.current)
                }
                await peer_conn.current.setLocalDescription()
                ws_conn.current.send({ sdp: peer_conn.current.localDescription })
              }
            } catch (err) {
              console.error(err)
              ws_conn.current.close()
            }
          }
          if (ice != null) {
            console.log('receive <<< : ', ice)
            try {
              // ICE candidate received from peer, add it to the peer connection
              await peer_conn.current.addIceCandidate(new RTCIceCandidate(ice))
            } catch (err) {
              console.error(err)
            }
          }
        }
      }
    }

    const reconnect = (wait) => {
      if (!isReconnecting) {
        setTimeout(() => websocketServerConnect(connect_attempts + 1, true), wait)
      }
    }

    ws_conn.current.onclose = async () => {
      console.log('Disconnected from server')
      // Release the webcam and mic
      const video = receive_video_tag.current
      if (video != null) {
        const { srcObject, style } = video
        trackStop(srcObject)
        style.display = 'none'
      }

      trackStop(send_video_stream.current)

      if (peer_conn.current) {
        peer_conn.current.close()
        peer_conn.current = new RTCPeerConnection(rtc_configuration)
      }
      setState((prevState) => ({ ...prevState, callCreateTriggered: false }))
      // Reset after a second
      reconnect(1000)
    }

    ws_conn.current.onerror = () => {
      console.error('Unable to connect to server, did you add an exception for the certificate?')
      // Retry after 3 seconds
      reconnect(3000)
    }
  }

  const createCall = () => {
    setState((prevState) => ({ ...prevState, callCreateTriggered: true }))

    const send_channel = peer_conn.current.createDataChannel('fpv japane', null)
    send_channel.onmessage = ({ type, data }) => {
      if (typeof data === 'string' || data instanceof String) {
        console.log(`type:${type} date:${data}`)
      }
      send_channel.send('Hi! (from browser send)')
    }

    peer_conn.current.ondatachannel = ({ channel: receive_channel }) => {
      receive_channel.onmessage = ({ type, data }) => {
        if (typeof data === 'string' || data instanceof String) {
          console.log(`type:${type} date:${data}`)
        }
        send_channel.send('Hi! (from browser receive)')
      }
    }

    peer_conn.current.ontrack = ({ receiver, streams, track, transceiver }) => {
      if (!streams || streams.length === 0) return
      const video = receive_video_tag.current
      track.onmute = () => {
        video.style.display = 'none'
      }
      track.onunmute = () => {
        video.style.display = 'block'
      }
      if (track.kind === 'video') video.style.display = 'block'
      video.srcObject = streams[0]
    }

    peer_conn.current.onicecandidate = ({ candidate }) => {
      // We have a candidate, send it to the remote party with the same uuid
      if (candidate == null) {
        console.log('ICE Candidate was null, done')
        return
      }
      ws_conn.current.send({ ice: candidate })
    }

    peer_conn.current.oniceconnectionstatechange = ({ currentTarget }) => {
      const { iceConnectionState, currentLocalDescription, currentRemoteDescription } = currentTarget
      if (iceConnectionState == 'connected') {
        console.log(`ICE gathering complete LocalDescription: ${currentLocalDescription.type} RemoteDescription: ${currentRemoteDescription.type}`)
        setState((prevState) => ({ ...prevState, startTimestamp: Date.now() }))
      }
    }

    // let the "negotiationneeded" event trigger offer generation
    peer_conn.current.onnegotiationneeded = async () => {
      if (state['remote-offerer']) return
      try {
        setState((prevState) => ({ ...prevState, makingOffer: true }))
        await peer_conn.current.setLocalDescription()
        ws_conn.current.send({ sdp: peer_conn.current.localDescription })
      } catch (err) {
        console.error(err)
        ws_conn.current.close()
      } finally {
        setState((prevState) => ({ ...prevState, makingOffer: false }))
      }
    }
    setState((prevState) => ({ ...prevState, 'peer-connect-button': 'Disconnect' }))
  }

  const onConnectClicked = () => {
    if (state['peer-connect-button'] == 'Disconnect') {
      ws_conn.current.close()
      return
    }
    var id = state['peer-connect']
    if (id == '') {
      alert('Peer id must be filled out')
      return
    }
    ws_conn.current.send('SESSION ' + id)
    setState((prevState) => ({ ...prevState, 'peer-connect-button': 'Disconnect' }))
  }

  const onTextKeyPress = ({ type, code }) => {
    if (type == 'keydown' && code == 'Enter') {
      onConnectClicked()
      return false
    }
    return true
  }

  const reproductionTime = () => {
    const elapsedTime = statsData.latestTimestamp - state.startTimestamp
    if (elapsedTime < 0) return 'N/A'
    const totalSeconds = Math.floor(elapsedTime / 1000)
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes}:${seconds.toString().padStart(2, '0')}`
  }

  return (
    <main className='grid min-h-full place-items-center bg-white px-6 py-24 sm:py-32 lg:px-8'>
      <div className='text-center'>
        <div id='video'>
          <video ref={receive_video_tag} style={{ display: 'none' }} autoPlay playsInline>
            {"Your browser doesn't support video"}
          </video>
        </div>

        <div className='inline-block text-left'>
          <label htmlFor='text' className='block text-sm/6 font-semibold text-gray-900'>
            Status: <span id='status'>{state.status}</span>
          </label>
          <textarea id='text' rows={6} cols={50} value={state.text} onChange={inputChange} className='block w-full rounded-md bg-white px-3.5 py-2 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600' />
        </div>

        <div className='flex items-center gap-x-1'>
          <label htmlFor='peer-connect' className='text-sm font-semibold text-gray-900'>
            Enter peer ID
          </label>
          <input id='peer-connect' type='text' onChange={inputChange} onKeyDown={onTextKeyPress} required disabled={state['peer-connect-button'] == 'Disconnect'} className='w-24 rounded-md bg-white px-3.5 py-2 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600' />
          <button type='button' onClick={onConnectClicked} className={state['peer-connect-button'] == 'Connect' ? 'inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600' : 'inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600'}>
            {state['peer-connect-button'] == 'Connect' ? <PhoneArrowUpRightIcon aria-hidden='true' className='-ml-0.5 mr-1.5 size-5' /> : <PhoneXMarkIcon aria-hidden='true' className='-ml-0.5 mr-1.5 size-5' />}
            {state['peer-connect-button']}
          </button>
          <Field className='flex gap-x-1 sm:col-span-2'>
            <div className='flex h-6 items-center'>
              <Switch checked={state['remote-offerer']} onChange={(checked) => setState({ ...state, 'remote-offerer': checked })} className='group flex w-8 flex-none cursor-pointer rounded-full bg-gray-200 p-px ring-1 ring-inset ring-gray-900/5 transition-colors duration-200 ease-in-out focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 data-[checked]:bg-indigo-600'>
                <span aria-hidden='true' className='size-4 transform rounded-full bg-white shadow-sm ring-1 ring-gray-900/5 transition duration-200 ease-in-out group-data-[checked]:translate-x-3.5' />
              </Switch>
            </div>
            <Label className='block text-sm/6 font-semibold text-gray-900'>Remote offerer</Label>
          </Field>
        </div>

        <div className='flex items-center gap-x-1'>
          <PhoneIcon aria-hidden='true' className='-ml-0.5 mr-1.5 size-5' />
          <span className='text-sm font-semibold text-gray-900'>Our ID is</span>
          <span className='text-lg text-sm font-semibold text-gray-900'>{state['peer-id']}</span>
        </div>

        <div className='inline-block text-left'>
          <label htmlFor='constraints' className='block text-sm font-semibold text-gray-900'>
            getUserMedia constraints being used:
          </label>
          <textarea id='constraints' rows={2} cols={50} onChange={inputChange} className='block w-full rounded-md bg-white px-3.5 py-2 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600' />
        </div>

        {state['peer-connect-button'] == 'Disconnect' && (
          <div className='flex items-center gap-x-1'>
            <strong>FPS:</strong> {statsData.fps !== null ? statsData.fps.toFixed(2) : 'N/A'}
            <strong>Bitrate:</strong> {statsData.bitrate !== null ? `${(statsData.bitrate / 1000000).toFixed(2)} Mbps` : 'N/A'}
            <strong>TotalBytes:</strong> {statsData.totalBytes ? (statsData.totalBytes / (1024 * 1024)).toFixed(2) : 'N/A'} MB
            <strong>TotalFrames:</strong> {statsData.totalFrames.toLocaleString()} frames
            <strong>ReproductionTime:</strong> {reproductionTime()}
          </div>
        )}
      </div>
    </main>
  )
}

createRoot($('root')).render(
  <Router>
    <Routes>
      <Route path='/health-check' element={<>OK</>} />
      <Route path='/' element={<App />} />
    </Routes>
  </Router>,
)
