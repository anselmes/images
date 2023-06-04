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

FROM golang:1.20-alpine3.17 AS build-env

ARG GOPROXY
ENV GOPROXY ${GOPROXY:-direct}

ARG CGO_EXTRA_CFLAGS

RUN apk add build-base git nodejs npm
RUN git clone https://gitea.com/gitea/act_runner.git && \
  cd act_runner && \
  make build

FROM alpine:3.17
LABEL maintainer="maintainers@gitea.io"

WORKDIR /var/lib/gitea

ENV HOME "/var/lib/gitea/git"
ENV TMPDIR /tmp/gitea

COPY --from=build-env --chown=root:root /go/act_runner/act_runner /app/gitea/act_runner

RUN apk --no-cache add \
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
RUN mkdir -p /var/lib/gitea /etc/gitea
RUN chown git:git /var/lib/gitea /etc/gitea

USER 1000:1000

VOLUME ["/var/lib/gitea", "/etc/gitea"]

ENTRYPOINT ["act_runner"]
CMD []
