import('GlobalVars')
import('Actions')

function Animate(obj)
	if obj.animation["frame-speed"] == 0 then
		return 0
	else
		local a = obj.animation
		local time = mode_manager.time()
		local framesPassed = (time - a.start) / a.frameTime
		local frameCount = a["last-shape"] - a["first-shape"]
		
		if obj.attributes["animation-cycle"] ~= true
		and framesPassed > frameCount then
			ExpireTrigger(obj)
			obj.dead = true
		end
		
		local frameNumber= (framesPassed+a["frame-shape"]-a["first-shape"])%(frameCount)+a["first-shape"]
		
		return frameNumber
	end
end