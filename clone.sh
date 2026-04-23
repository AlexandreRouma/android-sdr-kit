
cd $1

perform_clone() {
    cd $SDR_KIT_BUILD
    # Download libaries
    wget https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz
    tar -zxvf zstd-1.5.2.tar.gz
    mv zstd-1.5.2 zstd

    wget http://www.fftw.org/fftw-3.3.10.tar.gz
    tar -zxvf fftw-3.3.10.tar.gz
    mv fftw-3.3.10 fftw

    wget https://github.com/drowe67/codec2-dev/archive/refs/tags/v1.0.5.zip
    7z x v1.0.5.zip
    mv codec2-dev-1.0.5 codec2

    wget https://github.com/libusb/libusb/releases/download/v1.0.25/libusb-1.0.25.tar.bz2
    tar -xvf libusb-1.0.25.tar.bz2
    mv libusb-1.0.25 libusb

    git clone --recurse-submodules https://github.com/gnuradio/volk

    git clone https://github.com/airspy/airspyhf

    git clone https://github.com/airspy/airspyone_host

    git clone https://github.com/AlexandreRouma/hackrf

    git clone https://github.com/AlexandreRouma/rtl-sdr

    git clone https://github.com/rickmark/bladeRF.git

    wget https://www.sdrpp.org/libxml2-2.9.14.tar.xz
    tar -xvf libxml2-2.9.14.tar.xz
    mv libxml2-2.9.14 libxml2

    wget https://github.com/analogdevicesinc/libiio/archive/refs/tags/v0.24.tar.gz
    tar -zxvf v0.24.tar.gz
    mv libiio-0.24 libiio

    wget https://github.com/analogdevicesinc/libad9361-iio/archive/refs/tags/v0.2.tar.gz
    tar -zxvf v0.2.tar.gz
    mv libad9361-iio-0.2 libad9361

    git clone https://github.com/hydrasdr/rfone_host
}

perform_clone