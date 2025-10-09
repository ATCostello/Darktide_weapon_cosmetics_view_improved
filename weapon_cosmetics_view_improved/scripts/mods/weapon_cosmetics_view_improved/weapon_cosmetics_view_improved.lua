--[[
    Name: weapon_cosmetics_view_improved
    Author: Alfthebigheaded
]]
local mod = get_mod("weapon_cosmetics_view_improved")
local CCVI = get_mod("character_cosmetics_view_improved")
local weapon_customization = get_mod("weapon_customization")

local ItemUtils = require("scripts/utilities/items")
local ItemPassTemplates = require("scripts/ui/pass_templates/item_pass_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")
local StoreView = require("scripts/ui/views/store_view/store_view")
local Breeds = require("scripts/settings/breed/breeds")

local InventoryWeaponCosmeticsView =
	require("scripts/ui/views/inventory_weapon_cosmetics_view/inventory_weapon_cosmetics_view")
local InventoryView = require("scripts/ui/views/inventory_view/inventory_view")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local Definitions =
	require("scripts/ui/views/inventory_weapon_cosmetics_view/inventory_weapon_cosmetics_view_definitions")
local InputDevice = require("scripts/managers/input/input_device")
local Items = require("scripts/utilities/items")
local MasterItems = require("scripts/backend/master_items")
local ScriptWorld = require("scripts/foundation/utilities/script_world")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UISettings = require("scripts/settings/ui/ui_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementInventoryWeaponPreview =
	require("scripts/ui/view_elements/view_element_inventory_weapon_preview/view_element_inventory_weapon_preview")
local ViewElementTabMenu = require("scripts/ui/view_elements/view_element_tab_menu/view_element_tab_menu")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local PromiseContainer = require("scripts/utilities/ui/promise_container")
local Promise = require("scripts/foundation/utilities/promise")
local ItemSlotSettings = require("scripts/settings/item/item_slot_settings")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local Archetypes = require("scripts/settings/archetype/archetypes")
local generate_blueprints_function = require("scripts/ui/view_content_blueprints/item_blueprints")
local PENANCE_TRACK_ID = "dec942ce-b6ba-439c-95e2-022c5d71394d"
local trinket_slot_order = {
	"slot_trinket_1",
	"slot_trinket_2",
}

local base_item
current_commodores_offers = {}

mod.grab_current_commodores_items = function(self, archetype)
	local player = Managers.player:local_player(1)
	local character_id = player:character_id()
	local archetype_name = player:archetype_name()
	local storefront = "premium_store_featured"

	if archetype == "veteran" or archetype == nil and archetype_name == "veteran" then
		storefront = "premium_store_skins_veteran"
	elseif archetype == "zealot" or archetype == nil and archetype_name == "zealot" then
		storefront = "premium_store_skins_zealot"
	elseif archetype == "psyker" or archetype == nil and archetype_name == "psyker" then
		storefront = "premium_store_skins_psyker"
	elseif archetype == "ogryn" or archetype == nil and archetype_name == "ogryn" then
		storefront = "premium_store_skins_ogryn"
	elseif archetype == "adamant" or archetype == nil and archetype_name == "adamant" then
		storefront = "premium_store_skins_adamant"
	end

	local store_service = Managers.data_service.store

	local _store_promise = store_service:get_premium_store(storefront)

	if not _store_promise then
		return Promise:resolved()
	end

	return _store_promise:next(function(data)
		for i = 1, #data.offers do
			data.offers[i]["layout_config"] = data.layout_config
			table.insert(current_commodores_offers, data.offers[i])
		end
	end)
end

mod.get_wishlist = function()
	local CCVI = get_mod("character_cosmetics_view_improved")
	if CCVI then
		wishlisted_items = CCVI:get("wishlisted_items")
	else
		wishlisted_items = mod:get("wishlisted_items")
	end

	if wishlisted_items == nil then
		wishlisted_items = {}
	end
end

mod.set_wishlist = function()
	local CCVI = get_mod("character_cosmetics_view_improved")
	if CCVI then
		mod:set("wishlisted_items", wishlisted_items)
		CCVI:set("wishlisted_items", wishlisted_items)
	else
		mod:set("wishlisted_items", wishlisted_items)
	end
end

mod.on_all_mods_loaded = function()
	mod.get_wishlist()

	CCVI = get_mod("character_cosmetics_view_improved")

	-- Override weapon_customization function to prevent crash when immediately backing out of store view. (For old version of EWC, keeping in just incase someone is still using it.)
	weapon_customization = get_mod("weapon_customization")

	local vector3 = Vector3
	local vector3_box = Vector3Box
	local vector3_unbox = vector3_box.unbox
	local Unit = Unit
	local unit_set_local_position = Unit.set_local_position

	if weapon_customization then
		weapon_customization.set_light_positions = function(self)
			-- Get cosmetic view
			self:get_cosmetic_view()
			if self.preview_lights and self.cosmetics_view then
				for _, unit_data in pairs(self.preview_lights) do
					-- Get default position
					if unit_data.position then
						local default_position = vector3_unbox(unit_data.position)
						-- Get difference to link unit position
						local weapon_spawner = self.cosmetics_view._weapon_preview._ui_weapon_spawner
						if
							weapon_spawner
							and weapon_spawner._link_unit_position
							and weapon_spawner._link_unit_base_position
						then
							local link_difference = vector3_unbox(weapon_spawner._link_unit_base_position)
								- vector3_unbox(weapon_spawner._link_unit_position)
							-- Position with offset
							local light_position = vector3(
								default_position[1],
								default_position[2] - link_difference[2],
								default_position[3]
							)
							-- mod:info("WEAPONCUSTOMIZATION.set_light_positions: " .. tostring(unit_data.unit))
							if not tostring(unit_data.unit) == "[Unit (deleted)]" then
								unit_set_local_position(unit_data.unit, 1, light_position)
							end
						end
					end
				end
			end
		end
	end

	-- same functionality included in ccvi
	if not CCVI then
		mod.wishlist_store_check = function(self, archetype)
			if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
				local _store_promise = mod.grab_current_commodores_items(self, archetype)
				return _store_promise
			end
		end

		mod.display_wishlist_notification = function(self)
			local _store_promise_ogryn = mod.wishlist_store_check(self, "ogryn")

			if _store_promise_ogryn then
				_store_promise_ogryn:next(function(data)
					local _store_promise_zealot = mod.wishlist_store_check(self, "zealot")

					_store_promise_zealot:next(function(data)
						local _store_promise_veteran = mod.wishlist_store_check(self, "veteran")

						_store_promise_veteran:next(function(data)
							local _store_promise_psyker = mod.wishlist_store_check(self, "psyker")

							_store_promise_psyker:next(function(data)
								local _store_promise = mod.wishlist_store_check(self)

								_store_promise:next(function(data)
									local available_items = {}
									for i, item in pairs(wishlisted_items) do
										local item_name = item.name
										local gearid = item.gearid
										local purchase_offer = nil
										purchase_offer = mod.get_item_in_current_commodores(self, gearid, item.name)

										if purchase_offer ~= nil then
											local item_text = Localize(item.display_name)
											if item.parent_item then
												item_text = item_text .. " (" .. item.parent_item .. ")"
											end
											available_items[#available_items + 1] = item_text
										end
									end

									if #available_items > 0 then
										local text = "{#color(255, 170, 30)}"
											.. Localize("loc_VLWC_wishlist_notification")
											.. "\n"
										for _, available_item in pairs(available_items) do
											text = text
												.. "{#color(125, 108, 56)} {#color(169, 191, 153)}"
												.. available_item
												.. "\n"
										end
										Managers.event:trigger("event_add_notification_message", "default", text)
									end

									current_commodores_offers = {}
								end)
							end)
						end)
					end)
				end)
			end
		end

		-- display wishlist notifications when going to character select screen...
		mod:hook_safe(CLASS.StateMainMenu, "event_request_select_new_profile", function(self, profile)
			mod.display_wishlist_notification(self)
		end)
	end
end

mod.remove_item_from_wishlist = function(item_name)
	if item_name then
		if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
			for i, item1 in pairs(wishlisted_items) do
				if item1.name == item_name then
					table.remove(wishlisted_items, i)
				end
			end
		end
	end
end

mod.update_wishlist_icons = function(self)
	local item_grid = self._item_grid
	local widgets = item_grid:widgets()

	-- Checking for matching wishlist entries to determine if item is on wishlist and icon should be shown.
	for _, widget in pairs(widgets) do
		local item_on_wishlist = false

		-- weapon skins
		if
			widget.content
			and widget.content.entry
			and widget.content.entry.item
			and widget.content.entry.item.slot_weapon_skin
			and widget.content.entry.item.slot_weapon_skin.__master_item
		then
			if widget.content.entry.item.slot_weapon_skin.__master_item then
				local previewed_item_name = widget.content.entry.item.slot_weapon_skin.__master_item.name
				if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
					for i, item in pairs(wishlisted_items) do
						if item.name == previewed_item_name then
							item_on_wishlist = true
						end
					end
				end
			end
		end

		-- trinkets
		if
			widget.content
			and widget.content.entry
			and widget.content.entry.item
			and widget.content.entry.item.attachments
			and widget.content.entry.item.attachments.slot_trinket_1
			and widget.content.entry.item.attachments.slot_trinket_1.item
			and widget.content.entry.item.attachments.slot_trinket_1.item.__master_item
		then
			if widget.content.entry.item.attachments.slot_trinket_1.item.__master_item then
				local previewed_item_name = widget.content.entry.item.attachments.slot_trinket_1.item.__master_item.name
				if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
					for i, item in pairs(wishlisted_items) do
						if item.name == previewed_item_name then
							item_on_wishlist = true
						end
					end
				end
			end
		end

		if item_on_wishlist and widget.content.entry then
			widget.content.entry.item_on_wishlist = true
		elseif widget.content.entry then
			widget.content.entry.item_on_wishlist = false
		end
	end
end

-- When selecting any weapon cosmetic, remove equip button on locked items, set purchase offer and grab all other locked weapon cosmetics if not done already.
mod:hook_safe(CLASS.InventoryWeaponCosmeticsView, "_preview_element", function(self, element)
	-- Test version Extended Weapon Customization Compatability
	if self._context and self._context.customize_attachments then
		return
	end

	local parent_item = self._presentation_item
	local selected_item = self._previewed_item

	if self._selected_tab_index == 1 then
		if string.find(self._previewed_item.name, "trinket") then
			self._previewed_item = base_item
		else
			base_item = self._previewed_item
		end
		parent_item = self._previewed_item
	end

	-- Update equip, store and wishlist buttons for selected weapon/trinket...
	if element and (self._selected_tab_index == 1 or self._selected_tab_index == 2) then
		local widgets_by_name = self._widgets_by_name

		local can_be_equipped = mod.can_item_be_equipped(self, selected_item)
		widgets_by_name.equip_button.content.visible = can_be_equipped

		local show_store_button = false
		if element.purchase_offer then
			widgets_by_name.weapon_store_button.content.visible = true
			show_store_button = true
		else
			widgets_by_name.weapon_store_button.content.visible = false
		end

		-- move the item name widget to account for the store button...
		if show_store_button == true then
			widgets_by_name.item_name.offset[2] = widgets_by_name.item_name.offset[2] - 80
		end

		-- find if item is on wishlist
		local item_on_wishlist = false
		local widgets_by_name = self._widgets_by_name

		-- weapon skins
		if self._previewed_item.slot_weapon_skin and self._previewed_item.slot_weapon_skin.__master_item then
			local previewed_item = self._previewed_item.slot_weapon_skin
			local previewed_item_name = previewed_item.__master_item.name
			if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
				for i, item in pairs(wishlisted_items) do
					if item and item.name == previewed_item_name then
						item_on_wishlist = true
					end
				end
			end
		end

		-- trinkets
		if
			self._previewed_item.attachments
			and self._previewed_item.attachments.slot_trinket_1
			and self._previewed_item.attachments.slot_trinket_1.item
			and self._previewed_item.attachments.slot_trinket_1.item.__master_item
		then
			if self._previewed_item.attachments.slot_trinket_1.item.__master_item then
				local previewed_item_name = self._previewed_item.attachments.slot_trinket_1.item.__master_item.name
				if wishlisted_items ~= nil and not table.is_empty(wishlisted_items) then
					for i, item in pairs(wishlisted_items) do
						if item.name == previewed_item_name then
							item_on_wishlist = true
						end
					end
				end
			end
		end

		if item_on_wishlist == true then
			widgets_by_name.wishlist_button.style.background_gradient.default_color =
				Color.terminal_text_warning_light(nil, true)
		else
			widgets_by_name.wishlist_button.style.background_gradient.default_color =
				Color.terminal_background_gradient(nil, true)
		end

		mod.update_wishlist_icons(self)

		if
			self._previewed_item
			and self._previewed_item.__locked
			and self._previewed_item.__locked == true
			and self._previewed_item.__master_item.source == 3
		then
			widgets_by_name.wishlist_button.content.visible = true
		else
			widgets_by_name.wishlist_button.content.visible = false
		end

		Selected_purchase_offer = element.purchase_offer

		if Selected_purchase_offer then
			widgets_by_name.wishlist_button.content.visible = true
		end

		if weapon_customization then
			widgets_by_name.weapon_store_button.offset = {
				-65,
				-55,
				0,
			}
			widgets_by_name.wishlist_button.offset = {
				-5,
				0,
				0,
			}
		else
			widgets_by_name.weapon_store_button.offset = {
				-5,
				-70,
				0,
			}

			widgets_by_name.wishlist_button.offset = {
				50,
				-22,
				2,
			}

			-- If store button isnt visible, need to move wishlist button to account for the infopanel position
			if show_store_button == false then
				widgets_by_name.wishlist_button.offset = {
					25,
					30,
					2,
				}
			else
				widgets_by_name.wishlist_button.offset = {
					50,
					-22,
					2,
				}
			end
		end

		if CCVI then
			CCVI.Selected_purchase_offer = Selected_purchase_offer
		end
	end
end)

mod:hook(CLASS.InventoryView, "on_enter", function(func, self, ...)
	func(self, ...)

	-- cache available commodores shop items when entering the inventory...
	mod.grab_current_commodores_items(self)
end)

mod:hook_require("scripts/ui/pass_templates/item_pass_templates", function(instance)
	instance.item_icon = {}
end)

mod:hook(CLASS.InventoryWeaponCosmeticsView, "on_enter", function(func, self, ...)
	func(self, ...)

	mod.get_wishlist()

	-- Updating the default widgets for the grid entries to add custom icons for wishlists, store prices etc...
	local weapon_item_size = UISettings.weapon_item_size
	local weapon_icon_size = UISettings.weapon_icon_size
	local icon_size = UISettings.icon_size
	local gadget_size = UISettings.gadget_size
	local gadget_item_size = UISettings.gadget_item_size
	local gadget_icon_size = UISettings.gadget_icon_size
	local item_icon_size = UISettings.item_icon_size

	local symbol_text_style = table.clone(UIFontSettings.header_3)

	symbol_text_style.text_color = Color.terminal_text_body_sub_header(255, true)
	symbol_text_style.default_color = Color.terminal_text_body_sub_header(255, true)
	symbol_text_style.hover_color = Color.terminal_icon_selected(255, true)
	symbol_text_style.selected_color = Color.terminal_corner_selected(255, true)
	symbol_text_style.font_size = 24
	symbol_text_style.drop_shadow = false

	local item_lock_symbol_text_style = table.clone(symbol_text_style)

	item_lock_symbol_text_style.text_horizontal_alignment = "right"
	item_lock_symbol_text_style.text_vertical_alignment = "bottom"
	item_lock_symbol_text_style.offset = {
		-10,
		-5,
		7,
	}

	local function item_change_function(content, style)
		local hotspot = content.hotspot
		local is_selected = hotspot.is_selected
		local is_focused = hotspot.is_focused
		local is_hover = hotspot.is_hover
		local default_color = style.default_color
		local selected_color = style.selected_color
		local hover_color = style.hover_color
		local color

		if is_selected or is_focused then
			color = selected_color
		elseif is_hover then
			color = hover_color
		else
			color = default_color
		end

		local progress = math.max(
			math.max(hotspot.anim_hover_progress or 0, hotspot.anim_select_progress or 0),
			hotspot.anim_focus_progress or 0
		)

		ColorUtilities.color_lerp(style.color, color, progress, style.color)
	end

	local function _symbol_text_change_function(content, style)
		local hotspot = content.hotspot
		local is_selected = hotspot.is_selected
		local is_focused = hotspot.is_focused
		local is_hover = hotspot.is_hover
		local default_text_color = style.default_color
		local hover_color = style.hover_color
		local text_color = style.text_color
		local selected_color = style.selected_color
		local color

		if is_selected or is_focused then
			color = selected_color
		elseif is_hover then
			color = hover_color
		else
			color = default_text_color
		end

		local progress = math.max(
			math.max(hotspot.anim_hover_progress or 0, hotspot.anim_select_progress or 0),
			hotspot.anim_focus_progress or 0
		)

		ColorUtilities.color_lerp(text_color, color, progress, text_color)
	end

	local item_store_icon_text_style = table.clone(UIFontSettings.header_3)

	item_store_icon_text_style.text_color = Color.terminal_corner_selected(255, true)
	item_store_icon_text_style.default_color = Color.terminal_corner_selected(255, true)
	item_store_icon_text_style.hover_color = Color.terminal_corner_selected(255, true)
	item_store_icon_text_style.selected_color = Color.terminal_corner_selected(255, true)
	item_store_icon_text_style.font_size = 24
	item_store_icon_text_style.drop_shadow = false
	item_store_icon_text_style.text_horizontal_alignment = "left"
	item_store_icon_text_style.text_vertical_alignment = "bottom"
	item_store_icon_text_style.offset = {
		10,
		0,
		7,
	}

	local wishlist_icon_text_style = table.clone(UIFontSettings.header_3)

	wishlist_icon_text_style.text_color = Color.terminal_corner_selected(255, true)
	wishlist_icon_text_style.default_color = Color.terminal_corner_selected(255, true)
	wishlist_icon_text_style.hover_color = Color.terminal_corner_selected(255, true)
	wishlist_icon_text_style.selected_color = Color.terminal_corner_selected(255, true)
	wishlist_icon_text_style.font_size = 18
	wishlist_icon_text_style.drop_shadow = false
	wishlist_icon_text_style.text_horizontal_alignment = "right"
	wishlist_icon_text_style.text_vertical_alignment = "top"
	wishlist_icon_text_style.offset = {
		-10,
		5,
		7,
	}

	local weapon_item_size = UISettings.weapon_item_size
	local weapon_icon_size = UISettings.weapon_icon_size
	local icon_size = UISettings.icon_size
	local gadget_size = UISettings.gadget_size
	local gadget_item_size = UISettings.gadget_item_size
	local gadget_icon_size = UISettings.gadget_icon_size
	local item_icon_size = UISettings.item_icon_size

	local item_price_style = table.clone(UIFontSettings.body)

	item_price_style.text_horizontal_alignment = "left"
	item_price_style.text_vertical_alignment = "bottom"
	item_price_style.horizontal_alignment = "left"
	item_price_style.vertical_alignment = "center"
	item_price_style.offset = {
		35,
		-8,
		12,
	}
	item_price_style.font_size = 20
	item_price_style.text_color = Color.white(255, true)
	item_price_style.default_color = Color.white(255, true)
	item_price_style.hover_color = Color.white(255, true)

	local gear_item_price_style = table.clone(item_price_style)

	gear_item_price_style.offset = {
		25,
		-3,
		12,
	}

	-- override the item icon to include wishlist functionality and any other tweaks I want
	ItemPassTemplates.item_icon = {
		{
			content_id = "hotspot",
			pass_type = "hotspot",
			style = {
				on_hover_sound = UISoundEvents.default_mouse_hover,
				on_pressed_sound = UISoundEvents.default_click,
			},
		},
		{
			pass_type = "texture",
			style_id = "outer_shadow",
			value = "content/ui/materials/frames/dropshadow_medium",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "center",
				color = Color.black(200, true),
				size_addition = {
					20,
					20,
				},
			},
		},
		{
			pass_type = "texture_uv",
			style_id = "icon",
			value = "content/ui/materials/icons/items/containers/item_container_landscape",
			value_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				material_values = {},
				offset = {
					0,
					0,
					4,
				},
				uvs = {
					{
						(weapon_icon_size[1] - item_icon_size[1]) * 0.5 / weapon_icon_size[1],
						(weapon_icon_size[2] - item_icon_size[2]) * 0.5 / weapon_icon_size[2],
					},
					{
						1 - (weapon_icon_size[1] - item_icon_size[1]) * 0.5 / weapon_icon_size[1],
						1 - (weapon_icon_size[2] - item_icon_size[2]) * 0.5 / weapon_icon_size[2],
					},
				},
			},
			visibility_function = function(content, style)
				local use_placeholder_texture = content.use_placeholder_texture

				if use_placeholder_texture and use_placeholder_texture == 0 then
					return true
				end

				return false
			end,
		},
		{
			pass_type = "rotated_texture",
			style_id = "loading",
			value = "content/ui/materials/loading/loading_small",
			style = {
				angle = 0,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = {
					80,
					80,
				},
				color = {
					60,
					160,
					160,
					160,
				},
				offset = {
					0,
					0,
					4,
				},
			},
			visibility_function = function(content, style)
				local use_placeholder_texture = content.use_placeholder_texture

				if not use_placeholder_texture or use_placeholder_texture == 1 then
					return true
				end

				return false
			end,
			change_function = function(content, style, _, dt)
				local add = -0.5 * dt

				style.rotation_progress = ((style.rotation_progress or 0) + add) % 1
				style.angle = style.rotation_progress * math.pi * 2
			end,
		},
		{
			pass_type = "texture",
			style_id = "background",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = Color.terminal_background_dark(nil, true),
				selected_color = Color.terminal_background_selected(nil, true),
				offset = {
					0,
					0,
					0,
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "background_gradient",
			value = "content/ui/materials/gradients/gradient_vertical",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				default_color = {
					100,
					33,
					35,
					37,
				},
				color = {
					100,
					33,
					35,
					37,
				},
				offset = {
					0,
					0,
					1,
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "button_gradient",
			value = "content/ui/materials/gradients/gradient_diagonal_down_right",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				default_color = Color.terminal_background_gradient(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				offset = {
					0,
					0,
					1,
				},
			},
			change_function = function(content, style)
				ButtonPassTemplates.terminal_button_change_function(content, style)
				ButtonPassTemplates.terminal_button_hover_change_function(content, style)
			end,
		},
		{
			pass_type = "texture",
			style_id = "frame",
			value = "content/ui/materials/frames/frame_tile_2px",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = Color.terminal_frame(nil, true),
				default_color = Color.terminal_frame(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				hover_color = Color.terminal_frame_hover(nil, true),
				offset = {
					0,
					0,
					6,
				},
			},
			change_function = item_change_function,
		},
		{
			pass_type = "texture",
			style_id = "corner",
			value = "content/ui/materials/frames/frame_corner_2px",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = Color.terminal_corner(nil, true),
				default_color = Color.terminal_corner(nil, true),
				selected_color = Color.terminal_corner_selected(nil, true),
				hover_color = Color.terminal_corner_hover(nil, true),
				offset = {
					0,
					0,
					7,
				},
			},
			change_function = item_change_function,
		},
		{
			pass_type = "texture",
			style_id = "equipped_icon",
			value = "content/ui/materials/icons/items/equipped_label",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "top",
				size = {
					32,
					32,
				},
				offset = {
					0,
					0,
					8,
				},
			},
			visibility_function = function(content, style)
				return content.equipped
			end,
		},
		{
			pass_type = "text",
			style_id = "owned",
			value = "",
			value_id = "owned",
			style = item_owned_text_style,
			visibility_function = function(content, style)
				return content.owned
			end,
		},
		{
			pass_type = "text",
			value = "",
			style = item_lock_symbol_text_style,
			visibility_function = function(content, style)
				return content.locked
			end,
			change_function = _symbol_text_change_function,
		},
		{
			pass_type = "rect",
			style = {
				vertical_alignment = "bottom",
				offset = {
					0,
					0,
					3,
				},
				color = {
					150,
					0,
					0,
					0,
				},
				size = {
					nil,
					40,
				},
			},
			visibility_function = function(content, style)
				local is_locked = content.locked
				local is_sold = content.has_price_tag and not content.sold

				return is_locked or is_sold
			end,
		},
		{
			pass_type = "text",
			style_id = "price_text",
			value = "n/a",
			value_id = "price_text",
			style = gear_item_price_style,
			visibility_function = function(content, style)
				return content.has_price_tag and not content.sold
			end,
		},
		{
			pass_type = "texture",
			style_id = "wallet_icon",
			value = "content/ui/materials/base/ui_default_base",
			value_id = "wallet_icon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "bottom",
				size = {
					28,
					20,
				},
				offset = {
					-2,
					-5,
					12,
				},
				color = {
					255,
					255,
					255,
					255,
				},
			},
			visibility_function = function(content, style)
				return content.has_price_tag and not content.sold
			end,
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/symbols/new_item_indicator",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "top",
				size = {
					100,
					100,
				},
				offset = {
					30,
					-30,
					5,
				},
				color = Color.terminal_corner_selected(255, true),
			},
			visibility_function = function(content, style)
				return content.element.new_item_marker
			end,
			change_function = function(content, style)
				local speed = 5
				local anim_progress = 1 - (0.5 + math.sin(Application.time_since_launch() * speed) * 0.5)
				local hotspot = content.hotspot

				style.color[1] = 150 + anim_progress * 80

				local hotspot = content.hotspot

				if hotspot.is_selected or hotspot.on_hover_exit then
					content.element.new_item_marker = nil

					local element = content.element
					local item = element and (element.real_item or element.item)

					if content.element.remove_new_marker_callback and item then
						content.element.remove_new_marker_callback(item)
					end
				end
			end,
		},
		{
			pass_type = "texture",
			style_id = "favorite_icon",
			value = "content/ui/materials/symbols/character_level",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "bottom",
				size = {
					40,
					40,
				},
				offset = {
					0,
					0,
					9,
				},
				color = Color.ui_veteran(255, true),
			},
			visibility_function = function(content, style)
				return content.favorite
			end,
		},
		{
			pass_type = "text",
			value = Utf8.upper(Localize("loc_VLWC_wishlist")),
			style = wishlist_icon_text_style,
			visibility_function = function(content, style)
				if content.entry and content.entry.item_on_wishlist then
					return true
				else
					return false
				end
			end,
			change_function = _symbol_text_change_function,
		},
	}
