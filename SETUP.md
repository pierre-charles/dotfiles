# Setup

How to put these dotfiles on a machine. For what they are and why, see the [README](README.md).

## Quick start

```sh
git clone https://github.com/pierre-charles/dotfiles-public.git ~/dotfiles
bash ~/dotfiles/setup.sh            # macOS
bash ~/dotfiles/setup-ubuntu.sh     # Ubuntu (GNOME)
bash ~/dotfiles/setup-bazzite.sh    # Bazzite (KDE)
```

You can clone it anywhere: the scripts and `.zshrc` find the repo from their own location. Then add your git name and email (see [Your own settings](#your-own-settings)).

> [!WARNING]
> Setup **links** your `~/.zshrc`, `~/.gitconfig` and some `~/.config` folders to this repo. Files already there are kept as `<name>.backup-<date>`, but read what it does first.

| Machine | Guide | Script |
|---------|-------|--------|
| macOS (Apple Silicon) | [docs/macos.md](docs/macos.md) | `setup.sh` |
| Ubuntu with GNOME | [docs/ubuntu.md](docs/ubuntu.md) | `setup-ubuntu.sh` (runs `setup.sh` too) |
| Bazzite with KDE | [docs/bazzite.md](docs/bazzite.md) | `setup-bazzite.sh` (runs `setup.sh` too) |

All the scripts are safe to re-run: anything already installed or linked is skipped. They show each step as a checkbox (`[✓]` done, `[–]` already done, `[✗]` failed) and carry on past failures. A summary at the end lists any problems. The helpers are in `lib/output.sh`.

## What gets installed

`setup.sh` installs `brew/Brewfile` with Homebrew (on Linux too). Each guide has a table of what its own script adds.

| Group | Packages |
|-------|----------|
| Shell | `zsh`, `spaceship` (prompt), `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab` |
| CLI tools | `bat`, `btop`, `eza`, `fd`, `fzf`, `jq`, `ripgrep`, `tree`, `wget`, `gum`, `lazygit`, `yazi`, `git-delta`, `tlrc` (`tldr`), `poppler` |
| git | `git`, `gh` |
| Languages | `node`, `fnm`, `deno`, `python@3.14`, `pyenv`, `openjdk@21`, `gcc`, plus `corepack` from npm |
| Containers | `docker`, `docker-compose` |
| Media | `ffmpeg`, `yt-dlp` |
| Other | `herdr` |
| Fonts | Geist, MesloLG Nerd Font |
| Apps (macOS only) | 1Password, Brave, iTerm2, Obsidian, Zed. The Linux scripts install these their own way |

## What's here

| Path | Goes to | How |
|------|---------|-----|
| `brew/Brewfile` | — | installed by `setup.sh` |
| `zsh/.zshrc` | `~/.zshrc` | link |
| `git/.gitconfig` | `~/.gitconfig` | link |
| `zed/settings.json`, `zed/keymap.json` | `~/.config/zed/` | link |
| `herdr/config.toml` | `~/.config/herdr/config.toml` | link |
| `yazi/` | `~/.config/yazi` | link (themes listed in `package.toml`, downloaded by `setup.sh`) |
| `btop/` | `~/.config/btop` | link (Catppuccin theme in `themes/`) |
| `lazygit/config.yml` | — | read through `LG_CONFIG_FILE` in `.zshrc` |
| `eza/theme.yml` | — | read through `EZA_CONFIG_DIR` in `.zshrc` |
| `iterm2/*.itermcolors` | — | Catppuccin colour presets to import into iTerm2 (macOS) |

Linked files are the repo copy, so editing them on the machine edits the repo.

## Your own settings

Two files that aren't in the repo hold anything personal or machine-specific. Create them yourself:

**`~/.gitconfig.local`** (included by `.gitconfig`). Git needs it before you can commit:

```ini
[user]
	name = Your Name
	email = you@example.com
```

**`~/.zshrc.local`** (sourced at the end of `.zshrc`). Use it for work aliases, extra `PATH` entries and tokens.

## Day to day

```sh
~dotfiles                # named directory: goes to the repo
git pull                 # get changes made on another machine
bash setup.sh            # or setup-ubuntu.sh / setup-bazzite.sh: picks up new packages and links
```

To add a package, add a line to `brew/Brewfile`. A cask that only exists on macOS needs `if OS.mac?` after it, or it stops `setup.sh` on Linux.

**Colours:** Catppuccin Mocha everywhere: Zed, yazi, fzf, bat (and through it delta), eza, lazygit, btop, and herdr (its `catppuccin` theme). iTerm2 is the one to set by hand, see [docs/macos.md](docs/macos.md#5-app-settings).

For the shortcuts you get once it's done, see [Shell shortcuts](README.md#shell-shortcuts) in the README.
