function TestConditions(scen)
	for idx, cond in pairs(scen.conditions) do
		local type = cond.type
		if cond.active == true
		and Test[type](cond) == true then
			CallAction(cond.action)
			if cond["condition-flags"]["true-only-once"] == true then
				cond.active = false
			end
		end
	end
end

Test = {
["autopilot-condition"] = function(cond) end;
["counter-condition"] = function(cond) end;
["counter-greater-condition"] = function(cond) end;
["current-computer-condition"] = function(cond) end;
["current-message-condition"] = function(cond) end;
["destruction-condition"] = function(cond)
	if scen.objects[cond.value + 2] == nil then
		return true
	else
		return false
	end
end;
["direct-is-subject-target-condition"] = function(cond) end;
["distance-greater-condition"] = function(cond) end;
["half-health-condition"] = function(cond) end;
["is-auxiliary-object-condition"] = function(cond) end;
["is-target-object-condition"] = function(cond) end;
["no-condition"] = function(cond) return false end;
["no-ships-left-condition"] = function(cond) end;
["not-autopilot-condition"] = function(cond) end;
["object-is-being-built-condition"] = function(cond) end;
["owner-condition"] = function(cond) end;
["proximity-condition"] = function(cond) end;
["subject-is-player-condition"] = function(cond) end;
["time-condition"] = function(cond) end;
["velocity-less-than-equal-to-condition"] = function(cond) end;
["zoom-level-condition"] = function(cond) end;
}