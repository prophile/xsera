import('GlobalVars')
import('PrintRecursive')
import('ObjectLoad')

function key ( k )
    if k == "q" then
        mode_manager.switch("Xsera/MainMenu")
    elseif k == " " then
        local o = NewObject(0)
        printTable(o)
    elseif k == "p" then
        graphics.add_particles("Sparks", 20, vec(0, 0), vec(0, 0), { x = 2, y = 2 }, 0, 0.6, 3, 1)
    end
end

function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-100.0, -100.0, 100.0, 100.0)
    
    graphics.draw_starfield(3.4)
    graphics.draw_starfield(1.8)
    graphics.draw_starfield(0.6)
    graphics.draw_starfield(-0.3)
    graphics.draw_starfield(-0.9)
    
    graphics.draw_lightning({ x = -90.0, y = 0.0 }, { x = 90.0, y = 0.0 }, 1.0, 3.0, false)
    graphics.draw_particles()
    
    graphics.end_frame()
end
