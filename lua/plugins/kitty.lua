local function t_nav(fn)
    return function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), "n", false)
        vim.schedule(fn)
    end
end

return {
    "MunsMan/kitty-navigator.nvim",
    -- Keep the kitty-side kittens in sync with the plugin. ~/.config/kitty is symlinked into the
    -- dotfiles repo, so this copies navigate_kitty.py + pass_keys.py straight into the tracked config.
    -- navigate_kitty.py is required for the nvim->kitty edge handoff (init.lua calls `kitty @ kitten
    -- navigate_kitty.py <dir>`); pass_keys.py must match the `neighboring_window` map syntax in kitty.conf.
    build = {
        "cp navigate_kitty.py ~/.config/kitty",
        "cp pass_keys.py ~/.config/kitty",
    },
    -- Disable smart-splits navigation keys (AstroNvim injects these when KITTY_LISTEN_ON is set);
    -- kitty-navigator owns <C-h/j/k/l>. Resize bindings (<C-Up/Down/Left/Right>) are left intact.
    specs = {
        {
            "AstroNvim/astrocore",
            opts = function(_, opts)
                local m = opts.mappings.n
                m["<C-H>"] = false
                m["<C-J>"] = false
                m["<C-K>"] = false
                m["<C-L>"] = false
            end,
        },
    },
    keys = {
        {"<C-h>", function()require("kitty-navigator").navigateLeft()end,  desc = "Move left a Split",  mode = {"n"}},
        {"<C-j>", function()require("kitty-navigator").navigateDown()end,  desc = "Move down a Split",  mode = {"n"}},
        {"<C-k>", function()require("kitty-navigator").navigateUp()end,    desc = "Move up a Split",    mode = {"n"}},
        {"<C-l>", function()require("kitty-navigator").navigateRight()end, desc = "Move right a Split", mode = {"n"}},
        {"<C-h>", t_nav(function()require("kitty-navigator").navigateLeft()end),  desc = "Move left a Split",  mode = {"t"}},
        {"<C-j>", t_nav(function()require("kitty-navigator").navigateDown()end),  desc = "Move down a Split",  mode = {"t"}},
        {"<C-k>", t_nav(function()require("kitty-navigator").navigateUp()end),    desc = "Move up a Split",    mode = {"t"}},
        {"<C-l>", t_nav(function()require("kitty-navigator").navigateRight()end), desc = "Move right a Split", mode = {"t"}},
    },
}
