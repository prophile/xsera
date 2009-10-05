import('Console')

consoleDraw = false

function popDownConsole()
	if (consoleDraw == false) and (key == ConsoleKey) then
		key = normal_key
	end
	if consoleDraw == true and key == normal_key then
		isPopDown = true
		ConsoleAdd("$Loading console...")
		SetNewPrint()
		CONSOLE_MAX = 13
		keyup = ConsoleKeyup
		key = ConsoleKey
		ConsoleAdd("$Console loaded.")
		ConsoleAdd(">")
	end
	if consoleDraw == true then
		graphics.draw_box(320, -400, 105, 400, 2, ClutColour(1, 17))
		ConsoleDraw(12)
		while line > CONSOLE_MAX do
			table.remove(consoleHistory, 1)
			line = line - 1
			lineFocus = line
		end
	end
end