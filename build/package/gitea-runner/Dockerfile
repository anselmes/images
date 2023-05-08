FROM golang:1.20-alpine3.17 AS build-env

ARG GOPROXY
ENV GOPROXY ${GOPROXY:-direct}

ARG CGO_EXTRA_CFLAGS

RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm
RUN git clone --depth=1 https://gitea.com/gitea/act_runner.git \
  && cd act_runner \
  && make build

FROM alpine:3.17

WORKDIR /var/lib/gitea

ENV HOME "/var/lib/gitea/git"
ENV TMPDIR /tmp/gitea

COPY --from=build-env --chown=root:root /go/act_runner/act_runner /app/gitea/act_runner

# FIXME: pin version
RUN apk add --no-cache \
  bash \
  ca-certificates \
  dumb-init \
  gettext \
  git \
  curl \
  gnupg
RUN addgroup \
  -S -g 1000 \
  git && \
  adduser \
  -S -H -D \
  -h /var/lib/gitea/git \
  -s /bin/bash \
  -u 1000 \
  -G git \
  git
RUN mkdir -p /var/lib/gitea /etc/gitea \
  && chown git:git /var/lib/gitea /etc/gitea

USER 1000:1000

VOLUME ["/var/lib/gitea", "/etc/gitea"]

ENTRYPOINT ["act_runner"]
CMD []
