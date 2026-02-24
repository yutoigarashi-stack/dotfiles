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
  -- ここにプラグインを追加
  -- 例:
  -- { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
})
