-- Text tests. Will be changed from time to time, perhaps eventually removed if
-- there is no longer any need for them

import('TextManip')
import('PrintRecursive')

function test1()
	message = { "RUNNING TEST 1." }
	printTable(message)
	local i = 2
	local result
	result, numLines = textWrap("This is some sampler text that is longer than we want it to be. It should be shortened up, heh", "CrystalClear", 40, 700)
--	result, numLines = textWrap("This is some sample text", "CrystalClear", 40, 700)
	
	print(numLines)
	printTable(result)
	if numLines > 1 then
		for j = 1, #result do
			message[i] = result[j]
			i = i + 1
		end
	else
		message[i] = result
		i = i + 1
	end
	
	message[i] = "END OF TEST 1."
	printTable(message)
end

function key(k)
	if k == "1" then
		test1()
	elseif k == "2" then
		test2()
	elseif k == "3" then
		test3()
	elseif k == "4" then
		test4()
	elseif k == "5" then
		test5()
	elseif k == "6" then
		test6()
	elseif k == "7" then
		test7()
	elseif k == "8" then
		test8()
	elseif k == "9" then
		test9()
	elseif k == "0" then
		test0()
	elseif k == "escape" then
		mode_manager.switch('Xsera/MainMenu')
	end
end

function init(tabl)
	if tabl ~= nil then
		printTable(tabl)
	end
	local camera = { w = 800, h = 600 }
	graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function update()
	
end

function render()
	graphics.begin_frame()
	graphics.draw_text("ESC to go to main screen", "CrystalClear", "center", { x = 0, y = 240 }, 40)
	if message ~= nil then
		for i = 1, #message do
			graphics.draw_text(message[i], "CrystalClear", "center", { x = 0, y = 200 - 40 * i }, 30)
		end
	end
	graphics.end_frame()
end