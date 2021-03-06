import('GlobalVars')
import('Interfaces')
import('Console')

--[[-----------------------
    --{{---------------
        Key In Menu
    ---------------}}--
-----------------------]]--

down = { esc = false, rtrn = false, q = false, o = false, caps = false }

function escape_keyup(k)
    if k == "escape" then
        if down.esc == true then
            down.esc = "act"
        end
    elseif k == "return" then
        down.rtrn = "act"
    elseif k == "q" then
        down.q = "act"
    elseif k == "Mcaps" then
        down.caps = "act"
    end
end

function escape_key(k)
    if k == "escape" then
        down.esc = true
    elseif k == "return" then
        down.rtrn = true
    elseif k == "q" then
        down.q = true
    elseif k == "o" then
        down.o = true
    end
end

--[[-------------------------
    --{{-----------------
        Key Functions
    -----------------}}--
-------------------------]]--

    --[[--------
        Ship
    --------]]--

function DoFireWeap1()
    scen.playerShip.control.beam = true
end

function StopFireWeap1()
    scen.playerShip.control.beam = false
end

function DoFireWeap2()
    scen.playerShip.control.pulse = true
end

function StopFireWeap2()
    scen.playerShip.control.pulse = false
end

function DoFireWeapSpecial()
    scen.playerShip.control.special = true
end

function StopFireWeapSpecial()
    scen.playerShip.control.special = false
end

function DoAccelerate()
    scen.playerShip.control.accel = true
end

function StopAccelerate()
    scen.playerShip.control.accel = false
end

function DoDecelerate()
    scen.playerShip.control.decel = true
end

function StopDecelerate()
    scen.playerShip.control.decel = false
end

function DoLeftTurn()
    scen.playerShip.control.left = true
end

function StopLeftTurn()
    scen.playerShip.control.left = false
end

function DoRightTurn()
    scen.playerShip.control.right = true
end

function StopRightTurn()
    scen.playerShip.control.right = false
end

--MARK: WARPING KEY FUNCTIONS
function DoWarp()
    if scen.playerShip.base.warpSpeed ~= nil then
        scen.playerShip.control.warp = true
    end
end

function StopWarp()
    if scen.playerShip.base.warpSpeed ~= nil then
        scen.playerShip.control.warp = false
        if scen.playerShip.warp.stage == WARP_SPOOLING then
            scen.playerShip.warp.stage = WARP_ABORTING
        elseif  scen.playerShip.warp.stage == WARP_RUNNING then
            scen.playerShip.warp.stage = WARP_COOLING
        end
    end
end

    --[[-----------
        Command
    -----------]]--

