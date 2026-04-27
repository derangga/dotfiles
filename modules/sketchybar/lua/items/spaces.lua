local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Register aerospace custom event
sbar.add("event", "aerospace_workspace_change")

local spaces = {}

sbar.add("item", "space.tiling", {
	icon = {
		font = { family = settings.font.text },
		string = icons.tiling,
		padding_left = 10,
		padding_right = 10,
		color = colors.white,
	},
	label = { drawing = false },
	padding_right = 1,
	padding_left = 1,
	background = {
		color = colors.transparent,
		height = 28,
		border_width = 0,
	},
})

for i = 1, 9, 1 do
	local space = sbar.add("item", "space." .. i, {
		icon = {
			font = { family = settings.font.numbers },
			string = i,
			padding_left = 10,
			padding_right = 10,
			color = colors.white,
		},
		label = { drawing = false },
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.transparent,
			height = 28,
			border_width = 2,
			border_color = { alpha = 0 },
		},
	})

	spaces[i] = space

	space:subscribe("mouse.clicked", function()
		sbar.exec("aerospace workspace " .. i)
	end)
end

-- Single bracket wrapping all spaces
sbar.add("bracket", { "/space\\..*/" }, {
	background = {
		color = colors.bg2,
		height = 30,
	},
})

-- Padding after spaces
sbar.add("item", "space.padding", {
	width = settings.group_paddings,
})

-- Update highlight for all spaces based on focused workspace
local function update_spaces(focused_workspace)
	for i = 1, 9 do
		local selected = (tostring(i) == focused_workspace)
		spaces[i]:set({
			icon = { color = selected and colors.black or colors.white },
			background = { color = selected and colors.white or colors.transparent },
		})
	end
end

-- Listen for aerospace workspace changes
local space_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

space_observer:subscribe("aerospace_workspace_change", function(env)
	update_spaces(env.FOCUSED_WORKSPACE)
end)

-- Spaces toggle indicator
local spaces_indicator = sbar.add("item", {
	padding_left = 0,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 4,
		color = colors.white,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 8,
		padding_right = 8,
		string = "Spaces",
		color = colors.white,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Semibold"],
		},
	},
	background = {
		height = 30,
		color = colors.with_alpha(colors.bg2, 0.0),
		border_color = { alpha = 0 },
	},
})

spaces_indicator:subscribe("swap_menus_and_spaces", function()
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function()
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.67 },
				border_color = { alpha = 0.67 },
			},
			label = { width = "dynamic" },
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function()
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0 },
			},
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)

-- Initialize with current focused workspace
sbar.exec("aerospace list-workspaces --focused", function(focused)
	focused = focused:gsub("%s+", "")
	update_spaces(focused)
end)
