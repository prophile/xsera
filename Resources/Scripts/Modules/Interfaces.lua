import('GlobalVars')
import('BoxDrawing')
import('Camera')
import('TextManip')

selection = {
    control = {},
    target = {},
    lastPlanet = nil
}

setmetatable(selection, weak)

menuShift = 54
topOfMenu = -87
menuStride = -13
menuItemSelected = 1


menuBuild = { name = "BUILD",
    items = {},
    planet = nil -- this is used to check (if planet ~= lastPlanet,
                 -- we need to update the data in the items table)
}

function UpdateBuildMenu()
printTable(selection.lastPlanet.building.classes)
    menuLevel.planet = selection.lastPlanet
    for _, id in pairs(selection.lastPlanet.building.ids) do
        menuBuild.items[_] = {
            title = data.objects[id].name,
            action = DoBuildAction,
            context = {["id"] = id, planet = selection.lastPlanet}
        }
    end
    menuSelected = 1
end

function UpdateMissionStatus()
    -- [TODO] grab the mission objectives and show their status (a function has been created for this purpose)
end

menuSpecial = { name = "SPECIAL ORDERS",
    items = {
        { title = "Transfer Control",  action = DoTransferControl }, -- from KeyboardControl.lua
        { title = "Hold Position",     action = nil },
        { title = "Go To My Position", action = nil },
        { title = "Fire Weapon 1",     action = nil },
        { title = "Fire Weapon 2",     action = nil },
        { title = "Fire Special",      action = nil }
    }
}

menuMessages = { name = "MESSAGES",
    items = {
        { title = "Next Page/Clear", action = nil },
        { title = "Previous Page",   action = nil },
        { title = "Last Message",    action = nil }
    }
}

menuStatus = { name = "MISSION STATUS",
    items = {}
}

function ShowBuildMenu()
    print("Running ShowBuildMenu")
    if menuLevel.planet ~= selection.lastPlanet then
        UpdateBuildMenu()
    end
    if menuLevel.planet == nil then
        sound.play("NaughtyBeep")
        menuLevel = menuOptions
        return
    end
    -- [TODO] [ADAM] now show the stats for the selected ship
    menuLevel = menuBuild
end

menuOptions = { name = "MAIN MENU",
    items = {
        { title = "<Build>",          action = ShowBuildMenu },
        { title = "<Special Orders>", action = function() menuLevel = menuSpecial end },
        { title = "<Messages>",       action = function() menuLevel = menuMessages end },
        { title = "<Mission Status>", action = function() menuLevel = menuStatus end }
    }
}

menuLevel = menuOptions

function InterfaceDisplay(dt)
    if menu_display ~= nil then
        if menu_display == "esc_menu" then
            DrawEscapeMenu()
        elseif menu_display == "defeat_menu" then
            DrawDefeatMenu()
        elseif menu_display == "info_menu" then
            DrawInfoMenu()
        elseif menu_display == "victory_menu" then
            DrawVictoryMenu()
        elseif menu_display == "pause_menu" then
            DrawPauseMenu(dt)
        end
    end
end

