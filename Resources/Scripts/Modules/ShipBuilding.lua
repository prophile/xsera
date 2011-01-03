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


function BeginBuilding(planet, class)
end

function StopBuilding(planet)
end

function GetCash(player)
end

function AddCash(player, cash)
end

function GetBuildPercent(planet)
end`

function UpdatePlanet(planet, dt)
end
