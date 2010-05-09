#ifndef __XNET_PLUGIN_ALLOWING_LOGGING__
#define __XNET_PLUGIN_ALLOWING_LOGGING__

#include "XNet.h"

namespace XNet
{

namespace Plugins
{

class Logging : public Plugin
{
public:
	Logging();
	~Logging();

	// called on all plugins
	virtual void DidAttach();
	// called on all plugins
	virtual void DidDetach();
	// lower->higher
	virtual void DidConnect(ConnectionID connectionID, const std::string& hostname, uint16_t port);
	// lower->higher
	virtual void DidDisconnect(ConnectionID connectionID);
	// lower->higher
	virtual void DidReceiveMessage(ConnectionID connectionID, const Message& message);
	// higher->lower
	virtual bool AuditConnection(const std::string& hostname, uint16_t port);
	// higher->lower
	virtual bool AuditOutgoingMessage(ConnectionID connectionID, const Message& message);
};

}

}

#endif