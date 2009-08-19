import('GlobalVars')
import('Console')
import('BoxDrawing')

levelSwitching = true
screenNum = 1
background = {	{ coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColour = CBYELLOW, textColor = c_purple, execute = nil, letter = "ESC" },
	{ coordx = 110, coordy = -205, length = 150, text = "Begin", boxColour = c_lightGreen, textColor = c_purple, execute = nil, letter = "RTRN" },
	{ coordx = -260, coordy = -105, length = 150, text = "Previous", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "LEFT" },
	{ coordx = 110, coordy = -105, length = 150, text = "Next", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "RGHT", special = "disabled" },
	{ coordx = -280, coordy = 140, length = 560, text = " ", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "Select Level", underbox = -145 } }

scenInfo = { { title = "DEMO 2", subtitle = "The Second Technical Demo", desc = "In this demo, you must destroy the Gaitori Carrier prior to taking over a nearby planet with an Ishiman Transport.", unlocked = true, mode = "Demo2" },
			{ title = "TUTORIAL LESSON 1", subtitle = "Moons for Goons", desc = "Learning the Ares interface", unlocked = true },
			{ title = "CHAPTER 1", subtitle = "Easy Street", desc = "Destroy all 5 Gaitori Transports.", unlocked = true },
			{ title = "CHAPTER 6", subtitle = "...Into the Fire", desc = "Capture the planet Hades Beta while destroying as many Gaitori power stations as possible and saving as many of the Obish stations as you can.", unlocked = true } }
-- the above is [TEMPORARY]
menuNum = 1

function init()
	sound.stop_music()
	graphics.set_camera(-480, -360, 480, 360)
	local num = 1
--	execs[num] = { coordx = -260, coordy = -205, length = 150, text = "Cancel", boxColour = CBYELLOW, textColor = c_purple, execute = nil, letter = "ESC" }
	num = num + 1
--	execs[num] = { coordx = 110, coordy = -205, length = 150, text = "Begin", boxColour = c_lightGreen, textColor = c_purple, execute = nil, letter = "RTRN" }
	num = num + 1
--	execs[num] = { coordx = -260, coordy = -105, length = 150, text = "Previous", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "LEFT" }
	num = num + 1
--	execs[num] = { coordx = 110, coordy = -105, length = 150, text = "Next", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "RGHT", special = "disabled" }
--	num = num + 1
--	execs[num] = { coordx = -280, coordy = 140, length = 560, text = " ", boxColour = CTEAL, textColor = c_purple, execute = nil, letter = "Select Level", underbox = -145 }
	num = num + 1
--	execs[num] = { top = 120, left = -260, bottom = -55, right = 260, boxColour = CTEAL, title = scenInfo[menuNum].title, subtitle = scenInfo[menuNum].subtitle, desc = scenInfo[menuNum].desc }
end

function update()
	if menuNum == 1 then
		change_special("LEFT", "disabled", background)
	else
		change_special("LEFT", nil, background)
	end
	if scenInfo[menuNum + 1] ~= nil then
		if scenInfo[menuNum + 1].unlocked == true then
			change_special("RGHT", nil, background)
		end
	else
		change_special("RGHT", "disabled", background)
	end
	while background[num] ~= nil do
		if background[num].special == "click" then
			background[num].special = nil
		end
		num = num + 1
	end
--	execs[6] = { top = 120, left = -260, bottom = -55, right = 260, boxColour = CTEAL, title = scenInfo[menuNum].title, subtitle = scenInfo[menuNum].subtitle, desc = scenInfo[menuNum].desc }
end

function render()
	graphics.begin_frame()
	-- Background
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	local num = 1
	while background[num] ~= nil do
		switch_box(background[num])
		num = num + 1
	end
	-- Screen Info
	if levelSwitching == true then
	-- When we load the scenario data, change all instances of "scenLevels" to "scen.levels"
		switch_box( { top = 120, left = -260, bottom = -55, right = 260, boxColour = CTEAL, title = scenInfo[menuNum].title, subtitle = scenInfo[menuNum].subtitle, desc = scenInfo[menuNum].desc } )
	else
	-- When we load the scenario data, change all instances of "scenBriefing" to "scen.Briefing"
		
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
		if scenInfo[menuNum].mode ~= nil then
			mode_manager.switch(scenInfo[menuNum].mode)
		else
			errLog("This module is not yet available for playing.", 8)
			sound.play("NaughtyBeep")
		end
	end
end

function key(k)
	if k == "escape" then
		change_special("ESC", "click", background)
	elseif k == "return" then
		change_special("RTRN", "click", background)
	elseif k == "l" then
		if scenInfo[menuNum + 1] ~= nil then
			if scenInfo[menuNum + 1].unlocked == true then
				menuNum = menuNum + 1
			end
		end
	elseif k == "j" then
		if menuNum ~= 1 then
			menuNum = menuNum - 1
		end
	end
end