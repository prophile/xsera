#include <SDL/SDL.h>
#include "Utilities/ResourceManager.h"
#include "Graphics/Graphics.h"
#include "Sound/Sound.h"
#include "Scripting/Scripting.h"
#include "Modes/ModeManager.h"
#include "Utilities/TestHarness.h"
#include "Scripting/Compile.h"
#include "Input.h"

namespace XseraMain
{

void HandleInput ()
{
	Input::Pump();
	while (Input::Event* evt = Input::Next())
	{
		switch (evt->type)
		{
			case Input::Event::KEYDOWN:
				ActiveMode()->InvokeSubroutine("key", evt->object);
				break;
			case Input::Event::KEYUP:
				ActiveMode()->InvokeSubroutine("keyup", evt->object);
				break;
			case Input::Event::QUIT:
				exit(0);
				break;
		}
	}
}

void RunLoop ()
{
	UpdateModeManager();
	assert(ActiveMode());
	HandleInput();
	ActiveMode()->InvokeSubroutine("update");
	ActiveMode()->InvokeSubroutine("render");
}

void Startup ()
{
	// do init stuff
	SDL_Init(SDL_INIT_TIMER);
	InitModeManager();
	ResourceManager::Init("Xsera");
//	keep these other aspect ratios for later, when we will give the option to change resolution
//	actually, there will probably be two variables when it is implemented, but keep the numbers for reference
//	Graphics::Init(1280, 800, true); // 1280x800 resolution, fullscreen (8:5 aspect ratio) (MacBook res)
//	Graphics::Init(640, 480, false); // 640x480 resolution, non-fullscreen (4:3 aspect ratio)
//	Graphics::Init(800, 600, false); // 800x600 resolution, non-fullscreen (4:3 aspect ratio)
//	Graphics::Init(960, 720, false); // 960x720 resolution, non-fullscreen (4:3 aspect ratio)
	Graphics::Init(1024, 768, false); // 1024x768 resolution, non-fullscreen (4:3 aspect ratio)
	SDL_EnableUNICODE(1);
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

using namespace XseraMain;

int main ( int argc, char** argv )
{
	srand(time(NULL));
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

