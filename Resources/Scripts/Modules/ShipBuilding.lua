function LookupBuildId(class, race)
    for id, obj in ipairs(data.objects) do
        if class == obj.class and race == obj.race then
            return id
        end
    end
end

function CalculateBuildables(object, scen)--[HACK]
    for idx, class in ipairs(object.building.classes) do
        object.building.ids[idx] = LookupBuildId(class, 
        scen.base.players[
        object.ai.owner+1
        ].race)
    end
end