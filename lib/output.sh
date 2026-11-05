# Shared output for the setup scripts: [ ] running, [✓] done, [–] already done, [✗] failed.
# Sourced by the setup scripts. Loaded once, so LOG and FAILURES are shared when
# setup-ubuntu.sh sources setup.sh, and its summary lists failures from both.
[ -n "$SETUP_OUTPUT_LOADED" ] && return
SETUP_OUTPUT_LOADED=1

tmp="${TMPDIR:-/tmp}"
LOG="$(mktemp "${tmp%/}/setup.XXXXXX")"
FAILURES=()

tilde='~'  # in a variable: newer bash turns a bare ~ in a ${var/#$HOME/...} replacement back into the full path
green=$'\e[32m' red=$'\e[31m' dim=$'\e[2m' bold=$'\e[1m' reset=$'\e[0m'
section()    { printf "\n${bold}==> %s${reset}\n" "$1"; }
ok()         { printf "  ${green}[✓]${reset} %s\n" "$1"; }
skip()       { printf "  ${dim}[–] %s${reset}\n" "$1"; }
pending()    { printf "  [ ] %s" "$1"; }
clear_line() { printf "\r\e[K"; }
fail() {  # fail "what" ["why"]
    printf "  ${red}[✗] %s${reset}\n" "$1${2:+: $2}"
    FAILURES+=("$1${2:+: $2}")
}

# Runs a command with its output going to $LOG. On failure, shows the end of that step's output
run() {
    local label="$1"; shift
    local start; start=$(wc -l < "$LOG")
    pending "$label..."
    if "$@" >> "$LOG" 2>&1; then
        clear_line; ok "$label"
    else
        clear_line
        fail "$label" "$(tail -n +$((start + 1)) "$LOG" | grep -v '^[[:space:]]*$' | tail -n 1)"
        tail -n +$((start + 1)) "$LOG" | tail -n 10 | sed "s/^/      ${dim}/; s/\$/${reset}/"
        return 1
    fi
}

# Arrow-key menu: choose "question" default_index option... Sets CHOICE.
# ↑/↓ (or k/j) to move, Enter or Space to pick. Uses the default when there's no keyboard (stdin isn't a terminal)
choose() {
    local question="$1" selected="$2"; shift 2
    local options=("$@") count=$# key rest i
    printf "  %s ${dim}(↑/↓ to move, Enter or Space to pick)${reset}\n" "$question"
    if [ ! -t 0 ]; then
        CHOICE="${options[$selected]}"
        return
    fi
    while true; do
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                printf "\r\e[K    ${green}› %s${reset}\n" "${options[$i]}"
            else
                printf "\r\e[K      %s\n" "${options[$i]}"
            fi
        done
        IFS= read -rsn1 key
        case "$key" in
            $'\e') read -rsn2 rest
                   case "$rest" in
                       '[A') selected=$(( (selected + count - 1) % count )) ;;
                       '[B') selected=$(( (selected + 1) % count )) ;;
                   esac ;;
            k) selected=$(( (selected + count - 1) % count )) ;;
            j) selected=$(( (selected + 1) % count )) ;;
            ''|' ') break ;;
        esac
        printf "\e[%dA" "$count"  # back up to redraw the options in place
    done
    CHOICE="${options[$selected]}"
}

# Asks for the sudo password once (visibly, before any output is hidden) and keeps it fresh
need_sudo() {
    [ -n "$SUDO_KEEPALIVE" ] && return
    section "sudo"
    echo "  Some steps need sudo. Enter your password once and it's kept for the whole run:"
    if ! sudo -v; then
        fail "sudo" "can't continue without it"
        exit 1
    fi
    while true; do sudo -n true; sleep 60; done 2>/dev/null &
    SUDO_KEEPALIVE=$!
    trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null' EXIT
    ok "sudo ready"
}

# Links src to dst. Skips it if it's already linked, keeps a real file in the way as <name>.backup-<date>
symlink() {
    local src="$1" dst="$2" out
    local name="${dst/#$HOME/$tilde}"

    if [ ! -e "$src" ]; then
        skip "$name (${src/#$HOME/$tilde} isn't in the repo)"
    elif [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        skip "$name (already linked)"
    elif [ -d "$dst" ] && [ ! -L "$dst" ]; then
        # ln would put the link inside the folder instead of replacing it
        fail "$name" "already exists as a folder. Move it out of the way and re-run"
    elif [ -f "$dst" ] && [ ! -L "$dst" ]; then
        # A real file is in the way (e.g. the .zshrc Oh My Zsh creates): keep it, don't overwrite it
        local backup; backup="$dst.backup-$(date +%Y%m%d-%H%M%S)"
        if out="$(mv "$dst" "$backup" 2>&1 && ln -s "$src" "$dst" 2>&1)"; then
            ok "Linked $name (the file that was there is now ${backup/#$HOME/$tilde})"
        else
            fail "Linking $name" "$out"
        fi
    elif out="$(mkdir -p "$(dirname "$dst")" 2>&1 && ln -sf "$src" "$dst" 2>&1)"; then
        ok "Linked $name"
    else
        fail "Linking $name" "$out"
    fi
}

# Prints every failure again in red, then the next step. Returns non-zero if anything failed
summary() {
    section "Summary"
    if [ ${#FAILURES[@]} -eq 0 ]; then
        ok "Everything worked"
    else
        printf "  ${red}${bold}%d problem(s):${reset}\n" "${#FAILURES[@]}"
        local f
        for f in "${FAILURES[@]}"; do printf "  ${red}[✗] %s${reset}\n" "$f"; done
        echo "  Fix them and re-run: anything already done is skipped."
    fi
    echo "  Next: $1"
    echo "  Log of everything that ran: $LOG"
    [ ${#FAILURES[@]} -eq 0 ]
}
