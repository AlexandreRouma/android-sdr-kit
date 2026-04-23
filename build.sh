set -e

. /etc/profile

export MAKEOPTS=-j$(nproc)
export APP_ABI="armeabi-v7a arm64-v8a x86 x86_64"

# Helper functions
load_android_toolchain() { # [arch] [compiler_abi]
    export LD="$ANDROID_NDK_TOOLCHAIN/$1-linux-android$2$ANDROID_API_LEVEL-clang"
    export CC="$ANDROID_NDK_TOOLCHAIN/$1-linux-android$2$ANDROID_API_LEVEL-clang"
    export CXX="$ANDROID_NDK_TOOLCHAIN/$1-linux-android$2$ANDROID_API_LEVEL-clang++"
    export AS="$ANDROID_NDK_TOOLCHAIN/$1-linux-android$2$ANDROID_API_LEVEL-as"
}

load_native_toolchain() { # [arch] [compiler_abi]
    export LD="ld"
    export CC="gcc"
    export CXX="g++"
    export AS="as"
}

gen_cmake_args() { # [android_abi]
    echo -DENABLE_TESTING=OFF -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_CMAKE" -DANDROID_ABI=$1 -DANDROID_ARM_NEON=ON -DANDROID_NATIVE_API_LEVEL=$ANDROID_API_LEVEL -DENABLE_TESTING=OFF -DCMAKE_INSTALL_PREFIX=/ \
        -DCMAKE_INSTALL_LIBDIR=/lib -DCMAKE_INSTALL_FULL_LIBDIR=/lib \
        -DCMAKE_INSTALL_BINDIR=/bin -DCMAKE_INSTALL_FULL_BINDIR=/bin \
        -DCMAKE_INSTALL_BINDIR=/sbin -DCMAKE_INSTALL_FULL_BINDIR=/sbin \
        -DCMAKE_INSTALL_INCLUDEDIR=/include -DCMAKE_INSTALL_FULL_INCLUDEDIR=/include \
        -DTHREADS_PTHREAD_ARG=-pthread
}

gen_cmake_libusb_args() { # [android_abi]
    echo -DLIBUSB_LIBRARIES=$SDR_KIT_ROOT/$1/lib/libusb1.0.so -DLIBUSB_INCLUDE_DIRS=$SDR_KIT_ROOT/$1/include -DLIBUSB_INCLUDE_DIR=$SDR_KIT_ROOT/$1/include -DLIBUSB_FOUND=1 -DLIBUSB_VERSION=1.0.25
}

gen_cmake_fftw_args() { # [android_abi]
    echo -DFFTW_LIBRARIES=$SDR_KIT_ROOT/$1/lib/libfftw3f.so -DFFTW_INCLUDES=$SDR_KIT_ROOT/$1/include -DFFTW_FOUND=1
}

gen_cmake_libxml2_args() { # [android_abi]
    echo -DLIBXML2_LIBRARY=$SDR_KIT_ROOT/$1/lib/libxml2.so -DLIBXML2_INCLUDE_DIR=$SDR_KIT_ROOT/$1/include/libxml2 -DLIBXML2_FOUND=1
}

gen_cmake_libiio_args() { # [android_abi]
    echo -DLIBIIO_LIBRARIES=$SDR_KIT_ROOT/$1/lib/libiio.so -DLIBIIO_INCLUDEDIR=$SDR_KIT_ROOT/$1/include
}

# Build ZSTD
build_zstd() { # [arch] [android_abi] [compiler_abi]
    echo "===================== ZSTD ($2) ====================="
    cd $SDR_KIT_BUILD/zstd
    load_android_toolchain $1 $3
    make clean
    make $MAKEOPTS
    make prefix=/ libdir=/lib DESTDIR=$SDR_KIT_ROOT/$2 install
    patchelf --set-soname libzstd.so $SDR_KIT_ROOT/$2/lib/libzstd.so
    cd ..
}

