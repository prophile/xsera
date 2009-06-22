import('PrintRecursive')

function NewEntity (entOwner, entName, entType, entDir, entSubdir)
	local entTypeReal = entType
	if entType == "Projectile" then
		entType = "Weapon"
	end
	local rawData
	if entSubdir ~= nil then
		rawData = xml.load("Config/" .. entType .. "s/" .. entDir .. "/" .. entSubdir .. "/" .. entName .. ".xml")
	elseif entDir ~= nil then
		rawData = xml.load("Config/" .. entType .. "s/" .. entDir .. "/" .. entName .. ".xml")
	elseif entType ~= nil then
		rawData = xml.load("Config/" .. entType .. "s/" .. entName .. ".xml")
	else
		error("Entity " .. entName .. " has no type.", 7)
	end
	entType = entTypeReal
    local entData = rawData[1]
    local trueData = {}
    for k, v in ipairs(entData) do
        if type(v) == "table" then
            trueData[v.name] = v[1]
        end
    end
	local entObject = { type = entType, size = {} }
	if trueData.name == nil then
		error(entName .. " of " .. entType .. " does not have a name.", 7)
	end
	entObject.name = trueData.name
	if trueData.shortname ~= nil then
		entObject.shortName = trueData.shortname
	end
	if trueData.mass == nil then
		entObject.mass = 0.01
	else
		entObject.mass = tonumber(trueData.mass)
	end
	entObject.physicsObject = physics.new_object(entObject.mass)
	if entType == "Ship" then
		if trueData.sprite ~= nil then
			entObject.image = trueData.sprite
			if entSubdir ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entSubdir .. "/" .. entName)
			elseif entDir ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entName)
			elseif entType ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entName)
			end
			entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
		else
			entObject.fileName = trueData.filename
		end
	else
		if trueData.sprite ~= nil then
			entObject.image = trueData.sprite
			if entSubdir ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. "/" .. entSubdir .. "/" .. entName)
			elseif entDir ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. "/" .. entName)
			elseif entType ~= nil then
				entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. entName)
			end
			entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
		else
			entObject.fileName = trueData.fileName
		end
	end
	
	if entType == "Explosion" then
-- explosion-specific
		entObject.frameDuration = tonumber(trueData.frameDuration)
	elseif entType == "Scenario" then
-- scenario-specific
		entObject.planet =  { name = trueData.pname,
			position = { x = tonumber(trueData.ppositionx), y = tonumber(trueData.ppositiony) },
			image = trueData.psprite,
			res_gen = tonumber(trueData.presources_generated),
			build = trueData.pbuild,
			type = "Planet",
			text = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3 } }
		entObject.briefing = trueData.briefing
	elseif entType == "Weapon" then
-- weapon-specific
		entObject.cost = tonumber(trueData.energyCost)
		entObject.sound = trueData.fireSound
		entObject.damage = tonumber(trueData.damage)
		entObject.cooldown = tonumber(trueData.cooldown)
		entObject.life = tonumber(trueData.life)
		entObject.max_projectiles = math.ceil(entObject.life / entObject.cooldown)
		entObject.ammo = tonumber(trueData.ammo)
		if trueData.thrust ~= nil then
			entObject.thrust = tonumber(trueData.thrust)
		end
		entObject.class = trueData.class
		if entObject.class == "beam" then -- this is innacurate. Learn more about weapons [ADAM, FIX, SFIERA]
			entObject.length = tonumber(trueData.length)
			entObject.width = cameraRatio
			entObject.fired = false
			entObject.start = 0
			entObject.firing = false
		elseif entObject.class == "pulse" then
		elseif entObject.class == "special" then
			entObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
			entObject.delta = 0.0
			entObject.fired = false
			entObject.start = 0
			entObject.force = { x, y }
		elseif entObject.class == nil then
			error("Weapon '" .. entObject.name .. "' has no class. See NewEntity", 7)
		else
			error("Unknown weapon class '" .. entObject.class .. "'. See NewEntity", 6)
		end
	elseif entType == "Projectile" then
