import('PrintRecursive')

--[[------------------
	New Ship
------------------]]--

function NewShip (shipType)
    local rawData = xml.load("Config/Ships/" .. shipType .. ".xml")
    local shipData = rawData[1]
    local trueData = {}
    for k, v in ipairs(shipData) do
        if type(v) == "table" then
            trueData[v.name] = v[1]
        end
    end
    local shipObject = {size = {}}
    shipObject.image = trueData.sprite
    shipObject.size.x, shipObject.size.y = graphics.sprite_dimensions(shipObject.image)
	shipObject.life = tonumber(trueData.life)
    shipObject.physicsObject = physics.new_object(tonumber(trueData.mass))
    shipObject.physicsObject.collision_radius = hypot(shipObject.size.x, shipObject.size.y)
    shipObject.name = trueData.name
    shipObject.turningRate = tonumber(trueData.turnrate)
	shipObject.battery = { total = 5 * tonumber(trueData.energy), level = 5 * tonumber(trueData.energy), percent = 1.0 }
	shipObject.energy = { total = tonumber(trueData.energy), level = tonumber(trueData.energy), percent = 1.0 }
	shipObject.shield = { total = tonumber(trueData.life), level = tonumber(trueData.life), percent = 1.0 }
	if trueData.thrust ~= nil then
		shipObject.thrust = tonumber(trueData.thrust)
	else
		print("[WARNING]: No thrust data for ship " .. trueData.name)
	end
	if trueData.warp ~= nil then
		shipObject.warpSpeed = tonumber(trueData.warp)
		shipObject.canWarp = true
	else
		shipObject.canWarp = false
	end
    shipObject.maxSpeed = tonumber(trueData.maxspeed)
    shipObject.reverseThrust = tonumber(trueData.reverse)
    shipObject.beamName = trueData.beamname
    shipObject.pulseName = trueData.pulsename
    shipObject.specialName = trueData.specialname
	if trueData.beamname ~= nil then
		shipObject.beam = NewWeapon("Beam", trueData.beamname)
	end
	if trueData.pulsename ~= nil then
		shipObject.pulse = NewWeapon("Pulse", trueData.pulsename)
	end
	if trueData.specialname ~= nil then
		shipObject.special = NewWeapon("Special", trueData.specialname)
	end
    return shipObject
end

--[[------------------
	New Projectile
------------------]]--

function NewProjectile (weaponType, weaponClass, ownerShip)
	local rawData = xml.load("Config/Weapons/" .. weaponClass .. "/" .. weaponType .. ".xml")
	local projectileData = rawData[1]
	local trueData = {}
	for k, v in ipairs(projectileData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local projectileObject = { size = {} }
	if trueData.name == nil then
		print("ERROR: Projectile " .. projectileType .. " does not have a name.")
	end
	if trueData.mass == nil then
		trueData.mass = 0.01
	end
	projectileObject.physicsObject = physics.new_object(tonumber(trueData.mass))
	if projectileObject.image ~= nil then
		projectileObject.size.x, projectileObject.size.y = graphics.sprite_dimensions(projectileObject.image)
		projectileObject.physicsObject.collision_radius = hypot(projectileObject.size.x, projectileObject.size.y)
	end
	projectileObject.physicsObject.angle = ownerShip.physicsObject.angle
	if tonumber(trueData.velocity) ~= nil then
		projectileObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(projectileObject.physicsObject.angle) + ownerShip.physicsObject.velocity.x, y = tonumber(trueData.velocity) * math.sin(projectileObject.physicsObject.angle) + ownerShip.physicsObject.velocity.y }
	else
		projectileObject.physicsObject.velocity = { x = ownerShip.physicsObject.velocity.x, y = ownerShip.physicsObject.velocity.y }
	end
	if trueData.turnrate ~= nil then
		projectileObject.turningRate = tonumber(trueData.turnrate)
		projectileObject.maxSeek = tonumber(trueData.maxSeek)
		projectileObject.isSeeking = true
	else
		projectileObject.isSeeking = false
	end
	
	if weaponClass == "beam" then
		-- [ADAM, FIX] this piece of code is a hack, it relies on what little weapons we have right now to make the assumption
		if ownerShip.switch == true then
			projectileObject.physicsObject.position = { x = ownerShip.physicsObject.position.x + math.cos(projectileObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3), y = ownerShip.physicsObject.position.y + math.sin(projectileObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3) }
			ownerShip.switch = false
		else
			projectileObject.physicsObject.position = { x = ownerShip.physicsObject.position.x + math.cos(projectileObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3), y = ownerShip.physicsObject.position.y + math.sin(projectileObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3) }
			ownerShip.switch = true
		end
		-- cost
		ownerShip.energy.level = ownerShip.energy.level - tonumber(trueData.energyCost)
	elseif weaponClass == "pulse" then
		return
	elseif weaponClass == "special" then
		projectileObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
	elseif weaponClass == nil then
		print("[EntityLoad] ERROR: Weapon '" .. weaponType .. "' has no class. See NewProjectile")
	else
		print("[EntityLoad] ERROR: Unknown weapon class '" .. weaponClass .. "'. See NewProjectile")
	end

	projectileObject.life = tonumber(trueData.life)
