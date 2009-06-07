consoleHistory = {}
line = 0


function c_return()
	mode_manager.switch("MainMenu")
end

function c_load()
	
end

function sc_load_demo()
	mode_manager.switch("Demo2")
end

commands = {
			{ "return", c_return },
			{ "load demo", sc_load_demo } }


function console_add(text)
	table.insert(consoleHistory, text)
	line = line + 1
end