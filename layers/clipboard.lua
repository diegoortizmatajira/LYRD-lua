local L = { name = "Clipboard" }

function L.settings()
	-- only set clipboard if not in ssh, to make sure the OSC 52
	-- integration works automatically. Requires Neovim >= 0.10.0
	vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
end

return L
