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
