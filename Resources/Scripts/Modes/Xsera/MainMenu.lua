import('GlobalVars')

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
    shipType = { "Gaitori/Gunship", "Gaitori/Fighter", "Gaitori/Cruiser", "Gaitori/Destroyer", "Gaitori/Fighter", "Gaitori/Gunship", "Gaitori/AssaultTransport", "Cantharan/Fighter", "Cantharan/HeavyCruiser", "Cantharan/Gunship", "Cantharan/Drone", "Cantharan/HeavyCruiser", "Cantharan/AssaultTransport", "Cantharan/Engineer", "Audemedon/Cruiser", "Cantharan/Engineer", "Audemedon/Destroyer", "Cantharan/Transport", "Salrilian/Carrier", "Audemedon/Carrier", "Cantharan/Fighter", "Cantharan/HeavyCruiser", "Salrilian/Fighter", "Gaitori/Fighter", "Cantharan/HeavyDestroyer", "Salrilian/Destroyer", "Cantharan/Fighter", "Cantharan/Fighter", "Salrilian/Fighter", "Audemedon/Fighter", "Audemedon/Fighter", "Cantharan/Fighter", "Cantharan/Schooner", "Salrilian/Fighter", "Salrilian/Fighter", "Salrilian/Fighter", "Salrilian/AssaultTransport" }
    numShips = 50
end
versionInformation = ""
timeFactor = 1.0
sizeFactor = 1.0

function SortShips ()
    table.sort(ships, function (a, b) return a[4] < b[4] end)
    -- print "Sorted ships!"
end

function ShipSpeed ( type )
    local sz = graphics.sprite_dimensions("Ships/" .. type)
    local szt = math.sqrt(sz.x*sz.x + sz.y*sz.y)
    return 45.0 / szt
end

function RandomShipType ()
    return shipType[math.random(1, #shipType)]
end

for i=1,numShips do
    local shipType = RandomShipType()
    if allies then
        ships[i] = { RandomReal(700, 1000), RandomReal(-580, 20), shipType, RandomReal(-1, 1), ShipSpeed(shipType) }
    else
        ships[i] = { RandomReal(-700, -1000), RandomReal(580, -20), shipType, RandomReal(-1, 1), ShipSpeed(shipType) }
    end
end
SortShips()

function DistanceFactor ( distance )
    distance = distance + 1.3
    return distance / 1.4
end

function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-240 * aspectRatio, -240, 240 * aspectRatio, 240)
    graphics.draw_image("Bootloader/Xsera", vec(0, 0), { x = 480 * aspectRatio, y = 480 })
    for id, ship in ipairs(ships) do
        local sz = graphics.sprite_dimensions("Ships/" .. ship[3], goodSpriteSheetX, goodSpriteSheetY)
        graphics.draw_sprite("Ships/" .. ship[3], { x = ship[1], y = ship[2] }, { x = sz.x * sizeFactor * DistanceFactor(ship[4]), y = sz.y * sizeFactor * DistanceFactor(ship[4])}, math.atan2(shipVelocity[2], shipVelocity[1]))
    end
    
    graphics.draw_text("D - Demo", MAIN_FONT, "left", { x = -240 * aspectRatio + 30, y = 0 }, 45)
    graphics.draw_text("C - Credits", MAIN_FONT, "left", { x = -240 * aspectRatio + 30, y = -50 }, 45)
    
    graphics.draw_text(versionInformation, MAIN_FONT, "left", { x = -240 * aspectRatio + 10, y = -220 }, 20)
    
    graphics.draw_text("Level selected: " .. demoLevel .. " (" .. data.scenarios[demoLevel].name ..")", MAIN_FONT, "right", { x = 240 * aspectRatio - 10, y = 220 }, 30)
    graphics.end_frame()
end

function key ( k )
    if k == "x" then
        if RELEASE_BUILD == true then
            mode_manager.switch("Ares/Splash")
        else -- debug build tests
            mode_manager.switch("../Tests/TestMenu")
        end
    elseif k == "i" then
        timeFactor = timeFactor + 0.05
    elseif k == "u" then
        timeFactor = timeFactor - 0.05
    elseif k == "l" then
        sizeFactor = sizeFactor + 0.1
    elseif k == "k" then
        sizeFactor = sizeFactor - 0.1
    elseif k == "d" then
        mode_manager.switch("Demo4")
    elseif k == "c" then
        mode_manager.switch("Xsera/Credits")
    elseif k == "tab" then
        mode_manager.switch("Ares/Splash")
    elseif k == "escape" then
        mode_manager.quit()
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
        ships[ship][1] = ships[ship][1] + (shipVelocity[1] * DistanceFactor(ships[ship][4]) * ships[ship][5]) * dt
        ships[ship][2] = ships[ship][2] + (shipVelocity[2] * DistanceFactor(ships[ship][4]) * ships[ship][5]) * dt
        if (ships[ship][1] < -800 or ships[ship][1] > 800) then
            resortShips = true
            if allies then
                ships[ship][1] = RandomReal(520, 800)
                ships[ship][2] = RandomReal(-450, 190)
            else
                ships[ship][1] = RandomReal(-520, -800)
                ships[ship][2] = RandomReal(450, -190)
            end
            ships[ship][3] = RandomShipType()
            ships[ship][4] = RandomReal(-1, 1)
        end
    end
    if resortShips then
        SortShips()
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
    print(sound.current_music())
    if sound.current_music() ~= "Doomtroopers" then
        sound.play_music("FRED")
    end
end

