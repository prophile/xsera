import('Math')
import('AresCLUT')

--constants
SPEED_FACTOR = 64.0
TIME_FACTOR = 60.0 -- [ADAM] #TEST change this to dt
BEAM_LENGTH = 32
DEFAULT_ROTATION_RATE = 4.0
RESTITUTION_COEFFICIENT = 1.0
RESOURCES_PER_TICK = 200
GRID_DIST_BLUE = 512
GRID_DIST_LIGHT_BLUE = 4096
GRID_DIST_GREEN = 32768

demoLevel = 25
shipSeek = false


releaseBuild = mode_manager.is_release()

--camera vars
cameraRatio = 1
cameraRatios = { 2, 1, 1/2, 1/4, 1/16, "hostile" }
cameraRatioNum = 2
aspectRatio = 4 / 3
camera = { w = 1024 / cameraRatio, h }
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
gameData = dofile("./Xsera.app/Contents/Resources/Config/data.lua") --[FIX] this is A) not cross platform in ANY way shape or form B) an ugly way of fixing it.
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


ARROW_LENGTH = 135
ARROW_VAR = (3 * math.sqrt(3))
ARROW_DIST = hypot(6, (ARROW_LENGTH - ARROW_VAR))
CarrowAlpha = math.atan2(6, ARROW_DIST)
arrowLength = ARROW_LENGTH
arrowVar = ARROW_VAR
arrowDist = ARROW_DIST
arrowAlpha = CarrowAlpha
