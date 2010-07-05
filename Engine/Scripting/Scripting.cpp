#include "Scripting.h"
#include "ResourceManager.h"
#include "Engine/Logging.h"
#include "Compile.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

extern void __LuaBind ( lua_State* L );

#define LUA_READER_BUFFER_SIZE 1024

static const char* luaReader ( lua_State* L, void* data, size_t* size )
{
    static char buffer[LUA_READER_BUFFER_SIZE];
    size_t len = SDL_RWread((SDL_RWops*)data, buffer, 1, LUA_READER_BUFFER_SIZE);
    if (len <= 0)
    {
        *size = 0;
        return NULL;
    }
    else
    {
        *size = len;
        return buffer;
    }
}

static void luaHandleError ( lua_State* L )
{
    const char* message = lua_tostring(L, -1);
    LOG("Scripting::Driver", LOG_WARNING, "Script error: %s", message);
    lua_pop(L, 1);
}

static void luaLoad ( lua_State* L, const std::string& path )
{
	std::string fullpath = "Scripts/" + path + ".lua";
	if (ResourceManager::FileExists("Scripts/" + path + ".lo"))
	{
		fullpath = "Scripts/" + path + ".lo";
	}
	else
	{
#ifdef NDEBUG
		CompileScript(path);
#endif
	}
	SDL_RWops* rwops = ResourceManager::OpenFile(fullpath);
    if (rwops)
    {
        int rc = lua_load(L, luaReader, (void*)rwops, path.c_str());
		SDL_RWclose(rwops);
		if (rc != 0)
		{
			luaHandleError(L);
			return;
		}
        rc = lua_pcall(L, 0, 0, 0);
        if (rc != 0)
        {
            luaHandleError(L);
			return;
        }
    }
    else
    {
        LOG("Scripting::Driver", LOG_WARNING, "Unable to load script: %s", path.c_str());
    }
}

LuaScript::LuaScript ( const std::string& filename )
{
    L = luaL_newstate();
    luaL_openlibs(L);
    __LuaBind(L);
	luaLoad(L, "System/Class");
    luaLoad(L, filename);
}

LuaScript::~LuaScript ()
{
    lua_close(L);
}

void LuaScript::InvokeSubroutine ( const std::string& name )
{
	lua_getglobal(L, name.c_str());
    if (!lua_isnoneornil(L, -1))
    {
        int rc = lua_pcall(L, 0, 0, 0);
        if (rc > 0)
        {
            luaHandleError(L);
        }
    }
    else
    {
        lua_pop(L, 1);
    }
}

void LuaScript::InvokeSubroutine ( const std::string& name, const std::string& p )
{
	lua_getglobal(L, name.c_str());
    if (!lua_isnoneornil(L, -1))
    {
		lua_pushlstring(L, p.data(), p.length());
        int rc = lua_pcall(L, 1, 0, 0);
        if (rc > 0)
        {
            luaHandleError(L);
        }
    }
    else
    {
        lua_pop(L, 1);
    }
}

void LuaScript::InvokeSubroutine ( const std::string& name, int reference )
{
	lua_getglobal(L, name.c_str());
    if (!lua_isnoneornil(L, -1))
    {
		lua_rawgeti(L, reference, -1);
        int rc = lua_pcall(L, 1, 0, 0);
        if (rc > 0)
        {
            luaHandleError(L);
        }
    }
    else
    {
        lua_pop(L, 1);
    }
}

void LuaScript::InvokeSubroutine ( const std::string& name, float x, float y )
{
	lua_getglobal(L, name.c_str());
    if (!lua_isnoneornil(L, -1))
    {
		lua_pushnumber(L, x);
		lua_pushnumber(L, y);
        int rc = lua_pcall(L, 2, 0, 0);
        if (rc > 0)
        {
            luaHandleError(L);
        }
    }
    else
    {
        lua_pop(L, 1);
    }
}

void LuaScript::InvokeSubroutine ( const std::string& name, const std::string& p, float x, float y )
{
	lua_getglobal(L, name.c_str());
    if (!lua_isnoneornil(L, -1))
    {
		lua_pushlstring(L, p.data(), p.length());
		lua_pushnumber(L, x);
		lua_pushnumber(L, y);
        int rc = lua_pcall(L, 3, 0, 0);
        if (rc > 0)
        {
            luaHandleError(L);
        }
    }
    else
    {
        lua_pop(L, 1);
    }
}

void LuaScript::RawImport ( lua_State* L, const std::string& module )
{
	luaLoad(L, "Modules/" + module);
}
