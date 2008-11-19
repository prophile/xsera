-- main menu script
function render ()
    graphics.begin_frame()
    
    graphics.set_camera(-500, -240, 500, 240)
    graphics.draw_image("Bootloader/Ares", 0, 0, 1000, 480)
    
    graphics.end_frame()
end

function init ()
    local xmlData = xml.load("Config/Version.xml")
	local versionData = xmlData[1]
	print("Xsera " .. versionData[1][1] .. " <" .. versionData[2][1] .. ">")
	if versionData.n == 3 then
		print("Signed off by: " .. versionData[3][1])
	end
end

function key ( k )
    print(k)
end
