-- main menu script
function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-500, -240, 500, 240)
    graphics.draw_image("Bootloader/Ares", 0, 0, 1000, 480)
    
    graphics.end_frame()
end

function key ( k )
    print(k)
end
