local mod = get_mod("weapon_cosmetics_view_improved")

mod:add_global_localize_strings({
	loc_VLWC_store = {
		en = "View In Store"
	},
	loc_VLWC_inspect = {
		en = "Inspect"
	},
})

return {
	mod_description = {
		en = "Lets you view locked weapon cosmetics such as skins and trinkets (including premium items), just like the character cosmetic screen. ",
	},
}
