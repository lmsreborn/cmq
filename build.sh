#/bin/sh
set -x -e
# cmake for gflags
WORK_DIR=`pwd`
DEPS_SOURCE=`pwd`/thirdsrc
DEPS_PREFIX=`pwd`/thirdparty
DEPS_CONFIG="--prefix=${DEPS_PREFIX} --disable-shared --with-pic"
FLAG_DIR=`pwd`/.build

export PATH=${DEPS_PREFIX}/bin:$PATH
mkdir -p ${DEPS_SOURCE} ${DEPS_PREFIX} ${FLAG_DIR}

if [ ! -f "${FLAG_DIR}/dl_third" ] || [ ! -d "${DEPS_SOURCE}/.git" ]; then
    rm -rf ${DEPS_SOURCE}
    mkdir ${DEPS_SOURCE}
    cd ${DEPS_SOURCE}
    git clone https://github.com/mindlesslcc/mq-thirdsrc.git
    mv mq-thirdsrc/* .
    rm -rf mq-thirdsrc
    tar -zxvf CMake-3.2.1.tar.gz
    tar -zxvf gflags-2.1.1.tar.gz
    tar -zxvf gtest-1.7.0.tar.gz
    tar -zxvf protobuf-3.2.0.tar.gz
    touch "${FLAG_DIR}/dl_third"
fi

cd ${DEPS_SOURCE}
# protobuf
if [ ! -f "${FLAG_DIR}/protobuf-3.2.0" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libprotobuf.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/google/protobuf" ]; then
    cd protobuf-3.2.0
    autoreconf -ivf
    ./configure ${DEPS_CONFIG}
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/protobuf_3_2_0"
fi
#cmake
if ! which cmake ; then
    cd CMake-3.2.1
    ./configure --prefix=${DEPS_PREFIX}
    make -j4
    make install
    cd -
fi

# gflags
if [ ! -f "${FLAG_DIR}/gflags-2.1.1" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libgflags.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/gflags" ]; then
    cd gflags-2.1.1
    cmake -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DGFLAGS_NAMESPACE=google -DCMAKE_CXX_FLAGS=-fPIC
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/gflags_2_1_1"
fi

# gtest
if [ ! -f "${FLAG_DIR}/gtest-1.7.0" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libgtest.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/gtest" ]; then
    cd gtest-1.7.0
    ./configure ${DEPS_CONFIG}
    make
    cp -a lib/.libs/* ${DEPS_PREFIX}/lib
    cp -a include/gtest ${DEPS_PREFIX}/include
    cd -
    touch "${FLAG_DIR}/gtest_1_7_0"
fi

cd ${WORK_DIR}

# build

make clean
make -j4

