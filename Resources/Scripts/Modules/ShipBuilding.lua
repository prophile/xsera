function LookupBuildId(class, race)
    for local id, obj in ipairs(data.objects) do
        if class == obj.class and race == obj.race then
            return id
        end
    end
end