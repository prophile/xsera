import('GlobalVars')

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

function do_help()
	menu_display = "info_menu"
	keyup = escape_keyup
	key = escape_key
end

--[[--------------------
	--{{------------
		Key Data
	------------}}--
---------------------]]--

key_menu = { { "Ship",
				{ key = "KP8", name = "Accelerate", action = nil },
				{ key = "KP5", name = "Decelerate", action = nil }, 
				{ key = "KP4", name = "Turn Counter-Clockwise", action = nil }, 
				{ key = "KP6", name = "Turn Clockwise", action = nil }, 
				{ key = "MaltL", key_display = "AltL", name = "Fire Weapon 1", action = nil }, 
				{ key = "MctrlL", key_display = "CtrlL", name = "Fire Weapon 2", action = nil }, 
				{ key = " ", key_display = "Space", name = "Fire/Activate Special", action = nil }, 
				{ key = "Tab", name = "Warp", action = nil } },
			{ "Command", 
				{ key = "pgdn", name = "Select Friendly", action = nil }, 
				{ key = "KPequals", key_display = "KP=", name = "Select Hostile", action = nil }, 
				{ key = "KPdivide", key_display = "KP/", name = "Select Base", action = nil }, 
				{ key = "MshiftL", key_display = "ShiftL", name = "Target", action = nil }, 
				{ key = "MaltL", key_display = "AltL", name = "Move Order", action = nil }, 
				{ key = "KPplus", key_display = "KP+", name = "Scale In", action = nil }, 
				{ key = "KPminus", key_display = "KP-", name = "Scale Out", action = nil }, 
				{ key = "up", key_display = "UP", name = "Computer Previous", action = nil }, 
				{ key = "down", key_display = "DOWN", name = "Computer Next", action = nil }, 
				{ key = "right", key_display = "RGHT", name = "Computer Accept/Select/Do", action = nil }, 
				{ key = "left", key_display = "LEFT", name = "Computer Cancel/Back Up", action = nil } },
			{ "Shortcuts",
				{ key = "F8", name = "Transfer Control", action = nil }, 
				{ key = "F9", name = "Zoom to 1:1", action = nil }, 
				{ key = "F10", name = "Zoom to 1:2", action = nil }, 
				{ key = "F11", name = "Zoom to 1:4", action = nil }, 
				{ key = "F12", name = "Zoom to 1:16", action = nil }, 
				{ key = "ins", name = "Zoom to Closest Hostile", action = nil }, 
				{ key = "home", name = "Zoom to Closest Object", action = nil }, 
				{ key = "pgup", name = "Zoom to All", action = nil }, 
				{ key = "del", name = "Message Next Page / Clear", action = nil } },
			{ "Utility",
				{ key = "F1", name = "Help", action = do_help }, 
				{ key = "F2", name = "Lower Volume", action = nil }, 
				{ key = "F3", name = "Raise Volume", action = nil }, 
				{ key = "F4", name = "Mute Music", action = nil }, 
				{ key = "F5", name = "Expert Net Settings", action = nil }, 
				{ key = "F6", name = "Fast Motion", action = nil } }, 
			{ "HotKeys",
				{ key = "1", name = "HotKey 1", action = nil }, 
				{ key = "2", name = "HotKey 2", action = nil }, 
				{ key = "3", name = "HotKey 3", action = nil }, 
				{ key = "4", name = "HotKey 4", action = nil }, 
				{ key = "5", name = "HotKey 5", action = nil }, 
				{ key = "6", name = "HotKey 6", action = nil }, 
				{ key = "7", name = "HotKey 7", action = nil }, 
				{ key = "8", name = "HotKey 8", action = nil }, 
				{ key = "9", name = "HotKey 9", action = nil }, 
				{ key = "0", name = "HotKey 10", action = nil } } }

--[[---------------------------------
	--{{-------------------------
		Key Menu Manipulation
	-------------------------}}--
---------------------------------]]--

function reassign_key(name, key)
	local i = 1
	while key_menu[i] ~= nil do
		local j = 2
		while key_menu[i][j] ~= nil do
			if key_menu[i][j].key == key then
				key_menu[i][j].key = nil
			end
			if key_menu[i][j].menu == menu then
				key_menu[i][j].key = key
			end
			j = j + 1
		end
		i = i + 1
	end
end

function key_is_unassigned()
	local i = 1
	while key_menu[i] ~= nil do
		local j = 2
		while key_menu[i][j] ~= nil do
			if key_menu[i][j].key == nil then
				return true, key_menu[i][j].menu
			end
			j = j + 1
		end
		i = i + 1
	end
	return false
end

function key_activated(key)
	local i = 1
	while key_menu[i] ~= nil do
		local j = 2
		while key_menu[i][j] ~= nil do
			if key_menu[i][j].key == key then
				if key_menu[i][j].action() ~= nil then
					key_menu[i][j].action()
				end
				return
			end
			j = j + 1
		end
		i = i + 1
	end
end