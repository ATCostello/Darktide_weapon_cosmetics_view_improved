local mod = get_mod("weapon_cosmetics_view_improved")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{
				setting_id = "show_unobtainable",
				type = "checkbox",
				default_value = false,
			},
		},
	},
}
