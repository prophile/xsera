import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')


cid = 0

function init()
	physics.open(0.6)
	loadingEntities = true
	gameData = dofile("./Xsera.app/Contents/Resources/Config/data.lua") --[FIX] this is A) not cross platform in ANY way shape or form B) an ugly way of fixing it.
	loadingEntities = false
	scen = LoadScenario(1)
end

function key( k )
	print(k)
	if k == "q" then
		mode_manager.switch("MainMenu")
	elseif k =="w" then
		cid = cid + 1
	elseif k == "s" then
		cid = cid - 1
	elseif k == "return" then
		
	end
end

function update()

end

function render()
	graphics.begin_frame()
	graphics.draw_text("Current id: " .. cid,"CrystalClear","left",-400,200,60)
	graphics.draw_text(gameData["Objects"][cid].name,"CrystalClear","left",-400,120,30)
	graphics.end_frame()
end