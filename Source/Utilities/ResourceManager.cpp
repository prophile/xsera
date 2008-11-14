#include "ResourceManager.h"
#include <string>
#include <vector>
#ifdef __MACH__
#include <CoreFoundation/CoreFoundation.h>
#endif

namespace ResourceManager
{

namespace Internal
{

std::vector<std::string> searchPaths;
std::string userDirectoryPath;

bool FileExists ( const std::string& path )
{
	FILE* fp = fopen(path.c_str(), "rb");
	if (fp)
		fclose(fp);
	return fp != NULL;
}

}

using namespace Internal;

// utility function for reading from a RWops in full
void* ReadFull ( size_t* length, SDL_RWops* ops, int autoclose )
{
	size_t len = SDL_RWseek(ops, 0, SEEK_END);
	*length = len;
	SDL_RWseek(ops, 0, SEEK_SET);
	void* buffer = malloc(len);
	SDL_RWread(ops, buffer, 1, len);
	if (autoclose)
		SDL_RWclose(ops);
	return buffer;
}

SDL_RWops* OpenFile ( const std::string& name )
{
	if (name == "")
		return NULL;
	for (std::vector<std::string>::iterator iter = searchPaths.begin(); iter != searchPaths.end(); iter++)
	{
		std::string fullPath = (*iter) + '/' + name;
		if (FileExists(fullPath))
		{
			printf("[ResourceManager] loaded file %s\n", name.c_str());
			return SDL_RWFromFile(fullPath.c_str(), "r");
		}
	}
	return NULL;
}

void WriteFile ( const std::string& name, const void* data, size_t len )
{
	std::string path = userDirectoryPath + '/' + name;
	FILE* fp = fopen(path.c_str(), "rb");
	assert(fp);
	fwrite(data, 1, len, fp);
	fclose(fp);
}

void Init ()
{
	searchPaths.clear();
#ifdef __MACH__
	char systemDirectory[1024];
	char userDirectory[1024];
	sprintf(userDirectory, "%s/Library/Application Support/Xsera", getenv("HOME"));
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	CFURLRef resourcePath = CFBundleCopyResourcesDirectoryURL(mainBundle);
	CFURLGetFileSystemRepresentation(resourcePath, 1, (Uint8*)systemDirectory, sizeof(systemDirectory));
	CFRelease(resourcePath);
	searchPaths.push_back(systemDirectory);
	searchPaths.push_back(userDirectory);
	userDirectoryPath = userDirectory;
#endif
}

}
