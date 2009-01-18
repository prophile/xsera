#include "Scripting/Scripting.h"
#include "TestHarness.h"

extern "C"
{
#include "lua.h"
}

namespace TestHarness
{

LuaScript* script = NULL;

void Init ()
{
	if (!script)
	{
		script = new LuaScript ( "Tests/Tests" );
	}
}

bool InvokeTest ( const std::string& testName, const std::vector<std::string>& testParameters )
{
	Init();
	lua_State* L = script->RawState();
	lua_getglobal(L, ("test_" + testName).c_str());
	if (!lua_isnoneornil(L, -1))
	{
		if (!lua_isfunction(L, -1))
		{
			printf("Test %s FAILED: test is not a function!\n", testName.c_str());
			return false;
		}
		int nargs = 0;
		for (std::vector<std::string>::const_iterator iter = testParameters.begin(); iter != testParameters.end(); iter++)
		{
			lua_pushlstring(L, iter->data(), iter->length());
			nargs++;
		}
		int rc = lua_pcall(L, nargs, 0, 0);
		if (rc == 0)
		{
			printf("Test %s PASSED!\n", testName.c_str());
			return true;
		}
		else if (rc == LUA_ERRRUN)
		{
			printf("Test %s FAILED: %s\n", testName.c_str(), lua_tostring(L, -1));
			lua_pop(L, 1);
			return false;
		}
		else if (rc == LUA_ERRMEM)
		{
			printf("Test %s FAILED: out of memory!\n", testName.c_str());
			return false;
		}
		else if (rc == LUA_ERRERR)
		{
			printf("Test %s FAILED: internal inconsistency (existence of error function)!\n", testName.c_str());
			return false;
		}
	}
	else
	{
		printf("Test %s FAILED: test is undefined!\n", testName.c_str());
		return false;
	}
}

}