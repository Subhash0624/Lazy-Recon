#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Go is installed
if ! command_exists go; then
  echo "Installing Go..."
  wget -qO- https://golang.org/dl/go1.17.5.linux-amd64.tar.gz | tar -C /usr/local -xzf -
  export PATH=$PATH:/usr/local/go/bin
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  source ~/.bashrc
else
  echo "Go is already installed."
fi

# Check if subfinder is installed
if ! command_exists subfinder; then
  echo "Installing subfinder..."
  GO111MODULE=off go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
else
  echo "subfinder is already installed."
fi

# Check if assetfinder is installed
if ! command_exists assetfinder; then
  echo "Installing assetfinder..."
  GO111MODULE=off go get -u github.com/tomnomnom/assetfinder
else
  echo "assetfinder is already installed."
fi

# Check if httpx is installed
if ! command_exists httpx; then
  echo "Installing httpx..."
  GO111MODULE=off go get -v github.com/projectdiscovery/httpx/cmd/httpx
else
  echo "httpx is already installed."
fi

# Check if nuclei is installed
if ! command_exists nuclei; then
  echo "Installing nuclei..."
  GO111MODULE=off go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
else
  echo "nuclei is already installed."
fi

# Check if paramspider is installed
if [ ! -d "ParamSpider" ]; then
  echo "Installing paramspider..."
  git clone https://github.com/devanshbatham/ParamSpider.git
  cd ParamSpider || exit
  pip3 install -r requirements.txt
  cd ..
else
  echo "paramspider is already installed."
fi

# Check if SQLMap is installed
if ! command_exists sqlmap; then
  echo "Installing SQLMap..."
  apt-get update
  apt-get install -y sqlmap
else
  echo "SQLMap is already installed."
fi

# Check if kxss is installed
if ! command_exists kxss; then
  echo "Installing kxss..."
  GO111MODULE=off go get -v github.com/Emoe/kxss
else
  echo "kxss is already installed."
fi

echo "Installation completed."
