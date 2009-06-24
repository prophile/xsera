import('Math')

cameraRatio = 1
aspectRatio = 4 / 3
camera = { w = 640 / cameraRatio, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w

--color tables
c_lightRed = { r = 0.8, g = 0.4, b = 0.4, a = 1 }
c_red = { r = 0.6, g = 0.15, b = 0.15, a = 1 }
c_lightBlue = { r = 0.15, g = 0.15, b = 0.6, a = 1 }
c_blue = { r = 0.35, g = 0.35, b = 0.7, a = 1 }
c_laserGreen = { r = 0.1, g = 0.7, b = 0.1, a = 1 }
c_lightGreen = { r = 0.3, g = 0.7, b = 0.3, a = 1 }
c_green = { r = 0.0, g = 0.4, b = 0.0, a = 1 }
c_lightYellow = { r = 0.8, g = 0.8, b = 0.4, a = 1 }
c_yellow = { r = 0.6, g = 0.6, b = 0.15, a = 1 }
c_pink = { r = 0.8, g = 0.5, b = 0.5, a = 1 }
c_lightPurple = { r = 0.8, g = 0.5, b = 0.7, a = 1 }
c_purple = { r = 0.7, g = 0.4, b = 0.6, a = 1 }
--/color tables

--tempvars
firepulse = false
showVelocity = false
showAngles = false
frame = 0
printFPS = false
waitTime = 0.0
resources = 0
resource_bars = 0
RESOURCES_PER_TICK = 200
resource_time = 0.0
recharge_timer = 0.0
cash = 0
alliedShips = {}
--/tempvars

--loadingstuff
loading_percent = 0.0
loading = false
entities = { {} }
--/loadingstuff

soundLength = 0.25

arrowLength = 135
arrowVar = (3 * math.sqrt(3))
arrowDist = hypot(6, (arrowLength - arrowVar))
arrowAlpha = math.atan2(6, arrowDist)
gridDistBlue = 300
gridDistLightBlue = 2400
gridDistGreen = 4800

keyControls = { left = false, right = false, forward = false, brake = false }