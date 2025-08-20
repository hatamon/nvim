---@diagnostic disable: undefined-global
vim.g.mapleader = " "
vim.g.editorconfig = false
vim.keymap.set("n", "Y", "yy")
vim.keymap.set("n", "<C-PageDown>", "<cmd>bn<CR>", { silent = true })
vim.keymap.set("n", "<C-PageUp>", "<cmd>bp<CR>", { silent = true })
vim.keymap.set(
	"n",
	"<A-F>",
	"<cmd>lua vim.lsp.buf.format({ async = true, timeout_ms = 5000, filter = function(client) return client.name == 'null-ls' end })<CR>",
	{ silent = true }
)
if jit.os == "Windows" then
	vim.keymap.set("t", "<C-V>cb", "$(git branch --show-current)")
else
	vim.keymap.set("t", "<C-V>cb", "`git branch --show-current`")
end
vim.keymap.set("t", "<C-]>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-V>p", function()
	local next_char_code = vim.fn.getchar()
	local next_char = vim.fn.nr2char(next_char_code)
	return '<C-\\><C-n>"' .. next_char .. "pi"
end, { expr = true })
-- powershell 等で <C-r> を無効化しておく必要がある
vim.keymap.set("t", "<C-r>", function()
	local next_char_code = vim.fn.getchar()
	local next_char = vim.fn.nr2char(next_char_code)
	return '<C-\\><C-n>"' .. next_char .. "pi"
end, { expr = true })
vim.keymap.set("n", "<C-W>c", "<cmd>Bdelete<CR>")
vim.keymap.set("n", "<C-W><C-C>", "<cmd>Bdelete<CR>")

vim.o.ambiwidth = "single"

vim.opt.fileencodings = { "ucs-bom", "utf-8", "default", "cp932", "euc-jp", "iso-2022-jp", "latin1" }

-- powershell でいろいろおかしいので設定
vim.keymap.set("t", "<C-h>", "<BACKSPACE>")
vim.keymap.set("n", "<C-o>", "<Nop>")

----
---- disable netrw at the very start of your init.lua
----
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

----
---- disable diagnostics hide virtual text
----
--- mason でインストールした eslint-lsp により eslint が有効になるが、
--- エラーがコード中に表示されてしまい結構うざい。
--- エラーは lspsaga により表示したいので、この設定でコード中のエラー表示をなくす。
vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = false,
	severity_sort = true,
	signs = false,
})

----
---- set vim options
----
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.updatetime = 500
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.eol = true
vim.opt.fixeol = true
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"

----
---- lazy.nvim / package manager
----
--- :Lazy
--- でプラグインの管理をできる。
--- この init.lua と、lua/plugins があれば勝手にインストールしてくれる．
--- 以下は公式のインストール方法そのまま
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

----
---- mason.nvim / lsp
----
--- :Mason
--- で lsp の管理ができる。
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"ts_ls",
		"lua_ls",
		"stylelint_lsp",
		"rust_analyzer",
		"yamlls",
		"csharp_ls",
	},
	automatic_installation = true,
})
require("mason-null-ls").setup({
	ensure_installed = {
		"csharpier",
		"prettier",
		"eslint_d",
		"stylua",
		"yamlfmt",
	},
	automatic_installation = true,
})

--- :h mason-lspconfig-automatic-server-setup
--- したら出てきた設定。
--- これをやれば、いちいち lsp を指定しなくてもセットアップしてくれる模様。
require("mason-lspconfig").setup({
	function(server_name)
		require("lspconfig")[server_name].setup({
			-- これがないと .eslintrc.js が実行されるパスが、ソースコードのパスになってしまう
			-- これをいれれば、.eslintrc.js が存在するパスで実行される
			-- https://www.reddit.com/r/neovim/comments/1d0757g/comment/l5qu6us/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
			on_init = function(client)
				client.config.settings.workingDirectory = {
					directory = client.config.root_dir,
				}
			end,
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
			flags = {
				debounce_text_changes = 150,
			},
		})
	end,
})

