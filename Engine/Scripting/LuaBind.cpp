#include "Scripting.h"
#include "Utilities/ResourceManager.h"
#include "Sound/Sound.h"
#include "Graphics/Graphics.h"
#include "Input.h"
#include "Modes/ModeManager.h"
#include "TinyXML/tinyxml.h"
#include "Net/Net.h"
#include "Utilities/GameTime.h"
#include "Utilities/XarFile.h"
#include "Physics/PhysicsObject.h"
#include "Physics/PhysicsContext.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

namespace
{

vec2 luaL_checkvec2(lua_State* L, int narg)
{
	if (!lua_istable(L, narg))
	{
		luaL_argerror(L, narg, "must pass a vector table");
	}
	float x, y;
	lua_getfield(L, narg, "x");
	if (!lua_isnumber(L, -1))
	{
		luaL_argerror(L, narg, "must pass a vector table");
	}
	x = lua_tonumber(L, -1);
	lua_getfield(L, narg, "y");
	if (!lua_isnumber(L, -1))
	{
		luaL_argerror(L, narg, "must pass a vector table");
	}
	y = lua_tonumber(L, -1);
	lua_pop(L, 2);
	return vec2(x, y);
}

vec2 luaL_optvec2(lua_State* L, int narg, vec2 defaultValue)
{
	if (lua_isnoneornil(L, narg))
		return defaultValue;
	return luaL_checkvec2(L, narg);
}

void lua_pushvec2(lua_State* L, vec2 val)
{
	lua_createtable(L, 0, 2);
	lua_pushnumber(L, val.X());
	lua_setfield(L, -2, "x");
	lua_pushnumber(L, val.Y());
	lua_setfield(L, -2, "y");
}

int PHYS_Open ( lua_State* L )
{
	float resistance = luaL_optnumber(L, 1, 0.35);
	Physics::Open(resistance);
	return 0;
}

int PHYS_Close ( lua_State* L )
{
	Physics::Close();
	return 0;
}

int PHYS_Update ( lua_State* L )
{
	float timestep = luaL_checknumber(L, 1);
	Physics::Update(timestep);
	//ALASTAIR: No second arg above (should be friction)? How does that work in C++?
	return 0;
}

struct PHYS_Object
{
	Physics::Object* pob;
};

int PHYS_NewObject ( lua_State* L )
{
	float mass = luaL_checknumber(L, 1);
	luaL_argcheck(L, mass > 0.0f, 1, "you cannot have a zero or negative mass");
	Physics::Object* object = Physics::NewObject(mass);
	if (!object)
	{
		lua_pushliteral(L, "could not create object");
		return lua_error(L);
	}
	PHYS_Object* pob = (PHYS_Object*)lua_newuserdata(L, sizeof(PHYS_Object));
	pob->pob = object;
	luaL_getmetatable(L, "Apollo.PhysicsObject");
	lua_setmetatable(L, -2);
	return 1;
}

int PHYS_DestroyObject ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob)
	{
		Physics::DestroyObject(obj->pob);
		return 0;
	}
	else
	{
		lua_pushliteral(L, "double-destruction of physics object");
		return lua_error(L);
	}
}

int PHYS_ObjectFromID ( lua_State* L )
{
	unsigned id = luaL_checkinteger(L, 1);
	if (id == 0)
	{
		lua_pushnil(L);
		return 1;
	}
	Physics::Object* object = Physics::ObjectWithID(id);
	if (!object)
	{
		lua_pushnil(L);
		return 1;
	}
	PHYS_Object* pob = (PHYS_Object*)lua_newuserdata(L, sizeof(PHYS_Object));
	pob->pob = object;
	luaL_getmetatable(L, "Apollo.PhysicsObject");
	lua_setmetatable(L, -2);
	return 1;
}

int PHYS_Collisions ( lua_State* L )
{
	return 0;
}

