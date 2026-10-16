--- bufferline.nvim overrides on top of the astrocommunity spec
--- @module plugins.bufferline

---@type LazySpec
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    -- the community spec reserves a "Neo-tree" titled offset over the sidebar;
    -- drop it so tabs start at the far left
    opts.options = opts.options or {}
    opts.options.offsets = nil
  end,
}
