import('GlobalVars')

local execs = {}

function init()
	graphics.set_camera(-480, -360, 480, 360)
end

function update()

end

function render()
	graphics.begin_frame()
	graphics.draw_image("Panels/PanelTop", 0, 210, 572, 28)
	graphics.draw_image("Panels/PanelBottom", 0, -242, 572, 20)
	graphics.draw_image("Panels/PanelLeft", -302, -14, 33, 476)
	graphics.draw_image("Panels/PanelRight", 303, -14, 35, 476)
	num = 1
	while execs[num] ~= nil do
		-- draw them
	end
	graphics.end_frame()
end