int PHYS_Object_Impulse ( lua_State* L );
int PHYS_Object_AngularImpulse ( lua_State* L );
int PHYS_Object_Force ( lua_State* L );
int PHYS_Object_Torque ( lua_State* L );

int PHYS_Object_PropGet ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	std::string property = luaL_checkstring(L, 2);
	if (property == "apply_impulse")
	{
		lua_pushcclosure(L, PHYS_Object_Impulse, 0);
	}
	else if (property == "apply_angular_impulse")
	{
		lua_pushcclosure(L, PHYS_Object_AngularImpulse, 0);
	}
	else if (property == "apply_force")
	{
		lua_pushcclosure(L, PHYS_Object_Force, 0);
	}
	else if (property == "apply_torque")
	{
		lua_pushcclosure(L, PHYS_Object_Torque, 0);
	}
	else if (property == "mass")
	{
		lua_pushnumber(L, obj->pob->mass);
	}
	else if (property == "position")
	{
		lua_pushvec2(L, obj->pob->position);
	}
	else if (property == "velocity")
	{
		lua_pushvec2(L, obj->pob->velocity);
	}
	else if (property == "angle")
	{
		lua_pushnumber(L, obj->pob->angle);
	}
	else if (property == "angular_velocity")
	{
		lua_pushnumber(L, obj->pob->angularVelocity);
	}
	else if (property == "collision_radius")
	{
		lua_pushnumber(L, obj->pob->collisionRadius);
	}
	else if (property == "object_id")
	{
		lua_pushinteger(L, obj->pob->objectID);
	}
	else
	{
		char buffer[1024];
		sprintf(buffer, "unknown property: '%s'", property.c_str());
		lua_pushstring(L, buffer);
		return lua_error(L);
	}
	return 1;
}

int PHYS_Object_PropSet ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	std::string property = luaL_checkstring(L, 2);
	if (property == "position")
	{
		obj->pob->position = luaL_checkvec2(L, 3);
	}
	else if (property == "velocity")
	{
		obj->pob->velocity = luaL_checkvec2(L, 3);
	}
	else if (property == "angle")
	{
		obj->pob->angle = luaL_checknumber(L, 3);
	}
	else if (property == "angular_velocity")
	{
		obj->pob->angularVelocity = luaL_checknumber(L, 3);
	}
	else if (property == "mass")
	{
		obj->pob->mass = luaL_checknumber(L, 3);
	}
	else if (property == "collision_radius")
	{
		obj->pob->collisionRadius = luaL_checknumber(L, 3);
	}
	else
	{
		lua_pushliteral(L, "unknown property on physics object");
		return lua_error(L);
	}
	return 0;
}

int PHYS_Object_Impulse ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	obj->pob->ApplyImpulse(luaL_checkvec2(L, 2));
	return 0;
}

int PHYS_Object_AngularImpulse ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	obj->pob->ApplyAngularImpulse(luaL_checknumber(L, 2));
	return 0;
}

/*
int PHYS_Object_Force ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	obj->pob->force += luaL_checkvec2(L, 2);
	return 0;
}*/

int PHYS_Object_Force ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	obj->pob->force = luaL_checkvec2(L, 2);
	return 0;
}

int PHYS_Object_Torque ( lua_State* L )
{
	PHYS_Object* obj = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	obj->pob->torque += luaL_checknumber(L, 2);
	return 0;
}

luaL_Reg registryPhysics[] =
{
	"open", PHYS_Open,
	"close", PHYS_Close,
	"update", PHYS_Update,
	"new_object", PHYS_NewObject,
	"destroy_object", PHYS_DestroyObject,
	"object_from_id", PHYS_ObjectFromID,
	"collisions", PHYS_Collisions,
	NULL, NULL
};

luaL_Reg registryObjectPhysics[] =
{
	"__index", PHYS_Object_PropGet,
	"__newindex", PHYS_Object_PropSet,
	NULL, NULL
};

