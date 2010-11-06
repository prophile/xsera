import('GlobalVars')
import('PrintRecursive')

window_size = { x, y }

function init()
    graphics.set_camera(-400, -300, 400, 300)
end

function update()
end

function render()
    graphics.begin_frame()
    graphics.draw_text("1-2 - inc/dec window size", MAIN_FONT, "left", { x = 50, y = 250 }, 30)
    graphics.draw_text("3-4 - FS on/off", MAIN_FONT, "left", { x = 50, y = 200 }, 30)
    graphics.draw_text("5 - toggle FS", MAIN_FONT, "left", { x = 50, y = 150 }, 30)
    window_size.x, window_size.y = window.size();
    graphics.draw_text(window_size.x, MAIN_FONT, "left", { x = 50, y = 100 }, 30)
    graphics.draw_text(window_size.y, MAIN_FONT, "left", { x = 50, y = 50 }, 30)
    graphics.end_frame()
end

function key(k)
    if k == "1" then
        window_size.x = window_size.x + 20
        window_size.y = window_size.y + 20
        window.set(window_size)
    elseif k == "2" then
        window_size.x = window_size.x - 20
        window_size.y = window_size.y - 20
        window.set(window_size)
    elseif k == "3" then
        window.set_fullscreen("true")
    elseif k == "4" then
        window.set_fullscreen("false")
    elseif k == "5" then
        window.toggle_fullscreen()
    elseif k == "6" then
        print(window.is_fullscreen())
    elseif k == "7" then
        printTable(window_size)
    elseif k == "escape" then
        mode_manager.switch('Xsera/MainMenu')
    end
end

function keyup(k)
end