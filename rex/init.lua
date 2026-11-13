-- Migrated from Herdr and iTerm2: no binding had a Rex counterpart, so Rex's defaults stand.

-- lazygit in a floating layer, opened in the focused terminal's directory
rex.action{
  name = "lazygit",
  title = "Lazygit",
  run = function(ctx)
    local cwd = rex.block.call("com.superlogical.terminal", "pwd", { block_id = ctx.block_id }).pwd
    return rex.session.new_layer{
      session_id = ctx.session_id,
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus = true,
      layout = { block = {
        flavor = "com.superlogical.terminal.shell",
        label = "lazygit",
        options = { command = { "lazygit" }, cwd = cwd },
      } },
    }
  end,
}
rex.bind("cmd+g", "lazygit")
