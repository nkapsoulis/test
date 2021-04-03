#!/bin/bash

if [ -d "/local" ] && [ "$(ls /local)" ]; then
	exit 0;
fi

sudo apt-get update
sudo apt-get install -y nfs-kernel-server
sudo dpkg --configure -a

cp -r src/ /local/
mv /local/src /local/organizations

if [ ! -d "/local/bin" ]; then 
	cd /local/ && curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/release-2.2/scripts/bootstrap.sh | bash -s 2.2.0 1.4.7 -ds && cd -
fi

sudo chown nobody:nogroup /local/ /local/*
sudo chmod 777 /local /local/*

sudo cat /etc/exports | grep local
# sudo cat /etc/exports | grep -v local > /etc/exports # to correct wrong entries
if [ ! "$(cat /etc/exports | grep local)" ]; then # if NULL then
	sudo echo '/local/bin	CLIENT_IP(rw,no_root_squash,no_subtree_check)' >> /etc/exports;
	sudo echo '/local/organizations	CLIENT_IP(rw,no_root_squash,no_subtree_check)' >> /etc/exports;
	sudo exportfs -a
	sudo systemctl restart nfs-kernel-server # showmount -e CLIENT_IP
fi

if [ "$(sudo ufw status | grep Status | awk '{print $2}')" == active ]; then 
	sudo ufw allow from CLIENT_IP to any port nfs
	sudo ufw status
fi

# echo etc.exports && cat /usr/share/nfs-kernel-server/conffiles/etc.exports