function DrawEscapeMenu()
    SwitchBox( { top = 85, left = -140, bottom = -60, right = 140, boxColour = ClutColour(10, 8) } )
    graphics.draw_text("Resume, start chapter over, or quit?", MAIN_FONT, "left", { x = -125, y = 65 }, 16)
    if down.esc == true then
        SwitchBox( { xCoord = -125, yCoord = 30, length = 250, text = "Resume", boxColour = ClutLighten(ClutColour(12, 6), 1), textColour = ClutColour(12, 6), execute = nil, letter = "ESC" } )
    elseif down.esc == "act" then
        keyup = normal_keyup
        key = normal_key
        down = { esc = false, rtrn = false, q = false, o = false, caps = false }
        menu_display = nil
    else
        SwitchBox( { xCoord = -125, yCoord = 30, length = 250, text = "Resume", boxColour = ClutColour(12, 6), textColour = ClutColour(12, 6), execute = nil, letter = "ESC" } )
    end
    if down.rtrn == true then
        SwitchBox( { xCoord = -125, yCoord = 0, length = 250, text = "Start Chapter Over", boxColour = ClutLighten(ClutColour(9, 6)), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
    elseif down.rtrn == "act" then
        mode_manager.switch('Demo4')
        down.rtrn = false
    else
        SwitchBox( { xCoord = -125, yCoord = 0, length = 250, text = "Start Chapter Over", boxColour = ClutColour(9, 6), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
    end
    if down.q == true then
        SwitchBox( { xCoord = -125, yCoord = -30, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 4), textColour = ClutColour(8, 17), execute = nil, letter = "Q" } )
    elseif down.q == "act" then
        menu_display = nil
        mode_manager.switch('Xsera/MainMenu')
    else
        SwitchBox( { xCoord = -125, yCoord = -30, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 5), textColour = ClutColour(8, 5), execute = nil, letter = "Q" } )
    end
end

function DrawDefeatMenu()
    SwitchBox( { top = 85, left = -140, bottom = -60, right = 140, boxColour = ClutColour(16, 6) } )
    graphics.draw_text("You lost your Heavy Cruiser and failed.", MAIN_FONT, "left", { x = -125, y = 26 }, 16)
    graphics.draw_text("Start chapter over, or quit?", MAIN_FONT, "left", { x = -125, y = 10 }, 16)
    if down.rtrn == true then
        SwitchBox( { xCoord = -125, yCoord = -20, length = 250, text = "Start Chapter Over", boxColour = ClutLighten(ClutColour(9, 6), 1), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
    elseif down.rtrn == "act" then
        menu_display = nil
        mode_manager.switch('Demo4')
    else
        SwitchBox( { xCoord = -125, yCoord = -20, length = 250, text = "Start Chapter Over", boxColour = ClutColour(9, 6), textColour = ClutColour(9, 6), execute = nil, letter = "RTRN" } )
    end
    if down.q == true then
        SwitchBox( { xCoord = -125, yCoord = -50, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 5), textColour = ClutColour(8, 17), execute = nil, letter = "Q" } )
    elseif down.q == "act" then
        menu_display = nil
        mode_manager.switch('Xsera/MainMenu')
    else
        SwitchBox( { xCoord = -125, yCoord = -50, length = 250, text = "Quit to Main Menu", boxColour = ClutColour(8, 4), textColour = ClutColour(8, 1), execute = nil, letter = "Q" } )
    end
end

storedTime = 0.0

function DrawVictoryMenu()
    SwitchBox( { xCoord = -125, yCoord = 100, length = 290, text = " ", boxColour = ClutColour(3, 7), textColour = ClutColour(3, 7), execute = nil, letter = "Results", underbox = -100 } )
    graphics.draw_text("You did it! Congratulations!", MAIN_FONT, "left", { x = -110, y = 90 }, 16)
    SwitchBox( { top = 31, left = -75, bottom = -50, right = 115, boxColour = ClutColour(3, 7), background = ClutColour(3, 14) } )
    local startx = 113
    local starty = 28
    local xcheck = 1
    local ycheck = 1
    local xshift = 0
    local xlength = 0
    while endGameData[ycheck] ~= nil do
        local xcheck = 1
        while endGameData[ycheck][xcheck] ~= nil do
            if xcheck == 1 then
                xCoord = 121
                xlength = 64
            else
                xCoord = 60 * (3 - xcheck) + 1
                xlength = 60
            end
            if endGameData[ycheck][xcheck][1] == true then
                if endGameData[ycheck][xcheck][2] ~= cClear then
                    graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength, starty - ycheck * 15, startx - xCoord, 0, endGameData[ycheck][xcheck][2])
                    graphics.draw_text(endGameData[ycheck][xcheck][3], MAIN_FONT, "left", { x = startx - xCoord - xlength + 2, y = starty - (ycheck - 1) * 15 - 6 }, 16)
                else
                    graphics.draw_text(endGameData[ycheck][xcheck][3], MAIN_FONT, "left", { x = startx - xCoord - xlength + 2, y = starty - (ycheck - 1) * 15 - 6 }, 16)
                end
            else
                storedTime = storedTime + dt
                if storedTime >= 0.07 then
                    storedTime = storedTime - 0.07
                    if endGameData[ycheck][xcheck][1] == "inprogress" then
                        if position == nil then
                            position = 1
                        end
                        if position == 1 then
                            graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength / 2 - 5, starty - ycheck * 15, startx - xCoord - xlength / 2 + 5, 0, ClutColour(3, 7))
                            position = 2
                        elseif position == 2 then
                            graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - 10, starty - ycheck * 15, startx - xCoord, 0, ClutColour(3, 7))
                            endGameData[ycheck][xcheck][1] = true
                            position = nil
                        end
                        sound.play("ITeletype")
                    elseif endGameData[ycheck][xcheck][1] == false then
                        endGameData[ycheck][xcheck][1] = "inprogress"
                        sound.play("ITeletype")
                        graphics.draw_box(starty - (ycheck - 1) * 15, startx - xCoord - xlength, starty - ycheck * 15, startx - xCoord - xlength + 10, 0, ClutColour(3, 7))
                    end
                end
                ycheck = 5
                xcheck = 4
            end
            xcheck = xcheck + 1
        end
        ycheck = ycheck + 1
    end
end