int luaopen_physics ( lua_State* L )
{
	luaL_newmetatable(L, "Apollo.PhysicsObject");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, registryObjectPhysics);
	luaL_register(L, "physics", registryPhysics);
	return 1;
}

int NetClient_Connected ( lua_State* L )
{
	lua_pushboolean(L, Net::Client::IsConnected() ? 1 : 0);
	return 1;
}

int NetClient_Connect ( lua_State* L )
{
	int nargs = lua_gettop(L);
	const char* host = luaL_checkstring(L, 1);
	unsigned port = luaL_checkint(L, 2);
	luaL_argcheck(L, port < 65536 && port > 0, 2, "Invalid port number");
	const char* password = "";
	if (nargs > 2)
	{
		password = luaL_checkstring(L, 3);
	}
	Net::Client::Connect(host, port, password);
	return 0;
}

int NetClient_Disconnect ( lua_State* L )
{
	Net::Client::Disconnect();
	return 0;
}

int NetClient_SendMessage ( lua_State* L )
{
	int nargs = lua_gettop(L);
	const char* message = luaL_checkstring(L, 1);
	size_t len = 0;
	const void* data = NULL;
	if (nargs > 1)
	{
		data = luaL_checklstring(L, 2, &len);
	}
	Net::Message messageObject ( message, data, len );
	Net::Client::SendMessage ( messageObject );
	return 0;
}

int NetClient_GetMessage ( lua_State* L )
{
	Net::Message* msg = Net::Client::GetMessage();
	if (msg)
	{
		lua_pushlstring(L, msg->message.data(), msg->message.length());
		if (msg->data)
		{
			lua_pushlstring(L, (const char*)msg->data, msg->dataLength);
		}
		else
		{
			lua_pushnil(L);
		}
		delete msg;
	}
	else
	{
		lua_pushnil(L);
		lua_pushnil(L);
	}
	return 2;
}

luaL_Reg registryNetClient[] =
{
	"connected", NetClient_Connected,
	"connect", NetClient_Connect,
	"disconnect", NetClient_Disconnect,
	"send", NetClient_SendMessage,
	"get", NetClient_GetMessage,
	NULL, NULL
};

int NetServer_Startup ( lua_State* L )
{
	unsigned port = luaL_checkinteger(L, 1);
	luaL_argcheck(L, port < 65536 && port > 0, 1, "Invalid port number");
	const char* password = "";
	if (lua_gettop(L) > 1)
	{
		password = luaL_checkstring(L, 2);
	}
	Net::Server::Startup(port, password);
	return 0;
}

int NetServer_Shutdown ( lua_State* L )
{
	Net::Server::Shutdown();
	return 0;
}

int NetServer_Running ( lua_State* L )
{
	lua_pushboolean(L, Net::Server::IsRunning() ? 1 : 0);
	return 1;
}

int NetServer_ClientCount ( lua_State* L )
{
	lua_pushinteger(L, Net::Server::ClientCount());
	return 1;
}

int NetServer_KillClient ( lua_State* L )
{
	unsigned clientID = luaL_checkinteger(L, 1);
	Net::Server::KillClient(clientID);
	return 0;
}

int NetServer_Connected ( lua_State* L )
{
	unsigned clientID = luaL_checkinteger(L, 1);
	bool isConnected = Net::Server::IsConnected(clientID);
	lua_pushboolean(L, isConnected ? 1 : 0);
	return 1;
}

int NetServer_SendMessage ( lua_State* L )
{
	int nargs = lua_gettop(L);
	unsigned clientID = luaL_checkinteger(L, 1);
	const char* message = luaL_checkstring(L, 2);
	size_t len = 0;
	const void* data = NULL;
	if (nargs > 2)
	{
		data = luaL_checklstring(L, 3, &len);
	}
	Net::Message messageObject ( message, data, len );
	Net::Server::SendMessage ( clientID, messageObject );
	return 0;
}

