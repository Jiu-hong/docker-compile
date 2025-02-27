FROM ubuntu:focal

# DEBIAN_FRONTEND required for tzdata dependency install
RUN apt-get update \
      && DEBIAN_FRONTEND="noninteractive" \
      apt-get install -y sudo tzdata curl gnupg gcc git ca-certificates \
              protobuf-compiler libprotobuf-dev supervisor jq \
              pkg-config libssl-dev make build-essential gettext-base lsof python3-pip \
      && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"] 

# install cmake
RUN curl -Ls https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.tar.gz | sudo tar -C /usr/local --strip-components=1 -xz

# install rust nigthly and rustup
RUN curl -f -L https://static.rust-lang.org/rustup.sh -O \
    && sh rustup.sh -y 
ENV PATH="$PATH:/root/.cargo/bin"

RUN cargo install --git https://github.com/paritytech/cachepot
RUN python3 -m pip install toml


# copy the casper-node repo from host machine and build binaries
WORKDIR /
RUN git clone -b feat-2.0 https://github.com/casper-network/casper-node.git /casper-node
RUN source /casper-node/ci/build_update_package.sh

FROM scratch
COPY --from=0 /casper-node/target/upgrade_build upgrade_build