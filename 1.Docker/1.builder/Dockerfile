FROM rust:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
autoconf `# build tools` \
automake `# build tools` \
bash-completion \
bison `# build tools` \
bluez \
build-essential `# build tools` \
ca-certificates \
cdparanoia \
cmake \
flex `# build tools` \
gettext \
git \
gnutls-dev `# libnice` \
gtk-doc-tools `# documentation tools` \
iso-codes \
libaa1-dev \
libaom-dev `# AV1 codec` \
libasound2-dev \
libass-dev \
libavc1394-dev \
libavcodec-dev `# FFMpeg codecs` \
libavfilter-dev `# FFMpeg filters` \
libavformat-dev `# FFMpeg format support` \
libavutil-dev `# FFMpeg utility functions` \
libbs2b-dev \
libc6-dev \
libcaca-dev \
libcap-dev \
libcap2-bin \
libcdio-dev \
libcdparanoia-dev \
libcgroup-dev \
libchromaprint-dev \
libdav1d-dev `# AV1 decoder` \
libdca-dev \
libde265-dev `# H.265 decoder` \
libdirectfb-dev \
libdrm-dev \
libdv4-dev \
libdvdnav-dev \
libdvdread-dev \
libdw-dev \
libfaad-dev \
libffi-dev \
libflac-dev \
libfluidsynth-dev \
libfreeaptx-dev \
libgav1-dev `# AV1 decoder` \
libglib2.0-dev `# GStreamer dependencies` \
libgme-dev \
libgsl-dev \
libgsm1-dev \
libgtk-3-dev \
libgudev-1.0-dev \
libgupnp-igd-1.0-dev \
libiec61883-dev \
libjack-jackd2-dev \
libjpeg-dev \
liblilv-dev \
libltc-dev \
libmjpegtools-dev \
libmodplug-dev \
libmp3lame-dev `# MP3 encoder` \
libmpeg2-4-dev \
libmpg123-dev \
libneon27-gnutls-dev \
libnice-dev `# libnice for WebRTC` \
libopenal-dev \
libopenaptx-dev \
libopencore-amrnb-dev \
libopencore-amrwb-dev \
libopencv-dev \
libopenh264-dev `# H.264 decoder` \
libopenmpt-dev \
libopenni2-dev \
libopus-dev `# Opus codec` \
liborc-0.4-dev \
libpcre3-dev `# PCRE (Perl Compatible Regular Expressions)` \
libpng-dev `# PNG codec` \
libpostproc-dev `# FFMpeg post-processing` \
libqrencode-dev \
libqt5opengl5-dev \
librav1e-dev `# AV1 encoder` \
libraw1394-dev \
librtmp-dev \
libsbc-dev \
libsdl2-dev \
libshout3-dev \
libsodium-dev \
libsoundtouch-dev \
libsoup2.4-dev `# HTTP library for GStreamer` \
libspandsp-dev \
libspeex-dev \
libsrt-openssl-dev \
libsrtp2-dev `# Secure RTP for WebRTC` \
libssh2-1-dev \
libssl-dev `# SSL/TLS for DTLS` \
libsvtav1-dev `# Scalable Video Technology for AV1` \
libswresample-dev `# FFMpeg resampling` \
libswscale-dev `# FFMpeg scaling support` \
libtag1-dev \
libtheora-dev `# Theora codec` \
libtool `# build tools` \
libtwolame-dev \
libunwind-dev \
libusb-1.0-0-dev \
libv4l-dev \
libva-dev \
libvisual-0.4-dev \
libvo-aacenc-dev \
libvo-amrwbenc-dev \
libvorbis-dev \
libvorbisidec-dev \
libvpx-dev `# VP8/VP9 codec` \
libwavpack-dev \
libwebrtc-audio-processing-dev \
libwildmidi-dev \
libx11-xcb-dev \
libx264-dev `# H.264 encoder` \
libx265-dev `# H.265 encoder` \
libxkbcommon-x11-dev \
libxv-dev \
libzbar-dev \
libzvbi-dev \
mjpegtools \
mount `# system utility` \
nasm \
ninja-build `# build tools` \
perl \
python-gi-dev `# Python GObject introspection` \
python3-dev `# Python bindings` \
python3-openssl \
python3-pip `# Python package manager` \
qmake6 \
qt5-qmake \
qt6-5compat-dev \
qt6-base-dev \
qtbase5-dev \
qtdeclarative5-dev \
qttools5-dev-tools \
valgrind \
wget \
x264 `# H.264 encoder` \
x265 `# H.265 encoder` \
zlib1g `# compression library`

RUN apt-get remove --purge libsoup-3.0-dev -y
RUN pip3 install --break-system-packages meson
