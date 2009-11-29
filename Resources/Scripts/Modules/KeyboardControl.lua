import('GlobalVars')
import('Interfaces')

--[[-----------------------
	--{{---------------
		Key In Menu
	---------------}}--
-----------------------]]--

function escape_keyup(k)
    if k == "escape" then
		if down.esc == true then
			down.esc = "act"
		end
    elseif k == "return" then
        down.rtrn = "act"
    elseif k == "q" then
        down.q = "act"
	end
end

function escape_key(k)
    if k == "escape" then
		down.esc = true
    elseif k == "return" then
        down.rtrn = true
    elseif k == "q" then
        down.q = true
    elseif k == "o" then
        down.o = true
	end
end

--[[-------------------------
	--{{-----------------
		Key Functions
	-----------------}}--
-------------------------]]--

	--[[--------
		Ship
	--------]]--

function DoFireWeap1()
	if playerShip.beam ~= nil then
		playerShip.beam.firing = true
	end
end

function StopFireWeap1()
	if playerShip.beam ~= nil then
		playerShip.beam.firing = false
	end
end

function DoFireWeap2()
	if playerShip.pulse ~= nil then
		playerShip.pulse.firing = true
	end
end

function StopFireWeap2()
	if playerShip.pulse ~= nil then
		playerShip.pulse.firing = false
	end
end

function DoFireWeapSpecial()
	if playerShip.special ~= nil then
		playerShip.special.firing = true
	end
end

function StopFireWeapSpecial()
	if playerShip.special ~= nil then
		playerShip.special.firing = false
	end
end

function DoWarp()
	if playerShip.warp.stage == "notWarping" then
		playerShip.warp.time = 0.0
		playerShip.warp.stage = "spooling"
	end
end

function StopWarp()
	if playerShip.warp.stage == "warping" then
		playerShip.warp.stage = "cooldown"
	else
		playerShip.warp.stage = "notWarping"
	end
	playerShip.warp.time = 0.0
	playerShip.warp.lastPlayed = 0
end

	--[[-----------
		Command
	-----------]]--

