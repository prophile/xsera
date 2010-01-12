import('EntityLoad')
import('BoxDrawing')

loadingEntities = true
if scen == nil then
	scen = NewEntity(nil, "demo", "Scenario")
end
loadingEntities = false

control = scen.planet -- [HARDCODED]
target = nil

menuShift = -391
topOfMenu = -69
menuStride = -11
shipSelected = false
menuShipyard = { "BUILD", {} }

function MakeShip()
	shipBuilding = { p = shipQuerying.p, n = shipQuerying.n, r = shipQuerying.r, c = shipQuerying.c, t = shipQuerying.t }
	if shipBuilding.c > cash or scen.planet.buildqueue.percent ~= 100 then
		sound.play("NaughtyBeep")
		return
	end
	scen.planet.buildqueue.factor = shipBuilding.t
	scen.planet.buildqueue.time = mode_manager.time()
	scen.planet.buildqueue.current = mode_manager.time() - scen.planet.buildqueue.time
	cash = cash - shipBuilding.c
	buildTimerRunning = true
end

function Shipyard()
	menuLevel = menuShipyard
	local num = 1
	while scen.planet.build[num] ~= nil do
		menuShipyard[num + 1] = {}
		menuShipyard[num + 1][1] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
		if num ~= 1 then
			menuShipyard[num + 1][2] = false
		else
			menuShipyard[num + 1][2] = true
			shipSelected = true
			shipQuerying.p = scen.planet
			shipQuerying.n = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
			shipQuerying.r = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%1")
			shipQuerying.c = scen.planet.buildCost[num]
			shipQuerying.t = scen.planet.buildTime[num]
		end
		menuShipyard[num + 1][3] = MakeShip
		menuShipyard[num + 1][4] = {}
		menuShipyard[num + 1][4][1] = scen.planet
		menuShipyard[num + 1][4][2] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%2")
		menuShipyard[num + 1][4][3] = scen.planet.build[num]:gsub("(%w+)/(%w+)", "%1")
		num = num + 1
	end
	shipSelected = true
end

menuSpecial = { "SPECIAL ORDERS",
	{ "Transfer Control", true, DoTransferControl },
	{ "Hold Position", false, nil },
	{ "Go To My Position", false, nil },
	{ "Fire Weapon 1", false, nil },
	{ "Fire Weapon 2", false, nil },
	{ "Fire Special", false, nil }
}

function Special()
	menuLevel = menuSpecial
end

menuMessages = { "MESSAGES",
	{ "Next Page/Clear", true, DoMessageNext },
	{ "Previous Page", false, nil },
	{ "Last Message", false, nil }
}

function Messages()
	menuLevel = menuMessages
end

function MissionStatus()
	menuLevel = { "MISSION STATUS",
		{ scen.briefing, false } }
end

menuOptions = { "MAIN MENU",
	{ "<Build>", true, Shipyard },
	{ "<Special Orders>", false, Special },
	{ "<Messages>", false, Messages },
	{ "<Mission Status>", false, MissionStatus }
}
menuLevel = menuOptions

function InterfaceDisplay(dt)
	if menu_display ~= nil then
		if menu_display == "esc_menu" then
			DrawEscapeMenu()
		elseif menu_display == "defeat_menu" then
			DrawDefeatMenu()
		elseif menu_display == "info_menu" then
			DrawInfoMenu()
		elseif menu_display == "victory_menu" then
			DrawVictoryMenu()
		elseif menu_display == "pause_menu" then
			DrawPauseMenu(dt)
		end
	end
end

