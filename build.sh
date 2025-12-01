nix run --impure home-manager/master -- switch --flake . -b backup
echo /home/zed/.nix-profile/bin/zsh | sudo tee -a /etc/shells
chsh -s /home/zed/.nix-profile/bin/zsh