--	projectileObject.weapOwner = weaponType
	projectileObject.start = mode_manager.time() * 1000
	return projectileObject
end

--[[------------------
	New Weapon
------------------]]--

function NewWeapon (weaponClass, weaponType)
	local rawData = xml.load("Config/Weapons/" .. weaponClass .. "/" .. weaponType .. ".xml")
	local weaponData = rawData[1]
	local trueData = {}
	for k, v in ipairs(weaponData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local weaponObject = { size = {} }
	weaponObject.name = trueData.name
	weaponObject.shortName = trueData.shortName
	weaponObject.cost = tonumber(trueData.energyCost)
	weaponObject.sound = trueData.fireSound
	weaponObject.damage = tonumber(trueData.damage)
	weaponObject.cooldown = tonumber(trueData.cooldown)
	weaponObject.max_projectiles = math.ceil(tonumber(trueData.life) / weaponObject.cooldown)
	weaponObject.life = tonumber(trueData.life)
	weaponObject.mass = tonumber(trueData.mass)
	weaponObject.ammo = tonumber(trueData.ammo)
	if trueData.thrust ~= nil then
		weaponObject.thrust = tonumber(trueData.thrust)
	end
	weaponObject.class = trueData.class
	-- class specifics
	if weaponObject.class == "beam" then
		weaponObject.length = tonumber(trueData.length)
	elseif weaponObject.class == "pulse" then
		if trueData.sprite ~= nil then
			weaponObject.image = trueData.sprite
		end
	elseif weaponObject.class == "special" then
		if trueData.sprite ~= nil then
			weaponObject.image = trueData.sprite
		end
	elseif weaponObject.class == nil then
		print("[EntityLoad] ERROR: Weapon '" .. weaponObject.name .. "' has no class. See NewWeapon")
	else
		print("[EntityLoad] ERROR: Unknown weapon class '" .. weaponObject.class .. "'. See NewWeapon")
	end
	return weaponObject
end

--[[------------------
	New Scenario
------------------]]--

function NewScenario (scenario)
	local rawData = xml.load("Config/Scenarios/" .. scenario .. ".xml")
	local scenarioData = rawData[1]
	local trueData = {}
	for k, v in ipairs(scenarioData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local scenarioObject = { {} }
	scenarioObject.name = trueData.name
	local n = 1
	scenarioObject.planet = {}
--[[
	while trueData.planet[n] ~= nil do
		scenarioObject.planet[n] =  { name = trueData.planet[n].name,
			location = { x = tonumber(trueData.planet[n].locationx), y = tonumber(trueData.planet[n].locationy) },
			sprite = trueData.planet[n].sprite,
			res_gen = tonumber(trueData.planet[n].resources_generated),
			build = trueData.planet[n].build }
		n = n + 1
	end --]]
	scenarioObject.planet =  { name = trueData.pname,
		location = { x = tonumber(trueData.plocationx), y = tonumber(trueData.plocationy) },
		sprite = trueData.psprite,
		res_gen = tonumber(trueData.presources_generated),
		build = trueData.pbuild, text = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3 } }
	scenarioObject.briefing = trueData.briefing
	return scenarioObject
end

--[[------------------
	New Explosion
------------------]]--

function NewExplosion (explosionType)
    local rawData = xml.load("Config/Explosions/" .. explosionType .. ".xml")
    local explosionData = rawData[1]
    local trueData = {}
    for k, v in ipairs(explosionData) do
        if type(v) == "table" then
            trueData[v.name] = v[1]
        end
    end
    local explosionObject = {size = {}}
    explosionObject.image = trueData.sprite
    explosionObject.size.x, explosionObject.size.y = graphics.sprite_dimensions(explosionObject.image)
    explosionObject.name = trueData.name
    explosionObject.frameDuration = tonumber(trueData.frameDuration)
    return explosionObject
end

--[[----------------------
	--{{--------------
		New Entity
	--------------}}--
----------------------]]--

-- this function should replace all of the other functions in this file

function NewEntity (entName, entType, entDir, entSubdir)
	local entTypeReal = entType
	if entType == "Projectile" then
		entType = "Weapon"
	end
	local rawData
	if entSubdir ~= nil then
		rawData = xml.load("Config/" .. entType.. "s/" .. entDir .. "/" .. entSubdir.. "/" .. entName .. ".xml")
	elseif entDir ~= nil then
		rawData = xml.load("Config/" .. entType.. "s/" .. entDir .. "/" .. entName .. ".xml")
	elseif entType ~= nil then
		rawData = xml.load("Config/" .. entType.. "s/" .. entName .. ".xml")
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
	if trueData.shortName ~= nil then
		entObject.shortName = trueData.shortName
	end
	if trueData.mass == nil then
		entObject.mass = 0.01
	else
		entObject.mass = tonumber(trueData.mass)
	end
	entObject.physicsObject = physics.new_object(entObject.mass)
	if trueData.sprite ~= nil then
		entObject.image = trueData.sprite
		entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entObject.image)
		entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
	end
	
	if entType == "Explosion" then
