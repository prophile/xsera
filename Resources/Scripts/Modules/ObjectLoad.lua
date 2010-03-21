--import('GlobalVars')
--import('Actions')

function NewObject(id)
	local base = gameData["Objects"][id]
	
	local object = {
		name = base["short-name"];
		short = base["short-name"];
		
		base = base;
		control = {
			accel = false;
			decel = false;
			left = false;
			right = false;
			beam = false;
			pulse = false;
			special = false;
			warp = false;
		};
		warp = { stage = "notWarping", time = 0, lastPlayed = 0 };
		ai = {
			owner = nil;
			mode = "wait";
			objectives = {
				target = nil;
				dest = nil;
			};
		};
		physics = Physics.NewObject(base.mass or 1.0);
		gfx = {};
		status = {
			health = base.health;
			healthMax = base.health;
			energy = base.energy;
			energyMax = base.energy;
			battery = base.energy and base.energy * 5;
			batteryMax = base.energy and base.energy * 5;
			dead = false;
		}
	}
	
	setmetatable(object.ai.objectives, weak)
	
	if base.rotation ~= nil then
		object.type = "rotation"
	elseif base.animation ~= nil then
		object.type = "animation"
		object.gfx.startTime = mode_manager.time()
		object.gfx.frameTime = base.animation["frame-speed"] / TIME_FACTOR / 30
	elseif base.beam ~= nil then
		object.type = "beam"
	else
		LogError("UNKNOWN OBJECT CLASS")
	end
	
	if base["sprite-id"] ~= nil then
		object.gfx.sprite = "Id/"..base["sprite-id"];
		
		local dim = graphics.sprite_dimensions(object.gfx.sprite)
		
		object.gfx.dimensions = dim * (base["natural-scale"] or 1.0)
		
		object.physics.collision_radius = hypot1(object.gfx.dimensions) / 4.0
	else
		object.physics.collision_radius = 1
	end
	
	
	if base["initial-age"] ~= nil then
		object.age = {
			created = mode_manager.time();
			lifeSpan = (base["initial-age"] + math.random(0, base["initial-age"] or 0)) / TIME_FACTOR;
		}
	end

	--Prepare devices
	if base.weapon ~= nil then
		object.weapons = {}
		
		for wid = 1, #base.weapon do
			if object.weapons[base.weapon[wid].type] ~= nil then
				LogError("More than one weapon of type '" .. newObj.weapon[wid].type .. "' defined.")
			end
			
			local wbase = gameData["Objects"][base.weapon[wid].id]
			local weap = {
				base = wbase;
				lastPos = 1;
				positions = base.weapon[wid].position;
				ammo = wbase.device.ammo;
				lastActivated = -wbase.device["fire-time"] / TIME_FACTOR;
				lastRestock = mode_manager.time();
			}
			
			CopyActions(weap)

			object.weapons[base.weapon[wid].type] = weap
		
		
		end
	end
	
	CopyActions(object)
	return object
end



function CopyActions(object)
	local base = object.base
	object.triggers = {}
	
	if base.action ~= nil then
		for id = 1, #base.action do
			if base.action[id] ~= nil then
				object.triggers[base.action[id].trigger] = base.action[id]
			end
		end
	end
	
	if object.triggers.activate ~= nil
	and object.triggers.activate.count > 255 then
		local activate = object.triggers.activate
		local periodic = {
			interval = math.floor(activate.count/2^23) / TIME_FACTOR;
			range = math.floor(activate.count/2^15)%2^7 / TIME_FACTOR;
		}
		
		periodic.next = mode_manager.time() + periodic.interval + math.random(0, periodic.range)

--		math.floor(c/2^7)%7 --No discernable use.

		object.triggers.activate.count = activate.count%2^7
		
		object.triggers.periodic = periodic
	end
end
