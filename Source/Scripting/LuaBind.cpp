#include "Scripting.h"
#include "Utilities/ResourceManager.h"
#include "Sound/Sound.h"
#include "Graphics/Graphics.h"
#include "Modes/ModeManager.h"

namespace
{

int MM_Switch ( lua_State* L )
{
	const char* newmode = luaL_checkstring(L, 1);
	SwitchMode(std::string(newmode));
	return 0;
}

luaL_Reg registryModeManager[] =
{
	"switch", MM_Switch,
	NULL, NULL
};

int RM_Load ( lua_State* L )
{
    const char* file = luaL_checkstring(L, 1);
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
    const char* file = luaL_checkstring(L, 1);
    bool exists = ResourceManager::FileExists(file);
    lua_pushboolean(L, exists ? 1 : 0);
    return 1;
}

int RM_Write ( lua_State* L )
{
    const char* file = luaL_checkstring(L, 1);
    size_t len;
    const char* data = luaL_checklstring(L, 2, &len);
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

int GFX_BeginFrame ( lua_State* L )
{
	Graphics::BeginFrame();
	return 0;
}

int GFX_EndFrame ( lua_State* L )
{
	Graphics::EndFrame();
	return 0;
}

int GFX_SetCamera ( lua_State* L )
{
	float ll_x, ll_y, tr_x, tr_y, rot = 0.0f;
	int nargs = lua_gettop(L);
	ll_x = luaL_checknumber(L, 1);
	ll_y = luaL_checknumber(L, 2);
	tr_x = luaL_checknumber(L, 3);
	tr_y = luaL_checknumber(L, 4);
	if (nargs > 4)
		rot = luaL_checknumber(L, 5);
	Graphics::SetCamera(vec2(ll_x, ll_y), vec2(tr_x, tr_y), rot);
	return 0;
}

int GFX_DrawImage ( lua_State* L )
{
	const char* imgName;
	float loc_x, loc_y, size_x, size_y;
	imgName = luaL_checkstring(L, 1);
	loc_x = luaL_checknumber(L, 2);
	loc_y = luaL_checknumber(L, 3);
	size_x = luaL_checknumber(L, 4);
	size_y = luaL_checknumber(L, 5);
	Graphics::DrawImage(imgName, vec2(loc_x, loc_y), vec2(size_x, size_y));
	return 0;
}

int GFX_DrawSprite ( lua_State* L )
{
	const char* spritesheet;
	int sheet_x, sheet_y, nargs = lua_gettop(L);
	float loc_x, loc_y, size_x, size_y, rot = 0.0f;
	spritesheet = luaL_checkstring(L, 1);
	sheet_x = luaL_checkinteger(L, 2);
	sheet_y = luaL_checkinteger(L, 3);
	loc_x = luaL_checknumber(L, 4);
	loc_y = luaL_checknumber(L, 5);
	size_x = luaL_checknumber(L, 6);
	size_y = luaL_checknumber(L, 7);
	if (nargs > 7)
		rot = luaL_checknumber(L, 8);
	Graphics::DrawSprite(spritesheet, sheet_x, sheet_y, vec2(loc_x, loc_y), vec2(size_x, size_y), rot);
	return 0;
}

luaL_Reg registryGraphics[] =
{
	"begin_frame", GFX_BeginFrame,
	"end_frame", GFX_EndFrame,
	"set_camera", GFX_SetCamera,
	"draw_image", GFX_DrawImage,
	"draw_sprite", GFX_DrawSprite,
    NULL, NULL
};

int Sound_Play ( lua_State* L )
{
    const char* sound;
    float pan = 0.0f;
    float volume = 1.0f;
    int nargs = lua_gettop(L);
    sound = luaL_checkstring(L, 1);
    if (nargs > 1)
        volume = luaL_checknumber(L, 2);
    if (nargs > 2)
        pan = luaL_checknumber(L, 3);
    Sound::PlaySound(sound, volume, pan);
    return 0;
}

int Sound_PlayMusic ( lua_State* L )
{
    const char* mus = luaL_checkstring(L, 1);
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
	luaL_register(L, "mode_manager", registryModeManager);
    luaL_register(L, "resource_manager", registryResourceManager);
    luaL_register(L, "graphics", registryGraphics);
    luaL_register(L, "sound", registrySound);
}
