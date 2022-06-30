FROM redis:bullseye as redis-bin

# build buck from source
FROM ubuntu:20.04 AS buck

ARG BUCK_VERSION=2021.05.05.01
ENV ANT_OPTS="-Xmx4096m"
RUN apt-get update  && apt-get install  -y --no-install-recommends \
    ant \
    git \
    openjdk-11-jdk-headless \
    python-setuptools \
    python3-setuptools
# install buck by compiling it from source. We also remove the buck repo once it's built.
RUN git clone --depth 1 --branch v${BUCK_VERSION} https://github.com/facebook/buck.git \
    && cd buck \
    && ant \
    && ./bin/buck build buck --config java.target_level=11 --config java.source_level=11 --out /tmp/buck.pex

# Main image
FROM gitpod/workspace-full:latest
SHELL ["/bin/bash", "-c"]

LABEL org.opencontainers.image.description="This image provides a base Android development environment for React Native and Flutter, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-8512546_latest.zip
ARG ANDROID_BUILD_VERSION=31
ARG ANDROID_TOOLS_VERSION=31.0.0
ARG NDK_VERSION=23.2.8568313
ARG CMAKE_VERSION=3.18.1

# set default environment variables, please don't remove old env for compatibilty issue
ENV ANDROID_HOME=/home/gitpod/androidsdk
ENV ADB_INSTALL_TIMEOUT=10 \
    ANDROID_SDK_ROOT=${ANDROID_HOME} \
    ANDROID_NDK=${ANDROID_HOME}/ndk/${NDK_VERSION} \
	CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin

# Install flutter
ARG FLUTTER_VERSION=3.0.3-stable
USER gitpod
RUN FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz; \
    curl -fsSL ${FLUTTER_URL} | tar -xJ -C /home/gitpod; \
    /home/gitpod/flutter/bin/flutter precache; \
    echo 'export PATH="$PATH:/home/gitpod/flutter/bin"' >> /home/gitpod/.bashrc;

# Install Open JDK
USER root
RUN apt-get update; \
    apt-get install openjdk-11-jdk-headless -y;

# download and install buck using debian package
COPY --from=buck /tmp/buck.pex /usr/local/bin/buck

# download and install watchman
ARG WATCHMAN_VERSION=v2022.06.20.00
RUN curl -sS -L https://github.com/facebook/watchman/releases/download/${WATCHMAN_VERSION}/watchman-${WATCHMAN_VERSION}-linux.zip -o /tmp/watchman.zip; \
    unzip /tmp/watchman.zip -d /tmp; \
    cp /tmp/watchman-${WATCHMAN_VERSION}-linux/* /usr/local/; \
    rm -rf /tmp/watchman*;

# download cloudflared tunnel
RUN curl -sS -o /usr/local/bin/cloudflared -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64; \
    chmod +x /usr/local/bin/cloudflared

COPY --from=redis-bin /usr/local/bin/redis* /usr/local/bin/

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
# workaround buck clang version detection by symlinking
USER gitpod
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip; \
    mkdir -p ${ANDROID_HOME}/cmdline-tools; \
    unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip; \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest; \
    rm /tmp/sdk.zip; \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses; \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;$CMAKE_VERSION" \
        "ndk;$NDK_VERSION"; \
    cp ${ANDROID_HOME}/build-tools/31.0.0/d8 ${ANDROID_HOME}/build-tools/31.0.0/dx; \
    cp ${ANDROID_HOME}/build-tools/31.0.0/lib/d8.jar ${ANDROID_HOME}/build-tools/31.0.0/lib/dx.jar; \
    rm -rf ${ANDROID_HOME}/.android; \
    echo 'export PATH=$ANDROID_NDK:$CMAKE_BIN_PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin:$PATH' >> /home/gitpod/.bashrc;
