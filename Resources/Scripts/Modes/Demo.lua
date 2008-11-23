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
screenSizeX = { min = 0, max = 100 } -- temporary values
screenSizeY = { min = 0, max = 100 } -- temporary values

ships = {}
camera = { -500, -240, 500, 240 }
carrierLocation = { 100, 50 }
carrierSize = { 70, 49 }
hCruiserLocation = { -100, 0 }
hCruiserSize = { 35, 31 }

function render ()
    graphics.begin_frame()
    
    graphics.set_camera(camera[1], camera[2], camera[3], camera[4])
    graphics.draw_image("Panels/SideLeft", -430, 1, 129, 480)
    graphics.draw_image("Panels/SideRight", 430, 1, 129, 480)
    graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], carrierSize[1], carrierSize[2])
    graphics.draw_sprite("Ishiman/HeavyCruiser", hCruiserLocation[1], hCruiserLocation[2], hCruiserSize[1], hCruiserSize[2])
	
    graphics.end_frame()
end
