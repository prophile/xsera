#ifdef WIN32
#include <stdafx.h>
#endif

#include "Preferences.h"
#include "Utilities/ResourceManager.h"
#include <map>

namespace Preferences
{

typedef std::map<std::string, std::string> PreferenceMap;
PreferenceMap preferences;

std::string Get ( const std::string& key, const std::string& defaultValue )
{
	PreferenceMap::iterator iter = preferences.find(key);
	if (iter == preferences.end())
	{
		return defaultValue;
	}
	else
	{
		return iter->second;
	}
}

void Set ( const std::string& key, const std::string& defaultValue )
{
	preferences[key] = defaultValue;
}

void Clear ( const std::string& key )
{
	PreferenceMap::iterator iter = preferences.find(key);
	if (iter != preferences.end())
	{
		preferences.erase(iter);
	}
}

static void ParseLine ( const std::string& line )
{
	if (line != "")
	{
		std::string::size_type n = line.find_first_of(':');
		std::string k = line.substr(0, n);
		std::string v = line.substr(n + 1, std::string::npos);
		preferences[k] = v;
	}
}

void Load ()
{
	preferences.clear();
	SDL_RWops* ops = ResourceManager::OpenFile("Config/Preferences.cfg");
	if (!ops)
		return;
	size_t len;
	char* buffer = (char*)ResourceManager::ReadFull(&len, ops, 1);
	std::string preferenceLine;
	char* tempPointer = buffer;
	while (*tempPointer)
	{
		char ch = *tempPointer;
		if (ch == '\n')
		{
			ParseLine(preferenceLine);
			preferenceLine.clear();
		}
		else
		{
			preferenceLine.push_back(ch);
		}
		tempPointer++;
	}
	free((void*)buffer);
}

void Save ()
{
	std::string buffer;
	for ( PreferenceMap::iterator iter = preferences.begin(); iter != preferences.end(); iter++ )
	{
		buffer.append(iter->first + ":" + iter->second + "\n");
	}
	ResourceManager::WriteFile("Config/Preferences.cfg", buffer.data(), buffer.length());
}

}
