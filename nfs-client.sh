#!/bin/bash

sudo apt update
sudo apt install -y nfs-common
sudo mkdir -p /local
sudo mount HOST_IP:/local /local
