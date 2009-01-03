#include <SDL/SDL.h>
#include "Utilities/ResourceManager.h"
#include "Graphics/Graphics.h"
#include "Sound/Sound.h"
#include "Scripting/Scripting.h"
#include "Modes/ModeManager.h"
#include "Utilities/TestHarness.h"
#include "Scripting/Compile.h"

namespace XseraMain
{

const char* MapKey ( SDLKey k )
{
	switch (k)
	{
#define KEYCASE(sym, string) case SDLK_ ## sym: return string
#define DIRECTCASE(sym) KEYCASE(sym, #sym)
		DIRECTCASE(a);
		DIRECTCASE(b);
		DIRECTCASE(c);
		DIRECTCASE(d);
		DIRECTCASE(e);
		DIRECTCASE(f);
		DIRECTCASE(g);
		DIRECTCASE(h);
		DIRECTCASE(i);
		DIRECTCASE(j);
		DIRECTCASE(k);
		DIRECTCASE(l);
		DIRECTCASE(m);
		DIRECTCASE(n);
		DIRECTCASE(o);
		DIRECTCASE(p);
		DIRECTCASE(q);
		DIRECTCASE(r);
		DIRECTCASE(s);
		DIRECTCASE(t);
		DIRECTCASE(u);
		DIRECTCASE(v);
		DIRECTCASE(w);
		DIRECTCASE(x);
		DIRECTCASE(y);
		DIRECTCASE(z);
		DIRECTCASE(0);
		DIRECTCASE(1);
		DIRECTCASE(2);
		DIRECTCASE(3);
		DIRECTCASE(4);
		DIRECTCASE(5);
		DIRECTCASE(6);
		DIRECTCASE(7);
		DIRECTCASE(8);
		DIRECTCASE(9);
		DIRECTCASE(F1);
		DIRECTCASE(F2);
		DIRECTCASE(F3);
		DIRECTCASE(F4);
		DIRECTCASE(F5);
		DIRECTCASE(F6);
		DIRECTCASE(F7);
		DIRECTCASE(F8);
		DIRECTCASE(F9);
		DIRECTCASE(F10);
		DIRECTCASE(F11);
		DIRECTCASE(F12);
		KEYCASE(TAB, "tab");
		KEYCASE(RETURN, "return");
		KEYCASE(ESCAPE, "escape");
		KEYCASE(SPACE, " ");
		KEYCASE(LEFT, "arrow_left");
		KEYCASE(RIGHT, "arrow_right");
		KEYCASE(UP, "arrow_up");
		KEYCASE(DOWN, "arrow_down");
	}
	return "unhandled";
}

void DispatchEvent ( const SDL_Event& evt )
{
	if (!ActiveMode())
		return;
	switch (evt.type)
	{
		case SDL_KEYDOWN:
			ActiveMode()->InvokeSubroutine("key",   MapKey(evt.key.keysym.sym));
			break;
		case SDL_KEYUP:
			ActiveMode()->InvokeSubroutine("keyup", MapKey(evt.key.keysym.sym));
			break;
		case SDL_QUIT:
			exit(0);
			break;
	}
}

void RunLoop ()
{
	UpdateModeManager();
	assert(ActiveMode());
	ActiveMode()->InvokeSubroutine("render");
	//Graphics::DrawText("FooText", "CrystalClear", vec2(0.0f, 0.0f), 100.0f, colour(1.0f, 1.0f, 1.0f, 1.0f), 0.0f);
	ActiveMode()->InvokeSubroutine("update");
}

void Startup ()
{
	// do init stuff
	SDL_Init(SDL_INIT_TIMER);
	InitModeManager();
	ResourceManager::Init();
//	Graphics::Init(640, 480, false); // 640x480 resolution, non-fullscreen (4:3 aspect ratio)
	Graphics::Init(960, 720, false); // 960x720 resolution, non-fullscreen (4:3 aspect ratio)
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

