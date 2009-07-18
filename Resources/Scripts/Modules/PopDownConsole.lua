import('Console')

consoleDraw = false

function popDownConsole()
	if consoleDraw == false and key == console_key then
		key = normal_key
	end
	if consoleDraw == true and key == normal_key then
		console_add("$Loading console...")
		CONSOLE_MAX = 13
		console_add("$Console loaded.")
		console_add(">")
		key = console_key
	end
	if consoleDraw == true then
		graphics.draw_box(320, -400, 105, 400, 2, 0, 0, 0, 1)
		console_draw(12)
	end
	while line > CONSOLE_MAX do
		table.remove(consoleHistory, 1)
		line = line - 1
		line_focus = line
	end
end

function errLog(text, level)
	console_add(text .. "(level " .. level .. ")")
	if level > 10 then
		os.exit()
	end
	if level > 5 then
		-- display on screen
	end
end

--[[ error level scheme:
	1-5: non-fatal, continue
		1: code not implemented
		2: load error
	6-10: non-fatal, display on screen (not yet implemented)
	11-15: fatal, exit
		11: Improper input - data is not of the correct type
		12: No input given - file is missing necessary data
--]]