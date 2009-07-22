import('PrintRecursive')
import('GlobalVars')
import('PopDownConsole')

function NewEntity (entOwner, entName, entType, entDir, entSubdir, other)
--	print(entOwner, entName, entType, entDir, entSubdir, other)
	local entTypeReal = entType
	local concatString = nil
	if entType == "Projectile" then
		if entDir == "beam" then
			if entOwner.battery.level < entOwner[entDir].cost then
				return
			end
		elseif entDir == "special" then
			if entOwner.special.ammo == 0 then
				return
			end
		end
		entType = "Weapon"
	end
	if entSubdir ~= nil then
		concatString = (entType .. "s/" .. entDir .. "/" .. entSubdir .. "/" .. entName)
	elseif entDir ~= nil then
		concatString = (entType .. "s/" .. entDir .. "/" .. entName)
	elseif entType ~= nil then
		concatString = (entType .. "s/" .. entName)
	else
		errLog("Entity of type " .. entType .. " has no name.", 1)
	end
    local trueData = {}
	local rawData
	rawData = xml.load("Config/" .. concatString .. ".xml")
    local entData = rawData[1]
    for k, v in ipairs(entData) do
        if type(v) == "table" then
            trueData[v.name] = v[1]
        end
    end
	local entObject = { type = entType, size = {} }
	if entities ~= nil then
		local num = 1
		while entities[num] ~= nil do
			if entities[num].entName == concatString then
				entObject = deepcopy(entities[num])
				if trueData.mass == nil then
					entObject.mass = 0.01
				else
					entObject.mass = tonumber(trueData.mass)
				end
				entObject.physicsObject = physics.new_object(entObject.mass)
				if entOwner ~= nil then
					if entOwner.physicsObject ~= nil then
						entObject.physicsObject.angle = entOwner.physicsObject.angle
						entObject.physicsObject.position = { x = entOwner.physicsObject.position.x, y = entOwner.physicsObject.position.y }
						if trueData.velocity ~= nil then
							entObject.initialVelocity = tonumber(trueData.velocity)
							entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x + tonumber(trueData.velocity) * math.cos(entOwner.physicsObject.angle), y = entOwner.physicsObject.velocity.y + tonumber(trueData.velocity) * math.sin(entOwner.physicsObject.angle) }
						else
							entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x, y = entOwner.physicsObject.velocity.y }
						end
					else
						entObject.physicsObject.angle = 0
						entObject.physicsObject.position = { x = entOwner.position.x, y = entOwner.position.y }
						if trueData.velocity ~= nil then
							entObject.initialVelocity = tonumber(trueData.velocity)
							entObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(entObject.physicsObject.angle), y = tonumber(trueData.velocity) * math.sin(entObject.physicsObject.angle) }
						else
							entObject.physicsObject.velocity = { x = entOwner.initialVelocity.x, y = entOwner.initialVelocity.y }
						end
					end
				end
				if entType == "Ship" then
					if trueData.sprite ~= nil then
						entObject.image = trueData.sprite
						if entSubdir ~= nil then
							entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entSubdir .. "/" .. entName)
						elseif entDir ~= nil then
							entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entName)
						elseif entType ~= nil then
							entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entName)
						end
						entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
					else
						entObject.fileName = trueData.filename
					end
				else
					if trueData.sprite ~= nil then
						entObject.image = trueData.sprite
						if entSubdir ~= nil then
							entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. entSubdir .. "/" .. entName)
						elseif entType ~= nil then
							entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. entName)
						end
						entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
					else
						entObject.fileName = trueData.fileName
					end
				end
				if entType == "Projectile" then
					if weaponClass == "beam" then
						-- [ADAM, FIX] this piece of code is a hack, it relies on what little weapons we have right now to make the assumption
						if entOwner.switch == true then
							entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3) }
							entOwner.switch = false
						else
							entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3) }
							entOwner.switch = true
						end
						-- cost
						entOwner.energy.level = entOwner.energy.level - tonumber(trueData.energyCost)
					elseif weaponClass == "pulse" then
						return
					elseif weaponClass == "special" then
						entObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
						entOwner.special.ammo = entOwner.special.ammo - 1
						
						if computerShip == nil then
							entObject.isSeeking = false
						end
						if entObject.isSeeking == true then
							local projectileTravel = { x, y, dist }
							projectileTravel.dist = (entOwner[weaponClass].thrust * entOwner[weaponClass].life * entOwner[weaponClass].life / 1000000) / (2 * entOwner[weaponClass].mass)
							projectileTravel.x = math.cos(entObject.physicsObject.angle) * (projectileTravel.dist + entObject.physicsObject.velocity.x)
							projectileTravel.y = math.sin(entObject.physicsObject.angle) * (projectileTravel.dist + entObject.physicsObject.velocity.y)
							if find_hypot(entObject.physicsObject.position, entObject.dest) <= hypot(projectileTravel.x, projectileTravel.y) then
								if showAngles == true then
									print(find_angle(entObject.dest, entObject.physicsObject.position))
									print(entObject.physicsObject.angle)
									print(find_angle(entObject.dest, entObject.physicsObject.position) - entObject.physicsObject.angle)
								end
								local angle = find_angle(entObject.dest, entObject.physicsObject.position) - entObject.physicsObject.angle
								if math.abs(angle) > math.pi then -- need to go through 0
									if angle > 0.0 then
										angle = 2 * math.pi - angle
									else
										angle = 2 * math.pi + angle
									end
								end
								if math.abs(angle) > entObject.maxSeek then
									entObject.isSeeking = false
								end
							else
								entObject.isSeeking = false
							end
						else
							entObject.isSeeking = false
						end
					elseif weaponClass == nil then
						errLog("Projectile '" .. entType .. "' has no class. See NewEntity", 12)
					else
						errLog("Unknown projectile class '" .. entClass .. "'. See NewEntity", 11)
					end
					entObject.life = tonumber(trueData.life)
				end
				return entObject
			end
			num = num + 1
		end
		if loading_entities == false then
			errLog("Entity " .. concatString .. " being loaded after loading period.", 2)
			if trueData.mass == nil then
				entObject.mass = 0.01
			else
				entObject.mass = tonumber(trueData.mass)
			end
			entObject.physicsObject = physics.new_object(entObject.mass)
			if entOwner ~= nil then
				if entOwner.physicsObject ~= nil then
					entObject.physicsObject.angle = entOwner.physicsObject.angle
					entObject.physicsObject.position = { x = entOwner.physicsObject.position.x, y = entOwner.physicsObject.position.y }
					if trueData.velocity ~= nil then
						entObject.initialVelocity = tonumber(trueData.velocity)
						entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x + tonumber(trueData.velocity) * math.cos(entOwner.physicsObject.angle), y = entOwner.physicsObject.velocity.y + tonumber(trueData.velocity) * math.sin(entOwner.physicsObject.angle) }
					else
						entObject.physicsObject.velocity = { x = entOwner.physicsObject.velocity.x, y = entOwner.physicsObject.velocity.y }
					end
				else
					entObject.physicsObject.angle = 0
					entObject.physicsObject.position = { x = entOwner.position.x, y = entOwner.position.y }
					if trueData.velocity ~= nil then
						entObject.initialVelocity = tonumber(trueData.velocity)
						entObject.physicsObject.velocity = { x = tonumber(trueData.velocity) * math.cos(entObject.physicsObject.angle), y = tonumber(trueData.velocity) * math.sin(entObject.physicsObject.angle) }
					else
						entObject.physicsObject.velocity = { x = entOwner.initialVelocity.x, y = entOwner.initialVelocity.y }
					end
				end
			end
			if entType == "Ship" then
				if trueData.sprite ~= nil then
					entObject.image = trueData.sprite
					if entSubdir ~= nil then
						entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entSubdir .. "/" .. entName)
					elseif entDir ~= nil then
						entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entDir .. "/" .. entName)
					elseif entType ~= nil then
						entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entName)
					end
					entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
				else
					entObject.fileName = trueData.filename
				end
			else
				if trueData.sprite ~= nil then
					entObject.image = trueData.sprite
					if entSubdir ~= nil then
						entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. entSubdir .. "/" .. entName)
					elseif entType ~= nil then
						entObject.size.x, entObject.size.y = graphics.sprite_dimensions(entType .. "s/" .. entName)
					end
					entObject.physicsObject.collision_radius = hypot(entObject.size.x, entObject.size.y)
				else
					entObject.fileName = trueData.fileName
				end
			end
		end
	end
	entObject.entName = concatString
	if trueData.name == nil then
		errLog(entName .. " of type " .. entTypeReal .. " does not have a name.", 12)
	end
	entObject.name = trueData.name
	if trueData.shortname ~= nil then
		entObject.shortName = trueData.shortname
	end
	entType = entTypeReal
	if entType == "Explosion" then
