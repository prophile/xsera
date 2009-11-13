#include "Server.h"
#include "Scripting.h"

namespace Server
{

static volatile bool terminateServer = false;

static int BGThread ( void* udata )
{
	LuaScript* serverScript = new LuaScript("System/Server");
	while (!terminateServer)
	{
		serverScript->InvokeSubroutine("update");
		SDL_Delay(5);
	}
	delete serverScript;
	terminateServer = false;
	return 0;
}

void Start ()
{
	SDL_CreateThread(BGThread, 0);
}

void Terminate ()
{
	terminateServer = true;
	while (terminateServer)
	{
		SDL_Delay(100);
	}
}

}
