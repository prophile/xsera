import('PrintRecursive')

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
    local mass = trueData.mass
    shipObject.physicsObject = physics.new_object(tonumber(trueData.mass))
    shipObject.physicsObject.collision_radius = hypot(shipObject.size.x, shipObject.size.y)
    shipObject.name = trueData.name
    shipObject.turningRate = tonumber(trueData.turnrate)
    shipObject.thrust = tonumber(trueData.thrust)
    shipObject.warpThrust = tonumber(trueData.warp)
    shipObject.reverseThrust = tonumber(trueData.reverse)
	if trueData.specialname ~= nil then
		shipObject.special = NewWeapon("Special", trueData.specialname)
	end
	if trueData.beamname ~= nil then
		shipObject.beam = NewWeapon("Beam", trueData.beamname)
	end
    return shipObject
end

function NewBullet (bulletType)
	local rawData = xml.load("Config/Bullets/" .. bulletType .. ".xml")
	local bulletData = rawData[1]
	local trueData = {}
	for k, v in ipairs(bulletData) do
		if type(v) == "table" then
			trueData[v.name] = v[1]
		end
	end
	local bulletObject = { size = {} }
	bulletObject.image = trueData.sprite
	if bulletObject.image ~= nil then
		bulletObject.size.x, bulletObject.size.y = graphics.sprite_dimensions(bulletObject.image)
		bulletObject.physicsObject = physics.new_object(tonumber(trueData.mass))
		bulletObject.physicsObject.collision_radius = hypot(bulletObject.size.x, bulletObject.size.y)
	end
	local mass = trueData.mass
	bulletObject.name = trueData.name
	bulletObject.turningRate = tonumber(trueData.turnrate)
	bulletObject.thrust = tonumber(trueData.thrust)
	bulletObject.life = tonumber(trueData.life)
	bulletObject.damage = tonumber(trueData.damage)
	bulletObject.cooldown = tonumber(trueData.cooldown)
	bulletObject.max_seek_angle = tonumber(trueData.maxseekangle)
	return bulletObject
end

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
		print("Unknown weapon class. See EntityLoad.lua, function NewWeapon")
	end
	return weaponObject
end

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