#!/usr/bin/env bash

# Remove old CommandLineTools to force upgrade
sudo rm -rf /Library/Developer/CommandLineTools

# Install the latest version
sudo xcode-select --install

