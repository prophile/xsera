function LoadScenario(id)
	local scen = deepcopy(gameData.Scenarios[id])
	scen.objects = {}
	local datId
	local max = scen.initial.id + scen.initial.count - 1
	local ctr = 0
	
	for datId = scen.initial.id, max do
		local state = gameData.InitialObject[datId]
		local new = NewObject(state.type)
		print(state.attributes)
		if state.attributes == 512 then
			if scen.playerShip == nil then
				new.physics.velocity = {x = 0.0, y = -400.0}
				scen.playerShip = new
			else
				error "There is already a an intial player ship set."
			end
		end
		new.physics.position = state.location
		scen.objects[ctr] = new
		ctr = ctr + 1
	end
	return scen
end