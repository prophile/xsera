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

	InitConditions(scen)
	ParseScoreStrings(scen)
	GenerateStatusLines(scen)
	return scen
end

function InitConditions(scen)
	scen.conditions = {}
	--Ares has a limit of 4 players and 3 counters each
	--scen.counter[player][counter]
	scen.counters = {}
	for pl = 1, MAX_PLAYERS do
		scen.counters[pl] = {}
		for ctr = 0, MAX_COUNTERS - 1 do
			scen.counters[pl][ctr] = 0
		end
	end


	local max = scen.condition.id + scen.condition.count - 1
	for idx = scen.condition.id , max do
		local cond = deepcopy(gameData["Conditions"][idx])

		if cond["condition-flags"]["initially-true"] ~= true then
				cond.active = true
					cond.isTrue = true
			else
				cond.active = false
					cond.isTrue = true
			end

		table.insert(scen.conditions, cond)
	end
end

function ParseScoreStrings(scen)
	lines = {}
	for i, s in ipairs(scen["score-string"]) do
		local c = string.sub(s,1,1)
		local start = 1
		local line = {}
		local underline = false
		
		if c == "_" then
			line.underline = true
			c = string.sub(s,2,2)
			start = 2
		end
		
		if c == "-" then
			line.string = string.sub(s,start+1)
		else
			--type, number, player, negval, falsestring, truestring, basestring, poststring
			local type, number, player, negvalue, falsestring, truestring, prestring, poststring = string.match(s,"(-?%d)\\(%d+)\\(-?%d+)\\([^\\]*)\\([^\\]*)\\([^\\]*)\\([^\\]*)\\([^\\]*)",start)

			line.type = type+0
			line.number = number+0
			line.player = player+0
			line.negvalue = negvalue+0
			line.falsestring = falsestring
			line.truestring = truestring
			line.prestring = prestring
			line.poststring = poststring
		end
		table.insert(lines, line)
	end
	scen.status = lines
end

function GetRelativePlayerId(from, code)
	if code >= 0 then
		return code + 1
	elseif code == -1 then
		return from
	else ---2
		local i = next(scen.players)
		if i == from then
			i = next(scen.players,i)
		end
		return i
	end
end

function GenerateStatusLines(scen)
	menuStatus = {"MISSION STATUS"}
	for i, line in ipairs(scen.status) do
		local out
		if line.string ~= nil then
			out = {line.string, false}
		elseif line.type == -1 then
			--empty
			out = {"", false}
		elseif line.type == 0 then
			--plain text
			out = {line.preString, false}
		elseif line.type == 1 then
		--true/false
			if scen.conditions[line.number + 1].isTrue == true then
				out = {line.prestring..line.truestring..line.poststring,false}
			else
				out = {line.prestring..line.falsestring..line.poststring,false}
			end
		elseif line.type == 2 then
		--[HARDCODE]
			out = {line.prestring..scen.counters[GetRelativePlayerId(1,line.player)][line.number]..line.poststring, false}
		elseif line.type == 3 then
			print("UNIMPLEMENTED")
		elseif line.type == 4 then
		--[HARDCODE]
			out = {line.prestring..(line.negvalue-scen.counters[GetRelativePlayerId(1,line.player)][line.number])..line.poststring, false}
		elseif line.type == 5 then
			print("UNIMPLEMENTED")
		else
			error("INVALID STATUS MODE")
		end
		menuStatus[i + 1] = out
	end
end