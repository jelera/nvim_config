-- Abbreviations
-- Ported from old vimrc Phase 7 (lines 1092-1144)
--
-- Insert mode abbreviations for:
-- - Date/time stamps
-- - Common typo corrections
-- - Signatures
-- - Text placeholders (lorem ipsum)

local M = {}

function M.setup()
	-- ============================================================================
	-- DATE ABBREVIATIONS
	-- ============================================================================
	-- These expand to formatted date/time strings
	-- Use <expr> style abbreviations that evaluate at insertion time

	-- pxdate: Fri 06 Dec 2013 09:52:35 PM CDT
	-- RFC822 format with timezone abbreviation
	vim.cmd([[iabbrev <expr> pxdate strftime("%a %d %b %Y %I:%M:%S %p %Z")]])

	-- Commented out in original vimrc, but useful variants:
	-- Uncomment these if you want them:

	-- rdate: Fri, 06 Dec 2013 21:52:35 -0600
	-- RFC822 date format with numeric timezone offset
	-- vim.cmd([[iabbrev <expr> rdate strftime("%a, %d %b %Y %H:%M:%S %z")]])

	-- adate: Dec 06, 2013
	-- American date format
	-- vim.cmd([[iabbrev <expr> adate strftime("%b %d, %Y")]])

	-- ldate: 2013-12-06 21:52:52
	-- Long date format (ISO 8601 with time)
	-- vim.cmd([[iabbrev <expr> ldate strftime("%Y-%m-%d %H:%M:%S")]])

	-- sdate: 2013-12-06
	-- Short date format (ISO 8601 date only)
	-- vim.cmd([[iabbrev <expr> sdate strftime("%Y-%m-%d")]])

	-- ============================================================================
	-- COMMON TYPING MISTAKES
	-- ============================================================================
	-- Auto-correct common typos in insert mode

	-- Programming keywords
	vim.cmd("iabbrev retunr return")
	vim.cmd("iabbrev Flase False")
	vim.cmd("iabbrev sefl self")
	vim.cmd("iabbrev pritn print")
	vim.cmd("iabbrev prnt print")
	vim.cmd("iabbrev edn end")
	vim.cmd("iabbrev dfe def")

	-- Common words
	vim.cmd("iabbrev Whta What")
	vim.cmd("iabbrev whta what")
	vim.cmd("iabbrev becuase because")
	vim.cmd("iabbrev becuas because")

	-- ============================================================================
	-- SIGNATURES
	-- ============================================================================
	-- Quick signature expansions
	-- Note: You may want to update these with your own information

	vim.cmd("iabbrev ssig Jose Elera")
	vim.cmd("iabbrev lsig Jose Elera (https://github.com/jelera)")

	-- ============================================================================
	-- TEXT PLACEHOLDERS
	-- ============================================================================
	-- Lorem ipsum text for mockups and testing

	-- Short lorem ipsum (single paragraph)
	vim.cmd(
		"iabbrev lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
			.. "Cras sollicitudin quam eget libero pulvinar id condimentum velit sollicitudin. "
			.. "Proin cursus scelerisque dui ac condimentum. Nullam quis tellus leo. "
			.. "Morbi consectetur, lectus a blandit tincidunt, tortor augue tincidunt nisi, "
			.. "sit amet rhoncus tortor velit eu felis."
	)

	-- Long lorem ipsum (two sentences)
	vim.cmd(
		"iabbrev llorem Lorem ipsum dolor sit amet, consectetur adipisicing elit, "
			.. "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
			.. "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris "
			.. "nisi ut aliquip ex ea commodo consequat."
	)

	return true
end

return M
