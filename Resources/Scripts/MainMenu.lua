-- main menu script
function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-500, -240, 500, 240)
    graphics.draw_image("Bootloader/Ares", 0, 0, 1000, 480)
    
    graphics.end_frame()
end

function init ()
    local myComponent = component.create("TestComponent")
    local myResult = component.invoke(myComponent, "myTest", 3, 4)
    if myResult ~= 5 then
        print("Component system failed!")
	else
		print("Component system worked!")
    end
end

function key ( k )
    print(k)
end
