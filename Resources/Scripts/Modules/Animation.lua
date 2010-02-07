--import('GlobalVars')
--import('Actions')

function Animate(object)
	if object.gfx.fameTime == 0 then
		return 0
	else
		local anim = object.base.animation
		local time = mode_manager.time()
		
		local framesPassed = (time - object.gfx.startTime) / object.gfx.frameTime
		local frameCount = anim["last-shape"] - anim["first-shape"]
		
		if object.base.attributes["animation-cycle"] ~= true
		and framesPassed > frameCount then
			ExpireTrigger(object)
			object.status.dead = true
		end
		
		local frameNumber = (framesPassed+anim["frame-shape"]-anim["first-shape"])%(frameCount)+anim["first-shape"]
		
		return frameNumber
	end
end