#!/bin/bash

xcode-select -p > /dev/null 2>&1

if [[ $? > 0 ]] ; then
    echo "X-Code Command Line Tools not installed. You will be redirected to installation. Please call this script again once finished."
    xcode-select --install > /dev/null 2>&1
else
    echo "Provide your PAT..."
    read PAT
    rm -rf .tracker # Clean for idempotency
    GIT_DIR=.tracker git -C $HOME init
    alias home="git -C $HOME --git-dir=.tracker --work-tree=."
    home remote add origin https://$PAT@github.com/hernaneg350/home.git
    home fetch origin
    home checkout -f origin/master
    home remote set-url origin git@github.com:hernaneg350/home.git
fi
