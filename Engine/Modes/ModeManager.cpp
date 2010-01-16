#include "ModeManager.h"
#include <SDL/SDL.h>
#include "input.h"

#include "Logging.h"
#include "Graphics.h"

static AppMode* mode = NULL;
static AppMode* nextMode = NULL;
int reference = 0;

class LuaMode : public AppMode
{
private:
	LuaScript* script;
	std::string name;
public:
	LuaMode ( const std::string& _name )
	: name(_name)
	{
		script = new LuaScript("Modes/" + _name);
	}
	
	virtual ~LuaMode ()
	{
		delete script;
	}
	
	virtual std::string Name ()
	{
		return name;
	}
	
	virtual void Init ()
	{
		if (reference == 0)
		{
			script->InvokeSubroutine("init");
		}
		else
		{
			script->InvokeSubroutine("init", reference);
		}
	}
	
	virtual void Shutdown ()
	{
		script->InvokeSubroutine("shutdown");
	}
	
	virtual void Update ()
	{
		script->InvokeSubroutine("update");
	}
	
	virtual void Render ()
	{
		script->InvokeSubroutine("render");
	}
	
	virtual void HandleEvent ( const Input::Event& event )
	{
		vec2 mouseMapped = Graphics::MapPoint(event.mouse);
		switch (event.type)
		{
			case Input::Event::KEYDOWN:
				script->InvokeSubroutine("key", event.object);
				break;
			case Input::Event::KEYUP:
				script->InvokeSubroutine("keyup", event.object);
				break;
			case Input::Event::CLICK:
				script->InvokeSubroutine("mouse", event.object, mouseMapped.X(), mouseMapped.Y());
				break;
			case Input::Event::RELEASE:
				script->InvokeSubroutine("mouse_up", event.object, mouseMapped.X(), mouseMapped.Y());
				break;
			case Input::Event::QUIT:
				// TODO: interpret this better: maybe just handle it like an ESC?
				exit(0);
				break;
			default: break;
		}
	}
};

AppMode* ActiveMode ()
{
	return mode;
}

void InitModeManager ()
{
}

void UpdateModeManager ()
{
//	usleep(125000); // debug line
	if (nextMode != NULL)
	{
		if (mode)
		{
			mode->Shutdown();
			delete mode;
		}
		LOG("ModeManager", LOG_MESSAGE, "Switching to mode %s", nextMode->Name().c_str());
		mode = nextMode;
		nextMode = NULL;
		if (mode)
		{
			mode->Init();
		}
	}
	if (mode)
	{
		mode->Update();
		Input::Pump();
		while (Input::Event* event = Input::Next())
		{
			mode->HandleEvent(*event);
		}
		mode->Render();
	}
}

const char* QueryMode()
{
	return ActiveMode()->Name().c_str();
}

void SwitchMode ( const std::string& newmode )
{
	LuaMode* newMode = new LuaMode ( newmode );
	SwitchMode ( newMode );
}

void SwitchMode ( const std::string& newmode, int ref )
{
	reference = ref;
	LuaMode* newMode = new LuaMode ( newmode );
	SwitchMode ( newMode );
}

void SwitchMode ( AppMode* newmode )
{
	if (nextMode) delete nextMode;
	nextMode = newmode;
}

// 