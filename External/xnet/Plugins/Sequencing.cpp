#include "Sequencing.h"
#include "MessageIDs.h"
#include "DataSerialiser.h"
#include "DataUnserialiser.h"

namespace XNet
{

namespace Plugins
{

void Sequencing::DidDisconnect(ConnectionID connection)
{
	std::map<ConnectionID, uint32_t>::iterator iter;
	iter = maxReceivedID.find(connection);
	if (iter != maxReceivedID.end())
		maxReceivedID.erase(iter);
	iter = nextSendID.find(connection);
	if (iter != nextSendID.end())
		nextSendID.erase(iter);
	Plugin::DidDisconnect(connection);
}

void Sequencing::DidReceiveMessage(ConnectionID connection, const Message& message)
{
	if (message.id == MID_SEQ)
	{
		uint32_t lastSeqID;
		std::map<ConnectionID, uint32_t>::iterator iter;
		iter = maxReceivedID.find(connection);
		if (iter == maxReceivedID.end())
			lastSeqID = 1;
		else
			lastSeqID = iter->second;
		uint32_t seqID;
		DataUnserialiser unserialiser(message.data);
		unserialiser >> seqID;
		if (seqID > lastSeqID)
		{
			Message actualMessage;
			unserialiser >> actualMessage.id;
			unserialiser >> actualMessage.data;
			actualMessage.CopyMetadata(message);
			maxReceivedID[connection] = seqID;
			AttachedPeer()->ReceiveMessage(connection, actualMessage, this);
		}
		else
		{
			// reject the message, it's out of sequence
		}
	}
	else
	{
		Plugin::DidReceiveMessage(connection, message);
	}
}

bool Sequencing::AuditOutgoingMessage(ConnectionID connection, const Message& message)
{
	if (!message.sequenced)
	{
		// non-ordered, not our problem
		return Plugin::AuditOutgoingMessage(connection, message);
	}
	else
	{
		uint32_t sequenceID;
		std::map<ConnectionID, uint32_t>::iterator iter;
		// next order sequence
		iter = nextSendID.find(connection);
		if (iter != nextSendID.end())
		{
			sequenceID = iter->second;
		}
		else
		{
			sequenceID = 1;
		}
		nextSendID[connection] = sequenceID++;
		Message newMessage;
		newMessage.id = MID_SEQ;
		DataSerialiser serialiser;
		serialiser << sequenceID;
		serialiser << message.id;
		serialiser << message.data;
		serialiser.Sync();
		newMessage.data = serialiser.StringValue();
		newMessage.CopyMetadata(message);
		AttachedPeer()->SendMessage(newMessage, connection, this);
		return false;
	}
}

}

}
