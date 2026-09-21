-- Native supermaven source for blink.cmp (mirrors the astrocommunity blink-copilot pattern).
-- Inline ghost text + <C-l> accept come from `astrocommunity.completion.supermaven-nvim`;
-- this additionally surfaces supermaven suggestions in the blink menu so <Tab>/<CR> work.
return {
  "Huijiro/blink-cmp-supermaven",
  lazy = true,
  specs = {
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          default = { "supermaven" },
          providers = {
            supermaven = {
              name = "supermaven",
              module = "blink-cmp-supermaven",
              score_offset = 100,
              async = true,
            },
          },
        },
      },
    },
  },
}
