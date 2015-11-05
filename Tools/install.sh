#!/bin/zsh
if ! [ -w /usr/local ] || ! [ -d /usr/local ]
then
  echo "\033[0;31mYou don't have a /usr/local directory or it is not writable, please create it and make sure you have write permissions to it before running this script again.\033[0m"
  exit
fi

mkdir -p /usr/local/tranquil

echo "\033[0;32mI'm about to retrieve and compile Tranquil for you. This will take around 20 minutes,\ndepending on your connection & hardware of course.\n"

echo "\033[0;34mInstalling LLVM (This is the part that takes a while)...\033[0m"
if [ -d /usr/local/tranquil/llvm ]
then
  echo "\033[0;32mYou already have llvm installed.\033[0m"
else
    hash svn || {
      echo "\033[0;31msubversion not installed\033[0m"
      exit
    }
    mkdir -p /tmp/llvm.build
    pushd /tmp/llvm.build
        curl -O http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz
        curl -O http://llvm.org/releases/3.5.0/cfe-3.5.0.src.tar.xz
        curl -O http://llvm.org/releases/3.5.0/compiler-rt-3.5.0.src.tar.xz

        tar -xJf llvm-3.5.0.src.tar.xz
        pushd llvm-3.5.0.src/tools
            tar -xJf ../../cfe-3.5.0.src.tar.xz
            tar -xJf ../../compiler-rt-3.5.0.src.tar.xz
            mv cfe-3.5.0.src clang
            mv compiler-rt-3.5.0.src compiler-rt
        popd

        mkdir build
        pushd build
            env UNIVERSAL=1 UNIVERSAL_ARCH="i386 x86_64" ../llvm-3.5.0.src/configure --host=x86_64-apple-darwin --prefix=/usr/local/tranquil/llvm --enable-targets=arm,x86,x86_64,cpp --enable-libffi --enable-optimized
            env UNIVERSAL=1 UNIVERSAL_ARCH="i386 x86_64" make -j2
            make install
        popd
    popd
fi

echo "\n\033[0;34mInstalling Ragel\033[0m"
if [ -d /usr/local/tranquil/ragel ]
then
  echo "\033[0;32mYou already have ragel installed.\033[0m"
else
    pushd /tmp
        RAGEL_VERSION=6.9
        RAGEL_URL_PATH=http://www.colm.net/files/ragel
        RAGEL_TARBALL=ragel-${RAGEL_VERSION}.tar.gz
        curl ${RAGEL_URL_PATH}/${RAGEL_TARBALL} -o ${RAGEL_TARBALL}
        tar -xzf ${RAGEL_TARBALL}
        cd ragel-${RAGEL_VERSION}
        ./configure --prefix=/usr/local/tranquil/ragel
        make
        make install
    popd
fi

echo "\n\033[0;34mInstalling Lemon\033[0m"
if [ -d /usr/local/tranquil/lemon ]
then
  echo "\033[0;32mYou already have lemon installed.\033[0m"
else
    pushd /tmp
        curl http://tx97.net/pub/distfiles/lemon-1.69.tar.bz2 -o lemon-1.69.tbz
        tar -xzf lemon-1.69.tbz
        cd lemon-1.69
        mkdir -p /usr/local/tranquil/lemon/bin
        /usr/local/tranquil/llvm/bin/clang lemon.c -o /usr/local/tranquil/lemon/bin/lemon
        cp lempar.c /usr/local/tranquil/lemon/bin
    popd
fi

echo "\n\033[0;34mInstalling libffi\033[0m"
if [ -d /usr/local/tranquil/libffi ]
then
  echo "\033[0;32mYou already have libffi installed.\033[0m"
else
    pushd /tmp
        git clone --recursive https://github.com/pandamonia/libffi-iOS.git
        cd libffi-iOS

        xcodebuild -alltargets

        mkdir -p /usr/local/tranquil/libffi-ios/lib
        lipo build/Release-iphoneos/libffi.a -create -output /usr/local/tranquil/libffi-ios/lib/libffi.a
        cp -R build/Release-iphoneos/usr/local/include /usr/local/tranquil/libffi-ios/include

        mkdir -p /usr/local/tranquil/libffi/lib
        lipo build/Release/libffi.a -output /usr/local/tranquil/libffi/lib/libffi.a -extract x86_64
        cp -R build/Release/usr/local/include /usr/local/tranquil/libffi/include
    popd
fi

echo "\n\033[0;34mInstalling GNU MP...\033[0m"
if [ -d /usr/local/tranquil/gmp ]
then
  echo "\033[0;32mYou already have GMP installed.\033[0m"
else
    pushd /tmp
        curl ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.bz2 -o gmp-5.0.5.tar.bz2
        tar xzf gmp-5.0.5.tar.bz2
        pushd gmp-5.0.5
            ./configure --with-pic --prefix=/usr/local/tranquil/gmp
            make
            make check
            make install
        popd
    popd
fi


if [ -d /usr/local/tranquil/src ]
then
    echo "\n\033[0;34mUpdating Tranquil...\033[0m"
    pushd /usr/local/tranquil/src
        git pull
        git submodule foreach git pull
    popd
else
    echo "\n\033[0;34mCloning Tranquil from GitHub...\033[0m"
    hash git >/dev/null || {
      echo "\033[0;31mgit not installed\033[0m"
      exit
    }
    TRANQUIL_REPO=git://github.com/igorclark/Tranquil.git
    git clone ${TRANQUIL_REPO} /usr/local/tranquil/src
fi

echo "\033[0;34mCompiling...\033[0m"
pushd /usr/local/tranquil/src/
    rake || {
      echo "\033[0;31mError building tranquil!\033[0m"
      exit
    }
popd

echo "\n\033[0;32mCongratulations!\n\033[0;33mYou can now find the Tranquil binary at '\033[0m/usr/local/tranquil/bin/tranquil\033[0;33m'\033[0m"
echo "\n\033[0;33m(You'll probably want to add /usr/local/tranquil/bin to your \033[0mPATH\033[0;33m)\033[0m"
