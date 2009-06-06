consoleHistory = {}
line = 0

function console_add(text)
	table.insert(consoleHistory, text)
	line = line + 1
end