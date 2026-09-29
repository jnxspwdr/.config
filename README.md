# .config

Personal dotfiles for zsh, tmux, gh, git and Claude Code. Zed config lives in its own repo ([zed-config](https://github.com/jnxspwdr/zed-config)) and is cloned into `zed/` by the installer.
Built for WSL2/Linux; everything lives in `~/.config` and `install.sh` symlinks it into place.

## Quick start

Prerequisites: `git`, `zsh`, `tmux`, `curl`. Then:

```sh
git clone https://github.com/jnxspwdr/.config.git ~/.config
~/.config/install.sh
chsh -s "$(command -v zsh)"   # make zsh the login shell, then open a new terminal
```

The GitHub repos are private, so authenticate to GitHub first (`gh auth login`, an SSH key, or a PAT). GitLab (work) auth is separate; see below.

If `~/.config` already exists (usual on a fresh machine), clone in place instead:

```sh
cd ~/.config
git init -b main
git remote add origin https://github.com/jnxspwdr/.config.git
git fetch origin
git checkout -f main   # overwrites same-named tracked files only
~/.config/install.sh
```

## What `install.sh` does

Safe to re-run. Anything already linked is skipped; anything else at the target is moved to `<path>.bak.<timestamp>`.

- Symlinks `.zshrc`, `.p10k.zsh`, `.tmux.conf`, `.tmux` into `$HOME`.
- Symlinks `claude/settings.json` and `claude/statusline-command.sh` into `~/.claude/`.
- Clones oh-my-zsh, powerlevel10k, zsh-autosuggestions into `~/.oh-my-zsh` (the oh-my-zsh installer is not used; it would overwrite `.zshrc`).
- Clones tmux plugin manager (tpm) into `.tmux/plugins/tpm` and installs the tmux plugins.
- Clones [zed-config](https://github.com/jnxspwdr/zed-config) into `zed/` (skipped, with a warning, if `zed/` already exists and isn't a git checkout).
- Requires the repo to live at exactly `$HOME/.config`.

gh (`gh/`) and git (`git/ignore`) are read from `~/.config` directly, so they need no linking. Neovim is no longer used; `nvim/` and `zed/` are git-ignored here.

## Layout

| Path | Purpose |
|---|---|
| `.zshrc`, `.p10k.zsh` | zsh + oh-my-zsh + powerlevel10k; aliases, PATH (nvm, bun, go) |
| `.tmux.conf` | tmux; auto-starts from zsh (`ZSH_TMUX_AUTOSTART`) |
| `zed/` | Separate `zed-config` repo, cloned by the installer (git-ignored here) |
| `claude/` | Claude Code settings + statusline |
| `gh/`, `git/` | gh CLI config (no tokens), global git ignore |

## GitLab (work laptop)

Nothing here is GitHub-specific except `gh/`, which is inert without `gh`. Git itself uses your own `~/.gitconfig` (not tracked), so glab's credential helper won't conflict.

```sh
glab auth login                       # self-managed: add --hostname gitlab.example.com
glab auth status
```

`glab auth login` configures git's HTTPS credential helper for that host, so `git clone`/`push` to GitLab just work. `.zshrc` loads glab zsh completions when `glab` is installed. glab stores its token in `~/.config/glab-cli/`, which is git-ignored; never commit it.

## Work-laptop notes

- **Not on WSL?** `.tmux.conf` clipboard binds call `~/.local/bin/win32yank.exe`. On plain Linux/macOS, replace them with `xclip`/`pbcopy`, or delete those three lines.
- **Claude Code:** `claude/settings.json` hooks call `caveman` under `~/.caveman` and `~/.bun`, and `.zshrc` aliases `claude="caveman claude"`. Install caveman first (`bun i -g @caveman-ai/cli`, then its setup), or remove those hooks and the alias. Its paths are absolute `/home/jnx/...`; if your work username differs, re-run the caveman setup or edit them.
- **Tools `.zshrc` expects** (each is guarded, so missing ones only skip that part): `nvm`, `bun`, `go`, `bat`, `zed`, `glab`.
- Check nothing here conflicts with employer policy (telemetry settings, shell hooks) before syncing to a managed machine.
- Set your git identity: `git config --global user.name ...` and `user.email ...`.
- Machine-local Claude overrides go in `.claude/settings.local.json` (git-ignored).
