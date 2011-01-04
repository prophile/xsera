__idmt = {
    __lt = function(a, b)
        if a[1] == b[1] then
            if a[2] == nil then print(debug.traceback("A")) end
            if b[2] == nil then print(debug.traceback("B")) end
            return a[2] < b[2]
        else
            return a[1] < b[1]
        end
    end;
    __le = function(a, b)
        if a[1] == b[1] then
            return a[2] <= b[2]
        else
            return a[1] <= b[1]
        end
    end;
    __eq = function(a, b)
        return a[1] == b[1] and a[2] == b[2]
    end;
    __tostring = function(a)
        return (a[1] or "nil") .. ", " .. (a[2] or "nil")
    end;
}

function ObjectIterator(list)
    local function jaggedListIterator(list, index)
        if index[2] == nil then
            index[1] = next(list, index[1])
            if index[1] == nil then
                return nil, nil
            end
        end
        local i, k = next(list[index[1]], index[2])
        index[2] = i
        if index[2] == nil then
            return jaggedListIterator(list, index)
        end
        return index, k
    end
    local nlt = {nil, nil}
    setmetatable(nlt, __idmt)
    return jaggedListIterator, list, nlt
end

list = {
    {1, 2, 3, 4},
    {5, 6, 7},
    {8, 9, 10, 11, 12, 13, 14},
    {15},
    {16, 17, 18},
    {19, 20},
    }

for a, b in ObjectIterator(list) do
    if b ~= nil then
        print(a,": ", b)
    end
end

function key(k)
    if k == "escape" then
        mode_manager.switch("Xsera/MainMenu")
    end
end

function render()
    graphics.begin_frame()
    graphics.end_frame()
end