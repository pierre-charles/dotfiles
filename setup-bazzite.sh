#!/usr/bin/env bash
# Bazzite (Fedora Atomic) setup: Flatpak apps, KDE config, Steam Big Picture autostart,
# plus the shared setup.sh (Homebrew, Oh My Zsh, config links).
# No `set -e`: a failed step is shown with a red [✗], the rest still runs, and the summary lists failures.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES/lib/output.sh"

need_sudo

# --- rpm-ostree packages ---
# Bazzite is immutable: most things come from Flatpak or Homebrew. Only layer what must be system-level.
section "System packages (rpm-ostree)"
RPM_PACKAGES=(zsh)
missing=()
for pkg in "${RPM_PACKAGES[@]}"; do
    if rpm -q "$pkg" &> /dev/null; then skip "$pkg (already installed)"; else missing+=("$pkg"); fi
done
if [ ${#missing[@]} -gt 0 ]; then
    run "Layering ${missing[*]} (needs a reboot to take effect)" sudo rpm-ostree install -y --allow-inactive "${missing[@]}"
fi

# --- Shell ---
section "Shell"
if [ "$(basename "$SHELL")" = zsh ]; then
    skip "zsh is already your login shell"
else
    run "Setting zsh as your login shell (after you log out)" sudo chsh -s /usr/bin/zsh "$USER"
fi

# --- Shared setup: Homebrew, Oh My Zsh, config links ---
source "$DOTFILES/setup.sh"

# --- Flatpak apps ---
section "Flatpak apps"
# Bazzite comes with Flathub pre-configured. Each entry is "Name|App ID"
FLATPAKS=(
    "Obsidian|md.obsidian.Obsidian"
    "Brave|com.brave.Browser"
    "1Password|com.onepassword.OnePassword"
)
# Optional: install from Flathub after setup if needed
#   flatpak install flathub com.heroicgameslauncher.hgl   # Heroic Launcher (Epic/GOG/Amazon games, Lutris is pre-installed)
#   flatpak install flathub net.davidotek.pupgui2         # ProtonUp-Qt (manage Proton-GE versions)
#   flatpak install flathub com.github.tchx84.Flatseal    # Flatseal (edit Flatpak permissions)

for entry in "${FLATPAKS[@]}"; do
    name="${entry%%|*}" appid="${entry#*|}"
    if flatpak info "$appid" &> /dev/null 2>&1; then
        skip "$name (already installed)"
    else
        run "Installing $name" flatpak install -y flathub "$appid"
    fi
done

# Zed: their install script puts it in ~/.local/zed.app (same as Ubuntu)
if [ -d "$HOME/.local/zed.app" ]; then
    skip "Zed (already installed, updates itself)"
else
    run "Installing Zed" bash -c 'set -o pipefail; curl -fsS https://zed.dev/install.sh | sh'
fi

# --- Steam Big Picture autostart ---
section "Steam Big Picture (console mode)"

AUTOSTART_DIR="$HOME/.config/autostart"
STEAM_DESKTOP="$AUTOSTART_DIR/steam-bpm.desktop"

if [ -f "$STEAM_DESKTOP" ]; then
    skip "Steam BPM autostart (already set up)"
else
    mkdir -p "$AUTOSTART_DIR"
    cat > "$STEAM_DESKTOP" << 'EOF'
[Desktop Entry]
Type=Application
Name=Steam Big Picture
Exec=steam -bigpicture
X-KDE-autostart-after=panel
EOF
    ok "Created Steam BPM autostart (~/.config/autostart/steam-bpm.desktop)"
fi

# --- KDE Plasma config ---
section "KDE Plasma"

# Only apply defaults if kwriteconfig6 exists (it's the KDE config tool on Plasma 6)
if ! command -v kwriteconfig6 &> /dev/null; then
    skip "KDE config (kwriteconfig6 not found, not a KDE session)"
else
    # Dark theme (Breeze Dark)
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme "BreezeDark"
    kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"
    ok "Set dark theme (Breeze Dark)"

    # Task switcher: show only current desktop
    kwriteconfig6 --file kwinrc --group TabBox --key OnlyCurrentDesktopClients true
    ok "Task switcher shows only current desktop"

    # Disable screen locking (this is a gaming PC)
    kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
    ok "Disabled automatic screen lock"

    # Disable power management suspend
    kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime 0
    kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0
    ok "Disabled auto-suspend"

    echo "  ${dim}Run 'qdbus org.kde.KWin /KWin reconfigure' or log out to apply${reset}"
fi

summary "reboot (rpm-ostree changes need it), then follow docs/bazzite.md"
