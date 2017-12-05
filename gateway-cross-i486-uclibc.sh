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

NODE_MODULES_TARBALL=node_modules-i486-uclibc
OPENZWAVE_TARBALL=openzwave.tar.gz

# Remove the output, if it exists
rm -f ${NODE_MODULES_TARBALL} ${OPENZWAVE_TARBALL}

NODE_VERSION=8.9.1
SDK_X86_DIR=$HOME/LEDE/openwrt-git-x86
BUILD_DIR=${SDK_X86_DIR}/build_dir/target-i386_i486_uClibc-0.9.33.2

export STAGING_DIR=$HOME/x-toolchain

PREFIX=${STAGING_DIR}/i486-openwrt-linux-uclibc/bin/i486-openwrt-linux-uclibc-

LIBPATH=${STAGING_DIR}/i486-openwrt-linux-uclibc/lib
export LDFLAGS='-Wl,-rpath-link '${LIBPATH}

ARCH=ia32

SYSROOT=${SDK_X86_DIR}/staging_dir/target-i386_i486_uClibc-0.9.33.2

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
export npm_config_arch=ia32
# path to the node source that was used to create the cross-compiled version
export npm_config_nodedir=${BUILD_DIR}/node-v${NODE_VERSION}

sleep 2

cd gateway/

git pull
rm -rf node_modules

short=$(git rev-parse --short HEAD)
npm install --target_arch=ia32 --build-from-source

# Create a tarball with all of the node modules
# tar czvf ${NODE_MODULES_TARBALL} node_modules
now=$(date +%Y-%m-%d_%H.%M.%S)

#  zip -rq ${NODE_MODULES_TARBALL}-${short}.zip node_modules

tar cjf ${NODE_MODULES_TARBALL}-${short}.tar.bz2 node_modules

# And one with OpenZWave
# tar czf ${OPENZWAVE_TARBALL} -C ${SYSROOT} usr/local/include/openzwave usr/local/lib
