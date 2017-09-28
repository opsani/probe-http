FROM alpine:latest

LABEL maintainer "Opsani <support@opsani.com>"

WORKDIR /skopos

RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add --update --no-cache \
        ca-certificates \
        python3 \
        py3-requests && \
    rm -rf /var/cache/apk/*

COPY probe-http /skopos/

ADD probe_common /skopos/probe_common

ENTRYPOINT [ "python3", "probe-http" ]
