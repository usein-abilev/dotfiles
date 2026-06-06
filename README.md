# Dotfiles Backup

The repo contains my personal configs for Linux to easily setup on a new machine using **GNU Stow** symlink manager.

## Configs (`config/`)

| Config | What it does |
|---|---|
| `nvim/` | **Neovim** - Gruvbox theme, lazy.nvim (18 plugins), LSP (ts_ls/gopls/eslint via mason), Telescope+fzf, nvim-cmp+LuaSnip, conform.nvim formatting, fugitive+gitsigns |
| `.tmux.conf` | **Tmux** - Ctrl+S leader, vim-style pane nav, tpm plugin manager, vim-tmux-navigator |
| `alacritty/` | **Alacritty** - terminal emulator, SFMono Nerd Font 16pt, custom dark palette |
| `hypr/` | **Hyprland** - Wayland compositor |

## Standalone Scripts (`scripts/`)

| Script | Purpose |
|---|---|
| `install.sh` | One-shot setup: stow, Oh My Zsh, Neovim nightly, Volta (Node), Go, aliases |
| `tmux-sessionizer` | fzf + tmux: fuzzy-find dirs in `/mnt/d/dev` and `~/dotfiles`, create/attach session |
| `clipvault-rofi-img.sh` | Rofi GUI for clipvault clipboard manager with image thumbnails |
| `convert_to_h264.sh` | Batch `.mov` -> `.mp4` H.264 (CRF 18, slow, BT.709) |
| `convert_to_dnxhr.sh` | Batch `.mp4`-> `.mov` DNxHR HQ (DaVinci Resolve compatible) |

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
