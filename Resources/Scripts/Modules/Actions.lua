
function callAction(trigger, owner, other)
	local id
	local max = id + trigger.count - 1
	for id = trigger.id, max do
		local action = gameData["Actions"][id]
		actionTable[action.type](action, owner, other)
	end
end


actionTable = {
["activate-special-action"] = function(action, owner, other) end,
["alter-absolute-cash-action"] = function(action, owner, other) end,
["alter-absolute-location-action"] = function(action, owner, other) end,
["alter-age-action"] = function(action, owner, other)
	if action.reflexive == true then
		owner.age = action.value
	else
		other.age = action.value
	end
end,
["alter-base-type-action"] = function(action, owner, other) end,
["alter-cloak-action"] = function(action, owner, other) end,
["alter-condition-true-yet-action"] = function(action, owner, other) end,
["alter-damage-action"] = function(action, owner, other) end,
["alter-energy-action"] = function(action, owner, other)
	if action.reflexive == true then
		owner.energy = action.value
	else
		other.energy = action.value
	end
end,
["alter-hidden-action"] = function(action, owner, other) end,
["alter-location-action"] = function(action, owner, other) end,
["alter-max-velocity-action"] = function(action, owner, other) end,
["alter-occupation-action"] = function(action, owner, other) end,
["alter-offline-action"] = function(action, owner, other) end,
["alter-owner-action"] = function(action, owner, other) end,
["alter-special-action"] = function(action, owner, other) end,
["alter-spin-action"] = function(action, owner, other) end,
["alter-thrust-action"] = function(action, owner, other) end,
["alter-velocity-action"] = function(action, owner, other) end,
["assume-initial-object-action"] = function(action, owner, other) end,
["change-score-action"] = function(action, owner, other) end,
["color-flash-action"] = function(action, owner, other) end,
["computer-select-action"] = function(action, owner, other) end,
["create-object-action"] = function(action, owner, other) end,
["create-object-set-dest-action"] = function(action, owner, other) end,
["declare-winner-action"] = function(action, owner, other) end,
["die-action"] = function(action, owner, other) end,
["disable-keys-action"] = function(action, owner, other) end,
["display-message-action"] = function(action, owner, other) end,
["enable-keys-action"] = function(action, owner, other) end,
["land-at-action"] = function(action, owner, other) end,
["make-sparks-action"] = function(action, owner, other) end,
["nil-target-action"] = function(action, owner, other) end,
["no-action"] = function(action, owner, other) end,
["play-sound-action"] = function(action, owner, other) end,
["set-destination-action"] = function(action, owner, other) end,
["set-zoom-action"] = function(action, owner, other) end,
}