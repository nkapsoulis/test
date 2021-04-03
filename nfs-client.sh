#!/bin/bash

sudo apt-get update
sudo apt-get install -y nfs-common
sudo dpkg --configure -a

sudo mkdir -p /local
sudo mount HOST_IP:/local /local
