-- I need this function to run in Demo.lua every time the mouse button is clicked
-- ALISTAIR: I'll need your help on this - I want it to work like update() or key()

--[[ this doesn't work because input hasn't been encorporated yet
lmb = { x, y }

-- I need a vector here, containing the bounds of each rectangle that can be clicked on

function onMouseClick
	if input.lmb_state == true then
		lmb.x, lmb.y = input.mouse_coords()
		
	end
end
--]]