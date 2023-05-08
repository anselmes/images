# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# rebased/repackaged base image that only updates existing packages
FROM ubuntu:20.04

# TODO: add labels
LABEL org.opencontainers.image.authors=""
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.licenses=""

COPY healthcheck.sh install.sh log4j_patch.sh /

# install version (major.minor only); OMADA_URL set in install.sh
ARG INSTALL_VER="5.6"

# install omada controller (instructions taken from install.sh) & patch log4j, if applicable
RUN /install.sh \
  && /log4j_patch.sh \
  && rm /install.sh /log4j_patch.sh

COPY entrypoint.sh /

WORKDIR /opt/tplink/EAPController/lib
EXPOSE 8088 8043 8843 29810/udp 29811 29812 29813 29814
HEALTHCHECK --start-period=5m CMD /healthcheck.sh
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/java","-server","-Xms128m","-Xmx1024m","-XX:MaxHeapFreeRatio=60","-XX:MinHeapFreeRatio=30","-XX:+HeapDumpOnOutOfMemoryError","-XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof","-Djava.awt.headless=true","-cp","/opt/tplink/EAPController/lib/*::/opt/tplink/EAPController/properties:","com.tplink.smb.omada.starter.OmadaLinuxMain"]
