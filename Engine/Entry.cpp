#ifdef WIN32
#include "stdafx.h"
#include <time.h>
#endif

#include "Apollo.h"

struct _automatic_terminator
{
    _automatic_terminator () { Init(); }
    ~_automatic_terminator () { Shutdown(); }
};

int main ( int argc, char** argv )
{
    srand(time(NULL));
    _automatic_terminator at;
	SDL_Init(SDL_INIT_TIMER);
#ifndef NDEBUG
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
#else
	if (0)
	{
	}
#endif
    else
    {
        MainLoop();
    }
    return 0;
}