function DrawInfoMenu()
    SwitchBox( { top = 250, left = -260, bottom = -250, right = 280, boxColour = ClutColour(1, 8) } )
    if down.esc == true then
        SwitchBox( { xCoord = -255, yCoord = -240, length = 530, text = "Done", boxColour = ClutLighten(ClutColour(1, 8)), textColour = ClutColour(1, 8), execute = nil, letter = "ESC" } )
    elseif down.esc == "act" then
        keyup = normal_keyup
        key = normal_key
        down = { esc = false, rtrn = false, q = false, o = false, caps = false }
        menu_display = nil
        return
    else
        SwitchBox( { xCoord = -255, yCoord = -240, length = 530, text = "Done", boxColour = ClutColour(1, 8), textColour = ClutColour(1, 8), execute = nil, letter = "ESC" } )
    end
    local x = 245
    local col_switch = true
    while x - 15 >= -203 do
        if col_switch == false then
            col_switch = true
            graphics.draw_box(x, -257, x - 15, 277, 0, ClutColour(16, 11))
        else
            col_switch = false
            graphics.draw_box(x, -257, x - 15, 277, 0, ClutColour(16, 12))
        end
        graphics.draw_box(x, -257, x - 15, -217, 0, ClutColour(16, 1))
        graphics.draw_box(x, 5, x - 15, 45, 0, ClutColour(16, 1))
        x = x - 15
    end
    local num = 1
    local line_num = 1
    while keyboard[num] ~= nil do
        local subnum = 1
        graphics.draw_box(line_num * -15 + 260, -257, line_num * -15 + 245, 277, 0, ClutColour(1, 8))
        graphics.draw_text(keyboard[num][1], MAIN_FONT, "left", { x = -252, y = line_num * -15 + 253 }, 16)
        line_num = line_num + 1
        local xCoord = 0
        local yShift = 0
        local adjust = 0
        local numBoxes = 1
        while keyboard[num][numBoxes] ~= nil do
            numBoxes = numBoxes + 1
        end
        local rows = math.ceil(numBoxes / 2)
        while keyboard[num][subnum + 1] ~= nil do
            if subnum % rows ~= subnum then
                xCoord = 50
                adjust = (rows - 1) * 15
            else
                adjust = 0
                xCoord = -212
            end
            graphics.draw_text(keyboard[num][subnum + 1].name, MAIN_FONT, "left", { x = xCoord, y = line_num * -15 + 254 + adjust }, 16)
            if keyboard[num][subnum + 1].key_display == nil then
                graphics.draw_text(keyboard[num][subnum + 1].key, MAIN_FONT, "center", { x = xCoord - 24, y = line_num * -15 + 254 + adjust }, 16)
            else
                graphics.draw_text(keyboard[num][subnum + 1].key_display, MAIN_FONT, "center", { x = xCoord - 24, y = line_num * -15 + 254 + adjust }, 16)
            end
            line_num = line_num + 1
            subnum = subnum + 1
        end
        if numBoxes % 2 == 0 then
            line_num = line_num - rows + 1
        else
            line_num = line_num - rows + 2
        end
        num = num + 1
    end
end

local timeElapsed = 0

function DrawPauseMenu(dt)
    if down.caps == "act" then
        menu_display = nil
        keyup = normal_keyup
        key = normal_key
        down = { esc = false, rtrn = false, q = false, o = false, caps = false }
        return
    end
    timeElapsed = timeElapsed + dt
    if timeElapsed % 0.8 > 0.4 then -- cycles between displaying and not displaying every .4 seconds
        SwitchBox( { top = 20, left = -90, bottom = -20, right = 150, boxColour = ClutColour(5, 11), background = c_half_clear } )
        graphics.draw_text("> CAPS LOCK - PAUSED <", MAIN_FONT, "center", { x = 30, y = 0 }, 23, ClutColour(5, 11))
    end
end

UpdateWindow()
radar = { top = 237, left = panels.left.center.x - 58, bottom = 127, right = panels.left.center.x + 52, width = 110, length = 110 }

