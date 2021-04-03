#!/bin/bash

git add .
git status
if [ "$1" > /dev/null ];then 
	git commit -m "$1"
	git push 
fi
git status

### Automate "git push" without password prompt
# git remote set-url origin git+ssh://git@gitlab.com/nkapsoulis/test.git
# ssh-keygen -o -t rsa -b 4096 -C "testKey@testKey.testKey" # name as '/home/komodo/.ssh/testKey'
# subl .git/config
# 	[core] sshCommand = ssh -o IdentitiesOnly=yes -i ~/.ssh/testKey -F /dev/null
# 	[remote "origin"] url = git+ssh://git@gitlab.com/nkapsoulis/test.git
