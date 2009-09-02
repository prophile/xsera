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

	--[[--------
		Ship
	--------]]--

function do_fire_weap_1()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_fire_weap_2()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_fire_weap_special()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_warp()
	errLog("The command does not have any code. /placeholder", 9)
end

	--[[-----------
		Command
	-----------]]--

function do_select_friendly()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_select_hostile()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_select_base()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_target()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_move_order()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_scale_in()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_scale_out()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_computer_previous()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_computer_next()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_computer_accept()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_computer_back()
	errLog("The command does not have any code. /placeholder", 9)
end

	--[[-------------
		Shortcuts
	-------------]]--

function do_transfer_control()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_1_1()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_1_2()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_1_4()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_1_16()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_hostile()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_object()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_zoom_all()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_message_next()
	errLog("The command does not have any code. /placeholder", 9)
end

	--[[-----------
		Utility
	-----------]]--

function do_help()
	menu_display = "info_menu"
	keyup = escape_keyup
	key = escape_key
end

function do_lower_volume()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_raise_volume()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_mute_music()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_expert_net()
	errLog("The command does not have any code. /placeholder", 9)
end

	--[[-----------
		HotKeys
	-----------]]--

function do_hotkey_1()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_2()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_3()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_4()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_5()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_6()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_7()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_8()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_9()
	errLog("The command does not have any code. /placeholder", 9)
end

function do_hotkey_10()
	errLog("The command does not have any code. /placeholder", 9)
end


--[[--------------------
	--{{------------
		Key Data
	------------}}--
---------------------]]--

keyboard = { { "Ship",
				{ key = "KP8", name = "Accelerate", active = false },
				{ key = "KP5", name = "Decelerate", active = false }, 
				{ key = "KP4", name = "Turn Counter-Clockwise", active = false }, 
				{ key = "KP6", name = "Turn Clockwise", active = false }, 
				{ key = "MaltL", key_display = "AltL", name = "Fire Weapon 1", action = do_fire_weap_1, active = false }, 
				{ key = "MctrlL", key_display = "CtrlL", name = "Fire Weapon 2", action = do_fire_weap_2, active = false }, 
				{ key = " ", key_display = "Space", name = "Fire/Activate Special", action = do_fire_weap_special, active = false }, 
				{ key = "Tab", name = "Warp", action = do_warp, active = false } },
			{ "Command", 
				{ key = "pgdn", name = "Select Friendly", action = do_select_friendly, active = false }, 
				{ key = "KPequals", key_display = "KP=", name = "Select Hostile", action = do_select_hostile, active = false }, 
				{ key = "KPdivide", key_display = "KP/", name = "Select Base", action = do_select_base, active = false }, 
				{ key = "MshiftL", key_display = "ShiftL", name = "Target", action = do_target, active = false }, 
				{ key = "MmetaL", key_display = "CmndL", name = "Move Order", action = do_move_order, active = false }, 
				{ key = "KPplus", key_display = "KP+", name = "Scale In", action = do_scale_in, active = false }, 
				{ key = "KPminus", key_display = "KP-", name = "Scale Out", action = do_scale_out, active = false }, 
				{ key = "up", key_display = "UP", name = "Computer Previous", action = do_computer_previous, active = false }, 
				{ key = "down", key_display = "DOWN", name = "Computer Next", action = do_computer_next, active = false }, 
				{ key = "right", key_display = "RGHT", name = "Computer Accept/Select/Do", action = do_computer_accept, active = false }, 
				{ key = "left", key_display = "LEFT", name = "Computer Cancel/Back Up", action = do_computer_back, active = false } },
			{ "Shortcuts",
				{ key = "F8", name = "Transfer Control", action = do_transfer_control, active = false }, 
				{ key = "F9", name = "Zoom to 1:1", action = do_zoom_1_1, active = false }, 
				{ key = "F10", name = "Zoom to 1:2", action = do_zoom_1_2, active = false }, 
				{ key = "F11", name = "Zoom to 1:4", action = do_zoom_1_4, active = false }, 
				{ key = "F12", name = "Zoom to 1:16", action = do_zoom_1_16, active = false }, 
				{ key = "ins", name = "Zoom to Closest Hostile", action = do_zoom_hostile, active = false }, 
				{ key = "home", name = "Zoom to Closest Object", action = do_zoom_object, active = false }, 
				{ key = "pgup", name = "Zoom to All", action = do_zoom_all, active = false }, 
				{ key = "del", name = "Message Next Page / Clear", action = do_message_next, active = false } },
			{ "Utility",
				{ key = "F1", name = "Help", action = do_help, active = false }, 
				{ key = "F2", name = "Lower Volume", action = do_lower_volume, active = false }, 
				{ key = "F3", name = "Raise Volume", action = do_raise_volume, active = false }, 
				{ key = "F4", name = "Mute Music", action = do_mute_music, active = false }, 
				{ key = "F5", name = "Expert Net Settings", action = do_expert_net, active = false }, 
				{ key = "F6", name = "Fast Motion", active = false } }, 
			{ "HotKeys",
				{ key = "1", name = "HotKey 1", action = do_hotkey_1, active = false }, 
				{ key = "2", name = "HotKey 2", action = do_hotkey_2, active = false }, 
				{ key = "3", name = "HotKey 3", action = do_hotkey_3, active = false }, 
				{ key = "4", name = "HotKey 4", action = do_hotkey_4, active = false }, 
				{ key = "5", name = "HotKey 5", action = do_hotkey_5, active = false }, 
				{ key = "6", name = "HotKey 6", action = do_hotkey_6, active = false }, 
				{ key = "7", name = "HotKey 7", action = do_hotkey_7, active = false }, 
				{ key = "8", name = "HotKey 8", action = do_hotkey_8, active = false }, 
				{ key = "9", name = "HotKey 9", action = do_hotkey_9, active = false }, 
				{ key = "0", name = "HotKey 10", action = do_hotkey_10, active = false } } }

--[[---------------------------------
	--{{-------------------------
		Key Menu Manipulation
	-------------------------}}--
---------------------------------]]--

function reassign_key(name, key)
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

function key_is_unassigned()
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

function key_activate(key)
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

function key_do_activated()
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