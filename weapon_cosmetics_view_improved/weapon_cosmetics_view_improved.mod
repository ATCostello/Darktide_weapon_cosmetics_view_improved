return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`weapon_cosmetics_view_improved` encountered an error loading the Darktide Mod Framework.")

		new_mod("weapon_cosmetics_view_improved", {
			mod_script       = "weapon_cosmetics_view_improved/scripts/mods/weapon_cosmetics_view_improved/weapon_cosmetics_view_improved",
			mod_data         = "weapon_cosmetics_view_improved/scripts/mods/weapon_cosmetics_view_improved/weapon_cosmetics_view_improved_data",
			mod_localization = "weapon_cosmetics_view_improved/scripts/mods/weapon_cosmetics_view_improved/weapon_cosmetics_view_improved_localization",
		})
	end,
	packages = {},
}
