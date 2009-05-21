import('PrintRecursive')

--[[------------------
	New Ship
------------------]]--

function NewShip (shipType, shipOwner)
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
	if trueData.energy ~= nil then
		shipObject.energy = tonumber(trueData.energy)
	end
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


--[[ [ADAM, ALISTAIR, DEMO2]
- the functions of NewProjectile and NewWeapon are mixed...
- weapon should contain name, short name, firing sound, sprite, etc.
- projectile should contain physics and changeable aspects of any projectile

- Also, I should make better use of ownerShip by making angle, velocity, etc. equal
--]]

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
		ownerShip.charge.level = ownerShip.charge.level - tonumber(trueData.energyCost)
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
	scenarioObject.planet =  { name = trueData.pname,
			location = { x = tonumber(trueData.plocationx), y = tonumber(trueData.plocationy) },
			sprite = trueData.psprite,
			res_gen = tonumber(trueData.presources_generated),
			build = { } }
	if trueData.build1 ~= nil then
		scenarioObject.planet.build[1] = trueData.build1
	end
	if trueData.build2 ~= nil then
		scenarioObject.planet.build[2] = trueData.build2
	end
	if trueData.build3 ~= nil then
		scenarioObject.planet.build[3] = trueData.build3
	end
	if trueData.build4 ~= nil then
		scenarioObject.planet.build[4] = trueData.build4
	end
	if trueData.build5 ~= nil then
		scenarioObject.planet.build[5] = trueData.build5
	end
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