function DrawEscapeMenu()
	SwitchBox( { top = 85, left = -140, bottom = -60, right = 140, boxColour = ClutColour(10, 8) } )
	graphics.draw_text("Resume, start chapter over, or quit?", "CrystalClear", "left", { x = -125, y = 65 }, 16)
	if down.esc == true then
		SwitchBox( { xCoord = -125, yCoord = 30, length = 250, text = "Resume", boxColour = ClutLighten(ClutColour(12, 6), 1), textColour = ClutColour(12, 6), execute = nil, letter = "ESC" } )
	elseif down.esc == "act" then
		keyup = normal_keyup
		key = normal_key
		down.esc = false
		menu_display = nil
	else
		SwitchBox( { xCoord = -125, yCoord = 30, length = 250, text = "Resume", boxColour = ClutColour(12, 6), textColour = ClutColour(12, 6), execute = nil, letter = "ESC" } )
	end
	if down.rtrn == true then
		SwitchBox( { xCoord = -125, yCoord = 0, length = 250, text = "Start Chapter Over", boxColour = ClutLighten(ClutColour(9, 6)), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
	elseif down.rtrn == "act" then
		mode_manager.switch('Demo3')
		down.rtrn = false
	else
		SwitchBox( { xCoord = -125, yCoord = 0, length = 250, text = "Start Chapter Over", boxColour = ClutColour(9, 6), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
	end
	if down.q == true then
		SwitchBox( { xCoord = -125, yCoord = -30, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 4), textColour = ClutColour(8, 17), execute = nil, letter = "Q" } )
	elseif down.q == "act" then
		menu_display = nil
		mode_manager.switch('MainMenu')
	else
		SwitchBox( { xCoord = -125, yCoord = -30, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 5), textColour = ClutColour(8, 5), execute = nil, letter = "Q" } )
	end
end

function DrawDefeatMenu()
	SwitchBox( { top = 85, left = -140, bottom = -60, right = 140, boxColour = ClutColour(16, 6) } )
	graphics.draw_text("You lost your Heavy Cruiser and failed.", "CrystalClear", "left", { x = -125, y = 26 }, 16)
	graphics.draw_text("Start chapter over, or quit?", "CrystalClear", "left", { x = -125, y = 10 }, 16)
	if down.rtrn == true then
		SwitchBox( { xCoord = -125, yCoord = -20, length = 250, text = "Start Chapter Over", boxColour = ClutLighten(ClutColour(9, 6), 1), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
	elseif down.rtrn == "act" then
		menu_display = nil
		mode_manager.switch('Demo3')
	else
		SwitchBox( { xCoord = -125, yCoord = -20, length = 250, text = "Start Chapter Over", boxColour = ClutColour(9, 6), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
	end
	if down.q == true then
		SwitchBox( { xCoord = -125, yCoord = -50, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 5), textColour = ClutColour(8, 17), execute = nil, letter = "Q" } )
	elseif down.q == "act" then
		menu_display = nil
		mode_manager.switch('MainMenu')
	else
		SwitchBox( { xCoord = -125, yCoord = -50, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 4), textColour = ClutColour(8, 1), execute = nil, letter = "Q" } )
	end
end

storedTime = 0.0

function DrawVictoryMenu()
	SwitchBox( { xCoord = -125, yCoord = 100, length = 290, text = " ", boxColour = ClutColour(3, 7), textColour = ClutColour(3, 7), execute = nil, letter = "Results", underbox = -100 } )
	graphics.draw_text("You did it! Congratulations!", "CrystalClear", "left", { x = -110, y = 90 }, 16)
	SwitchBox( { top = 31, left = -75, bottom = -50, right = 115, boxColour = ClutColour(3, 7), background = ClutColour(3, 14) } )
	local startx = 113
	local starty = 28
	local xcheck = 1
	local ycheck = 1
	local xshift = 0
	local xlength = 0
	while endGameData[ycheck] ~= nil do
		local xcheck = 1
		while endGameData[ycheck][xcheck] ~= nil do
			if xcheck == 1 then
				xCoord = 121
				xlength = 64
			else
				xCoord = 60 * (3 - xcheck) + 1
				xlength = 60
			end
			if endGameData[ycheck][xcheck][1] == true then
				if endGameData[ycheck][xcheck][2] ~= cClear then
					graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength, starty - ycheck * 15, startx - xCoord, 0, endGameData[ycheck][xcheck][2])
					graphics.draw_text(endGameData[ycheck][xcheck][3], "CrystalClear", "left", { x = startx - xCoord - xlength + 2, y = starty - (ycheck - 1) * 15 - 6 }, 16)
				else
					graphics.draw_text(endGameData[ycheck][xcheck][3], "CrystalClear", "left", { x = startx - xCoord - xlength + 2, y = starty - (ycheck - 1) * 15 - 6 }, 16)
				end
			else
				storedTime = storedTime + dt
				if storedTime >= 0.07 then
					storedTime = storedTime - 0.07
					if endGameData[ycheck][xcheck][1] == "inprogress" then
						if position == nil then
							position = 1
						end
						if position == 1 then
							graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength / 2 - 5, starty - ycheck * 15, startx - xCoord - xlength / 2 + 5, 0, ClutColour(3, 7))
							position = 2
						elseif position == 2 then
							graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - 10, starty - ycheck * 15, startx - xCoord, 0, ClutColour(3, 7))
							endGameData[ycheck][xcheck][1] = true
							position = nil
						end
						sound.play("ITeletype")
					elseif endGameData[ycheck][xcheck][1] == false then
						endGameData[ycheck][xcheck][1] = "inprogress"
						sound.play("ITeletype")
						graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength, starty - ycheck * 15, startx - xCoord - xlength + 10, 0, ClutColour(3, 7))
					end
				end
				ycheck = 5
				xcheck = 4
			end
			xcheck = xcheck + 1
		end
		ycheck = ycheck + 1
	end
