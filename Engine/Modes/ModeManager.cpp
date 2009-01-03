#include "ModeManager.h"
#include <SDL/SDL.h>
#include "Logging.h"

static LuaScript* mode = NULL;

LuaScript* ActiveMode ()
{
	return mode;
}

void InitModeManager ()
{
}

std::string _next_mode = "";

void UpdateModeManager ()
{
	if (_next_mode != "")
	{
		if (mode)
		{
			mode->InvokeSubroutine("shutdown");
			delete mode;
		}
		LOG("ModeManager", LOG_MESSAGE, "Switching to mode %s", _next_mode.c_str());
		mode = new LuaScript("Modes/" + _next_mode);
		_next_mode = "";
		mode->InvokeSubroutine("init");
	}
}

void SwitchMode ( const std::string& newmode )
{
	_next_mode = newmode;
}
