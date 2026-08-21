local mod = get_mod("weapon_cosmetics_view_improved")
mod.version = "2.7.0"
mod:info("Weapon Cosmetics Improved is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function utf8_chars(s)
	local chars = {}
	for char in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(chars, char)
	end
	return chars
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local chars = utf8_chars(text)
	local visibleIndex = 0

	for _, char in ipairs(chars) do
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for _, char in ipairs(chars) do
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

	result = "{#color(" .. colours.title .. ")}" .. result .. "{#reset()}"
	return result
end

mod:add_global_localize_strings({
	loc_VLWC_store = {
		en = "View In Store",
		ru = "Показать в магазине",
		["zh-cn"] = "在商店中查看",
		["zh-tw"] = "在商店中查看",
	},
	loc_VLWC_inspect = {
		en = "Inspect",
		ru = "Осмотреть",
		["zh-cn"] = "检查",
		["zh-tw"] = "檢查",
	},
	loc_VLWC_wishlist = {
		en = "",
		ru = "",
		["zh-cn"] = "",
		["zh-tw"] = "",
	},
	loc_VLWC_in_store = {
		en = "",
		ru = "",
		["zh-cn"] = "",
		["zh-tw"] = "",
	},
	loc_VLWC_wishlist_notification = {
		en = "The following cosmetic(s) from your wishlist are available for purchase: ",
		ru = "Следующие косметические предметы из вашего списка желаемого доступны для покупки: ",
		["zh-cn"] = "愿望单中的装饰品现已可购买",
		["zh-tw"] = "願望單中的裝飾品現已可購買",
	},
	loc_VLWC_wishlist_added = {
		en = " has been added to your wishlist.",
		ru = " добавляется в список желаемого.",
		["zh-cn"] = "已被添加至愿望单",
		["zh-tw"] = "已被添加至願望單",
	},
	loc_VLWC_wishlist_removed = {
		en = " has been removed from your wishlist.",
		ru = " убирается из списка желаемого.",
		["zh-cn"] = "已被从愿望单中移除",
		["zh-tw"] = "已被從願望單中移除",
	},
})

local mod_name = {
	en = "Weapon Cosmetics View Improved",
	ru = "Улучшенный осмотр косметических элементов оружия",
	["zh-cn"] = "武器装饰品视图改进",
	["zh-tw"] = "武器裝飾品視圖改進",
}

mod.localisation = {
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 255, 0, 0 }, { 140, 0, 0 }, true),
		ru = mod.gradientText(mod_name["ru"], { 255, 0, 0 }, { 140, 0, 0 }, true),
		["zh-cn"] = mod.gradientText(mod_name["zh-cn"], { 255, 0, 0 }, { 140, 0, 0 }, true),
		["zh-tw"] = mod.gradientText(mod_name["zh-tw"], { 255, 0, 0 }, { 140, 0, 0 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
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
		["zh-tw"] = "使你可以像角色裝飾品頁面一樣預覽全部的皮膚和飾品。",
	},
	show_unobtainable = {
		en = "Show Unobtainable Cosmetics",
		ru = "Показывать недоступные косметические предметы",
		["zh-cn"] = "显示无法获取的装饰品",
		["zh-tw"] = "顯示無法取得的裝飾品",
	},
	show_unobtainable_tooltip = {
		en = "Toggle showing of unobtainable items. These are items that have been datamined, but have no set sources yet.\n\nThis mostly includes items that may come in future updates, or are debug/placeholders. ",
		ru = "Включить отображение недоступных предметов. Это предметы, которые были найдены в данных игры, но пока не имеют источников.\n\nВ основном это предметы, которые могут появиться в будущих обновлениях, или отладочные/заглушки.",
		["zh-cn"] = "切换显示无法获取的物品。这些是已被数据挖掘但尚无确定来源的物品。\n\n主要包括可能在未来更新中出现的物品，或调试/占位物品。",
		["zh-tw"] = "切換顯示無法取得的物品。這些是已被資料探勘但尚無確定來源的物品。\n\n主要包括可能在未來更新中出現的物品，或除錯/占位物品。",
	},
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
		ru = "Включить красочное название",
		["zh-cn"] = "启用名称特效",
		["zh-tw"] = "啟用名稱特效",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
		ru = "Включает радужный эффект на тексте названия мода. Требуется перезагрузка.\nЕсли включено, вы получите небольшой эйфорический опыт каждый раз, когда прокручиваете меню модов,\nЕсли выключено - вы будете Джоном Дарктайдом и не будете иметь радужных посыпок (но я всё равно буду любить вас).",
		["zh-cn"] = "切换模组名称文本上的彩虹颜色效果。需要重新加载。\n启用后，每次滚动模组菜单时您都会获得小小的愉悦体验，\n禁用后 - 您将是一个普通暗潮玩家，没有彩虹糖（但我仍然爱您）。",
		["zh-tw"] = "切換模組名稱文字上的彩虹顏色效果。需要重新載入。\n啟用後，每次滾動模組選單時您都會獲得小小的愉悅體驗，\n停用後 - 您將是一個普通暗潮玩家，沒有彩虹糖（但我仍然愛您）。",
	},
	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
		ru = "{#color(" .. colours.title .. ")}Основные настройки{#reset()}",
		["zh-cn"] = "{#color(" .. colours.title .. ")}常规设置{#reset()}",
		["zh-tw"] = "{#color(" .. colours.title .. ")}常規設定{#reset()}",
	},
	placeholder = {
		en = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
		ru = "Заполнитель для инициализации меню модов, пока ничего не делает.\nВозможно, в будущем будут добавлены дополнительные функции.",
		["zh-cn"] = "用于初始化模组菜单的占位项，目前没有任何功能。\n未来可能会添加更多功能。",
		["zh-tw"] = "用於初始化模組選單的占位項，目前沒有任何功能。\n未來可能會新增更多功能。",
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
