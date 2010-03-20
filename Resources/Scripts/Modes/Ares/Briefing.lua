import('GlobalVars')
import('Console')
import('BoxDrawing')

freezeMenuNum = 0
doLevelSwitch = true
background1 = {	{ xCoord = -280, yCoord = 140, length = 560, text = " ", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = nil, letter = "Select Level", underbox = -145 },
				{ xCoord = -260, yCoord = -205, length = 150, text = "Cancel", boxColour = ClutColour(3, 6), textColour = ClutColour(13, 9), execute = nil, letter = "ESC" },
				{ xCoord = 110, yCoord = -205, length = 150, text = "Begin", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = nil, letter = "RTRN" },
				{ xCoord = -260, yCoord = -105, length = 150, text = "Previous", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = nil, letter = "LEFT" },
				{ xCoord = 110, yCoord = -105, length = 150, text = "Next", boxColour = ClutColour(10, 8), textColour = ClutColour(13, 9), execute = nil, letter = "RGHT", special = "disabled" } }

background2 = { { xCoord = -280, yCoord = 175, length = 560, text = " ", boxColour = ClutColour(1, 8), textColour = ClutColour(1, 8), execute = nil, letter = "Mission Analysis", underbox = -200 },
				{ xCoord = -280, yCoord = -225, length = 170, text = "Previous", boxColour = ClutColour(1, 8), textColour = ClutColour(1, 8), execute = nil, letter = "LEFT" },
				{ xCoord = -100, yCoord = -225, length = 170, text = "Next", boxColour = ClutColour(1, 8), textColour = ClutColour(1, 8), execute = nil, letter = "RGHT" },
				{ xCoord = 110, yCoord = -225, length = 170, text = "Done", boxColour = ClutColour(12, 6), textColour = ClutColour(12, 6), execute = nil, letter = "RTRN" } }

scenLevels = { { title = "DEMO 4", subtitle = "The Second Technical Demo", desc = "In this demo, you must destroy the Gaitori Carrier prior to taking over a nearby planet with an Ishiman Transport.", unlocked = true, mode = "Demo4" },
			{ title = "TUTORIAL LESSON 1", subtitle = "Moons for Goons", desc = "Learning the Ares interface", unlocked = true },
			{ title = "CHAPTER 1", subtitle = "Easy Street", desc = "Destroy all 5 Gaitori Transports.", unlocked = true },
			{ title = "CHAPTER 6", subtitle = "...Into the Fire", desc = "Capture the planet Hades Beta while destroying as many Gaitori power stations as possible and saving as many of the Obish stations as you can.", unlocked = true } }

-- scenBriefing is hardcoded to work only with Demo3, in the future it will load whatever scenario data that I need
scenBriefing = { planet = vec(0, 0),
	screen = { { { sprite = "Ships/Ishiman/HeavyCruiser", x = 0, y = 0, size = 0.2 },
				{ sprite = "Planets/Saturny", x = 2500, y = 2500, size = 0.3 },
				{ sprite = "Planets/AnotherEarth", x = 100, y = 100, size = 0.3 },
				{ sprite = "Ships/Gaitori/Carrier", x = 2200, y = 2700, size = 0.2 } },
				{ xCoord = -220, yCoord = 100, length = 220, text = " ", boxColour = ClutColour(3, 7), textColour = ClutColour(3, 7), execute = nil, letter = "Xsera System", underbox = -100, uboxText = "Land a transport here.", sidecar = { x = 60, y = 130, size = { x = 23, y = 23 } }, special = "sidecar" }

				} }
-- the above is [TEMPORARY] - scenLevels will be replaced by scen.levels and scenBriefing will be replaced by scen.briefing
menuNum = 1
screenNum = 1

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
end

