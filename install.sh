#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

mkdir -p "$BIN_DIR"
for name in ricer noctalia-ricer wallpaper-to-noctalia; do
    if [[ ! -f "$SCRIPT_DIR/$name" ]]; then
        printf 'Missing required file: %s\n' "$SCRIPT_DIR/$name" >&2
        exit 1
    fi
    install -m755 "$SCRIPT_DIR/$name" "$BIN_DIR/$name"
done

printf 'Installed Ricer scripts to %s\n' "$BIN_DIR"
printf 'Make sure that directory is on your PATH.\n'