end

function DrawInfoMenu()
	SwitchBox( { top = 250, left = -260, bottom = -250, right = 280, boxColour = ClutColour(1, 8) } )
	if down.esc == true then
		SwitchBox( { xCoord = -255, yCoord = -240, length = 530, text = "Done", boxColour = ClutLighten(ClutColour(1, 8)), textColour = ClutColour(1, 8), execute = nil, letter = "ESC" } )
	elseif down.esc == "act" then
		keyup = normal_keyup
		key = normal_key
		down.esc = false
		menu_display = nil
		return
	else
		SwitchBox( { xCoord = -255, yCoord = -240, length = 530, text = "Done", boxColour = ClutColour(1, 8), textColour = ClutColour(1, 8), execute = nil, letter = "ESC" } )
	end
	local x = 245
	local col_switch = true
	while x - 15 >= -188 do
		if col_switch == false then
			col_switch = true
			graphics.draw_box(x, -257, x - 15, 277, 0, ClutColour(16, 11))
		else
			col_switch = false
			graphics.draw_box(x, -257, x - 15, 277, 0, ClutColour(16, 12))
		end
		graphics.draw_box(x, -257, x - 15, -217, 0, ClutColour(16, 1))
		graphics.draw_box(x, 5, x - 15, 45, 0, ClutColour(16, 1))
		x = x - 15
	end
	local num = 1
	local line_num = 1
	while keyboard[num] ~= nil do
		local subnum = 1
		graphics.draw_box(line_num * -15 + 260, -257, line_num * -15 + 245, 277, 0, ClutColour(1, 8))
		graphics.draw_text(keyboard[num][1], "CrystalClear", "left", { x = -252, y = line_num * -15 + 253 }, 16)
		line_num = line_num + 1
		local xCoord = 0
		local yShift = 0
		local adjust = 0
		local numBoxes = 1
		while keyboard[num][numBoxes] ~= nil do
			numBoxes = numBoxes + 1
		end
		local rows = math.ceil(numBoxes / 2)
		while keyboard[num][subnum + 1] ~= nil do
			if subnum % rows ~= subnum then
				xCoord = 50
				adjust = (rows - 1) * 15
			else
				adjust = 0
				xCoord = -212
			end
			graphics.draw_text(keyboard[num][subnum + 1].name, "CrystalClear", "left", { x = xCoord, y = line_num * -15 + 254 + adjust }, 16)
			if keyboard[num][subnum + 1].key_display == nil then
				graphics.draw_text(keyboard[num][subnum + 1].key, "CrystalClear", "center", { x = xCoord - 24, y = line_num * -15 + 254 + adjust }, 16)
			else
				graphics.draw_text(keyboard[num][subnum + 1].key_display, "CrystalClear", "center", { x = xCoord - 24, y = line_num * -15 + 254 + adjust }, 16)
			end
			line_num = line_num + 1
			subnum = subnum + 1
		end
		if numBoxes % 2 == 0 then
			line_num = line_num - rows + 1
		else
			line_num = line_num - rows + 2
		end
		num = num + 1
	end
