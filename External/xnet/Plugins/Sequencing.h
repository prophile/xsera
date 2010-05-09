#ifndef __XNET_SEQUENCING__
#define __XNET_SEQUENCING__

#include "XNet.h"
#include <inttypes.h>
#include <map>

namespace XNet
{

namespace Plugins
{

class Sequencing : public Plugin
{
private:
	std::map<ConnectionID, uint32_t> maxReceivedID;
	std::map<ConnectionID, uint32_t> nextSendID;
public:
	Sequencing() {}

	virtual void DidDisconnect(ConnectionID);
	virtual void DidReceiveMessage(ConnectionID, const Message& message);
	virtual bool AuditOutgoingMessage(ConnectionID, const Message& message);
};

}

}

#endif
