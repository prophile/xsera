import('Console')

function init ()
	ConsoleAdd("$Loading console...")
	sound.stop_music()
	SetNewPrint()
	CONSOLE_MAX = 18
	ConsoleAdd("$Console loaded.")
	ConsoleAdd(">")
end

function render ()
    graphics.begin_frame()
	ConsoleDraw(20)
    graphics.end_frame()
end

function key (k)
	ConsoleKey(k)
end

function keyup (k)
	ConsoleKeyup(k)
end

function update ()
	while line > CONSOLE_MAX do
		table.remove(consoleHistory, 1)
		line = line - 1
		lineFocus = line
	end
end