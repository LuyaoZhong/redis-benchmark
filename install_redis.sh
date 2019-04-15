#!/bin/bash

# opensource or pmem, install opensource redis 4.0 or pmem redis
REDIS_VERSION=$1

sudo apt update
sudo apt install -y autoconf automake libtool libtool-bin numactl tcl-dev pkg-config libndctl-dev libdaxctl-dev libnuma-dev ndctl

cd ~/
git clone https://github.com/pmem/pmem-redis.git
cd pmem-redis/
git submodule init
git submodule update

if [  "$REDIS_VERSION" = "pmem" ]; then
	make USE_NVM=yes AEP_COW=yes SUPPORT_PBA=yes USE_AOFGUARD=yes
fi

if [  "$REDIS_VERSION" = "opensource" ]; then
	make
fi

sudo cp ./src/redis-server /usr/local/bin/redis-server
sudo cp ./src/redis-cli /usr/local/bin/redis-cli
sudo cp ./src/redis-benchmark /usr/local/bin/redis-benchmark