-- explosion-specific
		entObject.frameDuration = tonumber(trueData.frameDuration)
	elseif entType == "Scenario" then
-- scenario-specific
		entObject.planet =  { name = trueData.pname,
			position = { x = tonumber(trueData.ppositionx), y = tonumber(trueData.ppositiony) },
			image = trueData.psprite,
			res_gen = tonumber(trueData.presources_generated),
			build = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3 },
			type = "Planet",
			initialVelocity = { x = trueData.pinitialvelocityx, y = trueData.pinitialvelocityy },
			buildqueue = { factor = 1, current = 0, percent = 100 },
			text = { trueData.pbuild1, trueData.pbuild2, trueData.pbuild3 } }
		num = 1
		while entObject.planet.text[num] ~= nil do
			NewEntity(nil, entObject.planet.text[num], "Ship")
			num = num + 1
		end
		entObject.briefing = trueData.briefing
		-- put standard includes here (sounds, explosions, etc) [ADAM, DEMO3]
	elseif entType == "Weapon" then
-- weapon-specific
		entObject.cost = tonumber(trueData.energyCost)
		entObject.sound = trueData.fireSound
		entObject.damage = tonumber(trueData.damage)
		entObject.cooldown = tonumber(trueData.cooldown)
		entObject.life = tonumber(trueData.life)
		entObject.max_projectiles = math.ceil(entObject.life * 1000 / entObject.cooldown)
		entObject.ammo = tonumber(trueData.ammo)
		if trueData.thrust ~= nil then
			entObject.thrust = tonumber(trueData.thrust)
		end
		entObject.fired = false
		entObject.class = trueData.class
		entObject.start = 0
		if entObject.class == "beam" then -- this is innacurate. Learn more about weapons [ADAM, FIX, SFIERA]
			entObject.length = tonumber(trueData.length)
			entObject.width = cameraRatio
			entObject.firing = false
		elseif entObject.class == "pulse" then
		elseif entObject.class == "special" then
			entObject.dest = { x = 2200, y = 2700 }
			entObject.delta = 0.0
			entObject.force = { x, y }
		elseif entObject.class == nil then
			errLog("Weapon '" .. entObject.name .. "' has no class. See NewEntity", 12)
		else
			errLog("Unknown weapon class '" .. entObject.class .. "'. See NewEntity", 11)
		end
	elseif entType == "Projectile" then
