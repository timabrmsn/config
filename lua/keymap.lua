-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.api.nvim_create_user_command("MiniFilesToggle", function()
	if not MiniFiles.close() then
		MiniFiles.open()
	end
end, {})
vim.keymap.set("n", "-", ":MiniFilesToggle<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Run current buffer based on file extension
vim.keymap.set("n", "<leader>raf", function()
	local ext = vim.fn.expand("%:e")
	local file = vim.fn.expand("%:p")
	local cmd = nil
	local tmux_session = "vim-" .. vim.fn.getcwd()

	if ext == "py" then
		cmd = "uv run " .. vim.fn.shellescape(file)
	end

	if cmd then
		local splitr = vim.system({ "tmux", "split-window", "-t", tmux_session })
		local sendr = vim.system({ "tmux", "send", "-t", tmux_session, cmd, "ENTER" })
		vim.cmd("Floaterminal")
	else
		vim.notify("No runner configured for ." .. ext .. " files", vim.log.levels.WARN)
	end
end, { desc = "Run current buffer" })

-- Floating Terminal Config
local state = {
	floating_term = {
		buf = -1,
		win = -1,
	},
	floating_lazygit = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

local function hide_floating_windows()
	local term = state.floating_term.win
	local lazygit = state.floating_lazygit.win

	if vim.api.nvim_win_is_valid(term) then
		vim.api.nvim_win_hide(state.floating_term.win)
	end
	if vim.api.nvim_win_is_valid(lazygit) then
		vim.api.nvim_win_hide(state.floating_lazygit.win)
	end
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "n", false)
end

vim.api.nvim_create_user_command("Floaterminal", function()
	if not vim.api.nvim_win_is_valid(state.floating_term.win) then
		state.floating_term = create_floating_window({ buf = state.floating_term.buf })
		if vim.bo[state.floating_term.buf].buftype ~= "terminal" then
			local cwd = vim.fn.getcwd()
			vim.cmd.term("tmux new-session -A -s vim-" .. cwd)
		end
		vim.cmd("startinsert")
	end
end, {})
vim.keymap.set("n", "<leader>t", "<C-\\><C-n>:Floaterminal<CR>")

-- Floating LazyGit Window
vim.api.nvim_create_user_command("Floatgit", function()
	if not vim.api.nvim_win_is_valid(state.floating_lazygit.win) then
		state.floating_lazygit = create_floating_window({ buf = state.floating_lazygit.buf })
		if vim.bo[state.floating_lazygit.buf].buftype ~= "terminal" then
			vim.cmd.term("lazygit")
		end
		vim.cmd("startinsert")
	end
end, {})
vim.keymap.set("n", "<leader>g", "<C-\\><C-n>:Floatgit<CR>")

vim.keymap.set({ "n", "t" }, "<leader>h", hide_floating_windows)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
