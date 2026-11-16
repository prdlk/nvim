--- Full-screen TUIs (lazygit <C-g><C-g>, lazydocker <C-d><C-d>) and pj's
--- project tasks palette (<CR> / <C-m>).
---
--- Under tmux (config.pane_nav's env) they open in a 90% tmux popup over this
--- Neovim's window, the way tmux.conf's prefix + g opens lazygit; elsewhere in
--- a snacks float. The tmux lazygit runs on its own config: snacks' generated
--- theme and nvim-remote edit preset belong to a lazygit inside Neovim (the
--- preset sends `q` to $NVIM to close the float before opening a file).
local M = {}

--- Show `cmd` in a tmux popup in Neovim's cwd. The tmux client blocks until
--- the popup closes, then buffers are re-checked for changes made in it
--- (checkout, stash, discard).
--- @param cmd string
local function popup(cmd)
  local args = { "tmux", "display-popup", "-E", "-w", "90%", "-h", "90%" }
  vim.list_extend(args, { "-t", vim.env.TMUX_PANE, "-d", vim.fn.getcwd(), cmd })
  vim.system(args, { text = true }, function(result)
    vim.schedule(function()
      local err = vim.trim(result.stderr or "")
      if err ~= "" then vim.notify(("tmux popup %s: %s"):format(cmd, err), vim.log.levels.WARN) end
      vim.cmd.checktime()
    end)
  end)
end

local function tmux() return require("config.pane_nav").env() == "tmux" end

function M.lazygit()
  if tmux() then return popup "lazygit" end
  require("snacks").lazygit()
end

function M.lazydocker()
  if tmux() then return popup "lazydocker" end
  require("snacks").terminal.toggle("lazydocker", { win = { style = "float" } })
end

local PALETTE = vim.fs.normalize "~/.config/tmux/plugins/tmux-palette-plugin/bin/tmux-palette.sh"

--- Expr mapping for normal-mode <CR> / <C-m>: pj's project tasks palette,
--- tmux.conf's prefix + t. pj-palette reads the project from the active
--- pane's cwd, which is Neovim's. Plain <CR> wherever it already means
--- something or the palette cannot run: special buffers (quickfix jumps,
--- the command-line window), a count (`3<CR>`), outside tmux.
--- @return string
function M.tasks()
  if
    not tmux()
    or vim.bo.buftype ~= ""
    or vim.fn.getcmdwintype() ~= ""
    or vim.v.count > 0
    or vim.fn.executable(PALETTE) == 0
  then
    return "<CR>"
  end
  vim.schedule(function()
    vim.system({ PALETTE, "tasks" }, { text = true }, function(result)
      if result.code == 0 then return end
      vim.schedule(
        function() vim.notify("pj tasks palette: " .. vim.trim(result.stderr or ""), vim.log.levels.WARN) end
      )
    end)
  end)
  return ""
end

return M
