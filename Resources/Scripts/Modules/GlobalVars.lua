import('Math')
import('AresCLUT')

--gameData = dofile("Config/data.lua")
playerShip = nil

releaseBuild = mode_manager.is_release()
print(releaseBuild)

cameraRatio = 1
cameraRatios = { 2, 1, 1/2, 1/4, 1/16, "hostile" }
cameraRatioNum = 2
aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w
timeInterval = 1

victoryTimer = nil
defeatTimer = 0
down = { esc = false, rtrn = false, q = false, o = false }

endGameData = nil

--tempvars
RESOURCES_PER_TICK = 200
--^^is that a tempvar?^^
firepulse = false
showVelocity = false
showAngles = false
frame = 0
printFPS = false
resources = 0
resourceBars = 0
resourceTime = 0.0
rechargeTimer = 0.0
cash = 1000
alliedShips = {}
buildTimerRunning = false
shipToBuild = nil
shipSelected = false
scen = nil
shipQuerying = { n, p, r, c, t }
shipBuilding = { n, p, r, c, t }
soundLength = 0.25
menuLevel = nil
--/tempvars

Admirals = {}

--loadingstuff
loadingEntities = false
entities = {}
--/loadingstuff

ARROW_LENGTH = 135
ARROW_VAR = (3 * math.sqrt(3))
ARROW_DIST = hypot(6, (ARROW_LENGTH - ARROW_VAR))
CarrowAlpha = math.atan2(6, ARROW_DIST)
arrowLength = ARROW_LENGTH
arrowVar = ARROW_VAR
arrowDist = ARROW_DIST
arrowAlpha = CarrowAlpha

GRID_DIST_BLUE = 256
GRID_DIST_LIGHT_BLUE = 2048
GRID_DIST_GREEN = 4096

keyControls = { left = false, right = false, forward = false, brake = false }