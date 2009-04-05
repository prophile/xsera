-- main menu script
lastTime = 0
ships = {}
math.randomseed(os.time())
math.random()
if (math.random() < 0.5) then
    -- allied ships going to war
    allies = true
    shipVelocity = { -340, 70 }
    shipType = { "Human/Gunship", "Human/Fighter", "Human/Cruiser", "Human/Destroyer", "Human/Fighter", "Human/Gunship", "Human/AssaultTransport", "Ishiman/Fighter", "Ishiman/HeavyCruiser", "Ishiman/Gunship", "Ishiman/ResearchVessel", "Obish/Cruiser", "Ishiman/AssaultTransport", "Ishiman/Engineer", "Human/AssaultTransport", "Elejeetian/Cruiser", "Human/GateShip", "Human/Destroyer", "Ishiman/Transport", "Human/Carrier", "Ishiman/Carrier", "Ishiman/Fighter", "Ishiman/HeavyCruiser", "Ishiman/Fighter", "Ishiman/Fighter", "Ishiman/HeavyCruiser", "Human/Cruiser", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/Fighter", "Human/AssaultTransport" }
    numShips = 150
else
    -- oppressive axis ships invading
    shipVelocity = { 340, -70 }
    allies = false
    shipType = { "Gaitori/Gunship", "Gaitori/Fighter", "Gaitori/Cruiser", "Gaitori/Destroyer", "Gaitori/Fighter", "Gaitori/Gunship", "Gaitori/AssaultTransport", "Cantharan/Fighter", "Cantharan/HeavyCruiser", "Cantharan/Gunship", "Cantharan/Drone", "Cantharan/HeavyCruiser", "Cantharan/AssaultTransport", "Cantharan/Engineer", "Human/AssaultTransport", "Audemedon/Cruiser", "Cantharan/Engineer", "Audemedon/Destroyer", "Cantharan/Transport", "Salrilian/Carrier", "Audemedon/Carrier", "Cantharan/Fighter", "Cantharan/HeavyCruiser", "Salrilian/Fighter", "Gaitori/Fighter", "Cantharan/HeavyDestroyer", "Salrilian/Destroyer", "Cantharan/Fighter", "Cantharan/Fighter", "Salrilian/Fighter", "Audemedon/Fighter", "Audemedon/Fighter", "Cantharan/Fighter", "Cantharan/Schooner", "Salrilian/Fighter", "Salrilian/Fighter", "Salrilian/Fighter", "Salrilian/AssaultTransport" }
    numShips = 50
end
versionInformation = ""
timeFactor = 1.0
sizeFactor = 1.0

function sort_ships ()
    table.sort(ships, function (a, b) return a[4] < b[4] end)
    -- print "Sorted ships!"
end

function ship_speed ( type )
    local szx, szy = graphics.sprite_dimensions(type)
    local szt = math.sqrt(szx*szx + szy*szy)
    return 45.0 / szt
end

function random_real ( min, max )
    return (math.random() * (max - min)) + min
end

function random_ship_type ()
    return shipType[math.random(1, #shipType)]
end

for i=1,numShips do
    local shipType = random_ship_type()
    if allies then
        ships[i] = { random_real(700, 1000), random_real(-580, 20), shipType, random_real(-1, 1), ship_speed(shipType) }
    else
        ships[i] = { random_real(-700, -1000), random_real(580, -20), shipType, random_real(-1, 1), ship_speed(shipType) }
    end
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
        local szx, szy = graphics.sprite_dimensions(ship[3], goodSpriteSheetX, goodSpriteSheetY)
        graphics.draw_sprite(ship[3], ship[1], ship[2], szx * sizeFactor * distancefactor(ship[4]), szy * sizeFactor * distancefactor(ship[4]), math.atan2(shipVelocity[2], shipVelocity[1]))
    end
    
    graphics.draw_text("D - Demo", "CrystalClear", -332, 0, 60)
    graphics.draw_text("T - Test", "CrystalClear", -349, -50, 60)
    graphics.draw_text("C - Credits", "CrystalClear", -318, -100, 60)
    
    graphics.draw_text(versionInformation, "CrystalClear", -340, -200, 28)
	
    graphics.end_frame()
end

function key ( k )
    if k == "i" then
        timeFactor = timeFactor + 0.05
    elseif k == "u" then
        timeFactor = timeFactor - 0.05
    elseif k == "l" then
        sizeFactor = sizeFactor + 0.1
    elseif k == "k" then
        sizeFactor = sizeFactor - 0.1
    elseif k == "d" then
        mode_manager.switch("Demo2")
    elseif k == "t" then
        mode_manager.switch("AngleTest")
    elseif k == "c" then
        mode_manager.switch("Credits")
    elseif k == "tab" then
        mode_manager.switch("Demo1")
    else
        print("Uninterpreted keystroke " .. k)
    end
end

function update ()
    newTime = mode_manager.time()
    local dt = newTime - lastTime
    lastTime = newTime
    dt = dt * timeFactor
    local gvx = shipVelocity[1]
    local gvy = shipVelocity[2]
    -- print("Advancing simulation with timestep " .. dt .. " and velocity vector " .. gvx .. ", " .. gvy)
    local resortShips = false
    for ship in pairs(ships) do
        ships[ship][1] = ships[ship][1] + (shipVelocity[1] * distancefactor(ships[ship][4]) * ships[ship][5]) * dt
        ships[ship][2] = ships[ship][2] + (shipVelocity[2] * distancefactor(ships[ship][4]) * ships[ship][5]) * dt
        if (ships[ship][1] < -800 or ships[ship][1] > 800) then
            resortShips = true
            if allies then
                ships[ship][1] = random_real(520, 800)
                ships[ship][2] = random_real(-450, 190)
            else
                ships[ship][1] = random_real(-520, -800)
                ships[ship][2] = random_real(450, -190)
            end
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
    lastTime = mode_manager.time()
	if sound.current_music() ~= "Doomtroopers" then
		sound.play_music("Doomtroopers")
	end
end

