#include "Splitting.h"
#include "MessageIDs.h"

namespace XNet
{

namespace Plugins
{

Splitting::Splitting(unsigned long maxsize)
: datamax(maxsize)
{
}

void Splitting::DidReceiveMessage(ConnectionID connectionID, const Message& message)
{
	Plugin::DidReceiveMessage(connectionID, message);
}

bool Splitting::AuditOutgoingMessage(ConnectionID connectionID, const Message& message)
{
	// if the message data is larger than datamax,
	//  calculate how many datamax-6 sized units the message will take
	//  split up into separate messages, including each one a group number, size, and index
	//  send them all
	return Plugin::AuditOutgoingMessage(connectionID, message);
}

}

}
