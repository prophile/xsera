#ifndef __XNET_SYSTEM_LOCAL_ONLY__
#define __XNET_SYSTEM_LOCAL_ONLY__

#include <queue>
#include <string>
#include "SocketProvider.h"

namespace XNet
{

class LocalOnlySocket : public Socket
{
private:
	uint16_t localPort;
	std::queue<std::pair<uint16_t, std::string> > queuedMessages;
	friend class LocalOnlySocketProvider;
protected:
	LocalOnlySocket(uint16_t portno);
public:
	virtual ~LocalOnlySocket();

	virtual void Send(uint32_t host, uint16_t port, const void* data, size_t length);
	virtual void* Receive(uint32_t& host, uint16_t& port, size_t& length);
};

class LocalOnlySocketProvider : public SocketProvider
{
private:
public:
	LocalOnlySocketProvider();
	virtual ~LocalOnlySocketProvider();

	virtual Socket* NewSocket(uint16_t port);
	virtual uint32_t ResolveHost(const std::string& hostname);
	virtual std::string ReverseLookup(uint32_t host);
};

}

#endif
