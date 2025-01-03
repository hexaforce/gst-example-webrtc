FROM maven:3.8.6-openjdk-11 as builder
WORKDIR /work
COPY . /work
RUN mvn clean package -DskipTests

FROM hexaforce/gstreamer-base:1.24.10

RUN apt-get update && apt-get install -yq \
  openjdk-17-jre-headless

COPY --from=builder /work/target/gst-java-0.9.4-SNAPSHOT-jar-with-dependencies.jar /gst-java.jar
