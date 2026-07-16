--[[
-- Welcome to my personal neovim config
-- I couldn't have started this config without help from the kickstart.nvim and modular-kickstart.nvim repos, shout out TJ fr, I left a lot of helpful comments from those repositories here for help

10-15 min Lua guide:
  - https://learnxinyminutes.com/docs/lua/

Use `:help lua-guide` as a reference for how Neovim integrates Lua.
- :help lua-guide
- (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:
  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

run `:checkhealth` for more info on Neovim health
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- NOTE: whenever we write...
--    require 'module-name'
-- in this root init.lua file, Neovim will look in the ~/.config/nvim/lua folder for the
-- specific module-name, which can be a lua module itself OR a folder with lua submodules

-- [[ Setting options ]]
require("options")

-- [[ Basic Keymaps ]]
require("keymaps")

-- [[ Basic Autocommands ]]
require("autocmds")

--[[ Bootstrap the lazy.nvim plugin manager ]]
--  NOTE: See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

--[[ Install plugins using lazy ]]
require("lazy").setup({ { import = "plugins" } }, { change_detection = { notify = false } })

--  NOTE: To check the current status of your plugins, run the following
--    :Lazy

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
