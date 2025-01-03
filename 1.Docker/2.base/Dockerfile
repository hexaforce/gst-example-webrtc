FROM hexaforce/gstreamer-builder:1.24.10

ARG GST_VERSION=1.24.10

# http://www.linuxfromscratch.org/blfs/view/svn/multimedia/gstreamer10.html
RUN wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$GST_VERSION.tar.xz \
 && tar xvfJ gstreamer-$GST_VERSION.tar.xz > /dev/null \
 && cd gstreamer-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-plugins-base
RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-$GST_VERSION.tar.xz \
 && tar xvfJ gst-plugins-base-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-plugins-base-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# libnice
RUN git clone https://github.com/libnice/libnice.git \
 && cd libnice \
 && PATH=~/.local/bin:$PATH meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-plugins-good
RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-$GST_VERSION.tar.xz \
 && tar xvfJ gst-plugins-good-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-plugins-good-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-plugins-bad
RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-$GST_VERSION.tar.xz \
 && tar xvfJ gst-plugins-bad-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-plugins-bad-$GST_VERSION \
 && meson --prefix=/usr -Dgpl=enabled -Ddtls=enabled build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-plugins-ugly
RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-$GST_VERSION.tar.xz \
 && tar xvfJ gst-plugins-ugly-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-plugins-ugly-$GST_VERSION \
 && meson --prefix=/usr -Dgpl=enabled build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-omx
# RUN wget https://gstreamer.freedesktop.org/src/gst-omx/gst-omx-$GST_VERSION.tar.xz \
#  && tar xvfJ gst-omx-$GST_VERSION.tar.xz > /dev/null \
#  && cd gst-omx-$GST_VERSION \
#  && meson --prefix=/usr -Dgpl=enabled build && ninja -C build && ninja -C build -v install \
#  && cd / 

# gst-rtsp-server
RUN wget https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-$GST_VERSION.tar.xz \
 && tar xvfJ gst-rtsp-server-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-rtsp-server-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-rtsp
# RUN wget https://gstreamer.freedesktop.org/src/gst-rtsp/gst-rtsp-$GST_VERSION.tar.xz \
#  && tar xvfJ gst-rtsp-$GST_VERSION.tar.xz > /dev/null \
#  && cd gst-rtsp-$GST_VERSION \
#  && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
#  && cd / 

# gst-libav
RUN wget https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-$GST_VERSION.tar.xz \
 && tar xvfJ gst-libav-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-libav-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 

# gst-python
RUN wget https://gstreamer.freedesktop.org/src/gst-python/gst-python-$GST_VERSION.tar.xz \
 && tar xvfJ gst-python-$GST_VERSION.tar.xz > /dev/null \
 && cd gst-python-$GST_VERSION \
 && meson --prefix=/usr build && ninja -C build && ninja -C build -v install \
 && cd / 
