oldTime = 0.0
angle = 0.0
doRotation = true

musics = {"Yesterday", "Doomtroopers", "Technobee", "Targetron"}

function init ()
    sound.play_music(musics[math.random(1, #musics)])
	oldTime = mode_manager.time()
end

function key ( k )
	if k == 'p' then
		if doRotation then
			doRotation = false
			print("Froze rotation at " .. angle .. " radians")
		else
			doRotation = true
		end
	elseif k == 'escape' then
		mode_manager.switch('MainMenu')
	end
end

function render ()
    local szx, szy = graphics.sprite_dimensions("Cantharan/Schooner")
	graphics.begin_frame()
	graphics.set_camera(-320, -240, 320, 240)
	graphics.draw_sprite("Cantharan/Schooner", 0, 0, szx * 2.2, szy * 2.2, angle)
	graphics.draw_text(string.format("Angle: %.3f", angle), "CrystalClear", -200, -200, 30)
	graphics.end_frame()
end

function update ()
	local newTime = mode_manager.time()
	local dt = newTime - oldTime
	oldTime = newTime
	if doRotation then
	   angle = angle + 0.5 * dt
	   if angle > math.pi * 2.0 then
	       angle = 0
	   end
    end
end
