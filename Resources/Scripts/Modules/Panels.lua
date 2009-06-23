import('GlobalVars') 
import('Scenario')

--displaycontrol
--[[ the following is not related to this file, I just need to stick it elsewhere when done.
controlparams = { -387, -372,	-- left, right (target)
				-32, -49,		-- top, bottom (target)
				-387, -372,		-- left, right (control)
				26, 9 }			-- top, bottom (control)
	-- those are the boundaries of the brackets
--]]
--/displaycontrol

control = scen.planet -- [HARDCODED]
target = nil

menu_shift = -391
top_of_menu = -69
menu_stride = -11

function make_ship(planet, name, race)
	otherShip = NewEntity(planet, name, "Ship", race)
	sound.play("IComboBeep")
end

menu_shipyard = { "BUILD", {} }

function shipyard()
	menu_level = menu_shipyard
	local num = 1
	while scen.planet.build[num] ~= nil do
		menu_shipyard[num + 1] = {}
		local tempvar = 0
		local foo, tempvar = scen.planet.build[num]:gsub("(%w+)/(%w+) (%w+)", "%1/%2 %3")
		print(foo, tempvar)
		if tempvar == 1 then
			menu_shipyard[num + 1][1] = scen.planet.build[num]:gsub("(%w+)/(%w+) (%w+)", "%2 %3")
		else
			menu_shipyard[num + 1][1] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
		end
		if num ~= 1 then
			menu_shipyard[num + 1][2] = false
			-- how do I have it create a ship when all I have is its name in a char?
			-- [ADAM] Answer: store its file name in the char and access its real name through that...
			-- all other attributes will be accessible
		else
			menu_shipyard[num + 1][2] = true
		end
		menu_shipyard[num + 1][3] = make_ship
		menu_shipyard[num + 1][4] = {}
		menu_shipyard[num + 1][4][1] = scen.planet
		if tempvar == 1 then
			menu_shipyard[num + 1][4][2] = scen.planet.build[num]:gsub("(%w+)/(%w+) (%w+)", "%2%3")
			menu_shipyard[num + 1][4][3] = scen.planet.build[num]:gsub("(%w+)/(%w+) (%w+)", "%1")
		else
			menu_shipyard[num + 1][4][2] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
			menu_shipyard[num + 1][4][3] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%1")
		end
		print(menu_shipyard[num + 1][4][3])
		num = num + 1
	end
end

-- Special Orders

function transfer_control()
	error("This command currently has no code.", 1)
	--[[ pseudocode!!! I don't have the concept of allies yet, need that before I can implement this
	if controlShip.ally == true then
		playerShip, controlShip = playerShip, controlShip
	end --]]
end

function hold_position()
	error("This command currently has no code.", 1)
end

function go_to_my_position()
	error("This command currently has no code.", 1)
end

function fire_weapon_1()
	error("This command currently has no code.", 1)
end

function fire_weapon_2()
	error("This command currently has no code.", 1)
end

function fire_special()
	error("This command currently has no code.", 1)
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
			if menu[num][4] ~= nil then
				menu[num][3](menu[num][4][1], menu[num][4][2], menu[num][4][3], menu[num][4][4], menu[num][4][5])
			else
				menu[num][3]()
			end
		end
	end
end

menu_level = menu_options

function draw_panels()
	graphics.set_camera(-400, -300, 400, 300)
	graphics.draw_image("Panels/SideLeft", -346, 0, 109, 607)
	graphics.draw_image("Panels/SideRight", 387, -2, 26, 608)

--[[------------------
	Right Panel
------------------]]--

-- Battery (red)
	graphics.draw_box(107, 379, 29, 386, 0, 0.6, 0.15, 0.15, 1)
	graphics.draw_box(playerShip.battery.percent * 78 + 29, 379, 29, 386, 0, 0.8, 0.4, 0.4, 1)
-- Energy (yellow)
	graphics.draw_box(6, 379, -72.5, 386, 0, 0.6, 0.6, 0.15, 1)
	graphics.draw_box(playerShip.energy.percent * 78.5 - 72.5, 379, -72.5, 386, 0, 0.7, 0.7, 0.4, 1)
-- Shield (blue)
	graphics.draw_box(-96, 379, -173, 386, 0, 0.15, 0.15, 0.6, 1)
	graphics.draw_box(playerShip.shield.percent * 77 - 173, 379, -173, 386, 0, 0.35, 0.35, 0.7, 1)
-- Factory resources (green)
	count = 1
	while count <= 100 do
		if count > resources then
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, 0.2, 0.5, 0.2, 1)
		else
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, 0.4, 0.7, 0.4, 1)
		end
		count = count + 1
	end
-- Factory resource bars (yellow)
	count = 1
	while count <= 7 do
		if count <= resource_bars then
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, 0.7, 0.7, 0.3, 1)
		else
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, 0.5, 0.5, 0.2, 1)
		end
		count = count + 1
	end
