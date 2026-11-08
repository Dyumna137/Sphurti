local M = {}

function M.root(buf)
	buf = buf or 0
	return vim.fs.root(buf, { ".git" })
end

function M.require_root()
	local root = M.root()
	if not root then
		vim.notify("[git] current buffer is not inside a Git repository", vim.log.levels.ERROR)
	end
	return root
end

function M.setup()
	vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git: Status" })
	vim.keymap.set("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git: Diff" })
	vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline --decorate --graph<CR>", { desc = "Git: Log" })
	vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git: Blame" })
end

return M