--- これも none-ls.nvim の公式の設定のまま。
--- 公式で null_ls.builtins.formatting.eslint って書いてるところもあったが、
--- require("none-ls.diagnostics.eslint") でよさそう。
--- ただし mason-null-ls.lua で depencencies に "nvimtools/none-ls-extras.nvim" を
--- 追加しておかないとエラーになる。
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.completion.spell,
		require("none-ls.code_actions.eslint_d"),
		require("none-ls.diagnostics.eslint_d"),
		null_ls.builtins.formatting.stylua, -- Luaのフォーマッター

		-- C#の設定
		null_ls.builtins.formatting.csharpier, -- C#のフォーマッター
	},
})

----
---- tokyonight.nvim / colorschema
----
vim.cmd([[colorscheme tokyonight]])

----
---- neotree / filer
----
vim.keymap.set("n", "<leader>ee", "<cmd>Neotree reveal position=right<CR>", { silent = true })
vim.keymap.set("n", "<leader>eg", "<cmd>Neotree git_status position=right<CR>", { silent = true })
vim.keymap.set("n", "<leader>ec", "<cmd>Neotree close<CR>", { silent = true })
vim.keymap.set("n", "<leader>et", "<cmd>Neotree toggle<CR>", { silent = true })
require("neo-tree").setup({
	source_selector = {
		winbar = true,
		statusline = true,
	},
	close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
	sort_case_insensitive = false, -- used when sorting files and directories in the tree
	sort_function = nil, -- use a custom function for sorting files and directories in the tree
	-- sort_function = function (a,b)
	--       if a.type == b.type then
	--           return a.path > b.path
	--       else
	--           return a.type > b.type
	--       end
	--   end , -- this sorts files and directories descendantly
	default_component_configs = {
		container = {
			enable_character_fade = true,
		},
		indent = {
			indent_size = 2,
			padding = 1, -- extra padding on left hand side
			-- indent guides
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			highlight = "NeoTreeIndentMarker",
			-- expander config, needed for nesting files
			with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
			expander_collapsed = "",
			expander_expanded = "",
			expander_highlight = "NeoTreeExpander",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "󰜌",
			-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
			-- then these will never be used.
			default = "*",
			highlight = "NeoTreeFileIcon",
		},
		modified = {
			symbol = "[+]",
			highlight = "NeoTreeModified",
		},
		name = {
			trailing_slash = false,
			use_git_status_colors = true,
			highlight = "NeoTreeFileName",
		},
		git_status = {
			symbols = {
				-- Change type
				added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
				modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
				deleted = "✖", -- this can only be used in the git_status source
				renamed = "󰁕", -- this can only be used in the git_status source
				-- Status type
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "",
				conflict = "",
			},
		},
		-- If you don't want to use these columns, you can set `enabled = false` for each of them individually
		file_size = {
			enabled = true,
			required_width = 64, -- min width of window required to show this column
		},
		type = {
			enabled = true,
			required_width = 122, -- min width of window required to show this column
		},
		last_modified = {
			enabled = true,
			required_width = 88, -- min width of window required to show this column
		},
		created = {
			enabled = true,
			required_width = 110, -- min width of window required to show this column
		},
		symlink_target = {
			enabled = false,
		},
	},
	-- A list of functions, each representing a global custom command
	-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
	-- see `:h neo-tree-custom-commands-global`
	commands = {},
	window = {
		position = "left",
		width = 40,
		mapping_options = {
			noremap = true,
			nowait = true,
		},
		mappings = {
			["<space>"] = {
				"toggle_node",
				nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
			},
			["<2-LeftMouse>"] = "open",
			["<cr>"] = "open",
			["<esc>"] = "cancel", -- close preview or floating neo-tree window
			["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
			-- Read `# Preview Mode` for more information
			["l"] = "focus_preview",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			-- ["S"] = "split_with_window_picker",
			-- ["s"] = "vsplit_with_window_picker",
			["t"] = "open_tabnew",
			-- ["<cr>"] = "open_drop",
			-- ["t"] = "open_tab_drop",
			["w"] = "open_with_window_picker",
			--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
			["C"] = "close_node",
			-- ['C'] = 'close_all_subnodes',
			["z"] = "close_all_nodes",
			--["Z"] = "expand_all_nodes",
			["a"] = {
				"add",
				-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
				-- some commands may take optional config options, see `:h neo-tree-mappings` for details
				config = {
					show_path = "none", -- "none", "relative", "absolute"
				},
			},
			["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
			["d"] = "delete",
			["r"] = "rename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
			-- ["c"] = {
			--  "copy",
			--  config = {
			--    show_path = "none" -- "none", "relative", "absolute"
			--  }
			--}
			["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
			["q"] = "close_window",
			["R"] = "refresh",
			["?"] = "show_help",
			["<"] = "prev_source",
			[">"] = "next_source",
			["i"] = "show_file_details",
		},
	},
	nesting_rules = {},
	filesystem = {
		filtered_items = {
			visible = false, -- when true, they will just be displayed differently than normal items
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_hidden = true, -- only works on Windows for hidden files/directories
			hide_by_name = {
				--"node_modules"
			},
			hide_by_pattern = { -- uses glob style patterns
				--"*.meta",
				--"*/src/*/tsconfig.json",
			},
			always_show = { -- remains visible even if other settings would normally hide it
				--".gitignored",
			},
			always_show_by_pattern = { -- uses glob style patterns
				--".env*",
			},
			never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
				--".DS_Store",
				--"thumbs.db"
			},
			never_show_by_pattern = { -- uses glob style patterns
				--".null-ls_*",
			},
		},
		follow_current_file = {
			enabled = true, -- This will find and focus the file in the active buffer every time
			--               -- the current file is changed while the tree is open.
			leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
		},
		group_empty_dirs = false, -- when true, empty folders will be grouped together
		hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
		-- in whatever position is specified in window.position
		-- "open_current",  -- netrw disabled, opening a directory opens within the
		-- window like netrw would, regardless of window.position
		-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
		use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
		-- instead of relying on nvim autocmd events.
		window = {
			width = 40,
			mappings = {
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				["D"] = "fuzzy_finder_directory",
				["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
				-- ["D"] = "fuzzy_sorter_directory",
				["f"] = "filter_on_submit",
				["<c-x>"] = "clear_filter",
				["[g"] = "prev_git_modified",
				["]g"] = "next_git_modified",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["og"] = { "order_by_git_status", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
				-- ['<key>'] = function(state) ... end,
			},
			fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
				-- ['<key>'] = function(state, scroll_padding) ... end,
			},
		},

		commands = {}, -- Add a custom command or override a global one using the same function name
	},
	buffers = {
		follow_current_file = {
			enabled = true, -- This will find and focus the file in the active buffer every time
			--              -- the current file is changed while the tree is open.
			leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
		},
		group_empty_dirs = true, -- when true, empty folders will be grouped together
		show_unloaded = true,
		window = {
			mappings = {
				["bd"] = "buffer_delete",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
		},
	},
	git_status = {
		window = {
			position = "float",
			mappings = {
				["A"] = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
				["gg"] = "git_commit_and_push",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
		},
	},
})

vim.cmd([[nnoremap \ :Neotree reveal<cr>]])

----
---- lspsaga.nvim / ui
----
vim.keymap.set("n", "<C-K><C-I>", "<cmd>Lspsaga hover_doc<CR>")
vim.keymap.set("n", "<C-K><C-F>", "<cmd>Lspsaga finder<CR>")
vim.keymap.set("n", "<C-K><C-.>", "<cmd>Lspsaga code_action<CR>")
vim.keymap.set("n", "<C-K>.", "<cmd>Lspsaga code_action<CR>")
vim.keymap.set("n", "<F2>", "<cmd>Lspsaga rename<CR>")
vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
vim.keymap.set("n", "<F12>", "<cmd>Lspsaga goto_definition<CR>")
vim.keymap.set("n", "<C-K><C-W>", "<cmd>Lspsaga winbar_toggle<CR>")
vim.keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
vim.keymap.set("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
vim.keymap.set("n", "<leader>cp", "<cmd>Lspsaga peek_definition<CR>")
vim.keymap.set("n", "<leader>cd", "<cmd>Lspsaga goto_definition<CR>")
vim.keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "<leader>db", "<cmd>Lspsaga show_buf_diagnostics<CR>")
vim.keymap.set("n", "<leader>dw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")
vim.keymap.set("n", "<leader>dl", "<cmd>Lspsaga show_line_diagnostics<CR>")

require("lspsaga").setup({
	symbol_in_winbar = { enable = false },
	lightbulb = { enable = false, sign = false, virtual_text = false, enable_in_insert = false },
	outline = { enable = false },
})

----
---- bufferline / ui
----
vim.opt.termguicolors = true
require("bufferline").setup({
	options = {
		indicator = {
			style = "none",
		},
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer",
				text_align = "left",
				separator = true,
			},
		},
		always_show_bufferline = true,
		close_command = "Bdelete %d",
		right_mouse_command = "Bdelete %d",
	},
})

----
---- scrollbar / ui
----
-- require("scrollbar").setup()
-- require("scrollbar.handlers.gitsigns").setup()

----
---- lualine / ui
----
require("lualine").setup({
	scope = { enabled = false },
})

----
---- indent-blankline / ui
----
require("ibl").setup()

----
---- telescope / search
----
require("telescope").setup({
	defaults = {
		layout_strategy = "vertical",
		layout_config = {
			width = 0.9,
			height = 0.9,
		},
		prompt_prefix = "🔍 ",
		selection_caret = "〉 ",
		entry_prefix = "  ",
		color_devicons = true,
		path_display = function(opts, path)
			local tail = string.match(path, "[^/\\]+$")
			return string.format("%s (%s)", tail, path)
		end,
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		grep_string = {
			additional_args = { "--hidden" },
		},
		live_grep = {
			additional_args = { "--hidden" },
		},
		quickfix = {
			show_line = false,
		},
	},
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ cwd = vim.fn.getcwd() })
end)
vim.keymap.set("n", "<leader>fg", function()
	builtin.git_files({ show_untracked = true, use_git_root = false, cwd = vim.fn.getcwd() })
end)
vim.keymap.set("n", "<leader>g", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>vg", function()
	local word = vim.fn.input("Search (git files): ")
	if word == "" then
		return
	end

	-- 除外したい拡張子リスト
	local excluded_extensions = {
		"exe",
		"xlsx",
		"xlsm",
		"pptx",
		"pptm",
		"docx",
		"docm",
		"csproj",
		"sln",
		"zip",
		"jpg",
		"jpeg",
		"png",
		"playlist",
	}

	-- ファイルが除外対象でないか判定する関数
	local function should_include(file)
		for _, ext in ipairs(excluded_extensions) do
			if file:match("%." .. ext .. "$") then
				return false
			end
		end
		return true
	end

	-- git ls-files から取得し、除外フィルタをかける
	local files = vim.fn.systemlist("git ls-files --cached --others --exclude-standard")
	local filtered = vim.tbl_filter(should_include, files)

	-- スペース区切りに変換
	local filelist = table.concat(filtered, " ")

	-- vimgrep を実行
	vim.cmd("vimgrep /" .. word .. "/gj " .. filelist)
	vim.cmd("Telescope quickfix")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>vr", "<cmd>Telescope resume<CR>", { noremap = true, silent = true })

----
---- terminal の shell
----
if jit.os == "Windows" then
	vim.opt.shell = "pwsh"
	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
	vim.opt.shellquote = ""
	vim.opt.shellpipe = "|"
	vim.opt.shellredir = "|"
	vim.opt.shellxquote = ""
end

----
---- toggleterm / ui
----
local shell = null
local shellcmdflag = null
if jit.os == "Windows" then
	shell = "pwsh"
	shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
end

require("toggleterm").setup({
	shell = shell,
	shellcmdflag = shellcmdflag,
	open_mapping = "<C-\\>",
	start_in_insert = true,
	direction = "float",
})

----
---- gitsigns / git
----
require("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		follow_files = true,
	},
	auto_attach = true,
	attach_to_untracked = false,
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	-- current_line_blame_formatter_opts = {
	--     relative_time = false,
	-- },
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000, -- Disable if file is longer than this (in lines)
	preview_config = {
		-- Options passed to nvim_open_win
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
})

----
---- nvim-treesitter
----
require("nvim-treesitter.configs").setup({
	-- VS2022 x64 の環境で :TSUpdate すればインストールされる
	ensure_installed = {
		"tsx",
		"typescript",
		"javascript",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"graphql",
		"csv",
		"c_sharp",
		"c",
		"cpp",
		"rust",
		"bash",
		"markdown",
		"markdown_inline",
	},
	-- 構文ハイライトを有効にする
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true -- Disable highlighting for large files
			end
		end,
	},

	-- インデントを有効にする
	indent = {
		enable = true,
	},

	-- 増強選択を有効にする
	incremental_selection = {
		enable = false,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},

	-- テキストオブジェクトを有効にする
	textobjects = {
		select = {
			enable = false,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = false,
			set_jumps = true,
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},
	---- vim-matchup
	matchup = {
		enable = true,
	},
})

---- vim-matchup 高速化
vim.g.matchup_matchparen_offscreen = {}
vim.g.matchup_matchparen_timeout = 100
vim.g.matchup_matchparen_deferred = 1

---- nvim 高速化
vim.opt.lazyredraw = true
vim.opt.ttyfast = true

----
---- nvim-cmp / completion
----
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local luasnip = require("luasnip")

require("luasnip/loaders/from_vscode").lazy_load() -- Load snippets from friendly-snippets

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(function(fallback)
			fallback()
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			fallback()
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, -- For luasnip users.
		-- { name = "buffer" },
		-- { name = "path" },
	}),
})

