FROM ghcr.io/linuxserver/baseimage-alpine:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BAZARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"
# hard set UTC in case the user does not define it
ENV TZ="Etc/UTC"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    g++ \
    gcc \
    libxml2-dev \
    libxslt-dev \
    py3-pip \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    curl \
    ffmpeg \
    libxml2 \
    libxslt \
    python3 \
    unrar \
    unzip && \
  echo "**** install bazarr ****" && \
  if [ -z ${BAZARR_VERSION+x} ]; then \
    BAZARR_VERSION=v0.9.4 \
  fi && \
  curl -o \
    /tmp/master.zip -L \
    "https://github.com/derinbay/bazarr/archive/refs/heads/master.zip" && \
  mkdir -p \
    /app/bazarr/bin && \
  unzip \
    /tmp/master.zip -d \
    /app/bazarr/bin && \
  rm -Rf /app/bazarr/bin/bin && \
  echo "UpdateMethod=docker\nBranch=master\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/bazarr/package_info && \
  echo "**** Install requirements ****" && \
  pip3 install --no-cache-dir -U  -r \
    /app/bazarr/bin/requirements.txt && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY root/ /

#  ports and volumes
EXPOSE 6767
VOLUME /config
