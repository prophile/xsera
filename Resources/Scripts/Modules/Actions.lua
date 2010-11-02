--import('Math')

local actionTable = {}

function ActivateTrigger(sender, owner)
	if owner == nil then
		CallAction(sender.triggers.activate,sender)
	
	elseif owner.status.energy >= sender.base.device.energyCost
	and (sender.base.device.ammo == -1 or sender.ammo > 0)
	and sender.lastActivated < realTime - sender.base.device.reload / TIME_FACTOR then
	
		sender.lastActivated = realTime

		if sender.ammo ~= -1 then
			sender.ammo = sender.ammo - 1
		end
		
		owner.status.energy = owner.status.energy - sender.base.device.energyCost
		
		if sender.lastPos == #sender.positions then
			sender.lastPos = 1
		else
			sender.lastPos = sender.lastPos + 1
		end
		
		CallAction(sender.base.actions.activate,sender,owner)
	end
end


function ExpireTrigger(owner)
	CallAction(owner.base.actions.expire,owner,nil)
end

function DestroyTrigger(owner)
	CallAction(owner.base.actions.destroy,owner,nil)
end

function CreateTrigger(owner)
	CallAction(owner.base.actions.create,owner,nil)
end

function CollideTrigger(owner,other)
	CallAction(owner.base.actions.collide,owner,other)
end

function ArriveTrigger(owner,other)
	CallAction(owner.base.actions.arrive,owner,other)
end

function CallAction(trigger, source, direct)
	if trigger ~= nil then
		local id
		local max = trigger.id + trigger.count - 1
		for id = trigger.id, max do
			local action = data.actions[id]
			actionTable[action.type](action, source, direct)
		end
	end
end

-- set a metatable so that an unknown action will return an action which does nothing
setmetatable(actionTable, {__index = function(table, key) return function(action, source, direct) end end})

--local function noAction(action, source, direct) end

-- actionTable["activate special"]         = noAction
-- actionTable["alter absolute cash"]      = noAction
-- actionTable["alter absolute location"]  = noAction
-- actionTable["alter age"]                = noAction
-- actionTable["alter base type"]          = noAction
-- actionTable["alter cloak"]              = noAction
-- actionTable["alter active condition"] = noAction
actionTable["alter health"] = function(action, source, direct)
	local p
	if action.subjectOverride ~= nil then
		p = scen.objects[action.subjectOverride]
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
actionTable["alter energy"] = function(action, source, direct)
	local p
	if action.subjectOverride ~= nil then
		p = scen.objects[action.subjectOverride]
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
-- actionTable["alter hidden"]       = noAction
-- actionTable["alter-location-action"]     = noAction
-- actionTable["alter max velocity"] = noAction
-- actionTable["alter occupation"]   = noAction
-- actionTable["alter offline"]      = noAction
-- actionTable["alter owner"]        = noAction
-- actionTable["alter special weapon"]      = noAction
-- actionTable["alter beam weapon"]      = noAction
-- actionTable["alter pulse weapon"]      = noAction
-- actionTable["alter spin"]         = noAction
-- actionTable["alter thrust"]       = noAction
actionTable["alter velocity"] = function(action, source, direct)
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
-- actionTable["assume initial object"] = noAction
actionTable["change score"] = function(action, source, direct)
	local player = action.player + 1
	local counter = action.score or 0
	local count = scen.counters[player][counter]
	scen.counters[player][counter] = count + action.amount
end
--actionTable["color flash"]     = noAction
--actionTable["computer select"] = noAction
actionTable["create object"] = function(action, source, direct)
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
	local count = action.min + math.random(0, action.range)
	for ctr = 1, count do
		local new = NewObject(action.baseType)
		
		new.physics.position = srcMotion.position + offset
		
		--[[BEG AQUIRE TARGET]]--
		local targ = selection.target and selection.target.physics or {position=GetMouseCoords(),velocity=vec(0,0)}
		--[[END AQUIRE TARGET]]--
		
		
		if new.type == "beam"
		and new.base.beam.type ~= "kinetic" then
			new.gfx.source = srcMotion
			new.gfx.offset = offset
			
			if new.base.beam.mode == "relative" then
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
		
		
		if source.base.attributes.autoTarget == true then
		
			if aimMethod == "smart" then
				local vel = (new.base.initialVelocity or 0) * SPEED_FACTOR
				new.physics.angle = AimTurret(srcMotion, targ, vel)
			else
				new.physics.angle = find_angle(targ.position, new.physics.position)
			end
		elseif action.directionRelative == true then
			new.physics.angle = srcMotion.angle
		else
			new.physics.angle = RandomReal(0, 2.0 * math.pi)
		end
		
--		if new.base["initial-direction"] ~= nil then
			new.physics.angle = new.physics.angle + math.pi * (new.base.initialDirection + math.random(0.0, new.base.initialDirectionRange))/180.0
--		end
		
		local iv = new.base.initialVelocity
		
		if action.velocityRelative == true then	
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
		
		if new.base.attributes.isGuided == true then
			new.control.accel = true
		end
		
		new.ai.owner = owner
		new.ai.creator = srcMotion.object_id
		
		CreateTrigger(new)
		scen.objects[new.physics.object_id] = new
	end
end

--actionTable["create object set destination"] = noAction
actionTable["declare winner"] = function(action, source, direct)
	Win()
	print("The winner is: " .. action.player)
end

actionTable["die"] = function(action, source, direct)
	if action.reflexive == true then
		source.status.dead = true
	else
		direct.status.dead = true
	end
end

-- actionTable["disable keys"]    = noAction
-- actionTable["display message"] = noAction
-- actionTable["enable keys"]     = noAction
-- actionTable["land at"]         = noAction
actionTable["make sparks"] = function(action, source, direct)
	--Aquire parent
	local parent
	if action.reflexive == true then
		parent = source
	else
		parent = direct
	end
	local theta = math.random(0,2*math.pi)
	local speed = action.velocity
	local range = 0
	if action.velocityRange ~= nil then
		range = action.velocityRange
	end
	graphics.add_particles("Sparks", action.count, parent.physics.position, {x = math.cos(theta) * speed, y = math.sin(theta) * speed}, {x = range, y = range}, {x = 0, y = 0}, 0.5, 0.4)
end

--actionTable["nil target"] = noAction
--actionTable["none"] = noAction
actionTable["play sound"] = function(action, source, direct)
	local rsound = data.sounds[action.soundId]
	local parent
	if action.reflexive == true then
		parent = source
	else
		parent = direct
	end
	if rsound ~= nil then
		if parent == nil or parent.physics == nil or
		   ((source.ai or direct.ai).creator == scen.playerShip.physics.object_id) then
			sound.play(rsound)
		else
			sound.play_positional(rsound, parent.physics.position, parent.physics.velocity)
		end
	else
		print("Sound '" .. action.soundId .. "' not found.")
	end
end

--actionTable["set destination"] = noAction
--actionTable["set zoom level"]        = noAction
