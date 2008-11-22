-- main menu script
ships = {}
lastTime = 0
shipVelocity = { -10, 4 }
spriteTypes = { "Human/Gunship", "Human/Fighter", "Human/Cruiser", "Human/Destroyer", "Human/Fighter", "Human/Gunship", "Human/AssaultTransport", "Ishiman/Fighter", "Ishiman/HeavyCruiser", "Ishiman/Gunship", "Ishiman/ResearchVessel", "Obish/Cruiser", "Ishiman/AssaultTransport", "Ishiman/Engineer", "Human/AssaultTransport", "Elejeetian/Cruiser", "Human/GateShip", "Human/Destroyer", "Ishiman/Transport" }
spriteSheetX = 2
spriteSheetY = 3
versionInformation = ""

function sort_ships ()
    table.sort(ships, function (a, b) return a[4] > b[4] end)
end

function ship_speed ( type )
    local szx, szy = graphics.sprite_dimensions(type, spriteSheetX, spriteSheetY)
    local szt = math.sqrt(szx*szx + szy*szy)
    return 45.0 / szt
end

function random_real ( min, max )
    return (math.random() * (max - min)) + min
end

function random_ship_type ()
    return spriteTypes[math.random(1, #spriteTypes)]
end

for i=1,70 do
    local shipType = random_ship_type()
    ships[i] = { random_real(700, 1000), random_real(-580, 20), shipType, random_real(-1, 1), ship_speed(shipType) }
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
    for id, ship in ipairs(ships) do
        local szx, szy = graphics.sprite_dimensions(ship[3], spriteSheetX, spriteSheetY)
        graphics.draw_sprite(ship[3], spriteSheetX, spriteSheetY, ship[1], ship[2], szx * 1.6 * distancefactor(ship[4]), szy * 1.6 * distancefactor(ship[4]))
    end
    
    graphics.draw_text(versionInformation, "CrystalClear", -340, -200, 28)
    
    graphics.end_frame()
end

function update ()
	newTime = mode_manager.time()
	local dt = newTime - lastTime
	lastTime = newTime
	local gvx = shipVelocity[1]
	local gvy = shipVelocity[2]
	-- print("Advancing simulation with timestep " .. dt .. " and velocity vector " .. gvx .. ", " .. gvy)
	local resortShips = false
	for ship in pairs(ships) do
	   ships[ship][1] = ships[ship][1] + (shipVelocity[1] * distancefactor(ships[ship][4]) * ships[ship][5])
	   ships[ship][2] = ships[ship][2] + (shipVelocity[2] * distancefactor(ships[ship][4]) * ships[ship][5])
	   if (ships[ship][1] < -560) then
	       resportShips = true
	       ships[ship][1] = random_real(520, 800)
	       ships[ship][2] = random_real(-450, 190)
	       ships[ship][3] = random_ship_type()
	       ships[ship][4] = random_real(-1, 1)
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
end

function key ( k )
	if (k == " ") then
		mode_manager.switch("Demo")
	end
    print(k)
end
