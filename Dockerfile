FROM ubuntu:bionic

ARG LLVM_VERSION=8

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN buildDeps="gnupg software-properties-common wget" \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-add-repository "deb https://apt.kitware.com/ubuntu/ bionic main" \
    && apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-${LLVM_VERSION} main" \
    && apt-get purge --auto-remove -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
        clang-${LLVM_VERSION} \
        clang-tidy-${LLVM_VERSION} \
        cmake \
        ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN buildDeps="g++ git libclang-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev zlib1g-dev" \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && git clone -b clang_${LLVM_VERSION}.0 --depth 1 https://github.com/include-what-you-use/include-what-you-use.git \
    && mkdir include-what-you-use/build \
    && cd include-what-you-use/build \
    && cmake -GNinja .. \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DLLVM_CONFIG_EXECUTABLE:FILEPATH=/usr/bin/llvm-config-${LLVM_VERSION} \
    && ninja \
    && ninja install \
    && cd / \
    && rm -rf include-what-you-use \
    && apt-get purge --auto-remove -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

RUN buildDeps="g++ git libclang-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev zlib1g-dev" \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && git clone -b 1.5 --depth 1 https://github.com/KDE/clazy.git \
    && mkdir clazy/build \
    && cd clazy/build \
    && cmake -GNinja .. \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DLLVM_CONFIG_EXECUTABLE:FILEPATH=/usr/bin/llvm-config-${LLVM_VERSION} \
    && ninja \
    && ninja install \
    && cd / \
    && rm -rf clazy \
    && apt-get purge --auto-remove -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

ENV CC="/usr/lib/llvm-${LLVM_VERSION}/bin/clang" \
    CLANGCXX="/usr/lib/llvm-${LLVM_VERSION}/bin/clang++" \
    CXX="/usr/bin/clazy" \
    PATH=/usr/lib/llvm-${LLVM_VERSION}/bin:$PATH
