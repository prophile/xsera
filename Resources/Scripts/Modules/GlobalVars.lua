import('Math')
import('AresCLUT')
if data == nil then import('data') end
import('Camera')

--[[
    [TODO]
    This file needs to be better split into chunks so that the information is
    decipherable.
--]]

RELEASE_BUILD = mode_manager.is_release()

WARP_TIME = 1.2
WARP_OUT_TIME = 5 / 3

WARP_IDLE = 0
WARP_SPOOLING = 1
WARP_ABORTING = 1.5
WARP_RUNNING = 2
WARP_COOLING = 3

--these limits are the values for ares but we can go MUCH higher if we want to :3
MAX_PLAYERS = 4
MAX_COUNTERS = 3 --per player

SPEED_FACTOR = 64.0
TIME_FACTOR = 60.0
BEAM_LENGTH = 48

MAIN_FONT = "prototype"
TITLE_FONT = "sneakout"
--[SCOTT] Recharge rates need tuning
BASE_RECHARGE_RATE = 4.0
ENERGY_RECHARGE_RATIO = 11.0
SHIELD_RECHARGE_MAX = 1.0 / 2.0
SHIELD_RECHARGE_RATIO = 5.0
WEAPON_RESTOCK_RATIO = 2.0
WEAPON_RESTOCK_RATE = 4.0

DEFAULT_ROTATION_RATE = math.pi
RESTITUTION_COEFFICIENT = 1.0
RESOURCES_PER_TICK = 200

GRID_DIST_BLUE = 512
GRID_DIST_LIGHT_BLUE = 4096
GRID_DIST_GREEN = 32768

ARROW_LENGTH = 135
ARROW_VAR = (3 * math.sqrt(3))
ARROW_DIST = hypot(6, (ARROW_LENGTH - ARROW_VAR))
ARROW_ALPHA = math.atan2(6, ARROW_DIST)

MOUSE_RADIUS = 15

SLOW_FROM_WARP = 5 / 3
WARP_SOUND_LENGTH = 0.3

demoLevel = 23
shipSeek = false
blinkMode = "triangle"

--mouse variables
oldMousePos = vec(0, 0)
mouseStart = 0
--/mouse variables

cameraSnap = false
requestedCamRatio = 1

--scenvars
scen = nil
victoryTimer = nil
defeatTimer = 0
endGameData = nil
--/scenvars

menuLevel = menuOptions

--tempvars
resources = 0
resourceBars = 0
resourceTime = 0.0
rechargeTimer = 0.0
cash = 1000
-- the above "tempvars" aren't really temporary, but they belong to the player
-- (and are not greatly used ATM)

-- the below "tempvars" deal with ship building, which will be necessary, but
-- also will belong to the player. I don't believe they are used much if at all.
buildTimerRunning = false
shipToBuild = nil
shipSelected = false
-- shipQuerying = { n, p, r, c, t }
shipBuilding = { n, p, r, c, t }
--/tempvars

arrowLength = ARROW_LENGTH
arrowVar = ARROW_VAR
arrowDist = ARROW_DIST
arrowAlpha = ARROW_ALPHA

--client-server
isMultiplayer = false
--/client-server

weak = {__mode = "v"}
