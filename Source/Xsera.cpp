#ifdef WIN32
#include <stdafx.h>
#endif

#include <SDL/SDL.h>
#include "Apollo.h"

namespace XseraMain
{

void RunLoop ()
{
	UpdateModeManager();
}

unsigned ToInt ( const std::string& value )
{
	return atoi(value.c_str());
}

bool ToBool ( const std::string& value )
{
	return value == "true";
}

void Startup ()
{
	// do init stuff
	InitModeManager();
	ResourceManager::Init("Xsera");
	Preferences::Load();
	Graphics::Init(ToInt(Preferences::Get("Screen/Width")), ToInt(Preferences::Get("Screen/Height")), ToBool(Preferences::Get("Screen/Fullscreen")));
	Sound::Init(ToInt(Preferences::Get("Audio/SamplingRate")), ToInt(Preferences::Get("Audio/Resolution")), ToInt(Preferences::Get("Audio/Channels"))); // init with 48 kHz sampling rate, 24-bit resolution, 128 channels
	// compile class script
	CompileScript("System/Class");
	LuaScript bootScript ("System/Boot");
	SwitchMode("MainMenu");
}

void MainLoop ()
{
	while (true)
	{
		RunLoop();
		SDL_Delay(1);
	}
}

}

// standard setup functions
void Init ()
{
    XseraMain::Startup();
}

void MainLoop ()
{
    XseraMain::MainLoop();
}

void Shutdown ()
{
}

