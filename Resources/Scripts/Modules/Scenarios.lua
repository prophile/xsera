function LoadScenario(id)
	local scen = gameData["Scenarios"][id]
	scen.objects = {}
	local datId
	local max = scen.initial.id + scen.initial.count - 1
	local ctr = 0
	for datId = scen.initial.id, max do
		local state = gameData.InitialObject[datId]
		local new = NewObject(state.type)
		print(new.name)
		new.physics.position = state.location
		scen.objects[ctr] = new
		ctr = ctr + 1
	end
	return scen
end