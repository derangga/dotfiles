local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local menu_watcher = sbar.add("item", {
	drawing = false,
	updates = false,
})
local space_menu_swap = sbar.add("item", {
	drawing = false,
	updates = true,
})
sbar.add("event", "swap_menus_and_spaces")

local max_items = 15
local menu_items = {}
for i = 1, max_items, 1 do
	local menu = sbar.add("item", "menu." .. i, {
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		drawing = false,
		icon = {
			drawing = (i == 1),
			font = "sketchybar-app-font:Regular:16.0",
		},
		label = {
			font = {
				style = settings.font.style_map[i == 1 and "Heavy" or "Semibold"],
			},
			padding_left = 6,
			padding_right = 6,
		},
		click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
	})

	menu_items[i] = menu
end

sbar.add("bracket", { "/menu\\..*/" }, {
	background = { color = colors.bg1 },
})

local menu_padding = sbar.add("item", "menu.padding", {
	drawing = false,
	width = 5,
})

local function update_menus()
	sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
		sbar.set("/menu\\..*/", { drawing = false })
		menu_padding:set({ drawing = true })
		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id < max_items then
				if id == 1 then
					local lookup = app_icons[menu]
					local icon = ((lookup == nil) and app_icons["Default"] or lookup)
					menu_items[id]:set({ icon = { string = icon, drawing = true }, label = menu, drawing = true })
				else
					menu_items[id]:set({ label = menu, drawing = true })
				end
			else
				break
			end
			id = id + 1
		end
	end)
end

menu_watcher:subscribe("front_app_switched", update_menus)

space_menu_swap:subscribe("swap_menus_and_spaces", function()
	local drawing = menu_items[1]:query().geometry.drawing == "on"
	if drawing then
		menu_watcher:set({ updates = false })
		sbar.set("/menu\\..*/", { drawing = false })
		sbar.set("/space\\..*/", { drawing = true })
		sbar.set("front_app", { drawing = true })
	else
		menu_watcher:set({ updates = true })
		sbar.set("/space\\..*/", { drawing = false })
		sbar.set("front_app", { drawing = false })
		update_menus()
	end
end)

return menu_watcher
