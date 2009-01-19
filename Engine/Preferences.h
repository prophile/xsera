#ifndef __xsera_preferences_h
#define __xsera_preferences_h

#include <string>

namespace Preferences
{

std::string Get ( const std::string& key, const std::string& defaultValue = "" );
void Set ( const std::string& key, const std::string& newValue );
void Clear ( const std::string& key );

void Load ();
void Save ();

}

#endif