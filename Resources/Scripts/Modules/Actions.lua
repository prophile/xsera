--import('Math')

local actionTable = {}

function ActivateTrigger(sender, owner)
	if owner == nil then
	
		CallAction(sender.triggers["activate"],sender)
	
	elseif owner.status.energy >= sender.base.device["energy-cost"]
	and (sender.base.device.ammo == -1
	or sender.ammo > 0)
	and sender.lastActivated < realTime - sender.base.device["fire-time"] / TIME_FACTOR then

			sender.lastActivated = realTime

			if sender.ammo ~= -1 then
				sender.ammo = sender.ammo - 1
			end
			
--			if owner ~= nil then
			owner.status.energy = owner.status.energy - sender.base.device["energy-cost"]
--			end
			
			
			if sender.lastPos == #sender.positions then
				sender.lastPos = 1
			else
				sender.lastPos = sender.lastPos + 1
			end
			
			CallAction(sender.triggers["activate"],sender,owner)
				
	end
end


function ExpireTrigger(owner)
	CallAction(owner.triggers["expire"],owner,nil)
end

function DestroyTrigger(owner)
	CallAction(owner.triggers["destroy"],owner,nil)
end

function CreateTrigger(owner)
	CallAction(owner.triggers["create"],owner,nil)
end

function CollideTrigger(owner,other)
	CallAction(owner.triggers["collide"],owner,other)
end

function ArriveTrigger(owner,other)
	CallAction(owner.triggers["arrive"],owner,other)
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

-- set a metatable so that an unknown action will return an action which does nothing
setmetatable(actionTable, {__index = function(table, key) return function(action, source, direct) end end})

--local function noAction(action, source, direct) end

-- actionTable["activate-special-action"]         = noAction
-- actionTable["alter-absolute-cash-action"]      = noAction
-- actionTable["alter-absolute-location-action"]  = noAction
-- actionTable["alter-age-action"]                = noAction
-- actionTable["alter-base-type-action"]          = noAction
-- actionTable["alter-cloak-action"]              = noAction
-- actionTable["alter-condition-true-yet-action"] = noAction
actionTable["alter-damage-action"] = function(action, source, direct)
	local p
	if action["initial-subject-override"] ~= nil then
		p = scen.objects[action["initial-subject-override"]]
	elseif action.reflexive == true then
		p = source
	else
		p = direct
	end

	if p ~= nil then
		p.status.health = p.status.health + action.value
		if p.status.health > p.status.healthMax then
			p.status.health = p.status.healthMax
		end
	end
end
actionTable["alter-energy-action"] = function(action, source, direct)
	local p
	if action["initial-subject-override"] ~= nil then
		p = scen.objects[action["initial-subject-override"]]
	elseif action.reflexive == true then
		p = source
	else
		p = direct
	end

	if p ~= nil then
		p.status.energy = p.status.energy + action.value
		if p.status.energy > p.status.energyMax then
			p.status.energy = p.status.energyMax
		end
	end
end
-- actionTable["alter-hidden-action"]       = noAction
-- actionTable["alter-location-action"]     = noAction
-- actionTable["alter-max-velocity-action"] = noAction
-- actionTable["alter-occupation-action"]   = noAction
-- actionTable["alter-offline-action"]      = noAction
-- actionTable["alter-owner-action"]        = noAction
-- actionTable["alter-special-action"]      = noAction
-- actionTable["alter-spin-action"]         = noAction
-- actionTable["alter-thrust-action"]       = noAction
actionTable["alter-velocity-action"] = function(action, source, direct)
	local p
	local angle = source.physics.angle
	local delta = PolarVec(math.sqrt(action.minimum)+math.random(0.0,math.sqrt(action.range)), angle)
	
	if action.reflexive == true then
		p = source.physics
	else
		p = direct.physics
	end

	if action.relative == true then
		p.velocity = p.velocity +  delta
	else
		p.velocity = delta
	end
end
-- actionTable["assume-initial-object-action"] = noAction
actionTable["change-score-action"] = function(action, source, direct)
	local player = action["which-player"] + 1
	local counter = action["which-counter"] or 0
	local count = scen.counters[player][counter]
	scen.counters[player][counter] = count + action.amount
