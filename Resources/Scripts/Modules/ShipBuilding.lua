function LookupBuildId(class, race)
    for id, obj in pairs(data.objects) do
        if class == obj.class and race == obj.race then
            return id
        end
    end
end

function CalculateBuildables(object, scen)--[HACK]
    local race = scen.base.players[object.ai.owner+1].race
    for idx, class in ipairs(object.building.classes) do
        object.building.ids[idx] = LookupBuildId(class, race) 
    end
end

function DoBuildAction(context)
end

function BeginBuilding(planet, class)
end

function StopBuilding(planet)
end

function GetCash(player)
    return scen.players[player].cash
end

function AddCash(player, cash)
    scen.players[player].cash = scen.players[player].cash + cash
    return scen.players[player].cash
end

function GetBuildPercent(planet)
end

function UpdatePlanet(planet, dt)
end
