#include <enet/enet.h>
#include <map>
#include "Net.h"
#include "MessageEncoding.h"

namespace Net
{

namespace Server
{

ENetHost* serverHost = NULL;
typedef std::map<unsigned int, ENetPeer*> ClientMap;
ClientMap clients;
static unsigned int nextClientID = 1;

const uint32_t SERVER_BANDWIDTH_LIMIT = 1024 * 64; // 64 kB/s
const int SERVER_MAX_CLIENTS = 8; // plucked this one out of my arse.

void Startup ( unsigned short port, const std::string& password )
{
	if (serverHost)
	{
		Shutdown();
	}
	ENetAddress addr;
	addr.port = htons(port);
	addr.host = INADDR_ANY;
	serverHost = enet_host_create(&addr, SERVER_MAX_CLIENTS, SERVER_BANDWIDTH_LIMIT, SERVER_BANDWIDTH_LIMIT);
}

void Shutdown ()
{
	if (serverHost)
	{
		clients.clear();
		enet_host_destroy(serverHost);
		serverHost = NULL;
	}
}

bool IsRunning ()
{
	return serverHost != NULL;
}

unsigned ClientCount ()
{
	return clients.size();
}

void KillClient ( unsigned int clientID )
{
	ClientMap::iterator iter = clients.find(clientID);
	if (iter != clients.end())
	{
		enet_peer_disconnect_later(iter->second, 0);
		clients.erase(iter);
	}
}

void SendMessage ( unsigned int clientID, const Message& msg )
{
	ClientMap::iterator iter = clients.find(clientID);
	if (iter != clients.end())
	{
		ENetPacket* packet = MessageEncoding::Encode(msg);
		enet_peer_send(iter->second, 0, packet);
	}
}

void BroadcastMessage ( const Message& msg )
{
	if (!serverHost)
		return;
	ENetPacket* packet = MessageEncoding::Encode(msg);
	enet_host_broadcast(serverHost, 0, packet);
}

bool IsConnected ( unsigned int clientID )
{
	return clients.find(clientID) != clients.end();
}

Message* GetMessage ()
{
	ENetEvent event;
	if (enet_host_service(serverHost, &event, 0))
	{
		Message* msg = NULL;
		unsigned int clientID = 0;
		for (ClientMap::iterator iter = clients.begin(); iter != clients.end(); iter++)
		{
			if (iter->second == event.second)
			{
				clientID = iter->first;
			}
		}
		switch (event.type)
		{
			case ENET_EVENT_TYPE_CONNECT:
				// TODO: handle this
				break;
			case ENET_EVENT_TYPE_DISCONNECT:
				break;
			case ENET_EVENT_TYPE_RECEIVE:
				msg = MessageEncoding::Decode(event.packet);
				msg->clientID = clientID;
				enet_packet_destroy(event.packet);
				break;
		}
		return msg;
	}
	return NULL;
}

}

}
