FROM ubuntu:jammy

# DEBIAN_FRONTEND required for tzdata dependency install
RUN apt-get update \
      && DEBIAN_FRONTEND="noninteractive" \
      apt-get install -y sudo tzdata curl gnupg gcc git ca-certificates \
              protobuf-compiler libprotobuf-dev supervisor jq \
              pkg-config libssl-dev make build-essential gettext-base lsof \
      && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"] 

# install cmake
RUN curl -Ls https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.tar.gz | sudo tar -C /usr/local --strip-components=1 -xz

# install rust nigthly and rustup
RUN curl -f -L https://static.rust-lang.org/rustup.sh -O \
    && sh rustup.sh -y 
ENV PATH="$PATH:/root/.cargo/bin"

# set few environment variables needed for the nctl build scripts

# copy the casper-node repo from host machine and build binaries
WORKDIR /
RUN git clone -b release-2.0.0 https://github.com/casper-ecosystem/casper-client-rs.git
WORKDIR casper-client-rs
RUN cargo build --release

# stage 2
FROM scratch
COPY --from=0 /casper-client-rs/target/release/casper-client /tmp/v1/22.04/casper-client