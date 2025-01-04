FROM hexaforce/gstreamer-base:1.24.10

RUN apt-get update && apt-get install -yq \
  libjson-glib-dev \
  libgtk-4-1 \
  libegl1 \
  libxdamage1 \
  libxi6 \
  libgraphene-1.0-0 \
  libwayland-cursor0 \
  python3.11-venv \
  libcairo2-dev \
  libgirepository1.0-dev

RUN python3 -m venv webrtc
ENV PATH="/webrtc/bin:$PATH"

ENV PYTHONPATH=/usr/lib/python3/dist-packages

# It is not compatible with version 11 or later.
RUN pip3 install websockets==10.4
RUN pip3 install pygobject

WORKDIR /opt/
COPY . /opt/

CMD echo "Waiting a few seconds for you to open the browser at localhost:8080" \
    && sleep 10 \
    && python -u ./webrtc_sendrecv.py \
    --peer-id=1 \
    --server=ws://signalling:8443