-- `/` cmdline setup.
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "cmdline" },
		{ name = "path" },
	}),
	completion = {
		autocomplete = false,
	},
})

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- LSP設定
local nvim_lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- サーバーの設定（例としてtsserverを使用）
nvim_lsp.ts_ls.setup({
	flags = {
		debounce_text_changes = 150,
	},
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

----
---- diffview / git
----
require("diffview").setup({
	view = {
		default = {
			layout = "diff2_vertical",
		},
	},
})
vim.keymap.set("n", "<leader>go", "<cmd>DiffviewOpen<CR>", { silent = true })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { silent = true })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>g[", "<cmd>Gitsigns prev_hunk<CR>", { silent = true })
vim.keymap.set("n", "<leader>g]", "<cmd>Gitsigns next_hunk<CR>", { silent = true })
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { silent = true })
vim.keymap.set("n", "<leader>gx", "<cmd>Gitsigns reset_hunk<CR>", { silent = true })

----
---- nvim-treesitter-context
----
require("treesitter-context").setup({
	multiline_threshold = 3,
	max_lines = 3,
	throttle = true, -- trueにすると更新処理を間引く（デフォルトはtrue）
	throttle_ms = 100, -- 最低100msごとにしか更新しない（遅くすると負荷減る）
	mode = "topline", -- 表示されている最上行の行番号に基づく（軽量）
})

----
---- github copilot
----
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	copilot_node_command = "node",
})

