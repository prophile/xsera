#ifndef __xsera_scripting_scripting_h
#define __xsera_scripting_scripting_h

#include <stdarg.h>

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
    
    void InvokeSubroutine ( const std::string& name );
	void InvokeSubroutine ( const std::string& name, const char* p );
	void InvokeSubroutine ( const std::string& name, float x, float y );
	
	lua_State* RawState () { return L; }
	static void RawImport ( lua_State* L, const std::string& modulename );
	
	void ImportModule ( const std::string& name )
		{ RawImport(L, name); }
};

#endif