function update()
	if menuNum == 1 then
		ChangeSpecial("LEFT", "disabled", background1)
		ChangeSpecial("LEFT", "disabled", background2)
	else
		ChangeSpecial("LEFT", nil, background1)
		ChangeSpecial("LEFT", nil, background2)
	end
	if doLevelSwitch == true then
		if scenLevels[menuNum + 1] ~= nil then
			if scenLevels[menuNum + 1].unlocked == true then
				ChangeSpecial("RGHT", nil, background1)
			end
		else
			ChangeSpecial("RGHT", "disabled", background1)
		end
	else
		if scenBriefing.screen[menuNum] ~= nil then
			ChangeSpecial("RGHT", nil, background2)
		else
			ChangeSpecial("RGHT", "disabled", background2)
		end
	end
	while background1[num] ~= nil do
		if background1[num].special == "click" then
			background1[num].special = nil
		end
		num = num + 1
	end
	while background2[num] ~= nil do
		if background2[num].special == "click" then
			background2[num].special = nil
		end
		num = num + 1
	end
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", { x = 0, y = 210 }, { x = 572, y = 28 })
	graphics.draw_image("Panels/PanelBottom", { x = 0, y = -242 }, { x = 572, y = 20 })
	graphics.draw_image("Panels/PanelLeft", { x = -302, y = -14 }, { x = 33, y = 476 })
	graphics.draw_image("Panels/PanelRight", { x = 303, y = -14 }, { x = 35, y = 476 })
	local num = 1
	-- Screen Info
	if doLevelSwitch == true then
	-- When we load the scenario data, change all instances of "scenLevels" to "scen.levels"
		while background1[num] ~= nil do
			SwitchBox(background1[num])
			num = num + 1
		end
		SwitchBox( { top = 120, left = -260, bottom = -55, right = 260, boxColour = ClutColour(10, 8), title = scenLevels[menuNum].title, subtitle = scenLevels[menuNum].subtitle, desc = scenLevels[menuNum].desc } )
	else
	-- When we load the scenario data, change all instances of "scenBriefing" to "scen.briefing"
		while background2[num] ~= nil do
			SwitchBox(background2[num])
			num = num + 1
		end
		if menuNum == 1 then
			graphics.draw_image("Scenario/Misc/Starmap", { x = 0, y = -10 }, { x = 533, y = 364 })
			-- add pointer to planet here when implemented
		else
			local i = 0
			while i * GRID_DIST_BLUE < 4200 do
				if (i * GRID_DIST_BLUE) % GRID_DIST_LIGHT_BLUE ~= 0 then
					if i * GRID_DIST_BLUE < 3000 then
						graphics.draw_line({ x = -270, y = -170 + i * GRID_DIST_BLUE * 374 / 3000 }, { x = 270, y = -170 + i * GRID_DIST_BLUE * 374 / 3000 }, 1, ClutColour(4, 11))
					end
					graphics.draw_line({ x = -240 + i * GRID_DIST_BLUE * 540 / 4332, y = -196 }, { x = -240 + i * GRID_DIST_BLUE * 540 / 4332, y = 174 }, 1, ClutColour(4, 11))
				else
					if i * GRID_DIST_BLUE < 3000 then
						graphics.draw_line({ x = -270, y = -170 + i * GRID_DIST_BLUE * 374 / 3000 }, { x = 270, y = -170 + i * GRID_DIST_BLUE * 374 / 3000 }, 1, ClutColour(5, 1))
					end
					graphics.draw_line({ x = -240 + i * GRID_DIST_BLUE * 540 / 4332, y = -196 }, { x = -240 + i * GRID_DIST_BLUE * 540 / 4332, y = 174 }, 1, ClutColour(5, 1))
				end
				i = i + 1
			end
			local num = 1
			while scenBriefing.screen[1][num] ~= nil do
				local temp = graphics.sprite_dimensions(scenBriefing.screen[1][num].sprite)
				graphics.draw_sprite(scenBriefing.screen[1][num].sprite, { x = -240 + scenBriefing.screen[1][num].x * 540 / 4332, y = -170 + scenBriefing.screen[1][num].y * 374 / 3000 }, { x = temp.x * scenBriefing.screen[1][num].size, y = temp.y * scenBriefing.screen[1][num].size }, math.pi / 2)
				num = num + 1
			end
			if menuNum ~= 2 then
				if scenBriefing.screen[menuNum - 1] ~= nil then
					SwitchBox(scenBriefing.screen[menuNum - 1])
				end
			end
		end
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, MAIN_FONT, "center", { x = 0, y = -270 }, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	if k == "escape" then
		mode_manager.switch('Ares/Splash')
	elseif k == "return" then
		if doLevelSwitch == true then
			if scenLevels[menuNum].mode ~= nil then
				sound.play_music("FRED")
				doLevelSwitch = false
				freezeMenuNum = menuNum
				menuNum = 1
			else
				LogError("This module is not yet available for playing.", 8)
				sound.play("NaughtyBeep")
			end
		else
			mode_manager.switch(scenLevels[freezeMenuNum].mode)
		end
	end
end

function key(k)
	if k == "escape" then
		if doLevelSwitch == true then
			ChangeSpecial("ESC", "click", background1)
		else
			ChangeSpecial("ESC", "click", background2)
		end
	elseif k == "return" then
		if doLevelSwitch == true then
			ChangeSpecial("RTRN", "click", background1)
		else
			ChangeSpecial("RTRN", "click", background2)
		end
	elseif k == "l" then
		if doLevelSwitch == true then
			if scenLevels[menuNum + 1] ~= nil then
				if scenLevels[menuNum + 1].unlocked == true then
					menuNum = menuNum + 1
				end
			end
		else
			if scenBriefing.screen[menuNum] ~= nil then
				menuNum = menuNum + 1
			end
		end
	elseif k == "j" then
		if menuNum ~= 1 then
			menuNum = menuNum - 1
		end
	end
end