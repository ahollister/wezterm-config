local wezterm = require("wezterm")

local act = wezterm.action

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
	-- Retrieve the text from the pane
	local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

	-- Create a temporary file to pass to vim
	local name = os.tmpname()
	local f = io.open(name, "w+")
	f:write(text)
	f:flush()
	f:close()

	-- Open a new window running vim and tell it to open the file
	window:perform_action(
		act.SpawnCommandInNewTab({
			args = { "vim", name },
		}),
		pane
	)

	-- Wait "enough" time for vim to read the file before we remove it.
	-- The window creation and process spawn are asynchronous wrt. running
	-- this script and are not awaitable, so we just pick a number.
	--
	-- NoteWe don't strictly need to remove this file, but it is nice
	-- to avoid cluttering up the temporary directory.
	wezterm.sleep_ms(1000)
	os.remove(name)
end)

return {
	color_scheme = "Tokyo Night",
	colors = {
		background = "#141414",
	},
	font = wezterm.font("JetBrains Mono", { weight = "Medium" }),
	window_decorations = "RESIZE",
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = true,
	font_size = 15,
	line_height = 1.3,
	leader = {
		key = "Space",
		mods = "CTRL",
		timeout_milliseconds = 1000,
	},
	keys = {
		{
			key = "v",
			mods = "LEADER",
			action = act.EmitEvent("trigger-vim-with-scrollback"),
		},
	},
}
