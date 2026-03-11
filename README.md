# Dotfiles Backup

The repo contains my personal configs for Linux to easily setup on a new machine using **GNU Stow** symlink manager.

## Installation
1. Clone repo 
2. Install GNU Stow

Using APT:
```bash
sudo apt install stow
```

Using Pacman:
```bash
sudo pacman -S stow
```

Using DNF (Fedora):
```
sudo dnf install stow
```

3. Apply all configs 
```bash
cd dotfiles & stow -t ~/.config config \
    & ln -s ./scripts/tmux-sessionizer /usr/local/bin/tmux-sessionizer \
    & ln -s ./config/.tmux.conf ~/.tmux.conf 
```

