-- Acid Cupcake — a Neovim colorscheme
-- Original author: Jordan Santell
-- Lua port preserving the original palette

vim.cmd("hi clear")
if vim.g.colors_name then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "acidcupcake"
vim.o.background = "dark"

local c = {
  black  = "#000000",
  white  = "#FFFDEB",
  green  = "#AAEE22",
  blue   = "#04DBE5",
  pink   = "#FF0077",
  orange = "#FFB412",
  grey   = "#727879",
  red    = "#f63d4e",
  yellow = "#f6c83d",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- UI highlights
hl("Normal",       { fg = c.white })
hl("Cursor",       { fg = c.black, bg = c.white })
hl("lCursor",      { bg = c.pink })
hl("DiffAdd",      { bg = c.blue })
hl("DiffChange",   { bg = c.pink })
hl("DiffDelete",   { fg = c.white, bg = c.pink })
hl("DiffText",     { bg = c.red, bold = true })
hl("Directory",    { fg = c.blue })
hl("ErrorMsg",     { fg = c.white, bg = c.red })
hl("FoldColumn",   { fg = c.blue, bg = c.grey })
hl("Folded",       { fg = c.blue, bg = c.grey })
hl("IncSearch",    { fg = c.black, bg = c.white })
hl("LineNr",       { fg = c.grey })
hl("ModeMsg",      { bold = true })
hl("MoreMsg",      { fg = c.green, bold = true })
hl("NonText",      { fg = c.green })
hl("Pmenu",        { bg = c.blue })
hl("PmenuSel",     { fg = c.white, bg = c.blue })
hl("Question",     { fg = c.green, bold = true })
hl("Search",       { bg = c.yellow })
hl("SpecialKey",   { fg = c.blue })
hl("StatusLine",   { fg = c.yellow, bg = c.blue, bold = true })
hl("StatusLineNC", { fg = c.black, bg = c.white, bold = true })
hl("Title",        { fg = c.pink, bold = true })
hl("VertSplit",    { fg = c.black, bg = c.white })
hl("Visual",       { fg = c.grey, bg = c.white })
hl("VisualNOS",    { underline = true, bold = true })
hl("WarningMsg",   { fg = c.red })
hl("WildMenu",     { fg = c.black, bg = c.yellow })

-- Neovim-specific UI groups (not in original, but useful)
hl("WinSeparator", { fg = c.black, bg = c.white })
hl("NormalFloat",  { fg = c.white })
hl("FloatBorder",  { fg = c.blue })
hl("CursorLine",   { bg = "#1a1a1a" })
hl("CursorLineNr", { fg = c.yellow, bold = true })
hl("SignColumn",   { fg = c.grey })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn",  { fg = c.yellow })
hl("DiagnosticInfo",  { fg = c.blue })
hl("DiagnosticHint",  { fg = c.green })

-- Syntax highlights
hl("Comment",    { fg = c.grey })
hl("Function",   { fg = c.pink })
hl("PreProc",    { fg = c.pink })
hl("Special",    { fg = c.pink })
hl("Operator",   { fg = c.blue })
hl("Constant",   { fg = c.orange })
hl("Type",       { fg = c.orange })
hl("Statement",  { fg = c.orange })
hl("String",     { fg = c.green })
hl("Boolean",    { fg = c.green })
hl("Identifier", { fg = c.green })

-- JavaScript-specific links (from the original)
hl("javaScriptBraces", { link = "Operator" })
hl("javaScriptParens", { link = "Operator" })
hl("javaScriptValue",  { link = "Constant" })

-- Treesitter highlight links (map to the base groups above)
hl("@comment",             { link = "Comment" })
hl("@function",            { link = "Function" })
hl("@function.call",       { link = "Function" })
hl("@keyword",             { link = "Statement" })
hl("@keyword.return",      { link = "Statement" })
hl("@keyword.function",    { link = "Statement" })
hl("@keyword.operator",    { link = "Operator" })
hl("@operator",            { link = "Operator" })
hl("@punctuation.bracket",  { link = "Operator" })
hl("@punctuation.delimiter",{ link = "Operator" })
hl("@string",              { link = "String" })
hl("@boolean",             { link = "Boolean" })
hl("@number",              { link = "Constant" })
hl("@float",               { link = "Constant" })
hl("@constant",            { link = "Constant" })
hl("@constant.builtin",    { link = "Constant" })
hl("@type",                { link = "Type" })
hl("@type.builtin",        { link = "Type" })
hl("@variable",            { link = "Identifier" })
hl("@variable.builtin",    { link = "Identifier" })
hl("@property",            { link = "Identifier" })
hl("@parameter",           { link = "Identifier" })
hl("@constructor",         { link = "Function" })
hl("@include",             { link = "PreProc" })
hl("@preproc",             { link = "PreProc" })
hl("@define",              { link = "PreProc" })
