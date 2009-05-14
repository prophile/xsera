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
	if trueData.sprite ~= nil then
		projectileObject.image = trueData.sprite
	end
	if trueData.mass == nil then
		trueData.mass = 0.01
	end
	projectileObject.physicsObject = physics.new_object(tonumber(trueData.mass))
	if projectileObject.image ~= nil then
		projectileObject.size.x, projectileObject.size.y = graphics.sprite_dimensions(projectileObject.image)
		projectileObject.physicsObject.collision_radius = hypot(projectileObject.size.x, projectileObject.size.y)
	end
	if trueData.velocity ~= nil then
		projectileObject.velocity = { total = trueData.velocity, x, y }
	end
	if trueData.turnrate ~= nil then
		projectileObject.turningRate = tonumber(trueData.turnrate)
		projectileObject.maxSeek = tonumber(trueData.maxSeek)
		projectileObject.isSeeking = true
	else
		projectileObject.isSeeking = false
	end
	if trueData.thrust ~= nil then
		projectileObject.thrust = tonumber(trueData.thrust)
	end
	projectileObject.life = tonumber(trueData.life)
	projectileObject.owner = ownerShip.name
	projectileObject.weapOwner = weaponType
	projectileObject.class = trueData.class
	-- class specifics
	if projectileObject.class == "beam" then
		projectileObject.length = tonumber(trueData.length)
	elseif projectileObject.class == "pulse" then
		
	elseif projectileObject.class == "special" then
		
	elseif projectileObject.class == nil then
		print("[EntityLoad] ERROR: Projectile '" .. projectileObject.name .. "' has no class. See NewProjectile")
	else
		print("[EntityLoad] ERROR: Unknown weapon class '" .. projectileObject.class .. "'. See NewProjectile")
	end
	
	
	
	
	projectileObject.shortName = trueData.shortName
	projectileObject.cost = tonumber(trueData.energyCost)
	projectileObject.sound = trueData.fireSound
	projectileObject.damage = tonumber(trueData.damage)
	projectileObject.cooldown = tonumber(trueData.cooldown)
	projectileObject.max_projectiles = math.ceil(projectileObject.life / projectileObject.cooldown)
	projectileObject.name = trueData.name
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
	if weaponClass == "Beam" then
		weaponObject.energy = tonumber(trueData.energy)
	elseif weaponClass == "Pulse" then
		weaponObject.energy = tonumber(trueData.energy)
	elseif weaponClass == "Special" then
		weaponObject.ammo = tonumber(trueData.ammo)
	else
		print("[EntityLoad] ERROR: Unknown weapon class '" .. projectileObject.type .. "'. See NewWeapon")
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