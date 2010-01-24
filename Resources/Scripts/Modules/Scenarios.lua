function LoadScenario(id)
	local scen = deepcopy(gameData.Scenarios[id])
	scen.objects = {}

	local max = scen.initial.id + scen.initial.count - 1
	
	for id = scen.initial.id, max do
		local state = gameData["InitialObject"][id]
		local new = NewObject(state.type)

		new.physics.position = state.location
		new.ai.owner = state.owner

		if state.attributes == 512 then
			if scen.playerShip == nil then
				scen.playerShip = new
				scen.playerShipId = #scen.objects + 1
			else
				LogError("There is already a an intial player ship set.", 1)
			end
		end
		
		if state["sprite-id-override"] ~= nil then
			new.sprite = state["sprite-id-override"]
			new.spriteDim = graphics.sprite_dimensions("Id/" .. new.sprite)
		end
		
		table.insert(scen.objects, new)
	end
	return scen
end