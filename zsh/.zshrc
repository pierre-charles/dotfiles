#!/usr/bin/env zsh
# Shell config for every machine. Anything machine-specific (work aliases, tokens) goes in ~/.zshrc.local,
# sourced at the end.
# Order matters: environment, then Oh My Zsh and plugins, then aliases (after Oh My Zsh, which defines
# its own ls aliases and would otherwise replace ours), then functions.

# === Environment ===

# The repo: ~/.zshrc links to zsh/.zshrc in it, so follow the link and go up one folder
DOTFILES="${${(%):-%x}:A:h:h}"

# --- Homebrew ---
if [ "$(uname -s)" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export PATH="$HOME/.local/zed.app/bin:$PATH"  # Zed's Linux install script puts it here
fi

# --- fnm (Node version manager) ---
eval "$(fnm env --use-on-cd)"

# --- FZF (shortcuts are turned on after Oh My Zsh, below) ---
# fd lists files and skips .git and .gitignored paths. Previews only where the item is a file or folder:
# Ctrl+R lists commands, so a bat preview there would only show errors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# Colours: Catppuccin Mocha (github.com/catppuccin/fzf), without its bg so the terminal background shows
export FZF_DEFAULT_OPTS='--reverse --border=rounded
  --color=bg+:#313244,spinner:#F5E0DC,hl:#F38BA8,fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC
  --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8,selected-bg:#45475A,border:#6C7086,label:#CDD6F4'
export FZF_CTRL_T_OPTS='--preview="bat --color=always {}" --preview-window=right:wrap'
export FZF_ALT_C_OPTS='--preview="eza --tree --level=2 --color=always {}"'

# --- Colours: Catppuccin Mocha (fzf above, yazi and btop in their own folders) ---
export BAT_THEME="Catppuccin Mocha"  # built into bat; delta and the fzf previews use it too
export EZA_CONFIG_DIR="$DOTFILES/eza"
export LG_CONFIG_FILE="$DOTFILES/lazygit/config.yml"

# === Shell: Oh My Zsh, prompt and plugins ===

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # no Oh My Zsh theme: the Spaceship prompt below draws the prompt
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# --- Spaceship prompt ---
source "$HOMEBREW_PREFIX/opt/spaceship/spaceship.zsh"

# --- fzf shortcuts: Ctrl+R history, Ctrl+T files, Alt+C folders, ** then Tab ---
# After Oh My Zsh, which binds Ctrl+R to its own history search
source <(fzf --zsh)

# --- fzf-tab: Tab completion as a searchable fzf list ---
# Needs compinit (run by Oh My Zsh) first, and must load before autosuggestions and syntax highlighting
source "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh"
zstyle ':completion:*' menu no                               # fzf-tab replaces zsh's own menu
zstyle ':fzf-tab:*' use-fzf-default-opts yes                 # same colours as the other fzf lists
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# --- Autosuggestions and syntax highlighting (from Homebrew) ---
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# --- iTerm2 shell integration (macOS, if installed) ---
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# === Named directories ===
# `~name` works anywhere a path does: `~dotfiles` on its own goes there (Oh My Zsh turns on auto_cd),
# `zed ~dotfiles`, `ls ~worktrees/data-hub`. Tab completes after `~`, and the prompt shortens to them.
hash -d projects="$HOME/Projects"
hash -d dotfiles="$DOTFILES"
hash -d worktrees="$HOME/Projects/worktrees"

# === Aliases ===

# --- Listing files ---
alias ls="ls --color=auto"
alias ll="eza -la --git --group-directories-first"  # ls stays real ls: eza flags differ (-t takes a value)
alias la="eza -a"
alias l="eza"
alias cat="bat"

# --- Shell config ---
alias conf="zed ~/.zshrc"
alias reload="exec zsh"  # fresh shell: removed aliases and functions go too, PATH isn't duplicated

# --- Tools ---
alias lg="lazygit"
alias ulid="deno run https://docs.deno.com/examples/scripts/ulid.ts"

# --- JavaScript projects ---
alias nuke="rm -rf node_modules"
alias launch="pnpm dev"
alias launch-random='PORT=$((RANDOM % 1000 + 3001)) pnpm dev'

# === Functions ===

# --- General ---
function mkcd() { mkdir -p "$1" && cd "$1" }

# yazi file manager; quitting it (q) leaves the shell in the folder you browsed to. From yazi's docs
function y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n $cwd && $cwd != $PWD ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# --- Git ---
# Deletes local branches whose remote branch is gone (deleted after the PR merged). -D, because
# squash-merged branches never look merged to git. Branches checked out in a worktree are refused
function git-remove-gone-branches() {
  git fetch --prune
  git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads \
    | awk '$2 == "[gone]" {print $1}' | xargs -r git branch -D
}

# --- Worktrees (all live in ~worktrees/<repo>/<name>) ---
# Asks for a branch and folder name, creates the worktree from main (or the branch given) and cd's into it
function worktree-create() {
  local repo=$(basename "$(git rev-parse --show-toplevel)")
  local base=${1:-main}

  printf "Branch name: "; read branch
  printf "Worktree name: "; read name

  local dir="$HOME/Projects/worktrees/$repo/$name"
  git worktree add -b "$branch" "$dir" "$base" && cd "$dir"
}

# Run inside a new worktree: links .env.local from the main worktree and installs dependencies
function worktree-init() {
  local main_tree
  main_tree=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //')

  if [[ -z "$main_tree" ]]; then
    echo "Error: not inside a git repository"
    return 1
  fi

  local current_tree
  current_tree=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ "$current_tree" == "$main_tree" ]]; then
    echo "Error: already in the main worktree, nothing to initialise"
    return 1
  fi

  local env_src="$main_tree/.env.local"
  if [[ -e ".env.local" ]]; then
    echo ".env.local already exists, skipping"
  elif [[ -f "$env_src" ]]; then
    ln -s "$env_src" ./.env.local
    echo "Symlinked .env.local from $main_tree"
  else
    echo "Warning: no .env.local found at $env_src"
  fi

  if [[ -f "pnpm-lock.yaml" ]]; then
    pnpm install
  elif [[ -f "package-lock.json" ]]; then
    npm install
  elif [[ -f "yarn.lock" ]]; then
    yarn install
  else
    echo "No lockfile found, skipping install"
  fi
}

