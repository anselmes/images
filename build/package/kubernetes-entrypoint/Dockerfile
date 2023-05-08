FROM docker.io/golang:1.20.4-buster as builder

SHELL [ "/bin/bash", "-cex" ]

RUN git clone https://github.com/stackanetes/kubernetes-entrypoint.git /usr/src/kubernetes-entrypoint

WORKDIR /usr/src/kubernetes-entrypoint
ENV GO111MODULE=on

RUN make get-modules

ARG MAKE_TARGET=build
RUN make ${MAKE_TARGET}

FROM ubuntu:22.04 as release
COPY --from=builder \
  /usr/src/kubernetes-entrypoint/bin/kubernetes-entrypoint \
  /usr/local/bin/kubernetes-entrypoint

RUN apt update -y
RUN apt install -y \
  --no-install-recommends \
  coreutils

USER 65534
ENTRYPOINT [ "/usr/local/bin/kubernetes-entrypoint" ]
