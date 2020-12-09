#!/bin/bash

set -euo pipefail

log() {
  echo
  echo "----------------------------------------------------------------------"
  echo "$1"
  echo "----------------------------------------------------------------------"
  echo
}

install_brew() {
  if [ "$1" != "" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_ansible() {
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    log "ansible-playbook not found on \$PATH, installing"
    install_brew "$1"
    brew install ansible
  fi
}

install_ansible_linux() {
  sudo apt-get install -y python3 python3-pip libssl-dev
  pip3 install --user ansible
}

run_it() {
  log "Configuring machine for $tag"
  (
    cd "$(dirname "$0")"
    ansible-galaxy install -r requirements.yml
    cmd="ansible-playbook -v -e ansible_python_interpreter=/usr/bin/python3 -i localhost, --tags $tag --con local playbook.yml"
    $cmd
  )

  source "$HOME/.bash_profile"

  log "Don't forget to read the post install steps for your section in README.md."
}

user="$*"
case $user in
m)
  tag="m-rcd"
  install_ansible
  ;;
c)
  tag="callisto"
  install_ansible "$tag"
  ;;
l)
  tag="linux"
  install_ansible_linux
  ;;
*)
  log "Usage: ./run.sh <m|c|l>"
  exit 0
  ;;
esac

run_it
