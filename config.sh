SYSTEM_HEADER_PROJECTS="libc kernel"
PROJECTS="libc kernel"

export MAKE=${MAKE:-make}
export HOST=${HOST:-$(./default-host.sh)}

export AR=${HOST}-ar
export AS=${HOST}-as
export CC="clang -v --target=${HOST} -march=x86-64"
export CXX="clang++ -v --target=${HOST} -march=x86-64"
if echo "$HOST" | grep -Eq -- 'x86_64-elf'; then
  export NASM="nasm -f elf64"
else
  export NASM=nasm
fi

export PREFIX=/usr
export EXEC_PREFIX=$PREFIX
export BOOTDIR=/boot
export LIBDIR=$EXEC_PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export CFLAGS='-O2 -g -Wall -Werror -pedantic'
export CXXFLAGS='--std=c++11'
export CPPFLAGS=''

# Configure the cross-compiler to use the desired system root.
export CC="$CC --sysroot=$PWD/sysroot"
export CXX="$CXX --sysroot=$PWD/sysroot"

# Work around that the -elf gcc targets doesn't have a system include directory
# because configure received --without-headers rather than --with-sysroot.
if echo "$HOST" | grep -Eq -- '-elf($|-)'; then
  export CC="$CC -isystem=$INCLUDEDIR"
  export CXX="$CXX -isystem=$INCLUDEDIR"
fi
