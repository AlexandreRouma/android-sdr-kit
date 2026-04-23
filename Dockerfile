FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ENV="/etc/profile"
ENV ANDROID_INSTALLER=commandlinetools-linux-8512546_latest.zip
ENV ANDROID_API_LEVEL=28
ENV ANDROID_NDK_VERSION=27.3.13750724
ENV ANDROID_CMAKE_VERSION=3.18.1
ENV GRADLE_VERSION=7.3.3
ENV SDR_KIT_BUILD=/root/sdr-kit-build
ENV SDR_KIT_ROOT=/sdr-kit
ENV ANDROID_HOME=/root/Android
ENV ANDROID_SDK_ROOT=/root/Android

COPY install.sh /root

RUN chmod +x /root/install.sh && /root/install.sh /root

COPY clone.sh /root
RUN chmod +x /root/clone.sh && /root/clone.sh $SDR_KIT_BUILD

COPY build.sh /root
RUN chmod +x /root/build.sh
RUN /root/build.sh clone
RUN /root/build.sh libstd
RUN /root/build.sh libfftw
RUN /root/build.sh codec2
RUN /root/build.sh libusb
RUN /root/build.sh libbladerf
RUN /root/build.sh libxml2
RUN /root/build.sh libiio
RUN /root/build.sh libhydrasdr
RUN /root/build.sh libad9361
RUN /root/build.sh librtlsdr
RUN /root/build.sh libhackrf
RUN /root/build.sh libairspy
RUN /root/build.sh libairspyhf
RUN /root/build.sh libvolk

COPY package.sh /root
RUN chmod +x /root/package.sh && /root/package.sh $SDR_KIT_ROOT