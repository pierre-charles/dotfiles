#!/usr/bin/env bash
# Rex keeps its settings in macOS preferences, not in a file, so setup.sh writes them with `defaults`.
# Changed something in Rex's Settings? Read it with `defaults read com.superlogical.rex` and update this file.
# themes.json is Rex's custom themes as it stores them: Catppuccin Macchiato, imported from iterm2/catppuccin-macchiato.itermcolors
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
set -e
w() { defaults write com.superlogical.rex "$@"; }

w Workspace.customThemes -data "$(xxd -p themes.json | tr -d '\n')"
w Workspace.darkThemeID custom-F1902CEC-C1EB-4190-9A04-5ABD7B6CB2E6
w Workspace.lightThemeID merino-light
w Workspace.lightUsesExtendedThemePalette -bool true
w Workspace.interfaceStyle useTheme
w Workspace.terminalFontName "MesloLGL Nerd Font Mono"
w Workspace.terminalFontPointSize -float 14
w Workspace.terminalCursorStyle underline
w Workspace.terminalCopyOnSelect -bool true
w Workspace.terminalSmoothScrolling -bool true
w Workspace.terminalUseThemePalette -bool true
w Workspace.tabStyle vertical
w Workspace.tabIconTintMode off
w Workspace.sidebarPosition left
w Workspace.inactivePaneFadeMode both
w Workspace.usesPaneGlass -bool false
w Workspace.usesStandardInactiveWindowPaneStyles -bool true
w rex.agents.names-sessions -bool true
w rex.client.remoteControl -bool true
w rex.server.automatic-restart-enabled -bool true
w rex.server.block-plugin-reload-enabled -bool false
