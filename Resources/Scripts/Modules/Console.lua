FONT_SIZE = 22
CONSOLE_MAX = 5

consoleHistory = {}
line = 0
lineFocus = 0
isPopDown = false
isShiftPressed = false
isCapsOn = false
consoleBuffer = nil
endsInCloseParen = nil
doProcessConsole = false
nestLevel = 0
newHistory = nil
io.output("XseraOutput.txt")

do
	originalPrint = print
	newPrint = function(...)
		local bigTable = {...}
		i = 1
		while bigTable[i] ~= nil do
			ConsoleAdd(tostring(bigTable[i]))
			i = i + 1
		end
	end
	SetOriginalPrint = function() print = originalPrint end
	SetNewPrint = function() print = newPrint end
end


function ConsoleDraw(FONT_SIZE)
	graphics.set_camera(-320, -240, 320, 240)
	local i = 1
	while consoleHistory[i] ~= nil do
		if i <= CONSOLE_MAX then
			graphics.draw_text(consoleHistory[i], MAIN_FONT, "left", { x = -319, y = 232 - (i - 1) * FONT_SIZE + 1 }, FONT_SIZE)
			i = i + 1
		else
			return
		end
	end
end

function ConsoleAdd(text, doPrint, output)
	if output ~= nil then
		io.output(output)
	else
		io.output("XseraOutput.txt")
	end
	table.insert(consoleHistory, text)
	if ((text ~= ">") and (text ~= ">>")) then
		if doPrint ~= false then
			originalPrint("[Console] " .. text)
		end
		io.write(text, "\n")
	end
	line = line + 1
	lineFocus = line
end

function ConsoleKeyup (k)
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
			isShiftPressed = false
		end
	end
end

function ConsoleKey (k)
	if k == "unhandled" then
		return
	end
	
	asciiKey = k:byte(1)
	if k == "return" then
		if ((consoleHistory == ">>") or (consoleHistory == ">")) then
			return
		end
		io.write(consoleHistory[line], "\n")
		originalPrint("[Console] " .. consoleHistory[line])
		local string = nil
		local error = nil
		local list = { "if", "do", "while", "repeat", "for", "function", "local function" }
		num = 1
		while list[num] ~= nil do
			if consoleHistory[line]:find(list[num]) ~= nil then
				nestLevel = nestLevel + 1
				num = 8 -- outside of the range
			end
			num = num + 1
		end
		if (consoleHistory[line]:sub(-1, -1) == ")") then
			endsInCloseParen = true
		else
			endsInCloseParen = false
		end
		local withoutGT = nil
		if consoleHistory[line]:gsub("(>>)(.)", "%2", 1) ~= nil then
			withoutGT = consoleHistory[line]:gsub("(>>)(.)", "%2", 1)
		else
			withoutGT = consoleHistory[line]:gsub("(>>)(.)", "%2", 1)
		end
		if withoutGT == "end" then
			nestLevel = nestLevel - 1
			if nestLevel == 0 then
				doProcessConsole = true
			elseif nestLevel < 0 then
				doProcessConsole = true
			end
		end
		if consoleBuffer ~= nil then
			consoleBuffer = consoleBuffer .. "\n" .. withoutGT
		else
			consoleBuffer = consoleHistory[line]:gsub("(>)(.)", "%2", 1)
		end
		if endsInCloseParen == true then
			if consoleBuffer == consoleHistory[line]:gsub("(>)(.)", "%2", 1) then
				if consoleBuffer:find("function") == nil then
					doProcessConsole = true
				end
			end
		end
		if doProcessConsole == false then
			ConsoleAdd(">>")
		else
			string, error = loadstring(consoleBuffer)
			if error == nil then
				string()
			else
				ConsoleAdd(error)
			end
			consoleBuffer = nil
			nestLevel = 0
			ConsoleAdd(">")
		end
	elseif k == "escape" then
		SetNewPrint()
		if isPopDown == true then
			consoleDraw = false
			isPopDown = false
		else
			mode_manager.switch("Xsera/MainMenu")
		end
	elseif k == "backspace" then
		if ((consoleHistory[line] ~= ">") and (consoleHistory[line] ~= ">>")) then
			consoleHistory[line] = consoleHistory[line]:sub(1, -2)
		end
	elseif k == "tab" then
		consoleDraw = false
		release = true
	elseif asciiKey >= 97 and asciiKey <= 122 then
		if k:byte(2, 2) == nil then
			if ((isShiftPressed == true) or (isCapsOn == true)) then
				consoleHistory[line] = consoleHistory[line] .. k:upper()
			else
				consoleHistory[line] = consoleHistory[line] .. k
			end
		end
	elseif asciiKey == 32 then
		consoleHistory[line] = consoleHistory[line] .. k
	elseif k == "," then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "<"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "." then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. ">"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "-" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "_"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "1" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "!"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "2" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "@"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "3" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "#"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "4" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "$"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "5" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "%"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "6" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "^"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "7" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "&"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "8" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "*"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "9" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "("
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "0" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. ")"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\'" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\""
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\=" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\+"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "/" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "?"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "[" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "{"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "]" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. "}"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == ";" then
		if ((isShiftPressed == true) or (isCapsOn == true)) then
			consoleHistory[line] = consoleHistory[line] .. ":"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "left" then
		originalPrint("BOING")
	elseif k == "right" then
		originalPrint("BOING")
	elseif k == "up" then
		originalPrint("BOING")
	elseif k == "down" then
		originalPrint("BOING")
	elseif k == "KP9" then
		if lineFocus > 1 then
			if newHistory == nil then
				newHistory = consoleHistory[line]
				originalPrint(newHistory)
			end
			lineFocus = lineFocus - 1
			if consoleHistory[lineFocus]:sub(1, 1) == "$" then
				lineFocus = lineFocus + 1
			end
			while consoleHistory[lineFocus]:sub(1, 1) ~= ">" do
				lineFocus = lineFocus - 1
			end
		end
		consoleHistory[line] = consoleHistory[lineFocus]
	elseif k == "KP3" then
		originalPrint(lineFocus, line)
		if lineFocus < line then
			lineFocus = lineFocus + 1
			while consoleHistory[lineFocus]:sub(1, 1) ~= ">" do
				lineFocus = lineFocus + 1
			end
			consoleHistory[line] = consoleHistory[lineFocus]
		end
		originalPrint(lineFocus, line)
		if ((lineFocus == line) and (newHistory ~= nil)) then
			consoleHistory[line] = newHistory
			newHistory = nil
		end
		originalPrint(lineFocus, line)
		if lineFocus > line then
			lineFocus = lineFocus - 1
		end
		originalPrint(lineFocus, line)
		originalPrint("----------")
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
				isShiftPressed = true
			end
			if cmd == "caps" then
				if isCapsOn == true then
					isCapsOn = false
				else
					isCapsOn = true
				end
				originalPrint("Caps: ", isCapsOn)
			end
		end
	end
end

function CoutTable (t, name, doPrint)
	ConsoleAdd(table_define(t, name), doPrint, "XseraTables.txt")
end


function LogError(text, current)
	ConsoleAdd(text .. "(current " .. current .. ")")
	if current > 10 then
		os.exit()
	end
	if current > 5 then
		errNotice = { start = mode_manager.time(), duration = current - 5, text = text }
	end
end

--[[ error current scheme:
	1-5: non-fatal, continue
		1: code not implemented
		2: load error
	6-10: non-fatal, display on screen
	11-15: fatal, exit
		11: Improper input - data is not of the correct type
		12: No input given - file is missing necessary data
--]]