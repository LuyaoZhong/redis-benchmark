#!/bin/bash

sudo add-apt-repository ppa:canonical-server/nvdimm -y
sudo apt update
sudo apt install ndctl -y

region=`ndctl list -R |grep region |cut -d ':' -f2 |cut -d '"' -f2`
namespace=`ndctl list |grep namespace |cut -d ':' -f2 |cut -d '"' -f2`
if [[ -n $namespace ]]; then
	sudo ndctl create-namespace -e $namespace -m fsdax -M mem --force
	sudo ls /dev/pmem*
	sudo mkfs.ext4 /dev/pmem0
	sudo mkdir /mnt/pmem0
	sudo mount -o dax /dev/pmem0 /mnt/pmem0
	sudo chmod 777 -R /mnt/pmem0
else
	if [[ -n $region ]]; then
		ndctl create-namespace -m fsdax -r $region
	fi
fi
