-- demo script = Player is Ishiman Heavy Cruiser, opponent is Gaitori Carrier.
-- Carrier has no AI, so it just sits there. Player must warp to Carrier's position
-- and can destroy it using both seeking and non-seeking weapons. Script ends when
-- Carrier is destroyed.

-- Future possible script variations =
-- Using autopilot to find Carrier.
-- Carrier has a "fleeing" AI, and runs away when attacked, possibly warping away.
-- Carrier has other AIs.
-- Implement planets.
-- Use other Heavy Cruisers (possibly built on planets) to destroy Carrier, using attack command.

spriteSheetX = 2
spriteSheetY = 3
screenSizeX = { min = 0, max = 100 } -- temporary values, unused right now
screenSizeY = { min = 0, max = 100 } -- temporary values, unused right now

ships = {}
camera = { -500, -500, 500, 500 }
carrierLocation = { 100, 50 }
carrierSize = {}
carrierSize[1], carrierSize[2] = graphics.sprite_dimensions("Gaitori/Carrier", goodSpriteSheetX, goodSpriteSheetY)
hCruiserLocation = { 0, 0 }
hCruiserSize = {}
hCruiserSize[1], hCruiserSize[2] = graphics.sprite_dimensions("Ishiman/HeavyCruiser", goodSpriteSheetX, goodSpriteSheetY)

function render ()
    graphics.begin_frame()
    
    graphics.set_camera(camera[1], camera[2], camera[3], camera[4])
    graphics.draw_image("Panels/SideLeft", camera[1] + 68, camera[2] + 501, 129, 1000)
    graphics.draw_image("Panels/SideRight", camera[3] - 14, camera[2] + 501, 27, 1000)
    graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], carrierSize[1], carrierSize[2])
    graphics.draw_sprite("Ishiman/HeavyCruiser", hCruiserLocation[1], hCruiserLocation[2], hCruiserSize[1], hCruiserSize[2])
	
    graphics.end_frame()
end

function key ( k )
	if k == "w" then
		camera[2] = camera[2] + 1
		camera[4] = camera[4] + 1
		hCruiserLocation[2] = hCruiserLocation[2] + 1;
	elseif k == "s" then
		camera[2] = camera[2] - 1
		camera[4] = camera[4] - 1
		hCruiserLocation[2] = hCruiserLocation[2] - 1;
	elseif k == "a" then
		camera[1] = camera[1] - 1
		camera[3] = camera[3] - 1
		hCruiserLocation[1] = hCruiserLocation[1] - 1;
	elseif k == "d" then
		camera[1] = camera[1] + 1
		camera[3] = camera[3] + 1
		hCruiserLocation[1] = hCruiserLocation[1] + 1;
	else
        print("Uninterpreted keystroke '" .. k .. "'")
	end
end
