local mod = get_mod("weapon_cosmetics_view_improved")

mod:add_global_localize_strings({
	loc_VLWC_store = {
		en = "View In Store",
		ru = "Показать в магазине",
	},
	loc_VLWC_inspect = {
		en = "Inspect",
		ru = "Осмотреть",
	},
	loc_VLWC_wishlist = {
		en = "",
	},
	loc_VLWC_in_store = {
		en = "",
	},
	loc_VLWC_wishlist_notification = {
		en = "The following cosmetic(s) from your wishlist are available for purchase: "
	},
	loc_VLWC_wishlist_added = {
		en = " has been added to your wishlist."
	},
	loc_VLWC_wishlist_removed = {
		en = " has been removed from your wishlist."
	},
})

return {
	mod_name = {
		en = "Weapon Cosmetics View Improved",
		ru = "Улучшенный осмотр косметических элементов оружия",
	},
	mod_description = {
		en =
		"Lets you view locked weapon cosmetics such as skins and trinkets (including premium items), just like the character cosmetic screen.",
		ru =
		"Weapon Cosmetics View Improved - Позволяет просматривать заблокированные косметические элементы оружия, такие как скины и безделушки (включая премиум-предметы), точно так же, как и на экране осмотра косметических вещей персонажа.",
	},
}
