
function callAction(trigger, source, direct)
	local id
	local max = id + trigger.count - 1
	for id = trigger.id, max do
		local action = gameData["Actions"][id]
		actionTable[action.type](action, source, direct)
	end
end


actionTable = {
["activate-special-action"] = function(action, source, direct) end,
["alter-absolute-cash-action"] = function(action, source, direct) end,
["alter-absolute-location-action"] = function(action, source, direct) end,
["alter-age-action"] = function(action, source, direct)
	if action.reflexive == true then
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
	if action.reflexive == true then
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
["create-object-action"] = function(action, source, direct) end,
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