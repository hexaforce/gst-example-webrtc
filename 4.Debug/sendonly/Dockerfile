# docker build . -t hexaforce/gstreamer-gst
# docker run -it -e PEER_ID=1 -e SERVER=wss://signalling.hexaforce.io hexaforce/gstreamer-gst

FROM hexaforce/gstreamer-base:1.24.10

WORKDIR /opt/
COPY . /opt/

RUN make

# CMD echo "Waiting a few seconds for you to open the browser at localhost:8080" \
#     # && sleep 10 \
    # && ./webrtc-sendrecv \
    # --peer-id=${PEER_ID} \
    # # --server=${SERVER} \
    # --server=ws://signalling:8443 \
    # --disable-ssl
