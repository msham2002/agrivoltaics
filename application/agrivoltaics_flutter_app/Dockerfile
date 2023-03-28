# Install Operating system and dependencies
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Define build arguments to be populated by build command (--build-arg BUILD_ARG=value)
ARG INFLUXDB_URL
RUN echo $INFLUXDB_URL
ARG INFLUXDB_TOKEN
ARG INFLUXDB_ORG
ARG INFLUXDB_BUCKET
ARG INFLUXDB_DEBUG
ARG ADMIN_EMAIL
ARG OWNER_EMAIL

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter build web --dart-define=INFLUXDB_URL=${INFLUXDB_URL} \
--dart-define=INFLUXDB_TOKEN=${INFLUXDB_TOKEN} \
--dart-define=INFLUXDB_ORG=${INFLUXDB_ORG} \
--dart-define=INFLUXDB_BUCKET=${INFLUXDB_BUCKET} \
--dart-define=INFLUXDB_DEBUG=${INFLUXDB_DEBUG} \
--dart-define=ADMIN_EMAIL=${ADMIN_EMAIL} \
--dart-define=OWNER_EMAIL=${OWNER_EMAIL}

# Record the exposed port
EXPOSE 5000

# make server startup script executable and start the web server
RUN ["chmod", "+x", "/app/server/server.sh"]

ENTRYPOINT [ "/app/server/server.sh"]