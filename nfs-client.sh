#!/bin/bash

if [ -d "/local" ] && [ "$(ls /local)" ]; then
	exit 0;
fi

sudo apt-get update
sudo apt-get install -y nfs-common
sudo dpkg --configure -a

sudo mkdir -p /local
sudo mount HOST_IP:/local /local