end)

-- Was having issues with the hook on this, so ended up running as a full override... Hopefully it wont break things in the future. If it does, I'm sorry. ;)
InventoryWeaponCosmeticsView.on_exit = function(self)
	mod.set_wishlist()

	Selected_purchase_offer = {}
	if CCVI then
		CCVI.Selected_purchase_offer = {}
	end

	if self._on_enter_anim_id then
		self:_stop_animation(self._on_enter_anim_id)

		self._on_enter_anim_id = nil
	end

	self:_destroy_forward_gui()
	self:_destroy_side_panel()
	self:_equip_items_on_server()

	InventoryWeaponCosmeticsView.super.on_exit(self)
end

-- Quick check to see if item is locked... not a full can it be equipped, as that is handled beforehand to set the locked status in the weapon_cosmetics_view code.
mod.can_item_be_equipped = function(self, selected_item)
	local can_be_equipped = true

	if selected_item.__locked and selected_item.__locked == true then
		can_be_equipped = false
	end

	return can_be_equipped
end

local function _item_plus_overrides(item, gear, gear_id, is_preview_item)
	local gearid = math.uuid() or gear_id

	local masterDataInstance = {
		id = item.name,
	}

	local slots = {
		item.slots,
	}

	local __gear = {
		uuid = gearid,
		masterDataInstance = masterDataInstance,
		slots = slots,
	}

	local item_instance = {
		__master_item = item,
		__gear = __gear,
		__gear_id = gearid,
		__original_gear_id = is_preview_item and gear_id,
		__is_preview_item = is_preview_item and true or false,
		__locked = true,
	}

	setmetatable(item_instance, {
		__index = function(t, field_name)
			local master_ver = rawget(item_instance, "__master_ver")

			if master_ver ~= MasterItems.get_cached_version() then
				if MasterItems and MasterItems.update_master_data then
					local success = MasterItems.update_master_data(item_instance)

					if not success then
						Log.error(
							"MasterItems",
							"[_item_plus_overrides][1] could not update master data with %s",
							gear.masterDataInstance.id
						)

						return nil
					end
				else
					return nil
				end
			end

			if field_name == "gear_id" then
				return rawget(item_instance, "__gear_id")
			end

			if field_name == "gear" then
				return rawget(item_instance, "__gear")
			end

			local master_item = rawget(item_instance, "__master_item")

			if not master_item then
				Log.warning(
					"MasterItemCache",
					string.format("No master data for item with id %s", gear.masterDataInstance.id)
				)

				return nil
			end

			local field_value = master_item[field_name]

			if field_name == "rarity" and field_value == -1 then
				return nil
			end

			return field_value
		end,
		__newindex = function(t, field_name, value)
			rawset(t, field_name, value)
		end,
		__tostring = function(t)
			local master_item = rawget(item_instance, "__master_item")

			return string.format(
				"master_item: [%s] gear_id: [%s]",
				tostring(master_item and master_item.name),
				tostring(rawget(item_instance, "__gear_id"))
			)
		end,
	})

	if MasterItems and MasterItems.update_master_data then
		local success = MasterItems.update_master_data(item_instance)

		if not success then
			Log.error(
				"MasterItems",
				"[_item_plus_overrides][2] could not update master data with %s",
				gear.masterDataInstance.id
			)

			return nil
		end
	else
		return nil
	end
	return item_instance
end

-- Add definitions for the new store and wishlist buttons to the weapon cosmetics screen.
local add_definitions = function(definitions)
	if not definitions then
		return
	end

	definitions.scenegraph_definition = definitions.scenegraph_definition or {}
	definitions.widget_definitions = definitions.widget_definitions or {}

	local store_button_size = {
		374,
		76,
	}

	definitions.scenegraph_definition.weapon_store_button = {
		horizontal_alignment = "right",
		parent = "info_box",
		vertical_alignment = "bottom",
		size = store_button_size,
		position = {
			0,
			65,
			1,
		},
	}

	definitions.widget_definitions.weapon_store_button =
		UIWidget.create_definition(ButtonPassTemplates.default_button, "weapon_store_button", {
			gamepad_action = "confirm_pressed",
			visible = false,
			original_text = Utf8.upper(Localize("loc_VLWC_store")),
			hotspot = {},
		})

	local wishlist_button_size = {
		48,
		48,
	}

	definitions.scenegraph_definition.wishlist_button = {
		horizontal_alignment = "right",
		parent = "info_box",
		vertical_alignment = "bottom",
		size = wishlist_button_size,
		position = {
			0,
			0,
			0,
		},
	}

	definitions.widget_definitions.wishlist_button =
		UIWidget.create_definition(ButtonPassTemplates.terminal_button, "wishlist_button", {
			gamepad_action = "confirm_pressed",
			visible = false,
			original_text = Utf8.upper(Localize("loc_VLWC_wishlist")),
			hotspot = {},
		})
	local should_add_inspect = true

	for i = 1, #definitions.legend_inputs do
		if definitions.legend_inputs[i].on_pressed_callback == "cb_on_inspect_pressed" then
			should_add_inspect = false
		end
	end

	if should_add_inspect then
		definitions.legend_inputs[#definitions.legend_inputs + 1] = {
			on_pressed_callback = "cb_on_inspect_pressed",
			input_action = "hotkey_item_inspect",
			display_name = "loc_VLWC_inspect",
			alignment = "right_alignment",
			visibility_function = function(parent)
				if parent._previewed_item then
					local previewed_item = parent._previewed_item
					local slot_weapon_skin = previewed_item.slot_weapon_skin
					local skin_item = slot_weapon_skin.__master_item

					if skin_item then
						return true
					end
				end

				return false
			end,
		}
	end
end

mod:hook_require(
	"scripts/ui/views/inventory_weapon_cosmetics_view/inventory_weapon_cosmetics_view_definitions",
	function(definitions)
		add_definitions(definitions)
	end
)

Category_index = 1

local Archetypes = require("scripts/settings/archetype/archetypes")

local STORE_LAYOUT = {
	{
		display_name = "loc_premium_store_category_title_featured",
		storefront = "premium_store_featured",
		telemetry_name = "featured",
		template = ButtonPassTemplates.terminal_tab_menu_with_divider_button,
	},
	{
		display_name = "loc_premium_store_category_skins_title_veteran",
		storefront = "premium_store_skins_veteran",
		telemetry_name = "veteran",
		template = ButtonPassTemplates.terminal_tab_menu_with_divider_button,
	},
	{
		display_name = "loc_premium_store_category_skins_title_zealot",
		storefront = "premium_store_skins_zealot",
		telemetry_name = "zealot",
		template = ButtonPassTemplates.terminal_tab_menu_with_divider_button,
	},
	{
		display_name = "loc_premium_store_category_skins_title_psyker",
		storefront = "premium_store_skins_psyker",
		telemetry_name = "psyker",
		template = ButtonPassTemplates.terminal_tab_menu_with_divider_button,
	},
	{
		display_name = "loc_premium_store_category_skins_title_ogryn",
		storefront = "premium_store_skins_ogryn",
		telemetry_name = "ogryn",
		template = ButtonPassTemplates.terminal_tab_menu_button,
	},
	{
		display_name = "loc_premium_store_category_skins_title_adamant",
		storefront = "premium_store_skins_adamant",
		telemetry_name = "adamant",
		template = ButtonPassTemplates.terminal_tab_menu_button,
		require_archetype_ownership = Archetypes.adamant,
	},
}

local opened_store = false

StoreView._on_page_index_selected = function(self, page_index)
	self._selected_page_index = page_index

	local category_index = self._selected_category_index
	local category_layout = STORE_LAYOUT[category_index]
	local category_name = category_layout.telemetry_name

	self:_set_telemetry_name(category_name, page_index)

	if self._page_panel then
		self._page_panel:set_selected_index(page_index)
	end

	local category_pages_layout_data = self._category_pages_layout_data

	if not category_pages_layout_data then
		return
	end

	local page_layout = category_pages_layout_data[page_index]
	local grid_settings = page_layout.grid_settings
	local elements = page_layout.elements
	local storefront_layout = self:_debug_generate_layout(grid_settings)

	self:_setup_grid(elements, grid_settings)
	self:_start_animation("grid_entry", self._grid_widgets, self)

	local grid_index = self:_get_first_grid_panel_index()

	if not self._using_cursor_navigation and grid_index then
		self:_set_selected_grid_index(grid_index)
	end

	self._widgets_by_name.navigation_arrow_left.content.visible = page_index > 1
	self._widgets_by_name.navigation_arrow_right.content.visible = page_index < #category_pages_layout_data
	if Selected_purchase_offer and not opened_store then
		opened_store = true
		for i = 1, #self._category_pages_layout_data do
			local page_elements = self._category_pages_layout_data[i].elements
			for j = 1, #page_elements do
				local page_element = page_elements[j]
				if page_element.offer and page_element.offer.offerId == Selected_purchase_offer.offerId then
					self:_on_page_index_selected(i)
					self:_set_selected_grid_index(page_element.index)
					StoreView.cb_on_grid_entry_left_pressed(self, nil, page_element)
				end
			end
		end
	end
end

StoreView.on_exit = function(self)
	self:_clear_telemetry_name()

	if self._world_spawner then
		self._world_spawner:release_listener()
		self._world_spawner:destroy()

		self._world_spawner = nil
	end

	if self._input_legend_element then
		self._input_legend_element = nil

		self:_remove_element("input_legend")
	end

	if self._store_promise then
		self._store_promise:cancel()
	end

	if self._purchase_promise then
		self._purchase_promise:cancel()
	end

	if self._wallet_promise then
		self._wallet_promise:cancel()
	end

	self:_destroy_offscreen_gui()
	self:_unload_url_textures()
	StoreView.super.on_exit(self)

	if self._hub_interaction then
		local level = Managers.state.mission and Managers.state.mission:mission_level()

		if level then
			Level.trigger_event(level, "lua_premium_store_closed")
		end
	end

	opened_store = false
	Selected_purchase_offer = {}
end

StoreView._initialize_opening_page = function(self)
	local store_category_index = 1

	-- Go to selected item's category
	if Selected_purchase_offer then
		store_category_index = Category_index
	end

	local path = {
		category_index = store_category_index,
		page_index = 1,
	}

	self:_open_navigation_path(path)
end

local function items_by_name(entry_array, is_item)
	local _items_by_name = {}

	for i = 1, #entry_array do
		local entry = entry_array[i]
		local item = is_item and entry or entry.item
		local name = item and item.name

		if name then
			_items_by_name[name] = entry
		end
	end

	return _items_by_name
end

-- Add  my custom items to layout...
InventoryWeaponCosmeticsView._prepare_layout_data = function(self)
	local tabs_content = self._tabs_content
	local items_by_slot = self._items_by_slot
	local layout_by_slot = {}

	for i = 1, #tabs_content do
		local tab_content = tabs_content[i]
		local slot_name = tab_content.slot_name
		local item_type = tab_content.item_type
		local items = items_by_slot[slot_name]
		local generate_visual_item_function = tab_content.generate_visual_item_function
		local get_empty_item_function = tab_content.get_empty_item
		local layout_count, layout = 0, {}
		local inventory_items = items and items.items
		local penance_track_items = items and items.penance_track_items
		local store_items = items and items.store_items
		local selected_slot = ItemSlotSettings[slot_name]
		local achievement_items = self:_achievement_items(slot_name)
		local player = self._preview_player
		local profile = player:profile()
		local remove_new_marker_callback = self._parent and callback(self._parent, "remove_new_item_mark")
		local locked_achievement_items_by_name = items_by_name(achievement_items, false)
		local locked_store_items_by_name = items_by_name(store_items, false)
		local locked_penance_track_items_by_name = items_by_name(penance_track_items, false)

		---------------------------------------------
		local custom_items = items.custom
		--------------------------------------------

		if inventory_items then
			for i = 1, #inventory_items do
				local inventory_item = inventory_items[i]
				local is_empty = inventory_item.empty_item
				local item

				if is_empty then
					item = get_empty_item_function(self._selected_item, slot_name, item_type)
				else
					item = inventory_item.item
				end

				if item then
					local item_name = item.name

					local found_achievement = locked_achievement_items_by_name[item_name]

					locked_achievement_items_by_name[item_name] = nil

					local found_store = locked_store_items_by_name[item_name]

					locked_store_items_by_name[item_name] = nil

					local found_penance_track = locked_penance_track_items_by_name[item_name]

					locked_penance_track_items_by_name[item_name] = nil

					local gear_id = item.gear_id
					local is_new = self._context
						and self._context.new_items_gear_ids
						and self._context.new_items_gear_ids[gear_id]
					local visual_item = is_empty and item
						or generate_visual_item_function(item, self._selected_item, item_type)
					local real_item = not is_empty and item or nil

					-- set rarity of item based on source...
					if item.__master_item and item.__master_item.source then
						local new_rarity = -1
						if item.__master_item.source == 1 then
							new_rarity = 3
						elseif item.__master_item.source == 2 then
							new_rarity = 4
						elseif item.__master_item.source == 3 then
							new_rarity = 5
						elseif is_empty then
							new_rarity = -1
						else
							new_rarity = 2
						end

						visual_item.rarity = new_rarity
						real_item.__master_item.rarity = new_rarity
					end

					layout_count = layout_count + 1
					layout[layout_count] = {
						widget_type = "item_icon",
						is_empty = is_empty,
						item = visual_item,
						real_item = real_item,
						slot = selected_slot,
						achievement = found_achievement,
						penance_track = found_penance_track,
						store = found_store,
						new_item_marker = is_new,
						remove_new_marker_callback = remove_new_marker_callback,
						profile = profile,
						sort_group = is_empty and 0 or 1,
						render_size = {
							256,
							128,
						},
					}
				end
			end
		end

		local has_locked_achievement_item = next(locked_achievement_items_by_name) ~= nil
		local has_locked_penance_track_item = next(locked_penance_track_items_by_name) ~= nil
		local has_locked_store_item = next(locked_store_items_by_name) ~= nil

		-- Commented out default adding of locked items, as I want to handle this myself to include commodores...

		layout_count = layout_count + 1

		layout[layout_count] = {
			sort_group = 4,
			widget_type = "divider",
		}

		--[[

	for _, achievement_item in pairs(locked_achievement_items_by_name) do
		local item = achievement_item.item

		if item then
			local visual_item = generate_visual_item_function(achievement_item.item, self._selected_item, item_type)
			--
			layout_count = layout_count + 1
			layout[layout_count] = {
				locked = true,
				sort_group = 5,
				widget_type = "item_icon",
				item = visual_item,
				real_item = achievement_item.item,
				slot = selected_slot,
				achievement = achievement_item,
				render_size = {
					256,
					128,
				},
			}
		end
	end

	for _, penance_track_item in pairs(locked_penance_track_items_by_name) do
		local item = penance_track_item.item

		if item then
			local visual_item = generate_visual_item_function(penance_track_item.item, self._selected_item, item_type)
			
			layout_count = layout_count + 1
			layout[layout_count] = {
				locked = true,
				sort_group = 5,
				widget_type = "item_icon",
				item = visual_item,
				real_item = penance_track_item.item,
				slot = selected_slot,
				penance_track = penance_track_item,
				render_size = {
					256,
					128,
				},
			}
		end
	end

	for _, store_item in pairs(locked_store_items_by_name) do
		local item = store_item.item

		if item then
			local visual_item = generate_visual_item_function(store_item.item, self._selected_item, item_type)

			layout_count = layout_count + 1
			layout[layout_count] = {
				locked = true,
				sort_group = 5,
				widget_type = "item_icon",
				item = visual_item,
				real_item = store_item.item,
				slot = selected_slot,
				store = store_item.item,
				render_size = {
					256,
					128,
				},
			}
		end
	end
	]]

		--------------------------

		-- Check that the custom item is not already included in the layout and add to the layout...
		for _, custom_item in pairs(custom_items) do
			local continue = true
			local skin_name = ""

			-- set rarity to that of the custom item...
			custom_item.item.rarity = custom_item.real_item.rarity

			if custom_item.real_item and custom_item.real_item.__master_item then
				skin_name = custom_item.real_item.__master_item.display_name
			end

			if custom_item.slot_name ~= slot_name then
				--continue = false
			end

			for _, default_item in pairs(inventory_items) do
				if
					default_item.item
					and default_item.item.__master_item
					and default_item.item.__master_item.display_name == skin_name
				then
					continue = false
				end

				if default_item.item and default_item.item and default_item.item.display_name == skin_name then
					continue = false
				end
			end

			for _, default_item in pairs(penance_track_items) do
				if
					default_item.item
					and default_item.item.__master_item
					and default_item.item.__master_item.display_name == skin_name
				then
					continue = false
				end

				if default_item.item and default_item.item and default_item.item.display_name == skin_name then
					continue = false
				end
			end

			for _, default_item in pairs(store_items) do
				if
					default_item.item
					and default_item.item.__master_item
					and default_item.item.__master_item.display_name == skin_name
				then
					continue = false
				end

				if default_item.item and default_item.item and default_item.item.display_name == skin_name then
					continue = false
				end
			end

			if continue == true then
				local visual_item = generate_visual_item_function(custom_item.item, self._selected_item, item_type)

				layout_count = layout_count + 1
				layout[layout_count] = custom_item
			end
		end

		layout_by_slot[slot_name] = layout

		-------------------------
	end

	self._weapon_cosmetic_layouts_by_slot = layout_by_slot
end

