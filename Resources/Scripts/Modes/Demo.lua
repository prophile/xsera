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
camera = { width = 1000, height = 1000 }
carrierLocation = { 100, 50 }
carrierRotation = 0
carrierSize = {}
carrierSize[1], carrierSize[2] = graphics.sprite_dimensions("Gaitori/Carrier")
hCruiserRotation = 0
hCruiserSize = {}
hCruiserSize[1], hCruiserSize[2] = graphics.sprite_dimensions("Ishiman/HeavyCruiser")
velocity = { increment = { current = 0, x = 0, y = 0 }, real = { speed = 0, x = 0, y = 0 }, increase = 0.5, decrease = -2, max = 5 }
ship = { x = 0, y = 0 }

function render ()
    graphics.begin_frame()
	
	velocity.increment.x = math.cos(hCruiserRotation) * velocity.increment.current
	velocity.increment.y = math.sin(hCruiserRotation) * velocity.increment.current
	
	velocity.real.x = velocity.increment.x + velocity.real.x
	velocity.real.y = velocity.increment.y + velocity.real.y
	
	ship.x = ship.x + velocity.real.x
	ship.y = ship.y + velocity.real.y
	
	velocity.increment.current = 0;
	
	if velocity.real.speed > velocity.max then
		velocity.real.speed = velocity.max
	end
	
	graphics.set_camera(ship.x - (camera.width / 2.0), ship.y - (camera.height / 2.0), ship.x + (camera.width / 2.0), ship.y + (camera.width / 2.0))
    graphics.draw_sprite("Gaitori/Carrier", carrierLocation[1], carrierLocation[2], carrierSize[1], carrierSize[2], carrierRotation)
    graphics.draw_sprite("Ishiman/HeavyCruiser", ship.x, ship.y, hCruiserSize[1], hCruiserSize[2], hCruiserRotation)
	
    graphics.draw_image("Panels/SideLeft", -(camera.width / 2) + 68 + ship.x, -(camera.height / 2) + 501 + ship.y, 129, 1000)
    graphics.draw_image("Panels/SideRight", 484 + ship.x, 1 + ship.y, 27, 1000)
    graphics.end_frame()
end

function key ( k )
	if k == "w" then
		velocity.increment.current = velocity.increase;
	elseif k == "s" then
		velocity.increment.current = velocity.decrease;
	elseif k == "a" then
		hCruiserRotation = (hCruiserRotation + .2) % (2 * math.pi)
	elseif k == "d" then
		hCruiserRotation = (hCruiserRotation - .2) % (2 * math.pi)
	elseif k == "q" then
		hCruiserRotation = math.pi / 2
	elseif k == "e" then
		sound.play("ShotC")
	end
end