function DrawRadar()
    graphics.draw_box(radar.top, radar.left, radar.bottom, radar.right, 0, ClutColour(5, 13)) -- background (dark green)
    if cameraRatio.current <= 1 / 8 then
        graphics.draw_box(radar.top, radar.left, radar.bottom, radar.right, 1, ClutColour(5, 11)) -- foreground (light green with edge)
    else
        boxSize = (cameraRatio.current * 8 - 1) / cameraRatio.current / 16
        graphics.draw_box(radar.top - radar.length * boxSize, radar.left + radar.width * boxSize, radar.bottom + radar.length * boxSize, radar.right - radar.width * boxSize, 0, ClutColour(5, 11))
    end
    
    
    local radarRange = { x = 2^11, y = 2^11 }
    for i, o in pairs(scen.objects) do
        if o ~= scen.playerShip
        and o.base.attributes["appear-on-radar"] == true
        and math.abs(o.physics.position.x - scen.playerShip.physics.position.x) < radarRange.x
        and math.abs(o.physics.position.y - scen.playerShip.physics.position.y) < radarRange.y then
            tab = { r = 0, g = 1, b = 0, a = 1 }
            placement = { x = radar.left + ((o.physics.position.x - scen.playerShip.physics.position.x) / radarRange.x + 1) * radar.width / 2, y = radar.bottom + ((o.physics.position.y - scen.playerShip.physics.position.y) / radarRange.y + 1) * radar.length / 2 }
            graphics.draw_point(placement, 10, tab)
        end
    end
end

function DrawPanels()
    UpdateWindow()
    local cam = CameraToWindow()
--    printTable(cam)
    graphics.set_camera(cam[1], cam[2], cam[3], cam[4])
    
--    printTable(panels)
    
    graphics.draw_image("Panels/SideLeftTrans", panels.left.center, { x = panels.left.width, y = panels.left.height })
    graphics.draw_image("Panels/SideRightTrans", panels.right.center, { x = panels.right.width, y = panels.right.height })
    
--[[------------------
    Right Panel
-----------------]]---
    
--    Battery (red)
    if scen.playerShip.status.battery ~= nil then
        graphics.draw_box(138, panels.right.center.x - 11, 38, panels.right.center.x, 0, ClutColour(8, 8))
        graphics.draw_box(scen.playerShip.status.battery / scen.playerShip.status.batteryMax * 100 + 38, panels.right.center.x - 11, 38, panels.right.center.x, 0, ClutColour(8, 5))
    end
--    Energy (yellow)
    if scen.playerShip.status.energy ~= nil then
        graphics.draw_box(-91, panels.right.center.x - 11, 9, panels.right.center.x, 0, ClutColour(3, 7))
        graphics.draw_box(scen.playerShip.status.energy / scen.playerShip.status.energyMax * 100 - 91, panels.right.center.x - 11, -91, panels.right.center.x, 0, ClutColour(9, 6))
    end
--    Shield (blue)
    if scen.playerShip.status.health ~= nil then
        graphics.draw_box(-219, panels.right.center.x - 11, -119, panels.right.center.x, 0, ClutColour(14, 8))
        graphics.draw_box(scen.playerShip.status.health / scen.playerShip.status.healthMax * 100 - 219, panels.right.center.x - 11, -219, panels.right.center.x, 0, ClutColour(14, 6))
    end
--    Factory resources (green - mostly)
    count = 1 -- [HARDCODED] <-- ?
    local cash = scen.players[0].cash
    local selectedShipCost
    if menuSelected == 1 then
        selectedShipCost = data.objects[selection.lastPlanet.building.ids[menuItemSelected]].price
    else
        selectedShipCost = 0
    end
   
    if selectedShipCost ~= 0 then
        if cash >= selectedShipCost then
            local drawGreen = math.floor((cash - selectedShipCost) / 200)
            local drawBlue = math.ceil(selectedShipCost / 200) + drawGreen
            while count <= drawGreen do
                graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(12, 3))
                count = count + 1
            end
            while count <= drawBlue do
                graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(14, 5))
                count = count + 1
            end
        else
            local drawGreen = math.floor(cash / 200)
            local drawRed = math.ceil(selectedShipCost / 200)
            while count <= drawGreen do
                graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(12, 3))
                count = count + 1
            end
            while count <= drawRed do
                graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(2, 9))
                count = count + 1
            end
        end
    else
        local drawGreen = math.floor(cash / 200)
        while count <= drawGreen do
            graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(12, 3))
            count = count + 1
        end
    end
    while count <= 100 do
        if count > 1 then
            graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(12, 14))
        else
            graphics.draw_box(196 - 4 * count, panels.right.center.x + 9, 193 - 4 * count, panels.right.center.x + 12, 0, ClutColour(12, 3))
        end
        count = count + 1
    end
--    Factory resource bars (yellow)
    --200 Per segment, 100 segments per bar
    for count = 1, math.floor(cash/(200*100)) do
        if count <= resourceBars then
            graphics.draw_box(198 - 6 * count, panels.right.center.x - 4, 193 - 6 * count, panels.right.center.x + 7, 0, ClutColour(3, 3))
        else
            graphics.draw_box(198 - 6 * count, panels.right.center.x - 4, 193 - 6 * count, panels.right.center.x + 7, 0, ClutColour(9, 13))
        end
        count = count + 1
    end
