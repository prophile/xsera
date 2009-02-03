#ifdef WIN32
#include <stdafx.h>
#endif

#include "XarFile.h"
#include "Utilities/ResourceManager.h"

#define XAR_MAGIC "XARK"

XarFile::XarFile ( const std::string& sourceFile )
{
    SDL_RWops* ops = ResourceManager::OpenFile(sourceFile);
    if (!ops)
    {
        data = NULL;
        len = 0;
        return;
    }
    unsigned char* _data;
    unsigned char* _data_base;
    size_t _len;
    _data_base = (unsigned char*)ResourceManager::ReadFull(&_len, ops, 1);
    _data = _data_base;
    if (memcmp(XAR_MAGIC, _data, 4))
    {
        free(_data);
        data = NULL;
        len = 0;
        return;
    }
    _data += 4;
    // get file count
    uint16_t fileCount;
    memcpy(&fileCount, _data, 2);
    _data += 2;
    fileCount = SDL_SwapBE16(fileCount);
    // get file references
    for (uint16_t i = 0; i < fileCount; i++)
    {
        uint32_t fileOffset;
        memcpy(&fileOffset, _data, 4);
        fileOffset = SDL_SwapBE32(fileOffset);
        _data += 4;
        uint32_t fileLength;
        memcpy(&fileLength, _data, 4);
        fileLength = SDL_SwapBE32(fileLength);
        _data += 4;
        uint16_t nameLength;
        memcpy(&nameLength, _data, 2);
        _data += 2;
        nameLength = SDL_SwapBE16(nameLength);
        char* name = (char*)alloca(nameLength + 1);
        name[nameLength] = 0;
        memcpy(name, _data, nameLength);
        _data += nameLength;
        index[name] = std::make_pair(fileOffset, fileLength);
    }
    // fill actual data
    unsigned blockSize = _len - (_data - _data_base);
    data = malloc(blockSize);
    memcpy(data, _data, blockSize);
    free(_data_base);
}

XarFile::~XarFile ()
{
    if (data)
        free(data);
}

bool XarFile::FileExists ( const std::string& subfile )
{
    return (index.find(subfile) != index.end());
}

SDL_RWops* XarFile::OpenFile ( const std::string& subfile )
{
    if (!FileExists(subfile))
        return NULL;
    std::map<std::string, std::pair<uint32_t, uint32_t> >::iterator iter = index.find(subfile);
    void* base = (void*)(((unsigned char*)data) + iter->second.first);
    size_t blockLen = iter->second.second;
    return SDL_RWFromConstMem(base, blockLen);
}
