# docker build . -t hexaforce/gstreamer-builder:1.24.10

FROM rust:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf `# build tools` \
  automake `# build tools` \
  bison `# build tools` \
  build-essential `# build tools` \
  ca-certificates \
  flex `# build tools` \
  gettext \
  git \
  cmake \
  libc6-dev \
  libunwind-dev \
  libdw-dev \
  libgsl-dev \
  bash-completion \
  libcap-dev \
  libgtk-3-dev \
  libcap2-bin \
  valgrind \
  libdrm-dev \
  liborc-0.4-dev \
  iso-codes \
  libasound2-dev \
  libcdparanoia-dev \
  libvisual-0.4-dev \
  libvorbis-dev \
  libxv-dev \
  libsodium-dev \
  libsdl2-dev \
  qtbase5-dev \
  qtdeclarative5-dev \
  cdparanoia \
  libgupnp-igd-1.0-dev \
  qttools5-dev-tools \
  libqt5opengl5-dev \
  qt5-qmake \
  qt6-5compat-dev \
  nasm \
  libv4l-dev \
  libaa1-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libflac-dev \
  libdv4-dev \
  libmpg123-dev \
  libraw1394-dev \
  libavc1394-dev \
  libiec61883-dev \
  libshout3-dev \
  libspeex-dev \
  libtag1-dev \
  libtwolame-dev \
  libwavpack-dev \
  libjack-jackd2-dev \
  libgudev-1.0-dev \
  libx11-xcb-dev \
  libvorbisidec-dev \
  libcaca-dev \
  qmake6 \
  qt6-base-dev \
  libcgroup-dev \
  libopencv-dev \
  libva-dev \
  libusb-1.0-0-dev \
  libssh2-1-dev \
  libdirectfb-dev \
  libmodplug-dev \
  libjpeg-dev \
  libcdio-dev \
  libmpeg2-4-dev \
  libdca-dev \
  libfaad-dev \
  libfluidsynth-dev \
  libgme-dev \
  libgsm1-dev \
  mjpegtools \
  libneon27-gnutls-dev \
  libopenal-dev \
  libfreeaptx-dev \
  libopenaptx-dev \
  libxkbcommon-x11-dev \
  libltc-dev \
  bluez \
  libsrt-openssl-dev \
  libass-dev \
  libbs2b-dev \
  libchromaprint-dev \
  liblilv-dev \
  libmjpegtools-dev \
  libopenmpt-dev \
  libopenni2-dev \
  libqrencode-dev \
  libdvdnav-dev \
  libdvdread-dev \
  librtmp-dev \
  libsbc-dev \
  libsoundtouch-dev \
  libspandsp-dev \
  libzvbi-dev \
  libvo-aacenc-dev \
  libvo-amrwbenc-dev \
  libwebrtc-audio-processing-dev \
  libwildmidi-dev \
  libzbar-dev \
  gnutls-dev `# libnice` \
  gtk-doc-tools `# documentation tools` \
  libffi-dev \
  libglib2.0-dev `# GStreamer dependencies` \
  libnice-dev `# libnice for WebRTC` \
  libsoup2.4-dev `# HTTP library for GStreamer` \
  libsrtp2-dev `# Secure RTP for WebRTC` \
  libssl-dev `# SSL/TLS for DTLS` \
  libtool `# build tools` \
  ninja-build `# build tools` \
  python3-dev `# Python bindings` \
  python3-pip `# Python package manager` \
  python-gi-dev `# Python GObject introspection` \
  wget \
  zlib1g `# compression library` \
  mount `# system utility` \
  perl \
  libpcre3-dev `# PCRE (Perl Compatible Regular Expressions)` \
  libavfilter-dev `# FFMpeg filters` \
  libavcodec-dev `# FFMpeg codecs` \
  libavformat-dev `# FFMpeg format support` \
  libswscale-dev `# FFMpeg scaling support` \
  libpostproc-dev `# FFMpeg post-processing` \
  libavutil-dev `# FFMpeg utility functions` \
  libswresample-dev `# FFMpeg resampling` \
  libaom-dev `# AV1 codec` \
  libdav1d-dev `# AV1 decoder` \
  libgav1-dev `# AV1 decoder` \
  librav1e-dev `# AV1 encoder` \
  libsvtav1-dev `# Scalable Video Technology for AV1` \
  libvpx-dev `# VP8/VP9 codec` \
  x264 `# H.264 encoder` \
  libx264-dev `# H.264 encoder` \
  x265 `# H.265 encoder` \
  libx265-dev `# H.265 encoder` \
  libde265-dev `# H.265 decoder` \
  libopenh264-dev `# H.264 decoder` \
  libmp3lame-dev `# MP3 encoder` \
  libopus-dev `# Opus codec` \
  libtheora-dev `# Theora codec` \
  libpng-dev `# PNG codec`

RUN apt-get remove --purge libsoup-3.0-dev -y
RUN pip3 install --break-system-packages meson