--   Factory build bar (purple)
    planet = selection.lastPlanet
    if planet ~= nil then
        graphics.draw_line({ x = panels.right.center.x - 8, y = 232 }, { x = panels.right.center.x + 7, y = 232 }, 1, ClutColour(13, 9))
        graphics.draw_line({ x = panels.right.center.x - 7, y = 232 }, { x = panels.right.center.x - 7, y = 228 }, 1, ClutColour(13, 9))
        graphics.draw_line({ x = panels.right.center.x + 7, y = 228 }, { x = panels.right.center.x + 7, y = 232 }, 1, ClutColour(13, 9))
        graphics.draw_line({ x = panels.right.center.x - 7, y = 201 }, { x = panels.right.center.x + 7, y = 201 }, 1, ClutColour(13, 9))
        graphics.draw_line({ x = panels.right.center.x - 7, y = 205 }, { x = panels.right.center.x - 7, y = 201 }, 1, ClutColour(13, 9))
        graphics.draw_line({ x = panels.right.center.x + 7, y = 201 }, { x = panels.right.center.x + 7, y = 205 }, 1, ClutColour(13, 9))
        graphics.draw_box(230, panels.right.center.x - 6, 204, panels.right.center.x + 5, 0, ClutColour(13, 9))
        graphics.draw_box(25 * GetBuildPercent(planet) + 204, panels.right.center.x - 6, 204, panels.right.center.x + 5, 0, ClutColour(13, 5))
    end

    
--[[------------------
    Left Panel
------------------]]--
    
--    Radar box (green)
    DrawRadar()
--    Communications panels (green)
    graphics.draw_box(-80, panels.left.center.x - 55, -200, panels.left.center.x + 57, 0, ClutColour(5, 11))
    graphics.draw_line({ x = panels.left.center.x - 55, y = -94 }, { x = panels.left.center.x + 57, y = -94 }, 1, ClutColour(12, 3))
--    Menu drawing
    graphics.draw_text(menuLevel.name, MAIN_FONT, "left", { x = panels.left.center.x - menuShift, y = topOfMenu }, 15)
    if menuItemSelected ~= 0 then
        graphics.draw_box(topOfMenu + menuStride * menuItemSelected + 6, panels.left.center.x - menuShift, topOfMenu + menuStride * menuItemSelected - 7, panels.left.center.x - menuShift + 112, 0, ClutColour(12, 10))
    end
    for i = 1, #menuLevel.items do
        graphics.draw_text(menuLevel.items[i].title, MAIN_FONT, "left", { x = panels.left.center.x - menuShift, y = topOfMenu + menuStride * i }, 15)
    end
    
--    Weapon ammo count
--OFFSET = 32 PIXELS -- [WHAT]
    if scen.playerShip.weapons ~= nil then
        if scen.playerShip.weapons.pulse ~= nil
        and scen.playerShip.weapons.pulse.ammo ~= -1 then
            graphics.draw_text(string.format('%03d', scen.playerShip.weapons.pulse.ammo), MAIN_FONT, "left", { x = panels.left.center.x - 34, y = 77 }, 15, ClutColour(16, 1))
        end
        
        if scen.playerShip.weapons.beam ~= nil
        and scen.playerShip.weapons.beam.ammo ~= -1 then
            graphics.draw_text(string.format('%03d', scen.playerShip.weapons.beam.ammo), MAIN_FONT, "left", { x = panels.left.center.x, y = 77 }, 15, ClutColour(16, 1))
        end
        
        if scen.playerShip.weapons.special ~= nil
        and scen.playerShip.weapons.special.ammo ~= -1 then
            graphics.draw_text(string.format('%03d', scen.playerShip.weapons.special.ammo), MAIN_FONT, "left", { x = panels.left.center.x + 38, y = 77 }, 15, ClutColour(16, 1))
        end
    end
    
    if selection.control ~= nil then
        DrawTargetBox(selection.control, true)
    end
    
    if selection.target ~= nil then
        DrawTargetBox(selection.target, false)
    end
    
--    printTable(panels)
    
    graphics.draw_box(-208, panels.left.center.x - 52, -234, panels.left.center.x + 49, 0, ClutColour(5, 11))
    
    graphics.draw_box(-208, panels.left.center.x - 51, -221, panels.left.center.x - 16, 0, ClutColour(4, 6))
    graphics.draw_text("RIGHT", MAIN_FONT, "left", { x = panels.left.center.x - 51, y = -215 }, 15, ClutColour(14, 5))
    graphics.draw_text("Select", MAIN_FONT, "left", { x = panels.left.center.x - 10, y = -215 }, 15, ClutColour(14, 5))
    if menuLevel ~= menuOptions then
        graphics.draw_box(-221, panels.left.center.x - 52, -234, panels.left.center.x - 16, 0, ClutColour(4, 6))
        graphics.draw_text("LEFT", MAIN_FONT, "left", { x = panels.left.center.x - 49, y = -227 }, 15, ClutColour(14, 5))
        graphics.draw_text("Go Back", MAIN_FONT, "left", { x = panels.left.center.x - 10, y = -227 }, 15, ClutColour(14, 5))
    end
