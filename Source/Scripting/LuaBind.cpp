#include "Scripting.h"
#include "Utilities/ResourceManager.h"
#include "Sound/Sound.h"

namespace
{

int RM_Load ( lua_State* L )
{
    const char* file = luaL_checkstring(L, 0);
    SDL_RWops* ptr = ResourceManager::OpenFile(file);
    if (ptr)
    {
        size_t len;
        void* data = ResourceManager::ReadFull(&len, ptr, 1);
        lua_pushlstring(L, (const char*)data, len);
        free(data);
        return 1;
    }
    else
    {
        lua_pushliteral(L, "file not found");
        return lua_error(L);
    }
}

int RM_FileExists ( lua_State* L )
{
    const char* file = luaL_checkstring(L, 0);
    bool exists = ResourceManager::FileExists(file);
    lua_pushboolean(L, exists ? 1 : 0);
    return 1;
}

int RM_Write ( lua_State* L )
{
    const char* file = luaL_checkstring(L, 0);
    size_t len;
    const char* data = luaL_checklstring(L, 1, &len);
    ResourceManager::WriteFile(file, (const void*)data, len);
    return 0;
}

luaL_Reg registryResourceManager[] =
{
    "file_exists", RM_FileExists,
    "load", RM_Load,
    "write", RM_Write,
    NULL, NULL
};

luaL_Reg registryGraphics[] =
{
    NULL, NULL
};

int Sound_Play ( lua_State* L )
{
    const char* sound;
    float pan = 0.0f;
    float volume = 1.0f;
    int nargs = lua_gettop(L);
    sound = luaL_checkstring(L, 0);
    if (nargs > 1)
        volume = luaL_checknumber(L, 1);
    if (nargs > 2)
        pan = luaL_checknumber(L, 2);
    Sound::PlaySound(sound, volume, pan);
    return 0;
}

int Sound_PlayMusic ( lua_State* L )
{
    const char* mus = luaL_checkstring(L, 0);
    Sound::PlayMusic(mus);
    return 0;
}

int Sound_StopMusic ( lua_State* L )
{
    Sound::StopMusic();
    return 0;
}

luaL_Reg registrySound[] =
{
    "play", Sound_Play,
    "play_music", Sound_PlayMusic,
    "stop_music", Sound_StopMusic,
    NULL, NULL
};

}

void __LuaBind ( lua_State* L )
{
    luaL_register(L, "resource_manager", registryResourceManager);
    luaL_register(L, "graphics", registryGraphics);
    luaL_register(L, "sound", registrySound);
}
