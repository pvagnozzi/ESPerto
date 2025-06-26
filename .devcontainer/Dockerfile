    FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

# Install additional packages for ESP32 development
RUN apt-get update && apt-get -y dist-upgrade \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        python3-pip \
        python3-venv \
        python3-setuptools \
        python3-serial \
        python3-click \
        python3-cryptography \
        python3-future \
        python3-pyparsing \
        python3-pyelftools \
        libusb-1.0-0-dev \
        libffi-dev \
        pkg-config \
        cmake \
        ninja-build \
        ccache \
        dfu-util \
        screen \
        minicom \
        openocd \
        gdb-multiarch \
        flex \
        bison \
        gperf \
        libssl-dev \
        libudev-dev \
        libboost-all-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install PlatformIO
COPY post-create.sh /tmp/post-create.sh
RUN chmod +x /tmp/post-create.sh
RUN bash /tmp/post-create.sh

# Create workspace directory
RUN mkdir -p /workspaces
WORKDIR /workspaces

# Set the default user
USER vscode