# Removes worktrees that are safe to delete, after asking. Safe means no uncommitted changes, and either
# everything on the branch is already in origin/main, or its GitHub PR was merged (catches squash merges)
# with no commits added since. Branches are kept: git-remove-gone-branches deletes those.
function worktree-clean() {
  local main_tree
  main_tree=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  [[ -z $main_tree ]] && { echo "Not inside a git repository"; return 1 }

  echo "Fetching ${main_tree:t}..."
  git -C "$main_tree" fetch --prune --quiet
  local base=$(git -C "$main_tree" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)

  # One entry per worktree; locked and detached ones get no branch, so they're left alone
  local -a trees branches remove
  local key value
  while read -r key value; do
    case $key in
      worktree) trees+=("$value"); branches+=("") ;;
      branch)   branches[-1]=${value#refs/heads/} ;;
      locked)   branches[-1]="" ;;
    esac
  done < <(git -C "$main_tree" worktree list --porcelain)

  # [ ] while checking, then green [✓] remove, dim [–] keep, yellow [!] keep but worth a look
  local green=$'\e[32m' yellow=$'\e[33m' red=$'\e[31m' dim=$'\e[2m' bold=$'\e[1m' reset=$'\e[0m' clear=$'\r\e[K'
  local keep="${clear}  ${dim}[–] %s (%s)${reset}\n" look="${clear}  ${yellow}[!]${reset} %s ${yellow}(%s)${reset}\n"

  echo "Checking $(( $#trees - 1 )) worktree(s) against $base and their GitHub PRs:"
  local i tree branch head pr reason out
  for (( i = 2; i <= $#trees; i++ )); do  # 1 is the main worktree
    tree=$trees[i] branch=$branches[i]
    [[ -z $branch ]] && continue
    printf "  [ ] %s" "$branch"
    if [[ $PWD == $tree || $PWD == $tree/* ]]; then
      printf "$keep" "$branch" "you're inside it"; continue
    fi
    if [[ -n $(git -C "$tree" status --porcelain) ]]; then
      printf "$keep" "$branch" "uncommitted changes"; continue
    fi
    head=$(git -C "$main_tree" rev-parse "refs/heads/$branch")
    if git -C "$main_tree" merge-base --is-ancestor "$head" "$base"; then
      reason="everything on it is in $base"
    else
      pr=$(cd "$main_tree" && gh pr list --head "$branch" --state merged --json number,headRefOid \
        --jq '.[0] | select(.) | "\(.number) \(.headRefOid)"' 2>/dev/null)
      if [[ -z $pr ]]; then
        printf "$keep" "$branch" "not merged"; continue
      elif [[ ${pr#* } != $head ]]; then
        printf "$look" "$branch" "PR #${pr%% *} merged, but it has newer commits"; continue
      fi
      reason="PR #${pr%% *} merged"
    fi
    printf "${clear}  ${green}[✓]${reset} %s ${dim}(%s)${reset}\n" "$branch" "$reason"
    remove+=("$tree")
  done

  if (( ! $#remove )); then
    echo "No merged worktrees to remove."; return
  fi
  echo
  read -q "?${bold}Remove the ${#remove} worktree(s) marked ${green}[✓]${reset}${bold}? [y/N]${reset} " || { echo; return }
  echo
  for tree in $remove; do
    if out=$(git -C "$main_tree" worktree remove "$tree" 2>&1); then
      printf "  ${green}[✓]${reset} removed %s\n" "${tree/#$HOME/~}"
    else
      printf "  ${red}[✗] %s: %s${reset}\n" "${tree/#$HOME/~}" "$out"
    fi
  done
}

# --- Dev servers ---
# Next.js dev server on the first free port from 3000 (or the one given)
function dev() {
  local port=${1:-3000}
  while lsof -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; do
    ((port++))
  done
  echo "Starting on http://localhost:$port"
  ENV=development pnpm exec next dev -p $port
}

# Static file server for the current folder, on port 8000 (or the one given)
function serve() {
  local port="${1:-8000}"
  deno run --allow-net --allow-read --allow-sys jsr:@std/http/file-server . --port "$port"
}

# === Local overrides (not in the repo) ===
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
