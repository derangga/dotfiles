local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Register aerospace custom event
sbar.add("event", "aerospace_workspace_change")

local spaces = {}

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
			color = colors.bg1,
			height = 30,
			border_color = { alpha = 0 },
		},
	})

	spaces[i] = space

	space:subscribe("mouse.clicked", function(env)
		sbar.exec("/etc/profiles/per-user/sociolla/bin/aerospace workspace " .. i)
	end)
end

-- Single bracket wrapping all spaces
sbar.add("bracket", { "/space\\..*/" }, {
	background = {
		color = colors.transparent,
		height = 28,
		border_color = { alpha = 0 },
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
			background = { color = selected and colors.white or colors.bg1 },
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
	padding_left = -3,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 9,
		color = colors.white,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 0,
		padding_right = 8,
		string = "Spaces",
		color = colors.white,
	},
	background = {
		color = colors.with_alpha(colors.bg1, 0.0),
		border_color = { alpha = 0 },
	},
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.67 },
			},
			label = { width = "dynamic" },
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
			},
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

-- Initialize with current focused workspace
sbar.exec("aerospace list-workspaces --focused", function(focused)
	focused = focused:gsub("%s+", "")
	update_spaces(focused)
end)
