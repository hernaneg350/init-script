#!/bin/bash

function provision_ssh_and_git() {
  # Clean for idempotency
  rm -rf .ssh/id_rsa
  rm -rf .ssh/id_rsa.pub

  SSH_FILE=$HOME/.ssh/id_rsa

  ssh-keygen -t rsa -b 2048 -N "" -f $SSH_FILE

  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $1" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$(hostname)\",\"key\":\"$(<$SSH_FILE.pub)\"}"
}

home() {
  git -C $HOME --git-dir=.tracker --work-tree=. $@
}

xcode-select -p > /dev/null 2>&1

if [[ $? > 0 ]] ; then
    echo "X-Code Command Line Tools not installed. You will be redirected to installation. Please call this script again once finished."
    xcode-select --install > /dev/null 2>&1
else
    echo "Provide your PAT..."
    read PAT
    provision_ssh_and_git $PAT
    rm -rf .tracker # Clean for idempotency
    # TODO: Cloned files should also be cleaned for idempotency

    home remote add origin git@github.com:hernaneg350/home.git
    home fetch origin
    home checkout -f master
    home remote set-url origin git@github.com:hernaneg350/home.git
    home submodule update --init --recursive
fi
