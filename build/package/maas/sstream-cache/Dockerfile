<<<<<<< HEAD
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

ARG FROM=ubuntu:18.04

FROM ${FROM}
=======
FROM ubuntu:22.04
>>>>>>> 013aac0 (Update container image (#32))

LABEL org.opencontainers.image.authors="airship-discuss@lists.airshipit.org, irc://#airshipit@freenode"
LABEL org.opencontainers.image.url="https://airshipit.org"
LABEL org.opencontainers.image.documentation="https://github.com/openstack/airship-maas"
LABEL org.opencontainers.image.source="https://git.openstack.org/openstack/airship-maas"
LABEL org.opencontainers.image.vendor="The Airship Authors"
LABEL org.opencontainers.image.licenses="Apache-2.0"

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG http_proxy
ARG https_proxy
ARG no_proxy

ARG SSTREAM_IMAGE=https://images.maas.io/ephemeral-v3/stable/
ARG SSTREAM_RELEASE=bionic

ENV DEBIAN_FRONTEND noninteractive
<<<<<<< HEAD
=======

RUN apt-get -qq update \
  && apt-get install -y simplestreams \
    apache2 \
    gpgv \
    ubuntu-cloudimage-keyring \
    python-certifi --no-install-recommends \
    file

RUN sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg ${SSTREAM_IMAGE} \
    /var/www/html/maas/images/ephemeral-v3/daily 'arch=amd64' "release~${SSTREAM_RELEASE}" --max=1 --progress

RUN sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg ${SSTREAM_IMAGE} \
   /var/www/html/maas/images/ephemeral-v3/daily 'os~(grub*|pxelinux)' --max=1 --progress

RUN sh -c 'echo "" > /etc/apache2/ports.conf'

>>>>>>> 013aac0 (Update container image (#32))
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/
ENV APACHE_LOCK_DIR /var/lock
ENV APACHE_LOG_DIR /var/log/
ENV LANG C

RUN apt-get -qq update \
  && apt-get install -y simplestreams \
    apache2 \
    gpgv \
    ubuntu-cloudimage-keyring \
    python3-certifi --no-install-recommends \
    file
RUN sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg ${SSTREAM_IMAGE} \
    /var/www/html/maas/images/ephemeral-v3/daily 'arch=amd64' "release~${SSTREAM_RELEASE}" --max=1 --progress \
  &&sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg ${SSTREAM_IMAGE} \
   /var/www/html/maas/images/ephemeral-v3/daily 'os~(grub*|pxelinux)' --max=1 --progress \
  && sh -c 'echo "" > /etc/apache2/ports.conf'

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-E", "/dev/stderr","-c","ErrorLog /dev/stderr","-c","Listen 8888","-c","ServerRoot /etc/apache2","-c","DocumentRoot /var/www/html","-D","FOREGROUND"]