function DoSelectFriendly()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoSelectHostile()
	LogError("The command does not have any code. /placeholder", 9)
	--[[ pseudocode
	if hostileSelected == false then
		testWithin(angle)
		select(closest)
	else
		if (testWithin(angle) ~= closest then
			select(testWithin(angle))
		end
	end
	--]]
end

--[[ pseudocode
function DoSelect(type)
	if currentSelect == type then
		select(nextClosest)
	else
		select(closest)
	end
end
--]]


function DoSelectBase()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoTarget()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoMoveOrder()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoScaleIn()
	if cameraRatioNum ~= 1 then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = cameraRatioNum - 1
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
	ActionDeactivate("Scale In")
end

function DoScaleOut()
	if cameraRatios[cameraRatioNum + 1] ~= nil then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = cameraRatioNum + 1
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
	ActionDeactivate("Scale Out")
end

function DoComputerPrevious()
	change_menu(menuLevel, "i")
	keyboard[2][9].active = false
end

function DoComputerNext()
	change_menu(menuLevel, "k")
	keyboard[2][10].active = false
end

function DoComputerAccept()
	change_menu(menuLevel, "l")
	keyboard[2][11].active = false
end

function DoComputerBack()
	change_menu(menuLevel, "j")
	keyboard[2][12].active = false
end

	--[[-------------
		Shortcuts
	-------------]]--

function DoTransferControl()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoZoom1_1()
	if cameraRatioNum ~= 2 then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = 2
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
end

function DoZoom1_2()
	if cameraRatioNum ~= 3 then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = 3
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
end

function DoZoom1_4()
	if cameraRatioNum ~= 4 then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = 4
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
end

function DoZoom1_16()
	if cameraRatioNum ~= 5 then
		cameraChanging = true
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = 5
		multiplier = (cameraRatios[cameraRatioNum] - cameraRatio) / cameraRatio
	end
end

function DoZoomHostile()
	-- the following is hardcoded, but can be easily modified to not be so
	-- cannot work on this on laptop, no insert key (change to F6 or F5 or something)
	
	-- the following does not work correctly [ADAM]
	--[[ insta-zoom version, doesn't work
	local diff = { x = computerShip.physicsObject.position.x - playerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y - playerShip.physicsObject.position.y }
	if aspectRatio > (diff.x / diff.y) then
		camera = { w = diff.x, h =  (diff.x + 50) / aspectRatio }
	else
		camera = { w = aspectRatio *  (diff.y + 50), h = diff.y }
	end
	--]]
	
	if cameraRatioNum ~= 6 then
		local diff = { x = computerShip.physicsObject.position.x - playerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y - playerShip.physicsObject.position.y }
		local calculatedRatio = 0
		if aspectRatio > (diff.x / diff.y) then
			calculatedRatio = 640 / diff.y * aspectRatio
		else
			calculatedRatio = 640 / diff.x
		end
		cameraChanging = false
		cameraRatioOrig = cameraRatio
		x = timeInterval
		cameraRatioNum = 6
		multiplier = (calculatedRatio - cameraRatio) / cameraRatio
	end
end

function DoZoomObject()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoZoomAll()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoMessageNext()
	LogError("The command does not have any code. /placeholder", 9)
end

	--[[-----------
		Utility
	-----------]]--

function DoHelp()
	menu_display = "info_menu"
	keyup = escape_keyup
	key = escape_key
	keyboard[4][2].active = false
end

function DoLowerVolume()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoRaiseVolume()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoMuteMusic()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoExpertNet()
	LogError("The command does not have any code. /placeholder", 9)
end

	--[[-----------
		HotKeys
	-----------]]--

function DoHotkey1()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey2()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey3()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey4()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey5()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey6()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey7()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey8()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey9()
	LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey10()
	LogError("The command does not have any code. /placeholder", 9)
end


--[[--------------------
	--{{------------
		Key Data
	------------}}--
---------------------]]--
-- keyboard with all the original keybindings here: <http://xsera.pastebin.com/f690af8a8>
keyboard = { { "Ship",
				{ key = "w", name = "Accelerate", active = false },
				{ key = "s", name = "Decelerate", active = false }, 
				{ key = "a", name = "Turn Counter-Clockwise", active = false }, 
				{ key = "d", name = "Turn Clockwise", active = false }, 
				{ key = "MmetaL", key_display = "CmdL", name = "Fire Weapon 1", action = DoFireWeap1, deaction = StopFireWeap1, active = false }, 
				{ key = "MaltL", key_display = "AltL", name = "Fire Weapon 2", action = DoFireWeap2, deaction = StopFireWeap2, active = false }, 
				{ key = " ", key_display = "Space", name = "Fire/Activate Special", action = DoFireWeapSpecial, deaction = StopFireWeapSpecial, active = false }, 
				{ key = "tab", key_display = "Tab", name = "Warp", action = DoWarp, deaction = StopWarp, active = false } },
			{ "Command", 
				{ key = "pgdn", name = "Select Friendly", action = DoSelectFriendly, active = false }, 
				{ key = "KPequals", key_display = "KP=", name = "Select Hostile", action = DoSelectHostile, active = false }, 
				{ key = "KPdivide", key_display = "KP/", name = "Select Base", action = DoSelectBase, active = false }, 
				{ key = "MshiftL", key_display = "ShiftL", name = "Target", action = DoTarget, active = false }, 
				{ key = "MctrlL", key_display = "CtrlL", name = "Move Order", action = DoMoveOrder, active = false }, 
				{ key = "=", name = "Scale In", action = DoScaleIn, active = false }, 
				{ key = "-", name = "Scale Out", action = DoScaleOut, active = false }, 
				{ key = "up", key_display = "UP", name = "Computer Previous", action = DoComputerPrevious, active = false }, 
				{ key = "down", key_display = "DOWN", name = "Computer Next", action = DoComputerNext, active = false }, 
				{ key = "right", key_display = "RGHT", name = "Computer Accept/Select/Do", action = DoComputerAccept, active = false }, 
				{ key = "left", key_display = "LEFT", name = "Computer Cancel/Back Up", action = DoComputerBack, active = false } },
			{ "Shortcuts",
				{ key = "F8", name = "Transfer Control", action = DoTransferControl, active = false }, 
				{ key = "F9", name = "Zoom to 1:1", action = DoZoom1_1, active = false }, 
				{ key = "F10", name = "Zoom to 1:2", action = DoZoom1_2, active = false }, 
				{ key = "F11", name = "Zoom to 1:4", action = DoZoom1_4, active = false }, 
				{ key = "F12", name = "Zoom to 1:16", action = DoZoom1_16, active = false }, 
				{ key = "F5", name = "Zoom to Closest Hostile", action = DoZoomHostile, active = false }, 
				{ key = "home", name = "Zoom to Closest Object", action = DoZoomObject, active = false }, 
				{ key = "pgup", name = "Zoom to All", action = DoZoomAll, active = false }, 
				{ key = "del", name = "Message Next Page / Clear", action = DoMessageNext, active = false } },
			{ "Utility",
				{ key = "F1", name = "Help", action = DoHelp, active = false }, 
				{ key = "F2", name = "Lower Volume", action = DoLowerVolume, active = false }, 
				{ key = "F3", name = "Raise Volume", action = DoRaiseVolume, active = false }, 
				{ key = "F4", name = "Mute Music", action = DoMuteMusic, active = false }, 
				{ key = "", name = "Expert Net Settings", action = DoExpertNet, active = false }, 
				{ key = "", name = "Fast Motion", active = false } }, 
			{ "HotKeys",
				{ key = "1", name = "HotKey 1", action = DoHotkey1, active = false }, 
				{ key = "2", name = "HotKey 2", action = DoHotkey2, active = false }, 
				{ key = "3", name = "HotKey 3", action = DoHotkey3, active = false }, 
				{ key = "4", name = "HotKey 4", action = DoHotkey4, active = false }, 
				{ key = "5", name = "HotKey 5", action = DoHotkey5, active = false }, 
				{ key = "6", name = "HotKey 6", action = DoHotkey6, active = false }, 
				{ key = "7", name = "HotKey 7", action = DoHotkey7, active = false }, 
				{ key = "8", name = "HotKey 8", action = DoHotkey8, active = false }, 
				{ key = "9", name = "HotKey 9", action = DoHotkey9, active = false }, 
				{ key = "0", name = "HotKey 10", action = DoHotkey10, active = false } } }

--[[---------------------------------
	--{{-------------------------
		Key Menu Manipulation
	-------------------------}}--
---------------------------------]]--

function ReassignKey(name, key)
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].key == key then
				keyboard[i][j].key = nil
			end
			if keyboard[i][j].menu == menu then
				keyboard[i][j].key = key
			end
			j = j + 1
		end
		i = i + 1
	end