end

local timeElapsed = 0

function DrawPauseMenu(dt)
	if down.o == true then
		menu_display = nil
		return
	end
	timeElapsed = timeElapsed + dt
	if timeElapsed % 0.8 > 0.4 then
		SwitchBox( { top = 20, left = -80, bottom = -20, right = 140, boxColour = ClutColour(5, 11), background = c_half_clear } )
		graphics.draw_text("> CAPS LOCK - PAUSED <", "CrystalClear", "center", { x = 30, y = 0 }, 23, ClutColour(5, 11))
	end
end

radar = { top = 184, left = -394, bottom = 100, right = -303, width = 91, length = 84 }

function DrawRadar()
	graphics.draw_box(radar.top, radar.left, radar.bottom, radar.right, 0, ClutColour(5, 13)) -- background (dark green)
	if cameraRatioNum >= 5 then
		graphics.draw_box(radar.top, radar.left, radar.bottom, radar.right, 1, ClutColour(5, 11)) -- foreground (light green with edge)
	else
		boxSize = (cameraRatio * 8 - 1) / cameraRatio / 16
		graphics.draw_box(radar.top - radar.length * boxSize, radar.left + radar.width * boxSize, radar.bottom + radar.length * boxSize, radar.right - radar.width * boxSize, 0, ClutColour(5, 11))
	end
	
	--[[ pseudo-code: (will need to plug in to GameFreak's Demo4.lua)
	
	for all the ships
		if the ship is in range of radar
			put a dot where it is on the radar (proportionally) -- how do I draw a dot? (need new C++ function?)
		end
	end
	
	--]]
end

menuLevel = menuOptions

function DrawPanels()
	graphics.set_camera(-400, -300, 400, 300)
	graphics.draw_image("Panels/SideLeft", { x = -346, y = 0 }, { x = 109, y = 607 })
	graphics.draw_image("Panels/SideRight", { x = 387, y = -2 }, { x = 26, y = 608 })

--[[------------------
	Right Panel
------------------]]--

-- Battery (red)
	graphics.draw_box(107, 379, 29, 386, 0, ClutColour(8, 8))
--	graphics.draw_box(playerShip.battery.percent * 78 + 29, 379, 29, 386, 0, ClutColour(8, 5)) -- #TEST these commented lines should be fixed and uncommented
-- Energy (yellow)
	graphics.draw_box(6, 379, -72.5, 386, 0, ClutColour(3, 7))
--	graphics.draw_box(playerShip.energy.percent * 78.5 - 72.5, 379, -72.5, 386, 0, ClutColour(9, 6))
-- Shield (blue)
	graphics.draw_box(-96, 379, -173, 386, 0, ClutColour(14, 8))
--	graphics.draw_box(playerShip.shield.percent * 77 - 173, 379, -173, 386, 0, ClutColour(14, 6))
-- Factory resources (green - mostly)
	count = 1
	if shipSelected == true then
		if cash >= shipQuerying.c then
			local drawGreen = math.floor((cash - shipQuerying.c) / 200)
			local drawBlue = math.ceil((shipQuerying.c) / 200) + drawGreen
		--	print(count, "=>", drawGreen, "-[", ((cash - shipQuerying.c) / 200), "]-")
			while count <= drawGreen do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(12, 3))
				count = count + 1
			end
		--	print(count, drawGreen, drawBlue)
			while count <= drawBlue do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(14, 5))
				count = count + 1
			end
		--	print(count, drawBlue)
		else
			local drawGreen = math.floor(cash / 200)
			local drawRed = math.ceil(shipQuerying.c / 200)
		--	print(count, "=>", drawGreen, "-[", (cash / 200), "]-")
			while count <= drawGreen do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(12, 3))
				count = count + 1
			end
		--	print(count, drawGreen, drawRed)
			while count <= drawRed do
				graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(2, 9))
				count = count + 1
			end
		--	print(count, drawRed)
		end
	end
	while count <= 100 do
		if count > resources then
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(12, 14))
		else
			graphics.draw_box(152 - 3.15 * count, 394, 150 - 3.15 * count, 397, 0, ClutColour(12, 3))
		end
		count = count + 1
	end
