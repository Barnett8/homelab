#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl ca-certificates

# Add NodeSource repo for Node.js 26.x (current LTS)
curl -fsSL https://deb.nodesource.com/setup_26.x -o /tmp/nodesource_setup.sh
sudo -E bash /tmp/nodesource_setup.sh

sudo apt-get install -y \
  build-essential \
  curl \
  wget \
	vim \
	git \
	tree \
  python3 python3-pip python3-venv python3-dev python3-setuptools python3-wheel \
	nodejs
