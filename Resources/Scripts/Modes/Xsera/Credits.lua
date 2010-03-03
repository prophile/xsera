creditsRolling = true
totalTime = 0.0
initialDist = -200
separationDist = 9
speed = 33

simpleCreditSizeBase = 20
simpleCreditSizeScale = 8
simpleCreditFont = "prototype"
titleCreditSizeBase = 20
titleCreditSizeScale = 6
titleCreditFont = "sneakout"
MAIN_FONT = "sneakout"

credits = {}
creditSizes = {}
creditFonts = {}
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
		if #sizeString > 0 then
			creditSizes[i] = titleCreditSizeBase + (titleCreditSizeScale * #sizeString)
			creditFonts[i] = titleCreditFont
			rowDist[i] = lastDist
			lastDist = lastDist - separationDist - creditSizes[i]
		else
			creditSizes[i] = simpleCreditSizeBase + (titleCreditSizeScale * #sizeString)
			creditFonts[i] = simpleCreditFont
			rowDist[i] = lastDist
			lastDist = lastDist - separationDist - creditSizes[i]
		end
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
		mode_manager.switch("Xsera/MainMenu")
	end
end

function render ()
	local starfieldOffset = totalTime * 2.2
	graphics.begin_frame()
	graphics.set_camera(-320, -240 + starfieldOffset, 320, 240 + starfieldOffset)
	graphics.draw_starfield(3.4)
	graphics.draw_starfield(1.8)
	graphics.draw_starfield(0.6)
	graphics.draw_starfield(-0.3)
	graphics.draw_starfield(-0.9)
	graphics.set_camera(-320, -240, 320, 240)
	for i, credit in pairs(credits) do
		if credit ~= "" then
			graphics.draw_text(credit, creditFonts[i], "center", { x = 0, y = rowDist[i] + totalTime } , creditSizes[i])
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
	--	mode_manager.switch("Xsera/MainMenu")
	-- end
end
