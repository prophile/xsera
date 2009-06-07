import('Console')

CONSOLE_MAX = 18

lastTime = mode_manager.time()

function init ()
	sound.stop_music()
	console_add("$Loading console...")
	console_add("$Console loaded.")
	console_add(">")
end

function render ()
    graphics.begin_frame()
	graphics.set_camera(-300, -200, 300, 200)
	local i = 1
	while consoleHistory[i] ~= nil do
		if i <= CONSOLE_MAX then
			graphics.draw_text(consoleHistory[i], "CrystalClear", "left", -295, 193 - (i - 1) * 22, 20)
			i = i + 1
		else
			graphics.end_frame()
			return
		end
	end
    graphics.end_frame()
end

function key ( k )
	if k == "return" then
		line_handle()
		line = line + 1
		table.insert(consoleHistory, ">")
		return
	elseif k == "escape" then
		mode_manager.switch("MainMenu")
    end

	asciikey = string.byte(k, 1)
    if asciikey >= 97 and asciikey <= 122 then
		consoleHistory[line] = consoleHistory[line] .. k
    elseif asciikey >= 65 and asciikey <= 90 then
		consoleHistory[line] = consoleHistory[line] .. k
    elseif asciikey == 32 then
		consoleHistory[line] = consoleHistory[line] .. k
	end
end

function update ()
	while line > CONSOLE_MAX do
		table.remove(consoleHistory, 1)
		line = line - 1
	end
end

function line_handle()
	local i = 1
	while commands[i] ~= nil do
		print(commands[i])
		if ">" .. commands[i][1] == consoleHistory[line] then
			commands[i][2]()
			return
		end
		i = i + 1
	end
end