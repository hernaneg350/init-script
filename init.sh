#!/bin/bash

xcode-select -p > /dev/null 2>&1

if [[ $0 > 0 ]] ; then
    echo "X-Code Command Line Tools not installed. You will be redirected to installation. Please call this script again once finished."
    xcode-select --install > /dev/null 2>&1
    exit 0
fi

echo "Provide your PAT..."
read PAT
git -C $HOME clone --recurse-submodules --separate-git-dir=$HOME/.tracker https://$PAT@github.com/hernaneg350/home.git


