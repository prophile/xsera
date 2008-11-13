#include <SDL/SDL.h>

namespace
{

void RunLoop ()
{
	// do stuff
}

void Startup ()
{
	// do init stuff
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

int main ( int argc, char** argv )
{
	(void)argc;
	(void)argv;
	Startup();
	MainLoop();
	return 0;
}

