#ifndef __XNET_PLUGIN_RELIABILITY__
#define __XNET_PLUGIN_RELIABILITY__

#include "XNet.h"

#include <map>
#include <set>
#include <inttypes.h>

namespace XNet
{

namespace Plugins
{

class Reliability : public Plugin
{
private:
	long resendDelay;
	typedef std::map<ConnectionID, std::set<uint32_t> > MessageLog;
	MessageLog unackedMessages;
	MessageLog receivedMessages;
	typedef std::map<uint32_t, Message> MessageBodyMap;
	MessageBodyMap loggedMessages;
	void ResendOnce();
public:
	Reliability();

	virtual void Update(unsigned long dt);
	virtual void DidDisconnect(ConnectionID connectionID);
	virtual void DidReceiveMessage(ConnectionID connectionID, const Message& message);
	virtual bool AuditOutgoingMessage(ConnectionID connectionID, const Message& message);
};

}

}

#endif
