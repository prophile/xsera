function TestConditions(scen)
	for idx, cond in pairs(scen.conditions) do
		local type = cond.type
		if cond.active == true then
			cond.isTrue = Test[type](cond)
			if cond.isTrue == true then
				CallAction(cond.action)
				if cond.flags.trueOnlyOnce == true then
					cond.active = false
				end
			end
		end
	end
end

Test = {}

setmetatable(Test, {__index = function (table, key) return function(cond) return false end end})

-- Test["autopilot-condition"]
Test["counter-condition"] = function(cond)
	local player = cond["which-player"] + 1
	local counter = cond["which-counter"]
	local count = scen.counters[player][counter]
	if count == cond.amount then
		return true
	else
		return false
	end
end

Test["counter-greater-condition"] = function(cond)
	local player = cond["which-player"] + 1
	local counter = cond["which-counter"]
	local count = scen.counters[player][counter]
	if count > cond.amount then
		return true
	else
		return false
	end
end

-- Test["current-computer-condition"]
-- Test["current-message-condition"]
Test["destruction-condition"] = function(cond)
	if scen.objects[cond.value + 1] == nil then
		return true
	else
		return false
	end
end

--Test["direct-is-subject-target-condition"]
Test["distance-greater-condition"] = function(cond)
	local subject = scen.objects[cond["subject-object"]+1]
	local direct = scen.objects[cond["direct-object"]+1]
	if hypot2(subject.physics.position, direct.physics.position) > math.sqrt(cond.value) then
		return true
	else
		return false
	end
end

Test["half-health-condition"] = function(cond)
	local objectStatus = scen.objects[cond["subject-object"]+1].status
	if objectStatus.health * 2 <= objectStatus.healthMax then
		return true
	else
		return false
	end
end

-- Test["is-auxiliary-object-condition"]
-- Test["is-target-object-condition"]
-- Test["no-condition"]
Test["no-ships-left-condition"] = function(cond)
	local player = cond["which-player"]
	for i,o in pairs(scen.objects) do
		if o.ai.owner == player then
			return false
		end
	end
	return true
end

-- Test["not-autopilot-condition"]
-- Test["object-is-being-built-condition"]
Test["owner-condition"] = function(cond)
	local player = cond.value
	local object = scen.objects[cond["subject-object"] + 1]
	if object.ai.owner == player then
		return true
	else
		return false
	end
end

Test["proximity-condition"] = function(cond)
	local subject = scen.objects[cond["subject-object"]+1]
	local direct = scen.objects[cond["direct-object"]+1]
	if hypot2(subject.physics.position, direct.physics.position) > math.sqrt(cond.value) then
		return true
	else
		return false
	end
end

-- Test["subject-is-player-condition"]

Test["time-condition"] = function(cond)
	--[[
	May need to measure from when the condition is first tested. Instead of scenario start.
	--]]
	if cond.value / TIME_FACTOR >= realtime then
		return true
	else
		return false
	end
end

Test["velocity-less-than-equal-to-condition"] = function(cond)
	if cond.value * SPEED_FACTOR >= hypot1(scen.objects[cond["subject-object"] + 1]) then
		return true
	else
		return false
	end
end

-- Test["zoom-level-condition"]