end
--actionTable["color-flash-action"]     = noAction
--actionTable["computer-select-action"] = noAction
actionTable["create-object-action"] = function(action, source, direct)
	--Aquire parent data
	local srcMotion
	local offset = vec(0,0)
	local owner = -1
	if action.reflexive == true then --There may be more conditions to consider
		if source.type == nil then --Weapon firing
			srcMotion = direct.physics
			offset = RotatePoint(source.positions[source.lastPos],srcMotion.angle-math.pi/2.0)
			owner = direct.ai.owner
		else
			srcMotion = source.physics
			owner = source.ai.owner
		end
	else
		srcMotion = direct.physics
		owner = direct.ai.owner
	end
	
	
	--create object(s)
	local count = action["how-many-min"] + math.random(0, action["how-many-range"])
	for ctr = 1, count do
		local new = NewObject(action["which-base-type"])
		
		new.physics.position = srcMotion.position + offset
		
		--[[BEG AQUIRE TARGET]]--
		local targ = selection.target and selection.target.physics or {position=GetMouseCoords(),velocity=vec(0,0)}
		--[[END AQUIRE TARGET]]--
		
		
		if new.type == "beam"
		and new.base.beam.kind ~= "kinetic" then
			new.gfx.source = srcMotion
			new.gfx.offset = offset
			
			if new.base.beam.kind == "bolt-relative"
			or new.base.beam.kind == "static-relative" then
				local len = math.min(new.base.beam.range, hypot2(new.gfx.source.position, targ.position))
				local dir = NormalizeVec(targ.position - new.physics.position)
				
				new.gfx.relative = dir * len		
				new.physics.position = new.physics.position +  new.gfx.relative
			else
		
				new.gfx.target = targ
				
				local len =  math.min(new.base.beam.range,hypot2(new.physics.position,new.gfx.target.position))
				local dir = NormalizeVec(new.target.position - new.gfx.source.position)
				
				new.physics.position = dir * len
		
			end
		end
		
		
		if source.base.attributes["auto-target"] == true then
		
			if aimMethod == "smart" then
				local vel = (new.base["initial-velocity"] or 0) * SPEED_FACTOR
				new.physics.angle = AimTurret(srcMotion, targ, vel)
			else
				new.physics.angle = find_angle(targ.position, new.physics.position)
			end
		elseif action["direction-relative"] == true then
			new.physics.angle = srcMotion.angle
		else
			new.physics.angle = RandomReal(0, 2.0 * math.pi)
		end
		
		if new.base["initial-direction"] ~= nil then
			new.physics.angle = new.physics.angle + math.pi * (new.base["initial-direction"] + math.random(0.0, new.base["initial-direction-range"] or 0.0))/180.0
		end
		
		local iv = new.base["initial-velocity"] or 0.0
		
		if action["velocity-relative"] == true then	
			new.physics.velocity = {
				x = srcMotion.velocity.x + SPEED_FACTOR * iv * math.cos(new.physics.angle);
				y = srcMotion.velocity.y + SPEED_FACTOR * iv * math.sin(new.physics.angle);
			}
		else
			new.physics.velocity = {
				x =  SPEED_FACTOR * iv * math.cos(new.physics.angle);
				y =  SPEED_FACTOR * iv * math.sin(new.physics.angle);
			}	
		end
		
		if new.base.attributes["is-guided"] == true then
			new.control.accel = true
		end
		
		new.ai.owner = owner
		new.ai.creator = srcMotion.object_id
		
		CreateTrigger(new)
		scen.objects[new.physics.object_id] = new
	end
end

--actionTable["create-object-set-dest-action"] = noAction
actionTable["declare-winner-action"] = function(action, source, direct)
	Win()
	print("The winner is: " .. action["which-player"])
end

actionTable["die-action"] = function(action, source, direct)
	if action.reflexive == true then
		source.status.dead = true
	else
		direct.status.dead = true
	end
end

-- actionTable["disable-keys-action"]    = noAction
-- actionTable["display-message-action"] = noAction
-- actionTable["enable-keys-action"]     = noAction
-- actionTable["land-at-action"]         = noAction
actionTable["make-sparks-action"] = function(action, source, direct)
	--Aquire parent
	local parent
	if action.reflexive == true then
		parent = source
	else
		parent = direct
	end
	local theta = math.random(0,2*math.pi)
	local speed = action["speed"]
	local range = 0
	if action["velocity-range"] ~= nil then
		range = action["velocity-range"]
	end
	graphics.add_particles("Sparks", action["how-many"], parent.physics.position, {x = math.cos(theta) * speed, y = math.sin(theta) * speed}, {x = range, y = range}, {x = 0, y = 0}, 0.5, 0.4)
end

--actionTable["nil-target-action"] = noAction
--actionTable["no-action"]         = noAction
actionTable["play-sound-action"] = function(action, source, direct)
	local rsound = gameData["Sounds"][action["id-minimum"]]
	local parent
	if action.reflexive == true then
		parent = source
	else
		parent = direct
	end
	if rsound ~= nil then
		if ((source.ai or direct.ai).creator == scen.playerShip.physics.object_id) then
			sound.play(rsound)
		else
			sound.play_positional(rsound, parent.physics.position, parent.physics.velocity)
		end
	else
		print("Sound '" .. action["id-minimum"] .. "' not found.")
	end
end

--actionTable["set-destination-action"] = noAction
--actionTable["set-zoom-action"]        = noAction
