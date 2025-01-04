# START BUILD PHASE
FROM maven:3.8.6-openjdk-11 as builder
WORKDIR /work
COPY . /work
RUN mvn clean package -DskipTests
# END BUILD PHASE

FROM hexaforce/gstreamer-base:1.24.10

RUN apt-get update && apt-get install -yq \
  libjson-glib-dev \
  libgtk-4-1 \
  libegl1 \
  libxdamage1 \
  libxi6 \
  libgraphene-1.0-0 \
  libwayland-cursor0 \
  openjdk-17-jre-headless

COPY --from=builder /work/target/gst-java-0.9.4-SNAPSHOT-jar-with-dependencies.jar /gst-java.jar

CMD echo "Waiting a few seconds for you to open the browser at localhost:8080" \
    && sleep 10 \
    && java -jar /gst-java.jar \
    --peer-id=1 \
    --server=ws://signalling:8443