-- projectile-specific
		entObject.physicsObject.angle = entOwner.physicsObject.angle
		if tonumber(trueData.velocity) ~= nil then
			entObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(entObject.physicsObject.angle) + entOwner.physicsObject.velocity.x, y = tonumber(trueData.velocity) * math.sin(entObject.physicsObject.angle) + entOwner.physicsObject.velocity.y }
		else
			entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x, y = entOwner.physicsObject.velocity.y }
		end
		if trueData.turnrate ~= nil then
			entObject.turningRate = tonumber(trueData.turnrate)
			entObject.maxSeek = tonumber(trueData.maxSeek)
			entObject.isSeeking = true
		else
			entObject.isSeeking = false
		end
		if weaponClass == "beam" then
			-- [ADAM, FIX] this piece of code is a hack, it relies on what little weapons we have right now to make the assumption
			if entOwner.switch == true then
				entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3) }
				entOwner.switch = false
			else
				-- [POSITIONVSLOCATION]
				entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3) }
				entOwner.switch = true
			end
			-- cost
			entOwner.energy.level = entOwner.energy.level - tonumber(trueData.energyCost)
		elseif weaponClass == "pulse" then
			return
		elseif weaponClass == "special" then
			entObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
		elseif weaponClass == nil then
			error("Weapon '" .. entType .. "' has no class. See NewEntity", 7)
		else
			error("Unknown weapon class '" .. entClass .. "'. See NewEntity", 6)
		end
		entObject.life = tonumber(trueData.life)
		entObject.start = mode_manager.time() * 1000
	elseif entType == "Ship" then
-- ship-specific
		entObject.life = tonumber(trueData.life)
		entObject.turningRate = tonumber(trueData.turnrate)
		entObject.battery = { total = 5 * tonumber(trueData.energy), level = 5 * tonumber(trueData.energy), percent = 1.0 }
		entObject.energy = { total = tonumber(trueData.energy), level = tonumber(trueData.energy), percent = 1.0 }
		entObject.shield = { total = tonumber(trueData.life), level = tonumber(trueData.life), percent = 1.0 }
		if trueData.thrust ~= nil then
			entObject.thrust = tonumber(trueData.thrust)
		else
			error("No thrust data for ship " .. trueData.name, 7)
		end
		if trueData.warp ~= nil then
			entObject.warpSpeed = tonumber(trueData.warp)
			entObject.canWarp = true
		else
			entObject.canWarp = false
		end
		entObject.maxSpeed = tonumber(trueData.maxspeed)
		entObject.reverseThrust = tonumber(trueData.reverse)
		entObject.beamName = trueData.beamname
		entObject.pulseName = trueData.pulsename
		entObject.specialName = trueData.specialname
		if trueData.beamname ~= nil then
			entObject.beam = NewEntity(nil, trueData.beamname, "Weapon", "Beam")
			entObject.beamWeap = { { {} } }
		end
		if trueData.pulsename ~= nil then
			entObject.pulse = NewEntity(nil,  trueData.pulsename, "Weapon", "Pulse")
			entObject.pulseWeap = { { {} } }
		end
		if trueData.specialname ~= nil then
			entObject.special = NewEntity(nil, trueData.specialname, "Weapon", "Special")
			entObject.specialWeap = { { {} } }
		end
		entObject.warp = { warping = false, start = { bool = false, time = nil, engine = false, sound = false, isStarted = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
		entObject.switch = true -- [HARDCODED]
		entObject.physicsObject.velocity.x = tonumber(trueData.initial_velocity)
		entObject.physicsObject.velocity.y = 0
		if entOwner ~= nil then
			-- [POSITIONVSLOCATION]
			entObject.physicsObject.position = { x = entOwner.position.x, y = entOwner.position.y }
		end
		entObject.type = "Ship"
	else
		error("Unknown entity of type " .. entType, 6)
	end
	cout_table(entObject, "object", false)
    return entObject
end