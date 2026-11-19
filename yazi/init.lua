-- Plugins that need setting up (all installed through package.toml)
require("full-border"):setup { set = "rounded" }  -- rounded border round all three panes, like the fzf lists
require("git"):setup { order = 1500 }              -- git status signs in the file list
