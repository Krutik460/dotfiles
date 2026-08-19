#!/usr/bin/env bash
# Takes a fresh Mac from nothing to this setup: Homebrew packages, dotfile
# symlinks, macOS defaults, and herdr plugins.
# Idempotent - rerun it after adding a package or symlink.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Homebrew"
if [ -x /opt/homebrew/bin/brew ]; then
  echo "    already installed, skipping"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# Every config symlink below resolves through ~/.dotfiles, so if the repo
# ever moves, only this one link needs updating.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: Homebrew packages"
brew install herdr starship zsh-autosuggestions zsh-syntax-highlighting
# renderers the herdr file-viewer plugin shells out to (plain text without them)
brew install glow git-delta bat
brew install --cask wezterm tailscale-app font-hack-nerd-font

echo "==> Step 4: Claude Code (native installer, self-updates via 'claude update')"
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
  echo "    already installed, skipping"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

echo "==> Step 5: dotfile symlinks"
mkdir -p ~/.config/opencode ~/.claude/skills ~/.codex ~/.pi/agent
ln -sfn ~/.dotfiles/home/.zshrc ~/.zshrc
ln -sfn ~/.dotfiles/home/.config/starship.toml ~/.config/starship.toml
ln -sfn ~/.dotfiles/home/.config/wezterm ~/.config/wezterm
ln -sfn ~/.dotfiles/home/.config/nvim ~/.config/nvim
ln -sfn ~/.dotfiles/home/.config/herdr ~/.config/herdr
ln -sfn ~/.dotfiles/home/.claude/settings.json ~/.claude/settings.json
# Skills are linked one by one, not as a directory: apps (e.g. ego) install
# their own skills into ~/.claude/skills and those stay machine-local.
ln -sfn ~/.dotfiles/home/.claude/skills/unslop ~/.claude/skills/unslop
# Claude, Codex, and opencode all share the one AGENTS.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.codex/AGENTS.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.config/opencode/AGENTS.md
# Pi: link only authored files and directories so credential and runtime
# state stays local to the machine.
ln -sfn ~/.dotfiles/home/.pi/agent/themes ~/.pi/agent/themes
ln -sfn ~/.dotfiles/home/.pi/agent/extensions ~/.pi/agent/extensions
ln -sfn ~/.dotfiles/home/.pi/agent/models.json ~/.pi/agent/models.json
ln -sfn ~/.dotfiles/home/.pi/agent/settings.json ~/.pi/agent/settings.json

echo "==> Step 6: macOS defaults"
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain KeyRepeat -int 2          # fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15  # short delay before repeat
defaults write NSGlobalDomain _HIHideMenuBar -bool true # auto-hide the menu bar
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"  # list view by default
defaults write com.apple.finder CreateDesktop -bool false            # clean desktop
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true # tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
killall Dock Finder 2>/dev/null || true

echo "==> Step 7: herdr plugins"
# Plugin state is deliberately gitignored (it embeds machine-specific paths),
# which is why this install step exists.
if herdr plugin list 2>/dev/null | grep -q "herdr-file-viewer"; then
  echo "    herdr-file-viewer already installed, skipping"
else
  herdr plugin install smarzban/herdr-file-viewer
fi

echo "==> Step 8: herdr agent integration (claude)"
# Installs ~/.claude/hooks/herdr-agent-state.sh and the matching SessionStart
# block in ~/.claude/settings.json. Both are herdr-generated and herdr-versioned
# (it overwrites them on upgrade), so they're installed here rather than
# committed - a pinned copy would silently go stale. See AGENTS.md.
herdr integration install claude

echo "==> Done. Edit files in home/ and changes apply immediately - everything is symlinked."
