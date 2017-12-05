#!/bin/bash -x
#
# This script is expected to run inside a docker container which has the Raspberry Pi toolchain
# and required prerequisites:
#   - pkg-config
#   - libusb-1.0-0-dev
#   - libudev-dev
#
# /build corresponds to the current directory when the docker container is run and it is expected
# that the following directory structure has been setup:
#
#   - /build/Open-ZWave/open-zwave  - git repository containing the desired version of OpenZWave
#   - /build/gateway                - git repository containing the gateway software

NODE_MODULES_TARBALL=node_modules-arm-musl
# OPENZWAVE_TARBALL=openzwave.tar.gz

# Remove the output, if it exists
rm -f ${NODE_MODULES_TARBALL} ${OPENZWAVE_TARBALL}

NODE_VERSION=8.9.1
SDK_ARM_DIR=$HOME/LEDE/lede-sdk-17.01.2-brcm2708-bcm2710
BUILD_DIR=${SDK_ARM_DIR}/build_dir/target-arm_cortex-a53+neon-vfpv4_musl-1.1.16_eabi

export STAGING_DIR=$HOME/x-toolchain

PREFIX=${STAGING_DIR}/arm-openwrt-linux-muslgnueabi/bin/arm-openwrt-linux-muslgnueabi-

LIBPATH=${STAGING_DIR}/arm-openwrt-linux-muslgnueabi/lib/
export LDFLAGS='-Wl,-rpath-link '${LIBPATH}

ARCH=arm

SYSROOT=${SDK_ARM_DIR}/staging_dir/target-arm_cortex-a53+neon-vfpv4_musl-1.1.16_eabi

# Setup Cross compiler vars which are used by node-gyp when building native node modules.
OPTS="--sysroot=${SYSROOT}"

export AR=${PREFIX}ar
export CC="${PREFIX}gcc ${OPTS}"
export CXX="${PREFIX}g++ ${OPTS}"
export AR=${PREFIX}ar
export RANLIB=${PREFIX}ranlib
export LINK=$CXX

# export CC="arm-linux-gnueabihf-gcc ${OPTS}"
# export CXX="arm-linux-gnueabihf-g++ ${OPTS}"

# npm arch to cross-compile
export npm_config_arch=arm
# path to the node source that was used to create the cross-compiled version
export npm_config_nodedir=${BUILD_DIR}/node-v${NODE_VERSION}

sleep 2

cd gateway/
git pull
rm -rf node_modules/

short=$(git rev-parse --short HEAD)
npm install --target_arch=arm --build-from-source

# Create a tarball with all of the node modules
# tar czvf ${NODE_MODULES_TARBALL} node_modules
now=$(date +%Y-%m-%d_%H.%M.%S)

zip -rq ${NODE_MODULES_TARBALL}-${short}-${NODE_VERSION}.zip node_modules

tar cjf ${NODE_MODULES_TARBALL}-${short}-${NODE_VERSION}.tar.bz2 node_modules

# And one with OpenZWave
# tar czf ${OPENZWAVE_TARBALL} -C ${SYSROOT} usr/local/include/openzwave usr/local/lib
