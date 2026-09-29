# .config

Personal dotfiles for zsh, tmux, gh, git and Claude Code. Zed config lives in its own public repo ([zed-config](https://github.com/jnxspwdr/zed-config)) and is cloned into `zed/` by the installer.
Built for Arch on WSL2; everything lives in `~/.config` and `install.sh` symlinks it into place.

## Setup (Arch on WSL2)

1. **Packages**
   ```sh
   sudo pacman -Syu --needed git zsh tmux curl unzip base-devel bat glab github-cli
   ```
   Optional: `nvm` and `bun` (both are picked up by `.zshrc` if present).

2. **Clipboard helper** (tmux copy/paste binds call `~/.local/bin/win32yank.exe`)
   ```sh
   mkdir -p ~/.local/bin && cd /tmp
   curl -fsSLO https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
   unzip -o win32yank-x64.zip win32yank.exe -d ~/.local/bin && chmod +x ~/.local/bin/win32yank.exe
   ```

3. **Clone and install**
   ```sh
   git clone https://github.com/jnxspwdr/.config.git ~/.config
   ~/.config/install.sh
   ```
   If `~/.config` already exists, clone in place instead:
   ```sh
   cd ~/.config && git init -b main
   git remote add origin https://github.com/jnxspwdr/.config.git
   git fetch origin && git checkout -f main   # overwrites same-named tracked files only
   ./install.sh
   ```

4. **Zed config** (separate public repo, [zed-config](https://github.com/jnxspwdr/zed-config)): `install.sh` already cloned it into `zed/`. Skip if you don't use Zed in WSL.

5. **Shell:** `chsh -s "$(command -v zsh)"`, then open a new terminal. Install a Nerd Font (GeistMono Nerd Font) on Windows and select it in your terminal so the prompt icons render.

6. **GitLab** (see [GitLab](#gitlab-work-laptop)): `glab auth login`, then set your git identity:
   ```sh
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

7. **WezTerm** (Windows): see [WezTerm](#wezterm-windows). Copy `wezterm/wezterm.lua` to `%USERPROFILE%\.config\wezterm\`.

8. **Claude Code** (optional; check your employer's policy first): install it, then caveman (`bun i -g @caveman-ai/cli` and its setup). Without caveman, remove its hooks from `claude/settings.json` and the `claude="caveman claude"` alias in `.zshrc`. If your username isn't `jnx`, fix the `/home/jnx/...` paths in `claude/settings.json` and `claude/statusline-command.sh`.

9. **Verify:** new terminal shows the prompt and starts tmux; `ls -l ~/.zshrc ~/.tmux.conf ~/.claude/settings.json` shows symlinks into `~/.config`; Ctrl+Insert / Shift+Insert copy and paste in tmux; `glab auth status` passes.

Update later with `git -C ~/.config pull && ~/.config/install.sh`. To push changes back, use a GitHub token scoped to this repo only.

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
| `.zshrc`, `.p10k.zsh` | zsh + oh-my-zsh + powerlevel10k; aliases, PATH (nvm, bun) |
| `.tmux.conf` | tmux; auto-starts from zsh (`ZSH_TMUX_AUTOSTART`) |
| `zed/` | Separate `zed-config` repo, cloned by the installer (git-ignored here) |
| `wezterm/` | WezTerm config (Windows side; see below). Background image not tracked |
| `claude/` | Claude Code settings + statusline |
| `gh/`, `git/` | gh CLI config (no tokens), global git ignore |

## WezTerm (Windows)

WezTerm runs on Windows and reads `%USERPROFILE%\.config\wezterm\`. From WSL, copy or link it across (replace `<you>`):

```sh
ln -s ~/.config/wezterm/wezterm.lua /mnt/c/Users/<you>/.config/wezterm/wezterm.lua  # may need Developer Mode; else cp
```

`wezterm.lua` sets `default_domain = 'WSL:archlinux'`; change it to your distro name (`wsl -l`). An optional `background.png` beside it is picked up automatically and is not tracked here.

## GitLab (work laptop)

Nothing here is GitHub-specific except `gh/`, which is inert without `gh`. Git itself uses your own `~/.gitconfig` (not tracked), so glab's credential helper won't conflict.

```sh
glab auth login                       # self-managed: add --hostname gitlab.example.com
glab auth status
```

`glab auth login` configures git's HTTPS credential helper for that host, so `git clone`/`push` to GitLab just work. `.zshrc` loads glab zsh completions when `glab` is installed. glab stores its token in `~/.config/glab-cli/`, which is git-ignored; never commit it.

## Notes

- **Not on WSL?** The `.tmux.conf` clipboard binds call `win32yank.exe`; replace them with `xclip`/`pbcopy` or delete those three lines.
- **Optional tools** (each guarded in `.zshrc`, so missing ones only skip that part): `nvm`, `bun`, `bat`, `zed`, `glab`.
- Machine-local Claude overrides go in `.claude/settings.local.json` (git-ignored).
