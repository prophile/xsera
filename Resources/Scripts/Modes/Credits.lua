creditsRolling = true
totalTime = 0.0
regularDist = -32
titleDist = -40
headerDist = -35
mainDist = -50
initialDist = -200
speed = 25

rowDist = {}
rowDist[1] = initialDist
rowDist[2] = rowDist[1] + mainDist
rowDist[3] = rowDist[2] + regularDist
rowDist[4] = rowDist[3] + regularDist

rowDist[5] = rowDist[4] + titleDist
rowDist[6] = rowDist[5] + regularDist
rowDist[7] = rowDist[6] + regularDist
rowDist[8] = rowDist[7] + regularDist

rowDist[9] = rowDist[8] + titleDist
rowDist[10] = rowDist[9] + regularDist

rowDist[11] = rowDist[10] + titleDist
rowDist[12] = rowDist[11] + regularDist

rowDist[13] = rowDist[12] + titleDist
rowDist[14] = rowDist[13] + regularDist
rowDist[15] = rowDist[14] + headerDist
rowDist[16] = rowDist[15] + regularDist

function init ()
    sound.play_music("Doomtroopers")
	oldTime = mode_manager.time()
end

function key ( k )
	if k == 'p' then
		if creditsRolling  == true then
			creditsRolling = false
		else
			creditsRolling = true
		end
	elseif k == 'q' then
		speed = speed + 10
	elseif k == 'a' then
		speed = speed - 10
	end
end

function render ()
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
	graphics.draw_text("Xsera", "CrystalClear", 0, rowDist[1] + totalTime, 60)
	graphics.draw_text("A Brainpen Production", "CrystalClear", 0, rowDist[2] + totalTime, 30)
	graphics.draw_text("Based on the game 'Ares' by Nathan Lamont", "CrystalClear", 0, rowDist[3] + totalTime, 30)
	graphics.draw_text("Copyright 1997-2001, 2008", "CrystalClear", 0, rowDist[4] + totalTime, 30)
	
	graphics.draw_text("Programmers", "CrystalClear", 0, rowDist[5] + totalTime, 40)
	graphics.draw_text("Alistair 'Prophile' Lynn", "CrystalClear", 0, rowDist[6] + totalTime, 30)
	graphics.draw_text("Adam 'adam_0' Hintz", "CrystalClear", 0, rowDist[7] + totalTime, 30)
	graphics.draw_text("Andrew 'LANS' Moscoe", "CrystalClear", 0, rowDist[8] + totalTime, 30)
	
	graphics.draw_text("Coordinator", "CrystalClear", 0, rowDist[9] + totalTime, 40)
	graphics.draw_text("Nick 'cia_man' Farley", "CrystalClear", 0, rowDist[10] + totalTime, 30)
	
	graphics.draw_text("Contact to Nathan Lamont", "CrystalClear", 0, rowDist[11] + totalTime, 40)
	graphics.draw_text("'redsteven'", "CrystalClear", 0, rowDist[12] + totalTime, 30)
	
	graphics.draw_text("Graphics Artists", "CrystalClear", 0, rowDist[13] + totalTime, 40)
	graphics.draw_text("All original graphics copyright Nathan Lamont", "CrystalClear", 0, rowDist[14] + totalTime, 30)
	graphics.draw_text("Weapons and Shields", "CrystalClear", 0, rowDist[15] + totalTime, 35)
	graphics.draw_text("'DarkRevenant'", "CrystalClear", 0, rowDist[16] + totalTime, 30)
	graphics.end_frame()
end

function update ()
	local newTime = mode_manager.time()
	local dt = newTime - oldTime
	oldTime = newTime
	if creditsRolling then
	   totalTime = totalTime + speed * dt
    end
	if totalTime > -rowDist[16] + 300 then
        mode_manager.switch("MainMenu")
	end
end
