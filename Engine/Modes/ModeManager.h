#ifndef __apollo_modes_modemanager_h
#define __apollo_modes_modemanager_h

#include "Scripting/Scripting.h"

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
LuaScript* ActiveMode ();
/**
 * Switches to a new mode
 * @param newmode The name of the new mode to which to switch
 */
void SwitchMode ( const std::string& newmode );

#endif
