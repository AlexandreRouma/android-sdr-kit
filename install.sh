set -e

# Settings
export ANDROID_INSTALLER=commandlinetools-linux-8512546_latest.zip
export ANDROID_API_LEVEL=28
export ANDROID_NDK_VERSION=25.1.8937393
export SDR_KIT_ROOT=/root/sdr
export SDR_KIT_OUT=/root/sdr-out

# Install dependencies
apt update -y
apt install -y wget git p7zip-full default-jdk build-essential cmake patchelf python3-mako

# Install the Android tools
mkdir Android
wget https://dl.google.com/android/repository/$ANDROID_INSTALLER
7z x $ANDROID_INSTALLER
mv cmdline-tools/ Android/
export ANDROID_HOME=/root/Android
export ANDROID_SDK_ROOT=/root/Android

# Install the SDK and NDK
yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --install "platforms;android-$ANDROID_API_LEVEL" "ndk;$ANDROID_NDK_VERSION"
export ANDROID_NDK_TOOLCHAIN=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION/toolchains/llvm/prebuilt/linux-x86_64/bin
export ANDROID_NDK_CMAKE=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION/build/cmake/android.toolchain.cmake

# Create directories
mkdir -p $SDR_KIT_ROOT
mkdir -p $SDR_KIT_OUT

# Do build
cd $SDR_KIT_ROOT
chmod +x /root/build.sh
/root/build.sh