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

float ToFloat ( const std::string& value )
{
	return (float)atof(value.c_str());
}

void Startup ()
{
	// do init stuff
	InitModeManager();
	ResourceManager::Init("Xsera");
	Preferences::Load();
	Graphics::Init(ToInt(Preferences::Get("Screen/Width")), ToInt(Preferences::Get("Screen/Height")), ToBool(Preferences::Get("Screen/Fullscreen")));
	Sound::Init(ToInt(Preferences::Get("Audio/SamplingRate")), ToInt(Preferences::Get("Audio/Resolution")), ToInt(Preferences::Get("Audio/Channels")));
	Sound::SetMusicVolume(ToFloat(Preferences::Get("Audio/MusicVolume")));
	Sound::SetSoundVolume(ToFloat(Preferences::Get("Audio/SoundVolume")));
	Graphics::BeginFrame();
	Graphics::EndFrame();
	// compile class script
	CompileScript("System/Class");
	LuaScript bootScript ("System/Boot");
	#ifdef NDEBUG
		SwitchMode("Xsera/Intro");
	#else
		SwitchMode("Xsera/MainMenu");
	#endif
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

