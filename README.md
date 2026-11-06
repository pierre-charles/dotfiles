# dotfiles

I'd been putting this off for years. This is finally the dotfiles repo I keep using on all my machines: one stop shop for my shell, git and editor config, tuned until every machine feels the same. Catppuccin Macchiato everywhere.

<table>
<tr>
<td><img src="docs/screenshots/eza.png" alt="The repo listed with eza --tree"><br><sub><code>eza --tree</code></sub></td>
<td><img src="docs/screenshots/fzf.png" alt="fzf's Ctrl+T file picker with a bat preview"><br><sub>fzf (Ctrl+T) with a <code>bat</code> preview</sub></td>
</tr>
<tr>
<td><img src="docs/screenshots/lazygit.png" alt="lazygit showing the latest commit"><br><sub>lazygit</sub></td>
<td><img src="docs/screenshots/yazi.png" alt="yazi browsing the scripts folder"><br><sub>yazi</sub></td>
</tr>
</table>

Want to use them? See [SETUP.md](SETUP.md).

## Why three setups

Every machine gets the same core: Homebrew, zsh with the Spaceship prompt, the CLI tools, and the configs in this repo. Each OS then has its own script for what only that OS needs.

| Machine | Why | What its script adds |
|---------|-----|----------------------|
| **macOS** | Where I spend most of my day | The apps as Homebrew casks, iTerm2 shell integration |
| **Ubuntu** | I was sick of setting it up from scratch and customising it all over again every time | apt packages, Obsidian, Brave, Zed, 1Password and 12 GNOME extensions |
| **Bazzite** | My gaming PC, which I keep tinkering with to make it a fullscreen gaming rig | Flatpak apps, Steam starting in Big Picture Mode, KDE set up for a PC that never locks or sleeps |

The Linux scripts run the shared `setup.sh` first, so the shell is the same everywhere and only the desktop differs.

## How the setup works

- **One command per machine.** Clone, run the script for your OS, log out and back in.
- **Safe to re-run.** Anything already installed or linked is skipped, so re-running after a `git pull` picks up only what's new.
- **Carries on past failures.** Each step shows `[✓]` done, `[–]` already done or `[✗]` failed with the reason, and a summary at the end lists every problem.
- **Linked, not copied.** `~/.zshrc`, `~/.gitconfig` and the app configs are links into the repo, so a tweak on one machine is a commit away from all of them.
- **Nothing personal in the repo.** Your git identity and machine-specific shell config live in `~/.gitconfig.local` and `~/.zshrc.local`.

## Shell shortcuts

What `zsh/.zshrc` and `git/.gitconfig` set up:

| Type | Does |
|------|------|
| `ll`, `la`, `l` | list files with `eza` (`ll`: everything, sizes, git status). `ls` stays plain `ls` |
| `cat` | `bat`: syntax highlighting and line numbers |
| Tab | completions as a searchable fzf list (fzf-tab), with a folder preview for `cd` |
| Ctrl+R | search command history with fzf |
| Ctrl+T | pick a file and paste its path, with a `bat` preview |
| Alt+C | jump to a folder below. In iTerm this needs **Profiles → Keys → Left Option key: Esc+** |
| `y` | yazi file manager. `q` quits into the folder you were in, `z` fuzzy-jumps, Enter opens text files in Zed |
| `lg` | lazygit |
| `mkcd <dir>` | make a folder and `cd` into it |
| `reload` | start a fresh shell after editing `.zshrc` |
| `~projects`, `~dotfiles`, `~worktrees` | named directories: `~dotfiles` on its own goes there, and they work in any path |
| `git diff`, `git show` | shown through `delta`: changed words highlighted, `n` / `N` jump between files |
| `git lg` | compact graph log. Also `git st`, `co`, `br`, `cm`, `df`, `unstage`, `last` |
| `git-remove-gone-branches` | delete local branches whose remote branch is gone (after the PR merged) |
| `worktree-create [base]` | ask for a branch and folder name, create a worktree in `~/Projects/worktrees/<repo>/` and `cd` into it |
| `worktree-init` | inside a new worktree: link `.env.local` from the main one and install dependencies |
| `worktree-clean` | remove worktrees whose branch is merged (checks GitHub PRs for squash merges), after asking |
| `dev [port]` | Next.js dev server on the first free port from 3000 |
| `serve [port]` | static file server for the current folder (Deno), port 8000 |
| `tldr <command>` | short examples, e.g. `tldr tar` |

### yazi keys

Start it with `y`, press `~` inside for the full list.

| Key | Does |
|-----|------|
| `a` | new file. End the name with `/` for a folder (`photos/`) |
| `r` | rename. With several selected, opens all the names in an editor to rename in one go |
| `d` / `D` | move to Trash / delete for good (asks first) |
| `y` / `x` / `p` | copy / cut / paste. `P` pastes over files with the same name |
| `Space` / `v` / `Ctrl+a` | select one and move down / select a range / select all. `Esc` clears |
| Enter or `o` | open: text files in Zed, others in their usual app. `O` lists every way to open it |
| `z` / `/` / `s` / `S` | fuzzy-jump below (fzf) / find in this folder / search names below (fd) / search inside files (ripgrep) |
| `c` `c` | copy the full path |
| `;` | run a shell command on the selected files |
| `t` | new tab |
| `.` | show or hide hidden files |
| `q` | quit into the folder you were in |

## Credits

- [Catppuccin](https://github.com/catppuccin) for the themes (iTerm2, btop, yazi, fzf colours)
- [Oh My Zsh](https://ohmyz.sh), [Spaceship](https://spaceship-prompt.sh), [fzf-tab](https://github.com/Aloxaf/fzf-tab)

## License

[MIT](LICENSE)
