import('Console')

consoleDraw = false

function popDownConsole()
	if (consoleDraw == false) and (key == console_key) then
		key = normal_key
	end
	if consoleDraw == true and key == normal_key then
		popDown = true
		console_add("$Loading console...")
		setNewPrint()
		CONSOLE_MAX = 13
		keyup = console_keyup
		key = console_key
		console_add("$Console loaded.")
		console_add(">")
	end
	if consoleDraw == true then
		graphics.draw_box(320, -400, 105, 400, 2, clut_colour(1, 17))
		console_draw(12)
		while line > CONSOLE_MAX do
			table.remove(consoleHistory, 1)
			line = line - 1
			line_focus = line
		end
	end
end