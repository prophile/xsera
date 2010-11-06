--import('GlobalVars')
--import('Actions')

function NewObject(id)
    local base = data.objects[id]
    
    local object = {
        name = base.shortName;
        short = base.shortName;
        
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
        warp = {
            stage = WARP_IDLE;
            factor = 0;
            lastPlayed = 0;
            };
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
        object.gfx.startTime = realTime
        --implement speed range
        object.gfx.frameTime = base.animation.speed / TIME_FACTOR / 30
    elseif base.beam ~= nil then
        object.type = "beam"
    else
        LogError("UNKNOWN OBJECT CLASS")
    end
    
    if base.spriteId ~= -1 then
        object.gfx.sprite = "Id/"..base.spriteId;
        
        local dim = graphics.sprite_dimensions(object.gfx.sprite)
        
        object.gfx.dimensions = dim * (base.scale/4096 or 1.0)
        
        object.physics.collision_radius = hypot1(object.gfx.dimensions) / 4.0
    else
        object.physics.collision_radius = 1
    end
    
    
    if base.initialAge ~= -1 then
        object.age = {
            created = realTime;
            lifeSpan = (base.initialAge + math.random(0, base.initialAgeRange)) / TIME_FACTOR;
        }
    end

    --Prepare devices
    object.weapons = {}

    for key, weapon in pairs(object.base.weapons) do
        if weapon.id ~= -1 then
            local wbase = data.objects[weapon.id]
            local weap = {
                base = wbase;
                lastPos = 1;
                positions = weapon.positions;
                ammo = wbase.device.ammo;
                lastActivated = -wbase.device.reload / TIME_FACTOR;
                lastRestock = realTime
            }
            CopyActions(weap)
            object.weapons[key] = weap
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
            interval = bit.rshift(activate.count,24);
            range = bit.band(bit.rshift(activate.count,16),0xff) / TIME_FACTOR;
        }
        
        periodic.next = realTime + periodic.interval + math.random(0, periodic.range)

--        math.floor(c/2^7)%7 --No discernable use. But do not delete!

        object.triggers.activate.count = bit.band(activate.count,0xff)
        
        object.triggers.periodic = periodic
    end
end
