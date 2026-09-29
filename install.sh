#!/usr/bin/env bash
# Symlinks this repo's dotfiles into place. Safe to re-run: skips paths
# already correctly linked, backs up anything else to *.bak.<timestamp>.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"

if [ "$REPO_DIR" != "$HOME/.config" ]; then
  echo "error: this repo must be cloned to \$HOME/.config (found at $REPO_DIR)" >&2
  exit 1
fi

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$(dirname "$dst")"
    mv "$dst" "$dst.bak.$TS"
    echo "backed up existing $dst -> $dst.bak.$TS"
  else
    mkdir -p "$(dirname "$dst")"
  fi
  ln -s "$src" "$dst"
  echo "linked  $dst -> $src"
}

# shell / tmux / prompt dotfiles at $HOME root
link "$REPO_DIR/.zshrc"     "$HOME/.zshrc"
link "$REPO_DIR/.p10k.zsh"  "$HOME/.p10k.zsh"
link "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/.tmux"      "$HOME/.tmux"

# clone <url> <dir>: clone if <dir> isn't already a git checkout.
clone() {
  if [ -d "$2/.git" ]; then
    echo "ok      $2 (already present)"
  else
    git clone --depth 1 "$1" "$2"
  fi
}

# oh-my-zsh + powerlevel10k + zsh-autosuggestions (what .zshrc expects).
# Cloned directly: the oh-my-zsh installer would overwrite ~/.zshrc.
ZSH_DIR="$HOME/.oh-my-zsh"
clone https://github.com/ohmyzsh/ohmyzsh "$ZSH_DIR"
clone https://github.com/romkatv/powerlevel10k "$ZSH_DIR/custom/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_DIR/custom/plugins/zsh-autosuggestions"

# tmux plugin manager (tracked as an empty gitlink, so a plain clone of this
# repo leaves the dir empty; clone tpm into it, then install the plugins)
TPM_DIR="$REPO_DIR/.tmux/plugins/tpm"
clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
if command -v tmux >/dev/null 2>&1; then
  "$TPM_DIR/bin/install_plugins" || echo "warn    tpm plugin install failed; press prefix + I inside tmux" >&2
else
  echo "warn    tmux not installed; install it, then press prefix + I to fetch plugins" >&2
fi

# Zed config lives in its own repo; Zed reads it from ~/.config/zed.
# Skip (don't clobber) if a non-git zed dir is already there.
ZED_DIR="$REPO_DIR/zed"
if [ -d "$ZED_DIR/.git" ]; then
  echo "ok      $ZED_DIR (already present)"
elif [ -e "$ZED_DIR" ]; then
  echo "warn    $ZED_DIR exists but isn't a git checkout; move it and re-run to clone zed-config" >&2
else
  git clone https://github.com/jnxspwdr/zed-config "$ZED_DIR" || echo "warn    could not clone zed-config (auth?); clone it to $ZED_DIR manually" >&2
fi

# Claude Code settings + statusline live in the repo, symlinked back
# into ~/.claude so Claude Code finds them at its expected path.
link "$REPO_DIR/claude/settings.json"         "$HOME/.claude/settings.json"
link "$REPO_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
chmod +x "$HOME/.claude/statusline-command.sh"

echo "done."
