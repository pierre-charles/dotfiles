#!/usr/bin/env bash
# Shared setup (macOS and Linux): Homebrew, Oh My Zsh, config links, git-secrets.
# No `set -e`: a failed step is shown with a red [✗], the rest still runs, and the summary lists failures.

# The repo is wherever this script is, so it can be cloned anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES/brew/Brewfile"

source "$DOTFILES/lib/output.sh"

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

symlink() {
    local src="$1" dst="$2" out
    local name="${dst/#$HOME/~}"

    if [ ! -e "$src" ]; then
        skip "$name (${src/#$HOME/~} isn't in the repo)"
    elif [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        skip "$name (already linked)"
    elif [ -d "$dst" ] && [ ! -L "$dst" ]; then
        # ln would put the link inside the folder instead of replacing it
        fail "$name" "already exists as a folder. Move it out of the way and re-run"
    elif [ -f "$dst" ] && [ ! -L "$dst" ]; then
        # A real file is in the way (e.g. the .zshrc Oh My Zsh creates): keep it, don't overwrite it
        local backup; backup="$dst.backup-$(date +%Y%m%d-%H%M%S)"
        if out="$(mv "$dst" "$backup" 2>&1 && ln -s "$src" "$dst" 2>&1)"; then
            ok "Linked $name (the file that was there is now ${backup/#$HOME/~})"
        else
            fail "Linking $name" "$out"
        fi
    elif out="$(mkdir -p "$(dirname "$dst")" 2>&1 && ln -sf "$src" "$dst" 2>&1)"; then
        ok "Linked $name"
    else
        fail "Linking $name" "$out"
    fi
}

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

# --- git-secrets hooks (copied into new repos by init.templateDir in .gitconfig) ---
section "git-secrets"
if [ -d "$HOME/.git-templates/git-secrets" ]; then
    skip "~/.git-templates/git-secrets (already installed)"
else
    run "Installing git-secrets hooks" git secrets --install "$HOME/.git-templates/git-secrets"
fi

# Run directly (macOS): print the summary. Sourced by setup-ubuntu.sh and setup-bazzite.sh: it prints one at the end
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    summary "carry on from step 5 in docs/macos.md"
fi
