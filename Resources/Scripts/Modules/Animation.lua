--import('GlobalVars')
--import('Actions')

function Animate(object)
    if object.gfx.frameTime == 0 then
        return 0
    else
        local anim = object.base.animation

        local framesPassed = (realTime - object.gfx.startTime) / object.gfx.frameTime
        local frameCount = anim.lastShape - anim.firstShape
        
        if object.base.attributes.animationCycle ~= true
        and framesPassed > frameCount then
            ExpireTrigger(object)
            object.status.dead = true
        end
        
        local frameNumber = (framesPassed+anim.shape-anim.firstShape)%(frameCount)+anim.firstShape
        
        return frameNumber
    end
end