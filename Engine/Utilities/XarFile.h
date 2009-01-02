#ifndef __apollo_utilities_xarfile_h
#define __apollo_utilities_xarfile_h

#include <string>
#include <SDL/SDL.h>
#include <map>

class XarFile
{
private:
    std::map<std::string, std::pair<uint32_t, uint32_t> > index; // the pair is offset, index
    void* data;
    size_t len;
public:
    XarFile ( const std::string& sourceFile );
    ~XarFile ();
    
    bool FileExists ( const std::string& subfile );
    SDL_RWops* OpenFile ( const std::string& subfile );
};

#endif
