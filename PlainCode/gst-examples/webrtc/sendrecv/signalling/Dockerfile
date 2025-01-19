FROM python:slim-bookworm

WORKDIR /opt/
COPY . /opt/

# It is not compatible with version 11 or later.
RUN pip3 install --user websockets==10.4

CMD python -u ./server.py
