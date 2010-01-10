
function callAction(trigger, parent, direct)
	local id
	local max = id + trigger.count - 1
	for id = trigger.id, max do
		local action = gameData["Actions"][id]
		actionTable[action.type](action, parent, direct)
	end
end


actionTable = {
["activate-special-action"] = function(action, parent, direct) end,
["alter-absolute-cash-action"] = function(action, parent, direct) end,
["alter-absolute-location-action"] = function(action, parent, direct) end,
["alter-age-action"] = function(action, parent, direct)
	if action.reflexive == true then
		parent.age = action.value
	else
		direct.age = action.value
	end
end,
["alter-base-type-action"] = function(action, parent, direct) end,
["alter-cloak-action"] = function(action, parent, direct) end,
["alter-condition-true-yet-action"] = function(action, parent, direct) end,
["alter-damage-action"] = function(action, parent, direct) end,
["alter-energy-action"] = function(action, parent, direct)
	if action.reflexive == true then
		parent.energy = action.value
	else
		direct.energy = action.value
	end
end,
["alter-hidden-action"] = function(action, parent, direct) end,
["alter-location-action"] = function(action, parent, direct) end,
["alter-max-velocity-action"] = function(action, parent, direct) end,
["alter-occupation-action"] = function(action, parent, direct) end,
["alter-offline-action"] = function(action, parent, direct) end,
["alter-owner-action"] = function(action, parent, direct) end,
["alter-special-action"] = function(action, parent, direct) end,
["alter-spin-action"] = function(action, parent, direct) end,
["alter-thrust-action"] = function(action, parent, direct) end,
["alter-velocity-action"] = function(action, parent, direct) end,
["assume-initial-object-action"] = function(action, parent, direct) end,
["change-score-action"] = function(action, parent, direct) end,
["color-flash-action"] = function(action, parent, direct) end,
["computer-select-action"] = function(action, parent, direct) end,
["create-object-action"] = function(action, parent, direct) end,
["create-object-set-dest-action"] = function(action, parent, direct) end,
["declare-winner-action"] = function(action, parent, direct) end,
["die-action"] = function(action, parent, direct) end,
["disable-keys-action"] = function(action, parent, direct) end,
["display-message-action"] = function(action, parent, direct) end,
["enable-keys-action"] = function(action, parent, direct) end,
["land-at-action"] = function(action, parent, direct) end,
["make-sparks-action"] = function(action, parent, direct) end,
["nil-target-action"] = function(action, parent, direct) end,
["no-action"] = function(action, parent, direct) end,
["play-sound-action"] = function(action, parent, direct) end,
["set-destination-action"] = function(action, parent, direct) end,
["set-zoom-action"] = function(action, parent, direct) end,
}