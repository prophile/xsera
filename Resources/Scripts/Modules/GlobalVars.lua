import('Math')
import('AresCLUT')
import('data')
import('Camera')

--constants

--these limits are the values for ares but we can go MUCH higher if we want to :3
MAX_PLAYERS = 4
MAX_COUNTERS = 3 --per player

SPEED_FACTOR = 64.0
TIME_FACTOR = 1.0
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
--/constants

ARROW_LENGTH = 135
ARROW_VAR = (3 * math.sqrt(3))
ARROW_DIST = hypot(6, (ARROW_LENGTH - ARROW_VAR))
ARROW_ALPHA = math.atan2(6, ARROW_DIST)

MOUSE_RADIUS = 15

RELEASE_BUILD = mode_manager.is_release()
--/constants

demoLevel = 25
shipSeek = false

--mouse variables
oldMousePos = vec(0, 0)
mouseStart = 0
--/mouse variables

--camera vars
cameraRatio = 1
cameraRatioTarget = 1
--cameraRatios = { 2, 1, 1/2, 1/4, 1/8, 1/16, "hostile", "object", "all" }
--cameraRatioNum = 2
aspectRatio = WINDOW.width / WINDOW.height
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w
timeInterval = 1
x = 0
--/camera vars

--scenvars
scen = nil
victoryTimer = nil
defeatTimer = 0
endGameData = nil
--/scenvars

--tempvars
resources = 0
resourceBars = 0
resourceTime = 0.0
rechargeTimer = 0.0
cash = 1000
buildTimerRunning = false
shipToBuild = nil
shipSelected = false
-- shipQuerying = { n, p, r, c, t }
shipBuilding = { n, p, r, c, t }
soundLength = 0.25
menuLevel = menuOptions
--/tempvars

arrowLength = ARROW_LENGTH
arrowVar = ARROW_VAR
arrowDist = ARROW_DIST
arrowAlpha = ARROW_ALPHA

--client-server
isMultiplayer = false
--/client-server

weak = {__mode = "v"}
