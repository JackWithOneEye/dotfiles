!#/usr/bin/env bash

set -euo pipefall

omarchy update -y
omarchy update firmware

# Login
sudo sed -i '/^\[Autologin\]/,/^\[Theme\]/{/^\[Theme\]/!d}' /etc/sddm.conf.d/autologin.conf

# SSH
sudo systemctl enable --now sshd
sudo ufw allow in ssh

# neovim
rm -rf ~/.config/nvim
ln -s ~/Projects/dotfiles/config/nvim ~/.config/nvim

# Install stuff
for d in bun go rust zig; do
  omarchy install dev-env $d
done

omarchy install terminal ghostty

# Remove stuff
omarchy remove gaming 2>&1 |
  grep -o 'omarchy remove gaming [a-z].*' |
  while IFS= read -r cmd; do
    echo "==> $cmd"
    eval "$cmd"
  done

for p in spotify obsidian pinta localsend libreoffice-fresh signal-desktop mpv obs kdenlive 1password-beta 1password-cli typora; do
  omarchy pkg drop $p
done

echo "done. reboot now!"
