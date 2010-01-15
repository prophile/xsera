#ifndef __apollo_scripting_scripting_h
#define __apollo_scripting_scripting_h

#include <stdarg.h>

#include <string>

typedef struct lua_State lua_State;

/**
 * A lua script
 */
class LuaScript
{
private:
    lua_State* L;
public:
    /**
     * Loads a script from a file
     */
    LuaScript ( const std::string& filename );
    /**
     * Generic destructor
     */
    ~LuaScript ();
    
    /**
     * Invokes a lua subroutine
     * @param name The name of the subroutine to invoke
     */
    void InvokeSubroutine ( const std::string& name );
    /**
     * Invokes a lua subroutine
     * @param name The name of the subroutine to invoke
     * @param p A string parameter
     */
	void InvokeSubroutine ( const std::string& name, const std::string& p );
	/**
     * Invokes a lua subroutine
     * @param name The name of the subroutine to invoke
     * @param x A float parameter
     * @param y Another float parameter
     */
	void InvokeSubroutine ( const std::string& name, int reference );
	/**
     * Invokes a lua subroutine
     * @param name The name of the subroutine to invoke
     * @param reference a reference to a lua table
     */
	void InvokeSubroutine ( const std::string& name, float x, float y );
    /**
     * Invokes a lua subroutine
     * @param name The name of the subroutine to invoke
     * @param p A string parameter
     * @param x A float parameter
     * @param y Another float parameter
     */
	void InvokeSubroutine ( const std::string& name, const std::string& p, float x, float y );
	
	/**
	 * Fetches the underlying lua_State* object
	 */
	lua_State* RawState () { return L; }
	/**
	 * Runs the normal procedure for import() on a state
	 * @param L The low-level state to use
	 * @param modulename The name of the module to import
	 */
	static void RawImport ( lua_State* L, const std::string& modulename );
	
	/**
	 * Imports a module into a state
	 * @param name The name of the module to import
	 */
	void ImportModule ( const std::string& name )
		{ RawImport(L, name); }
};

#endif