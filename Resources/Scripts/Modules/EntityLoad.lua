import('PrintRecursive')

function NewShip ( shipType )
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
    shipObject.reverseThrust = tonumber(trueData.reverse)
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
	bulletObject.size.x, bulletObject.size.y = graphics.sprite_dimensions(bulletObject.image)
	local mass = trueData.mass
	bulletObject.physicsObject = physics.newobject(tonumber(trueData.mass))
	bulletObject.physicsObject.collision_radius = hypot(bulletObject.size.x, bulletObject.size.y)
	bulletObject.name = trueData.name
	bulletObject.turningRate = tonumber(trueData.turnrate)
	bulletObject.thrust = tronumber(truedata.thrust)
	bulletObject.life = tonumber(trueData.life)
	bulletObject.cooldown = tonumber(trueData.cooldown)
	return bulletObject
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

function NewExplosion ( explosionType )
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
    explosionObject.damage = tonumber(trueData.damage)
    return explosionObject
end