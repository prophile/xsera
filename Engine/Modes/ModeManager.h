#ifndef __apollo_modes_modemanager_h
#define __apollo_modes_modemanager_h

#include "Scripting/Scripting.h"
#include "Input.h"

class AppMode;

/**
 * Initialises the mode manager
 */
void InitModeManager ();
/**
 * Updates the mode manager
 */
void UpdateModeManager ();
/**
 * Fetches the active mode
 * @return A LuaScript which constitutes the active mode
 */
AppMode* ActiveMode ();
/**
 * Switches to a new mode - a lua one
 * @param newmode The name of the new mode to which to switch
 */
void SwitchMode ( const std::string& newmode );
/**
 * Switches to a new mode - a non-lua one
 * @param newMode The mode to which to switch. This should not be deleted.
 */
void SwitchMode ( AppMode* newMode );
/**
 * Queries the name of the current mode
 */
const char* QueryMode ();

class AppMode
{
public:
	AppMode () {}
	virtual ~AppMode () {}
	virtual std::string Name () = 0;
	virtual void Init () {}
	virtual void Shutdown () {}
	virtual void Update () {}
	virtual void Render () {}
	virtual void HandleEvent ( const Input::Event& event ) {}
};

#endif
