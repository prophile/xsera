-- physics tests

import('GlobalVars')
import('PrintRecursive')
import('Physics')

local messages = { "Velocity X:", "Velocity Y:", "Position X:", "Position Y:", "Press ESC to go to main menu" }
local objects = {}
local dt = 0
local st = 0
local lastTime = 0
local testSelected = false
local testNum = 0
local forceToApply = vec(0, 0)

function addMessage(msg)
	messages[#messages + 1] = msg
end

function addObject(obj)
	if objects ~= {} then
		objects[#objects + 1] = obj
	else
		objects = { obj }
	end
end

function init()
	local camera = { w = 800, h = 600 }
	graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function update()
	local newTime = mode_manager.time()
	dt = newTime - lastTime
	lastTime = newTime
	st = st + dt
	
	if #messages >= 7 and st > 0.1 then
		st = st % 0.1
		if testNum == "1" then
			messages[1] = string.format("VELOCITY X: %f", objects[1].velocity.x)
			messages[2] = string.format("VELOCITY Y: %f", objects[1].velocity.y)
		else
			objects[1].force = objects[1].force + forceToApply
			messages[1] = string.format("FORCE X: %.2f", objects[1].force.x)
			messages[2] = string.format("FORCE Y: %.2f", objects[1].force.y)
		end
		messages[3] = string.format("POSITION X: %.2f", objects[1].position.x)
		messages[4] = string.format("POSITION Y: %.2f", objects[1].position.y)
	end
	
	Physics.UpdateSystem(dt, objects)
end

function render()
	graphics.begin_frame()
	if messages ~= nil then
		for i = 1, #messages do
			graphics.draw_text(messages[i], MAIN_FONT, "left", { x = -390, y = 320 - 40 * i }, 30)
		end
	end
	graphics.end_frame()
end

function key(k)
	if not testSelected then
		if k == "escape" then
			mode_manager.switch("Xsera/MainMenu")
		elseif k == "1" or k == "2" then
			testSelected = true
			testNum = k
		end
		return
	end
	
	if k == "escape" then
		mode_manager.switch("Xsera/MainMenu")
	elseif testNum == "1" then
		test1(k)
	elseif testNum == "2" then
		test2(k)
	end
end

function test1(k)
	print(k)
	if k == "1" then
		addMessage("Creating system without gravity.")
		Physics.NewSystem()
	elseif k == "2" then
		addMessage("Creating object of mass 1, velocity and position (0, 0).")
		addObject(Physics.NewObject())
	elseif k == "3" then
		objects[1].velocity = objects[1].velocity + vec(0, .1)
	elseif k == "4" then
		objects[1].velocity = objects[1].velocity + vec(.1, 0)
	end
end

function test2(k)
	if k == "1" then
		addMessage("Creating system with Earth gravity straight down.")
		Physics.NewSystem(vec(0, -9.8))
	elseif k == "2" then
		addMessage("Creating object of mass 10, velocity and position (0, 0).")
		addObject(Physics.NewObject(10, vec(0, 0), vec(0, 0)))
	elseif k == "3" then
		forceToApply = forceToApply + vec(0, .1)
	elseif k == "4" then
		forceToApply = forceToApply + vec(.1, 0)
		objects[1].force = objects[1].force + vec(.1, 0)
	end
end