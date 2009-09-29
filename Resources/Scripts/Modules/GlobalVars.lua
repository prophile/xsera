import('Math')
import('AresCLUT')

playerShip = nil

releaseBuild = false

cameraRatio = 1
aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w
cameraRatios = { 2, 1, 1/2, 1/4, 1/16 }
cameraRatioNum = 2
timeInterval = 1

victoryTimer = nil
defeatTimer = 0
down = { esc = false, rtrn = false, q = false, o = false }

endGameData = nil

--tempvars
firepulse = false
showVelocity = false
showAngles = false
frame = 0
printFPS = false
resources = 0
resource_bars = 0
RESOURCES_PER_TICK = 200
resource_time = 0.0
recharge_timer = 0.0
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

CarrowLength = 135
CarrowVar = (3 * math.sqrt(3))
CarrowDist = hypot(6, (CarrowLength - CarrowVar))
CarrowAlpha = math.atan2(6, CarrowDist)
arrowLength = CarrowLength
arrowVar = CarrowVar
arrowDist = CarrowDist
arrowAlpha = CarrowAlpha

gridDistBlue = 300
gridDistLightBlue = 2400
gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }