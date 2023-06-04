# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

ARG BUILD_IMAGE=golang:1.20-alpine
ARG BASE_IMAGE=ubuntu:20.04

FROM ${BUILD_IMAGE} as builder

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

LABEL org.opencontainers.image.authors="Schubert Anselme <schubert@anselm.es>"
LABEL org.opencontainers.image.url="https://github.com/sanselme/images"
LABEL org.opencontainers.image.documentation="https://github.com/sanselme/images"
LABEL org.opencontainers.image.source="https://github.com/sanselme/images"
LABEL org.opencontainers.image.vendor="Schubert Anselme"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

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
