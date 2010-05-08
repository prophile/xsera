WINDOW = { width, height }
WINDOW.width, WINDOW.height = window.size()

panels = { left = { width = 128, height = 768, center = { x = -WINDOW.width / 2, y = 0 } }, right = { width = 32, height = 768, center = { x = WINDOW.width / 2, y = 0 } } }

cameraRatio = 1
cameraRatioTarget = 1
aspectRatio = WINDOW.width / WINDOW.height
camera = { w = WINDOW.width / cameraRatio, h }
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
	2, 1/2, 1/4, 1/16,
	function() -- zoom to nearest hostile object
		--[TEMP, SCOTT] this is temporary untill we have a more efficient technique
		local pos = scen.playerShip.position
		local dist = 0;
		for id, o in pairs(scen.objects) do
			if id ~= playerShipId and o.ai.owner ~= scen.playerShip.ai.owner then
				if dist > 0 then
					dist = math.min(hypot2(pos,o.physics.position), dist)
				else
					dist = hypot2(pos,o.physics.position)
				end
			end
		end
		local ratio = WINDOW.w / distance
		return ratio
	end,
	function() -- zoom to nearest object
		--[TEMP, SCOTT] this is temporary untill we have a more efficient technique
		local pos = scen.playerShip.position
		local dist = 0;
		for id, o in pairs(scen.objects) do
			if id ~= playerShipId then
				if dist > 0 then
					dist = math.min(hypot2(pos,o.physics.position), dist)
				else
					dist = hypot2(pos,o.physics.position)
				end
			end
		end
		local ratio = WINDOW.w / distance
		return ratio
	end,
	function() -- zoom to all
		--[TEMP, SCOTT] this is temporary untill we have a more efficient technique
		local pos = scen.playerShip.position
		local dist = 0
		for id, o in pairs(scen.objects) do
			if id ~= playerShipId then
				dist = math.max(hypot2(pos,o.physics.position), dist)
			end
		end
		local ratio = WINDOW.w / distance
		return ratio
	end
}

CAMERA_RATIO = { curr = 1, num = 2, target = 1 }
-- should I add a function that checks to make sure that the camera ratio is the
-- same as the target, and adjusting if not? [ADAM, TODO]

