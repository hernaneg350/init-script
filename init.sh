#!/bin/bash

xcode-select --install

echo "Provide your PAT..."
read PAT
git -C $HOME clone --recurse-submodules --separate-git-dir=$HOME/.tracker https://$PAT@github.com/hernaneg350/home.git
