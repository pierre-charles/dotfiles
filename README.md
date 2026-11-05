# dotfiles

My shell, git and editor config, plus setup scripts that turn a fresh macOS, Ubuntu or Bazzite machine into the same zsh + Homebrew environment. Catppuccin Mocha everywhere.

Use them as they are, or fork the repo and change things to suit you (start with `brew/Brewfile` and `zsh/.zshrc`).

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
| git | `git`, `gh`, `git-secrets` |
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

**`~/.zshrc.local`** (sourced at the end of `.zshrc`). Use it for work aliases, extra `PATH` entries and tokens:

```sh
export NPM_TOKEN=...
alias work="cd ~/Projects/work"
```

## Day to day

```sh
~dotfiles                # named directory: goes to the repo
git pull                 # get changes made on another machine
bash setup.sh            # or setup-ubuntu.sh / setup-bazzite.sh: picks up new packages and links
```

To add a package, add a line to `brew/Brewfile`. A cask that only exists on macOS needs `if OS.mac?` after it, or it stops `setup.sh` on Linux.

**Colours:** Catppuccin Mocha everywhere: Zed, yazi, fzf, bat (and through it delta), eza, lazygit, btop, and herdr (its `catppuccin` theme). iTerm2 is the one to set by hand, see [docs/macos.md](docs/macos.md#5-app-settings).

## Shell shortcuts

What `zsh/.zshrc` and `git/.gitconfig` set up:

| Type | Does |
|------|------|
| `ll`, `la`, `l` | list files with `eza` (`ll`: everything, sizes, git status). `ls` stays plain `ls` |
| `cat` | `bat`: syntax highlighting and line numbers |
| Tab | completions as a searchable fzf list (fzf-tab), with a folder preview for `cd` |
| Ctrl+R | search command history with fzf |
| Ctrl+T | pick a file and paste its path, with a `bat` preview |
| Alt+C | jump to a folder below. In iTerm this needs **Profiles → Keys → Left Option key: Esc+** |
| `y` | yazi file manager. `q` quits into the folder you were in, `z` fuzzy-jumps, Enter opens text files in Zed |
| `lg` | lazygit |
| `mkcd <dir>` | make a folder and `cd` into it |
| `reload` | start a fresh shell after editing `.zshrc` |
| `~projects`, `~dotfiles`, `~worktrees` | named directories: `~dotfiles` on its own goes there, and they work in any path |
| `git diff`, `git show` | shown through `delta`: changed words highlighted, `n` / `N` jump between files |
| `git lg` | compact graph log. Also `git st`, `co`, `br`, `cm`, `df`, `unstage`, `last` |
| `git-remove-gone-branches` | delete local branches whose remote branch is gone (after the PR merged) |
| `worktree-create [base]` | ask for a branch and folder name, create a worktree in `~/Projects/worktrees/<repo>/` and `cd` into it |
| `worktree-init` | inside a new worktree: link `.env.local` from the main one and install dependencies |
| `worktree-clean` | remove worktrees whose branch is merged (checks GitHub PRs for squash merges), after asking |
| `dev [port]` | Next.js dev server on the first free port from 3000 |
| `serve [port]` | static file server for the current folder (Deno), port 8000 |
| `tldr <command>` | short examples, e.g. `tldr tar` |

### yazi keys

Start it with `y`, press `~` inside for the full list.

| Key | Does |
|-----|------|
| `a` | new file. End the name with `/` for a folder (`photos/`) |
| `r` | rename. With several selected, opens all the names in an editor to rename in one go |
| `d` / `D` | move to Trash / delete for good (asks first) |
| `y` / `x` / `p` | copy / cut / paste. `P` pastes over files with the same name |
| `Space` / `v` / `Ctrl+a` | select one and move down / select a range / select all. `Esc` clears |
| Enter or `o` | open: text files in Zed, others in their usual app. `O` lists every way to open it |
| `z` / `/` / `s` / `S` | fuzzy-jump below (fzf) / find in this folder / search names below (fd) / search inside files (ripgrep) |
| `c` `c` | copy the full path |
| `;` | run a shell command on the selected files |
| `t` | new tab |
| `.` | show or hide hidden files |
| `q` | quit into the folder you were in |

## Credits

- [Catppuccin](https://github.com/catppuccin) for the themes (iTerm2, btop, yazi, fzf colours)
- [Oh My Zsh](https://ohmyz.sh), [Spaceship](https://spaceship-prompt.sh), [fzf-tab](https://github.com/Aloxaf/fzf-tab)

## License

[MIT](LICENSE)
