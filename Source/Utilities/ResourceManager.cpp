#include "ResourceManager.h"
#include <string>
#include <vector>
#ifdef __MACH__
#include <CoreFoundation/CoreFoundation.h>
#include <sys/stat.h>
#endif

namespace ResourceManager
{

namespace Internal
{

std::vector<std::string> searchPaths;
std::string userDirectoryPath;
SDL_mutex* mutex;

bool _FileExists ( const std::string& path )
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

bool FileExists ( const std::string& name )
{
	if (name == "")
		return false;
	SDL_LockMutex(mutex);
	for (std::vector<std::string>::iterator iter = searchPaths.begin(); iter != searchPaths.end(); iter++)
	{
		std::string fullPath = (*iter) + '/' + name;
		if (_FileExists(fullPath))
		{
			SDL_UnlockMutex(mutex);
			return true;
		}
	}
	SDL_UnlockMutex(mutex);
	return false;
}

static void CreateDirectoryWithIntermediates ( const std::string& dir )
{
	printf("[ResourceManager] creating directory %s (including intermediates)\n", dir.c_str());
	char cmdBuf[1024];
	sprintf(cmdBuf, "mkdir -p '%s'", dir.c_str());
	system(cmdBuf);
}

SDL_RWops* OpenFile ( const std::string& name )
{
	if (name == "")
		return NULL;
	SDL_LockMutex(mutex);
	for (std::vector<std::string>::iterator iter = searchPaths.begin(); iter != searchPaths.end(); iter++)
	{
		std::string fullPath = (*iter) + '/' + name;
		if (_FileExists(fullPath))
		{
			printf("[ResourceManager] loaded file %s\n", name.c_str());
			SDL_UnlockMutex(mutex);
			return SDL_RWFromFile(fullPath.c_str(), "r");
		}
	}
	SDL_UnlockMutex(mutex);
	return NULL;
}

SDL_RWops* WriteFile ( const std::string& name )
{
	std::string path = userDirectoryPath + '/' + name;
	CreateDirectoryWithIntermediates(path.substr(0, path.find_last_of('/')));
	return SDL_RWFromFile(path.c_str(), "wb");
}

void WriteFile ( const std::string& name, const void* data, size_t len )
{
	std::string path = userDirectoryPath + '/' + name;
	CreateDirectoryWithIntermediates(path.substr(0, path.find_last_of('/')));
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
	CreateDirectoryWithIntermediates(userDirectory);
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	CFURLRef resourcePath = CFBundleCopyResourcesDirectoryURL(mainBundle);
	CFURLGetFileSystemRepresentation(resourcePath, 1, (Uint8*)systemDirectory, sizeof(systemDirectory));
	CFRelease(resourcePath);
	printf("Search directories:\n\tSystem: %s\n\tUser: %s\n", systemDirectory, userDirectory);
	searchPaths.push_back(systemDirectory);
	searchPaths.push_back(userDirectory);
	userDirectoryPath = userDirectory;
#endif
	mutex = SDL_CreateMutex();
}

}
