#ifndef __XNET_PLUGIN_ALLOWING_CONNECTIONS__
#define __XNET_PLUGIN_ALLOWING_CONNECTIONS__

#include "XNet.h"

namespace XNet
{

namespace Plugins
{

class AllowingConnections : public Plugin
{
public:
	bool AuditConnection(const std::string& hostname, uint16_t port);
};

}

}

#endif
