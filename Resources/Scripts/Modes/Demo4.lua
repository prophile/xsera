import('Actions')
import('ObjectLoad')
import('GlobalVars')
import('Math')
import('Scenarios')

gameData = dofile("./Xsera.app/Contents/Resources/Config/data.lua") --[FIX] this is A) not cross platform in ANY way shape or form B) an ugly way of fixing it.


function key( k )
	if k == "q" then
		mode_manager.switch("MainMenu")
	end
end


function render()
	graphics.begin_frame()
	
	graphics.end_frame()
end