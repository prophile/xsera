#include "XNet.h"
#include <assert.h>
#include "DataSerialiser.h"
#include "DataUnserialiser.h"
#include <stdio.h>

namespace XNet
{

#ifdef __LITTLE_ENDIAN__
#define BE16(x) ((x)<<8 | (x)>>8)
#ifdef __clang__
#define BE32(x) __builtin_bswap32(x)
#else
#define BE32(x) ntohl(x)
#endif
#else
#define BE16(x) (x)
#define BE32(x) (x)
#endif

Peer::Peer(SocketProvider* provider, uint16_t port)
: highestPlugin(0),
  lowestPlugin(0),
  socketProvider(provider),
  primarySocket(0),
  acceptNewConnections(false),
  nextConnectionID(1)
{
	primarySocket = socketProvider->NewSocket(BE16(port));
}

Peer::~Peer()
{
	delete primarySocket;
}

void Peer::Update(unsigned long dt)
{
	// update plugins
	Plugin* current = highestPlugin;
	while (current)
	{
		current->Update(dt);
		assert(current != current->lower);
		current = current->lower;
	}
	// check connections
	size_t dataLength;
	uint32_t dataHost;
	uint16_t dataPort;
	void* data;
	while ((data = primarySocket->Receive(dataHost, dataPort, dataLength)))
	{
		if (!dataLength || !dataHost || !dataPort)
		{
			continue;
		}
		fprintf(stderr, "got message\n");
		bool found = false;
		for (std::map<ConnectionID, std::pair<uint32_t, uint16_t> >::iterator iter = connections.begin(); iter != connections.end(); ++iter)
		{
			if (iter->second.first == dataHost &&
			    iter->second.second == dataPort)
			{
				// we've got the connection
				DataUnserialiser unserialiser(data, dataLength);
				Message msg;
				unserialiser >> msg.id;
				unserialiser >> msg.data;
				ReceiveMessage(iter->first, msg, NULL);
				free(data);
				found = true;
				break;
			}
		}
		if (found)
			continue;
		// new connection! excitement ensues
		if (!acceptNewConnections)
		{
			// or not. DENIED!
			free(data);
			continue;
		}
		std::string hostname = socketProvider->ReverseLookup(dataHost);
		uint16_t hostPort = BE16(dataPort);
		// audit it
		bool ok = highestPlugin ? highestPlugin->AuditConnection(hostname, hostPort) : false;
		if (!ok)
		{
			// audit denied connection
			free(data);
			continue;
		}
		// OK, we accept this connection, assign it an ID
		ConnectionID id = nextConnectionID++;
		connections[id] = std::make_pair(dataHost, dataPort);
		// inform plugins -
		// we can assume the existence of plugins at this point
		// since without them, the connection would have been automatically
		// denied anyway
		lowestPlugin->DidConnect(id, hostname, hostPort);
		// and now dispatch their first message
		DataUnserialiser unserialiser(data, dataLength);
		Message msg;
		unserialiser >> msg.id;
		unserialiser >> msg.data;
		ReceiveMessage(id, msg, NULL);
	}
}

bool Peer::Connect(const std::string& remote, uint16_t port)
{
	uint16_t netPort = BE16(port);
	uint32_t ip = socketProvider->ResolveHost(remote);
	if (!ip || !port)
		return false;
	ConnectionID id = nextConnectionID++;
	connections[id] = std::make_pair(ip, netPort);
	if (lowestPlugin)
		lowestPlugin->DidConnect(id, remote, port);
	Message firstMessage(0);
	SendMessage(firstMessage, id, lowestPlugin);
	return true;
}

void Peer::Disconnect(ConnectionID connection)
{
	if (lowestPlugin)
	{
		lowestPlugin->DidDisconnect(connection);
	}
	std::map<ConnectionID, std::pair<uint32_t, uint16_t> >::iterator iter = connections.find(connection);
	assert(iter != connections.end());
	connections.erase(iter);
}

void Peer::SendMessage(const Message& message, ConnectionID target, Plugin* source)
{
	std::map<ConnectionID, std::pair<uint32_t, uint16_t> >::iterator iter = connections.find(target);
	assert(iter != connections.end());
	Plugin* next = source ? source->lower : highestPlugin;
	bool ok = next ? (next->AuditOutgoingMessage(target, message)) : true;
	if (!ok)
		return;
	DataSerialiser serialiser;
	serialiser << message.id << message.data;
	serialiser.Sync();
	size_t length;
	const void* data = serialiser.DataValue(length);
	primarySocket->Send(iter->second.first, iter->second.second, data, length);
}

void Peer::AttachPlugin(Plugin* plugin, Plugin* lowerThan)
{
	if (!highestPlugin)
	{
		highestPlugin = lowestPlugin = plugin;
		plugin->lower = plugin->higher = NULL;
	}
	else if (lowerThan)
	{
		Plugin* p = highestPlugin;
		while (p && p != lowerThan)
		{
			 p = p->lower;
		}
		assert(p);
		if (p->lower)
		{
			p->lower->higher = plugin;
		}
		else
		{
			lowestPlugin = plugin;
		}
		p->lower = plugin;
		plugin->lower = NULL;
		plugin->higher = p;
	}
	else
	{
		highestPlugin->higher = plugin;
		plugin->lower = highestPlugin;
		plugin->higher = NULL;
		highestPlugin = plugin;
	}
	plugin->DidAttach();
}

void Peer::DetachPlugin(Plugin* plugin)
{
	assert(0 && !"DetachPlugin is not yet implemented!");
}

void Peer::ReceiveMessage(ConnectionID source, const Message& message, Plugin* plugin)
{
	if (message.id == 0)
		return;
	Plugin* receiver = plugin ? plugin->higher : lowestPlugin;
	if (receiver)
	{
		receiver->DidReceiveMessage(source, message);
	}
}

}