-- projectile-specific
		local weaponClass = entDir
		local wNum = other
		if trueData.turnrate ~= nil then
			entObject.turningRate = tonumber(trueData.turnrate)
			entObject.maxSeek = tonumber(trueData.maxSeek)
			entObject.isSeeking = true
		else
			entObject.isSeeking = false
		end
		
		if loading_entities == false then
			if weaponClass == "beam" then
				-- [ADAM, FIX] this piece of code is a hack, it relies on what little weapons we have right now to make the assumption
				if entOwner.switch == true then
					entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle + 0.17) * (tonumber(trueData.length) - 3) }
					entOwner.switch = false
				else
					entObject.physicsObject.position = { x = entOwner.physicsObject.position.x + math.cos(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3), y = entOwner.physicsObject.position.y + math.sin(entObject.physicsObject.angle - 0.17) * (tonumber(trueData.length) - 3) }
					entOwner.switch = true
				end
				-- cost
				entOwner.energy.level = entOwner.energy.level - tonumber(trueData.energyCost)
			elseif weaponClass == "pulse" then
				return
			elseif weaponClass == "special" then
				entObject.dest = { x = computerShip.physicsObject.position.x, y = computerShip.physicsObject.position.y }
				entOwner.special.ammo = entOwner.special.ammo - 1
				
				if computerShip == nil then
					entObject.isSeeking = false
				end
				if entObject.isSeeking == true then
					local projectileTravel = { x, y, dist }
					projectileTravel.dist = (entOwner[weaponClass].thrust * entOwner[weaponClass].life * entOwner[weaponClass].life / 1000000) / (2 * entOwner[weaponClass].mass)
					projectileTravel.x = math.cos(entObject.physicsObject.angle) * (projectileTravel.dist + entObject.physicsObject.velocity.x)
					projectileTravel.y = math.sin(entObject.physicsObject.angle) * (projectileTravel.dist + entObject.physicsObject.velocity.y)
					if find_hypot(entObject.physicsObject.position, entObject.dest) <= hypot(projectileTravel.x, projectileTravel.y) then
						if showAngles == true then
							print(find_angle(entObject.dest, entObject.physicsObject.position))
							print(entObject.physicsObject.angle)
							print(find_angle(entObject.dest, entObject.physicsObject.position) - entObject.physicsObject.angle)
						end
						local angle = find_angle(entObject.dest, entObject.physicsObject.position) - entObject.physicsObject.angle
						if math.abs(angle) > math.pi then -- need to go through 0
							if angle > 0.0 then
								angle = 2 * math.pi - angle
							else
								angle = 2 * math.pi + angle
							end
						end
						if math.abs(angle) > entObject.maxSeek then
							entObject.isSeeking = false
						end
					else
						entObject.isSeeking = false
					end
				else
					entObject.isSeeking = false
				end
			elseif weaponClass == nil then
				errLog("Projectile '" .. entType .. "' has no class. See NewEntity", 12)
			else
				errLog("Unknown projectile class '" .. entClass .. "'. See NewEntity", 11)
			end
			entObject.life = tonumber(trueData.life)
		end
	elseif entType == "Ship" then
