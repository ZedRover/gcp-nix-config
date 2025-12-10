#!/usr/bin/env bash
nix run --impure home-manager/master -- switch --flake . -b backup
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"
