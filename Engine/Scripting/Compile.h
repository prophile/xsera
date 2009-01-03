#ifndef __apollo_scripting_compile_h
#define __apollo_scripting_compile_h

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <string>

/**
 * Compiles a lua script for faster access, if it is not already up-to-date
 * @param scriptName The name of the script to compile
 */
void CompileScript ( const std::string& scriptName );

#endif