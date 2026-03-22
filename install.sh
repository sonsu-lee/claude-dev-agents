#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

for dir in agents rules; do
  target="$CLAUDE_DIR/$dir"

  if [ -L "$target" ]; then
    echo "$dir: already symlinked, skipping"
  elif [ -d "$target" ]; then
    mv "$target" "${target}.bak"
    ln -s "$REPO_DIR/$dir" "$target"
    echo "$dir: backed up to ${dir}.bak, symlinked"
  else
    mkdir -p "$CLAUDE_DIR"
    ln -s "$REPO_DIR/$dir" "$target"
    echo "$dir: symlinked"
  fi
done

echo "Done."
