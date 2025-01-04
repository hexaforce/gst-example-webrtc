// SPDX-License-Identifier: MPL-2.0

use crate::signaller::{Signallable, SignallableImpl};
use crate::RUNTIME;

use anyhow::{anyhow, Error};
use async_tungstenite::tungstenite;
use futures::channel::mpsc;
use futures::sink::SinkExt;
use futures::stream::StreamExt;
use gst::glib;
use gst::glib::Properties;
use gst::prelude::*;
use gst::subclass::prelude::*;
use http::Uri;
use once_cell::sync::Lazy;
use rand::prelude::*;
use serde::{Deserialize, Serialize};
use std::ops::ControlFlow;
use std::sync::Mutex;
use std::time::Duration;
use tokio::{task, time::timeout};
use tungstenite::Message as WsMessage;

static CAT: Lazy<gst::DebugCategory> = Lazy::new(|| {
    gst::DebugCategory::new(
        "webrtc-janusvr-signaller",
        gst::DebugColorFlags::empty(),
        Some("WebRTC Janus Video Room signaller"),
    )
});

fn transaction_id() -> String {
    thread_rng()
        .sample_iter(&rand::distributions::Alphanumeric)
        .map(char::from)
        .take(30)
        .collect()
}

fn feed_id() -> u32 {
    thread_rng().gen()
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq, Clone)]
#[serde(untagged)]
/// Ids are either u64 (default) or string in Janus, depending of the
/// `string_ids` configuration in the videoroom plugin config file.
enum JanusId {
    Str(String),
    Num(u64),
}

