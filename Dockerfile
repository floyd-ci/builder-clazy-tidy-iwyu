FROM floydci/debian:testing

ARG LLVM_VERSION=7

RUN apt-get update && apt-get install -y --no-install-recommends \
        clang-${LLVM_VERSION} \
        clang-tidy-${LLVM_VERSION} \
        iwyu \
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
