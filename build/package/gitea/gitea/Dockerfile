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

ARG TAGS="sqlite sqlite_unlock_notify"
ENV TAGS "bindata timetzdata $TAGS"
ARG CGO_EXTRA_CFLAGS

RUN apk --no-cache add build-base git nodejs npm
# FIXME: build gitea with gitea actions
RUN git clone https://github.com/go-gitea/gitea.git && \
  cd gitea && \
  git fetch origin pull/21937/head && \
  git checkout -b pullrequest FETCH_HEAD && \
  make build
RUN cd /go/gitea && go build contrib/environment-to-ini/environment-to-ini.go

FROM alpine:3.17
LABEL maintainer="maintainers@gitea.io"

WORKDIR /var/lib/gitea

ENV HOME "/var/lib/gitea/git"
ENV TMPDIR /tmp/gitea
ENV GITEA_APP_INI /etc/gitea/app.ini
ENV GITEA_CUSTOM /var/lib/gitea/custom
ENV GITEA_TEMP /tmp/gitea
ENV GITEA_WORK_DIR /var/lib/gitea

COPY --from=build-env /go/gitea/docker/rootless /
COPY --from=build-env --chown=root:root /go/gitea/gitea /app/gitea/gitea
COPY --from=build-env --chown=root:root /go/gitea/environment-to-ini /usr/local/bin/environment-to-ini

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-setup.sh /app/gitea/gitea /usr/local/bin/gitea /usr/local/bin/environment-to-ini
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
EXPOSE 2222 3000

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD []
