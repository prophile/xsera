import('Scenario') 

--displaycontrol
--[[ the following is not related to this file, I just needed to stick it elsewhere when done.
controlparams = { -387, -372,	-- left, right (target)
				-32, -49,		-- top, bottom (target)
				-387, -372,		-- left, right (control)
				26, 9 }			-- top, bottom (control)
	-- those are the boundaries of the brackets. Ships draw from the middle, and I can't control the size,
	-- so how is this going to work? I think I'm going to need something in the API to draw this correctly...
--]]
--/displaycontrol

menu_shift = -345
top_of_menu = -69
menu_stride = -11

menu_shipyard = { "BUILD", {} }

function shipyard()
	menu_level = menu_shipyard
	local num = 1
	while scen.planet.build[num] ~= nil do
		menu_shipyard[num + 1] = {}
		menu_shipyard[num + 1][1] = scen.planet.build[num]
		if num ~= 1 then
			menu_shipyard[num + 1][2] = false
			-- how do I have it create a ship when all I have is its name in a char?
		else
			menu_shipyard[num + 1][2] = true
			-- how do I have it create a ship when all I have is its name in a char?
		end
		num = num + 1
	end
end

-- Special Orders

function transfer_control()
	--[[ pseudocode!!! I don't have the concept of allies yet, need that before I can implement this
	if controlShip.ally == true then
		playerShip, controlShip = playerShip, controlShip
	end --]]
end

function hold_position()
	-- AI command, keep for later
end

function go_to_my_position()
	-- maybe I could build simple code for this. Maybe not. I'll do this later
end

function fire_weapon_1()
	-- AI command, keep for later
end

function fire_weapon_2()
	-- AI command, keep for later
end

function fire_special()
	-- AI command, keep for later
end

-- Message menu

text_being_drawn = false
text_was_drawn = false
textnum = 0

function next_page_clear()
	if text_being_drawn == true then
		if scen.text[textnum + 1] ~= nil then
			textnum = textnum + 1
		else
			text_being_drawn = false
			text_was_drawn = true
		end
	else
		text_being_drawn = true
		textnum = textnum + 1
	end
end

function previous_page()
	if text_being_drawn == true then
		if textnum ~= 1 then
			textnum = textnum - 1
		else
			text_being_drawn = false
			textnum = 0
		end
	end
end

function last_message()
	if text_was_drawn == true then
		text_being_drawn = true
	end
end

-----------------------------
---------------------------------
-------------------------------------
---------------------------------
-----------------------------

menu_level = menu_options

function special()
	menu_level = menu_special
end

function messages()
	menu_level = menu_messages
end

function mission_status()
	menu_level = { "BRIEFING",
		{ scen.briefing, false } }
end

menu_special = { "SPECIAL ORDERS",
	{ "Transfer Control", true, transfer_control },
	{ "Hold Position", false, hold_position },
	{ "Go To My Position", false, go_to_my_position },
	{ "Fire Weapon 1", false, fire_weapon_1 },
	{ "Fire Weapon 2", false, fire_weapon_2 },
	{ "Fire Special", false, fire_special }
}

menu_messages = { "MESSAGES",
	{ "Next Page/Clear", true, next_page_clear },
	{ "Previous Page", false, previous_page },
	{ "Last Message", false, last_message }
}

menu_options = { "MAIN MENU",
	{ "<Build>", true, shipyard },
	{ "<Special Orders>", false, special },
	{ "<Messages>", false, messages },
	{ "<Mission Status>", false, mission_status }
}

function change_menu(menu, direction)
	local num = 2
	if direction == "i" then
		if menu[num - 1][2] ~= true then
			while menu[num][2] ~= true do
				num = num + 1
			end
			if num - 1 ~= 1 then
				menu[num][2] = false
				menu[num - 1][2] = true
			end
		end
	elseif direction == "k" then
		num = num - 1
		while menu[num][2] ~= true do
			num = num + 1
		end
		if menu[num + 1] ~= nil then
			menu[num][2] = false
			menu[num + 1][2] = true
		end
	elseif direction == "j" then
		if menu ~= menu_options then
			menu_level = menu_options
		end
	elseif direction == "l" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if menu[num][3] ~= nil then
			menu[num][3]()
		end
	end
end

menu_level = menu_options

function display_menu()
	local shift = 1
	local num = 1
	graphics.draw_text(menu_level[1], "CrystalClear", menu_shift, top_of_menu, 13)
	while menu_level[num] ~= nil do
		if menu_level[num][1] ~= nil then
			if menu_level[num][2] == true then
				graphics.draw_box(top_of_menu + menu_stride * shift + 4, -392, top_of_menu + menu_stride * shift - 5, -298, 0, 0.1, 0.5, 0.1, 1)
			end
			graphics.draw_text(menu_level[num][1], "CrystalClear", menu_shift, top_of_menu + menu_stride * shift, 13)
			shift = shift + 1
		end
		num = num + 1
	end
	if text_being_drawn == true then
		graphics.draw_text(scen.text[textnum], "CrystalClear", 0, -250, 30)
	end
end