WINDOW = { width, height }
WINDOW.width, WINDOW.height = window.size()

panels = { left = { width = 128, height = 768, center = { x = -WINDOW.width / 2, y = 0 } }, right = { width = 32, height = 768, center = { x = WINDOW.width / 2, y = 0 } } }
cameraRatio = { current = 1, num = 2, target = 1 }

aspectRatio = WINDOW.width / WINDOW.height
camera = { w = WINDOW.width / cameraRatio.current, h }
camera.h = camera.w / aspectRatio
shipAdjust = .045 * camera.w
timeInterval = 1
zoomTime = 0

function CameraToWindow()
	return { -WINDOW.width / 2, -WINDOW.height / 2, WINDOW.width / 2, WINDOW.height / 2 }
end

function UpdateWindow()
	WINDOW.width, WINDOW.height = window.size()
	panels.left.center = { x = -WINDOW.width / 2 + panels.left.width / 2, y = 0 }
	panels.right.center = { x = WINDOW.width / 2 - panels.right.width / 2, y = 0 }
end

CAMERA_RATIO_OPTIONS = {
	2, 1, 1/2, 1/4, 1/16,
	function() -- zoom to nearest hostile
		local object, distance = GetClosestHostile(scen.playerShip)

		local ratio = WINDOW.height / 3 / distance
		ratio = math.min(ratio, 2.0)
		return ratio
	end,
    
	function() -- zoom to nearest object
		local object, distance = GetClosestObject(scen.playerShip)

		local ratio = WINDOW.height / 3 / distance
		ratio = math.min(ratio, 2.0)
		return ratio
	end,
    
	function() -- zoom to all
		local object, distance = GetFurthestObject(scen.playerShip)

		local ratio = WINDOW.height / 3 / distance
		ratio = math.min(ratio, 2.0)
		return ratio
	end
}
CAMERA_DYNAMIC_THRESHOLD = 6

function CameraInterpolate(dt)
	local oldRatio = cameraRatio.current
	local zoomGoal
	if cameraRatio.target < CAMERA_DYNAMIC_THRESHOLD then
		--Normal scaling
		zoomGoal = CAMERA_RATIO_OPTIONS[cameraRatio.target]
	else
		--Dynamic scaling
		zoomGoal = CAMERA_RATIO_OPTIONS[cameraRatio.target]()
	end

	local goalExponent = math.log(zoomGoal)/math.log(2)
	local currExponent = math.log(oldRatio)/math.log(2)
	local diff = goalExponent - currExponent
	local dir = math.sign(diff)
	local dz = dir * dt * 2
	if diff ~= 0 then
		if not ValuePasses(currExponent, dz, goalExponent) then
			cameraRatio.current = math.pow(2, currExponent + dz)
		else
			cameraRatio.current = math.pow(2, goalExponent)
		end
	end

	if (cameraRatio.current < 1 / 4 and oldRatio > 1 / 4)
	or (cameraRatio.current > 1 / 4 and oldRatio < 1 / 4) then
		sound.play("ZoomChange")
	end

	camera = { w = WINDOW.width / cameraRatio.current, h }
	camera.h = camera.w / aspectRatio
	shipAdjust = .045 * camera.w
	arrowLength = ARROW_LENGTH / cameraRatio.current
	arrowVar = ARROW_VAR / cameraRatio.current
	arrowDist = ARROW_DIST / cameraRatio.current

	--[==[
	if cameraRatio. >= CAMERA_DYNAMIC_THRESHOLD
	or  then
		zoomTime = zoomTime - dt
		if zoomTime < 0 then
			zoomTime = 0
			cameraChanging = false
--				scen.playerShip.weapon.beam.width = cameraRatio.curr
			soundJustPlayed = false
		end

		if zoomTime >= 0 then
			cameraRatio = cameraRatioOrig + cameraRatioOrig * multiplier * math.pow(math.abs((timeInterval - zoomTime) / timeInterval), 2)
			 --[[* (((x - timeInterval) * (x - timeInterval) * math.sqrt(math.abs(x - timeInterval))) / (timeInterval * timeInterval * math.sqrt(math.abs(timeInterval))))--]]
		end
		camera = { w = WINDOW.width / cameraRatio.curr, h }
		camera.h = camera.w / aspectRatio
		shipAdjust = .045 * camera.w
		arrowLength = ARROW_LENGTH / cameraRatio.curr
		arrowVar = ARROW_VAR / cameraRatio.curr
		arrowDist = ARROW_DIST / cameraRatio.curr
		if (cameraRatio.curr < 1 / 4 and cameraRatio.orig > 1 / 4) or (cameraRatio.curr > 1 / 4 and cameraRatio.orig < 1 / 4) then
			if soundJustPlayed == false then
				sound.play("ZoomChange")
				soundJustPlayed = true
			end
		end

	end
	--]==]
end

-- Adam's replacement for CameraInterpolate(dt)
-- Quadratic ease-in of the ship camera
function CameraEaseIn(dt, zoomLevel)
    zoomLevel = zoomLevel or 1 -- optional arguments, huzzah
    
    -- yet to be written [ADAM] [DEMO3]
end

-- To be used when the camera is in algorithmic zooms, possibly (may be built
-- into the CAMERA_RATIO_OPTIONS table)
function CameraFollow(dt, zoomLevel)
    -- to be written
end

function CameraSnap()
	if cameraChanging == true then
		cameraRatio.curr = cameraRatio.target
		camera = { w = WINDOW.width / cameraRatio.curr, h }
		camera.h = camera.w / aspectRatio
		shipAdjust = .045 * camera.w
		arrowLength = ARROW_LENGTH / cameraRatio.curr
		arrowVar = ARROW_VAR / cameraRatio.curr
		arrowDist = ARROW_DIST / cameraRatio.curr
	end
end

-- Adam's replacement for CameraSnap()
function InstantCamera(zoomLevel)
    zoomLevel = zoomLevel or 1 -- optional arguments, huzzah
    print(zoomLevel, "ZOOM LEVEL")
    cameraRatio.target = CAMERA_RATIO_OPTIONS[zoomLevel]() -- currently, no error checking
    cameraRatio.curr = cameraRatio.target
    
    ChangeCamAndWindow()
    UpdateWindow()
end

function ChangeCamAndWindow()
    camera = { w = WINDOW.width / cameraRatio.curr, h }
    camera.h = camera.w / aspectRatio
    shipAdjust = .045 * camera.w
    arrowLength = ARROW_LENGTH / cameraRatio.curr
    arrowVar = ARROW_VAR / cameraRatio.curr
    arrowDist = ARROW_DIST / cameraRatio.curr
end

function CameraToObject(object)
	local pos = object.physics.position
graphics.set_camera(
		-pos.x + shipAdjust - (camera.w / 2.0),
		-pos.y - (camera.h / 2.0),
		-pos.x + shipAdjust + (camera.w / 2.0),
		-pos.y + (camera.h / 2.0))
end
