#!/bin/bash

source $(dirname $0)/usetoolchain

TARGET=x86_64-elf

BINUTILS_VER=2.26
BINUTILS=binutils-$BINUTILS_VER
BINUTILS_BZ2=$BINUTILS.tar.bz2
BINUTILS_URL=ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.bz2

GCC_VER=5.3.0
GCC=gcc-$GCC_VER
GCC_BZ2=$GCC.tar.bz2
GCC_URL=ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC_BZ2

#LLVM_VER=release_38
#LLVM_TARGETS="X86;ARM;AArch64;Mips"



mkdir -p $PREFIX/sources
mkdir -p $PREFIX/build
cd $PREFIX/sources

if [ ! -f "$BINUTILS_BZ2" ]; then
    wget $BINUTILS_URL
fi
if [ ! -d "$BINUTILS" ]; then
	tar xvf $BINUTILS_BZ2
fi

if [ ! -f "$GCC_BZ2" ]; then
    wget $GCC_URL
fi
if [ ! -d "$GCC" ]; then
	tar xvf $GCC_BZ2
	(cd $GCC; contrib/download_prerequisites)
fi

#if [ ! -d llvm ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/llvm.git llvm
#else
#    (cd llvm; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi
#if [ ! -d "llvm/projects/compiler-rt" ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/compiler-rt.git llvm/projects/compiler-rt
#else
#    (cd llvm/projects/compiler-rt; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi
#if [ ! -d "llvm/tools/clang" ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/clang.git llvm/tools/clang
#else
#    (cd llvm/tools/clang; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi
#if [ ! -d "llvm/tools/lld" ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/lld.git llvm/tools/lld
#else
#    (cd llvm/tools/lld; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi
#if [ ! -d "llvm/projects/libcxx" ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/libcxx.git llvm/projects/libcxx
#else
#    (cd llvm/projects/libcxx; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi
#if [ ! -d "llvm/projects/libcxxabi" ]; then
#    git clone --depth 1 --branch $LLVM_VER https://github.com/llvm-mirror/libcxxabi.git llvm/projects/libcxxabi
#else
#    (cd llvm/projects/libcxxabi; git fetch; git checkout $LLVM_VER; git reset --hard origin/$LLVM_VER)
#fi

cd $PREFIX/build
mkdir -p build-binutils
cd build-binutils
if [ ! -f .config.succeeded ]; then
    $PREFIX/sources/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror && \
    touch .config.succeeded || exit 1
else
    echo "$BINUTILS .config.succeeded exists, NOT reconfiguring!"
fi
if [ ! -f .install.succeeded ]; then
    make -j4 && \
    make install && \
    touch .install.succeeded || exit 1
else
    echo "$BINUTILS .install.succeeded exists, NOT reinstalling!"
fi



# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH
which -- $TARGET-as || exit 1

cd $PREFIX/build
mkdir -p build-gcc
cd build-gcc
if [ ! -f .config.succeeded ]; then
    $PREFIX/sources/$GCC/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers && \
    touch .config.succeeded || exit 1
else
    echo "$GCC .config.succeeded exists, NOT reconfiguring!"
fi
if [ ! -f .compile.succeeded ]; then
    make all-target-libgcc -j4 && \
    sed -i.bak -e "s/CRTSTUFF_T_CFLAGS =/CRTSTUFF_T_CFLAGS = -mcmodel=large/g" $TARGET/libgcc/Makefile && \
    rm $TARGET/libgcc/crtbegin.* $TARGET/libgcc/crtend.* && \
    touch .compile.succeeded || exit 1
else
    echo "$GCC .compile.succeeded exists, NOT changing the Makefile and crtbegin!"
fi
if [ ! -f .install.succeeded ]; then
    make all-target-libgcc -j4 && \
    make install-target-libgcc && \
    touch .install.succeeded || exit 1
else
    echo "$GCC .install.succeeded exists, NOT reinstalling!"
fi

#cd $PREFIX/build
#mkdir -p build-llvm
#cd build-llvm
#if [ ! -f .config.succeeded ]; then
#    cmake -DCMAKE_BUILD_TYPE=Release -G Ninja -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_TARGETS_TO_BUILD=$LLVM_TARGETS $PREFIX/sources/llvm && \
#    touch .config.succeeded || exit 1
#else
#    echo "LLVM .config.succeeded exists, NOT reconfiguring!"
#fi
#ninja install
