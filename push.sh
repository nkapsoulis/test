#!/bin/bash

git add .
git status
if [ "$1" > /dev/null ];then 
	git commit -m "$1"
	git push
fi

