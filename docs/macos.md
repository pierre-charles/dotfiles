# macOS setup

For Apple Silicon Macs. `setup.sh` installs everything with Homebrew and Oh My Zsh, and links the configs in this repo into place.

## What gets installed

| What | From | Details |
|------|------|---------|
| CLI tools, languages, shell plugins, fonts | Homebrew | `brew/Brewfile`, listed in [SETUP.md](../SETUP.md#what-gets-installed) |
| Apps: 1Password, Brave, iTerm2, Obsidian, Zed | Homebrew casks | in `brew/Brewfile` |
| Oh My Zsh | its install script | Spaceship and the zsh plugins come from Homebrew instead |
| Config links | this repo | `.zshrc`, `.gitconfig`, Zed, herdr, yazi, btop and Rex. Table in [SETUP.md](../SETUP.md#whats-here) |
| fzf-git.sh | github.com/junegunn/fzf-git.sh | `~/.fzf-git.sh`, loaded by `.zshrc` (the Ctrl+G git shortcuts). Not in Homebrew |
| iTerm2 shell integration | iterm2.com | `~/.iterm2_shell_integration.zsh`, loaded by `.zshrc` (marks each command, enables iTerm features like jumping between prompts) |

## 1. Command line tools

```sh
xcode-select --install
```

This gives you `git`. Wait for the installer window to finish.

## 2. Clone the repo

```sh
git clone https://github.com/pierre-charles/dotfiles.git ~/dotfiles
```

Any folder works. If you fork it, clone your fork instead so you can push your changes.

## 3. Run setup

```sh
bash ~/dotfiles/scripts/setup.sh
```

It shows each step as a checkbox: `[✓]` done, `[–]` already done, `[✗]` failed (with the reason, and the script carries on). A **Summary** at the end lists any problems. It takes a while on a fresh machine.

| Step | What happens | You need to |
|------|--------------|-------------|
| sudo | asks for your password once and keeps it for the whole run | enter your password |
| Homebrew | installs Homebrew, then everything in `brew/Brewfile` | wait, it takes a while (`tail -f` the log to watch) |
| Oh My Zsh | installs it (skipped if it's already there) | — |
| Config links | links `.zshrc`, `.gitconfig`, Zed, herdr, yazi, btop and Rex's `init.lua`, downloads the yazi theme and writes Rex's settings and theme. A real file in the way, like the `.zshrc` Oh My Zsh creates, is kept as `<name>.backup-<date>` | — |
| fzf-git.sh | downloads it if it isn't there | — |
| iTerm2 shell integration | downloads it if it isn't there | — |

Then load the new shell config:

```sh
exec zsh
```

## 4. Git identity

Create `~/.gitconfig.local` with your name and email (`.gitconfig` includes it):

```sh
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

Anything else that's only for this machine goes in `~/.zshrc.local`, see [SETUP.md](../SETUP.md#your-own-settings).

## 5. App settings

- **iTerm2 colours:** Settings → Profiles → Colors → Color Presets → **Import…** → pick `iterm2/catppuccin-macchiato.itermcolors` from the repo, then choose **catppuccin-macchiato** in the same menu.
- **iTerm2 font:** Settings → Profiles → Text → Font → **MesloLGS Nerd Font** (the prompt's icons need it).
- **iTerm2 Alt+C:** Settings → Profiles → Keys → Left Option key → **Esc+**.
- **Rex:** not on Homebrew, download Rex Beta from [superlogical.com/rex](https://www.superlogical.com/rex). `setup.sh` has already written its settings and theme.
- **Zed:** the Homebrew cask installs the `zed` command, which git uses as its editor. If it ever goes missing, run `zed: install cli` from Zed's command palette.

## 6. Sign in

```sh
gh auth login
```

## Check it worked

```sh
ls -l ~/.gitconfig ~/.zshrc ~/.config/zed/settings.json   # all should point into the repo
brew bundle check --file=~dotfiles/brew/Brewfile
```

- [ ] The prompt is Spaceship, and typing shows grey suggestions and coloured commands
- [ ] `git config user.email` shows your email
- [ ] `gh auth status` shows you're signed in

## Troubleshooting

- **A step shows `[✗]`:** the reason is on the same line and the end of its output is under it. The full log path is in the Summary. Fix it and re-run: anything already done is skipped.
- **`brew bundle` stops on one package:** run `brew bundle --file=~dotfiles/brew/Brewfile` to see the full error, fix it (or delete the line), then re-run setup.
- **`Config links` says a folder already exists:** an app made its own `~/.config/<app>` folder first. Move it away (`mv ~/.config/yazi ~/.config/yazi.old`) and re-run.
