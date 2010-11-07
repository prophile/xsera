-- Text tests. Will be changed from time to time, perhaps eventually removed if
-- there is no longer any need for them

import('TextManip')
import('PrintRecursive')

function test1()
    message = { "RUNNING TEST 1." }
    printTable(message)
    local i = 2
    local result
    
    result = textWrap("This is some sampler text that is longer than we want it to be. It should be shortened up, heh", MAIN_FONT, 40, 800)
    
    if type(result) == "table" and #result > 1 then
        for j = 1, #result do
            message[i] = result[j]
            i = i + 1
        end
    else
        message[i] = result
        i = i + 1
    end
    
    message[i] = "END OF TEST 1."
    printTable(message)
end

function key(k)
    if k == "1" then
        test1()
    elseif k == "escape" then
        mode_manager.switch('Xsera/MainMenu')
    end
end

function init(tabl)
    if tabl ~= nil then
        printTable(tabl)
    end
    local camera = { w = 800, h = 600 }
    graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function update()
    
end

function render()
    graphics.begin_frame()
    graphics.draw_text("ESC to go to main screen", MAIN_FONT, "center", { x = 0, y = 240 }, 40)
    if message ~= nil then
        for i = 1, #message do
            graphics.draw_text(message[i], MAIN_FONT, "center", { x = 0, y = 200 - 40 * i }, 30)
        end
    end
    graphics.end_frame()
end