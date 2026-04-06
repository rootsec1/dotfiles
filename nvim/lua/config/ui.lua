local M = {}

local excluded_window_filetypes = {
	NvimTree = true,
	diff = true,
}

local function is_standard_editor_window(winid)
	if not winid or not vim.api.nvim_win_is_valid(winid) then
		return false
	end

	if vim.api.nvim_win_get_config(winid).relative ~= "" then
		return false
	end

	local bufnr = vim.api.nvim_win_get_buf(winid)
	local filetype = vim.bo[bufnr].filetype

	if vim.bo[bufnr].buftype ~= "" or excluded_window_filetypes[filetype] then
		return false
	end

	return not vim.startswith(filetype, "snacks")
end

local function set_window_state(winid, active)
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end

	if is_standard_editor_window(winid) then
		local base = active and "ActiveWindow" or "InactiveWindow"
		vim.wo[winid].winhighlight = table.concat({
			"Normal:" .. base,
			"NormalNC:" .. base,
			"EndOfBuffer:" .. base .. "EndOfBuffer",
			"SignColumn:" .. base .. "SignColumn",
			"LineNr:" .. base .. "LineNr",
			"CursorLine:" .. base .. "CursorLine",
		}, ",")
		return
	end

	local bufnr = vim.api.nvim_win_get_buf(winid)
	if vim.bo[bufnr].filetype == "NvimTree" then
		vim.wo[winid].winhighlight =
			"Normal:NvimTreeNormal,NormalNC:NvimTreeNormalNC,EndOfBuffer:NvimTreeEndOfBuffer,SignColumn:NvimTreeNormal,CursorLine:NvimTreeCursorLine"
		return
	end

	vim.wo[winid].winhighlight = ""
end

function M.refresh_window_highlights()
	local current = vim.api.nvim_get_current_win()

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		set_window_state(winid, winid == current)
	end
end

