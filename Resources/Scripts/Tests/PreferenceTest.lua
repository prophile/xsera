import('GlobalVars')
import('PrintRecursive')

local messages = { "Press ESC to go to main menu" }

function addMessage(msg)
	messages[#messages + 1] = msg
end

function init()
	local camera = { w = 800, h = 600 }
	graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function update()
	
end

function render()
	graphics.begin_frame()
	if messages ~= nil then
		for i = 1, #messages do
			graphics.draw_text(messages[i], MAIN_FONT, "center", { x = 0, y = 300 - 30 * i }, 25)
		end
	end
	graphics.end_frame()
end

function key(k)
	if k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	elseif k == "1" then
		preferences.set("Key/a", "Turn Counter-Clockwise")
		addMessage("Key 'a' set to 'Turn Counter-Clockwise'")
	elseif k == "2" then
		preferences.set("Screen/Width", "1025")
		addMessage("Screen/Width set to 1025")
	end
end