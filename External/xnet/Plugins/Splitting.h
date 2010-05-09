#ifndef __XNET_PLUGIN_SPLITTING__
#define __XNET_PLUGIN_SPLITTING__

#include "XNet.h"

namespace XNet
{

namespace Plugins
{

class Splitting : public Plugin
{
private:
	unsigned long datamax;
public:
	Splitting(unsigned long maxsize = 800);

	virtual void DidReceiveMessage(ConnectionID connectionID, const Message& message);
	virtual bool AuditOutgoingMessage(ConnectionID connectionID, const Message& message);
};

}

}

#endif
