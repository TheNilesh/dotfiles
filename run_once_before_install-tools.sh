#!/usr/bin/env bash
set -e

sudo apt update

sudo apt install -y \
  ripgrep \
  fd-find \
  bat \
  fzf \
  tmux

if command -v go >/dev/null 2>&1; then
  go install github.com/charmbracelet/glow/v2@latest
  go install github.com/charmbracelet/gum@latest
fi
