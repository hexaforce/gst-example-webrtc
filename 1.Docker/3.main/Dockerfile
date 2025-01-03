FROM hexaforce/gstreamer-base:1.24.10

ARG GST_VERSION=1.24.10

RUN cargo install cargo-c 

# gst-plugins-rs
RUN wget https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/archive/gstreamer-$GST_VERSION/gst-plugins-rs-gstreamer-$GST_VERSION.tar.gz \
 && tar -xvf gst-plugins-rs-gstreamer-$GST_VERSION.tar.gz > /dev/null \
 && cd gst-plugins-rs-gstreamer-$GST_VERSION \
 \
#&& cargo cbuild -p gst-plugin-cdg --prefix=/usr && cargo cinstall -p gst-plugin-cdg --prefix=/usr -v \
 && meson --prefix=/usr build && ninja -C build -j$(nproc) && ninja -C build -v install \
 && cd / \
 && rm -rf gst* 
