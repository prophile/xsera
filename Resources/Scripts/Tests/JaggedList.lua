function ObjectIterator(list)
    local function jaggedObjectListOterator(list, index)
        if index[2] == nil then
            index[1] = next(list, index[1])
            if index[1] == nil then
                return nil, nil
            end
        end
        local i, k = next(list[index[1]], index[2])
        index[2] = i

        return index, k
    end
    return jaggedObjectListOterator, list, {nil, nil}
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
        print(b)
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