-- Factory build bar
	planet = scen.planet
	planet.buildqueue = { factor = 100, current = 0, percent = 0 }
	if planet ~= nil then
		graphics.draw_line(382, 181, 392, 181, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 181, 382, 177, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(392, 177, 392, 181, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 159, 392, 159, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(382, 163, 382, 159, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_line(392, 159, 392, 163, 0.5, 0.7, 0.4, 0.6, 1)
		graphics.draw_box(179, 384, 161, 390, 0, 0.7, 0.4, 0.6, 1)
		graphics.draw_box(18 * planet.buildqueue.percent + 161, 384, 161, 390, 0, 0.8, 0.5, 0.7, 1)
	end
	
--[[------------------
	Left Panel
------------------]]--
	
-- Radar box (green)
	graphics.draw_box(184, -394, 100, -303, 1, 0.0, 0.4, 0.0, 1)
-- Communications panels (green)
	graphics.draw_box(-63, -393, -158, -297, 0, 0.0, 0.4, 0.0, 1)
	graphics.draw_line(-391, -74, -298, -74, 1, 0.4, 0.8, 0.4, 0.5)
	graphics.draw_box(-165, -389.5, -185.5, -304, 0, 0.0, 0.4, 0.0, 1)
-- Menu drawing
	local shift = 1
	local num = 1
	graphics.draw_text(menu_level[1], "CrystalClear", "left", menu_shift, top_of_menu, 13)
	while menu_level[num] ~= nil do
		if menu_level[num][1] ~= nil then
			if menu_level[num][2] == true then
				graphics.draw_box(top_of_menu + menu_stride * shift + 4, -392, top_of_menu + menu_stride * shift - 5, -298, 0, 0.1, 0.5, 0.1, 1)
			end
			graphics.draw_text(menu_level[num][1], "CrystalClear", "left", menu_shift, top_of_menu + menu_stride * shift, 13)
			shift = shift + 1
		end
		num = num + 1
	end
	if text_being_drawn == true then
		graphics.draw_text(scen.text[textnum], "CrystalClear", "center", 0, -250, 30)
	end
-- Weapon (special) ammo count
	graphics.draw_text(string.format('%03d', playerShip.special.ammo), "CrystalClear", "left", -314, 60, 13) -- GREEN
	control = playerShip -- [HARDCODE]
	if control ~= nil then
		graphics.draw_box(49, -392, 40, -297, 0, 0.7, 0.7, 0.4, 1)
		graphics.draw_text("CONTROL", "CrystalClear", "left", -389, 44, 12) -- BLACK
		if control.type == "Planet" then
			graphics.draw_text(control.name, "CrystalClear", "left", -389, 35, 12) -- WHITE
		else
			graphics.draw_text(control.shortName, "CrystalClear", "left", -389, 35, 12) -- WHITE
		end
		if control.ctrlObject ~= nil then
			graphics.draw_text(control.ctrlObject.name, "CrystalClear", "left", -389, 3, 12) -- COLORED RED IF HOSTILE, GREEN IF FRIENDLY
		end
		if control.energy ~= nil then
			graphics.draw_line(-357, 28, -347, 28, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_line(-357, 27, -357, 28, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_line(-347, 27, -347, 28, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_line(-357, 9, -347, 9, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_line(-357, 10, -357, 9, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_line(-347, 10, -347, 9, 0.5, 0.6, 0.6, 0.15, 1)
			graphics.draw_box(27, -356, 10, -348, 0, 0.6, 0.6, 0.15, 1)
			graphics.draw_box(17 * control.energy.percent + 10, -356, 10, -348, 0, 0.7, 0.7, 0.4, 1)
		end
		if control.shield ~= nil then
			graphics.draw_line(-369, 28, -359, 28, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_line(-369, 27, -369, 28, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_line(-359, 27, -359, 28, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_line(-369, 9, -359, 9, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_line(-369, 10, -369, 9, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_line(-359, 10, -359, 9, 0.5, 0.15, 0.15, 0.6, 1)
			graphics.draw_box(27, -367.5, 10, -360, 0, 0.15, 0.15, 0.6, 1)
			graphics.draw_box(17 * control.shield.percent + 10, -367.5, 10, -360, 0, 0.35, 0.35, 0.7, 1)
		end
		if control.type == "Planet" then
			graphics.draw_sprite(control.type .. "s/" .. control.image, -380, 19, 17, 17, 0)
		else
			graphics.draw_sprite(control.image, -380, 19, 17, 17, 3.14 / 2.0)
		end
		graphics.draw_line(-387, 28, -372, 28, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 27, -387, 28, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, 27, -372, 28, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 9, -372, 9, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, 10, -372, 9, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, 10, -387, 9, 0.5, 1.0, 1.0, 1.0, 1)
	end
	if target ~= nil then
		graphics.draw_box(-8, -392, -17, -297, 0, 0.2, 0.2, 0.6, 1)
		graphics.draw_text("TARGET", "CrystalClear", "left", -389, -13, 12) -- BLACK
		graphics.draw_line(-387, -32, -372, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, -34, -372, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -34, -387, -32, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -49, -372, -49, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-372, -47, -372, -49, 0.5, 1.0, 1.0, 1.0, 1)
		graphics.draw_line(-387, -47, -387, -49, 0.5, 1.0, 1.0, 1.0, 1)
	end
	graphics.draw_box(-165.5, -389.5, -175.5, -358, 0, 0.15, 0.15, 0.6, 1)
	graphics.draw_text("RIGHT", "CrystalClear", "left", -388, -170, 13) -- BLUE
	graphics.draw_text("Select", "CrystalClear", "left", -354, -170, 13) -- BLUE
	if menu_level ~= menu_options then
		graphics.draw_box(-175.5, -389.5, -185.5, -358, 0, 0.15, 0.15, 0.6, 1)
		graphics.draw_text("LEFT", "CrystalClear", "left", -388, -180, 13) -- BLUE
		graphics.draw_text("Go Back", "CrystalClear", "left", -354, -180, 13) -- BLUE
	end
end