-- Factory resource bars (yellow)
	count = 1
	while count <= 7 do
		if count <= resourceBars then
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, ClutColour(3, 3))
		else
			graphics.draw_box(154.5 - 4.5 * count, 384, 151 - 4.5 * count, 392, 0, ClutColour(9, 13))
		end
		count = count + 1
	end
-- Factory build bar (purple)
	planet = scen.planet
	if planet ~= nil then
		graphics.draw_line({ x = 382, y = 181 }, { x = 392, y = 181 }, 0.5, ClutColour(13, 9))
		graphics.draw_line({ x = 382, y = 181 }, { x = 382, y = 177 }, 0.5, ClutColour(13, 9))
		graphics.draw_line({ x = 392, y = 177 }, { x = 392, y = 181 }, 0.5, ClutColour(13, 9))
		graphics.draw_line({ x = 382, y = 159 }, { x = 392, y = 159 }, 0.5, ClutColour(13, 9))
		graphics.draw_line({ x = 382, y = 163 }, { x = 382, y = 159 }, 0.5, ClutColour(13, 9))
		graphics.draw_line({ x = 392, y = 159 }, { x = 392, y = 163 }, 0.5, ClutColour(13, 9))
		graphics.draw_box(179, 384, 161, 390, 0, ClutColour(13, 9))
		graphics.draw_box(18 * (100 - planet.buildqueue.percent) / 100 + 161, 384, 161, 390, 0, ClutColour(13, 5))
	end
	
--[[------------------
	Left Panel
------------------]]--
	
-- Radar box (green)
	DrawRadar()
-- Communications panels (green)
	graphics.draw_box(-63, -393, -158, -297, 0, ClutColour(5, 11))
	graphics.draw_line({ x = -391, y = -74 }, { x = -298, y = -74 }, 1, ClutColour(12, 3))
	graphics.draw_box(-165, -389.5, -185.5, -304, 0, ClutColour(5, 11))
-- Menu drawing
	local shift = 1
	local num = 1
	graphics.draw_text(menuLevel[1], "CrystalClear", "left", { x = menuShift, y = topOfMenu }, 13)
	while menuLevel[num] ~= nil do
		if menuLevel[num][1] ~= nil then
			if menuLevel[num][2] == true then
				graphics.draw_box(topOfMenu + menuStride * shift + 4, -392, topOfMenu + menuStride * shift - 5, -298, 0, ClutColour(12, 10))
			end
			graphics.draw_text(menuLevel[num][1], "CrystalClear", "left", { x = menuShift, y = topOfMenu + menuStride * shift }, 13)
			shift = shift + 1
		end
		num = num + 1
	end
	if text_being_drawn == true then
		graphics.draw_text(scen.text[textnum], "CrystalClear", "center", { x = 0, y = -250 }, 30)
	end
	
