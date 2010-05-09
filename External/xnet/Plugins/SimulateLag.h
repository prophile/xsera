#ifndef __XNET_PLUGIN_SIMULATE_LAG__
#define __XNET_PLUGIN_SIMULATE_LAG__

#include "XNet.h"
#include <queue>
#include <stdlib.h>

namespace XNet
{

namespace Plugins
{

class SimulateLag : public Plugin
{
private:
	float packetDropRate;
	unsigned long maxDelay;
	unsigned long currentTime;
	struct DelayedMessage
	{
		Message message;
		ConnectionID target;
		unsigned long targetTime;
		bool operator<(const DelayedMessage& odm) const
			{ return targetTime < odm.targetTime; }
	};
	std::priority_queue<DelayedMessage> delayedMessages;
public:
	SimulateLag(float pdr, unsigned long maxd);

	virtual void Update(unsigned long amount);
	virtual bool AuditOutgoingMessage(ConnectionID connectionID, const Message& message);
};

}

}

#endif