----
---- csvview
----
vim.keymap.set("n", "<leader>csv", "<cmd>CsvViewToggle<CR>")

----
---- dotnet test
----
-- テスト関数名を取得（簡易的に）
local function get_current_test_method()
	local ts_utils = require("nvim-treesitter.ts_utils")

	local node = ts_utils.get_node_at_cursor()
	while node do
		if node:type() == "method_declaration" then
			for child in node:iter_children() do
				if child:type() == "identifier" then
					return vim.treesitter.get_node_text(child, 0)
				end
			end
		end
		node = node:parent()
	end
	return nil
end

-- 名前空間とクラス名を取得
local function get_namespace_and_class()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local namespace, class
	for _, line in ipairs(lines) do
		namespace = namespace or line:match("^%s*namespace%s+([%w%.]+)")
		class = class or line:match("^%s*public%s+class%s+([%w_]+)")
		if namespace and class then
			break
		end
	end
	return namespace, class
end

local function find_csproj_path()
	local path = vim.fn.expand("%:p:h")
	while path ~= "/" do
		local csproj = vim.fn.glob(path .. "/*.csproj")
		if csproj ~= "" then
			return csproj
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil
end

local function run_current_test(target)
	local method = get_current_test_method()
	local ns, class = get_namespace_and_class()
	local csproj = find_csproj_path()

	if not (method and ns and class and csproj) then
		print("❌ 情報を取得できませんでした")
		return
	end

	local fqname = ns .. "." .. class
	if target == "method" then
		fqname = fqname .. "." .. method
	end
	local cmd = string.format(
		'dotnet build %q --verbosity quiet && dotnet test %q --no-build --logger "console;verbosity=minimal" --filter "FullyQualifiedName~%s"',
		csproj,
		csproj,
		fqname
	)

	print("▶ 実行: " .. cmd)
	vim.cmd("split | terminal " .. cmd)
	vim.cmd("setlocal bufhidden=wipe")
end

vim.keymap.set("n", "<leader>tn", function()
	run_current_test("method")
end, { desc = "現在のテスト関数を dotnet test 実行" })
vim.keymap.set("n", "<leader>tf", function()
	run_current_test("file")
end, { desc = "現在のファイルを dotnet test 実行" })
