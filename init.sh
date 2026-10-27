#!/bin/bash

# This script is meant to be sourced (see README.md), so it runs in the user's
# own shell: bash on Ubuntu, usually zsh on macOS. Keep it portable between
# both, and use `return` instead of `exit`.

HOME_REPO_URL=git@github.com:hernaneg350/home.git

function as_root() {
  if [ "$(id -u)" = 0 ] ; then
    "$@"
  else
    sudo "$@"
  fi
}

# Makes sure git, curl and ssh exist, and prints and returns 1 if the OS isn't
# supported. On macOS, installing them means installing the Command Line
# Tools, which is interactive: the script has to be called again afterwards.
function install_prerequisites() {
  case "$(uname)" in
    Darwin)
      if ! xcode-select -p > /dev/null 2>&1 ; then
        echo "X-Code Command Line Tools not installed. You will be redirected to installation. Please call this script again once finished."
        xcode-select --install > /dev/null 2>&1
        return 1
      fi
      ;;
    Linux)
      if [ "$(. /etc/os-release && echo "$ID")" != "ubuntu" ] ; then
        echo "Only Ubuntu is supported on Linux."
        return 1
      fi
      as_root apt-get update
      as_root apt-get install -y git curl openssh-client ca-certificates
      ;;
    *)
      echo "Unsupported OS: $(uname)"
      return 1
      ;;
  esac
}

function provision_ssh_and_git() {
  SSH_FILE=$HOME/.ssh/id_rsa

  # Clean for idempotency
  rm -rf "$SSH_FILE" "$SSH_FILE.pub"
  mkdir -p "$HOME/.ssh"

  ssh-keygen -t rsa -b 2048 -N "" -f "$SSH_FILE"

  local response http_status body

  response="$(curl -sS \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $1" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -w '\n%{http_code}' \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$(hostname)\",\"key\":\"$(<$SSH_FILE.pub)\"}")" || return 1

  http_status="${response##*$'\n'}"
  body="${response%$'\n'*}"

  case "$http_status" in
    201)
      echo "SSH key registered on GitHub."
      ;;
    401)
      echo "GitHub rejected the token (401): it is wrong, expired or revoked."
      return 1
      ;;
    403|404)
      # GitHub can answer 404 (not only 403) for a token that can't manage keys.
      echo "GitHub answered $http_status: $body"
      echo "The token is probably missing permission to manage SSH keys:"
      echo "  - classic token: the 'write:public_key' scope"
      echo "  - fine-grained token: Account permissions > 'Git SSH keys' > Read and write"
      return 1
      ;;
    *)
      echo "GitHub answered $http_status: $body"
      return 1
      ;;
  esac
}

home() {
  git -C $HOME --git-dir=.tracker --work-tree=. "$@"
}

# The preset decides what `home`'s install.sh installs. It is read from
# ~/.config/home/preset (or $XDG_CONFIG_HOME/home/preset); this is what
# creates that file. It has to run after `home` has been checked out so that
# the available presets can be listed and the answer validated.
function select_preset() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/home"
  local available
  local preset

  available="$(grep -o '^\[presets\.[A-Za-z0-9_-]*\]' "$HOME/presets.toml" | sed 's/^\[presets\.//; s/\]$//')"

  if [ -z "$available" ] ; then
    echo "No presets found in $HOME/presets.toml."
    return 1
  fi

  echo "Available presets:"
  echo "$available" | sed 's/^/  - /'

  while true ; do
    printf "Preset for this machine: "
    read -r preset

    if echo "$available" | grep -qx -- "$preset" ; then
      break
    fi

    echo "'$preset' is not one of the available presets."
  done

  mkdir -p "$config_dir"
  echo "$preset" > "$config_dir/preset"
  echo "Preset '$preset' saved to $config_dir/preset"
}

install_prerequisites && {
    echo "Provide your PAT..."
    read PAT
    provision_ssh_and_git $PAT || return 1
    rm -rf "$HOME/.tracker" # Clean for idempotency
    # TODO: Cloned files should also be cleaned for idempotency
    GIT_DIR=.tracker git -C $HOME init

    home remote add origin $HOME_REPO_URL
    home fetch origin
    home checkout -f origin/master
    home remote set-url origin $HOME_REPO_URL
    home submodule update --init --recursive

    select_preset && echo "Done. Call ~/install.sh to provision this machine."
}
