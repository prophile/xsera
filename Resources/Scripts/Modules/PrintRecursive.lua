-- import('Console')

table.print_recursive = function (t, indent) -- alt version, abuse to http://richard.warburton.it
    local indent=indent or ''
    for key,value in pairs(t) do
        io.write(indent,'[',tostring(key),']') 
        if type(value)=="table" then
            io.write(':\n') table.print_recursive(value,indent..'\t')
        else
            io.write(' = ',tostring(value),'\n')
        end
    end
end

function table_define (t, name, indent)
    local tableList = {}
    function table_r (t, name, indent, full)
        local id = not full and name
            or type(name)~="number" and tostring(name) or '['..name..']'
        local tag = indent .. id .. ' = '
        local out = {}      -- result
        if type(t) == "table" then
            if tableList[t] ~= nil then
                table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
            else
                tableList[t]= full and (full .. '.' .. id) or id
                if next(t) then -- Table not empty
                    table.insert(out, tag .. '{')
                    for key,value in pairs(t) do
                        table.insert(out,table_r(value,key,indent .. '   ',tableList[t]))
                    end
                    table.insert(out,indent .. '}')
                else
                    table.insert(out,tag .. '{}')
                end
            end
        else
            local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
            table.insert(out, tag .. val)
        end
        return table.concat(out, '\n')
    end
    return table_r(t,name or 'Value',indent or '')
end

function printTable (t, name)
    if originalPrint ~= nil then
        originalPrint(table_define(t, name))
    else
        print(table_define(t, name))
    end
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end