end

function DrawDialogueBox(text)
    local cam = CameraToWindow()
    local length = cam[3] * 2 - panels.left.width - panels.right.width - 20
    local lines = textWrap(text, MAIN_FONT, 16, length)
    
    graphics.set_camera(cam[1], cam[2], cam[3], cam[4])
    
    if type(lines) == "table" then
        graphics.draw_box(#lines * 18 + cam[2] + 13, panels.left.center.x + panels.left.width / 2, cam[2] + 12, panels.right.center.x - panels.right.width / 2, 1, ClutColour(4, 10))
        for i = 1, #lines do
            graphics.draw_text(lines[i], MAIN_FONT, "left", { x = panels.left.center.x + panels.left.width / 2 + 5, y = (#lines - i + 1) * 18 + cam[2] + 4 }, 16)
        end
    else
        graphics.draw_box(38 + cam[2], panels.left.center.x + panels.left.width / 2, cam[2] + 12, panels.right.center.x - panels.right.width / 2, 1, ClutColour(4, 10))
        graphics.draw_text(lines, MAIN_FONT, "left", { x = panels.left.center.x + panels.left.width / 2 + 5, y = 25 + cam[2] }, 16)
    end
end

function GetMouseCoords()
    local mPos = input.mouse_position()
    return vec(
        scen.playerShip.physics.position.x -shipAdjust + camera.w * mPos.x - camera.w / 2,
        scen.playerShip.physics.position.y  + camera.h * mPos.y - camera.h / 2
    )
end

local realPos = { x, y }

function DrawMouse1()
    mousePos = GetMouseCoords()
    if input.mouse_still_time() > 2.0 then return end
    
    if hypot2(mousePos, oldMousePos) > 0 then
        mouseStart = mode_manager.time()
    end
    if mode_manager.time() - mouseStart >= 2.0 then
        mouseMovement = false
    else
        ship = scen.playerShip.physics.position
        
        realPos.x = (mousePos.x - ship.x + shipAdjust) * cameraRatio.current
        realPos.y = (mousePos.y - ship.y) * cameraRatio.current
        
        if realPos.x > panels.right.center.x - panels.right.width / 2 - 10 then
            mousePos.x = (panels.right.center.x - panels.right.width / 2 - 10) / cameraRatio.current - shipAdjust + ship.x
        elseif realPos.x < panels.left.center.x + panels.left.width / 2 then
            mousePos.x = (panels.right.center.x + panels.right.width / 2) / cameraRatio.current - shipAdjust + ship.x
        end
        
        if realPos.y > WINDOW.height / 2 - 10 then
            mousePos.y = (WINDOW.height / 2 - 10) / cameraRatio.current + ship.y
        elseif realPos.y < -WINDOW.height / 2 + 10 then
            mousePos.y = (-WINDOW.height / 2 + 10) / cameraRatio.current + ship.y
        end
        
        graphics.draw_line({ x = - camera.w / 2 + ship.x, y = mousePos.y }, { x = mousePos.x - 20 / cameraRatio.current, y = mousePos.y }, 1.0, ClutColour(4, 8))
        graphics.draw_line({ x = camera.w / 2 + ship.x, y = mousePos.y }, { x = mousePos.x + 20 / cameraRatio.current, y = mousePos.y }, 1.0, ClutColour(4, 8))
        graphics.draw_line({ x = mousePos.x, y = -camera.h / 2 + ship.y }, { x = mousePos.x, y = mousePos.y - 20 / cameraRatio.current }, 1.0, ClutColour(4, 8))
        graphics.draw_line({ x = mousePos.x, y = camera.h / 2 + ship.y }, { x = mousePos.x, y = mousePos.y + 20 / cameraRatio.current }, 1.0, ClutColour(4, 8))
    end
end

function DrawMouse2()
    ship = scen.playerShip.physics.position
    
    if mode_manager.time() - mouseStart < 2.0 and realPos.x < panels.left.center.x + panels.left.width / 2 then
        graphics.draw_sprite("Misc/Cursor", realPos, graphics.sprite_dimensions("Misc/Cursor"), 0)
    end
end

function DrawArrow()
    local angle = scen.playerShip.physics.angle
    local pos = scen.playerShip.physics.position
    local c1 = {
        x = math.cos(arrowAlpha + angle) * arrowDist + pos.x,
        y = math.sin(arrowAlpha + angle) * arrowDist + pos.y
    }
    local c2 = {
        x = math.cos(angle - arrowAlpha) * arrowDist + pos.x,
        y = math.sin(angle - arrowAlpha) * arrowDist + pos.y
    }
    local c3 = {
        x = math.cos(angle) * (arrowLength + arrowVar) + pos.x,
        y = math.sin(angle) * (arrowLength + arrowVar) + pos.y
    }
    graphics.draw_line(c1, c2, 1.5, ClutColour(5, 1))
    graphics.draw_line(c2, c3, 1.5, ClutColour(5, 1))
    graphics.draw_line(c3, c1, 1.5, ClutColour(5, 1))
end

function DrawGrid()
    local i = 0
    while i * GRID_DIST_BLUE - 10 < camera.w + 10 + GRID_DIST_BLUE do
        local grid_x = math.floor((i * GRID_DIST_BLUE + scen.playerShip.physics.position.x - (camera.w / 2.0)) / GRID_DIST_BLUE) * GRID_DIST_BLUE
        
        if grid_x % GRID_DIST_LIGHT_BLUE == 0 then
            if grid_x % GRID_DIST_GREEN == 0 then
                graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(5, 1))
            else
                graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(14, 9))
            end
        else
            if cameraRatio.current > 1 / 8 then
                graphics.draw_line({ x = grid_x, y = scen.playerShip.physics.position.y - (camera.h / 2.0) }, { x = grid_x, y = scen.playerShip.physics.position.y + (camera.h / 2.0) }, 1, ClutColour(4, 11))
            end
        end
        i = i + 1
    end
    
    i = 0
    while i * GRID_DIST_BLUE - 10 < camera.h + 10 + GRID_DIST_BLUE do
        local grid_y = math.floor((i * GRID_DIST_BLUE + scen.playerShip.physics.position.y - (camera.h / 2.0)) / GRID_DIST_BLUE) * GRID_DIST_BLUE
        if grid_y % GRID_DIST_LIGHT_BLUE == 0 then
            if grid_y % GRID_DIST_GREEN == 0 then
                graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(5, 1))
            else
                graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(14, 9))
            end
        else
            if cameraRatio.current > 1 / 8 then
                graphics.draw_line({ x = scen.playerShip.physics.position.x - shipAdjust - (camera.w / 2.0), y = grid_y }, { x = scen.playerShip.physics.position.x - shipAdjust + (camera.w / 2.0), y = grid_y }, 1, ClutColour(4, 11))
            end
        end
        i = i + 1
    end