-- Weapon ammo count
--OFFSET = 32 PIXELS
	if scen.playerShip.weapon ~= nil then
		if scen.playerShip.weapon.pulse ~= nil and scen.playerShip.weapon.pulse.ammo ~= -1 then
			graphics.draw_text(string.format('%03d', scen.playerShip.weapon.pulse.ammo), "CrystalClear", "left", { x = -376, y = 60 }, 13, ClutColour(5, 1))
		end
		
		if scen.playerShip.weapon.beam ~= nil and scen.playerShip.weapon.beam.ammo ~= -1 then
			graphics.draw_text(string.format('%03d', scen.playerShip.weapon.beam.ammo), "CrystalClear", "left", { x = -345, y = 60 }, 13, ClutColour(5, 1))
		end
		
		if scen.playerShip.weapon.special ~= nil and scen.playerShip.weapon.special.ammo ~= -1 then
			graphics.draw_text(string.format('%03d', scen.playerShip.weapon.special.ammo), "CrystalClear", "left", { x = -314, y = 60 }, 13, ClutColour(5, 1))
		end
	end
	control = scen.playerShip -- [HARDCODE]
	if control ~= nil then
		graphics.draw_box(49, -392, 40, -297, 0, ClutColour(9, 6))
		graphics.draw_text("CONTROL", "CrystalClear", "left", { x = -389, y = 44 }, 12, ClutColour(1, 17))
		if control.type == "Planet" then
			graphics.draw_text(control.name, "CrystalClear", "left", { x = -389, y = 35 }, 12)
		else
			graphics.draw_text(control["short-name"], "CrystalClear", "left", { x = -389, y = 35 }, 12)
		end
		if control.ctrlObject ~= nil then
			if control.owner == "Human/Ishiman" then
				graphics.draw_text(control.ctrlObject.name, "CrystalClear", "left", { x = -389, y = 3 }, 12, ClutColour(5, 11))
			else
				graphics.draw_text(control.ctrlObject.name, "CrystalClear", "left", { x = -389, y = 3 }, 12, ClutColour(16, 1))
			end
		end
		if control.energy ~= nil then
			graphics.draw_line({ x = -357, y = 28 }, { x = -347, y = 28 }, 0.5, ClutColour(3, 7))
			graphics.draw_line({ x = -357, y = 27 }, { x = -357, y = 28 }, 0.5, ClutColour(3, 7))
			graphics.draw_line({ x = -347, y = 27 }, { x = -347, y = 28 }, 0.5, ClutColour(3, 7))
			graphics.draw_line({ x = -357, y = 9 }, { x = -347, y = 9 }, 0.5, ClutColour(3, 7))
			graphics.draw_line({ x = -357, y = 10 }, { x = -357, y = 9 }, 0.5, ClutColour(3, 7))
			graphics.draw_line({ x = -347, y = 10 }, { x = -347, y = 9 }, 0.5, ClutColour(3, 7))
			graphics.draw_box(27, -356, 10, -348, 0, ClutColour(3, 7))
			graphics.draw_box(17 * control.energy.percent + 10, -356, 10, -348, 0, ClutColour(9, 6))
		end
		if control.shield ~= nil then
			graphics.draw_line({ x = -369, y = 28 }, { x = -359, y = 28 }, 0.5, ClutColour(4, 8))
			graphics.draw_line({ x = -369, y = 27 }, { x = -369, y = 28 }, 0.5, ClutColour(4, 8))
			graphics.draw_line({ x = -359, y = 27 }, { x = -359, y = 28 }, 0.5, ClutColour(4, 8))
			graphics.draw_line({ x = -369, y = 9 }, { x = -359, y = 9 }, 0.5, ClutColour(4, 8))
			graphics.draw_line({ x = -369, y = 10 }, { x = -369, y = 9 }, 0.5, ClutColour(4, 8))
			graphics.draw_line({ x = -359, y = 10 }, { x = -359, y = 9 }, 0.5, ClutColour(4, 8))
			graphics.draw_box(27, -367.5, 10, -360, 0, ClutColour(4, 8))
			graphics.draw_box(17 * control.shield.percent + 10, -367.5, 10, -360, 0, ClutColour(4, 6))
		end
		if control.type == "Planet" then
			graphics.draw_sprite(control.type .. "s/" .. control.image, { x = -380, y = 19 }, { x = 17, y = 17 }, 0)
		else
			graphics.draw_sprite("Id/" .. control.sprite, { x = -380, y = 19 }, { x = 17, y = 17 }, 3.14 / 2.0)
		end
		graphics.draw_line({ x = -387, y = 28 }, { x = -372, y = 28 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = 27 }, { x = -387, y = 28 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -372, y = 27 }, { x = -372, y = 28 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = 9 }, { x = -372, y = 9 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -372, y = 10 }, { x = -372, y = 9 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = 10 }, { x = -387, y = 9 }, 0.5, ClutColour(1, 1))
	end
	if target ~= nil then
		graphics.draw_box({ x = -8, y = -392 }, { x = -17, y = -297 }, 0, ClutColour(4, 7))
		graphics.draw_text("TARGET", "CrystalClear", "left", { x = -389, y = -13 } , 12, ClutColour(1, 17))
		graphics.draw_line({ x = -387, y = -32 }, { x = -372, y = -32 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -372, y = -34 }, { x = -372, y = -32 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = -34 }, { x = -387, y = -32 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = -49 }, { x = -372, y = -49 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -372, y = -47 }, { x = -372, y = -49 }, 0.5, ClutColour(1, 1))
		graphics.draw_line({ x = -387, y = -47 }, { x = -387, y = -49 }, 0.5, ClutColour(1, 1))
	end
	graphics.draw_box(-165.5, -389.5, -175.5, -358, 0, ClutColour(4, 8))
	graphics.draw_text("RIGHT", "CrystalClear", "left", { x = -388, y = -170 }, 13, ClutColour(4, 6))
	graphics.draw_text("Select", "CrystalClear", "left", { x = -354, y = -170 }, 13, ClutColour(4, 6))
	if menuLevel ~= menuOptions then
		graphics.draw_box(-175.5, -389.5, -185.5, -358, 0, ClutColour(4, 8))
		graphics.draw_text("LEFT", "CrystalClear", "left", { x = -388, y = -180 }, 13, ClutColour(4, 6))
		graphics.draw_text("Go Back", "CrystalClear", "left", { x = -354, y = -180 }, 13, ClutColour(4, 6))
	end
