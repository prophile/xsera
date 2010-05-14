function GetClosestHostile(subject)
	local subjectId = subject.physics.object_id
	local nearest = nil
	local dist = 0
	local pos = subject.physics.position
	
	for id, other in pairs(scen.objects) do
		if subject.ai.owner ~= other.ai.owner
		and other.base.attributes.hated == true
		and subjectId ~= id then
			local tempDist = hypot2(pos, other.physics.position)
			
			if tempDist < dist
			or nearest == nil then
				dist = tempDist
				nearest = other
			end
		end
	end
	
	return nearest, dist
end


function GetClosestObject(subject)
	local subjectId = subject.physics.object_id
	local nearest = nil
	local dist = 0
	local pos = subject.physics.position

	for id, other in pairs(scen.objects) do
		if other.base.attributes.hated == true
		and subjectId ~= id then
			local tempDist = hypot2(pos, other.physics.position)

			if tempDist < dist
			or nearest == nil then
				dist = tempDist
				nearest = other
			end
		end
	end

	return nearest, dist
end