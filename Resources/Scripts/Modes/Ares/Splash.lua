import('GlobalVars')
import('PrintRecursive')
import('Console')
import('BoxDrawing')
import('Interfaces')

SPLASH_SHIFT_LEFT = -140
SPLASH_SHIFT_RIGHT = 138
TOP_OF_SPLASH = -28
SPLASH_STRIDE = 26

local mup = false
local mdown = false

local execs = {
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Start New Game", justify = "left", boxColour = ClutColour(8, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch('Ares/Briefing') end, letter = "S" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 1 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Start Network Game", justify = "left", boxColour = ClutColour(5, 5), textColour = ClutColour(13, 9), execute = nil, letter = "N" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 2 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Replay Intro", justify = "left", boxColour = ClutColour(1, 8), textColour = ClutColour(13, 9), execute = nil, letter = "R" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 3 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Demo", justify = "left", boxColour = ClutColour(1, 6), textColour = ClutColour(13, 9), execute = nil, letter = "D" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 4 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Options", justify = "left", boxColour = ClutColour(12, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch('Ares/Options') end, letter = "O" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 5 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "About Ares and Xsera", justify = "left", boxColour = ClutColour(1, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch('Xsera/Credits') end, letter = "A" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 6 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Xsera Main Menu", justify = "left", boxColour = ClutColour(9, 6), textColour = ClutColour(13, 9), execute = function() mode_manager.switch('Xsera/MainMenu') end, letter = "M" },
	{ xCoord = SPLASH_SHIFT_LEFT, yCoord = TOP_OF_SPLASH - 7 * SPLASH_STRIDE, length = SPLASH_SHIFT_RIGHT - SPLASH_SHIFT_LEFT, text = "Quit", justify = "left", boxColour = ClutColour(8, 4), textColour = ClutColour(13, 9), execute = function() os.exit() end, letter = "Q" } }

function init()
	sound.stop_music()
	graphics.set_camera(-240 * aspectRatio, -240, 240 * aspectRatio, 240)
end

function update()
	-- mouse button handling
	if mup then
		mup = false
		mousePos = mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, nil, execs)
	elseif mdown then
		mousePos = mouse_position()
		mousePos.x = mousePos.x * 480 * aspectRatio - 240 * aspectRatio
		mousePos.y = mousePos.y * 480 - 240
		ChangeSpecialByLoc(mousePos, "click", execs)
	end
end

function render()
	graphics.begin_frame()
    graphics.draw_image("Panels/MainTop", { x = 0, y = 118 }, { x = 640, y = 245 })
    graphics.draw_image("Panels/MainBottom", { x = 0, y = -227 }, { x = 640, y = 24 })
    graphics.draw_image("Panels/MainLeft", { x = -231, y = -110 }, { x = 178, y = 211 })
    graphics.draw_image("Panels/MainRight", { x = 230, y = -110 }, { x = 180, y = 211 })
	
	for num = 1, #execs do
		SwitchBox(execs[num])
	end
	
	-- Error Printing
	if errNotice ~= nil then
		graphics.draw_text(errNotice.text, MAIN_FONT, "left", { x = -315, y = 225 }, 28)
		if errNotice.start + errNotice.duration < mode_manager.time() then
			errNotice = nil
		end
	end
	graphics.end_frame()
end

function keyup(k)
	ChangeSpecial(k:upper(), nil, execs)
end

function key(k)
	ChangeSpecial(k:upper(), "click", execs)
end

function mouse(button, x, y)
	if button ~= "wheel_up" and button ~= "wheel_down" then
		mdown = true
	end
end

function mouse_up(button, mbX, mbY)
	if button ~= "wheel_up" and button ~= "wheel_down" then
		mup = true
		mdown = false
	end
end