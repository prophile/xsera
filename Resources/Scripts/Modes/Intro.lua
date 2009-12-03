local dt = 0
local myTime = 0
local lastTime = 0

function init()
    lastTime = mode_manager.time()
	sound.play_music("Doomtroopers")
end

function update()
	local newTime = mode_manager.time()
	
	dt = newTime - lastTime
	lastTime = newTime
end

function render()
	myTime = myTime + dt
	
    graphics.begin_frame()
	graphics.set_camera(-512, -384, 512, 384)
	if myTime < 5 then
		graphics.draw_image("Panels/BrainpenLogo", 0, 50, 512, 469)
		graphics.draw_text("Presents...", "CrystalClear", "center", 0, -210, 50)
	elseif myTime < 10 then
		graphics.draw_text("Based upon", "CrystalClear", "center", 0, 300, 50)
		graphics.draw_image("Panels/NLCredits", 0, 230, 160, 36)
		graphics.draw_text("Produced by", "CrystalClear", "center", 0, 180, 50)
		graphics.draw_image("Panels/AmbrosiaLogo", 0, -30, 259, 312)
	elseif myTime < 17 then
		graphics.draw_image("Panels/XseraLogo", 0, -200, 653, 93) -- this area needs more
	else
		mode_manager.switch("MainMenu")
	end
    graphics.end_frame()
end

function key(k)
	if myTime < 5 then
		myTime = 4
	elseif myTime < 10 then
		myTime = 9
	else
		myTime = 16
	end
end