end

function DrawTargetBox(object, isControl)
	local off = isControl and 0 or 72
	local barBot = 13 -- debug line [ADAM]
	local barTop = 37 -- debug line [ADAM]
	
	graphics.draw_box(63 - off, panels.left.center.x - 53, 50 - off, panels.left.center.x + 57, 0, (isControl and ClutColour(9,6) or ClutColour(4, 3)))
	graphics.draw_text((isControl and "CONTROL" or "TARGET"), MAIN_FONT, "left", { x = panels.left.center.x - 53, y = 56 - off }, 14, ClutColour(1, 17))
	graphics.draw_text(object.name, MAIN_FONT, "left", { x = panels.left.center.x - 53, y = 44 - off }, 14)
	
	local isFriendly = false -- [HARDCODED]
	if object.ai.objectives.dest ~= nil then
		local col = isFriendly and ClutColour(5, 11) or ClutColour(16, 4)
		graphics.draw_text(object.ai.objectives.dest.name, MAIN_FONT, "left", { x = panels.left.center.x - 53, y = 4 - off }, 14, col)
	end
	
	-- display the beam and pulse weapons
	-- [INCOMPLETE]
	off = off - 4
	if object.base.weapons.beam.id ~= -1 then
		graphics.draw_text(data.objects[object.base.weapons.beam.id].shortName, MAIN_FONT, "left", { x = panels.left.center.x - 6, y = 20 - off }, 14)
	end
	if object.base.weapons.pulse.id ~= -1 then
		graphics.draw_text(data.objects[object.base.weapons.pulse.id].shortName, MAIN_FONT, "left", { x = panels.left.center.x - 6, y = 30 - off }, 14)
	end
	if object.base.weapons.special.id ~= -1 then
		graphics.draw_text(data.objects[object.base.weapons.special.id].shortName, MAIN_FONT, "left", { x = panels.left.center.x - 6, y = 10 - off }, 14)
	end
	off = off + 4
	
	-- mini energy bar
	if object.status.energy ~= nil then
		graphics.draw_line({ x = panels.left.center.x - 17, y = barTop + 1 - off }, { x = panels.left.center.x - 7, y = barTop - off }, 1, ClutColour(3, 7))
		graphics.draw_line({ x = panels.left.center.x - 17, y = barTop - 3 - off }, { x = panels.left.center.x - 17, y = barTop + 1 - off }, 1, ClutColour(3, 7))
		graphics.draw_line({ x = panels.left.center.x - 7, y = barTop - 3 - off }, { x = panels.left.center.x - 7, y = barTop - off }, 1, ClutColour(3, 7))
		graphics.draw_line({ x = panels.left.center.x - 17, y = barBot - off }, { x = panels.left.center.x - 7, y = barBot - off }, 1, ClutColour(3, 7))
		graphics.draw_line({ x = panels.left.center.x - 17, y =  barBot + 3 - off }, { x = panels.left.center.x - 17, y = barBot - off }, 1, ClutColour(3, 7))
		graphics.draw_line({ x = panels.left.center.x - 7, y =  barBot + 3 - off }, { x = panels.left.center.x - 7, y = barBot - off }, 1, ClutColour(3, 7))
		graphics.draw_box(barTop - 1 - off, panels.left.center.x - 16,  barBot + 2 - off, panels.left.center.x - 9, 0, ClutColour(3, 7))
		graphics.draw_box((barTop - barBot - 4) * object.status.energy / object.status.energyMax + barBot + 3 - off, panels.left.center.x - 16, barBot + 2 - off, panels.left.center.x - 9, 0, ClutColour(9, 6))
	end
	
	-- mini health bar
	if object.status.health ~= nil then
		graphics.draw_line({ x = panels.left.center.x - 29, y = barTop + 1 - off }, { x = panels.left.center.x - 19, y = barTop - off }, 1, ClutColour(4, 8))
		graphics.draw_line({ x = panels.left.center.x - 29, y = barTop - 3 - off }, { x = panels.left.center.x - 29, y = barTop + 1 - off }, 1, ClutColour(4, 8))
		graphics.draw_line({ x = panels.left.center.x - 19, y = barTop - 3 - off }, { x = panels.left.center.x - 19, y = barTop - off }, 1, ClutColour(4, 8))
		graphics.draw_line({ x = panels.left.center.x - 29, y = barBot - off }, { x = panels.left.center.x - 19, y = barBot - off }, 1, ClutColour(4, 8))
		graphics.draw_line({ x = panels.left.center.x - 29, y = barBot + 3 - off }, { x = panels.left.center.x - 29, y = barBot - off }, 1, ClutColour(4, 8))
		graphics.draw_line({ x = panels.left.center.x - 19, y = barBot + 3 - off }, { x = panels.left.center.x - 19, y = barBot - off }, 1, ClutColour(4, 8))
		graphics.draw_box(barTop - 1 - off, panels.left.center.x - 28,  barBot + 2 - off, panels.left.center.x - 21, 0, ClutColour(4, 8))
		graphics.draw_box((barTop - barBot - 4) * object.status.health / object.status.healthMax +  barBot + 3 - off, panels.left.center.x - 28,  barBot + 2 - off, panels.left.center.x - 21, 0, ClutColour(4, 6))
	end

	-- mini sprite
	if object.gfx.sprite ~= nil then
		graphics.draw_sprite(object.gfx.sprite, { x = panels.left.center.x - 42, y = 26 - off }, { x = 28, y = 28 }, math.pi / 2.0) -- TODO [ADAM] Having { x = 28, y = 28 } is stretching the sprite unless it is a square sprite. Convert to actual sprite's dimensions, maximum of 28
	end
	
	-- brackets around sprite
	graphics.draw_line({ x = panels.left.center.x - 51, y = barTop + 1 - off }, { x = panels.left.center.x - 31, y = barTop - off }, 1, ClutColour(1, 1))
	graphics.draw_line({ x = panels.left.center.x - 51, y = barTop - 3 - off }, { x = panels.left.center.x - 51, y = barTop + 1 - off }, 1, ClutColour(1, 1))
	graphics.draw_line({ x = panels.left.center.x - 31, y = barTop - 3 - off }, { x = panels.left.center.x - 31, y = barTop - off }, 1, ClutColour(1, 1))
	graphics.draw_line({ x = panels.left.center.x - 51, y = barBot - off }, { x = panels.left.center.x - 31, y = barBot - off }, 1, ClutColour(1, 1))
	graphics.draw_line({ x = panels.left.center.x - 31, y =  barBot + 3 - off }, { x = panels.left.center.x - 31, y = barBot - off }, 1, ClutColour(1, 1))
	graphics.draw_line({ x = panels.left.center.x - 51, y =  barBot + 3 - off }, { x = panels.left.center.x - 51, y = barBot - off }, 1, ClutColour(1, 1))
end
