import('GlobalVars')
import('Actions')

function Animate(obj)
	local a = obj.animation
	local time = mode_manager.time()
	local framesPassed = (time - a.start) / a.frameTime
	local frameCount = a["last-shape"] - a["first-shape"]
	
	local frameNumber= (framesPassed+a["frame-shape"]-a["first-shape"])%(frameCount)+a["first-shape"]
	
	return frameNumber
	
end