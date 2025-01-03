FROM hexaforce/gstreamer:1.24.10 as gstreamer

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=gstreamer /usr/bin/gst-webrtc-signalling-server /usr/bin/gst-webrtc-signalling-server

EXPOSE 18443
CMD ["/bin/sh", "-c", "/usr/bin/gst-webrtc-signalling-server & nginx -g 'daemon off;'"]
