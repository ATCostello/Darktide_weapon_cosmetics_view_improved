local mod = get_mod("weapon_cosmetics_view_improved")
mod.version = "2.6.04"
mod:info("Weapon Cosmetics Improved is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local length = #text
	local visibleIndex = 0

	-- Count visible characters
	for i = 1, length do
		local char = text:sub(i, i)
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for i = 1, length do
		local char = text:sub(i, i)

		if not colorSpaces and char == " " then
			result = result .. char
		else
			currentIndex = currentIndex + 1
			local t = (visibleIndex <= 1) and 0 or (currentIndex - 1) / (visibleIndex - 1)

			local r = math.floor(lerp(startColor[1], endColor[1], t))
			local g = math.floor(lerp(startColor[2], endColor[2], t))
			local b = math.floor(lerp(startColor[3], endColor[3], t))

			result = result .. string.format("{#color(%d,%d,%d)}%s", r, g, b, char)
		end
	end

	result = "{#color(" .. colours.title .. ")} " .. result .. "{#reset()}"
	return result
end

mod:add_global_localize_strings({
	loc_VLWC_store = {
		en = "View In Store",
		ru = "Показать в магазине",
		["zh-cn"] = "在商店中查看",
	},
	loc_VLWC_inspect = {
		en = "Inspect",
		ru = "Осмотреть",
		["zh-cn"] = "检查",
	},
	loc_VLWC_wishlist = {
		en = "",
		["zh-cn"] = "",
	},
	loc_VLWC_in_store = {
		en = "",
		["zh-cn"] = "",
	},
	loc_VLWC_wishlist_notification = {
		en = "The following cosmetic(s) from your wishlist are available for purchase: ",
		["zh-cn"] = "愿望单中的装饰品现已可购买",
	},
	loc_VLWC_wishlist_added = {
		en = " has been added to your wishlist.",
		["zh-cn"] = "已被添加至愿望单",
	},
	loc_VLWC_wishlist_removed = {
		en = " has been removed from your wishlist.",
		["zh-cn"] = "已被从愿望单中移除",
	},
})

local mod_name = {
	en = "Weapon Cosmetics View Improved",
	ru = "Улучшенный осмотр косметических элементов оружия",
	["zh-cn"] = "武器装饰品视图改进",
}

mod.localisation = {
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 255, 0, 0 }, { 140, 0, 0 }, true),
		ru = mod.gradientText(mod_name["ru"], { 255, 0, 0 }, { 140, 0, 0 }, true),
		["zh-cn"] = mod.gradientText(mod_name["zh-cn"], { 255, 0, 0 }, { 140, 0, 0 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
	},

	mod_description = {
		en = "{#color("
			.. colours.text
			.. ")}"
			.. "See locked skins & trinkets, all commodore's vestures items, data mined items and wishlisting and more, to improve the weapon cosmetics screen."
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Author: "
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Version: {#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		ru = "Weapon Cosmetics View Improved - Позволяет просматривать заблокированные косметические элементы оружия, такие как скины и безделушки (включая премиум-предметы), точно так же, как и на экране осмотра косметических вещей персонажа.",
		["zh-cn"] = "使你可以像角色装饰品页面一样预览全部的皮肤和饰品。",
	},
	show_unobtainable = {
		en = "Show Unobtainable Cosmetics",
		ru = "Показывать недоступные косметические предметы",
		["zh-cn"] = "显示无法获取的装饰品",
	},
	show_unobtainable_tooltip = {
		en = "Toggle showing of unobtainable items. These are items that have been datamined, but have no set sources yet.\n\nThis mostly includes items that may come in future updates, or are debug/placeholders. ",
	},
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
	},
	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
	},
	placeholder = {
		en = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
	},
}

mod.toggle_pizazz = function()
	for key, values in pairs(mod.localisation) do
		if key == "mod_name" then
			for language, text in pairs(values) do
				if mod:get("mod_name_pizazz_toggle") then
					mod.localisation[key][language] = mod.localisation["mod_name_pizazz"][language]
				else
					mod.localisation[key][language] = mod.localisation["mod_name_boring"][language]
				end
			end
		end
	end
end

mod.toggle_pizazz()

return mod.localisation
