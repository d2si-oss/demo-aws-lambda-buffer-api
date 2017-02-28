#!/usr/bin/env bash

set -e
set -x

pip install awscli
apt-get install -y curl tar
curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh
