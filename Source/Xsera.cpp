#include <SDL/SDL.h>
#include "Utilities/ResourceManager.h"
#include "Graphics/Graphics.h"
#include "Sound/Sound.h"
#include "Scripting/Scripting.h"
#include "Modes/ModeManager.h"
#include "Utilities/TestHarness.h"

namespace XseraMain
{

void DispatchEvent ( const SDL_Event& evt )
{
	switch (evt.type)
	{
		case SDL_KEYDOWN:
			{
				ActiveMode()->InvokeSubroutine("key", (char)evt.key.keysym.unicode);
			}
			break;
		case SDL_QUIT:
			exit(0);
			break;
	}
}

void RunLoop ()
{
	UpdateModeManager();
	ActiveMode()->InvokeSubroutine("render");
}

void Startup ()
{
	// do init stuff
	SDL_EnableUNICODE(1);
	InitModeManager();
	ResourceManager::Init();
	Graphics::Init(640, 480, false); // 640x480 resolution, non-fullscreen
	Sound::Init(48000, 24, 128); // init with 48 kHz sampling rate, 24-bit resolution, 128 channels
	LuaScript bootScript ( "Scripts/Boot" );
	SwitchMode("MainMenu");
}

void MainLoop ()
{
	while (true)
	{
		SDL_Event event;
		while (SDL_PollEvent(&event) > 0)
			DispatchEvent(event);
		RunLoop();
		SDL_Delay(1);
	}
}

}

using namespace XseraMain;

int main ( int argc, char** argv )
{
	Startup();
	if (argc > 1)
	{
		assert(!strcmp(argv[1], "-test"));
		assert(argc > 2);
		std::string test = argv[2];
		std::vector<std::string> testParameters;
		if (argc > 3)
		{
			for (int i = 3; i < argc; i++)
			{
				testParameters.push_back(std::string(argv[i]));
			}
		}
		bool testReturnCode = TestHarness::InvokeTest ( test, testParameters );
		if (testReturnCode)
		{
			return 0;
		}
		else
		{
			return -1;
		}
	}
	MainLoop();
	return 0;
}

