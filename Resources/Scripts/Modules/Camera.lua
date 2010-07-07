WINDOW = { width, height }
WINDOW.width, WINDOW.height = window.size()

panels = { left = { width = 128, height = 768, center = { x = -WINDOW.width / 2, y = 0 } }, right = { width = 32, height = 768, center = { x = WINDOW.width / 2, y = 0 } } }

--[[
    [CR CONVERT]
    cameraRatio.curr - cameraRatio.curr
    cameraRatio.target - cameraRatio.target
    ??? - cameraRatio.num
--]]

cameraRatio = { curr = 1, orig = 1, num = 2, target = 1 }
-- how this works when not zooming: curr = target = CAMERA_RATIO_OPTIONS[num]
-- when moving, zooming from curr = CAMERA_RATIO_OPTIONS[num] to target, set num
-- to the proper value once we reachy the target

-- should I add a function that checks to make sure that the camera ratio is the
-- same as the target, and adjusting if not? [ADAM] [TODO]

aspectRatio = WINDOW.width / WINDOW.height
camera = { w = WINDOW.width / cameraRatio.curr, h }
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
    function() -- Zoom to 2:1
        return 2
    end,
    
    function() -- Zoom to 1:1
        return 1
    end,
    
    function() -- Zoom to 1:2
        return 1/2
    end,
    
    function() -- Zoom to 1:4
        return 1/4
    end,
    
    function() -- Zoom to 1:16
        return 1/16
    end,
    
	function() -- zoom to nearest hostile object
		return 1/8 -- [TEMP] [ADAM] [DEMO3] need to make the algorithm for this
	end,
    
	function() -- zoom to nearest object
		return 1/9 -- [TEMP] [ADAM] [DEMO3] need to make the algorithm for this
	end,
    
	function() -- zoom to all
		return 1/10 -- [TEMP] [ADAM] [DEMO3] need to make the algorithm for this
	end
}

function CameraInterpolate(dt) -- note: this function now controlls both quadratic zooming and snap zooming (not good from a code design philosophy)
	if cameraChanging == true then
		zoomTime = zoomTime - dt
		if zoomTime < 0 then
			zoomTime = 0
			cameraChanging = false
--				scen.playerShip.weapon.beam.width = cameraRatio.curr
			soundJustPlayed = false
		end
		if zoomTime >= 0 then
			cameraRatio.curr = cameraRatio.orig + cameraRatio.orig * multiplier * math.pow(math.abs((timeInterval - zoomTime) / timeInterval), 2)  --[[* (((x - timeInterval) * (x - timeInterval) * math.sqrt(math.abs(x - timeInterval))) / (timeInterval * timeInterval * math.sqrt(math.abs(timeInterval))))--]] 
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