-- Override fetch inventory items to include commodore's items...
InventoryWeaponCosmeticsView._fetch_inventory_items = function(self)
	local local_player_id = 1
	local player = Managers.player:local_player(local_player_id)
	local character_id = player:character_id()
	local selected_item = self._selected_item
	local promises = Promise.resolved({})
	local tabs_content = self._tabs_content

	for i = 1, #tabs_content do
		local tab_content = tabs_content[i]
		local slot_name = tab_content.slot_name
		local item_type = tab_content.item_type
		local get_empty_item_function = tab_content.get_empty_item
		local get_item_filters_function = tab_content.get_item_filters
		local generate_visual_item_function = tab_content.generate_visual_item_function
		local filter_on_weapon_template = tab_content.filter_on_weapon_template
		local slot_filter, item_type_filter

		if get_item_filters_function then
			slot_filter, item_type_filter = get_item_filters_function(slot_name, item_type)
		end

		----------------------------------------------------------------------------------------

		local custom_items = {}
		custom_items["slot_weapon_skin"] = {}
		custom_items["slot_trinket_1"] = {}
		-- Get all weapon cosmetics...
		local weapon_cosmetics = {}
		weapon_cosmetics = mod.get_weapon_cosmetic_items(self)
		local selected_item_slot = "slot_weapon_skin"

		for _, item in pairs(weapon_cosmetics) do
			-- Add locked cosmetics
			local item = _item_plus_overrides(item)

			local valid = true

			if item and self:_item_valid_by_current_pattern(item) then
				if filter_on_weapon_template then
					valid = self:_item_valid_by_current_pattern(item)
				end

				if valid then
					if item.slots and string.find(item.slots[1], "slot_trinket") then
						selected_item_slot = "slot_trinket_1"
					else
						selected_item_slot = "slot_weapon_skin"
					end

					local visual_item
					local continue = true

					local visual_item = generate_visual_item_function(item, selected_item, item_type)

					local gear_id = item.gear_id
					local is_new = self._context
						and self._context.new_items_gear_ids
						and self._context.new_items_gear_ids[gear_id]
					local remove_new_marker_callback

					if is_new then
						remove_new_marker_callback = self._parent and callback(self._parent, "remove_new_item_mark")
					end

					-- Find if item is in store.
					local purchase_offer = mod.get_item_in_current_commodores(self, gear_id, item.name)
					-- if the source isn't "commodores vestures" yet the item is available in store - set the correct source...
					if purchase_offer and item.source ~= 3 then
						item.source = 3
					end

					-- Filter out unknown sources
					if item.source == nil or item.source < 1 then
						continue = false
					end

					-- find if item is on wishlist
					local item_on_wishlist = false
					local widgets_by_name = self._widgets_by_name

					for i, item in pairs(wishlisted_items) do
						if item.name == "previewed_item_name" then
							item_on_wishlist = true
						end
					end

					-- set rarity of item based on source...
					if item.source == 1 then
						item.rarity = 3
					elseif item.source == 2 then
						item.rarity = 4
					elseif item.source == 3 then
						item.rarity = 5
					else
						item.rarity = 2
					end

					if continue then
						table.insert(custom_items[selected_item_slot], {
							widget_type = "item_icon",
							sort_group = 5,
							item = visual_item,
							real_item = item,
							slot_name = selected_item_slot,
							new_item_marker = is_new,
							remove_new_marker_callback = remove_new_marker_callback,
							locked = true,
							slot = selected_item_slot,
							purchase_offer = purchase_offer,
							item_on_wishlist = item_on_wishlist,
							render_size = {
								256,
								128,
							},
							source = item.source,
							offer = purchase_offer,
						})
					end
				end
			end
		end

		----------------------------------------------------------------------------------------

		local slot_promises = {}

		slot_promises[#slot_promises + 1] = self._promise_container
			:cancel_on_destroy(Managers.data_service.gear:fetch_inventory(character_id, slot_filter, item_type_filter))
			:next(function(items)
				if self._destroyed then
					return
				end

				local items_data = {}

				if get_empty_item_function then
					items_data[#items_data + 1] = {
						empty_item = true,
					}
				end

				local equipped_item_name = self:equipped_item_name_in_slot(slot_name)

				for gear_id, item in pairs(items) do
					local item_name = item.name
					local item_equipped = equipped_item_name == item_name

					if item_equipped then
						if slot_name == "slot_weapon_skin" then
							self._equipped_weapon_skin = item
						else
							self._equipped_weapon_trinket = item
						end
					end

					self._inventory_items[#self._inventory_items + 1] = item

					-- remove any purchased items from wishlist on inventory load...
					mod.remove_item_from_wishlist(item_name)

					local valid = true

					if filter_on_weapon_template then
						valid = self:_item_valid_by_current_pattern(item)
					end

					if valid then
						items_data[#items_data + 1] = {
							item = item,
						}
					end
				end

				return Promise.resolved(items_data)
			end)
		slot_promises[#slot_promises + 1] = self._promise_container
			:cancel_on_destroy(Managers.data_service.store:get_credits_weapon_cosmetics_store())
			:next(function(data)
				local offers = data.offers

				return self:_parse_store_items(slot_name, offers, {})
			end)
		slot_promises[#slot_promises + 1] = self._promise_container
			:cancel_on_destroy(Managers.data_service.penance_track:get_track(PENANCE_TRACK_ID))
			:next(function(data)
				local penance_track_items = {}
				local tiers = data and data.tiers

				if tiers then
					for i = 1, #tiers do
						local tier = tiers[i]
						local tier_rewards = tier.rewards

						if tier_rewards then
							for reward_name, reward in pairs(tier_rewards) do
								if reward.type == "item" then
									local reward_item = MasterItems.get_item(reward.id)

									if
										reward_item
										and self:_item_valid_by_current_pattern(reward_item)
										and table.find(reward_item.slots, slot_name)
									then
										local valid = true

										if valid then
											penance_track_items[#penance_track_items + 1] = {
												item = reward_item,
												label = Localize("loc_item_source_penance_track"),
											}
										end
									end
								end
							end
						end
					end
				end

				return Promise.resolved(penance_track_items)
			end)
		promises[i] = Promise.all(unpack(slot_promises)):next(function(items)
			local newitems = {}
			if tab_content.slot_name == "slot_weapon_skin" then
				newitems = custom_items["slot_weapon_skin"]
			elseif tab_content.slot_name == "slot_trinket_1" then
				newitems = custom_items["slot_trinket_1"]
			end

			return {
				items = items[1],
				store_items = items[2],
				penance_track_items = items[3],
				custom = newitems,
			}
		end)
	end

	return Promise.all(unpack(promises)):next(function(items_data)
		self._items_by_slot = {}
		for i = 1, #items_data do
			local tab_content = tabs_content[i]
			local slot_name = tab_content.slot_name
			self._items_by_slot[slot_name] = items_data[i]
		end
	end)
end

-- Grabs all weapon cosmetic trinkets, skins etc.
mod.get_weapon_cosmetic_items = function(self)
	MasterItems.refresh()

	local weapon_cosmetic_items = {}

	local item_definitions = MasterItems.get_cached()

	for item_name, item in pairs(item_definitions) do
		repeat
			local slots = item.slots
			local gearid = item.__gear_id
			if gearid then
				gearid[#gearid + 1] = gearid
			end
			local slot = slots and slots[1]

			if slot == "slot_weapon_skin" or slot == "slot_trinket_1" then
				-- filter out skins for wrong weapon types
				if slot == "slot_weapon_skin" then
					local is_item_stripped = true
					local strip_tags_table = Application.get_strip_tags_table()

					if table.size(item.feature_flags) == 0 then
						is_item_stripped = false
					else
						for _, feature_flag in pairs(item.feature_flags) do
							if strip_tags_table[feature_flag] == true then
								is_item_stripped = false

								break
							end
						end
					end

					if is_item_stripped then
						break
					end

					-- Filter unlocked items
					local locked = true
					for i = 1, #self._inventory_items do
						if item.name == self._inventory_items[i].__master_item.name then
							locked = false
							break
						end
					end

					if locked then
						weapon_cosmetic_items[#weapon_cosmetic_items + 1] = item
					end
				end
				if slot == "slot_trinket_1" then
					weapon_cosmetic_items[#weapon_cosmetic_items + 1] = item
				end
			end
		until true
	end

	return weapon_cosmetic_items
end

-- add my custom functions to the weapons view...
mod:hook_require("scripts/ui/views/inventory_weapon_cosmetics_view/inventory_weapon_cosmetics_view", function(instance)
	instance.cb_on_wishlist_pressed = function(self)
		if not self._previewed_item then
			return
		end

		local item = self._previewed_item
		local widgets_by_name = self._widgets_by_name
		local temp = {}
		local previewed_item_name, previewed_item_dev_name, previewed_item_display_name, previewed_item_gearid
		local already_on_wishlist = false

		-- Check and remove from wishlist
		local function remove_from_wishlist()
			for i, entry in pairs(wishlisted_items or {}) do
				if entry.name == previewed_item_name then
					already_on_wishlist = true
					table.remove(wishlisted_items, i)
					self:_play_sound(UISoundEvents.notification_default_exit)
					widgets_by_name.wishlist_button.style.background_gradient.default_color =
						Color.terminal_background_gradient(nil, true)

					local text = Localize(previewed_item_display_name)
						.. " ("
						.. temp.parent_item
						.. ")"
						.. Localize("loc_VLWC_wishlist_removed")
					Managers.event:trigger("event_add_notification_message", "default", text)
					break
				end
			end
		end

		-- Handle weapon skins
		if item.__master_item then
			local master = item.__master_item
			previewed_item_name = master.name
			previewed_item_dev_name = master.dev_name
			previewed_item_display_name = master.display_name
			previewed_item_gearid = item.__gear_id
			temp.parent_item = Localize(master.display_name)

			remove_from_wishlist()
		end

		-- Handle trinkets
		local trinket_item = item.attachments
			and item.attachments.slot_trinket_1
			and item.attachments.slot_trinket_1.item
		if trinket_item and trinket_item.__master_item then
			local master = trinket_item.__master_item
			previewed_item_name = master.name
			previewed_item_dev_name = master.dev_name
			previewed_item_display_name = master.display_name
			previewed_item_gearid = trinket_item.__gear_id
			temp.parent_item = "Trinket"

			remove_from_wishlist()
		end

		-- Add to wishlist if not already added
		if not already_on_wishlist then
			temp.name = previewed_item_name
			temp.dev_name = previewed_item_dev_name
			temp.gearid = previewed_item_gearid
			temp.display_name = previewed_item_display_name

			wishlisted_items = wishlisted_items or {}
			wishlisted_items[#wishlisted_items + 1] = temp

			self:_play_sound(UISoundEvents.notification_default_enter)
			widgets_by_name.wishlist_button.style.background_gradient.default_color =
				Color.terminal_text_warning_light(nil, true)

			local text = Localize(previewed_item_display_name)
				.. " ("
				.. temp.parent_item
				.. ")"
				.. Localize("loc_VLWC_wishlist_added")
			Managers.event:trigger("event_add_notification_message", "default", text)
		end

		mod.set_wishlist()
		mod.update_wishlist_icons(self)
	end

	instance.cb_on_inspect_pressed = function(self)
		local view_name = "cosmetics_inspect_view"

		local previewed_item = self._previewed_item

		if self._previewed_item.slot_weapon_skin then
			previewed_item = self._previewed_item.slot_weapon_skin.__master_item
		end

		local context

		if previewed_item then
			local item_type = previewed_item.item_type
			local is_weapon = item_type == "WEAPON_MELEE" or item_type == "WEAPON_RANGED"

			if is_weapon or item_type == "GADGET" then
				view_name = "inventory_weapon_details_view"
			end

			local player = self:_player()
			local player_profile = player:profile()
			local include_skin_item_texts = true
			local item = item_type == "WEAPON_SKIN"
					and ItemUtils.weapon_skin_preview_item(previewed_item, include_skin_item_texts)
				or previewed_item
			local is_item_supported_on_played_character = false
			local item_archetypes = item.archetypes

			if item_archetypes and not table.is_empty(item_archetypes) then
				is_item_supported_on_played_character =
					table.array_contains(item_archetypes, player_profile.archetype.name)
			else
				is_item_supported_on_played_character = true
			end

			local profile = is_item_supported_on_played_character and table.clone_instance(player_profile)
				or ItemUtils.create_mannequin_profile_by_item(item)

			context = {
				use_store_appearance = true,
				profile = profile,
				preview_with_gear = is_item_supported_on_played_character,
				preview_item = item,
			}

			if item_type == "WEAPON_SKIN" then
				local slots = item.slots
				local slot_name = slots[1]

				profile.loadout[slot_name] = item

				local archetype = profile.archetype
				local breed_name = archetype.breed
				local breed = Breeds[breed_name]
				local state_machine = breed.inventory_state_machine
				local animation_event = item.inventory_animation_event or "inventory_idle_default"

				context.disable_zoom = true
				context.state_machine = state_machine
				context.animation_event = animation_event
				context.wield_slot = slot_name
			end
		end

		if context and not Managers.ui:view_active(view_name) then
			Managers.ui:open_view(view_name, nil, nil, nil, nil, context)

			self._inpect_view_opened = view_name
		end
	end

	instance.cb_on_weapon_store_pressed = function(self)
		local previewed_item = self._previewed_item
		local presentation_profile = self._presentation_profile
		local presentation_loadout = presentation_profile.loadout
		local preview_profile_equipped = self._preview_profile_equipped_items

		local offer = Selected_purchase_offer
		if offer then
			local player = Managers.player:local_player(1)
			local character_id = player:character_id()
			local archetype_name = player:archetype_name()

			local page_index = 1

			if archetype_name == "veteran" then
				Category_index = 2
			elseif archetype_name == "zealot" then
				Category_index = 3
			elseif archetype_name == "psyker" then
				Category_index = 4
			elseif archetype_name == "ogryn" then
				Category_index = 5
			elseif archetype_name == "adamant" then
				Category_index = 6
			end

			if CCVI then
				CCVI.Category_index = Category_index
			end

			local ui_manager = Managers.ui

			if ui_manager then
				local context = {
					hub_interaction = true,
				}

				ui_manager:open_view("store_view", nil, nil, nil, nil, context)
			end
		end
	end

	instance._register_button_callbacks = function(self)
		local widgets_by_name = self._widgets_by_name
		widgets_by_name.weapon_store_button.content.hotspot.pressed_callback =
			callback(self, "cb_on_weapon_store_pressed")
		local equip_button = widgets_by_name.equip_button

		widgets_by_name.wishlist_button.content.hotspot.pressed_callback = callback(self, "cb_on_wishlist_pressed")

		equip_button.content.hotspot.pressed_callback = callback(self, "cb_on_equip_pressed")
	end

	mod.grab_current_commodores_items = function(self, archetype)
		local player = Managers.player:local_player(1)
		local character_id = player:character_id()
		local archetype_name = player:archetype_name()
		local storefront = "premium_store_featured"

		if archetype == "veteran" or archetype == nil and archetype_name == "veteran" then
			storefront = "premium_store_skins_veteran"
		elseif archetype == "zealot" or archetype == nil and archetype_name == "zealot" then
			storefront = "premium_store_skins_zealot"
		elseif archetype == "psyker" or archetype == nil and archetype_name == "psyker" then
			storefront = "premium_store_skins_psyker"
		elseif archetype == "ogryn" or archetype == nil and archetype_name == "ogryn" then
			storefront = "premium_store_skins_ogryn"
		elseif archetype == "adamant" or archetype == nil and archetype_name == "adamant" then
			storefront = "premium_store_skins_adamant"
		end

		local store_service = Managers.data_service.store

		local _store_promise = store_service:get_premium_store(storefront)

		if not _store_promise then
			return Promise:resolved()
		end

		return _store_promise:next(function(data)
			for i = 1, #data.offers do
				data.offers[i]["layout_config"] = data.layout_config
				table.insert(current_commodores_offers, data.offers[i])
			end
		end)
	end

	instance._setup_sort_options = function(self)
		if not self._sort_options then
			self._sort_options = {}
			self._sort_options[#self._sort_options + 1] = {
				display_name = Localize("loc_inventory_item_grid_sort_title_format_increasing_letters", true, {
					sort_name = Localize("loc_inventory_item_grid_sort_title_name"),
				}),
				sort_function = function(a, b)
					local a_locked, b_locked = a.locked, b.locked

					if not a_locked and b_locked == true then
						return true
					elseif not b_locked and a_locked == true then
						return false
					end

					if
						a.widget_type == "divider" and not b_locked
						or b.widget_type == "divider" and a_locked == true
					then
						return false
					elseif
						a.widget_type == "divider" and b_locked == true
						or b.widget_type == "divider" and not a_locked
					then
						return true
					end

					return ItemUtils.sort_element_key_comparator({
						"<",
						"sort_data",
						ItemUtils.compare_item_name,
					})(a, b)
				end,
			}
			self._sort_options[#self._sort_options + 1] = {
				display_name = Localize("loc_inventory_item_grid_sort_title_format_decreasing_letters", true, {
					sort_name = Localize("loc_inventory_item_grid_sort_title_name"),
				}),
				sort_function = function(a, b)
					local a_locked, b_locked = a.locked, b.locked

					if not a_locked and b_locked == true then
						return true
					elseif not b_locked and a_locked == true then
						return false
					end

					if
						a.widget_type == "divider" and not b_locked
						or b.widget_type == "divider" and a_locked == true
					then
						return false
					elseif
						a.widget_type == "divider" and b_locked == true
						or b.widget_type == "divider" and not a_locked
					then
						return true
					end

					return ItemUtils.sort_element_key_comparator({
						">",
						"sort_data",
						ItemUtils.compare_item_name,
					})(a, b)
				end,
			}
		end

		local sort_callback = callback(self, "cb_on_sort_button_pressed")

		self._item_grid:setup_sort_button(self._sort_options, sort_callback)
	end
end)

-- Grab commodore's offer for selected items... (Used to jump straight to the offer and grab details...)
mod.get_item_in_current_commodores = function(self, gearid, item_name)
	if not current_commodores_offers then
		return
	end

	for i = 1, #current_commodores_offers do
		if current_commodores_offers[i].bundleInfo then
			-- For bundles
			for j = 1, #current_commodores_offers[i].bundleInfo do
				local bundle_item = current_commodores_offers[i].bundleInfo[j]

				if bundle_item.description.id == item_name or bundle_item.description.gearid == gearid then
					return current_commodores_offers[i]
				end
			end
		else
			-- for single items
			if
				current_commodores_offers[i].description.id == item_name
				or current_commodores_offers[i].description.gearid == gearid
			then
				return current_commodores_offers[i]
			end
		end
	end
end
