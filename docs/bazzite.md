# Bazzite setup

For a gaming PC running [Bazzite](https://bazzite.gg) (Fedora Atomic with gaming built in), on the **Desktop + KDE** image, booting into Steam Big Picture. With an NVIDIA GPU, pick the `bazzite-nvidia` image rather than the Deck one: gamescope has issues with NVIDIA.

`setup-bazzite.sh` layers a few system packages, runs the shared `setup.sh` (Homebrew, Oh My Zsh, config links), then installs the apps and sets up Steam and KDE.

## What gets installed

| What | From | Details |
|------|------|---------|
| `zsh` | rpm-ostree (layered) | the only system-level package. It needs a reboot |
| CLI tools, languages, shell plugins | Homebrew | `brew/Brewfile`, listed in [SETUP.md](../SETUP.md#what-gets-installed). The macOS-only apps are skipped |
| Oh My Zsh, config links | `setup.sh` | same as macOS, see [macos.md](macos.md#what-gets-installed) |
| Obsidian, Brave, 1Password | Flatpak (Flathub) | |
| Zed | Zed's install script | in `~/.local/zed.app`, updates itself |
| Steam autostart | `~/.config/autostart/steam-bpm.desktop` | Steam opens in Big Picture Mode at login |
| KDE settings | `kwriteconfig6` | Breeze Dark, task switcher shows only the current desktop, no screen lock, no auto-suspend |
| Steam, Lutris | already on Bazzite | Lutris is for non-Steam games (Epic, GOG…) |

The KDE settings suit a machine that sits under a TV. Remove that section from `setup-bazzite.sh` if you want screen lock and suspend.

## 1. Install Bazzite

Download the ISO for your hardware from [bazzite.gg](https://bazzite.gg), flash it to a USB stick and install. For dual boot, install Windows first and give Bazzite its own drive or a free partition.

First boot is slow while Bazzite downloads updates and sets up drivers. Then open a terminal (Konsole).

## 2. Clone the repo

```sh
git clone https://github.com/pierre-charles/dotfiles-public.git ~/dotfiles
```

## 3. Run setup

```sh
bash ~/dotfiles/setup-bazzite.sh
```

| Step | What happens | You need to |
|------|--------------|-------------|
| sudo | asks for your password once | enter your password |
| rpm-ostree | layers `zsh` (needs a reboot) | — |
| Shell | switches login shell to zsh | — |
| `setup.sh` steps | Homebrew + Brewfile, Oh My Zsh, config links | wait, Homebrew takes a while |
| Flatpak apps | Obsidian, Brave, 1Password | — |
| Zed | Zed's install script | — |
| Steam BPM | creates an autostart entry for Steam in Big Picture Mode | — |
| KDE Plasma | dark theme, task switcher shows only the current desktop, disables screen lock and auto-suspend | log out, or run `qdbus org.kde.KWin /KWin reconfigure`, to apply |

When it's done, **reboot** (rpm-ostree changes take effect on reboot).

## 4. After setup

```sh
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
gh auth login
```

Then open **Steam** and sign in. It launches in Big Picture Mode on every boot from now on, and is fully controller-navigable.

## Check it worked

```sh
rpm-ostree status                               # zsh under LayeredPackages
echo $SHELL                                     # /usr/bin/zsh
ls -l ~/.gitconfig ~/.zshrc                     # both should point into the repo
brew bundle check --file=~dotfiles/brew/Brewfile
flatpak list --app                              # Obsidian, Brave, 1Password
```

- [ ] The prompt is Spaceship, and typing shows grey suggestions and coloured commands
- [ ] After a reboot, Steam opens in Big Picture Mode

## KDE vs the GNOME setup

| GNOME (Ubuntu) | KDE (Bazzite) |
|----------------|---------------|
| GNOME Tweaks | System Settings |
| Extension Manager + GNOME extensions | KDE widgets (built in, no extensions needed) |
| Dash to Dock extension | Task Manager (the default panel has one) |
| gTile extension | KDE's built-in tiling (System Settings → Window Management → Window Tiling) |
| Caffeine extension | Inhibit sleep in System Settings → Power Management, or the script disables it |
| Clipboard Indicator extension | Klipper (built into the panel by default) |
| Vitals extension | System Monitor widget, or `btop` in the terminal |
| `dconf` for settings | `kwriteconfig6` or edit `~/.config/*.rc` files directly |

KDE has most of what the GNOME extensions give you out of the box.

## Updating Bazzite

Bazzite updates the whole image atomically:

```sh
ujust update   # Bazzite's update command, updates the OS, Flatpaks and firmware
```

If an update breaks something, roll back to the previous image:

```sh
sudo rpm-ostree rollback
```

## Troubleshooting

- **A step shows `[✗]`:** the reason is on the same line. Fix it and re-run.
- **`rpm-ostree install` fails:** you may need to reboot first if there's a pending deployment. Run `rpm-ostree status` to check.
- **Homebrew package fails:** same as macOS/Ubuntu — check the log, some packages need `gcc` or other build deps that may not be layered.
- **Flatpak app can't access files:** open Flatseal, find the app, and add the folder to its filesystem permissions.
- **Steam doesn't launch in BPM:** check `~/.config/autostart/steam-bpm.desktop` exists. Also set it inside Steam: Settings → Interface → "Start Steam in Big Picture Mode".
