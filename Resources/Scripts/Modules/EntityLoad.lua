import('PrintRecursive')
import('GlobalVars')
import('PopDownConsole')

function NewEntity (entOwner, entName, entType, entDir, entSubdir, other)
--	print(entOwner, entName, entType, entDir, entSubdir, other)
	local entTypeReal = entType
	local entObject = { type = entType, size = {} }
---- if it's a projectile, make sure that it's not cost-prohibitive
	if entType == "Projectile" then
		if entDir == "beam" then
			if entOwner.battery.level < entOwner[entDir].cost then
				return
			end
		elseif entDir == "special" then
			if entOwner.special.ammo == 0 then
				return
			end
		end
		entType = "Weapon"
	end
---- create entName for identification purposes
	if entSubdir ~= nil then
		entObject.entName = (entType .. "s/" .. entDir .. "/" .. entSubdir .. "/" .. entName)
	elseif entDir ~= nil then
		entObject.entName = (entType .. "s/" .. entDir .. "/" .. entName)
	elseif entType ~= nil then
		entObject.entName = (entType .. "s/" .. entName)
	else
		errLog("Entity " .. entName .. " has no type.", 1)
	end
---- load data from file
    local trueData = {}
	local rawData
	rawData = xml.load("Config/" .. entObject.entName .. ".xml")
    local entData = rawData[1]
    for k, v in ipairs(entData) do
        if type(v) == "table" then
            trueData[v.name] = v[1]
        end
    end
---- check to see if this type has already been loaded
	if entities ~= nil then
		local num = 1
		while entities[num] ~= nil do
			if entities[num].entName == entObject.entName then
---- if it has, make a copy of it and add physicsObject properties
				entObject = deepcopy(entities[num])
				add_properties(entOwner, entName, entType, entDir, entSubdir, other, trueData, entObject, entObject.entName)
---- return - nothing more to do
				return entObject
			end
			num = num + 1
		end
		if loading_entities == false then
			errLog("Entity " .. entObject.entName .. " being loaded after loading period.", 2)
			add_properties(entOwner, entName, entType, entDir, entSubdir, other, trueData, entObject, entObject.entName)
		end
	end
	if trueData.name == nil then
		errLog(entName .. " of type " .. entTypeReal .. " does not have a name.", 12)
	end
	entObject.name = trueData.name
	if trueData.shortname ~= nil then
		entObject.shortName = trueData.shortname
	end
	entType = entTypeReal
	if entType == "Explosion" then
-- explosion-specific
		entObject.frameDuration = tonumber(trueData.frameDuration)
	elseif entType == "Scenario" then
-- scenario-specific
		entObject.planet =  { name = trueData.pname,
			position = { x = tonumber(trueData.ppositionx), y = tonumber(trueData.ppositiony) },
			image = trueData.psprite,
			res_gen = tonumber(trueData.presources_generated),
			build = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3, trueData.pbuild4 },
			type = "Planet",
			initialVelocity = { x = trueData.pinitialvelocityx, y = trueData.pinitialvelocityy },
			initialAngle = trueData.pinitialangle,
			buildqueue = { factor = 1, current = 0, percent = 100 },
			text = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3, trueData.pbuild4 },
			owner = trueData.powner }
		entObject.planet2 =  { name = trueData.p2name,
			position = { x = tonumber(trueData.p2positionx), y = tonumber(trueData.p2positiony) },
			image = trueData.p2sprite,
			res_gen = tonumber(trueData.p2resources_generated),
			build = { trueData.p2build1, trueData.p2build2, trueData.p2build3, trueData.p2build4 },
			type = "Planet",
			initialVelocity = { x = trueData.p2initialvelocityx, y = trueData.p2initialvelocityy },
			initialAngle = trueData.p2initialangle,
			buildqueue = { factor = 1, current = 0, percent = 100 },
			text = { trueData.p2build1, trueData.p2build2, trueData.p2build3, trueData.p2build4 },
			owner = trueData.p2owner }
		num = 1
		while entObject.planet.text[num] ~= nil do
			NewEntity(nil, entObject.planet.text[num], "Ship")
			num = num + 1
		end
		entObject.briefing = trueData.briefing
		-- put standard includes here (sounds, explosions, etc) [ADAM, DEMO3]
	elseif entType == "Weapon" then
