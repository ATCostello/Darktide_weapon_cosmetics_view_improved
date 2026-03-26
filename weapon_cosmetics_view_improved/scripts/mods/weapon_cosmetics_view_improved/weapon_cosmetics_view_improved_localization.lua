local mod = get_mod("weapon_cosmetics_view_improved")
mod.version = "2.5.05"
mod:info("Weapon Cosmetics Improved is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

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

return {
	mod_name = {
		en = "{#color("
			.. colours.title
			.. ")} "
			.. "{#color(255,0,0)}W{#color(250,0,0)}e{#color(246,0,0)}a{#color(241,0,0)}p{#color(237,0,0)}o{#color(232,0,0)}n {#color(228,0,0)}C{#color(224,0,0)}o{#color(219,0,0)}s{#color(215,0,0)}m{#color(210,0,0)}e{#color(206,0,0)}t{#color(201,0,0)}i{#color(197,0,0)}c{#color(193,0,0)}s {#color(188,0,0)}V{#color(184,0,0)}i{#color(179,0,0)}e{#color(175,0,0)}w {#color(170,0,0)}I{#color(166,0,0)}m{#color(162,0,0)}p{#color(157,0,0)}r{#color(153,0,0)}o{#color(148,0,0)}v{#color(144,0,0)}e{#color(140,0,0)}d{#reset()}",
		ru = "Улучшенный осмотр косметических элементов оружия",
		["zh-cn"] = "武器装饰品视图改进",
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
