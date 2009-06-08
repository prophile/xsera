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
		graphics.draw_box(320, -400, 105, 400, 0, 0, 0, 0, 1)
		console_draw(12)
	end
	while line > CONSOLE_MAX do
		table.remove(consoleHistory, 1)
		line = line - 1
	end
end