int NetServer_BroadcastMessage ( lua_State* L )
{
	int nargs = lua_gettop(L);
	const char* message = luaL_checkstring(L, 1);
	size_t len = 0;
	const void* data = NULL;
	if (nargs > 1)
	{
		data = luaL_checklstring(L, 2, &len);
	}
	Net::Message messageObject ( message, data, len );
	Net::Server::BroadcastMessage ( messageObject );
	return 0;
}

int NetServer_GetMessage ( lua_State* L )
{
	Net::Message* msg = Net::Server::GetMessage();
	if (msg)
	{
		lua_pushlstring(L, msg->message.data(), msg->message.length());
		if (msg->data)
		{
			lua_pushlstring(L, (const char*)msg->data, msg->dataLength);
		}
		else
		{
			lua_pushnil(L);
		}
		lua_pushinteger(L, msg->clientID);
		delete msg;
	}
	else
	{
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushnil(L);
	}
	return 3;
}

luaL_Reg registryNetServer[] =
{
	"startup", NetServer_Startup,
	"shutdown", NetServer_Shutdown,
	"running", NetServer_Running,
	"client_count", NetServer_ClientCount,
	"kill", NetServer_KillClient,
	"connected", NetServer_Connected,
	"send", NetServer_SendMessage,
	"broadcast", NetServer_BroadcastMessage,
	"get", NetServer_GetMessage,
	NULL, NULL
};

// XML code based on code from lua-users.org
void XML_ParseNode (lua_State* L, TiXmlNode* xmlNode)
{
	if (!xmlNode) return;
	// resize stack if neccessary
	luaL_checkstack(L, 5, "XML_ParseNode : recursion too deep");
	
	TiXmlElement* xmlElement = xmlNode->ToElement();
	if (xmlElement)
	{
		// element name
		lua_pushstring(L, "name");
		lua_pushstring(L, xmlElement->Value());
		lua_settable(L, -3);
		
		// parse attributes
		TiXmlAttribute* xmlAttribute = xmlElement->FirstAttribute();
		if (xmlAttribute)
		{
			lua_pushstring(L,"attr");
			lua_newtable(L);
			for (; xmlAttribute; xmlAttribute = xmlAttribute->Next())
			{
				lua_pushstring(L, xmlAttribute->Name());
				lua_pushstring(L, xmlAttribute->Value());
				lua_settable(L, -3);
				
			}
			lua_settable(L, -3);
		}
	}
	
	// children
	TiXmlNode *child = xmlNode->FirstChild();
	if (child)
	{
		int childCount = 0;
		for(; child; child = child->NextSibling())
		{
			switch (child->Type())
			{
				case TiXmlNode::DOCUMENT:
					break;
				case TiXmlNode::ELEMENT: 
					// normal element, parse recursive
					lua_newtable(L);
					XML_ParseNode(L, child);
					lua_rawseti(L, -2, ++childCount);
				break;
				case TiXmlNode::COMMENT: break;
				case TiXmlNode::TEXT: 
					// plaintext, push raw
					lua_pushstring(L, child->Value());
					lua_rawseti(L, -2, ++childCount);
				break;
				case TiXmlNode::DECLARATION: break;
				case TiXmlNode::UNKNOWN: break;
			};
		}
		lua_pushstring(L,"n");
		lua_pushnumber(L,childCount);
		lua_settable(L,-3);
	}
}

static int XML_ParseFile (lua_State *L)
{
	const char* fileName = luaL_checkstring(L, 1);
	SDL_RWops* ops = ResourceManager::OpenFile(fileName);
	size_t len;
	void* dataPointer = ResourceManager::ReadFull(&len, ops, 1);
	char* fullDataPointer = (char*)malloc(len + 1);
	fullDataPointer[len] = 0;
	memcpy(fullDataPointer, dataPointer, len);
	free(dataPointer);
	TiXmlDocument doc ( fileName );
	doc.Parse(fullDataPointer);
	lua_newtable(L);
	XML_ParseNode(L, &doc);
	free((void*)fullDataPointer);
	return 1;
}

