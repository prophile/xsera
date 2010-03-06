function TestConditions(scen)
	for idx, cond in pairs(scen.conditions) do
		local type = cond.type
		if cond.active == true then
			cond.isTrue = Test[type](cond)
			if cond.isTrue == true then
				CallAction(cond.action)
				if cond["condition-flags"]["true-only-once"] == true then
					cond.active = false
				end
			end
		end
	end
end

Test = {
["autopilot-condition"] = function(cond) end;
["counter-condition"] = function(cond)
	local player = cond["which-player"] + 1
	local counter = cond["which-counter"]
	local count = scen.counters[player][counter]
	if count == cond.amount then
		return true
	else
		return false
	end
end;
["counter-greater-condition"] = function(cond)
	local player = cond["which-player"] + 1
	local counter = cond["which-counter"]
	local count = scen.counters[player][counter]
	if count > cond.amount then
		return true
	else
		return false
	end
end;
["current-computer-condition"] = function(cond) end;
["current-message-condition"] = function(cond) end;
["destruction-condition"] = function(cond)
	if scen.objects[cond.value + 1] == nil then
		return true
	else
		return false
	end
end;
["direct-is-subject-target-condition"] = function(cond) end;
["distance-greater-condition"] = function(cond) end;
["half-health-condition"] = function(cond)
	local objectStatus = scen.objects[cond["subject-object"]+1].status
	if objectStatus.health * 2 <= objectStatus.healthMax then
		return true
	else
		return false
	end
end;
["is-auxiliary-object-condition"] = function(cond) end;
["is-target-object-condition"] = function(cond) end;
["no-condition"] = function(cond) return false end;
["no-ships-left-condition"] = function(cond)
	local player = cond["which-player"]
	for i,o in pairs(scen.objects) do
		if o.ai.owner == player then
			return false
		end
	end
	return true
end;
["not-autopilot-condition"] = function(cond) end;
["object-is-being-built-condition"] = function(cond) end;
["owner-condition"] = function(cond)
	local player = cond.value
	local object = scen.objects[cond["subject-object"] + 1]
	if object.ai.owner == player then
		return true
	else
		return false
	end
end;
["proximity-condition"] = function(cond) end;
["subject-is-player-condition"] = function(cond) end;
["time-condition"] = function(cond) end;
["velocity-less-than-equal-to-condition"] = function(cond) end;
["zoom-level-condition"] = function(cond) end;
}