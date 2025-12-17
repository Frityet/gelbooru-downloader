#!/bin/sh
set -e

apt update
apt install -y p7zip-full linux-headers-amd64 curl
su node -c "bash -c 'curl -fsSL https://xmake.io/shget.text | bash'"