luaL_Reg registryXML[] =
{
	"load", XML_ParseFile,
	NULL, NULL
};

int MM_Switch ( lua_State* L )
{
	const char* newmode = luaL_checkstring(L, 1);
	SwitchMode(std::string(newmode));
	return 0;
}

int MM_Time ( lua_State* L )
{
	lua_pushnumber(L, GameTime());
	return 1;
}

luaL_Reg registryModeManager[] =
{
	"switch", MM_Switch,
	"time", MM_Time,
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

static colour LoadColour ( lua_State* L, int index )
{
	lua_gettable(L, index);
	float r = 1.0f, g = 1.0f, b = 1.0f, a = 1.0f;
	
	// get red
	lua_getfield(L, -1, "r");
	if (lua_isnumber(L, -1))
	{
		r = lua_tonumber(L, -1);
	}
	lua_pop(L, 1);
	
	// get green
	lua_getfield(L, -1, "g");
	if (lua_isnumber(L, -1))
	{
		g = lua_tonumber(L, -1);
	}
	lua_pop(L, 1);
	
	// get blue
	lua_getfield(L, -1, "b");
	if (lua_isnumber(L, -1))
	{
		b = lua_tonumber(L, -1);
	}
	lua_pop(L, 1);
	
	// get alpha
	lua_getfield(L, -1, "a");
	if (lua_isnumber(L, -1))
	{
		a = lua_tonumber(L, -1);
	}
	lua_pop(L, 1);
	
	lua_pop(L, 1);
	return colour(r, g, b, a);
}

int GFX_DrawText ( lua_State* L )
{
	int nargs = lua_gettop(L);
	const char* text = luaL_checkstring(L, 1);
	const char* font = luaL_checkstring(L, 2);
	float locx = luaL_checknumber(L, 3);
	float locy = luaL_checknumber(L, 4);
	float height = luaL_checknumber(L, 5);
	float rotation = 0.0f;
	if (nargs >= 7)
	{
		rotation = luaL_checknumber(L, 6);
	}
	if (nargs >= 6)
	{
		luaL_argcheck(L, lua_istable(L, 5), 5, "bad colour");
		Graphics::DrawText(text, font, vec2(locx, locy), height, LoadColour(L, 5), rotation);
	}
	else
	{
		Graphics::DrawText(text, font, vec2(locx, locy), height, colour(1.0f, 1.0f, 1.0f, 1.0f), rotation);
	}
	return 0;
}

int GFX_DrawLine ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float x1, y1, x2, y2, width;
	x1 = luaL_checknumber(L, 1);
	y1 = luaL_checknumber(L, 2);
	x2 = luaL_checknumber(L, 3);
	y2 = luaL_checknumber(L, 4);
	width = luaL_checknumber(L, 5);
	if (nargs > 5)
	{
		Graphics::DrawLine(vec2(x1, y1), vec2(x2, y2), width, LoadColour(L, 6));
	}
	else
	{
		Graphics::DrawLine(vec2(x1, y1), vec2(x2, y2), width, colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
	return 0;
}

int GFX_DrawCircle ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float x, y, radius, width;
	x = luaL_checknumber(L, 1);
	y = luaL_checknumber(L, 2);
	radius = luaL_checknumber(L, 3);
	width = luaL_checknumber(L, 4);
	if (nargs > 4)
	{
		Graphics::DrawCircle(vec2(x, y), radius, width, LoadColour(L, 4));
	}
	else
	{
		Graphics::DrawCircle(vec2(x, y), radius, width, colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
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

int GFX_SpriteDimensions ( lua_State* L )
{
	const char* spritesheet;
	spritesheet = luaL_checkstring(L, 1);
	vec2 dims = Graphics::SpriteDimensions(spritesheet);
	lua_pushnumber(L, dims.X());
	lua_pushnumber(L, dims.Y());
	return 2;
}

int GFX_DrawSprite ( lua_State* L )
{
	const char* spritesheet;
	int nargs = lua_gettop(L);
	float loc_x, loc_y, size_x, size_y, rot = 0.0f;
	spritesheet = luaL_checkstring(L, 1);
	loc_x = luaL_checknumber(L, 2);
	loc_y = luaL_checknumber(L, 3);
	size_x = luaL_checknumber(L, 4);
	size_y = luaL_checknumber(L, 5);
	if (nargs > 5)
		rot = luaL_checknumber(L, 6);
	Graphics::DrawSprite(spritesheet, 0, 0, vec2(loc_x, loc_y), vec2(size_x, size_y), rot);
	return 0;
}

int GFX_DrawStarfield ( lua_State* L )
{
	if (lua_gettop(L) > 0)
	{
		float depth = luaL_checknumber(L, 1);
		Graphics::DrawStarfield(depth);
	}
	else
	{
		Graphics::DrawStarfield(0.0f);
	}
	return 0;
}

int GFX_IsCulled ( lua_State* L )
{
	float x = luaL_checknumber(L, 1);
	float y = luaL_checknumber(L, 2);
	float radius = luaL_optnumber(L, 3, 0.0);
	bool isCulled = Graphics::IsCulled(vec2(x, y), radius);
	lua_pushboolean(L, isCulled ? 1 : 0);
	return 1;
}

int GFX_DrawSpriteFromSheet ( lua_State* L )
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
	"draw_sheet_sprite", GFX_DrawSpriteFromSheet,
	"draw_text", GFX_DrawText,
	"draw_line", GFX_DrawLine,
	"draw_circle", GFX_DrawCircle,
	"sprite_dimensions", GFX_SpriteDimensions,
	"draw_starfield", GFX_DrawStarfield,
	"is_culled", GFX_IsCulled,
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

int Sound_CurrentMusic ( lua_State* L )
{
	std::string name = Sound::MusicName();
	lua_pushlstring(L, name.data(), name.length());
	return 1;
}

luaL_Reg registrySound[] =
{
    "play", Sound_Play,
    "play_music", Sound_PlayMusic,
    "stop_music", Sound_StopMusic,
    "current_music", Sound_CurrentMusic,
    NULL, NULL
};

typedef struct Component
{
	LuaScript* script;
};

int CPT_Create ( lua_State* L )
{
	const char* name = luaL_checkstring(L, 1);
	Component* cpt = (Component*)lua_newuserdata(L, sizeof(Component));
	cpt->script = new LuaScript ( std::string("Components/") + name );
	cpt->script->InvokeSubroutine("component_init");
	luaL_getmetatable(L, "Apollo.Component");
	lua_setmetatable(L, -2);
	return 1;
}

int CPT_Cleanup ( lua_State* L )
{
	Component* cpt = (Component*)luaL_checkudata(L, 1, "Apollo.Component");
	if (cpt->script)
	{
		cpt->script->InvokeSubroutine("component_quit");
		delete cpt->script;
		cpt->script = NULL;
	}
	return 0;
}

int CPT_Invoke ( lua_State* L )
{
	Component* cpt = (Component*)luaL_checkudata(L, 1, "Apollo.Component");
	LuaScript* script = cpt->script;
	luaL_argcheck(L, script, 1, "Component already freed");
	const char* routine = luaL_checkstring(L, 2);
	lua_State* componentState = script->RawState();
	int nargs = lua_gettop(L);
	int oldBase = lua_gettop(componentState);
	lua_getglobal(componentState, routine);
	if (!lua_isfunction(componentState, -1))
	{
		char errorBuffer[512];
		sprintf(errorBuffer, "Component has no routine named '%s'", routine);
		lua_pushstring(L, errorBuffer);
		return lua_error(L);
	}
	if (nargs > 2)
	{
		lua_xmove(L, componentState, nargs - 2);
	}
	int rc = lua_pcall(componentState, nargs - 2, LUA_MULTRET, 0);
	if (rc != 0)
	{
		lua_xmove(componentState, L, 1);
		return lua_error(L);
	}
	int newBase = lua_gettop(componentState);
	int nresults = newBase - oldBase;
	lua_xmove(componentState, L, nresults);
	lua_settop(componentState, oldBase);
	return nresults;
}

luaL_Reg registryComponent[] =
{
	"create", CPT_Create,
	"invoke", CPT_Invoke,
	NULL, NULL
};

luaL_Reg registryObjectComponent[] =
{
	"invoke", CPT_Invoke,
	"__gc", CPT_Cleanup,
	NULL, NULL
};

int luaopen_component ( lua_State* L )
{
	luaL_newmetatable(L, "Apollo.Component");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, registryObjectComponent);
	luaL_register(L, "component", registryComponent);
	return 1;
}

int XAR_Open ( lua_State* L )
{
	const char* filename = luaL_checkstring(L, 1);
	XarFile* file = new XarFile ( filename );
	lua_pushlightuserdata(L, (void*)file);
	luaL_getmetatable(L, "Apollo.XarFile");
	lua_setmetatable(L, -2);
	return 1;
}

int XAR_Close ( lua_State* L )
{
	XarFile* file = (XarFile*)luaL_checkudata(L, 1, "Apollo.XarFile");
	assert(file);
	delete file;
	return 0;
}

int XAR_FileExists ( lua_State* L )
{
	XarFile* file = (XarFile*)luaL_checkudata(L, 1, "Apollo.XarFile");
	assert(file);
	const char* path = luaL_checkstring(L, 2);
	lua_pushboolean(L, file->FileExists(path) ? 1 : 0);
	return 1;
}

int XAR_Read ( lua_State* L )
{
	XarFile* file = (XarFile*)luaL_checkudata(L, 1, "Apollo.XarFile");
	assert(file);
	const char* path = luaL_checkstring(L, 2);
	SDL_RWops* rwops = file->OpenFile(path);
	if (!rwops)
	{
		lua_pushnil(L);
		return 1;
	}
	size_t len;
	void* data = ResourceManager::ReadFull(&len, rwops, 1);
	lua_pushlstring(L, (const char*)data, len);
	free(data);
	return 1;
}

luaL_Reg registryXAR [] =
{
	"open", XAR_Open,
	NULL, NULL
};

luaL_Reg registryObjectXAR [] =
{
	"__gc", XAR_Close,
	"contains", XAR_FileExists,
	"read", XAR_Read,
	NULL, NULL
};

int luaopen_xar ( lua_State* L )
{
	luaL_newmetatable(L, "Apollo.XarFile");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, registryObjectXAR);
	luaL_register(L, "xar", registryXAR);
	return 1;
}

int import ( lua_State* L )
{
	const char* modulename = luaL_checkstring(L, 1);
	LuaScript::RawImport(L, modulename);
	return 0;
}

}

void __LuaBind ( lua_State* L )
{
	lua_pushcfunction(L, import);
	lua_setglobal(L, "import");
	lua_cpcall(L, luaopen_component, NULL);
	luaL_register(L, "xml", registryXML);
	luaL_register(L, "mode_manager", registryModeManager);
    luaL_register(L, "resource_manager", registryResourceManager);
    luaL_register(L, "graphics", registryGraphics);
    luaL_register(L, "sound", registrySound);
	luaL_register(L, "net_client", registryNetClient);
	luaL_register(L, "net_server", registryNetServer);
	lua_cpcall(L, luaopen_physics, NULL);
}
