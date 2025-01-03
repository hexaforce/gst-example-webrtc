import { useState, useEffect, useRef } from 'react'
import { gstWebRTCAPI, start } from 'gstwebrtc-api'

const CaptureSection = ({ clientId }) => {
  const videoRef = useRef(null)
  const sectionRef = useRef(null)
  const [producerSession, setProducerSession] = useState(null)

  const handleCaptureClick = async () => {
    if (producerSession) {
      producerSession.close()
    } else {
      const section = sectionRef.current
      section.classList.add('starting')
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: { width: 1280, height: 720 } })
        const session = gstWebRTCAPI.createProducerSession(stream)
        if (session) {
          setProducerSession(session)

          session.addEventListener('error', (event) => {
            console.error(event.message, event.error)
          })

          session.addEventListener('closed', () => {
            setProducerSession(null)
            videoRef.current.pause()
            videoRef.current.srcObject = null
            section.classList.remove('has-session', 'starting')
          })

          session.addEventListener('stateChanged', (event) => {
            if (event.target.state === gstWebRTCAPI.SessionState.streaming) {
              videoRef.current.srcObject = stream
              videoRef.current.play()
              section.classList.remove('starting')
            }
          })

          session.addEventListener('clientConsumerAdded', (event) => {
            console.info(`client consumer added: ${event.detail.peerId}`)
          })

          session.addEventListener('clientConsumerRemoved', (event) => {
            console.info(`client consumer removed: ${event.detail.peerId}`)
          })

          section.classList.add('has-session')
          session.start()
        } else {
          for (const track of stream.getTracks()) {
            track.stop()
          }
          section.classList.remove('starting')
        }
      } catch (error) {
        console.error('Cannot access webcam and microphone:', error)
        section.classList.remove('starting')
      }
    }
  }

  return (
    <section ref={sectionRef} id='capture'>
      <span className='client-id'>{clientId}</span>
      <button className='button' id='capture-button' onClick={handleCaptureClick}></button>
      <div className='video'>
        <div className='spinner'>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>
        <video ref={videoRef}></video>
      </div>
    </section>
  )
}

const RemoteStreamsSection = () => {
  const [producers, setProducers] = useState([])
  const entryElementRef = useRef([])
  const sessionRef = useRef([])
  const videoElementRef = useRef([])

  useEffect(() => {
    const listener = {
      producerAdded: (producer) => {
        if (!producers.some((p) => p.id === producer.id)) {
          setProducers((prev) => [...prev, producer])
        }
      },
      producerRemoved: (producer) => {
        sessionRef.current[producer.id].close()
        setProducers((prev) => prev.filter((p) => p.id !== producer.id))
      },
    }
    gstWebRTCAPI.registerProducersListener(listener)
    for (const producer of gstWebRTCAPI.getAvailableProducers()) {
      listener.producerAdded(producer)
    }
    return () => {
      gstWebRTCAPI.unregisterProducersListener(listener)
    }
  }, [])

  const handleStreamClick = (event, producerId) => {
    event.preventDefault()
    if (!event.target.classList.contains('button')) {
      return
    }

    videoElementRef.current[producerId].addEventListener('playing', () => {
      if (entryElementRef.current[producerId].classList.contains('has-session')) {
        entryElementRef.current[producerId].classList.add('streaming')
      }
    })

    if (sessionRef.current[producerId]) {
      sessionRef.current[producerId].close()
    } else {
      const session = gstWebRTCAPI.createConsumerSession(producerId)
      if (session) {
        sessionRef.current[producerId] = session

        session.addEventListener('error', (event) => {
          console.error(event.message, event.error)
        })

        session.addEventListener('closed', () => {
          videoElementRef.current[producerId].pause()
          videoElementRef.current[producerId].srcObject = null
          entryElementRef.current[producerId].classList.remove('has-session', 'streaming', 'has-remote-control')
        })

        session.addEventListener('streamsChanged', () => {
          const streams = session.streams
          if (streams.length > 0) {
            videoElementRef.current[producerId].srcObject = streams[0]
            videoElementRef.current[producerId].play().catch(() => {})
          }
        })

        session.addEventListener('remoteControllerChanged', () => {
          const remoteController = session.remoteController
          if (remoteController) {
            entryElementRef.current[producerId].classList.add('has-remote-control')
            remoteController.attachVideoElement(videoElementRef.current[producerId])
          } else {
            entryElementRef.current[producerId].classList.remove('has-remote-control')
          }
        })

        entryElementRef.current[producerId].classList.add('has-session')
        session.connect()
      }
    }
  }

  return (
    <section>
      <h1>Remote Streams</h1>
      <ul id='remote-streams'>
        {producers.map((producer) => (
          <li id={producer.id} key={producer.id} ref={(el) => (entryElementRef.current[producer.id] = el)}>
            <div className='button' onClick={(event) => handleStreamClick(event, producer.id)}>
              {producer.meta.name || producer.id}
            </div>
            <div className='video'>
              <div className='spinner'>
                <div></div>
                <div></div>
                <div></div>
                <div></div>
              </div>
              <span className='remote-control'>&#xA9;</span>
              <video ref={(el) => (videoElementRef.current[producer.id] = el)}></video>
              <div className='fullscreen'>
                <span title='Toggle fullscreen'>&#x25A2;</span>
              </div>
            </div>
          </li>
        ))}
      </ul>
    </section>
  )
}

function WebRTC() {
  const [clientId, setClientId] = useState('none')

  useEffect(() => {
    window.gstWebRTCAPI = gstWebRTCAPI
    start({
      signalingServerUrl: 'wss://gst-webrtc-signalling-server.hexaforce.io/webrtc',
      // meta: { name: window.location.hostname },
    })

    const listener = {
      connected: (id) => setClientId(id),
      disconnected: () => setClientId('none'),
    }
    gstWebRTCAPI.registerConnectionListener(listener)

    return () => {
      gstWebRTCAPI.unregisterConnectionListener(listener)
    }
  }, [])

  return (
    <>
      <header>
        <h1>GstWebRTC API</h1>
      </header>
      <main>
        <CaptureSection {...{ clientId }} />
        <RemoteStreamsSection />
      </main>
    </>
  )
}

export default WebRTC
