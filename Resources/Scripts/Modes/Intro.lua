import("GlobalVars")

local dt = 0
local myTime = 0
local lastTime = 0

function init()
	sound.play_music("Doomtroopers")
    lastTime = mode_manager.time()
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
		graphics.draw_text("Presents...", "CrystalClear", "center", 0, -215, 50)
	elseif myTime < 10 then
		graphics.draw_text("Based upon", "CrystalClear", "center", 0, 250, 50)
		graphics.draw_image("Panels/NLCredits", 0, 180, 160, 36)
		graphics.draw_text("Produced by", "CrystalClear", "center", 0, 130, 50)
		graphics.draw_image("Panels/AmbrosiaLogo", 0, -80, 259, 312)
	elseif myTime < 17 then
		graphics.draw_image("Panels/XseraLogo", 0, -220, 653, 93) -- this area needs more
	else
		mode_manager.switch("MainMenu")
	end
    graphics.end_frame()
end

function key(k)
	if myTime < 4 then
		myTime = 4.5
	elseif myTime < 9 then
		myTime = 9.5
	elseif myTime < 16 then
		myTime = 16
	end
end