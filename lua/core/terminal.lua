local M = {
	buf = nil,
	win = nil,
}

local function cwd(project)
	if project then
		return vim.fs.root(0, { ".git", "platformio.ini", "CMakeLists.txt", "Makefile", "sdkconfig" })
	end
	local file = vim.api.nvim_buf_get_name(0)
	return file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
end

local function close()
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
	end
	M.win = nil
end

function M.toggle(project)
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		return close()
	end

	local dir = cwd(project) or vim.fn.getcwd()
	if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
		M.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[M.buf].bufhidden = "hide"
		vim.bo[M.buf].filetype = "terminal"
		vim.api.nvim_buf_call(M.buf, function()
			vim.fn.termopen(vim.o.shell, {
				cwd = dir,
				on_exit = function()
					if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
						vim.bo[M.buf].modified = false
					end
				end,
			})
		end)
	end

	vim.cmd("botright split")
	M.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_height(M.win, math.floor(vim.o.lines * 0.3))
	vim.api.nvim_win_set_buf(M.win, M.buf)
	vim.cmd("startinsert")
end

function M.setup()
	vim.keymap.set({ "n", "t" }, "<leader>tt", function()
		M.toggle(false)
	end, { desc = "Terminal: Toggle file directory" })
	vim.keymap.set({ "n", "t" }, "<leader>tc", function()
		M.toggle(true)
	end, { desc = "Terminal: Toggle project root" })
	vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: Exit insert mode" })
	vim.api.nvim_create_user_command("ProjectTerminal", function()
		M.toggle(true)
	end, { desc = "Open terminal at project root" })
end

return M