function M.apply()
	local set_hl = vim.api.nvim_set_hl
	local colors = {
		text = "#f5fff5",
		text_soft = "#ecf6ec",
		muted = "#869486",
		sidebar = "#000000",
		editor = "#000000",
		editor_active = "#000000",
		panel = "#0a0f14",
		panel_alt = "#0d1319",
		panel_soft = "#101820",
		border = "#39ff14",
		border_soft = "#1f6b24",
		accent = "#39ff14",
		accent_alt = "#dcdcaa",
		accent_hot = "#ff9d00",
		success = "#39ff14",
		warn = "#ff9d00",
		error = "#ff5370",
		selection = "#16351a",
		cursorline = "#0a1015",
		keyword = "#c586c0",
		type = "#dcdcaa",
		string = "#ce9178",
		constant = "#39ff14",
		func = "#dcdcaa",
		cyan = "#39ff14",
	}

	set_hl(0, "Normal", { fg = colors.text, bg = "NONE" })
	set_hl(0, "NormalNC", { fg = colors.text, bg = "NONE" })
	set_hl(0, "EndOfBuffer", { fg = colors.editor, bg = "NONE" })
	set_hl(0, "SignColumn", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "FoldColumn", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "LineNr", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "CursorLine", { bg = colors.cursorline })
	set_hl(0, "CursorLineNr", { fg = colors.accent_hot, bg = colors.editor, bold = true })
	set_hl(0, "ColorColumn", { bg = colors.panel_soft })
	set_hl(0, "Visual", { bg = colors.selection })
	set_hl(0, "Search", { fg = colors.editor, bg = colors.accent_hot, bold = true })
	set_hl(0, "IncSearch", { fg = colors.editor, bg = colors.accent, bold = true })
	set_hl(0, "WinSeparator", { fg = colors.border, bg = "NONE" })
	set_hl(0, "FloatBorder", { fg = colors.border, bg = colors.panel_alt, bold = true })
	set_hl(0, "FloatTitle", { fg = colors.accent, bg = colors.panel_alt, bold = true })
	set_hl(0, "NormalFloat", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "Pmenu", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "PmenuSel", { fg = colors.editor, bg = colors.accent, bold = true })
	set_hl(0, "PmenuSbar", { bg = colors.panel })
	set_hl(0, "PmenuThumb", { bg = colors.panel_soft })
	set_hl(0, "StatusLine", { fg = colors.text, bg = "NONE", bold = true })
	set_hl(0, "StatusLineNC", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "WinBar", { fg = colors.text, bg = "NONE" })
	set_hl(0, "WinBarNC", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "Cursor", { fg = colors.editor, bg = colors.accent_hot })
	set_hl(0, "MatchParen", { fg = colors.editor, bg = colors.accent, bold = true })
	set_hl(0, "Directory", { fg = colors.accent, bold = true })
	set_hl(0, "Comment", { fg = colors.muted })
	set_hl(0, "Keyword", { fg = colors.keyword, bold = true })
	set_hl(0, "Statement", { fg = colors.keyword, bold = true })
	set_hl(0, "Conditional", { fg = colors.keyword, bold = true })
	set_hl(0, "Repeat", { fg = colors.keyword, bold = true })
	set_hl(0, "Type", { fg = colors.type, bold = true })
	set_hl(0, "Identifier", { fg = colors.text_soft })
	set_hl(0, "Function", { fg = colors.func, bold = true })
	set_hl(0, "String", { fg = colors.string })
	set_hl(0, "Character", { fg = colors.string })
	set_hl(0, "Constant", { fg = colors.constant, bold = true })
	set_hl(0, "Boolean", { fg = colors.constant, bold = true })
	set_hl(0, "Number", { fg = colors.constant, bold = true })
	set_hl(0, "Operator", { fg = colors.text_soft })
	set_hl(0, "PreProc", { fg = colors.accent, bold = true })
	set_hl(0, "Special", { fg = colors.cyan })
	set_hl(0, "Todo", { fg = colors.editor, bg = colors.accent_hot, bold = true })
	set_hl(0, "DiagnosticError", { fg = colors.error, bold = true })
	set_hl(0, "DiagnosticWarn", { fg = colors.warn, bold = true })
	set_hl(0, "DiagnosticInfo", { fg = colors.accent, bold = true })
	set_hl(0, "DiagnosticHint", { fg = colors.success, bold = true })
	set_hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = colors.panel })
	set_hl(0, "DiagnosticVirtualTextWarn", { fg = colors.warn, bg = colors.panel })
	set_hl(0, "DiagnosticVirtualTextInfo", { fg = colors.accent, bg = colors.panel })
	set_hl(0, "DiagnosticVirtualTextHint", { fg = colors.success, bg = colors.panel })

	set_hl(0, "BufferLineFill", { bg = "NONE" })
	set_hl(0, "BufferLineBackground", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "BufferLineBufferSelected", { fg = colors.text, bg = colors.panel_alt, bold = true, italic = false })
	set_hl(0, "BufferLineBufferVisible", { fg = colors.text_soft, bg = colors.panel })
	set_hl(0, "BufferLineIndicatorSelected", { fg = colors.accent_hot, bg = colors.panel_alt })
	set_hl(0, "BufferLineIndicatorVisible", { fg = colors.panel, bg = colors.panel })
	set_hl(0, "BufferLineSeparator", { fg = colors.sidebar, bg = "NONE" })
	set_hl(0, "BufferLineSeparatorSelected", { fg = colors.panel_alt, bg = colors.panel_alt })
	set_hl(0, "BufferLineSeparatorVisible", { fg = colors.panel, bg = colors.panel })
	set_hl(0, "BufferLineModified", { fg = colors.warn, bg = colors.sidebar })
	set_hl(0, "BufferLineModifiedVisible", { fg = colors.warn, bg = colors.panel })
	set_hl(0, "BufferLineModifiedSelected", { fg = colors.warn, bg = colors.panel_alt, bold = true })
	set_hl(0, "BufferLineCloseButtonSelected", { fg = colors.error, bg = colors.panel_alt })
	set_hl(0, "BufferLineCloseButtonVisible", { fg = colors.muted, bg = colors.panel })
	set_hl(0, "BufferLineCloseButton", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "BufferLineDuplicateSelected", { fg = colors.accent, bg = colors.panel_alt })
	set_hl(0, "BufferLineOffsetSeparator", { fg = colors.border, bg = "NONE" })
	set_hl(0, "BufferLineOffsetText", { fg = colors.text, bg = "NONE", bold = true })
	set_hl(0, "BufferLineTabSeparator", { fg = colors.sidebar, bg = "NONE" })
	set_hl(0, "BufferLineTabSelected", { fg = colors.text, bg = colors.panel_alt })

	set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
	set_hl(0, "WhichKeyNormal", { link = "NormalFloat" })
	set_hl(0, "WhichKeyTitle", { link = "FloatTitle" })
	set_hl(0, "WhichKeyDesc", { fg = colors.text })
	set_hl(0, "WhichKeySeparator", { fg = colors.muted })
	set_hl(0, "WhichKeyGroup", { fg = colors.accent_hot, bold = true })

	set_hl(0, "SnacksInputNormal", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "SnacksPicker", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "SnacksPickerInput", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "SnacksPickerList", { fg = colors.text, bg = colors.panel_alt })
	set_hl(0, "SnacksPickerPreview", { fg = colors.text, bg = colors.panel })
	set_hl(0, "SnacksPickerBorder", { link = "FloatBorder" })
	set_hl(0, "SnacksPickerTitle", { link = "FloatTitle" })
	set_hl(0, "SnacksInputBorder", { link = "FloatBorder" })
	set_hl(0, "SnacksInputTitle", { link = "FloatTitle" })
	set_hl(0, "SnacksPickerMatch", { fg = colors.accent_hot, bold = true })
	set_hl(0, "SnacksPickerDir", { fg = colors.accent })
	set_hl(0, "SnacksPickerPrompt", { fg = colors.accent, bold = true })
	set_hl(0, "SnacksPickerInputSearch", { fg = colors.accent_hot, bold = true })
	set_hl(0, "SnacksPickerDimmed", { fg = colors.muted })

	set_hl(0, "NvimTreeNormal", { fg = colors.text_soft, bg = "NONE" })
	set_hl(0, "NvimTreeNormalNC", { fg = colors.text_soft, bg = "NONE" })
	set_hl(0, "NvimTreeEndOfBuffer", { fg = colors.sidebar, bg = "NONE" })
	set_hl(0, "NvimTreeCursorLine", { bg = colors.panel })
	set_hl(0, "NvimTreeWinSeparator", { fg = colors.border, bg = "NONE" })
	set_hl(0, "NvimTreeRootFolder", { fg = colors.text, bold = true })
	set_hl(0, "NvimTreeFolderName", { fg = colors.text_soft })
	set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.text, bold = true })
	set_hl(0, "NvimTreeEmptyFolderName", { fg = colors.muted })
	set_hl(0, "NvimTreeIndentMarker", { fg = colors.border_soft })
	set_hl(0, "NvimTreeGitDirty", { fg = colors.warn, bold = true })
	set_hl(0, "NvimTreeGitNew", { fg = colors.success, bold = true })
	set_hl(0, "NvimTreeGitDeleted", { fg = colors.error, bold = true })
	set_hl(0, "NvimTreeSpecialFile", { fg = colors.accent, underline = true })
	set_hl(0, "NvimTreeOpenedFile", { fg = colors.text, bg = colors.selection, bold = true })
	set_hl(0, "NvimTreeExecFile", { fg = colors.accent_alt, bold = true })

	set_hl(0, "ActiveWindow", { fg = colors.text, bg = "NONE" })
	set_hl(0, "ActiveWindowEndOfBuffer", { fg = colors.editor, bg = "NONE" })
	set_hl(0, "ActiveWindowSignColumn", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "ActiveWindowLineNr", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "ActiveWindowCursorLine", { bg = colors.cursorline })
	set_hl(0, "InactiveWindow", { fg = colors.text, bg = "NONE" })
	set_hl(0, "InactiveWindowEndOfBuffer", { fg = colors.editor, bg = "NONE" })
	set_hl(0, "InactiveWindowSignColumn", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "InactiveWindowLineNr", { fg = colors.muted, bg = "NONE" })
	set_hl(0, "InactiveWindowCursorLine", { bg = colors.panel_soft })
end

local group = vim.api.nvim_create_augroup("rootsec1_ui", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function()
		M.apply()
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "TabEnter", "WinEnter", "WinLeave" }, {
	group = group,
	callback = function()
		vim.schedule(M.refresh_window_highlights)
	end,
})

M.apply()
vim.schedule(M.refresh_window_highlights)

return M
