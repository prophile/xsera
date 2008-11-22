-- main menu script
lastTime = 0
goodShips = {}
goodShipVelocity = { -300, 120 }
goodShipType = { "Human/Gunship", "Human/Fighter", "Human/Cruiser", "Human/Destroyer", "Human/Fighter", "Human/Gunship", "Human/AssaultTransport", "Ishiman/Fighter", "Ishiman/HeavyCruiser", "Ishiman/Gunship", "Ishiman/ResearchVessel", "Obish/Cruiser", "Ishiman/AssaultTransport", "Ishiman/Engineer", "Human/AssaultTransport", "Elejeetian/Cruiser", "Human/GateShip", "Human/Destroyer", "Ishiman/Transport" }
goodSpriteSheetX = 2
goodSpriteSheetY = 3
versionInformation = ""
timeFactor = 1.0

function sort_ships ()
    table.sort(goodShips, function (a, b) return a[4] < b[4] end)
    -- print "Sorted goodShips!"
end

function ship_speed ( type )
    local szx, szy = graphics.sprite_dimensions(type, goodSpriteSheetX, goodSpriteSheetY)
    local szt = math.sqrt(szx*szx + szy*szy)
    return 45.0 / szt
end

function random_real ( min, max )
    return (math.random() * (max - min)) + min
end

function random_ship_type ()
    return goodShipType[math.random(1, #goodShipType)]
end

for i=1,70 do
    local goodShipType = random_ship_type()
    goodShips[i] = { random_real(700, 1000), random_real(-580, 20), goodShipType, random_real(-1, 1), ship_speed(goodShipType) }
end
sort_ships()

function distancefactor ( distance )
    distance = distance + 1.3
    return distance / 1.4
end

function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-500, -240, 500, 240)
    graphics.draw_image("Bootloader/Xsera", 0, 0, 1000, 480)
    for id, goodShip in ipairs(goodShips) do
        local szx, szy = graphics.sprite_dimensions(goodShip[3], goodSpriteSheetX, goodSpriteSheetY)
        graphics.draw_sprite(goodShip[3], goodSpriteSheetX, goodSpriteSheetY, goodShip[1], goodShip[2], szx * 1.6 * distancefactor(goodShip[4]), szy * 1.6 * distancefactor(goodShip[4]))
    end
    
    graphics.draw_text(versionInformation, "CrystalClear", -340, -200, 28)
    
    graphics.end_frame()
end

function key ( k )
    if k == "i" then
        timeFactor = timeFactor + 0.05
    elseif k == "u" then
        timeFactor = timeFactor - 0.05
    else
        print("Uninterpreted keystroke " .. k)
    end
end

function update ()
	newTime = mode_manager.time()
	local dt = newTime - lastTime
	lastTime = newTime
	dt = dt * timeFactor
	local gvx = goodShipVelocity[1]
	local gvy = goodShipVelocity[2]
	-- print("Advancing simulation with timestep " .. dt .. " and velocity vector " .. gvx .. ", " .. gvy)
	local resortShips = false
	for goodShip in pairs(goodShips) do
	   goodShips[goodShip][1] = goodShips[goodShip][1] + (goodShipVelocity[1] * distancefactor(goodShips[goodShip][4]) * goodShips[goodShip][5]) * dt
	   goodShips[goodShip][2] = goodShips[goodShip][2] + (goodShipVelocity[2] * distancefactor(goodShips[goodShip][4]) * goodShips[goodShip][5]) * dt
	   if (goodShips[goodShip][1] < -560) then
	       resortShips = true
	       goodShips[goodShip][1] = random_real(520, 800)
	       goodShips[goodShip][2] = random_real(-450, 190)
	       goodShips[goodShip][3] = random_ship_type()
	       goodShips[goodShip][4] = random_real(-1, 1)
	   end
	end
	if resortShips then
	   sort_ships()
    end
end

function init ()
    local xmlData = xml.load("Config/Version.xml")
	local versionData = xmlData[1]
	versionInformation = "Xsera " .. versionData[1][1] .. " <" .. versionData[2][1] .. ">"
	print(versionInformation)
	if versionData.n == 3 then
		print("Signed off by: " .. versionData[3][1])
	end
	lastTime = mode_manager.time()
end

