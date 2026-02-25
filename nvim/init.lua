-- lazy.nvim のブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 基本設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvim セットアップ
require("lazy").setup({
  -- dashboard-nvim: スタートアップ画面
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      theme = "hyper",
      config = {
        week_header = {
          enable = true,
        },
      },
    },
  },

  -- dropbar.nvim: ウィンバーにパンくずリストを表示
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- nvim-scrollbar: スクロールバーを表示
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- render-markdown.nvim: バッファ内で Markdown をリッチ表示
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {
      enabled = false,
    },
  },
})
