#!/bin/bash

sudo apt-get update
sudo apt-get install -y nfs-kernel-server
sudo dpkg --configure -a

sudo mkdir -p /local/organizations
sudo mount --bind organizations/ /local/organizations

cd /local/ && curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/release-2.2/scripts/bootstrap.sh | bash -s 2.2.0 1.4.7 -ds && cd -

sudo chown nobody:nogroup /local/ /local/*
sudo chmod 777 /local /local/*
sudo echo '/local/bin	CLIENT_IP(rw,no_root_squash,no_subtree_check)' >> /etc/exports 
sudo echo '/local/organizations	CLIENT_IP(rw,no_root_squash,no_subtree_check)' >> /etc/exports 
sudo exportfs -a
sudo systemctl restart nfs-kernel-server # showmount -e CLIENT_IP
if [ "$(sudo ufw status | grep Status | awk '{print $2}')" == active ]; then 
	sudo ufw allow from CLIENT_IP to any port nfs
	sudo ufw status
fi

