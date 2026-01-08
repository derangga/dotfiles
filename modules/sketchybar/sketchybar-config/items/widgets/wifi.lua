local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Choose correct interface here (change to your actual interface if needed)
local iface = "en0"

-- Build an explicit config_dir (avoid relying on $CONFIG_DIR being present)
local provider_path = "$CONFIG_DIR/helpers/event_providers/network_load/bin/network_load"

-- Start (restart) network_load provider for iface
sbar.exec(string.format('killall network_load >/dev/null 2>&1; "%s" %s network_update 2.0 &', provider_path, iface))

local popup_width = 250

local wifi_up = sbar.add("item", "widgets.wifi1", {
	position = "right",
	padding_left = -5,
	width = 0,
	icon = {
		padding_right = 0,
		font = {
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		string = icons.wifi.upload,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		color = colors.red,
		string = "??? Bps",
	},
	y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
	position = "right",
	padding_left = -5,
	icon = {
		padding_right = 0,
		font = {
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		string = icons.wifi.download,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		color = colors.blue,
		string = "??? Bps",
	},
	y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	label = { drawing = false },
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
	wifi_up.name,
	wifi_down.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center", height = 30, drawing = false },
})

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		font = {
			style = settings.font.style_map["Bold"],
		},
		string = icons.wifi.router,
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = 15,
			style = settings.font.style_map["Bold"],
		},
		max_chars = 18,
		string = "????????????",
	},
	background = {
		height = 2,
		color = colors.grey,
		y_offset = -15,
	},
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Hostname:",
		width = popup_width / 2,
	},
	label = {
		max_chars = 20,
		string = "????????????",
		width = popup_width / 2,
		align = "right",
	},
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "IP:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Subnet mask:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local router = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Router:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

-- helper to trim newlines/whitespace
local function trim(s)
	if not s then
		return ""
	end
	return s:match("^%s*(.-)%s*$") or s
end

wifi_up:subscribe("network_update", function(env)
	-- env.upload and env.download should be provided by the provider
	local up_val = env.upload or "000 Bps"
	local down_val = env.download or "000 Bps"

	local up_trim = trim(up_val)
	local down_trim = trim(down_val)

	local up_color = (up_trim == "000 Bps") and colors.grey or colors.red
	local down_color = (down_trim == "000 Bps") and colors.grey or colors.blue

	wifi_up:set({
		icon = { color = up_color },
		label = {
			string = up_trim,
			color = up_color,
		},
	})
	wifi_down:set({
		icon = { color = down_color },
		label = {
			string = down_trim,
			color = down_color,
		},
	})
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(_env)
	sbar.exec("ipconfig getifaddr " .. iface, function(result)
		local ip_trim = trim(result)
		local connected = (ip_trim ~= "")
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
				color = connected and colors.white or colors.red,
			},
		})
	end)
end)

local function hide_details()
	wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
	local q = wifi_bracket:query()
	local cur = q and q.popup and q.popup.drawing
	local should_draw = not (cur == true or cur == "on")

	if should_draw then
		wifi_bracket:set({ popup = { drawing = true } })
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = { string = trim(result) } })
		end)
		sbar.exec("ipconfig getifaddr " .. iface, function(result)
			ip:set({ label = { string = trim(result) } })
		end)
		sbar.exec("ipconfig getsummary " .. iface .. " | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			ssid:set({ label = { string = trim(result) } })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
			mask:set({ label = { string = trim(result) } })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
			router:set({ label = { string = trim(result) } })
		end)
	else
		hide_details()
	end
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
	local q = sbar.query(env.NAME)
	local label_str = nil
	if q and q.label then
		label_str = q.label.string or q.label.value or ""
	end
	label_str = trim(label_str or "")
	if label_str == "" then
		return
	end
	sbar.exec('echo "' .. label_str .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label_str, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