-- explosion-specific
		entObject.frameDuration = tonumber(trueData.frameDuration)
	elseif entType == "Scenario" then
-- scenario-specific
		entObject.planet =  { name = trueData.pname,
			location = { x = tonumber(trueData.plocationx), y = tonumber(trueData.plocationy) },
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
		elseif entObject.class == "pulse" then
		elseif entObject.class == "special" then
			entObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
		elseif entObject.class == nil then
			error("Weapon '" .. entObject.name .. "' has no class. See NewEntity", 7)
		else
			error("Unknown weapon class '" .. entObject.class .. "'. See NewEntity", 6)
		end
	elseif entType == "Projectile" then
-- projectile-specific
		entObject.physicsObject.angle = ownerShip.physicsObject.angle
		if tonumber(trueData.velocity) ~= nil then
			entObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(entObject.physicsObject.angle) + ownerShip.physicsObject.velocity.x, y = tonumber(trueData.velocity) * math.sin(entObject.physicsObject.angle) + ownerShip.physicsObject.velocity.y }
		else
			entObject.physicsObject.velocity = { x = ownerShip.physicsObject.velocity.x, y = ownerShip.physicsObject.velocity.y }
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
			if ownerShip.switch == true then
				entObject.physicsObject.position = { x = ownerShip.physicsObject.position.x + math.cos(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3), y = ownerShip.physicsObject.position.y + math.sin(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3) }
				ownerShip.switch = false
			else
				entObject.physicsObject.position = { x = ownerShip.physicsObject.position.x + math.cos(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3), y = ownerShip.physicsObject.position.y + math.sin(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3) }
				ownerShip.switch = true
			end
			-- cost
			ownerShip.energy.level = ownerShip.energy.level - tonumber(trueData.energyCost)
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
			entObject.beam = NewEntity(trueData.beamname, "Weapon", "Beam")
		end
		if trueData.pulsename ~= nil then
			entObject.pulse = NewEntity( trueData.pulsename, "Weapon", "Pulse")
		end
		if trueData.specialname ~= nil then
			entObject.special = NewEntity(trueData.specialname, "Weapon", "Special")
		end
	else
		error("Unknown entity of type " .. entType, 6)
	end
	cout_table(entObject, "object", false)
    return entObject
end