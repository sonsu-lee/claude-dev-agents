#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Install agents and rules for Claude Code."
  echo ""
  echo "Options:"
  echo "  --global       Install to ~/.claude/ (all projects)"
  echo "  --dir DIR      Install to DIR/.claude/"
  echo "  --unlink       Remove existing symlinks from ~/.claude/"
  echo "  -h, --help     Show this help"
  echo ""
  echo "By default, installs to \$PWD/.claude/ (current directory)."
  echo ""
  echo "Examples:"
  echo "  ./install.sh                   # copy to \$PWD/.claude/"
  echo "  ./install.sh --global          # copy to ~/.claude/"
  echo "  ./install.sh --dir ~/dev/app   # copy to ~/dev/app/.claude/"
  echo "  ./install.sh --unlink          # remove old symlinks from ~/.claude/"
}

MODE="project"
TARGET_BASE="$PWD/.claude"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      MODE="global"
      TARGET_BASE="$HOME/.claude"
      shift
      ;;
    --dir)
      MODE="project"
      TARGET_BASE="${2:?--dir requires a directory argument}/.claude"
      shift 2
      ;;
    --unlink)
      MODE="unlink"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Unlink mode: remove symlinks and stop
if [ "$MODE" = "unlink" ]; then
  for dir in agents rules; do
    target="$HOME/.claude/$dir"
    if [ -L "$target" ]; then
      rm "$target"
      echo "$dir: symlink removed"
    else
      echo "$dir: not a symlink, skipping"
    fi
  done
  echo "Done. Symlinks removed."
  exit 0
fi

mkdir -p "$TARGET_BASE"

for dir in agents rules; do
  target="$TARGET_BASE/$dir"

  # Remove existing symlink first
  if [ -L "$target" ]; then
    rm "$target"
    echo "$dir: removed old symlink"
  fi

  # Back up existing directory
  if [ -d "$target" ]; then
    mv "$target" "${target}.bak"
    echo "$dir: backed up to ${dir}.bak"
  fi

  # Copy files
  cp -r "$REPO_DIR/$dir" "$target"
  echo "$dir: copied to $target"
done

echo "Done. Files copied to $TARGET_BASE/"
