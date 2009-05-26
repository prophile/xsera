creditsRolling = true
totalTime = 0.0
initialDist = -200
separationDist = 9
speed = 33

credits = {}
creditSizes = {}
rowDist = {}

function init ()
	if sound.current_music() ~= "Doomtroopers" then
		sound.stop_music()
		sound.play_music("Doomtroopers")
	end
	oldTime = mode_manager.time()
	local rawInput = resource_manager.load("Config/Credits.txt")
	local i = 1
	local lastDist = initialDist
	for sizeString, line in string.gmatch(rawInput, "(%**)(.-)\n") do
		credits[i] = line
		creditSizes[i] = 30 + (10 * #sizeString)
		rowDist[i] = lastDist
		lastDist = lastDist - separationDist - creditSizes[i]
		i = i + 1
	end
end

function key ( k )
	if k == 'p' then
		if creditsRolling == true then
			creditsRolling = false
		else
			creditsRolling = true
		end
	elseif k == 'q' then
		speed = speed + 10
	elseif k == 'a' then
		speed = speed - 10
	elseif k == 'escape' then
		mode_manager.switch("MainMenu")
	end
end

function render ()
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
	for i, credit in pairs(credits) do
		if credit ~= "" then
			graphics.draw_text(credit, "CrystalClear", "center", 0, rowDist[i] + totalTime, creditSizes[i])
		end
	end
	graphics.end_frame()
end

function update ()
	local newTime = mode_manager.time()
	local dt = newTime - oldTime
	oldTime = newTime
	if creditsRolling then
		totalTime = totalTime + speed * dt
	end
	-- if totalTime > -rowDist[table.maxn(rowDist)] + 300 then
	--	mode_manager.switch("MainMenu")
	-- end
end
