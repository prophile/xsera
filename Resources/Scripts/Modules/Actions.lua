function ActivateTrigger(device, owner)
	if device.device == nil then
	
		CallAction(device.trigger["activate"],device)
	
	elseif xor(owner == nil, owner.energy >= device.device["energy-cost"])
	and xor(device.ammo == -1, device.ammo > 0)
	and device.device.lastActivated < mode_manager.time() - device.device["fire-time"] / TIME_FACTOR then

			device.device.lastActivated = mode_manager.time()

			if device.ammo ~= -1 then
				device.ammo = device.ammo - 1
			end
			
			if owner ~= nil then
				owner.energy = owner.energy - device.device["energy-cost"]
			end
			
			
			if device.position.last == #device.position then
				device.position.last = 1
			else
				device.position.last = device.position.last + 1
			end
			
			CallAction(device.trigger["activate"],device,nil)
				
	end
end


function ExpireTrigger(owner)
	CallAction(owner.trigger["expire"],owner,nil)
end

function DestroyTrigger(owner)
	CallAction(owner.trigger["destroy"],owner,nil)
end

function CreateTrigger(owner)
	CallAction(owner.trigger["create"],owner,nil)
end

function CollideTrigger(owner,other)
	CallAction(owner.trigger["collide"],owner,other)
end

function ArriveTrigger(owner,other)
	CallAction(owner.trigger["arrive"],owner,other)
end

function CallAction(trigger, source, direct)
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
local owner
if action.reflexive == "true" then --There may be more conditions to consider
	if source.device ~= nil then
		p = source.parent.physics
		owner = source.parent.owner
		offset = RotatePoint(source.position[source.position.last],p.angle-math.pi/2.0)
	else
		p = source.physics
		owner = source.owner
	end
else
	p = direct.physics
	owner = direct.owner
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

if new["initial-direction"] ~= nil then
	if new["initial-direction-range"] ~= nil then
		new.physics.angle = new.physics.angle + math.pi *( new["initial-direction"] + math.random(0.0, new["initial-direction-range"]))/180
	else
		new.physics.angle = new.physics.angle + math.pi * new["initial-direction"] / 180
	end
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

new.owner = owner
table.insert(scen.objects,new)
end
end,
["create-object-set-dest-action"] = function(action, source, direct) end,
["declare-winner-action"] = function(action, source, direct) end,
["die-action"] = function(action, source, direct)
	if action.reflexive == "true" then
		source.dead = true
		print(source.name)
	else
		direct.dead = true
		print(direct.name)
	end
end,
["disable-keys-action"] = function(action, source, direct) end,
["display-message-action"] = function(action, source, direct) end,
["enable-keys-action"] = function(action, source, direct) end,
["land-at-action"] = function(action, source, direct) end,
["make-sparks-action"] = function(action, source, direct)
--Aquire parent
	local p
	if action.reflexive == "true" then
		p = source
	else
		p = direct
	end
	local theta = math.random(0,2*math.pi)
	local speed = action["speed"]
	local range = 0
	if action["velocity-range"] ~= nil then
		range = action["velocity-range"]
	end
	graphics.add_particles("Sparks", action["how-many"], p.physics.position, {x = math.cos(theta) * speed, y = math.sin(theta) * speed}, {x = range, y = range}, {x = 0, y = 0}, 0.5, 0.4)
	
end,
["nil-target-action"] = function(action, source, direct) end,
["no-action"] = function(action, source, direct) end,
["play-sound-action"] = function(action, source, direct)

	local rsound = gameData["Sounds"][action["id-minimum"]]
	if rsound ~= nil then
		sound.play(rsound)
	else
		print("Sound '" .. action["id-minimum"] .. "' not found.")
	end
end,
["set-destination-action"] = function(action, source, direct) end,
["set-zoom-action"] = function(action, source, direct) end,
}