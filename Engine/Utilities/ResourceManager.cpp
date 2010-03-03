#include "Apollo.h"
#include "ResourceManager.h"
#include <string>
#include <vector>
#ifdef __MACH__
#include <CoreFoundation/CoreFoundation.h>
#include <sys/stat.h>
#endif
#include "Logging.h"
#include "GAFFile.h"

namespace ResourceManager
{

namespace Internal
{

bool _FileExists ( const std::string& path )
{
	FILE* fp = fopen(path.c_str(), "rb");
	if (fp)
		fclose(fp);
	return fp != NULL;
}

class ResourceDomain
{
public:
	ResourceDomain () {}
	virtual ~ResourceDomain () {}
	
	virtual SDL_RWops* OpenFile ( const std::string& path ) = 0;
	virtual bool FileExists ( const std::string& path );
};

bool ResourceDomain::FileExists ( const std::string& path )
{
	SDL_RWops* ops = OpenFile(path);
	if (ops)
	{
		SDL_RWclose(ops);
		return true;
	}
	else
	{
		return false;
	}
}

class ResourceDomainFilesystem : public ResourceDomain
{
private:
	std::string _basePath;
public:
	ResourceDomainFilesystem ( const std::string& basePath ) : _basePath(basePath) {}
	virtual ~ResourceDomainFilesystem () {}
	
	virtual bool FileExists ( const std::string& path );
	virtual SDL_RWops* OpenFile ( const std::string& path );
};

bool ResourceDomainFilesystem::FileExists ( const std::string& path )
{
	std::string fullPath = _basePath + '/' + path;
	return _FileExists(fullPath);
}

SDL_RWops* ResourceDomainFilesystem::OpenFile ( const std::string& path )
{
	return SDL_RWFromFile((_basePath + '/' + path).c_str(), "rb");
}

class ResourceDomainGAF : public ResourceDomain
{
private:
	GAFFile* _file;
public:
	ResourceDomainGAF(const std::string& path);
	virtual ~ResourceDomainGAF () { delete _file; }

	virtual SDL_RWops* OpenFile(const std::string& path);
};

ResourceDomainGAF::ResourceDomainGAF(const std::string& path)
{
	SDL_RWops* rwops = OpenFile(path);
	size_t length;
	void* data = ReadFull(&length, rwops, 1);
	_file = new GAFFile(data, (unsigned long)length, true);
}

SDL_RWops* ResourceDomainGAF::OpenFile(const std::string& path)
{
	unsigned long length;
	const void* data = _file->GetFile(path, length);
	if (data)
		return SDL_RWFromConstMem(data, length);
	else
		return NULL;
}

std::vector<ResourceDomain*> searchDomains;
std::string userDirectoryPath;
SDL_mutex* mutex;

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
	for (std::vector<ResourceDomain*>::iterator iter = searchDomains.begin(); iter != searchDomains.end(); iter++)
	{
		ResourceDomain* domain = *iter;
		if (domain->FileExists(name))
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
    LOG("ResourceManager", LOG_MESSAGE, "creating directory %s with intermediates", dir.c_str());
	char cmdBuf[1024];
	sprintf(cmdBuf, "mkdir -p '%s'", dir.c_str());
	system(cmdBuf);
}

SDL_RWops* OpenFile ( const std::string& name )
{
	if (name == "")
		return NULL;
    LOG("ResourceManager", LOG_NOTICE, "Reading file: %s", name.c_str());
	SDL_LockMutex(mutex);
	for (std::vector<ResourceDomain*>::iterator iter = searchDomains.begin(); iter != searchDomains.end(); iter++)
	{
		ResourceDomain* domain = *iter;
		if (domain->FileExists(name))
		{
			SDL_RWops* ops = domain->OpenFile(name);
			SDL_UnlockMutex(mutex);
			return ops;
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

void Init ( const std::string& appname )
{
#ifdef __MACH__
	char systemDirectory[1024];
	char userDirectory[1024];
	sprintf(userDirectory, "%s/Library/Application Support/%s", getenv("HOME"), appname.c_str());
	CreateDirectoryWithIntermediates(userDirectory);
	
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	CFURLRef appResourcePath = CFBundleCopyResourcesDirectoryURL(mainBundle);
	CFURLGetFileSystemRepresentation(appResourcePath, 1, (Uint8*)systemDirectory, sizeof(systemDirectory));
	CFRelease(appResourcePath);
	
	searchDomains.push_back(new ResourceDomainFilesystem(userDirectory));
	searchDomains.push_back(new ResourceDomainFilesystem(systemDirectory));
	userDirectoryPath = userDirectory;
#elif defined(WIN32)
#else
	char userDirectory[1024];
	char currentDirectory[1024];
	char appShareDirectory[1024];
	sprintf(userDirectory, "%s/.%s", getenv("HOME"), appname.c_str());
	CreateDirectoryWithIntermediates(userDirectory);
	getcwd(currentDirectory);
	sprintf(appShareDirectory, "/usr/share/%s", appname.c_str());
	searchDomains.push_back(new ResourceDomainFilesystem(userDirectory));
	searchDomains.push_back(new ResourceDomainFilesystem(currentDirectory));
	searchDomains.push_back(new ResourceDomainFilesystem(shareDirectory));
#endif
	mutex = SDL_CreateMutex();
}

}
