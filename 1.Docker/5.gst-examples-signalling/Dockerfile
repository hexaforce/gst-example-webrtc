FROM python:slim-bookworm

# It is not compatible with version 11 or later.
RUN pip3 install --user websockets==10.4

WORKDIR /opt/
COPY . /opt/

EXPOSE 8443
CMD python -u ./simple_server.py --disable-ssl --health /health-check
