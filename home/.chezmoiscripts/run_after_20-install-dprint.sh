#!/usr/bin/env bash
set -euo pipefail

if command -v dprint >/dev/null 2>&1; then
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  brew install dprint
  exit 0
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --locked dprint
  exit 0
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsSL https://dprint.dev/install.sh | sh
  exit 0
fi

echo "No supported dprint installer found; install Homebrew, Cargo, or curl first." >&2
