-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Skip confirmation prompt when closing wezterm if all running processes
config.skip_close_confirmation_for_processes_named = { "bash", "zsh", "tmux" }
config.window_close_confirmation = "NeverPrompt"

-- my coolnight colorscheme
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#CBE0F0" },
	brights = { "#3A6B94", "#FF5C5C", "#5DFFC1", "#FFE899", "#A277FF", "#C49BFF", "#5FF3FF", "#FFFFFF" },
}

local jetbrains = function(weight, italic)
	return wezterm.font_with_fallback({
		{ family = "JetBrainsMono Nerd Font Mono", weight = weight, italic = italic },
		{ family = "MesloLGS Nerd Font Mono" },
		{ family = "Apple Color Emoji" },
	})
end

config.font = jetbrains("Medium", false)
config.font_size = 19

config.font_rules = {
	{ intensity = "Bold", italic = false, font = jetbrains("Bold", false) },
	{ intensity = "Normal", italic = true, font = jetbrains("Medium", false) },
	{ intensity = "Bold", italic = true, font = jetbrains("Bold", false) },
	{ intensity = "Half", italic = false, font = jetbrains("Light", false) },
	{ intensity = "Half", italic = true, font = jetbrains("Light", false) },
}

config.harfbuzz_features = {
	"calt=0",
	"clig=0",
	"liga=0",
	"ss01=1",
	"ss02=1",
	"zero=1",
	"cv99=1",
}

config.line_height = 1.0
config.cell_width = 1.0

config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.custom_block_glyphs = true
config.allow_square_glyphs_to_overflow_width = "Always"
config.bold_brightens_ansi_colors = "BrightAndBold"
config.warn_about_missing_glyphs = false

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

config.scrollback_lines = 10000

config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

config.selection_word_boundary = " \t\n{}[]()\"'`,;:│"

config.underline_thickness = "2px"
config.underline_position = "-2px"

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- smart-splits: seamless C-hjkl nav across wezterm panes <-> nvim splits (M-hjkl resize)
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	direction_keys = { "h", "j", "k", "l" },
	modifiers = { move = "CTRL", resize = "META" },
})

-- and finally, return the configuration to wezterm
return config
