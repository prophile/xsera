-- old code
Ish_hCruiser_Size = {}
Ish_hCruiser_Size[1], Ish_hCruiser_Size[2] = graphics.sprite_dimensions("Ishiman/HeavyCruiser")

Gai_Carrier_Size = {}
Gai_Carrier_Size[1], Gai_Carrier_Size[2] = graphics.sprite_dimensions("Gaitori/Carrier")

explosion = {}
explosion[1], explosion[2] = graphics.sprite_dimensions("Explosions/BestExplosion")

import('PrintRecursive')
-- new code
function NewShip ( shipType )
    local rawData = xml.load("Config/Ships/" .. shipType .. ".xml")
    local shipData = rawData[1]
    --table.print_recursive(data)
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
