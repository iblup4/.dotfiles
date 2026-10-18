#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target="$HOME"
dry_run=false
packages=()

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--target DIR] [PACKAGE ...]

Install dotfiles for macOS and Linux/WSL using GNU Stow.

Packages: home tmux nvim kitty alacritty
Defaults: home tmux nvim, plus kitty/alacritty when their commands are available.

Options:
  --dry-run     Preview links without changing files.
  --target DIR  Install into an existing directory (default: $HOME).
  -h, --help    Show this help.

Examples:
  ./install.sh --dry-run
  ./install.sh home tmux nvim
  ./install.sh kitty
EOF
}

die() {
  printf 'install.sh: %s\n' "$*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --target)
      [[ $# -ge 2 && -n "$2" ]] || die '--target requires a directory.'
      target="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1. Use --help for usage."
      ;;
    *)
      case "$1" in
        home|tmux|nvim|kitty|alacritty) packages+=("$1") ;;
        *) die "Unknown package: $1. Use --help to list packages." ;;
      esac
      shift
      ;;
  esac
done

case "$(uname -s)" in
  Darwin|Linux) ;;
  *) die 'Supported platforms are macOS and Linux/WSL.' ;;
esac

command -v stow >/dev/null 2>&1 || die 'GNU Stow is required. Install it with your package manager (brew install stow on macOS; apt install stow on Debian/Ubuntu).'
[[ -d "$target" ]] || die "Target directory does not exist: $target"

if [[ ${#packages[@]} -eq 0 ]]; then
  packages=(home tmux nvim)
  for terminal in kitty alacritty; do
    if command -v "$terminal" >/dev/null 2>&1; then
      packages+=("$terminal")
    fi
  done
fi

# Link files individually so ignored files cannot leak through directory links.
stow_args=(--dir="$DOTFILES_DIR" --target="$target" --verbose --no-folding --ignore='\.DS_Store$' --ignore='\.bak$' --ignore='\.orig$')
if [[ "$dry_run" == true ]]; then
  stow_args+=(--simulate)
fi

printf 'Stowing packages: %s\n' "${packages[*]}"
exec stow "${stow_args[@]}" "${packages[@]}"
