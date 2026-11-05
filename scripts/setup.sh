#!/usr/bin/env bash
# Shared setup (macOS and Linux): Homebrew, Oh My Zsh, config links.
# No `set -e`: a failed step is shown with a red [✗], the rest still runs, and the summary lists failures.

# The repo is the folder above this script, so it can be cloned anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES/brew/Brewfile"

source "$DOTFILES/scripts/lib/output.sh"

need_sudo

# --- Homebrew ---
section "Homebrew"

install_homebrew() (
    local script
    script="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
    NONINTERACTIVE=1 /bin/bash -c "$script"
)

if command -v brew &> /dev/null; then
    skip "Homebrew (already installed)"
elif run "Installing Homebrew" install_homebrew; then
    # Add brew to PATH for the rest of this script
    if [ "$(uname -s)" = "Darwin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

if command -v brew &> /dev/null; then
    if brew bundle check --file="$BREWFILE" &> /dev/null; then
        skip "${BREWFILE#$DOTFILES/} packages (all installed)"
    else
        echo "  Watch progress in another terminal: tail -f $LOG"
        run "Installing ${BREWFILE#$DOTFILES/} packages (can take a while)" brew bundle --file="$BREWFILE"
    fi
else
    fail "Brewfile packages" "skipped, Homebrew isn't installed"
fi

# --- Oh My Zsh ---
section "Oh My Zsh"

install_oh_my_zsh() (
    local script
    script="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || exit 1
    RUNZSH=no CHSH=no sh -c "$script"
)

if [ -d "$HOME/.oh-my-zsh" ]; then
    skip "Oh My Zsh (already installed)"
else
    run "Installing Oh My Zsh" install_oh_my_zsh
fi

# --- Symlinks ---
section "Config links"

symlink "$DOTFILES/zsh/.zshrc"                 "$HOME/.zshrc"
symlink "$DOTFILES/git/.gitconfig"             "$HOME/.gitconfig"
symlink "$DOTFILES/zed/settings.json"          "$HOME/.config/zed/settings.json"
symlink "$DOTFILES/zed/keymap.json"            "$HOME/.config/zed/keymap.json"
symlink "$DOTFILES/herdr/config.toml"          "$HOME/.config/herdr/config.toml"
symlink "$DOTFILES/yazi"                       "$HOME/.config/yazi"
symlink "$DOTFILES/btop"                       "$HOME/.config/btop"

# yazi themes are downloaded, not kept in git: install the ones listed in yazi/package.toml
command -v ya &> /dev/null && run "Installing yazi themes" ya pkg install

# --- iTerm2 shell integration (macOS): .zshrc sources it when it's there ---
# Downloaded directly: iTerm's installer would also append a line to .zshrc, which is linked to this repo
if [ "$(uname -s)" = "Darwin" ]; then
    section "iTerm2 shell integration"
    if [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
        skip "~/.iterm2_shell_integration.zsh (already installed)"
    else
        run "Downloading iTerm2 shell integration" \
            curl -fsSL https://iterm2.com/shell_integration/zsh -o "$HOME/.iterm2_shell_integration.zsh"
    fi
fi

# Run directly (macOS): print the summary. Sourced by setup-ubuntu.sh and setup-bazzite.sh: it prints one at the end
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    summary "carry on from step 5 in docs/macos.md"
fi
