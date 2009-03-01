#include "Apollo.h"
#include "Compile.h"
#include "Utilities/ResourceManager.h"
#include "Logging.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

struct CompileInstructions
{
	std::string sourcePath;
	std::string destPath;
	std::string name;
};

#define LUA_READER_BUFFER_SIZE 4096

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

static int luaWriter ( lua_State* L, const void* p, size_t len, void* ud )
{
	SDL_RWops* rwops = (SDL_RWops*)ud;
	return SDL_RWwrite(rwops, p, len, 1) == 1 ? 0 : -1;
}

static void luaLoad ( lua_State* L, const std::string& path )
{
	SDL_RWops* rwops = ResourceManager::OpenFile(path);
    if (rwops)
    {
        int rc = lua_load(L, luaReader, (void*)rwops, path.c_str());
		SDL_RWclose(rwops);
		if (rc != 0)
		{
            LOG("Scripting::Compiler", LOG_WARNING, "Unable to load script %s", path.c_str());
			return;
		}
    }
    else
    {
        LOG("Scripting::Compiler", LOG_WARNING, "Unable to open script %s", path.c_str());
    }
}

static int CompileScript_Thread ( void* data )
{
	CompileInstructions* command = (CompileInstructions*)data;
	
	if (!ResourceManager::FileExists(command->destPath))
	{
		// you just lost the game
		lua_State* L = luaL_newstate();
		luaLoad(L, command->sourcePath);
		SDL_RWops* writerRWops = ResourceManager::WriteFile(command->destPath);
		assert(writerRWops);
		lua_dump(L, luaWriter, (void*)writerRWops);
		SDL_RWclose(writerRWops);
		lua_close(L);
		printf("[Compiler] Compiled script %s\n", command->name.c_str());
	}
	
	delete command;
	return 0;
}

void CompileScript ( const std::string& scriptName )
{
	CompileInstructions* instrs = new CompileInstructions;
	instrs->name = scriptName;
	instrs->sourcePath = "Scripts/" + scriptName + ".lua";
	instrs->destPath = "Scripts/" + scriptName + ".lo";
	SDL_CreateThread(CompileScript_Thread, (void*)instrs);
}