-- weapon-specific
		if trueData.sprite ~= nil then
			entObject.image = trueData.sprite
			entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entObject.entName)
		else
			entObject.fileName = trueData.fileName
		end
		if trueData.mass == nil then
			entObject.mass = 0.01
		else
			entObject.mass = tonumber(trueData.mass)
		end
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
		entObject.fired = false
		entObject.class = trueData.class
		entObject.start = 0
		if entObject.class == "beam" then -- this is innacurate. Learn more about weapons [ADAM, FIX, SFIERA]
			entObject.length = tonumber(trueData.length)
			entObject.width = cameraRatio
			entObject.firing = false
		elseif entObject.class == "pulse" then
		elseif entObject.class == "special" then
			entObject.dest = { x = 2200, y = 2700 }
			entObject.delta = 0.0
			entObject.force = { x, y }
		elseif entObject.class == nil then
			errLog("Weapon '" .. entObject.name .. "' has no class. See NewEntity", 12)
		else
			errLog("Unknown weapon class '" .. entObject.class .. "'. See NewEntity", 11)
		end
	elseif entType == "Projectile" then
-- projectile-specific
		local weaponClass = entDir
		local wNum = other
		if trueData.turnrate ~= nil then
			entObject.turningRate = tonumber(trueData.turnrate)
			entObject.maxSeek = tonumber(trueData.maxSeek)
			entObject.isSeeking = true
		else
			entObject.isSeeking = false
		end
		
		if loading_entities == false then
			entObject.life = tonumber(trueData.life)
		end
	elseif entType == "Ship" then
-- ship-specific
		entObject.cost = tonumber(trueData.cost)
		entObject.buildTime = tonumber(trueData.time) / 200
		entObject.life = tonumber(trueData.life)
		entObject.turningRate = tonumber(trueData.turnrate)
		entObject.battery = { total = 5 * tonumber(trueData.energy), level = 5 * tonumber(trueData.energy), percent = 1.0 }
		entObject.energy = { total = tonumber(trueData.energy), level = tonumber(trueData.energy), percent = 1.0 }
		entObject.shield = { total = tonumber(trueData.life), level = tonumber(trueData.life), percent = 1.0 }
		if trueData.thrust ~= nil then
			entObject.thrust = tonumber(trueData.thrust)
		else
			errLog("No thrust data for ship " .. trueData.name, 12)
		end
		if trueData.warp ~= nil then
			entObject.warpSpeed = tonumber(trueData.warp)
			entObject.canWarp = true
		else
			entObject.canWarp = false
		end
		entObject.maxSpeed = tonumber(trueData.maxspeed)
		entObject.reverseThrust = tonumber(trueData.reverse)
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
		entObject.type = "Ship"
	else
		errLog("Unknown entity of type " .. entType, 11)
	end
--	cout_table(entObject, "object", false)
	local num = 1
	while entities[num] ~= nil do
		num = num + 1
	end
	local tempEnt = deepcopy(entObject)
	tempEnt.physicsObject = nil
	entities[num] = tempEnt
	return entObject
end

function add_properties(entOwner, entName, entType, entDir, entSubdir, other, trueData, entObject, concatString)
	if trueData.mass == nil then
		entObject.mass = 0.01
	else
		entObject.mass = tonumber(trueData.mass)
	end
	entObject.physicsObject = physics.new_object(entObject.mass)
	if entOwner ~= nil then
		if entOwner.physicsObject ~= nil then
			entObject.physicsObject.angle = entOwner.physicsObject.angle
			entObject.physicsObject.position = { x = entOwner.physicsObject.position.x, y = entOwner.physicsObject.position.y }
			if trueData.velocity ~= nil then
				entObject.initialVelocity = tonumber(trueData.velocity)
				entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x + tonumber(trueData.velocity) * math.cos(entOwner.physicsObject.angle), y = entOwner.physicsObject.velocity.y + tonumber(trueData.velocity) * math.sin(entOwner.physicsObject.angle) }
			else
				entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x, y = entOwner.physicsObject.velocity.y }
			end
		else
			entObject.physicsObject.angle = 0
			entObject.physicsObject.position = { x = entOwner.position.x, y = entOwner.position.y }
			if trueData.velocity ~= nil then
				entObject.initialVelocity = tonumber(trueData.velocity)
				entObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(entObject.physicsObject.angle), y = tonumber(trueData.velocity) * math.sin(entObject.physicsObject.angle) }
			else
				entObject.physicsObject.velocity = { x = entOwner.initialVelocity.x, y = entOwner.initialVelocity.y }
			end
		end
	end
	if ((entType ~= "projectile") and (entType ~= "weapon")) then
		if trueData.sprite ~= nil then
			entObject.image = entType .. "s/" .. trueData.sprite
			entObject.size.x, entObject.size.y = graphics.sprite_dimensions(concatString)
			entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
		else
			entObject.fileName = trueData.fileName
		end
	end
	if entTypeReal == "Projectile" then
		entObject.life = tonumber(trueData.life)
	end
end