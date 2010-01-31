import('Math')
import('AresCLUT')
import('data')

--constants
SPEED_FACTOR = 64.0
TIME_FACTOR = 60.0 -- [ADAM] #TEST change this to dt
BEAM_LENGTH = 48
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

MOUSE_RADIUS = 15

RELEASE_BUILD = mode_manager.is_release()
--/constants

demoLevel = 25
shipSeek = false

--mouse variables
oldMousePos = { x = 0, y = 0 }
mouseStart = 0
--/mouse variables


--camera vars
cameraRatio = 1
cameraRatios = { 2, 1, 1/2, 1/4, 1/8, 1/16, "hostile", "object", "all" }
cameraRatioNum = 2
aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w
timeInterval = 1
--/camera vars

--scenvars
scen = nil
victoryTimer = nil
defeatTimer = 0
endGameData = nil
loadingEntities = false
entities = {}
--/scenvars

--tempvars
showVelocity = false
showAngles = false
printFPS = false
resources = 0
resourceBars = 0
resourceTime = 0.0
rechargeTimer = 0.0
cash = 1000
buildTimerRunning = false
shipToBuild = nil
shipSelected = false
shipQuerying = { n, p, r, c, t }
shipBuilding = { n, p, r, c, t }
soundLength = 0.25
menuLevel = nil
--/tempvars

--client-server
isMultiplayer = false
--/client-server

CarrowAlpha = math.atan2(6, ARROW_DIST)
arrowLength = ARROW_LENGTH
arrowVar = ARROW_VAR
arrowDist = ARROW_DIST
arrowAlpha = CarrowAlpha
