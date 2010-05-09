#include "SimulateLag.h"

namespace XNet
{

namespace Plugins
{

void SimulateLag::Update(unsigned long amount)
{
	currentTime += amount;
	DelayedMessage delayedMessage;
	while (!delayedMessages.empty() &&
		   (delayedMessage = delayedMessages.top()).targetTime <= currentTime)
	{
		AttachedPeer()->SendMessage(delayedMessage.message, delayedMessage.target, this);
		delayedMessages.pop();
	}
}

bool SimulateLag::AuditOutgoingMessage(ConnectionID connectionID, const Message& message)
{
	float randomNumber = rand() / (float)RAND_MAX;
	randomNumber -= packetDropRate;
	if (randomNumber < 0.0f)
		return false;
	randomNumber /= (1.0f - packetDropRate);
	unsigned long delay = randomNumber*maxDelay;
	if (delay < 10)
		return Plugin::AuditOutgoingMessage(connectionID, message);
	DelayedMessage delayedMessage;
	delayedMessage.message = message;
	delayedMessage.target = connectionID;
	delayedMessage.targetTime = currentTime + (randomNumber*maxDelay);
	delayedMessages.push(delayedMessage);
	return false;
}

}

}
