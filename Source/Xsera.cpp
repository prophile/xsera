#include <SDL/SDL.h>
#include "Utilities/ResourceManager.h"
#include "Graphics/Graphics.h"
#include "Sound/Sound.h"

namespace
{

void DispatchEvent ( const SDL_Event& evt )
{
	switch (evt.type)
	{
		case SDL_QUIT:
			exit(0);
			break;
	}
}

void RunLoop ()
{
	// do stuff
}

void Startup ()
{
	// do init stuff
	ResourceManager::Init();
	Graphics::Init(640, 480, false); // 640x480 resolution, non-fullscreen
	Sound::Init(48000, 24, 128); // init with 48 kHz sampling rate, 24-bit resolution, 128 channels
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

int main ( int argc, char** argv )
{
	(void)argc;
	(void)argv;
	Startup();
	MainLoop();
	return 0;
}

