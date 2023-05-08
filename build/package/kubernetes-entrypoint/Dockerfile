FROM docker.io/golang:1.20.4-buster as builder

ARG MAKE_TARGET=build

ENV GO111MODULE=on
SHELL [ "/bin/bash", "-cex" ]

RUN git clone --depth=1 https://github.com/airshipit/kubernetes-entrypoint.git
WORKDIR /kubernetes-entrypoint

RUN make get-modules \
  && make ${MAKE_TARGET}

FROM ubuntu:22.04 as release
COPY --from=builder \
  /kubernetes-entrypoint/bin/kubernetes-entrypoint \
  /usr/local/bin/kubernetes-entrypoint

RUN apt-get update -qq \
  && apt-get install -y \
  coreutils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER 65534
ENTRYPOINT [ "/usr/local/bin/kubernetes-entrypoint" ]
