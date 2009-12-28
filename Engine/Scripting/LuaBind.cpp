#include <string.h>
#include "Apollo.h"
#include "Scripting.h"
#include "Utilities/ResourceManager.h"
#include "Sound/Sound.h"
#include "Graphics/Graphics.h"
#include "Graphics/TextRenderer.h"
#include "Preferences.h"
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
		luaL_argerror(L, narg, "must pass a vector table (not a table)");
	}
	float x, y;
	lua_getfield(L, narg, "x");
	if (!lua_isnumber(L, -1))
	{
		luaL_argerror(L, narg, "must pass a vector table (bad x value)");
	}
	x = lua_tonumber(L, -1);
	lua_getfield(L, narg, "y");
	if (!lua_isnumber(L, -1))
	{
		luaL_argerror(L, narg, "must pass a vector table (bad y value)");
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
	object->Init();
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
	//	obj->pob = NULL;
		return 0;
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
	PHYS_Object* obj1 = (PHYS_Object*)luaL_checkudata(L, 1, "Apollo.PhysicsObject");
	if (obj1->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	PHYS_Object* obj2 = (PHYS_Object*)luaL_checkudata(L, 2, "Apollo.PhysicsObject");
	if (obj2->pob == NULL)
	{
		lua_pushliteral(L, "cannot access properties on destroyed physics object");
		return lua_error(L);
	}
	int projectile = luaL_checknumber(L, 3);
	bool collide = false;
	if (projectile == 1)
	{
		collide = obj1->pob->Collision(obj1->pob->position, obj2->pob->position, obj1->pob->collisionRadius);
	} else
	{
		collide = obj1->pob->Collision(obj1->pob->position, obj2->pob->position, obj1->pob->collisionRadius, obj2->pob->collisionRadius);
	}
	lua_pushboolean(L, collide);
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

/**
 * @page lua_physics The Lua Physics Registry
 * This page contains information about the Lua physics registry.
 *
 * This registry contains functions related to utilizing Apollo's physics
 * engine. In Lua, they are all called like so: "physics.function_name()" (for
 * example: "open" becomes "physics.open(num)").
 * 
 * @section open
 * Opens a physics system with a given amount of "resistance".\n
 * Parameters:\n
 * resistance - The resistance to movement; for space, should be 0.
 * 
 * @section close
 * Closes the current physics system. This function has no parameters.
 * 
 * @section update
 * Updates the current physics system based upon a small timestep (within Xsera,
 * a variable named
 * 'dt' is used to represent the change in time (delta time) from one frame to
 * another).\n
 * Parameters:\n
 * dt - Change in time between updates.
 * 
 * @section new_object
 * Creates a new physics object with properties like velocity, position, angular
 * velocity, and more. To see what properties physics objects have, please visit
 * the @ref lua_physics_object page. This function has no parameters.
 * 
 * @section destroy_object
 * Destroys a physics object. This function has no parameters.
 * 
 * @section object_from_id
 * Takes in an ID and returns the physics object with that ID, if one exists.\n
 * Parameters:\n
 * id - The ID of the requested physics object\n
 * Returns:\n
 * object - The physics object, if it exists under given ID.\n
 * nil - If there is no physics object for the given ID, nil is returned.
 * 
 * @section collisions
 * Given two objects and whether or not the second object is a bullet, this will
 * tell you if there is a collision.\n
 * Parameters:\n
 * obj1 - The first object\n
 * obj2 - The second object\n
 * projectile - boolean of whether the second object is a projectile (or other
 * object with insignificant radius) or not\n
 * Returns:\n
 * boolean - True if there is a collision, false if there is not.
 * 
 * @todo Create the @ref lua_physics_object page, referenced in @ref new_object (and possibly others)
 */

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
//	"__gc", PHYS_DestroyObject,
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

int Pref_Get ( lua_State* L )
{
	const char* arg = luaL_checkstring(L, 1);
	std::string push = Preferences::Get(arg, "nil");
//	lua_pushstring(L, push);
	if (push == "true") // [HARDCODED]
	{
		lua_pushboolean(L, true);
	} else
	{
		lua_pushboolean(L, false);
	}
	return 1;
}

/**
 * @page lua_preferences The Lua Preferences Registry
 * This page contains information about the Lua preferences registry.
 *
 * This registry currently only contains one function, used for retrieving
 * preferences. In Lua, it is called called like so: "preferences.get(name)".
 * 
 * @section xml_get get
 * Finds and returns a particular preference.\n
 * Parameters:\n
 * name - The name of the preference to be fetched.\n
 * Returns:\n
 * boolean - The status of the requested preference.
 * 
 * @todo Make @ref xml_get un-hardcoded.
 */

luaL_Reg registryPreferences[] = 
{
	"get", Pref_Get,
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

/**
 * @page lua_net_server The Lua Net Server Registry
 * This page contains information about the Lua net server registry.
 *
 * This registry contains functions related to running a multiplayer server. In
 * Lua, they are all called like so: "net_server.function_name()" (for example:
 * "startup" becomes "net_server.startup(port, password)").
 * 
 * Note: Somebody else will need to complete this registry, I don't know
 * anything about it right now.
 * 
 * @section startup
 * 
 * @section shutdown
 * 
 * @section running
 * 
 * @section client_count
 * 
 * @section kill
 * 
 * @section net_server_connected connected
 * 
 * @section net_server_send send
 * 
 * @section broadcast
 * 
 * @section net_server_get get
 * 
 * @todo Complete the @ref lua_net_server registry.
 * 
 */

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
			lua_pushstring(L, "attr");
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
		lua_pushstring(L, "n");
		lua_pushnumber(L, childCount);
		lua_settable(L, -3);
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

/**
 * @page lua_xml The Lua XML Registry
 * This page contains information about the Lua XML registry.
 *
 * This registry currently only contains one function. In Lua, it is called 
 * called like so: "xml.load(file)".
 * 
 * @section load
 * Loads and parses an XML file\n
 * Parameters:\n
 * name - The name of the mode that the game is currently in.\n
 * Returns:\n
 * A table with the contents of the file in it.\n
 * Note: This function is deprecated. It will likely not be used in Xsera, and
 * is not fully functional.
 */

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

int MM_Query ( lua_State* L )
{
	lua_pushstring(L, QueryMode());
	return 1;
}

int MM_Release ( lua_State* L )
{
	#ifdef NDEBUG
		lua_pushboolean(L, true);
		return 1;
	#else
		lua_pushboolean(L, false);
		return 1;
	#endif
}

/**
 * @page lua_mode_manager The Lua Mode Manager Registry
 * This page contains information about the Lua mode manager registry.
 *
 * This small registry contains functions for dealing with modes. Modes are the
 * states in which Lua runs, containing functions triggered by certain states of
 * Apollo (like mouse movement, keyboard presses, etc). In Lua, they are all
 * called like so: "mode_manager.function_name()" (for example: "switch" becomes
 * "mode_manager.switch(mode)").
 * 
 * @section switch
 * Switches the game mode. If the mode cannot be switched to the given name, an
 * error occurs.\n
 * Parameters:\n
 * mode - the name of the mode you want to switch to (without the suffix
 * ".lua"). For example, to switch to "MainMenu.lua", enter "MainMenu" for the
 * parameter.
 * 
 * @section time
 * Gives the game's time, in seconds, since the game's start. This function has
 * no parameters.\n
 * Returns:\n
 * number - The amount of seconds (accurate to miliseconds) since the game's
 * start.
 * 
 * @section query
 * Returns the game's current mode. This function has no parameters.\n
 * Returns:\n
 * string - The name of the mode that the game is currently in.
 * 
 * @section is_release
 * Returns the game's current build mode. This function has no parameters.\n
 * Returns:\n
 * bool - True if the game's current build is a release build, false if not.
 */

luaL_Reg registryModeManager[] =
{
	"switch", MM_Switch,
	"time", MM_Time,
	"query", MM_Query,
	"is_release", MM_Release,
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

/**
 * @page lua_resource_manager The Lua Resource Manager Registry
 * This page contains information about the Lua resource manager registry.
 *
 * This small registry contains a few simple tools for manipulating files. In
 * Lua, they are all called like so: "resource_manager.function_name()" (for
 * example: "file_exists" becomes "resource_manager.file_exists(file)").
 * 
 * @section file_exists
 * Ensures that the given file exists, then returns a boolean of whether it does
 * or not.\n
 * Parameters:\n
 * file - The name of the file\n
 * Returns:\n
 * Boolean - true if file exists, false if it does not\n
 * 
 * @section load
 * Loads a given file. Will return error statement along with error if the file
 * does not exist or cannot be opened.\n
 * Parameters:\n
 * file - The name of the file to be loaded\n
 * Returns:\n
 * data - If the load is successful, data will be returned from the file
 * literal - If the load is unsuccessful, a string will be returned ("file not
 * found")
 * 
 * @section write
 * Writes to a given file. No error checking implemented.
 * Parameters:\n
 * file - The name of the file\n
 * data - The data to be written to the file\n
 */

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
	float r = 1.0f, g = 1.0f, b = 1.0f, a = 1.0f;
	lua_getfield(L, index, "r");
	r = luaL_checknumber(L, -1);
	lua_getfield(L, index, "g");
	g = luaL_checknumber(L, -1);
	lua_getfield(L, index, "b");
	b = luaL_checknumber(L, -1);
	lua_getfield(L, index, "a");
	a = luaL_checknumber(L, -1);
	return colour(r, g, b, a);
}

int GFX_DrawText ( lua_State* L )
{
	int nargs = lua_gettop(L);
	const char* text = luaL_checkstring(L, 1);
	const char* font = luaL_checkstring(L, 2);
	const char* justify = luaL_checkstring(L, 3);
	vec2 location = luaL_checkvec2(L, 4);
	float height = luaL_checknumber(L, 5);
	float rotation = 0.0f;
	if (nargs >= 7)
	{
		rotation = luaL_checknumber(L, 7);
	}
	if (nargs >= 6)
	{
		luaL_argcheck(L, lua_istable(L, 6), 6, "bad colour");
		Graphics::DrawTextSDL(text, font, justify, location, height, LoadColour(L, 6), rotation);
	}
	else
	{
		Graphics::DrawTextSDL(text, font, justify, location, height, colour(1.0f, 1.0f, 1.0f, 1.0f), rotation);
	}
	return 0;
}

int GFX_TextLength (lua_State* L )
{
	const char* text = luaL_checkstring(L, 1);
	const char* font = luaL_checkstring(L, 2);
	float height = luaL_checknumber(L, 3);
	vec2 dims = Graphics::TextRenderer::TextDimensions(font, text);
	dims = dims * (height / dims.Y());
	lua_pushnumber(L, dims.X());
	return 1;
}

int GFX_DrawLine ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float width;
	vec2 point1 = luaL_checkvec2(L, 1);
	vec2 point2 = luaL_checkvec2(L, 2);
	width = luaL_checknumber(L, 3);
	if (nargs > 3)
	{
		Graphics::DrawLine(point1, point2, width, LoadColour(L, 4));
	}
	else
	{
		Graphics::DrawLine(point1, point2, width, colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
	return 0;
}

int GFX_DrawLightning ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float width, chaos;
	bool tailed;
	vec2 point1 = luaL_checkvec2(L, 1);
	vec2 point2 = luaL_checkvec2(L, 2);
	width = luaL_checknumber(L, 3);
	chaos = luaL_checknumber(L, 4);
	tailed = lua_tonumber(L, 5);
	if (nargs > 5)
	{
		Graphics::DrawLightning(point1, point2, width, chaos, LoadColour(L, 6), tailed);
	}
	else
	{
		Graphics::DrawLightning(point1, point2, width, chaos, colour(0.93f, 0.88f, 1.0f, 1.0f), tailed);
	}
	return 0;
}

int GFX_DrawBox ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float top, left, bottom, right, width;
	top = luaL_checknumber(L, 1);
	left = luaL_checknumber(L, 2);
	bottom = luaL_checknumber(L, 3);
	right = luaL_checknumber(L, 4);
	width = luaL_checknumber(L, 5);
	if (nargs > 5)
	{
		Graphics::DrawBox(top, left, bottom, right, width, LoadColour(L, 6));
	}
	else
	{
		Graphics::DrawBox(top, left, bottom, right, width, colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
	return 0;
}

int GFX_DrawRadarTriangle ( lua_State* L )
{
	int nargs = lua_gettop(L);
	vec2 coordinates = luaL_checkvec2(L, 1);
	float varsize = luaL_checknumber(L, 2);
	if (nargs > 2)
	{
		Graphics::DrawTriangle(vec2(coordinates.X(), coordinates.Y() + varsize),
							   vec2(coordinates.X() - varsize, coordinates.Y() - varsize),
							   vec2(coordinates.X() + varsize, coordinates.Y() - varsize),
							   LoadColour(L, 3));
	}
	else
	{
		Graphics::DrawTriangle(vec2(coordinates.X(), coordinates.Y() + varsize),
							   vec2(coordinates.X() - varsize, coordinates.Y() - varsize),
							   vec2(coordinates.X() + varsize, coordinates.Y() - varsize),
							   colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
	return 0;
}

int GFX_DrawRadarPlus ( lua_State* L )
{
	int nargs = lua_gettop(L);
	vec2 coordinates = luaL_checkvec2(L, 1);
	float varsize = luaL_checknumber(L, 2);
	if (nargs > 2)
	{
		Graphics::DrawBox(coordinates.Y() + varsize, coordinates.X() - 0.3 * varsize, coordinates.Y() - varsize, coordinates.X() + 0.3 * varsize, 0, LoadColour(L, 3));
		Graphics::DrawBox(coordinates.Y() + 0.3 * varsize, coordinates.X() - varsize, coordinates.Y() - 0.3 * varsize, coordinates.X() + varsize, 0, LoadColour(L, 3));
	}
	else
	{
		Graphics::DrawBox(coordinates.Y() + varsize, coordinates.X() - 0.3 * varsize, coordinates.Y() - varsize, coordinates.X() + 0.3 * varsize, 0, colour(0, 1, 0, 1));
		Graphics::DrawBox(coordinates.Y() + 0.3 * varsize, coordinates.X() - varsize, coordinates.Y() - 0.3 * varsize, coordinates.X() + varsize, 0, colour(0, 1, 0, 1));
	}
	return 0;
}

int GFX_DrawRadarBox ( lua_State* L )
{
	int nargs = lua_gettop(L);
	vec2 coordinates = luaL_checkvec2(L, 1);
	float varsize = luaL_checknumber(L, 2);
	if (nargs > 2)
	{
		Graphics::DrawBox(coordinates.Y() + varsize, coordinates.X() - varsize, coordinates.Y() - varsize, coordinates.X() + varsize, 0, LoadColour(L, 3));
	}
	else
	{
		Graphics::DrawBox(coordinates.Y() + varsize, coordinates.X() - varsize, coordinates.Y() - varsize, coordinates.X() + varsize, 0, colour(0, 1, 0, 1));
	}
	return 0;
}

int GFX_DrawRadarDiamond ( lua_State* L )
{
	int nargs = lua_gettop(L);
	vec2 coordinates = luaL_checkvec2(L, 1);
	float varsize = luaL_checknumber(L, 2);
	if (nargs > 2)
	{
		Graphics::DrawDiamond(coordinates.Y() + varsize, coordinates.X() - varsize, coordinates.Y() - varsize, coordinates.X() + varsize, LoadColour(L, 3));
	}
	else
	{
		Graphics::DrawDiamond(coordinates.Y() + varsize, coordinates.X() - varsize, coordinates.Y() - varsize, coordinates.X() + varsize, colour(0, 1, 0, 1));
	}
	return 0;
}

int GFX_DrawObject3DAmbient ( lua_State* L )
{
	std::string object = luaL_checkstring(L, 1);
	vec2 location = luaL_checkvec2(L, 2);
	colour col = LoadColour(L, 3);
	float scale = luaL_checknumber(L, 4);
	float angle = luaL_checknumber(L, 5);
	float bank = luaL_optnumber(L, 6, 0.0);
	Graphics::DrawObject3DAmbient(object, location, col, scale, angle, bank);
	return 0;
}

int GFX_DrawParticles ( lua_State* L )
{
	Graphics::DrawParticles();
	return 0;
}

int GFX_ClearParticles ( lua_State* L )
{
	Graphics::ClearParticles();
}

int GFX_AddParticles ( lua_State* L )
{
	const char* name = luaL_checkstring(L, 1);
	unsigned long pcount = luaL_checkinteger(L, 2);
	vec2 location = luaL_checkvec2(L, 3);
	vec2 velocity = luaL_checkvec2(L, 4);
	vec2 velocityVar = luaL_checkvec2(L, 5);
	vec2 acc = luaL_checkvec2(L, 6);
	float size = luaL_checknumber(L, 7);
	float lifetime = luaL_checknumber(L, 8);
	Graphics::AddParticles(name, pcount, location, velocity, velocityVar, acc, size, lifetime);
	return 0;
}

int GFX_DrawCircle ( lua_State* L )
{
	int nargs = lua_gettop(L);
	float radius, width;
	vec2 location = luaL_checkvec2(L, 1);
	radius = luaL_checknumber(L, 2);
	width = luaL_checknumber(L, 3);
	if (nargs > 3)
	{
		Graphics::DrawCircle(location, radius, width, LoadColour(L, 4));
	}
	else
	{
		Graphics::DrawCircle(location, radius, width, colour(0.0f, 1.0f, 0.0f, 1.0f));
	}
	return 0;
}

int GFX_DrawImage ( lua_State* L )
{
	const char* imgName;
	imgName = luaL_checkstring(L, 1);
	vec2 location = luaL_checkvec2(L, 2);
	vec2 size = luaL_checkvec2(L, 3);
	Graphics::DrawImage(imgName, location, size);
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
	float rot = 0.0f;
	colour col;
	spritesheet = luaL_checkstring(L, 1);
	vec2 location = luaL_checkvec2(L, 2);
	vec2 size = luaL_checkvec2(L, 3);
	if (nargs > 3)
	{
		rot = luaL_checknumber(L, 4);
	}
	if (nargs > 4)
	{
		Graphics::DrawSprite(spritesheet, 0, 0, location, size, rot, LoadColour(L, 5));
	}
	else
	{
		Graphics::DrawSprite(spritesheet, 0, 0, location, size, rot, colour(1.0f, 1.0f, 1.0f, 1.0f));
	}
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
	vec2 location = luaL_checkvec2(L, 1);
	float radius = luaL_optnumber(L, 2, 0.0);
	bool isCulled = Graphics::IsCulled(location, radius);
	lua_pushboolean(L, isCulled ? 1 : 0);
	return 1;
}

int GFX_DrawSpriteFromSheet ( lua_State* L )
{
	const char* spritesheet;
	int nargs = lua_gettop(L);
	float rot = 0.0f;
	spritesheet = luaL_checkstring(L, 1);
	vec2 sheet = luaL_checkvec2(L, 2);
	vec2 location = luaL_checkvec2(L, 3);
	vec2 size = luaL_checkvec2(L, 4);
	if (nargs > 4)
	{
		rot = luaL_checknumber(L, 5);
	}
	if (nargs > 5)
	{
		Graphics::DrawSprite(spritesheet, sheet.X(), sheet.Y(), location, size, rot, LoadColour(L, 6));
	}
	else
	{
		Graphics::DrawSprite(spritesheet, sheet.X(), sheet.Y(), location, size, rot, colour(1.0f, 1.0f, 1.0f, 1.0f));
	}
	return 0;
}

int GFX_BeginWarp ( lua_State* L )
{
	float magnitude = luaL_checknumber(L, 1);
	float angle = luaL_checknumber(L, 2);
	float scale = luaL_checknumber(L, 3);
	Graphics::BeginWarp(magnitude, angle, scale);
	return 0;
}

int GFX_EndWarp ( lua_State* L )
{
	Graphics::EndWarp();
	return 0;
}

/**
 * @page lua_graphics The Lua Graphics Registry
 * This page contains information about the Lua graphics registry.
 *
 * This registry contains all drawing mechanisms for Lua, along with some
 * drawing manipulation functions. In Lua, they are all called like so:
 * "graphics.function_name()" (for example: "begin_frame" becomes
 * "graphics.begin_frame()").
 * 
 * @section frame_and_camera Frame and Camera
 * 
 * @subsection begin_frame
 * Must be called before any graphics routines are called. It has no parameters.
 * 
 * @subsection end_frame
 * Must be called after any graphics routines are called. It has no parameters.
 * 
 * @subsection set_camera
 * Sets the bounds of the camera. It requires arguments for the left, bottom,
 * right, and top of the camera, respectively.\n
 * Parameters:\n
 * left - The left, or lower-x bound, of the screen.\n
 * bottom - The bottom, or lower-y bound, of the screen.\n
 * right - The right, or upper-x bound, of the screen.\n
 * top - The top, or upper-y bound, of the screen.\n
 * 
 * @section sprites Sprites
 * 
 * @subsection draw_image
 * Draws an "image", which is functionally different from a sprite. In general,
 * a sprite has rotational capabilities and / or multiple frames, like most
 * ships, where an image does not, like panels on the sides of the screen.\n
 * Parameters:\n
 * imgname - The name of the image to be drawn\n
 * loc_x - The x location of where the center of the image should be\n
 * loc_y - The y location of where the center of the image should be\n
 * size_x - The x size, in pixels, of the image\n
 * size_y - The y size, in pixels, of the image - note that size_x and size_y
 * should be in the same ratio of x:y as the original image, or stretching may
 * occur.\n
 * rot - The rotation of the image, in radians. Optional parameter.\n
 * colour - The colour to be applied to the image, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_sprite
 * Draws a "sprite", which is functionally different from an image. In general,
 * a sprite has rotational capabilities and / or multiple frames, like a ship,
 * where an image does not, like panels on the sides of the screen.
 * Parameters:\n
 * spritesheet - The name of the file containing the sprites\n
 * loc_x - The x location of where the center of the sprite should be\n
 * loc_y - The y location of where the center of the sprite should be\n
 * size_x - The x size, in pixels, of the sprite\n
 * size_y - The y size, in pixels, of the sprite - note that size_x and size_y
 * should be in the same ratio of x:y as the original image, or stretching may
 * occur.\n
 * rot - The rotation of the sprite, in radians. Determines which sprite is
 * drawn\n
 * colour - The colour to be applied to the sprite, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_sheet_sprite
 * Draws a given sprite from within a sprite sheet.\n
 * Parameters:\n
 * spritesheet - The name of the sprite sheet to be drawn\n
 * sheet_x - ?\n
 * sheet_y - ?\n
 * loc_x - The x location of where the center of the sprite should be\n
 * loc_y - The y location of where the center of the sprite should be\n
 * size_x - The x size, in pixels, of the sprite\n
 * size_y - The y size, in pixels, of the sprite - note that size_x and size_y
 * should be in the same ratio of x:y as the original image, or stretching may
 * occur.\n
 * rot - The rotation of the sprite, in radians. Determines which sprite is
 * drawn\n
 * colour - The colour to be applied to the sprite, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * @todo define sheet_x and sheet_y for @ref draw_sheet_sprite
 * @todo add in table reading for colours to @ref draw_sheet_sprite
 * 
 * @subsection sprite_dimensions
 * Returns the dimensions for a given sprite.\n
 * Parameters:\n
 * spritesheet - The sprite sheet to check the dimensions of.\n
 * Returns:\n
 * x - The x size of one sprite on the sheet\n
 * y - The y size of one sprite on the sheet
 * 
 * @subsection draw_starfield
 * Draws a starfield at the given depth. Draw multiple starfields at varying
 * depths to give them a parallax feel.
 * Parameters:\n
 * depth - How deep the starfield should appear. Optional parameter (default is
 * 0).
 * 
 * @section drawing_text Drawing Text
 * 
 * @subsection draw_text
 * Given a position, size, font, and some text, (and optionally a rotation and
 * some colour) this function will draw text to the screen with those
 * specifications. If not given rotation or colour, this function will default
 * to zero degrees rotation and white text.\n
 * Parameters:\n
 * text - The text to be displayed on the screen\n
 * font - The font for the text to be drawn in\n
 * justify - One of "left", "right", or "center", the justification of the text.
 * If misspelled or missing, defaults to "center".\n
 * loc_x - The x coordinate of the text. Justification revolves around the
 * position of this component.\n
 * loc_y - The y coordinate of the text.\n
 * height - The size of the font to be displayed.\n
 * rotation - Rotation clockwise from the viewer's perspective, in radians.\n
 * colour - The colour to be applied to the text, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection text_length
 * Given a size, font, and some text, this function will output how long this
 * text will be on the screen.\n
 * Parameters:\n
 * text - The text to be sized up\n
 * font - The font being used for the text\n
 * height - the size of the font
 * 
 * @section drawing_basic_objects Drawing Basic Objects
 * 
 * @subsection draw_line
 * Draws a basic line.\n
 * Parameters:\n
 * x1 - The x coordinate of the starting point.\n
 * y1 - The y coordinate of the starting point.\n
 * x2 - The x coordinate of the ending point.\n
 * y2 - The y coordinate of the ending point.\n
 * width - The thickness of the line in pixels.\n
 * colour - The colour to be applied to the line, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 *
 * @subsection draw_box
 * Draws a basic box.\n
 * Parameters:\n
 * top - The y coordinate of the top of the box.\n
 * left - The x coordinate of the left of the box.\n
 * bottom - The y coordinate of the bottom of the box.\n
 * right - The x coordinate of the right of the box.\n
 * width - The thickness of the line surrounding the boxin pixels. Use 0 for no
 * line.\n
 * colour - The colour to be applied to the box, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_circle
 * Draws a "circle", which is really just a series of lines approximating a
 * circle.\n
 * x - The x coordinate of the center of the circle.\n
 * y - The y coordinate of the center of the circle.\n
 * radius - The radius of the circle.\n
 * width - The width of the lines comprising the circle.\n
 * colour - The colour to be applied to the circle, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @section drawing_radar_objects Drawing 'Radar' Objects
 * 
 * @subsection draw_rtri
 * Draws a triangle - generally used as a placeholder for objects when zoomed
 * out beyond 1:8 camera ratios. (short for "radar triangle")\n
 * x - The x coordinate of the center of the triangle.\n
 * y - The y coordinate of the center of the triangle.\n
 * varsize - The size of the triangle, according to the object's data.\n
 * colour - The colour to be applied to the triangle, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_rplus
 * Draws a plus sign - generally used as a placeholder for objects when zoomed
 * out beyond 1:8 camera ratios (short for "radar plus").\n
 * x - The x coordinate of the center of the plus.\n
 * y - The y coordinate of the center of the plus.\n
 * varsize - The size of the plus, according to the object's data.\n
 * colour - The colour to be applied to the plus, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_rbox
 * Draws a square - generally used as a placeholder for objects when zoomed out
 * beyond 1:8 camera ratios (short for "radar box").\n
 * x - The x coordinate of the center of the box.\n
 * y - The y coordinate of the center of the box.\n
 * varsize - The size of the box, according to the object's data.\n
 * colour - The colour to be applied to the box, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection draw_rdia
 * Draws a diamond - generally used as a placeholder for objects when zoomed out
 * beyond 1:8 camera ratios (short for "radar diamond").\n
 * x - The x coordinate of the center of the diamond.\n
 * y - The y coordinate of the center of the diamond.\n
 * varsize - The size of the diamond, according to the object's data.\n
 * colour - The colour to be applied to the diamond, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * 
 * @subsection is_culled
 * Checks to see if a particular circle is entirely outside of the vision of the
 * camera.\n
 * Parameters:\n
 * x - The x coordinate of the center of the circle.\n
 * y - The y coordinate of the center of the circle.\n
 * radius - The radius of the circle.\n
 * Returns:\n
 * isCulled - If the circle is entirely off the screen, true. Otherwise false.
 * 
 * @section Special Effects
 * This section contains information about special effects like particles and 
 * lightning.
 *
 * @subsection draw_lightning
 * Draws lightning effects needed for certain weapons.\n
 * x1 - The x coordinate of the starting point.\n
 * y1 - The y coordinate of the starting point.\n
 * x2 - The x coordinate of the ending point.\n
 * y2 - The y coordinate of the ending point.\n
 * width - The thickness of the lightning in pixels.\n
 * chaos - How jagged the lightning appears. 0 gives perfectly straight
 * lightning.\n
 * tailed - If tailed is true, the lightning tapers down to the endpoint. If
 * tailed is false, the lightning does not taper down to the endpoint but
 * instead ends somewhere around the endpoint.\n
 * colour - The colour to be applied to the lightning, in the form of a table:\n
 *    t = { r = red_val, b = blue_val, g = green_val, a = alpha_val }\n
 * where the colour values are between 0.0 and 1.0. (optional)
 * @todo figure out "chaos" and "tailed" properties of @ref draw_lightning
 * 
 * @subsection add_particles
 * 
 * @subsection draw_particles
 * 
 * @subsection clear_particles
 * 
 * @subsection begin_warp
 * 
 * @subsection end_warp
 * 
 * @subsection draw_3d_ambient
 * 
 * @todo Document @ref add_particles, @ref draw_particles, @ref clear_particles, @ref begin_warp, and @ref end_warp
 * @todo Fix documentation @ref draw_image and @ref draw_sprite to better define sprites/images.
 */

luaL_Reg registryGraphics[] =
{
	"begin_frame", GFX_BeginFrame,
	"end_frame", GFX_EndFrame,
	"set_camera", GFX_SetCamera,
	"draw_image", GFX_DrawImage,
	"draw_sprite", GFX_DrawSprite,
	"draw_sheet_sprite", GFX_DrawSpriteFromSheet,
	"sprite_dimensions", GFX_SpriteDimensions,
	"draw_starfield", GFX_DrawStarfield,
	"draw_text", GFX_DrawText,
	"text_length", GFX_TextLength,
	"draw_line", GFX_DrawLine,
	"draw_box", GFX_DrawBox,
	"draw_circle", GFX_DrawCircle,
	"draw_rtri", GFX_DrawRadarTriangle,
	"draw_rplus", GFX_DrawRadarPlus,
	"draw_rbox", GFX_DrawRadarBox,
	"draw_rdia", GFX_DrawRadarDiamond,
	"is_culled", GFX_IsCulled,
	"draw_lightning", GFX_DrawLightning,
	"add_particles", GFX_AddParticles,
	"draw_particles", GFX_DrawParticles,
	"clear_particles", GFX_ClearParticles,
	"begin_warp", GFX_BeginWarp,
	"end_warp", GFX_EndWarp,
	"draw_3d_ambient", GFX_DrawObject3DAmbient,
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
    Sound::PlaySoundSDL (sound, volume, pan);
    return 0;
}

int Sound_Preload ( lua_State* L )
{
	const char* sound = luaL_checkstring(L, 1);
	Sound::Preload(sound);
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

/**
 * @page lua_sound The Lua Sound Registry
 * This page contains information about the Lua sound registry.
 *
 * This registry contains all music control mechanisms for Lua, along with a
 * function for playing sound effects. In Lua, they are all called like so:
 * "sound.function_name()" (for example: "play" becomes "sound.play(file)").
 * 
 * @section sounds Sounds
 * 
 * @subsection play
 * Plays the specified sound effect.\n
 * Parameters:\n
 * sound - The name of the sound file to be played.
 * 
 * @subsection preload
 * Preloads the specified sound effect for quicker access in-game.\n
 * Parameters:\n
 * sound - The name of the sound file to be preloaded.
 * 
 * @section music Music
 * 
 * @subsection play_music
 * Plays the given song. Songs can be stopped on command, and their names can be
 * queried.\n
 * Parameters:\n
 * song - the name of the song to be played.
 * 
 * @subsection stop_music
 * Stops the current song. This function has no parameters.
 * 
 * @subsection current_music
 * Queries the name of the song currently playing. This function has no
 * parameters.\n
 * Return:\n
 * song - the name of the currently playing song.
 */

luaL_Reg registrySound[] =
{
    "play", Sound_Play,
    "preload", Sound_Preload,
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

int mouse_position ( lua_State* L )
{
	vec2 mouse = Input::MousePosition();
	lua_pushnumber(L, mouse.X());
	lua_pushnumber(L, mouse.Y());
	return 2;
}

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

/**
 * @page all_lua_bindings All LuaBind Registries
 * This page contains information about all Lua registries, along with links to
 * the pages describing them.
 * 
 * @ref lua_xml \n
 * This registry currently only contains one function (load). It is used to load
 * XML data from files.
 * 
 * @ref lua_mode_manager \n
 * This small registry contains functions for dealing with modes. Modes are the
 * states in which Lua runs, containing functions triggered by certain states of
 * Apollo (like mouse movement, keyboard presses, etc).
 * 
 * @ref lua_resource_manager \n
 * This small registry contains a few simple tools for manipulating files.
 * 
 * @ref lua_graphics \n
 * This registry contains all drawing mechanisms for Lua, along with some
 * drawing manipulation functions.
 * 
 * @ref lua_sound \n
 * This registry contains all music control mechanisms for Lua, along with a
 * function for playing sound effects.
 * 
 * @ref lua_net_client \n
 * This registry contains functions related to playing on a multiplayer server.
 * 
 * @ref lua_net_server \n
 * This registry contains functions related to hosting a multiplayer server.
 * 
 * @ref lua_preferences \n
 * This registry currently only contains one function, used for retrieving
 * preferences.
 */

void __LuaBind ( lua_State* L )
{
	lua_pushcfunction(L, import);
	lua_setglobal(L, "import");
	lua_pushcfunction(L, mouse_position);
	lua_setglobal(L, "mouse_position");
	lua_cpcall(L, luaopen_component, NULL);
	luaL_register(L, "xml", registryXML);
	luaL_register(L, "mode_manager", registryModeManager);
    luaL_register(L, "resource_manager", registryResourceManager);
    luaL_register(L, "graphics", registryGraphics);
    luaL_register(L, "sound", registrySound);
	luaL_register(L, "preferences", registryPreferences);
	luaL_register(L, "net_server", registryNetServer);
	lua_cpcall(L, luaopen_physics, NULL);
}
