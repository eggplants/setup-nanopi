#!/usr/bin/env bash
set -euo pipefail

repo='https://github.com/eggplants/setup-nanopi.git'
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git
fi

if ! command -v mise &>/dev/null; then
  curl -fsSL https://mise.run | sh
fi

if [[ ! -d "$config_dir/.git" ]]; then
  git clone "$repo" "$config_dir"
fi

# Recordings and the MariaDB data live on the external storage
if ! mountpoint -q /mnt/hdd1; then
  mise run hdd:init
fi

# --update: refresh apt metadata after [bootstrap.files] rewrites the apt sources
mise bootstrap --update "$@"
