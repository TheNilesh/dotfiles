#!/usr/bin/env bash
set -euo pipefail

TPM="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"

if [[ ! -d "$TPM/.git" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM"
fi

"$TPM/bin/install_plugins"