function DoSelectFriendly()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoSelectHostile()
    LogError("The command does not have any code. /placeholder", 9)
    --[[ pseudocode
    if hostileSelected == false then
        testWithin(angle)
        select(closest)
    else
        if (testWithin(angle) ~= closest then
            select(testWithin(angle))
        end
    end
    --]]
end

--[[ pseudocode
function DoSelect(type)
    if currentSelect == type then
        select(nextClosest)
    else
        select(closest)
    end
end
--]]


function DoSelectBase()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoTarget()
--    No Code
end

function DoMoveOrder()
    if selection.control ~= nil
    and selection.control ~= selection.target
    and selection.control ~= scen.playerShip
    and selection.control.base.attributes.canAcceptDestination == true
    and (selection.target == nil
    or selection.target.base.attributes.canBeDestination == true) then
        selection.control.ai.objectives.dest = selection.target
    end
end

function DoScaleIn()
    if cameraRatio.target > 1 then
        cameraRatio.target = cameraRatio.target - 1
    end
    ActionDeactivate("Scale In")
end

function DoScaleOut()
    if cameraRatio.target < #CAMERA_RATIO_OPTIONS then
        cameraRatio.target = cameraRatio.target + 1
    end
    ActionDeactivate("Scale Out")
end

function DoComputerPrevious()
    if menuItemSelected ~= 1 and menuItemSelected ~= 0 then
        menuItemSelected = menuItemSelected - 1
        if menuLevel == menuBuild then
            if menuLevel.planet ~= lastPlanet then
                UpdateBuildMenu()
            end
            -- [TODO] [ADAM] now show the stats for the selected ship
        end
    end
    keyboard[2][9].active = false
end

function DoComputerNext()
    if menuItemSelected ~= #menuLevel.items and menuItemSelected ~= 0 then
        menuItemSelected = menuItemSelected + 1
        if menuLevel == menuBuild then
            if menuLevel.planet ~= lastPlanet then
                UpdateBuildMenu()
            end
            -- [TODO] [ADAM] now show the stats for the selected ship
        end
    end
    keyboard[2][10].active = false
end

function DoComputerAccept()
    local item = menuLevel.items[menuItemSelected]
    if menuItemSelected ~= 0 and item.action ~= nil then
        item.action(item.context)
        menuItemSelected = 1
        if menuLevel == menuStatus then
            menuItemSelected = 0
        end
    end
    keyboard[2][11].active = false
end

function DoComputerBack()
    if menu ~= menuOptions then
        menuLevel = menuOptions
        menuItemSelected = 1
    end
    keyboard[2][12].active = false
end

    --[[-------------
        Shortcuts
    -------------]]--

function DoTransferControl()
    if selection.control ~= nil
    and (
    not(RELEASE_BUILD)
    or scen.playerShip.ai.owner == control.ai.owner)
    then
        scen.playerShipId = selection.control.physics.object_id
        scen.playerShip.ai.objectives.target = nil
        scen.playerShip.ai.objectives.dest = nil
        ChangePlayerShip()
--[[        scen.playerShip.control = {
            accel = false;
            decel = false;
            left = false;
            right = false;
            beam = false;
            pulse = false;
            special = false;
            warp = false;
        }--]]
    else
        sound.play("NaughtyBeep")
    end
end

function DoZoom1_1()
    cameraRatio.target = 2
end

function DoZoom1_2()
    cameraRatio.target = 3
end

function DoZoom1_4()
    cameraRatio.target = 4
end

function DoZoom1_16()
    cameraRatio.target = 5
end

function DoZoomHostile()
    cameraRatio.target = 6
end

function DoZoomObject()
    cameraRatio.target = 7
end

function DoZoomAll()
    cameraRatio.target = 8
end

function DoMessageNext()
    LogError("The command does not have any code. /placeholder", 9)
end

    --[[-----------
        Utility
    -----------]]--

function DoHelp()
    menu_display = "info_menu"
    keyup = escape_keyup
    key = escape_key
    keyboard[4][2].active = false
end

function DoLowerVolume()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoRaiseVolume()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoMuteMusic()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoExpertNet()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoEscapeMenu()
    menu_display = "esc_menu"
    keyup = escape_keyup
    key = escape_key
    keyboard[4][8].active = false
end

function DoPause()
    menu_display = "pause_menu"
    keyup = escape_keyup
    key = escape_key
    keyboard[4][9].active = false
end

    --[[-----------
        HotKeys
    -----------]]--

function DoHotkey1()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey2()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey3()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey4()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey5()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey6()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey7()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey8()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey9()
    LogError("The command does not have any code. /placeholder", 9)
end

function DoHotkey10()
    LogError("The command does not have any code. /placeholder", 9)
end


--[[--------------------
    --{{------------
        Key Data
    ------------}}--
---------------------]]--
-- keyboard with all the original keybindings here: <http://xsera.pastebin.com/f690af8a8>
keyboard = { { "Ship",
                { key = "w", name = "Accelerate", active = false, action = DoAccelerate, deaction = StopAccelerate },
                { key = "s", name = "Decelerate", active = false, action = DoDecelerate, deaction = StopDecelerate }, 
                { key = "a", name = "Turn Counter-Clockwise", active = false , action = DoLeftTurn, deaction = StopLeftTurn }, 
                { key = "d", name = "Turn Clockwise", active = false, action = DoRightTurn, deaction = StopRightTurn }, 
                { key = "MmetaL", key_display = "CmdL", name = "Fire Weapon 1", action = DoFireWeap1, deaction = StopFireWeap1, active = false }, 
                { key = "MaltL", key_display = "AltL", name = "Fire Weapon 2", action = DoFireWeap2, deaction = StopFireWeap2, active = false }, 
                { key = " ", key_display = "Space", name = "Fire/Activate Special", action = DoFireWeapSpecial, deaction = StopFireWeapSpecial, active = false }, 
                { key = "tab", key_display = "Tab", name = "Warp", action = DoWarp, deaction = StopWarp, active = false } },
            { "Command", 
                { key = "pgdn", name = "Select Friendly", action = DoSelectFriendly, active = false }, 
                { key = "KPequals", key_display = "KP=", name = "Select Hostile", action = DoSelectHostile, active = false }, 
                { key = "KPdivide", key_display = "KP/", name = "Select Base", action = DoSelectBase, active = false }, 
                { key = "MshiftL", key_display = "ShiftL", name = "Target", action = DoTarget, active = false }, 
                { key = "MctrlL", key_display = "CtrlL", name = "Move Order", action = DoMoveOrder, active = false }, 
                { key = "=", name = "Scale In", action = DoScaleIn, active = false }, 
                { key = "-", name = "Scale Out", action = DoScaleOut, active = false }, 
                { key = "up", key_display = "UP", name = "Computer Previous", action = DoComputerPrevious, active = false }, 
                { key = "down", key_display = "DOWN", name = "Computer Next", action = DoComputerNext, active = false }, 
                { key = "right", key_display = "RGHT", name = "Computer Accept/Select/Do", action = DoComputerAccept, active = false }, 
                { key = "left", key_display = "LEFT", name = "Computer Cancel/Back Up", action = DoComputerBack, active = false } },
            { "Shortcuts",
                { key = "F8", name = "Transfer Control", action = DoTransferControl, active = false }, 
                { key = "F9", name = "Zoom to 1:1", action = DoZoom1_1, active = false }, 
                { key = "F10", name = "Zoom to 1:2", action = DoZoom1_2, active = false }, 
                { key = "F11", name = "Zoom to 1:4", action = DoZoom1_4, active = false }, 
                { key = "F12", name = "Zoom to 1:16", action = DoZoom1_16, active = false }, 
                { key = "m", name = "Zoom to Closest Hostile", action = DoZoomHostile, active = false }, 
                { key = "home", name = "Zoom to Closest Object", action = DoZoomObject, active = false }, 
                { key = "pgup", name = "Zoom to All", action = DoZoomAll, active = false }, 
                { key = "del", name = "Message Next Page / Clear", action = DoMessageNext, active = false } },
            { "Utility",
                { key = "F1", name = "Help", action = DoHelp, active = false }, 
                { key = "F2", name = "Lower Volume", action = DoLowerVolume, active = false }, 
                { key = "F3", name = "Raise Volume", action = DoRaiseVolume, active = false }, 
                { key = "F4", name = "Mute Music", action = DoMuteMusic, active = false }, 
                { key = "F5", name = "Expert Net Settings", action = DoExpertNet, active = false }, 
                { key = "F6", name = "Fast Motion", active = false }, 
                { key = "escape", name = "Escape Menu", action = DoEscapeMenu, active = false }, 
                { key = "Mcaps", name = "Pause", action = DoPause, active = false } }, 
            { "HotKeys",
                { key = "1", name = "HotKey 1", action = DoHotkey1, active = false }, 
                { key = "2", name = "HotKey 2", action = DoHotkey2, active = false }, 
                { key = "3", name = "HotKey 3", action = DoHotkey3, active = false }, 
                { key = "4", name = "HotKey 4", action = DoHotkey4, active = false }, 
                { key = "5", name = "HotKey 5", action = DoHotkey5, active = false }, 
                { key = "6", name = "HotKey 6", action = DoHotkey6, active = false }, 
                { key = "7", name = "HotKey 7", action = DoHotkey7, active = false }, 
                { key = "8", name = "HotKey 8", action = DoHotkey8, active = false }, 
                { key = "9", name = "HotKey 9", action = DoHotkey9, active = false }, 
                { key = "0", name = "HotKey 10", action = DoHotkey10, active = false } } }

--[[---------------------------------
    --{{-------------------------
        Key Menu Manipulation
    -------------------------}}--
---------------------------------]]--

function ReassignKey(name, key)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.key == key then
                j.key = nil
            end
            if j.menu == menu then
                j.key = key
            end
        end
    end
end

function KeyIsUnassigned()
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.key == nil then
                return true, j.name
            end
        end
    end
    return false
end

function KeyActivate(key)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.key == key then
                j.active = true
                return
            end
        end
    end
end

function ActionActivate(name)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.name == name then
                j.active = true
                return
            end
        end
    end
end

function KeyDeactivate(key)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.key == key then
                j.active = false
                if j.deaction ~= nil then
                    j.deaction()
                end
                return
            end
        end
    end
end

function ActionDeactivate(name)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.name == name then
                j.active = false
                if j.deaction ~= nil then
                    j.deaction()
                end
                return
            end
        end
    end
end

function KeyDoActivated()
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.active == true then
                if j.action ~= nil then
                    j.action()
                end
            end
        end
    end
end

--[[[
    - @function KeyToName
    - Given a key `key`, will attempt to find the name of the corresponding
    - action taken when that key is pressed. If the name associated with `key`
    - is not found, nothing is returned.
    - @param key
        The key value to be searched for
    - @return name
        If such a key is bound (it triggers an event when pressed), then the
        name of that action is returned.
--]]

function KeyToName(key)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.key == key then
                return j.name
            end
        end
    end
end

--[[[
    - @function NameToKey
    - Given a name `name`, will attempt to find the name of the key that will
        trigger it. If the key associated with `name` is not found, nothing is
        returned.
    - @param key
        The key value to be searched for
    - @return name
        If such a key is bound (it triggers an event when pressed), then the
        name of that action is returned.
--]]

function NameToKey(name)
    for _, i in ipairs(keyboard) do
        for _, j in ipairs(i) do
            if j.name == name then
                return j.key
            end
        end
    end
end