impl std::fmt::Display for JanusId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            JanusId::Str(s) => write!(f, "{s}"),
            JanusId::Num(n) => write!(f, "{n}"),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct KeepAliveMsg {
    janus: String,
    transaction: String,
    session_id: u64,
    apisecret: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct CreateSessionMsg {
    janus: String,
    transaction: String,
    apisecret: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct AttachPluginMsg {
    janus: String,
    transaction: String,
    plugin: String,
    session_id: u64,
    apisecret: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct RoomRequestBody {
    request: String,
    ptype: String,
    room: JanusId,
    id: JanusId,
    #[serde(skip_serializing_if = "Option::is_none")]
    display: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct RoomRequestMsg {
    janus: String,
    transaction: String,
    session_id: u64,
    handle_id: u64,
    apisecret: Option<String>,
    body: RoomRequestBody,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct PublishBody {
    request: String,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct Jsep {
    sdp: String,
    trickle: Option<bool>,
    r#type: String,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct PublishMsg {
    janus: String,
    transaction: String,
    session_id: u64,
    handle_id: u64,
    apisecret: Option<String>,
    body: PublishBody,
    jsep: Jsep,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct Candidate {
    candidate: String,
    #[serde(rename = "sdpMLineIndex")]
    sdp_m_line_index: u32,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct TrickleMsg {
    janus: String,
    transaction: String,
    session_id: u64,
    handle_id: u64,
    apisecret: Option<String>,
    candidate: Candidate,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(untagged)]
enum OutgoingMessage {
    KeepAlive(KeepAliveMsg),
    CreateSession(CreateSessionMsg),
    AttachPlugin(AttachPluginMsg),
    RoomRequest(RoomRequestMsg),
    Publish(PublishMsg),
    Trickle(TrickleMsg),
}

#[derive(Serialize, Deserialize, Debug)]
struct InnerError {
    code: i32,
    reason: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct InnerHangup {
    session_id: JanusId,
    sender: JanusId,
    reason: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct RoomJoined {
    room: JanusId,
}

#[derive(Serialize, Deserialize, Debug)]
struct RoomEvent {
    room: Option<JanusId>,
    error_code: Option<i32>,
    error: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "videoroom")]
struct RoomDestroyed {
    room: JanusId,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "videoroom", rename_all = "kebab-case")]
enum VideoRoomData {
    #[serde(rename = "joined")]
    Joined(RoomJoined),
    #[serde(rename = "event")]
    Event(RoomEvent),
    Destroyed(RoomDestroyed),
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "plugin")]
enum PluginData {
    #[serde(rename = "janus.plugin.videoroom")]
    VideoRoom { data: VideoRoomData },
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq)]
struct DataHolder {
    id: u64,
}

#[derive(Serialize, Deserialize, Debug)]
struct SuccessMsg {
    transaction: Option<String>,
    session_id: Option<u64>,
    data: Option<DataHolder>,
}

#[derive(Serialize, Deserialize, Debug)]
struct EventMsg {
    transaction: Option<String>,
    session_id: Option<u64>,
    plugindata: Option<PluginData>,
    jsep: Option<Jsep>,
}

// IncomingMessage
#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "janus", rename_all = "lowercase")]
enum JsonReply {
    Ack,
    Success(SuccessMsg),
    Event(EventMsg),
    WebRTCUp,
    Media,
    Error(InnerError),
    HangUp(InnerHangup),
}

#[derive(Default)]
struct State {
    ws_sender: Option<mpsc::Sender<OutgoingMessage>>,
    send_task_handle: Option<task::JoinHandle<Result<(), Error>>>,
    recv_task_handle: Option<task::JoinHandle<()>>,
    session_id: Option<u64>,
    handle_id: Option<u64>,
    transaction_id: Option<String>,
    room_id: Option<JanusId>,
    feed_id: Option<JanusId>,
}

#[derive(Clone)]
struct Settings {
    janus_endpoint: String,
    room_id: Option<String>,
    feed_id: String,
    display_name: Option<String>,
    secret_key: Option<String>,
    string_ids: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            janus_endpoint: "ws://127.0.0.1:8188".to_string(),
            room_id: None,
            feed_id: feed_id().to_string(),
            display_name: None,
            secret_key: None,
            string_ids: false,
        }
    }
}

#[derive(Default, Properties)]
#[properties(wrapper_type = super::JanusVRSignaller)]
pub struct Signaller {
    state: Mutex<State>,
    #[property(name="janus-endpoint", get, set, type = String, member = janus_endpoint, blurb = "The Janus server endpoint to POST SDP offer to")]
    #[property(name="room-id", get, set, type = String, member = room_id, blurb = "The Janus Room ID that will be joined to")]
    #[property(name="feed-id", get, set, type = String, member = feed_id, blurb = "The Janus Feed ID to identify where the track is coming from")]
    #[property(name="display-name", get, set, type = String, member = display_name, blurb = "The name of the publisher in the Janus Video Room")]
    #[property(name="secret-key", get, set, type = String, member = secret_key, blurb = "The secret API key to communicate with Janus server")]
    #[property(name="string-ids", get, set, type = bool, member = string_ids, blurb = "Force passing room-id and feed-id as string even if they can be parsed into an integer")]
    settings: Mutex<Settings>,
}

impl Signaller {
    fn raise_error(&self, msg: String) {
        self.obj()
            .emit_by_name::<()>("error", &[&format!("Error: {msg}")]);
    }

    async fn connect(&self) -> Result<(), Error> {
        let settings = self.settings.lock().unwrap().clone();
        use tungstenite::client::IntoClientRequest;
        let mut request = settings
            .janus_endpoint
            .parse::<Uri>()?
            .into_client_request()?;
        request.headers_mut().append(
            "Sec-WebSocket-Protocol",
            http::HeaderValue::from_static("janus-protocol"),
        );

        let (ws, _) = timeout(
            // FIXME: Make the timeout configurable
            Duration::from_secs(20),
            async_tungstenite::tokio::connect_async(request),
        )
        .await??;

        // Channel for asynchronously sending out websocket message
        let (mut ws_sink, mut ws_stream) = ws.split();

        // 1000 is completely arbitrary, we simply don't want infinite piling
        // up of messages as with unbounded
        let (ws_sender, mut ws_receiver) = mpsc::channel::<OutgoingMessage>(1000);
        let send_task_handle =
            RUNTIME.spawn(glib::clone!(@weak-allow-none self as this => async move {
                let mut res = Ok(());
                loop {
                    tokio::select! {
                        opt = ws_receiver.next() => match opt {
                            Some(msg) => {
                                gst::log!(CAT, "Sending websocket message {:?}", msg);
                                res = ws_sink
                                    .send(WsMessage::Text(serde_json::to_string(&msg).unwrap()))
                                    .await;
                            },
                            None => break,
                        },
                        _ = tokio::time::sleep(Duration::from_secs(10)) => {
                            if let Some(ref this) = this {
                                let (transaction, session_id, apisecret) = {
                                    let state = this.state.lock().unwrap();
                                    let settings = this.settings.lock().unwrap();
                                    (
                                        state.transaction_id.clone().unwrap(),
                                        state.session_id.unwrap(),
                                        settings.secret_key.clone(),
                                    )
                                };
                                let msg = OutgoingMessage::KeepAlive(KeepAliveMsg {
                                    janus: "keepalive".to_string(),
                                    transaction,
                                    session_id,
                                    apisecret,
                                });
                                res = ws_sink
                                    .send(WsMessage::Text(serde_json::to_string(&msg).unwrap()))
                                    .await;
                            }
                        }
                    }

                    if let Err(ref err) = res {
                        this.as_ref().map_or_else(|| gst::error!(CAT, "Quitting send task: {err}"),
                            |this| gst::error!(CAT, imp: this, "Quitting send task: {err}")
                        );

                        break;
                    }
                }

                this.map_or_else(|| gst::debug!(CAT, "Done sending"),
                    |this| gst::debug!(CAT, imp: this, "Done sending")
                );

                let _ = ws_sink.close().await;

                res.map_err(Into::into)
            }));

        let recv_task_handle =
            RUNTIME.spawn(glib::clone!(@weak-allow-none self as this => async move {
                while let Some(msg) = tokio_stream::StreamExt::next(&mut ws_stream).await {
                    if let Some(ref this) = this {
                        if let ControlFlow::Break(_) = this.handle_msg(msg) {
                            break;
                        }
                    } else {
                        break;
                    }
                }

                let msg = "Stopped websocket receiving";
                this.map_or_else(|| gst::info!(CAT, "{msg}"),
                    |this| gst::info!(CAT, imp: this, "{msg}")
                );
            }));

        let mut state = self.state.lock().unwrap();
        state.ws_sender = Some(ws_sender);
        state.send_task_handle = Some(send_task_handle);
        state.recv_task_handle = Some(recv_task_handle);

        Ok(())
    }

    fn handle_msg(
        &self,
        msg: Result<WsMessage, async_tungstenite::tungstenite::Error>,
    ) -> ControlFlow<()> {
        match msg {
            Ok(WsMessage::Text(msg)) => {
                gst::trace!(CAT, imp: self, "Received message {}", msg);
                if let Ok(reply) = serde_json::from_str::<JsonReply>(&msg) {
                    self.handle_reply(reply);
                } else {
                    gst::error!(CAT, imp: self, "Unknown message from server: {}", msg);
                }
            }
            Ok(WsMessage::Close(reason)) => {
                gst::info!(CAT, imp: self, "websocket connection closed: {:?}", reason);
                return ControlFlow::Break(());
            }
            Ok(_) => (),
            Err(err) => {
                self.raise_error(err.to_string());
                return ControlFlow::Break(());
            }
        }
        ControlFlow::Continue(())
    }

    fn handle_reply(&self, reply: JsonReply) {
        match reply {
            JsonReply::WebRTCUp => {
                gst::trace!(CAT, imp: self, "WebRTC streaming is working!");
            }
            JsonReply::Success(success) => {
                if let Some(data) = success.data {
                    if success.session_id.is_none() {
                        gst::trace!(CAT, imp: self, "Janus session {} was created successfully", data.id);
                        self.set_session_id(data.id);
                        self.attach_plugin();
                    } else {
                        gst::trace!(CAT, imp: self, "Attached to Janus Video Room plugin successfully, handle: {}", data.id);
                        self.set_handle_id(data.id);
                        self.join_room();
                    }
                }
            }
            JsonReply::Event(event) => {
                if let Some(PluginData::VideoRoom { data: plugindata }) = event.plugindata {
                    match plugindata {
                        VideoRoomData::Joined(joined) => {
                            gst::trace!(CAT, imp: self, "Joined room {:?} successfully", joined.room);
                            self.session_requested();
                        }
                        VideoRoomData::Event(room_event) => {
                            if room_event.error_code.is_some() && room_event.error.is_some() {
                                self.raise_error(format!(
                                    "code: {}, reason: {}",
                                    room_event.error_code.unwrap(),
                                    room_event.error.unwrap(),
                                ));
                                return;
                            }

                            if let Some(jsep) = event.jsep {
                                if jsep.r#type == "answer" {
                                    gst::trace!(CAT, imp: self, "Session requested successfully");
                                    self.handle_answer(jsep.sdp);
                                }
                            }
                        }
                        VideoRoomData::Destroyed(room_destroyed) => {
                            gst::trace!(CAT, imp: self, "Room {} has been destroyed", room_destroyed.room);

                            self.raise_error(format!(
                                "room {} has been destroyed",
                                room_destroyed.room
                            ));
                        }
                    }
                }
            }
            JsonReply::Error(error) => {
                self.raise_error(format!("code: {}, reason: {}", error.code, error.reason))
            }
            JsonReply::HangUp(hangup) => self.raise_error(format!("hangup: {}", hangup.reason)),
            // ignore for now
            JsonReply::Ack | JsonReply::Media => {}
        }
    }

    fn send(&self, msg: OutgoingMessage) {
        let state = self.state.lock().unwrap();
        if let Some(mut sender) = state.ws_sender.clone() {
            RUNTIME.spawn(glib::clone!(@weak self as this => async move {
                if let Err(err) = sender.send(msg).await {
                    this.raise_error(err.to_string());
                }
            }));
        }
    }

    // Only used at the end when cleaning up the resources.
    // So that `SignallableImpl::stop` waits the last message
    // to be sent properly.
    fn send_blocking(&self, msg: OutgoingMessage) {
        let state = self.state.lock().unwrap();
        if let Some(mut sender) = state.ws_sender.clone() {
            RUNTIME.block_on(glib::clone!(@weak self as this => async move {
                if let Err(err) = sender.send(msg).await {
                    this.raise_error(err.to_string());
                }
            }));
        }
    }

    fn set_transaction_id(&self, transaction: String) {
        self.state.lock().unwrap().transaction_id = Some(transaction);
    }

    fn create_session(&self) {
        let transaction = transaction_id();
        self.set_transaction_id(transaction.clone());
        let settings = self.settings.lock().unwrap();
        let apisecret = settings.secret_key.clone();
        self.send(OutgoingMessage::CreateSession(CreateSessionMsg {
            janus: "create".to_string(),
            transaction,
            apisecret,
        }));
    }

    fn set_session_id(&self, session_id: u64) {
        self.state.lock().unwrap().session_id = Some(session_id);
    }

    fn set_handle_id(&self, handle_id: u64) {
        self.state.lock().unwrap().handle_id = Some(handle_id);
    }

    fn attach_plugin(&self) {
        let (transaction, session_id, apisecret) = {
            let state = self.state.lock().unwrap();
            let settings = self.settings.lock().unwrap();

            (
                state.transaction_id.clone().unwrap(),
                state.session_id.unwrap(),
                settings.secret_key.clone(),
            )
        };
        self.send(OutgoingMessage::AttachPlugin(AttachPluginMsg {
            janus: "attach".to_string(),
            transaction,
            plugin: "janus.plugin.videoroom".to_string(),
            session_id,
            apisecret,
        }));
    }

    fn join_room(&self) {
        let (transaction, session_id, handle_id, room, feed_id, display, apisecret) = {
            let mut state = self.state.lock().unwrap();
            let settings = self.settings.lock().unwrap();

            if settings.room_id.is_none() {
                self.raise_error("Janus Room ID must be set".to_string());
                return;
            }

            /* room_id and feed_id can be either a string or integer depending
             * on server configuration. The property is always a string, if we
             * can parse it to integer then assume that's what the server expects,
             * unless string-ids=true is set to force usage of strings.
             * Save parsed value in state to not have to parse it again for future
             * API calls.
             */
            if settings.string_ids {
                state.room_id = Some(JanusId::Str(settings.room_id.clone().unwrap()));
                state.feed_id = Some(JanusId::Str(settings.feed_id.clone()));
            } else {
                let room_id_str = settings.room_id.as_ref().unwrap();
                match room_id_str.parse() {
                    Ok(n) => {
                        state.room_id = Some(JanusId::Num(n));
                        state.feed_id = Some(JanusId::Num(settings.feed_id.parse().unwrap()));
                    }
                    Err(_) => {
                        state.room_id = Some(JanusId::Str(room_id_str.clone()));
                        state.feed_id = Some(JanusId::Str(settings.feed_id.clone()));
                    }
                };
            }

            (
                state.transaction_id.clone().unwrap(),
                state.session_id.unwrap(),
                state.handle_id.unwrap(),
                state.room_id.clone().unwrap(),
                state.feed_id.clone().unwrap(),
                settings.display_name.clone(),
                settings.secret_key.clone(),
            )
        };
        self.send(OutgoingMessage::RoomRequest(RoomRequestMsg {
            janus: "message".to_string(),
            transaction,
            session_id,
            handle_id,
            apisecret,
            body: RoomRequestBody {
                request: "join".to_string(),
                ptype: "publisher".to_string(),
                room,
                id: feed_id,
                display,
            },
        }));
    }

    fn leave_room(&self) {
        let (transaction, session_id, handle_id, room, feed_id, display, apisecret) = {
            let state = self.state.lock().unwrap();
            let settings = self.settings.lock().unwrap();

            if settings.room_id.is_none() {
                self.raise_error("Janus Room ID must be set".to_string());
                return;
            }

            (
                state.transaction_id.clone().unwrap(),
                state.session_id.unwrap(),
                state.handle_id.unwrap(),
                state.room_id.clone().unwrap(),
                state.feed_id.clone().unwrap(),
                settings.display_name.clone(),
                settings.secret_key.clone(),
            )
        };
        self.send_blocking(OutgoingMessage::RoomRequest(RoomRequestMsg {
            janus: "message".to_string(),
            transaction,
            session_id,
            handle_id,
            apisecret,
            body: RoomRequestBody {
                request: "leave".to_string(),
                ptype: "publisher".to_string(),
                room,
                id: feed_id,
                display,
            },
        }));
    }

    fn publish(&self, offer: &gst_webrtc::WebRTCSessionDescription) {
        let (transaction, session_id, handle_id, apisecret) = {
            let state = self.state.lock().unwrap();
            let settings = self.settings.lock().unwrap();

            if settings.room_id.is_none() {
                self.raise_error("Janus Room ID must be set".to_string());
                return;
            }

            (
                state.transaction_id.clone().unwrap(),
                state.session_id.unwrap(),
                state.handle_id.unwrap(),
                settings.secret_key.clone(),
            )
        };
        let sdp_data = offer.sdp().as_text().unwrap();
        self.send(OutgoingMessage::Publish(PublishMsg {
            janus: "message".to_string(),
            transaction,
            session_id,
            handle_id,
            apisecret,
            body: PublishBody {
                request: "publish".to_string(),
            },
            jsep: Jsep {
                sdp: sdp_data,
                trickle: Some(true),
                r#type: "offer".to_string(),
            },
        }));
    }

    fn trickle(&self, candidate: &str, sdp_m_line_index: u32) {
        let (transaction, session_id, handle_id, apisecret) = {
            let state = self.state.lock().unwrap();
            let settings = self.settings.lock().unwrap();

            if settings.room_id.is_none() {
                self.raise_error("Janus Room ID must be set".to_string());
                return;
            }

            (
                state.transaction_id.clone().unwrap(),
                state.session_id.unwrap(),
                state.handle_id.unwrap(),
                settings.secret_key.clone(),
            )
        };
        self.send(OutgoingMessage::Trickle(TrickleMsg {
            janus: "trickle".to_string(),
            transaction,
            session_id,
            handle_id,
            apisecret,
            candidate: Candidate {
                candidate: candidate.to_string(),
                sdp_m_line_index,
            },
        }));
    }

    fn session_requested(&self) {
        self.obj().emit_by_name::<()>(
            "session-requested",
            &[
                &"unique",
                &"unique",
                &None::<gst_webrtc::WebRTCSessionDescription>,
            ],
        );
    }

    fn handle_answer(&self, sdp: String) {
        match gst_sdp::SDPMessage::parse_buffer(sdp.as_bytes()) {
            Ok(ans_sdp) => {
                let answer = gst_webrtc::WebRTCSessionDescription::new(
                    gst_webrtc::WebRTCSDPType::Answer,
                    ans_sdp,
                );
                self.obj()
                    .emit_by_name::<()>("session-description", &[&"unique", &answer]);
            }
            Err(err) => {
                self.raise_error(format!("Could not parse answer SDP: {err}"));
            }
        }
    }
}

impl SignallableImpl for Signaller {
    fn start(&self) {
        let this = self.obj().clone();
        let imp = self.downgrade();
        RUNTIME.spawn(async move {
            if let Some(imp) = imp.upgrade() {
                if let Err(err) = imp.connect().await {
                    this.emit_by_name::<()>("error", &[&format!("{:?}", anyhow!(err))]);
                } else {
                    imp.create_session();
                }
            }
        });
    }

    fn send_sdp(&self, _session_id: &str, offer: &gst_webrtc::WebRTCSessionDescription) {
        gst::info!(CAT, imp: self, "sending SDP offer to peer: {:?}", offer.sdp().as_text());

        self.publish(offer);
    }

    fn add_ice(
        &self,
        _session_id: &str,
        candidate: &str,
        sdp_m_line_index: u32,
        _sdp_mid: Option<String>,
    ) {
        self.trickle(candidate, sdp_m_line_index);
    }

    fn stop(&self) {
        gst::info!(CAT, imp: self, "Stopping now");
        let mut state = self.state.lock().unwrap();

        let send_task_handle = state.send_task_handle.take();
        let recv_task_handle = state.recv_task_handle.take();

        if let Some(mut sender) = state.ws_sender.take() {
            RUNTIME.block_on(async move {
                sender.close_channel();

                if let Some(handle) = send_task_handle {
                    if let Err(err) = handle.await {
                        gst::warning!(CAT, imp: self, "Error while joining send task: {}", err);
                    }
                }

                if let Some(handle) = recv_task_handle {
                    // if awaited instead, it hangs the plugin
                    handle.abort();
                }
            });
        }

        state.session_id = None;
        state.handle_id = None;
        state.transaction_id = None;
    }

    fn end_session(&self, _session_id: &str) {
        self.leave_room();
    }
}

#[glib::object_subclass]
impl ObjectSubclass for Signaller {
    const NAME: &'static str = "GstJanusVRWebRTCSignaller";
    type Type = super::JanusVRSignaller;
    type ParentType = glib::Object;
    type Interfaces = (Signallable,);
}

#[glib::derived_properties]
impl ObjectImpl for Signaller {}
