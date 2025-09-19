-- Bootstrap Lazy.nvim and load config safely across environments
local uv = vim.uv or vim.loop
pcall(function()
  if vim.loader then vim.loader.enable() end
end)

-- Set leaders early for consistency
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Allow overriding lazy path via LAZY env
local lazypath = vim.env.LAZY or (vim.fn.stdpath "data" .. "/lazy/lazy.nvim")

-- Bootstrap lazy.nvim only if not provided via env and not installed
if not vim.env.LAZY and not (uv and uv.fs_stat(lazypath)) then
  if vim.fn.executable "git" == 1 then
    local result = vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    }
    if vim.v.shell_error ~= 0 then vim.notify(("Error cloning lazy.nvim:\n%s"):format(result), vim.log.levels.ERROR) end
  else
    vim.notify("git not found; skipping lazy.nvim bootstrap", vim.log.levels.WARN)
  end
end

-- Add to runtimepath if available, else exit quietly (headless-safe)
if uv and uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  vim.notify(("lazy.nvim not available at %s"):format(lazypath), vim.log.levels.WARN)
  return
end

-- validate that lazy is available
local ok_lazy = pcall(require, "lazy")
if not ok_lazy then
  vim.notify(("Unable to load lazy from: %s"):format(lazypath), vim.log.levels.ERROR)
  return
end

-- Load specs and final polish with guards
local ok_setup = pcall(require, "lazy_setup")
if not ok_setup then
  vim.notify("Failed to load lazy_setup", vim.log.levels.ERROR)
  return
end

-- Polish is optional; don't fail startup if it's missing
pcall(require, "polish")
