#ifndef __XNET_PLUGIN_ORDERING__
#define __XNET_PLUGIN_ORDERING__

#include "XNet.h"
#include <map>
#include <queue>

namespace XNet
{

namespace Plugins
{

class Ordering : public Plugin
{
private:
	struct QueuedMessage
	{
		Message msg;
		uint32_t seqID;

		QueuedMessage(const Message& aMesg, uint32_t sid) :
			msg(aMesg), seqID(sid) {}
		bool operator<(const QueuedMessage& qm) const
			{ return seqID < qm.seqID; }
	};
	typedef std::priority_queue<QueuedMessage> MessageQueue;
	std::map<ConnectionID, MessageQueue> messageQueues;
	std::map<ConnectionID, uint32_t> nextExpectedMessage;
	std::map<ConnectionID, uint32_t> nextOutgoingMessage;

	const static int MAX_QUEUE_SIZE = 20;
public:
	Ordering();

	virtual void DidConnect(ConnectionID, const std::string& hostname, uint16_t port);
	virtual void DidDisconnect(ConnectionID);
	virtual void DidReceiveMessage(ConnectionID, const Message& message);
	virtual bool AuditOutgoingMessage(ConnectionID, const Message& message);
};

}

}

#endif
