# Ubuntu setup

For Ubuntu with GNOME. `setup-ubuntu.sh` installs system packages with apt, runs the shared `setup.sh` (Homebrew, Oh My Zsh, config links), then installs the apps and GNOME extensions.

## What gets installed

| What | From | Details |
|------|------|---------|
| `build-essential`, `procps`, `curl`, `wget`, `file`, `git`, `zsh` | apt | build tools Homebrew needs, and zsh as the login shell |
| GNOME Tweaks, Extension Manager | apt | see [GNOME](#gnome) |
| CLI tools, languages, shell plugins | Homebrew | `brew/Brewfile`, listed in [SETUP.md](../SETUP.md#what-gets-installed). The macOS-only apps are skipped |
| Oh My Zsh, config links | `setup.sh` | same as macOS, see [macos.md](macos.md#what-gets-installed) |
| Obsidian | Snap | |
| Brave | Brave's install script (adds its apt repo) | |
| Zed | Zed's install script | in `~/.local/zed.app`, updates itself |
| 1Password | 1Password's apt repo | amd64 only |
| 12 GNOME extensions | extensions.gnome.org | listed in [Extensions](#extensions) |

Don't want some of the apps or extensions? Delete them from `setup-ubuntu.sh` before running it.

## 1. git and the repo

```sh
sudo apt update && sudo apt install -y git
git clone https://github.com/pierre-charles/dotfiles.git ~/dotfiles
```

## 2. Run setup

Open a terminal **inside your GNOME desktop** (not over SSH: the extension step talks to GNOME Shell):

```sh
bash ~/dotfiles/setup-ubuntu.sh
```

It asks for your password once at the start, then shows each step as a checkbox: `[ ]` running, `[✓]` done, `[–]` already done, `[✗]` failed. Install output goes to a log file (its path is printed at the end). If a step fails, you get a red `[✗]` with the reason and the last lines of its output, and the script carries on with everything that doesn't depend on it. The **Summary** at the end lists every problem again.

| Step | What happens | You need to |
|------|--------------|-------------|
| sudo | asks for your password once and keeps it for the whole run | enter your password |
| apt packages | build tools, `curl`, `wget`, `git`, `zsh`, GNOME Tweaks, Extension Manager | — |
| Shell | switches your login shell to zsh (skipped if it already is) | — |
| `setup.sh` steps | Homebrew + Brewfile, Oh My Zsh, config links | wait, Homebrew takes a while (`tail -f` the log to watch) |
| Apps | Obsidian (Snap), Brave and Zed (their install scripts), 1Password (its own apt repo) | — |
| GNOME extensions | a GNOME dialog pops up for each one not yet installed | click **Install** each time (within 5 minutes) |

When it's done, **log out and back in** so zsh becomes your shell.

## 3. After setup

```sh
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
gh auth login
```

Machine-specific shell config goes in `~/.zshrc.local`, see [SETUP.md](../SETUP.md#your-own-settings).

## Check it worked

```sh
echo $SHELL                                     # /usr/bin/zsh
ls -l ~/.gitconfig ~/.zshrc                     # both should point into the repo
brew bundle check --file=~dotfiles/brew/Brewfile
gnome-extensions list --enabled                 # the extensions from the table below
```

- [ ] The prompt is Spaceship, and typing shows grey suggestions and coloured commands
- [ ] Obsidian, Brave, Zed and 1Password open from Activities

## GNOME

Apps (search for them in Activities, the Super key):

- **Tweaks:** fonts, title bar buttons, startup apps, keyboard
- **Extension Manager** (green puzzle piece): turn extensions on/off, open their settings, browse and install new ones. Not to be confused with **Extensions** (blue), the simpler built-in app

### Extensions

The script installs and turns on all of these except Sound Output Device Chooser:

| Extension | What for |
|-----------|----------|
| [Applications Menu](https://extensions.gnome.org/extension/6/applications-menu/) | GNOME 2-style apps menu in the top bar |
| [Extension List](https://extensions.gnome.org/extension/3088/extension-list/) | Turn extensions on/off from the top bar |
| [User Themes](https://extensions.gnome.org/extension/19/user-themes/) | Load shell themes from `~/.themes` |
| [Places Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/) | Menu of common folders and drives |
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/) | Turn the dash into a dock |
| [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/) | Blur the overview, top bar and dash |
| [Vitals](https://extensions.gnome.org/extension/1460/vitals/) | CPU, memory, temperature and network in the top bar |
| [Caffeine](https://extensions.gnome.org/extension/517/caffeine/) | Stop the screen locking or the machine sleeping |
| [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/) | Clipboard history |
| [Removable Drive Menu](https://extensions.gnome.org/extension/7/removable-drive-menu/) | Mount and eject USB drives from the top bar |
| [gTile](https://extensions.gnome.org/extension/28/gtile/) | Tile windows on a grid |
| [Status Area Horizontal Spacing](https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/) | Less spacing between top bar icons |
| [Sound Output Device Chooser](https://extensions.gnome.org/extension/906/sound-output-device-chooser/) | Not installed: only supports GNOME 43 and older, newer GNOME has it built in |

Ubuntu's own extensions can clash with these:

```sh
gnome-extensions disable ubuntu-dock@ubuntu.com           # if you see two docks
gnome-extensions disable tiling-assistant@ubuntu.com      # if window snapping fights gTile
```

Adding or removing an extension for future machines: edit the `EXTENSIONS` list in `setup-ubuntu.sh` (each entry is `Name|UUID`; the UUID is shown on the extension's page and in `gnome-extensions list`) and the table above. The script never uninstalls anything; remove one from this machine with `gnome-extensions uninstall <uuid>`.

### Back up extension settings

Not automated yet. To carry extension settings to another machine:

```sh
dconf dump /org/gnome/shell/extensions/ > gnome-extensions.dconf   # on the old machine
dconf load /org/gnome/shell/extensions/ < gnome-extensions.dconf   # on the new one
```

## Troubleshooting

- **A step shows `[✗]`:** the reason is on the same line and the end of its output is under it; the full log path is in the Summary. Fix it and re-run.
- **`[✗] <extension>: ...`:** the message after it is GNOME's error. Cancelled dialogs show up here too. Re-run the script, or install it from Extension Manager.
- **`brew bundle` fails on a cask:** most casks are macOS-only. Mark it `if OS.mac?` in `brew/Brewfile` and install the Linux version in `setup-ubuntu.sh`, like Obsidian, Brave and 1Password.
