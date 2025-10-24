# Dotfiles Backup

The repo contains my personal configs for Linux to easily setup on a new machine using **GNU Stow** symlink manager.

## Installation
1. Clone repo 
2. Install GNU Stow
```bash
sudo apt-get install stow
```
3. Apply all configs 
```bash
stow -t ~ dotfiles
```
or specific ones
```bash
stow -t ~/.config dotfiles/.config
```

