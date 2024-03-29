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
ARG ALPINE_IMAGE=3.17

FROM ${BUILD_IMAGE} as builder

ARG GOPROXY
ARG CGO_EXTRA_CFLAGS

ENV GOPROXY ${GOPROXY:-direct}


ARG GOPROXY
ARG CGO_EXTRA_CFLAGS

ENV GOPROXY ${GOPROXY:-direct}

RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm \
  && git clone --depth=1 https://gitea.com/gitea/act_runner.git /act_runner
WORKDIR /act_runner
RUN make build

FROM ${ALPINE_IMAGE}

LABEL org.opencontainers.image.authors="Schubert Anselme <schubert@anselm.es>"
LABEL org.opencontainers.image.url="https://github.com/sanselme/images"
LABEL org.opencontainers.image.documentation="https://github.com/sanselme/images"
LABEL org.opencontainers.image.source="https://github.com/sanselme/images"
LABEL org.opencontainers.image.vendor="Schubert Anselme"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV HOME /var/lib/gitea/git
ENV TMPDIR /tmp/gitea

WORKDIR /var/lib/gitea

COPY --from=builder --chown=root:root /act_runner/act_runner /usr/local/bin/act_runner


FROM ${ALPINE_IMAGE}

LABEL org.opencontainers.image.authors="Schubert Anselme <schubert@anselm.es>"
LABEL org.opencontainers.image.url="https://github.com/sanselme/images"
LABEL org.opencontainers.image.documentation="https://github.com/sanselme/images"
LABEL org.opencontainers.image.source="https://github.com/sanselme/images"
LABEL org.opencontainers.image.vendor="Schubert Anselme"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV HOME /var/lib/gitea/git
ENV TMPDIR /tmp/gitea

WORKDIR /var/lib/gitea

COPY --from=builder --chown=root:root /act_runner/act_runner /usr/local/bin/act_runner

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
ENTRYPOINT ["/usr/local/bin/act_runner"]
