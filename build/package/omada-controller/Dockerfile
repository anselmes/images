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

ARG FROM=ubuntu:20.04

# rebased/repackaged base image that only updates existing packages
FROM ubuntu:20.04

# TODO: add labels
LABEL org.opencontainers.image.authors=""
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.licenses=""

FROM ${FROM} as builder

ARG INSTALL_VER="5.6"

COPY scripts/omada/entrypoint.sh /
COPY scripts/omada/healthcheck.sh \
  scripts/omada/install.sh \
  scripts/omada/log4j_patch.sh \
  /
RUN /install.sh \
  && /log4j_patch.sh \
  && rm /install.sh /log4j_patch.sh

FROM ${FROM}

LABEL org.opencontainers.image.authors="Schubert Anselme <schubert@anselm.es>"
LABEL org.opencontainers.image.url="https://github.com/sanselme/images"
LABEL org.opencontainers.image.documentation="https://github.com/sanselme/images"
LABEL org.opencontainers.image.source="https://github.com/sanselme/images"
LABEL org.opencontainers.image.vendor="Schubert Anselme"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

COPY --from=builder /opt/tplink/EAPController /opt/tplink/EAPController
WORKDIR /opt/tplink/EAPController/lib

EXPOSE 8088 8043 8843 29810/udp 29811 29812 29813 29814
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/logs"]

HEALTHCHECK --start-period=5m CMD /healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/java","-server","-Xms128m","-Xmx1024m","-XX:MaxHeapFreeRatio=60","-XX:MinHeapFreeRatio=30","-XX:+HeapDumpOnOutOfMemoryError","-XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof","-Djava.awt.headless=true","-cp","/opt/tplink/EAPController/lib/*::/opt/tplink/EAPController/properties:","com.tplink.smb.omada.starter.OmadaLinuxMain"]
