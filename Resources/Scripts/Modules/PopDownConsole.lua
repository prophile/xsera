import('Console')
import('Camera')

consoleDraw = false

function PopDownConsole()
	if (consoleDraw == false) and (key == ConsoleKey) then
		key = normal_key
		keyup = normal_keyup
		ConsoleAdd("$Leaving console...")
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
		local cam = CameraToWindow()
		graphics.set_camera(cam[1], cam[2], cam[3], cam[4])
		graphics.draw_box(cam[4], cam[1], cam[4] - (CONSOLE_MAX - 1) * FONT_SIZE, cam[3], 2, ClutColour(1, 17))
		ConsoleDraw(CONSOLE_MAX)
		while line > CONSOLE_MAX do
			table.remove(consoleHistory, 1)
			line = line - 1
			lineFocus = line
		end
	end
end