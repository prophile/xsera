-- client-server tests. If you add tests, please put descriptions of what the test does

import('Networking')

-- this test checks very basic local message functionality using strings as messages.
-- this test will be unusable when messages become something more complex.
function test1()
	message = "RUNNING TEST 1."
	print(message)
	
	--/CLIENT/
	client.addMsg("MESSAGE 1")
	client.addMsg("MESSAGE 2")
	multiMessage = { "MESSAGE 3", "MESSAGE 4", "MESSAGE 5" }
	client.addMsg(multiMessage)
	
	--/SERVER/
	if server.receivedMsg() then
		print("SERVER HAS RECEIVED MESSAGES")
		serverMessages = server.readMsg()
		for i = 1, #serverMessages do
			print("'" .. serverMessages[i] .. "' is a message from the server")
		end
		printTable(serverMessages)
	else
		print("SERVER HAS NOT RECEIVED MESSAGES")
	end
	
	message = "END OF TEST 1."
	print(message)
end

function servConcatReturn1(msg)
	return msg .. "<< Server received this message"
end

function key(k)
	if k == "1" then
		test1()
	elseif k == "2" then
		
	elseif k == "3" then
		
	elseif k == "4" then
		
	elseif k == "5" then
		
	elseif k == "6" then
		
	elseif k == "7" then
		
	elseif k == "8" then
		
	elseif k == "9" then
		
	elseif k == "0" then
		
	elseif k == "escape" then
		mode_manager.switch('MainMenu')
	end
end

function init()
	local camera = { w = 800, h = 600 }
	graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function update()
	
end

function render()
	graphics.begin_frame()
	graphics.draw_text("ESC to go to main screen", "CrystalClear", "center", { x = 0, y = 0 }, 30)
	if message ~= nil then
		graphics.draw_text(message, "CrystalClear", "center", { x = 0, y = -50 }, 30)
	end
	graphics.end_frame()
end