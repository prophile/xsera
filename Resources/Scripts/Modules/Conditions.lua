function TestConditions(scen)
    for idx, cond in pairs(scen.conditions) do
        local type = cond.type
        if cond.active == true then
            cond.isTrue = Test[type](cond)
            if cond.isTrue == true then
                CallAction(cond.action)
                if cond.flags.trueOnlyOnce == true then
                    cond.active = false
                end
            end
        end
    end
end

Test = {}

setmetatable(Test, {__index = function(table, key)
    print("[lua] Warning: Unimplented condition: " .. key)
        return function(cond) return false end
end})

-- Test["autopilot"]
Test["counter"] = function(cond)
    return scen.counters[cond.counter.player+1][cond.counter.id] == cond.counter.amount
end

Test["counter greater"] = function(cond)
    return scen.counters[cond.counter.player+1][cond.counter.id] > cond.amount
end

-- Test["current computer selection"]
-- Test["current message"]
Test["destruction"] = function(cond)
    return scen.objects[cond.value + 1] == nil
end

--Test["direct is subject target"]
Test["distance greater"] = function(cond)
    local subject = scen.objects[cond.subject+1]
    local direct = scen.objects[cond.direct+1]
    return hypot2(subject.physics.position, direct.physics.position) > math.sqrt(cond.value)
end

Test["half health"] = function(cond)
    local objectStatus = scen.objects[cond.subject+1].status
    return objectStatus.health * 2 <= objectStatus.healthMax
end

-- Test["is auxiliary"]
-- Test["is target"]
-- Test["none"]
Test["no ships left"] = function(cond)
    local player = cond.player
    for i,o in pairs(scen.objects) do
        if o.ai.owner == player then
            return false
        end
    end
    return true
end

-- Test["not autopilot"]
-- Test["object being built"]
Test["owner"] = function(cond)
    return scen.objects[cond.subject + 1].ai.owner == cond.value
end

Test["proximity"] = function(cond)
    local subject = scen.objects[cond.subject+1]
    local direct = scen.objects[cond.direct+1]
    return hypot2(subject.physics.position, direct.physics.position) > cond.value
end

-- Test["subject is player"]

Test["time"] = function(cond)
    --[[
    May need to measure from when the condition is first tested. Instead of scenario start.
    --]]
    return cond.value / TIME_FACTOR >= realtime
end

Test["velocity less than equal"] = function(cond)
    return cond.value * SPEED_FACTOR >= hypot1(scen.objects[cond.subject + 1])
end

-- Test["zoom level"]