-- ship-specific
		entObject.cost = tonumber(trueData.cost)
		entObject.buildTime = tonumber(trueData.time) / 200
		entObject.life = tonumber(trueData.life)
		entObject.turningRate = tonumber(trueData.turnrate)
		entObject.battery = { total = 5 * tonumber(trueData.energy), level = 5 * tonumber(trueData.energy), percent = 1.0 }
		entObject.energy = { total = tonumber(trueData.energy), level = tonumber(trueData.energy), percent = 1.0 }
		entObject.shield = { total = tonumber(trueData.life), level = tonumber(trueData.life), percent = 1.0 }
		if trueData.thrust ~= nil then
			entObject.thrust = tonumber(trueData.thrust)
		else
			errLog("No thrust data for ship " .. trueData.name, 12)
		end
		if trueData.warp ~= nil then
			entObject.warpSpeed = tonumber(trueData.warp)
			entObject.canWarp = true
		else
			entObject.canWarp = false
		end
		entObject.maxSpeed = tonumber(trueData.maxspeed)
		entObject.reverseThrust = tonumber(trueData.reverse)
		if trueData.beamname ~= nil then
			entObject.beam = NewEntity(nil, trueData.beamname, "Weapon", "Beam")
			entObject.beamWeap = { { {} } }
		end
		if trueData.pulsename ~= nil then
			entObject.pulse = NewEntity(nil,  trueData.pulsename, "Weapon", "Pulse")
			entObject.pulseWeap = { { {} } }
		end
		if trueData.specialname ~= nil then
			entObject.special = NewEntity(nil, trueData.specialname, "Weapon", "Special")
			entObject.specialWeap = { { {} } }
		end
		entObject.warp = { warping = false, start = { bool = false, time = nil, engine = false, sound = false, isStarted = false }, endTime = 0.0, disengage = 2.0, finished = true, soundNum = 0 }
		entObject.switch = true -- [HARDCODED]
		entObject.type = "Ship"
	else
		errLog("Unknown entity of type " .. entType, 11)
	end
--	cout_table(entObject, "object", false)
	local num = 1
	while entities[num] ~= nil do
		num = num + 1
	end
	local tempEnt = deepcopy(entObject)
	tempEnt.physicsObject = nil
	entities[num] = tempEnt
	return entObject
end