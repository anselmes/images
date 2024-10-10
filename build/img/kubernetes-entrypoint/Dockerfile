# SPDX-License-Identifier: GPL-3.0

ARG BUILD_IMAGE=golang:1.22-alpine
ARG BASE_IMAGE=ubuntu:24.04

FROM ${BUILD_IMAGE} AS builder
ARG MAKE_TARGET=build
ENV GO111MODULE=on
RUN apk add --no-cache \
  bash \
  build-base \
  git \
  make \
  && git clone --depth=1 https://github.com/airshipit/kubernetes-entrypoint.git /kubernetes-entrypoint
WORKDIR /kubernetes-entrypoint
RUN make get-modules \
  && make ${MAKE_TARGET}

FROM ${BASE_IMAGE}

COPY --from=builder \
  /kubernetes-entrypoint/bin/kubernetes-entrypoint \
  /usr/local/bin/kubernetes-entrypoint

RUN apt-get update -qq \
  && apt-get install -y coreutils \
  && apt-get clean \
  && rm -rf \
  /var/cache/debconf/* \
  /var/lib/apt/lists/*

USER 65534
ENTRYPOINT [ "/usr/local/bin/kubernetes-entrypoint" ]
HEALTHCHECK NONE
