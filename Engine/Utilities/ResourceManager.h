#ifndef __apollo_utilities_resourcemanager_h
#define __apollo_utilities_resourcemanager_h

/**
 * @file ResourceManager.h
 * @brief A generic resource manager
 */

#include <SDL/SDL.h>
#include <string>

namespace ResourceManager
{

// utility function for reading from a RWops in full
/**
 * Fetches the full contents of an SDL_RWops
 * @param length A pointer to a size_t to hold the length of the SDL_RWops
 * @param ops The rwops in question
 * @param autoclose Whether to automatically close the rwops or not
 * @return The data of the rwops
 */
void* ReadFull ( size_t* length, SDL_RWops* ops, int autoclose );

/**
 * Checks if a given file exists
 * @param name The name of the file
 * @return Whether the file exists
 */
bool FileExists ( const std::string& name );
/**
 * Opens a file
 * @param name The name of the file
 * @return An SDL_RWops for the file, or NULL on error
 * @note Separate paths with /, they will be automatically converted
 */
SDL_RWops* OpenFile ( const std::string& name );
/**
 * Opens a file for writing
 * @param name The name of the file
 * @return An SDL_RWops for the file, or NULL on error
 */
SDL_RWops* WriteFile ( const std::string& name );
/**
 * Writes data to a file
 * @param name The name of the file
 * @param data The data to write
 * @param len The length of the data
 * @return An SDL_RWops for the file, or NULL on error
 */
void WriteFile ( const std::string& name, const void* data, size_t len );

/**
 * Initialises the resource manager
 * @param appname The application's name (eg: Xsera)
 */
void Init ( const std::string& appname );

}

#endif
