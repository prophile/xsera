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

function updateWindow()
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

-- should I add a function that checks to make sure that the camera ratio is the
-- same as the target, and adjusting if not? [ADAM, TODO]

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

	local zoomTime = math.max(math.abs(math.log(zoomGoal/cameraRatio.current)/math.log(2)),1)
	if zoomTime ~= 0 then
	cameraRatio.current = cameraRatio.current + (zoomGoal-cameraRatio.current)*(zoomTime*dt)
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
			soundJustPlayed = false
		end

		if zoomTime >= 0 then
			cameraRatio = cameraRatioOrig + cameraRatioOrig * multiplier * math.pow(math.abs((timeInterval - zoomTime) / timeInterval), 2)
			 --[[* (((x - timeInterval) * (x - timeInterval) * math.sqrt(math.abs(x - timeInterval))) / (timeInterval * timeInterval * math.sqrt(math.abs(timeInterval))))--]]
		end
		camera = { w = WINDOW.width / cameraRatio, h }
		camera.h = camera.w / aspectRatio
		shipAdjust = .045 * camera.w
		arrowLength = ARROW_LENGTH / cameraRatio
		arrowVar = ARROW_VAR / cameraRatio
		arrowDist = ARROW_DIST / cameraRatio

		if (cameraRatio < 1 / 4 and cameraRatioOrig > 1 / 4) or (cameraRatio > 1 / 4 and cameraRatioOrig < 1 / 4) then
			if soundJustPlayed == false then
				sound.play("ZoomChange")
				soundJustPlayed = true
			end
		end

	end
	--]==]
end

function CameraToObject(object)
	local pos = object.physics.position
graphics.set_camera(
		-pos.x + shipAdjust - (camera.w / 2.0),
		-pos.y - (camera.h / 2.0),
		-pos.x + shipAdjust + (camera.w / 2.0),
		-pos.y + (camera.h / 2.0))
end
