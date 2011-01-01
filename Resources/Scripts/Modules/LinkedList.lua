--[[
    Linked list structure is as follows:
    list = { count = 2, first = { prev = list, next = { prev = list.first, next = nil } } }
    (note that this is not valid code but properly shows the structure
    
    This file provides the iterator for a linked list, which can be invoked as follows:
    for obj in lList(list) do ... end
    
    The LayeredLinkedList is a way to keep track of the different layers in Xsera. The only
    addition is a couple pointers in the list pointer: list { { layer0, layer1, layer2 } }
--]]



function lList(list)
    local lastVisited = list.first
    return
        function ()
            lastVisited, ret = lastVisited.next, lastVisited
            return ret
        end
end

function addToLayeredLinkedList(list, value, layer)
    layerName = "layer" .. tostring(layer)
    list[layerName].prev.next = value
    value.prev = list[layerName].prev
    list[layerName] = value
end