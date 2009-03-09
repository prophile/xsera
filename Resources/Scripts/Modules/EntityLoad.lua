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
	New Bullet
------------------]]--


--[[ BULLETIN: [ADAM, ALASTAIR, DEMO2]
- the functions of NewBullet and NewWeapon are mixed...
- weapon should contain name, short name, firing sound, sprite, etc.
- bullet should contain physics (anything else?)
- haha, BULLETin, get it? BULLET? IN?

- Also, I should make better use of ownerShip (heh, TURBOPUNS) by making angle, velocity, etc. equal
--]]

function NewBullet (bulletType, ownerShip)
	local rawData = xml.load("Config/Bullets/" .. bulletType .. ".xml")
	local bulletData = rawData[1]
	local trueData = {}
	for k, v in ipairs(bulletData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local bulletObject = { size = {} }
	if trueData.name == nil then
		print("ERROR: Bullet " .. bulletType .. " does not have a name.")
	end
	bulletObject.name = trueData.name
	bulletObject.shortName = trueData.shortName
	bulletObject.sound = trueData.fireSound
	if trueData.sprite ~= nil then
		bulletObject.image = trueData.sprite
	end
	if trueData.mass == nil then
		trueData.mass = 1
	end
	bulletObject.physicsObject = physics.new_object(tonumber(trueData.mass))
	if bulletObject.image ~= nil then
		bulletObject.size.x, bulletObject.size.y = graphics.sprite_dimensions(bulletObject.image)
		bulletObject.physicsObject.collision_radius = hypot(bulletObject.size.x, bulletObject.size.y)
	end
	if trueData.velocity ~= nil then
		bulletObject.velocity = { total = trueData.velocity, x, y }
	end
	if trueData.turnrate ~= nil then
		bulletObject.turningRate = tonumber(trueData.turnrate)
		bulletObject.maxSeekAngle = tonumber(trueData.maxseekangle)
	end
	if trueData.thrust ~= nil then
		bulletObject.thrust = tonumber(trueData.thrust)
	end
	bulletObject.life = tonumber(trueData.life)
	bulletObject.damage = tonumber(trueData.damage)
	bulletObject.cooldown = tonumber(trueData.cooldown)
	bulletObject.max_bullets = math.ceil(bulletObject.life / bulletObject.cooldown)
	bulletObject.owner = ownerShip.name
	bulletObject.cost = tonumber(trueData.energyCost)
	bulletObject.class = trueData.class
	-- class specifics
	if bulletObject.class == "beam" then
		bulletObject.length = tonumber(trueData.length)
	elseif bulletObject.class == "pulse" then
		
	elseif bulletObject.class == "special" then
		
	elseif bulletObject.class == nil then
		print("[EntityLoad] ERROR: Bullet '" .. bulletObject.name .. "' has no class. See NewBullet")
	else
		print("[EntityLoad] ERROR: Unknown weapon class '" .. bulletObject.class .. "'. See NewBullet")
	end
	return bulletObject
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
		print("[EntityLoad] ERROR: Unknown weapon class '" .. bulletObject.type .. "'. See NewWeapon")
	end
	return weaponObject
end

--[[------------------
	New Scenario
------------------]]--

function NewScenario (scenarioType)
	local rawData = xml.load("Config/Scenarios/" .. scenarioType .. ".xml")
	local scenarioData = rawData[1]
	local trueData = {}
	for k, v in ipairs(scenarioData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local scenarioObject = {}
	scenarioObject.name = trueData.name
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