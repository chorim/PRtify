#!/bin/sh

echo "Installing the mint..."
brew install mint

echo "Instaling the tuist..."
curl -Ls https://install.tuist.io | bash

cd ..
make all
