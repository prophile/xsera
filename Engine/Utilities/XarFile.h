#ifndef __apollo_utilities_xarfile_h
#define __apollo_utilities_xarfile_h

/**
 * @file XarFile.h
 * @brief XAR archive loader
 */

#include <string>
#ifdef WIN32
#include "SDL.h"
#else
#include <SDL/SDL.h>
#endif
#include <map>

/**
 * An XAR archive
 */
class XarFile
{
private:
    std::map<std::string, std::pair<uint32_t, uint32_t> > index; // the pair is offset, index
    void* data;
    size_t len;
public:
    /**
     * Opens an archive with a given path
     * @param sourceFile Path to the archive
     */
    XarFile ( const std::string& sourceFile );
    /**
     * Closes an archive
     */
    ~XarFile ();
    
    /**
     * Checks if a file exists
     * @param subfile The filename within the archive
     * @return Whether or not the file exists
     */
    bool FileExists ( const std::string& subfile );
    /**
     * Opens a file
     * @param subfile The filename within the archive
     * @return An SDL_RWops for the stream, or NULL on error
     */
    SDL_RWops* OpenFile ( const std::string& subfile );
};

#endif
