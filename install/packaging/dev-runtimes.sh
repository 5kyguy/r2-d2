#!/bin/bash

# Preinstall Go (official tarball to /usr/local) and Node.js (nvm), non-interactive
GO_VERSION=1.26.0
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
curl -sL "https://go.dev/dl/${GO_TAR}" | sudo tar -C /usr/local -xz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh >/dev/null

# Install nvm and default Node LTS
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -d $NVM_DIR ]]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | PROFILE=/dev/null bash
fi
if [[ -s $NVM_DIR/nvm.sh ]]; then
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
fi
