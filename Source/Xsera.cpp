#include <SDL/SDL.h>
#include "Utilities/ResourceManager.h"
#include "Graphics/Graphics.h"
#include "Sound/Sound.h"

namespace XseraMain
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
	Graphics::BeginFrame();
	Graphics::SetCamera(vec2(0.0f, 0.0f), vec2(1.0f, 1.0f), 0.0f);
	Graphics::DrawLine(vec2(0.0f, 0.0f), vec2(1.0f, 1.0f), 1.0f, colour(1.0f, 1.0f, 1.0f, 1.0f));
	//Graphics::DrawCircle(vec2(0.5f, 0.5f), 0.4f, 3.0f, colour(1.0f, 1.0f, 1.0f, 1.0f));
	Graphics::EndFrame();
}

void Startup ()
{
	// do init stuff
	ResourceManager::Init();
	Graphics::Init(640, 480, false); // 640x480 resolution, non-fullscreen
	Sound::Init(48000, 24, 128); // init with 48 kHz sampling rate, 24-bit resolution, 128 channels
	Sound::PlayMusic("Yesterday");
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
	(void)argc;
	(void)argv;
	Startup();
	MainLoop();
	return 0;
}

