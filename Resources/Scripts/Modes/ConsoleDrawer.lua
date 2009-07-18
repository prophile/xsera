import('Console')

function init ()
	console_add("$Loading console...")
	sound.stop_music()
	setNewPrint()
	CONSOLE_MAX = 18
	console_add("$Console loaded.")
	console_add(">")
end

function render ()
    graphics.begin_frame()
	console_draw(20)
    graphics.end_frame()
end

function key (k)
	console_key(k)
end

function keyup (k)
	console_keyup(k)
end

function update ()
	while line > CONSOLE_MAX do
		table.remove(consoleHistory, 1)
		line = line - 1
	end
end