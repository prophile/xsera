consoleHistory = {}
line = 0
CONSOLE_MAX = 5

shift_press = false
caps_hold = false

io.output("XseraOutput.txt")

function console_draw(fontsize)
	camera = { w = 640, h = 480 }
	graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
	local i = 1
	while consoleHistory[i] ~= nil do
		if i <= CONSOLE_MAX then
			graphics.draw_text(consoleHistory[i], "CrystalClear", "left", -319, 234 - (i - 1) * fontsize + 1, fontsize)
			i = i + 1
		else
			return
		end
	end
end

function console_add(text, doPrint, output)
	if output ~= nil then
		io.output(output)
	else
		io.output("XseraOutput.txt")
	end
	table.insert(consoleHistory, text)
	if text ~= ">" then
		if doPrint ~= false then
			print("[Console] " .. text)
		end
		io.write(text, "\n")
	end
	line = line + 1
end

function console_keyup (k)
	if k:gsub("(M)(%w+)", "%1", 1) == "M" then
		local side = nil
		local cmd = nil
		if k:gsub("(M)(%w+)(L)", "%3", 1) == "L" then
			side = "left"
			cmd = k:gsub("(M)(%w+)(L)", "%2", 1)
		elseif k:gsub("(M)(%w+)(R)", "%3", 1) == "R" then
			side = "right"
			cmd = k:gsub("(M)(%w+)(R)", "%2", 1)
		else
			cmd = k:gsub("(M)(%w+)", "%2", 1)
		end
		if cmd == "shift" then
			shift_press = false
		end
	end
end

function console_key (k)
	if k == "unhandled" then
		return
	end
	
	asciikey = k:byte(1)
	if k == "return" then
		local i = 1
		io.write(consoleHistory[line], "\n")
		print("[Console] " .. consoleHistory[line])
		local string, error = loadstring(consoleHistory[line]:gsub("(>)(.)", "%2", 1))
		if error == nil then
			string()
			console_add(consoleHistory[line]:gsub("(>)(.)", "%2", 1))
		else
			console_add(error)
		end
		console_add(">")
	elseif k == "escape" then
		mode_manager.switch("MainMenu")
	elseif k == "tab" then
		consoleDraw = false
	elseif asciikey >= 97 and asciikey <= 122 then
		if k:byte(2, 2) == nil then
			if ((shift_press == true) or (caps_hold == true)) then
				consoleHistory[line] = consoleHistory[line] .. k:upper()
			else
				consoleHistory[line] = consoleHistory[line] .. k
			end
		end
--	elseif asciikey >= 65 and asciikey <= 90 then
--		consoleHistory[line] = consoleHistory[line] .. k
	elseif asciikey == 32 then
		consoleHistory[line] = consoleHistory[line] .. k
	elseif k == "backspace" then
		
	elseif k == "1" then
		
	elseif k == "2" then
		
	elseif k == "3" then
		
	elseif k == "4" then
		
	elseif k == "5" then
		
	elseif k == "6" then
		
	elseif k == "7" then
		
	elseif k == "8" then
		
	elseif k == "9" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "("
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "0" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. ")"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\'" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\""
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\=" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\+"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	else
		if k:gsub("(M)(%w+)", "%1", 1) == "M" then
			local side = nil
			local cmd = nil
			if k:gsub("(M)(%w+)(L)", "%3", 1) == "L" then
				side = "left"
				cmd = k:gsub("(M)(%w+)(L)", "%2", 1)
			elseif k:gsub("(M)(%w+)(R)", "%3", 1) == "R" then
				side = "right"
				cmd = k:gsub("(M)(%w+)(R)", "%2", 1)
			else
				cmd = k:gsub("(M)(%w+)", "%2", 1)
			end
			if cmd == "shift" then
				shift_press = true
			end
			if cmd == "caps" then
				if caps_hold == true then
					caps_hold = false
				else
					caps_hold = true
				end
				print("Caps: ", caps_hold) -- [FIX3] caps_hold only changes every other time
			end
		end
	--	consoleHistory[line] = consoleHistory[line] .. k
	end
end

function cout_table (t, name, doPrint)
	console_add(table_define(t, name), doPrint, "XseraTables.txt")
end