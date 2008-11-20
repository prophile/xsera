#include <enet/enet.h>
#include "Net.h"
#include "MessageDecode.h"

namespace Net
{

namespace Client
{

ENetHost* clientHost = NULL;
ENetPeer* clientPeer = NULL;

const uint32_t CLIENT_BANDWIDTH_LIMIT = 1024 * 16; // 16 kB/s

void Connect ( const std::string& host, unsigned short port, const std::string& password )
{
	if (clientHost)
	{
		Disconnect();
	}
	clientHost = enet_host_create(NULL, 0, CLIENT_BANDWIDTH_LIMIT, CLIENT_BANDWIDTH_LIMIT);
	ENetAddress addr;
	addr.port = htons(port);
	enet_address_set_host(&addr, host.c_str());
	clientPeer = enet_host_connect(clientHost, &addr, 1);
}

void Disconnect ()
{
	if (clientHost)
	{
		enet_peer_disconnect_now(clientPeer, 0);
		enet_host_flush(clientHost);
		enet_host_destroy(clientHost);
		clientHost = NULL;
		clientPeer = NULL;
	}
}

bool IsConnected ()
{
	return clientHost != NULL;
}

void SendMessage ( const Message& msg )
{
	if (!clientPeer)
		return;
	ENetPacket* packet = MessageEncoding::Encode(msg);
	enet_peer_send(clientPeer, 0, packet);
}

Message* GetMessage ()
{
	ENetEvent event;
	if (enet_host_service(clientHost, &event, 0))
	{
		Message* result = NULL;
		switch (event.type)
		{
			case ENET_EVENT_TYPE_CONNECT:
				break;
			case ENET_EVENT_TYPE_DISCONNECT:
				Disconnect();
				break;
			case ENET_EVENT_TYPE_RECEIVE:
				result = MessageEncoding::Decode(event.packet);
				enet_packet_destroy(event.packet);
				break;
		}
		return result;
	}
	else
	{
		return NULL;
	}
}

}

}
