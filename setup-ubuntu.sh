#!/usr/bin/env bash
# Ubuntu setup: apt packages, apps and GNOME extensions, plus the shared setup.sh.
# Run from a terminal inside your GNOME session (extensions install through GNOME Shell).
# No `set -e`: a failed step is shown with a red [✗], the rest still runs, and the summary lists failures.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/output.sh"

apt_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"; }

need_sudo

# --- apt ---
section "apt packages"
APT_PACKAGES=(build-essential procps curl wget file git zsh gnome-tweaks gnome-shell-extension-manager)
missing=()
for pkg in "${APT_PACKAGES[@]}"; do
    if apt_installed "$pkg"; then skip "$pkg (already installed)"; else missing+=("$pkg"); fi
done
if [ ${#missing[@]} -gt 0 ]; then
    run "Updating package lists" sudo apt-get update \
        && run "Installing ${missing[*]}" sudo apt-get install -y "${missing[@]}"
fi

# --- Shell ---
# Use apt's zsh: Homebrew's may come first in PATH but isn't in /etc/shells
section "Shell"
if [ "$(basename "$SHELL")" = zsh ]; then
    skip "zsh is already your login shell"
else
    run "Setting zsh as your login shell (after you log out)" sudo chsh -s /usr/bin/zsh "$USER"
fi

# --- Shared setup: Homebrew, Oh My Zsh, config links (adds to the same summary) ---
source "$DOTFILES/setup.sh"

# --- Apps whose Homebrew casks are macOS-only ---
section "Apps"

if snap list obsidian &> /dev/null; then
    skip "Obsidian (already installed)"
else
    run "Installing Obsidian (Snap)" sudo snap install obsidian --classic
fi

# Brave's own script adds its apt repo, then installs it
if command -v brave-browser &> /dev/null; then
    skip "Brave (already installed)"
else
    run "Installing Brave" bash -c 'set -o pipefail; curl -fsS https://dl.brave.com/install.sh | sh'
fi

# Zed's script installs to ~/.local/zed.app (on PATH via .zshrc). Zed updates itself afterwards
if [ -d "$HOME/.local/zed.app" ]; then
    skip "Zed (already installed, updates itself)"
else
    run "Installing Zed" bash -c 'set -o pipefail; curl -fsS https://zed.dev/install.sh | sh'
fi

# 1Password's own apt repo (amd64 only), as in its Linux install docs
add_1password_repo() (
    set -o pipefail  # set -e is ignored inside run's `if`, so each step is chained with &&
    curl -fsS https://downloads.1password.com/linux/keys/1password.asc \
        | sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" \
        | sudo tee /etc/apt/sources.list.d/1password.list \
    && sudo apt-get update
)
if apt_installed 1password; then
    skip "1Password (already installed)"
else
    { [ -f /etc/apt/sources.list.d/1password.list ] || run "Adding 1Password's apt repo" add_1password_repo; } \
        && run "Installing 1Password" sudo apt-get install -y 1password
fi

# --- GNOME extensions ---
section "GNOME extensions"
echo "  New ones open a GNOME dialog: click Install (you have 5 minutes each)."

# Name|UUID. Sound Output Device Chooser is left out: it only supports GNOME <= 43, newer GNOME has it built in
EXTENSIONS=(
    "Applications Menu|apps-menu@gnome-shell-extensions.gcampax.github.com"
    "Extension List|extension-list@tu.berry"
    "User Themes|user-theme@gnome-shell-extensions.gcampax.github.com"
    "Places Status Indicator|places-menu@gnome-shell-extensions.gcampax.github.com"
    "Dash to Dock|dash-to-dock@micxgx.gmail.com"
    "Blur my Shell|blur-my-shell@aunetx"
    "Vitals|Vitals@CoreCoding.com"
    "Caffeine|caffeine@patapon.info"
    "Clipboard Indicator|clipboard-indicator@tudmotu.com"
    "Removable Drive Menu|drive-menu@gnome-shell-extensions.gcampax.github.com"
    "gTile|gTile@vibou"
    "Status Area Horizontal Spacing|status-area-horizontal-spacing@mathematical.coffee.gmail.com"
)

install_extensions() {
    local installed entry name uuid result
    if ! installed="$(gnome-extensions list 2>&1)"; then
        fail "GNOME extensions" "couldn't reach GNOME Shell ($installed). Run this from a terminal in your GNOME desktop"
        return
    fi
    for entry in "${EXTENSIONS[@]}"; do
        name="${entry%%|*}" uuid="${entry#*|}"
        if grep -qx "$uuid" <<< "$installed"; then
            if gnome-extensions enable "$uuid" 2>> "$LOG"; then
                skip "$name (already installed, enabled)"
            else
                fail "$name" "installed but couldn't be enabled"
            fi
            continue
        fi
        pending "$name (waiting for you to click Install)"
        result="$(gdbus call --session --timeout 300 --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension "$uuid" 2>&1)" || true
        clear_line
        if [[ $result == *successful* ]]; then
            ok "$name"
        else
            fail "$name" "$result"
        fi
    done
}
install_extensions

summary "log out and back in, then follow 'After setup' in docs/ubuntu.md"
