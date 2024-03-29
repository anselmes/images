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

FROM ubuntu:22.04

LABEL org.opencontainers.image.authors='airship-discuss@lists.airshipit.org, irc://#airshipit@freenode'
LABEL org.opencontainers.image.url='https://airshipit.org'
LABEL org.opencontainers.image.documentation='https://github.com/openstack/airship-maas'
LABEL org.opencontainers.image.source='https://git.openstack.org/openstack/airship-maas'
LABEL org.opencontainers.image.vendor='The Airship Authors'
LABEL org.opencontainers.image.licenses='Apache-2.0'

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG http_proxy
ARG https_proxy
ARG no_proxy

ENV DEBIAN_FRONTEND noninteractive
ENV container docker

ENV MAAS_VERSION 1:3.3.1-13169-g.94920eb1e-0ubuntu1~22.04.1

# Remove systemd-timesyncd, which conflicts with chrony
RUN apt-get remove -y --purge systemd-timesyncd

RUN apt-get -qq update \
 && apt-get install -y \
        avahi-daemon \
        jq \
        patch \
        software-properties-common \
        sudo \
        systemd \
        cron \
        ca-certificates \
# Don't start any optional services except for the few we need.
# (specifically, don't start avahi-daemon)
 && find /etc/systemd/system \
         /lib/systemd/system \
         -path '*.wants/*' \
         -not -name '*journald*' \
         -not -name '*systemd-tmpfiles*' \
         -not -name '*systemd-user-sessions*' \
         -exec rm \{} \; \
 && systemctl set-default multi-user.target \
# Install maas from the ppa
 && add-apt-repository -yu ppa:maas/3.3 \
 && apt-get install -y \
        maas-region-api=$MAAS_VERSION \
        # tcpdump is required by /usr/lib/maas/beacon-monitor
        tcpdump \
 && rm -rf /var/lib/apt/lists/*

# Preserve the directory structure, permissions, and contents of /var/lib/maas
RUN mkdir -p /opt/maas/ && tar -cvzf /opt/maas/var-lib-maas.tgz /var/lib/maas

# MAAS workarounds
COPY build/patch/maas/route.patch /tmp/route.patch
COPY build/patch/maas/kernel_package.patch /tmp/kernel_package.patch
COPY build/patch/maas/bios_grub_partition.patch /tmp/bios_grub_partition.patch
# sh8121att: allow all requests via the proxy to allow it to work
# behind ingress
COPY build/patch/maas/proxy_acl.patch /tmp/proxy_acl.patch
# Patch to add retrying to MaaS BMC user setup, and improve exception handling
COPY build/patch/maas/configure_ipmi_user.patch /tmp/configure_ipmi_user.patch
COPY build/patch/maas/secure_headers.patch /tmp/secure_headers.patch
COPY build/patch/maas/partitiontable_does_not_exist.patch /tmp/partitiontable_does_not_exist.patch
# Allow tags with '/' symbols
COPY build/patch/maas/regex_tags.patch /tmp/regex_tags.patch

RUN cd /usr/lib/python3/dist-packages/maasserver && patch preseed_network.py < /tmp/route.patch
RUN cd /usr/lib/python3/dist-packages/maasserver && patch preseed.py < /tmp/kernel_package.patch
RUN cd /usr/lib/python3/dist-packages/maasserver/models && patch partition.py < /tmp/bios_grub_partition.patch
RUN cd /usr/lib/python3/dist-packages/metadataserver/builtin_scripts/commissioning_scripts && patch bmc_config.py < /tmp/configure_ipmi_user.patch
RUN cd /usr/lib/python3/dist-packages/provisioningserver/templates/proxy && patch maas-proxy.conf.template < /tmp/proxy_acl.patch
RUN cd /usr/lib/python3/dist-packages/twisted/web && patch server.py < /tmp/secure_headers.patch
RUN cd /usr/lib/python3/dist-packages/maasserver/api && patch partitions.py < /tmp/partitiontable_does_not_exist.patch
RUN cd /usr/lib/python3/dist-packages/maasserver/models && patch ownerdata.py < /tmp/regex_tags.patch

# echo journalctl logs to the container's stdout
COPY config/journalctl-to-tty.service /etc/systemd/system/journalctl-to-tty.service
COPY config/journalctl-to-tty.service /etc/systemd/system/journalctl-to-tty.service
RUN systemctl enable journalctl-to-tty.service

# quiet sudo for the maas user
RUN umask 0337; echo 'Defaults:maas !pam_session, !syslog' > /etc/sudoers.d/99-maas-no-log

# avoid triggering bind9 high cpu utilization bug
RUN sed -i -e '$a\include "/etc/bind/bind.keys";' /etc/bind/named.conf

# initalize systemd
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=console 3>&1"]
