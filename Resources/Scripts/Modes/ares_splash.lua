function init()
	sound.stop_music()
end

function update()
	
end

function render()
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
    graphics.draw_image("Panels/MainTop", 0, 118, 640, 245)
    graphics.draw_image("Panels/MainBottom", 0, -227, 640, 24)
    graphics.draw_image("Panels/MainLeft", -231, -110, 178, 211)
    graphics.draw_image("Panels/MainRight", 230, -110, 180, 211)
	graphics.end_frame()
end

function key(k)
	
end