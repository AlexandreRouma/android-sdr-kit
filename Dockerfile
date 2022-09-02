FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive 

COPY install.sh /root
COPY build.sh /root

RUN chmod +x /root/install.sh && cd /root && ./install.sh