import('GlobalVars')
import('Console')
import('BoxDrawing')

freezeMenuNum = 0
levelSwitching = true
background1 = {	{ coordx = -280, coordy = 140, length = 560, text = " ", boxColour = c_teal, textColour = c_purple, execute = nil, letter = "Select Level", underbox = -145 },
				{ coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColour = c_brightYellow, textColour = c_purple, execute = nil, letter = "ESC" },
				{ coordx = 110, coordy = -205, length = 150, text = "Begin", boxColour = c_lightGreen, textColour = c_purple, execute = nil, letter = "RTRN" },
				{ coordx = -260, coordy = -105, length = 150, text = "Previous", boxColour = c_teal, textColour = c_purple, execute = nil, letter = "LEFT" },
				{ coordx = 110, coordy = -105, length = 150, text = "Next", boxColour = c_teal, textColour = c_purple, execute = nil, letter = "RGHT", special = "disabled" } }

background2 = { { coordx = -280, coordy = 175, length = 560, text = " ", boxColour = c_grey, textColour = c_grey, execute = nil, letter = "Mission Analysis", underbox = -200 },
				{ coordx = -280, coordy = -225, length = 170, text = "Previous", boxColour = c_grey, textColour = c_grey, execute = nil, letter = "LEFT" },
				{ coordx = -100, coordy = -225, length = 170, text = "Next", boxColour = c_grey, textColour = c_grey, execute = nil, letter = "RGHT" },
				{ coordx = 110, coordy = -225, length = 170, text = "Done", boxColour = c_lightGreen, textColour = c_lightGreen, execute = nil, letter = "RTRN" } }

scenLevels = { { title = "DEMO 2", subtitle = "The Second Technical Demo", desc = "In this demo, you must destroy the Gaitori Carrier prior to taking over a nearby planet with an Ishiman Transport.", unlocked = true, mode = "Demo3" },
			{ title = "TUTORIAL LESSON 1", subtitle = "Moons for Goons", desc = "Learning the Ares interface", unlocked = true },
			{ title = "CHAPTER 1", subtitle = "Easy Street", desc = "Destroy all 5 Gaitori Transports.", unlocked = true },
			{ title = "CHAPTER 6", subtitle = "...Into the Fire", desc = "Capture the planet Hades Beta while destroying as many Gaitori power stations as possible and saving as many of the Obish stations as you can.", unlocked = true } }

-- scenBriefing is hardcoded to work only with Demo3, in the future it will load whatever scenario data that I need
scenBriefing = { planet = { x = 0, y = 0 },
	screen = { { { sprite = "Ships/Ishiman/HeavyCruiser", x = 0, y = 0, size = 0.2 },
				{ sprite = "Planets/Saturny", x = 2500, y = 2500, size = 0.3 },
				{ sprite = "Planets/AnotherEarth", x = 100, y = 100, size = 0.3 },
				{ sprite = "Ships/Gaitori/Carrier", x = 2200, y = 2700, size = 0.2 } },
				{ coordx = -220, coordy = 100, length = 220, text = " ", boxColour = c_yellow, textColour = c_yellow, execute = nil, letter = "Xsera System", underbox = -100, uboxText = "Land a transport here.", sidecar = { x = 60, y = 130, size = { x = 23, y = 23 } }, special = "sidecar" }

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
		change_special("LEFT", "disabled", background1)
		change_special("LEFT", "disabled", background2)
	else
		change_special("LEFT", nil, background1)
		change_special("LEFT", nil, background2)
	end
	if levelSwitching == true then
		if scenLevels[menuNum + 1] ~= nil then
			if scenLevels[menuNum + 1].unlocked == true then
				change_special("RGHT", nil, background1)
			end
		else
			change_special("RGHT", "disabled", background1)
		end
	else
		if scenBriefing.screen[menuNum] ~= nil then
			change_special("RGHT", nil, background2)
		else
			change_special("RGHT", "disabled", background2)
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
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	local num = 1
	-- Screen Info
	if levelSwitching == true then
	-- When we load the scenario data, change all instances of "scenLevels" to "scen.levels"
		while background1[num] ~= nil do
			switch_box(background1[num])
			num = num + 1
		end
		switch_box( { top = 120, left = -260, bottom = -55, right = 260, boxColour = c_teal, title = scenLevels[menuNum].title, subtitle = scenLevels[menuNum].subtitle, desc = scenLevels[menuNum].desc } )
	else
	-- When we load the scenario data, change all instances of "scenBriefing" to "scen.briefing"
		while background2[num] ~= nil do
			switch_box(background2[num])
			num = num + 1
		end
		if menuNum == 1 then
			graphics.draw_image("Scenario/Misc/Starmap", 0, -10, 533, 364)
			-- add pointer to planet here when implemented
		else
			local i = 0
			while i * gridDistBlue < 4200 do
				if (i * gridDistBlue) % gridDistLightBlue ~= 0 then
					if i * gridDistBlue < 3000 then
						graphics.draw_line(-270, -170 + i * gridDistBlue * 374 / 3000, 270, -170 + i * gridDistBlue * 374 / 3000, 1, c_darkBlue)
					end
					graphics.draw_line(-240 + i * gridDistBlue * 540 / 4332, -196, -240 + i * gridDistBlue * 540 / 4332, 174, 1, c_darkBlue)
				else
					if i * gridDistBlue < 3000 then
						graphics.draw_line(-270, -170 + i * gridDistBlue * 374 / 3000, 270, -170 + i * gridDistBlue * 374 / 3000, 1, c_laserGreen)
					end
					graphics.draw_line(-240 + i * gridDistBlue * 540 / 4332, -196, -240 + i * gridDistBlue * 540 / 4332, 174, 1, c_laserGreen)
				end
				i = i + 1
			end
			local num = 1
			while scenBriefing.screen[1][num] ~= nil do
				tempx, tempy = graphics.sprite_dimensions(scenBriefing.screen[1][num].sprite)
				graphics.draw_sprite(scenBriefing.screen[1][num].sprite, -240 + scenBriefing.screen[1][num].x * 540 / 4332, -170 + scenBriefing.screen[1][num].y * 374 / 3000, tempx * scenBriefing.screen[1][num].size, tempy * scenBriefing.screen[1][num].size, math.pi / 2)
				num = num + 1
			end
			if menuNum ~= 2 then
				if scenBriefing.screen[menuNum - 1] ~= nil then
					switch_box(scenBriefing.screen[menuNum - 1])
				end
			end
		end
	end
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, "CrystalClear", "center", 0, -270, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	if k == "escape" then
		mode_manager.switch('AresSplash')
	elseif k == "return" then
		if levelSwitching == true then
			if scenLevels[menuNum].mode ~= nil then
				sound.play_music("FRED")
				levelSwitching = false
				freezeMenuNum = menuNum
				menuNum = 1
			else
				errLog("This module is not yet available for playing.", 8)
				sound.play("NaughtyBeep")
			end
		else
			mode_manager.switch(scenLevels[freezeMenuNum].mode)
		end
	end
end

function key(k)
	if k == "escape" then
		if levelSwitching == true then
			change_special("ESC", "click", background1)
		else
			change_special("ESC", "click", background2)
		end
	elseif k == "return" then
		if levelSwitching == true then
			change_special("RTRN", "click", background1)
		else
			change_special("RTRN", "click", background2)
		end
	elseif k == "l" then
		if levelSwitching == true then
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