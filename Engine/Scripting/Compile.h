#ifndef __apollo_scripting_compile_h
#define __apollo_scripting_compile_h

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <string>

void CompileScript ( const std::string& scriptName );

#endif