# Build FFTW3
build_fftw() { # [android_abi]
    echo "===================== FFTW3 ($1) ====================="
    cd $SDR_KIT_BUILD/fftw
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) -DENABLE_FLOAT=ON ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build codec2
build_codec2() { # [android_abi]
    echo "===================== Codec2 ($1) ====================="
    cd $SDR_KIT_BUILD/codec2
    mkdir -p build_$1 && cd build_$1
    load_native_toolchain
    cmake $(gen_cmake_args $1) -DUNITTEST=FALSE -DGENERATE_CODEBOOK=$SDR_KIT_BUILD/codec2/build_linux/src/generate_codebook ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libusb
build_libusb() {
    echo "===================== libusb ====================="
    cd $SDR_KIT_BUILD/libusb/android/jni
    $ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION/ndk-build
    cd ..
    mkdir -p $SDR_KIT_ROOT/x86/lib
    mkdir -p $SDR_KIT_ROOT/x86_64/lib
    mkdir -p $SDR_KIT_ROOT/armeabi-v7a/lib
    mkdir -p $SDR_KIT_ROOT/arm64-v8a/lib
    cp libs/x86/* $SDR_KIT_ROOT/x86/lib
    cp libs/x86_64/* $SDR_KIT_ROOT/x86_64/lib
    cp libs/armeabi-v7a/* $SDR_KIT_ROOT/armeabi-v7a/lib
    cp libs/arm64-v8a/* $SDR_KIT_ROOT/arm64-v8a/lib
    cd ..
    mkdir -p $SDR_KIT_ROOT/x86/include
    mkdir -p $SDR_KIT_ROOT/x86_64/include
    mkdir -p $SDR_KIT_ROOT/armeabi-v7a/include
    mkdir -p $SDR_KIT_ROOT/arm64-v8a/include
    cp libusb/libusb.h $SDR_KIT_ROOT/x86/include
    cp libusb/libusbi.h $SDR_KIT_ROOT/x86/include
    cp libusb/libusb.h $SDR_KIT_ROOT/x86_64/include
    cp libusb/libusbi.h $SDR_KIT_ROOT/x86_64/include
    cp libusb/libusb.h $SDR_KIT_ROOT/armeabi-v7a/include
    cp libusb/libusbi.h $SDR_KIT_ROOT/armeabi-v7a/include
    cp libusb/libusb.h $SDR_KIT_ROOT/arm64-v8a/include
    cp libusb/libusbi.h $SDR_KIT_ROOT/arm64-v8a/include
    cd ..
}


# Build volk
build_volk() { # [android_abi]
    echo "===================== Volk ($1) ====================="
    cd $SDR_KIT_BUILD/volk
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libairspyhf
build_libairspyhf() { # [android_abi]
    echo "===================== libairspyhf ($1) ====================="
    cd $SDR_KIT_BUILD/airspyhf
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libairspy
build_libairspy() { # [android_abi]
    echo "===================== libairspy ($1) ====================="
    cd $SDR_KIT_BUILD/airspyone_host
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libhackrf
build_libhackrf() { # [android_abi]
    echo "===================== libhackrf ($1) ====================="
    cd $SDR_KIT_BUILD/hackrf/host
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) $(gen_cmake_fftw_args $1) -DDISABLE_USB_ENUMERATION=ON ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../../
}


# Build librtlsdr
build_librtlsdr() { # [android_abi]
    echo "===================== librtlsdr ($1) ====================="
    cd $SDR_KIT_BUILD/rtl-sdr
    mkdir -p build_$1 && cd build_$1
    BLADERF_CMAKE="cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) $(gen_cmake_libusb_args $1) -DBUILD_UTILITIES=OFF .."
    echo "bladeRF: $BLADERF_CMAKE"
    $BLADERF_CMAKE
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libbladerf
build_libbladerf() { # [android_abi]
    echo "===================== libbladerf ($1) ====================="
    cd $SDR_KIT_BUILD/bladeRF
    mkdir -p build_$1 && cd build_$1
    export BLADERF_CMAKE="cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) -DENABLE_BACKEND_LIBUSB=True -DENABLE_USB_DEV_RESET_ON_OPEN=True -DBUILD_BLADERF_UTILITIES=OFF -DTEST_LIBBLADERF=OFF .."
    echo "bladeRF CMAKE: $BLADERF_CMAKE"
    $BLADERF_CMAKE
    make $MAKEOPTS libbladerf_shared
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libxml2
build_libxml2() { # [android_abi]
    echo "===================== LibXML2 ($1) ====================="
    cd $SDR_KIT_BUILD/libxml2
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_PYTHON=OFF ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}


# Build libiio
build_libiio() { # [android_abi]
    echo "===================== LibIIO ($1) ====================="
    cd $SDR_KIT_BUILD/libiio
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libxml2_args $1) -DWITH_TESTS=OFF -DWITH_USB_BACKEND=OFF -DHAVE_DNS_SD=OFF ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}

# Build libad9361
build_libad9361() { # [android_abi]
    echo "===================== LibAD9361 ($1) ====================="
    cd $SDR_KIT_BUILD/libad9361
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libiio_args $1) -DDESTINATION=$SDR_KIT_ROOT/$1 ..
    make $MAKEOPTS
    # Install is broken, so it must be done manually...
    cp ../ad9361.h $SDR_KIT_ROOT/$1/include/
    cp libad9361.so $SDR_KIT_ROOT/$1/lib/
    cd ../../
}

# Build libhydrasdr
build_libhydrasdr() { # [android_abi]
    echo "===================== libhydrasdr ($1) ====================="
    cd $SDR_KIT_BUILD/rfone_host
    mkdir -p build_$1 && cd build_$1
    cmake $(gen_cmake_args $1) $(gen_cmake_libusb_args $1) ..
    make $MAKEOPTS
    make DESTDIR=$SDR_KIT_ROOT/$1 install
    cd ../../
}

case "$1" in
    libhydrasdr ) 
        build_libhydrasdr x86
        build_libhydrasdr x86_64
        build_libhydrasdr armeabi-v7a
        build_libhydrasdr arm64-v8a
    ;;
    libad9361 ) 
        build_libad9361 x86
        build_libad9361 x86_64
        build_libad9361 armeabi-v7a
        build_libad9361 arm64-v8a
        ;;
    libiio ) 
        build_libiio x86
        build_libiio x86_64
        build_libiio armeabi-v7a
        build_libiio arm64-v8a
    ;;
    libxml2 ) 
        build_libxml2 x86
        build_libxml2 x86_64
        build_libxml2 armeabi-v7a
        build_libxml2 arm64-v8a
    ;;
    libbladerf ) 
        build_libbladerf x86
        build_libbladerf x86_64
        build_libbladerf armeabi-v7a
        build_libbladerf arm64-v8a
    ;;
    librtlsdr ) 
        build_librtlsdr x86
        build_librtlsdr x86_64
        build_librtlsdr armeabi-v7a
        build_librtlsdr arm64-v8a
    ;;
    libhackrf ) 
        build_libhackrf x86
        build_libhackrf x86_64
        build_libhackrf armeabi-v7a
        build_libhackrf arm64-v8a
    ;;
    libairspy ) 
        build_libairspy x86
        build_libairspy x86_64 
        build_libairspy armeabi-v7a
        build_libairspy arm64-v8a
    ;;
    libairspyhf )
        build_libairspyhf x86
        build_libairspyhf x86_64 
        build_libairspyhf armeabi-v7a
        build_libairspyhf arm64-v8a
    ;;
    libvolk )
        build_volk x86
        build_volk x86_64 
        build_volk armeabi-v7a
        build_volk arm64-v8a
    ;;
    libusb )
        build_libusb
    ;;
    libstd )
        build_zstd i686 x86
        build_zstd x86_64 x86_64
        build_zstd armv7a armeabi-v7a eabi
        build_zstd aarch64 arm64-v8a
    ;;
    libfftw )
        build_fftw x86
        build_fftw x86_64 
        build_fftw armeabi-v7a
        build_fftw arm64-v8a
    ;;
    codec2 )
        build_codec2 x86
        build_codec2 x86_64
        build_codec2 armeabi-v7a
        build_codec2 arm64-v8a
    ;;
esac