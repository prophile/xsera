import('GlobalVars')

options = {
            { key = "escape", name = "Return",              loc = "Xsera/MainMenu"                                      },
            { key = "x",      name = "Console",             loc = "Xsera/ConsoleDrawer"                                 },
            { key = "t",      name = "Turret Test",         loc = "../Tests/TurretTest"                                 },
            { key = "s",      name = "Ares Splash",         loc = "Ares/Splash"                                         },
            { key = "1",      name = "Client-Server Tests", loc = "../Tests/CSTest",         status = "Non-operational" },
            { key = "2",      name = "<blank>",             loc = nil                                                   },
            { key = "3",      name = "Window Test",         loc = "../Tests/WindowTest",     status = "Incomplete"      },
            { key = "4",      name = "Text Test",           loc = "../Tests/TextTest"                                   },
            { key = "5",      name = "<blank>",             loc = nil                                                   },
            { key = "6",      name = "Preference Test",     loc = "../Tests/PreferenceTest", status = "Non-operational" },
            { key = "7",      name = "Physics Test",        loc = "../Tests/PhysicsTest",    status = "Broken"          },
            { key = "8",      name = "Bit Test",            loc = "../Tests/Bits"                                       },
            { key = "9",      name = "3D Test",             loc = "../Tests/3DTest"                                     },
            { key = "0",      name = "XNet Test",           loc = "../Tests/XNetTest",       status = "Non-operational" }
          }

function init ()
    local camera = { w = 800, h = 600 }
    graphics.set_camera(-camera.w / 2, -camera.h / 2, camera.w / 2, camera.h / 2)
end

function render ()
    graphics.begin_frame()
    
    for i = 1, #options do
        graphics.draw_text(options[i].key .. " - " .. options[i].name .. (options[i].status == nil and "" or " (" .. options[i].status .. ")"), MAIN_FONT, "left", { x = -390, y = 300 - 25 * i }, 20)
    end
    
    graphics.end_frame()
end

function key ( k )
    for i = 1, #options do
        if options[i].key == k then
            mode_manager.switch(options[i].loc)
        end
    end
end