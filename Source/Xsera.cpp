#include <SDL/SDL.h>
#include "Apollo.h"

namespace XseraMain
{

void RunLoop ()
{
	UpdateModeManager();
}

void Startup ()
{
	// do init stuff
	InitModeManager();
	ResourceManager::Init("Xsera");
	Graphics::Init(960, 720, false);
	Sound::Init(48000, 24, 128); // init with 48 kHz sampling rate, 24-bit resolution, 128 channels
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