end

function change_menu(menu, direction)
	local num = 2
	if direction == "i" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if num ~= 2 then
			menu[num][2] = false
			num = num - 1
			menu[num][2] = true
			if menu == menuShipyard then
				shipQuerying.p = menuShipyard[num][4][1]
				shipQuerying.n = menuShipyard[num][4][2]
				shipQuerying.r = menuShipyard[num][4][3]
				shipQuerying.c = scen.planet.buildCost[num - 1]
				shipQuerying.t = scen.planet.buildTime[num - 1]
			end
		end
	elseif direction == "k" then
		while menu[num][2] ~= true do
			num = num + 1
		end
		if menu[num + 1] ~= nil then
			menu[num][2] = false
			num = num + 1
			menu[num][2] = true
			if menu == menuShipyard then
				shipQuerying.p = menuShipyard[num][4][1]
				shipQuerying.n = menuShipyard[num][4][2]
				shipQuerying.r = menuShipyard[num][4][3]
				shipQuerying.c = scen.planet.buildCost[num - 1]
				shipQuerying.t = scen.planet.buildTime[num - 1]
			end
		end
	elseif direction == "j" then
		if menu ~= menuOptions then
			menuLevel = menuOptions
			shipSelected = false
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


function DrawArrow()
	local angle = scen.playerShip.physics.angle
	local pos = scen.playerShip.physics.position
	local c1 = {
		x = math.cos(arrowAlpha + angle) * arrowDist + pos.x,
		y = math.sin(arrowAlpha + angle) * arrowDist + pos.y
	}
	local c2 = {
		x = math.cos(angle - arrowAlpha) * arrowDist + pos.x,
		y = math.sin(angle - arrowAlpha) * arrowDist + pos.y
	}
	local c3 = {
		x = math.cos(angle) * (arrowLength + arrowVar) + pos.x,
		y = math.sin(angle) * (arrowLength + arrowVar) + pos.y
	}
	graphics.draw_line(c1, c2, 1.5, ClutColour(5, 1))
	graphics.draw_line(c2, c3, 1.5, ClutColour(5, 1))
	graphics.draw_line(c3, c1, 1.5, ClutColour(5, 1))
end