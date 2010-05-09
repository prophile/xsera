#include "Reliability.h"

namespace XNet
{

namespace Plugins
{

const static long TIME_DELAY = 100;

Reliability::Reliability()
: resendDelay(TIME_DELAY)
{
}

void Reliability::ResendOnce()
{
	for (MessageLog::iterator iter = unackedMessages.begin();
	                          iter != unackedMessages.end();
	                          ++iter)
	{
		// this loops over all connections
		if (!iter->second.empty())
		{
			// resend message
			AttachedPeer()->SendMessage(loggedMessages[*(iter->second.begin())],
			                            iter->first, this);
		}
	}
}

void Reliability::Update(unsigned long dt)
{
	resendDelay -= dt;
	while (resendDelay < 0)
	{
		ResendOnce();
		resendDelay += TIME_DELAY;
	}
}

void Reliability::DidDisconnect(ConnectionID connectionID)
{
	MessageLog::iterator iter;
	iter = unackedMessages.find(connectionID);
	if (iter != unackedMessages.end())
	{
		for (std::set<uint32_t>::iterator iter2 = iter->second.begin();
		                                  iter2 != iter->second.end();
		                                  ++iter2)
		{
			loggedMessages.erase(loggedMessages.find(*iter2));
		}
		unackedMessages.erase(iter);
	}
	iter = receivedMessages.find(connectionID);
	if (iter != receivedMessages.end())
	{
		receivedMessages.erase(iter);
	}
	Plugin::DidDisconnect(connectionID);
}

void Reliability::DidReceiveMessage(ConnectionID connectionID, const Message& message)
{
	Plugin::DidReceiveMessage(connectionID, message);
}

bool Reliability::AuditOutgoingMessage(ConnectionID connectionID, const Message& message)
{
	return Plugin::AuditOutgoingMessage(connectionID, message);
}

}

}
