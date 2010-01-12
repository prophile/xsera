function ActivateTrigger(device, owner)
	if xor(owner == nil, owner.energy.level >= device.device["energy-cost"])
	and xor(device.ammo == -1, device.ammo > 0)
	and device.device.lastActivated < mode_manager.time() - device.device["fire-time"] / TIME_FACTOR then

			device.device.lastActivated = mode_manager.time()

			if device.ammo ~= -1 then
				device.ammo = device.ammo - 1
			end
			
			if owner ~= nil then
				owner.energy.level = owner.energy.level - device.device["energy-cost"]
			end
			
			
			if device.position.last == #device.position then
				device.position.last = 1
			else
				device.position.last = device.position.last + 1
			end
			
			callAction(device.trigger["activate"],device,nil)
				
	end
end


function ExpireTrigger(owner)
end

function DestroyTrigger(owner)
end

function CreateTrigger(owner)
	callAction(owner.trigger["create"],owner,nil)
end

function CollideTrigger(owner,other)
end

function ArriveTrigger(owner,other)
end

function callAction(trigger, source, direct)
	if trigger ~= nil then
		local id
		local max = trigger.id + trigger.count - 1
		for id = trigger.id, max do
			local action = gameData["Actions"][id]
			actionTable[action.type](action, source, direct)
		end
	end
end


actionTable = {
["activate-special-action"] = function(action, source, direct) end,
["alter-absolute-cash-action"] = function(action, source, direct) end,
["alter-absolute-location-action"] = function(action, source, direct) end,
["alter-age-action"] = function(action, source, direct)
	if action.reflexive == "true" then
		source.age = action.value
	else
		direct.age = action.value
	end
end,
["alter-base-type-action"] = function(action, source, direct) end,
["alter-cloak-action"] = function(action, source, direct) end,
["alter-condition-true-yet-action"] = function(action, source, direct) end,
["alter-damage-action"] = function(action, source, direct) end,
["alter-energy-action"] = function(action, source, direct)
	if action.reflexive == "true" then
		source.energy = action.value
	else
		direct.energy = action.value
	end
end,
["alter-hidden-action"] = function(action, source, direct) end,
["alter-location-action"] = function(action, source, direct) end,
["alter-max-velocity-action"] = function(action, source, direct) end,
["alter-occupation-action"] = function(action, source, direct) end,
["alter-offline-action"] = function(action, source, direct) end,
["alter-owner-action"] = function(action, source, direct) end,
["alter-special-action"] = function(action, source, direct) end,
["alter-spin-action"] = function(action, source, direct) end,
["alter-thrust-action"] = function(action, source, direct) end,
["alter-velocity-action"] = function(action, source, direct) end,
["assume-initial-object-action"] = function(action, source, direct) end,
["change-score-action"] = function(action, source, direct) end,
["color-flash-action"] = function(action, source, direct) end,
["computer-select-action"] = function(action, source, direct) end,
["create-object-action"] = function(action, source, direct)
--Aquire parent data
local p
local offset = {x = 0.0, y = 0.0}
if action.reflexive == "true" then --There may be more conditions to consider
	if source.device ~= nil then
		p = source.parent.physics
		offset = RotatePoint(source.position[source.position.last],p.angle-math.pi/2.0)
	else
		p = source.physics
	end
else
	p = direct.physics
end

--create object(s)
local count = action["how-many-min"] + math.random(0, action["how-many-range"])
for ctr = 1, count do
local new = NewObject(action["which-base-type"])

new.physics.position = {
		x = p.position.x + offset.x;
		y = p.position.y + offset.y;
		}

if action["direction-relative"] == "true" then
new.physics.angle = p.angle
else
new.physics.angle = RandomReal(0, 2.0 * math.pi)
end

if new["initial-velocity"] == nil then
new["initial-velocity"] = 0
end

if action["velocity-relative"] == "true" then

new.physics.velocity = {
x = p.velocity.x + SPEED_FACTOR * new["initial-velocity"] * math.cos(new.physics.angle);
y = p.velocity.y + SPEED_FACTOR * new["initial-velocity"] * math.sin(new.physics.angle);
}
else
new.physics.velocity = {
x =  SPEED_FACTOR * new["initial-velocity"] * math.cos(new.physics.angle);
y =  SPEED_FACTOR * new["initial-velocity"] * math.sin(new.physics.angle);
}

end

if new.attributes["is-guided"] == true then
	new.control.accel = true
end
table.insert(scen.objects,new)
end
end,
["create-object-set-dest-action"] = function(action, source, direct) end,
["declare-winner-action"] = function(action, source, direct) end,
["die-action"] = function(action, source, direct) end,
["disable-keys-action"] = function(action, source, direct) end,
["display-message-action"] = function(action, source, direct) end,
["enable-keys-action"] = function(action, source, direct) end,
["land-at-action"] = function(action, source, direct) end,
["make-sparks-action"] = function(action, source, direct) end,
["nil-target-action"] = function(action, source, direct) end,
["no-action"] = function(action, source, direct) end,
["play-sound-action"] = function(action, source, direct) end,
["set-destination-action"] = function(action, source, direct) end,
["set-zoom-action"] = function(action, source, direct) end,
}