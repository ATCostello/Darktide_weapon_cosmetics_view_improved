local mod = get_mod("weapon_cosmetics_view_improved")

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
		en = "Weapon Cosmetics View Improved",
		ru = "Улучшенный осмотр косметических элементов оружия",
		["zh-cn"] = "武器装饰品视图改进",
	},
	mod_description = {
		en =
		"Lets you view locked weapon cosmetics such as skins and trinkets (including premium items), just like the character cosmetic screen.",
		ru =
		"Weapon Cosmetics View Improved - Позволяет просматривать заблокированные косметические элементы оружия, такие как скины и безделушки (включая премиум-предметы), точно так же, как и на экране осмотра косметических вещей персонажа.",
		["zh-cn"] = 
		"使你可以像角色装饰品页面一样预览全部的皮肤和饰品。",
	},
}
