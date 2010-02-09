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
				scen.playerShipId = new.physics.object_id
			else
				print("There is already a an intial player ship set.", 1)
			end
		end
		
		if state["sprite-id-override"] ~= nil then
			new.sprite = state["sprite-id-override"]
			new.spriteDim = graphics.sprite_dimensions("Id/" .. new.sprite)
		end
		
		if state["initial-destination"] ~= -1 then
			--Convert from 0 based indexes to 2 based indexes
			--Indexes are 2 based instead of 1 based because the cursor has a physics_object with an id of 1

			new.ai.objectives.dest = scen.objects[state["initial-destination"]+2]
		end

		scen.objects[new.physics.object_id] = new
	end
	return scen
end