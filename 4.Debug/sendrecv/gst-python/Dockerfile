FROM hexaforce/gstreamer-base:1.24.10

RUN apt-get update && apt-get install -yq \
  python3.11-venv

RUN python3 -m venv webrtc
ENV PATH="/webrtc/bin:$PATH"

ENV PYTHONPATH=/usr/lib/python3/dist-packages

# It is not compatible with version 11 or later.
RUN pip3 install websockets==10.4
RUN pip3 install pygobject

WORKDIR /opt/
COPY . /opt/