end

function KeyIsUnassigned()
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].key == nil then
				return true, keyboard[i][j].menu
			end
			j = j + 1
		end
		i = i + 1
	end
	return false
end

function KeyActivate(key)
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].key == key then
				keyboard[i][j].active = true
				return
			end
			j = j + 1
		end
		i = i + 1
	end
end

function ActionActivate(name)
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].name == name then
				keyboard[i][j].active = true
				return
			end
			j = j + 1
		end
		i = i + 1
	end
end

function KeyDeactivate(key)
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].key == key then
				keyboard[i][j].active = false
				if keyboard[i][j].deaction ~= nil then
					keyboard[i][j].deaction()
				end
				return
			end
			j = j + 1
		end
		i = i + 1
	end
end

function ActionDeactivate(name)
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].name == name then
				keyboard[i][j].active = false
				if keyboard[i][j].deaction ~= nil then
					keyboard[i][j].deaction()
				end
				return
			end
			j = j + 1
		end
		i = i + 1
	end
end

function KeyDoActivated()
	local i = 1
	while keyboard[i] ~= nil do
		local j = 2
		while keyboard[i][j] ~= nil do
			if keyboard[i][j].active == true then
				if keyboard[i][j].action ~= nil then
					keyboard[i][j].action()
				end
			end
			j = j + 1
		end
		i = i + 1
	end
end