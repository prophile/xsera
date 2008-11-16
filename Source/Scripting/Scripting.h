#ifndef __xsera_scripting_scripting_h
#define __xsera_scripting_scripting_h

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <string>

class LuaScript
{
private:
    lua_State* L;
public:
    LuaScript ( const std::string& filename );
    ~LuaScript ();
    
    void InvokeSubroutine ( const std::string& name ); // can use dot syntax
};

#endif