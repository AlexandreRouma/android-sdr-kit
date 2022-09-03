FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ENV="/etc/profile"

COPY install.sh /root
COPY build.sh /root
COPY package.sh /root

RUN chmod +x /root/install.sh && cd /root && ./install.sh