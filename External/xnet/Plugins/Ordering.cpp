#include "Ordering.h"
#include "MessageIDs.h"
#include "DataSerialiser.h"
#include "DataUnserialiser.h"

namespace XNet
{

namespace Plugins
{

Ordering::Ordering()
{
}

void Ordering::DidConnect(ConnectionID id, const std::string& hostname, uint16_t port)
{
	messageQueues[id] = MessageQueue();
	nextExpectedMessage[id] = 0;
	nextOutgoingMessage[id] = 0;
	Plugin::DidConnect(id, hostname, port);
}

void Ordering::DidDisconnect(ConnectionID id)
{
	std::map<ConnectionID, MessageQueue>::iterator mqIter = messageQueues.find(id);
	if (mqIter != messageQueues.end())
		messageQueues.erase(mqIter);
	std::map<ConnectionID, uint32_t>::iterator seqIter = nextExpectedMessage.find(id);
	if (seqIter != nextExpectedMessage.end())
		nextExpectedMessage.erase(seqIter);
	seqIter = nextOutgoingMessage.find(id);
	if (seqIter != nextOutgoingMessage.end())
		nextOutgoingMessage.erase(seqIter);
	Plugin::DidDisconnect(id);
}

void Ordering::DidReceiveMessage(ConnectionID id, const Message& message)
{
	if (message.id == MID_ORD)
	{
		DataUnserialiser unserialiser(message.data);
		Message msg;
		uint32_t id;
		unserialiser >> id;
		unserialiser >> msg.id;
		unserialiser >> msg.data;
		QueuedMessage qm(msg, id);
		MessageQueue& mq(messageQueues[id]);
		mq.push(qm);
		if (mq.size() > MAX_QUEUE_SIZE)
		{
			// connection is dead
			AttachedPeer()->Disconnect(id);
			return;
		}
		while (!mq.empty() && mq.top().seqID == nextExpectedMessage[id])
		{
			nextExpectedMessage[id]++;
			AttachedPeer()->ReceiveMessage(id, mq.top().msg, this);
			mq.pop();
		}
	}
	else
		Plugin::DidReceiveMessage(id, message);
}

bool Ordering::AuditOutgoingMessage(ConnectionID id, const Message& message)
{
	if (message.ordered)
	{
		uint32_t id = nextOutgoingMessage[id]++;
		DataSerialiser serialiser;
		serialiser << id;
		serialiser << message.id;
		serialiser << message.data;
		serialiser.Sync();
		Message newMessage(MID_ORD, serialiser.StringValue());
		newMessage.CopyMetadata(message);
		AttachedPeer()->SendMessage(newMessage, id, this);
		return false;
	}
	else
		return Plugin::AuditOutgoingMessage(id, message);
}

}

}
