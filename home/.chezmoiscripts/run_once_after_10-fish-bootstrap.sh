#!/usr/bin/env bash
set -euo pipefail

if ! command -v fish >/dev/null 2>&1; then
  echo "fish not installed; skipping fisher/plugin bootstrap" >&2
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl not installed; skipping fisher/plugin bootstrap" >&2
  exit 0
fi

if [ -x "$HOME/.local/bin/bootstrap-fish" ]; then
  "$HOME/.local/bin/bootstrap-fish"
  exit 0
fi

fish -c 'type -q fisher; or begin; curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher; end'
fish -c 'fisher update'

