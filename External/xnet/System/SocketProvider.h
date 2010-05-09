#ifndef __XNET_SYSTEM_SOCKET_PROVIDER__
#define __XNET_SYSTEM_SOCKET_PROVIDER__

#include <string>
#include <inttypes.h>

namespace XNet
{

// data are provided in network byte order

class Socket
{
private:
protected:
	Socket();
public:
	virtual ~Socket() {}

	virtual void Send(uint32_t host, uint16_t port, const void* data, size_t length) = 0;
	virtual void* Receive(uint32_t& host, uint16_t& port, size_t& length) = 0;
};

class SocketProvider
{
private:
public:
	SocketProvider();
	virtual ~SocketProvider() {}

	// bindPort is provided in network byte order
	virtual Socket* NewSocket(uint16_t bindPort) = 0;
	virtual uint32_t ResolveHost(const std::string& hostname) = 0;
	virtual std::string ReverseLookup(uint32_t host) = 0;
};

}

#endif
