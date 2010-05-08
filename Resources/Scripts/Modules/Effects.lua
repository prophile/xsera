
--Currently the only type "flash"
--Will add "shield" in the future.
--the contents of data depends on the effect type
function AddEffects(type, color, duration, data)
	scen.effects[type][#scen.effects[type]+1] = {
	color = color;
	age = 0;
	life = duration;
	data = data;
	}
	print("ADD EFFECT")
end

function UpdateEffects(dt)
	for type, effectList in pairs(scen.effects) do
		for id, e in pairs(effectList) do
			e.age = e.age + dt
			print("EFFECT UPDATE")
			if e.age > e.life then
				scen.effects[type][id] = nil
			end
		end
	end
end

function DrawEffects()
	for type, effectList in pairs(scen.effects) do
		for id, e in pairs(effectList) do
			Effect[type](e)
		end
	end
end

Effect = {
["flash"] = function(effect)
	local pos = scen.playerShip.physics.position
	local w = camera.w/2.0
	local h = camera.h/2.0
	
	local color = ClutColour(effect.color)
	local delta = effect.age/effect.life
	
	if blinkMode == "triangle" then
		color.a = -math.abs(2*delta - 1)+1
	elseif blinkMode == "flash" then
		color.a = 1.0 - (delta*delta)
	else -- sine
		color.a = math.sin(math.pi * delta)
	end
	
	graphics.draw_box(pos.y + h, pos.x - w, pos.y - h, pos.x + w, 0,color)
end;
}