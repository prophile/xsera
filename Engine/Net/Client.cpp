#include "Apollo.h"
#include "eNetAdapt.h"
#include "Net.h"
#include "MessageDecode.h"
#include <assert.h>
#include "Utilities/GameTime.h"

namespace Net
{

const uint32_t CLIENT_BANDWIDTH_LIMIT = 1024 * 16; // 16 kB/s

Client::Client ()
: clientHost(NULL), clientPeer(NULL), badMessageCount(0)
{
}

Client::~Client ()
{
	assert(!IsConnected());
}

void Client::Connect ( const std::string& host, unsigned short port, const std::string& password )
{
	if (clientHost)
	{
		Disconnect();
	}
	clientHost = enet_host_create(NULL, 1, CLIENT_BANDWIDTH_LIMIT, CLIENT_BANDWIDTH_LIMIT);
	ENetAddress addr;
	addr.port = htons(port);
	enet_address_set_host(&addr, host.c_str());
	clientPeer = enet_host_connect(clientHost, &addr, 1);
	assert(clientPeer);
}

void Client::Disconnect ()
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

bool Client::IsConnected ()
{
	return clientHost != NULL;
}

void Client::SendMessage ( const Message& msg )
{
	if (!clientPeer)
		return;
	ENetPacket* packet = MessageEncoding::Encode(msg);
	enet_peer_send(clientPeer, 0, packet);
}

void Client::BadMessage()
{
		float currentTime = GameTime();
		
		if(badMessageCount > 1) 
		{
			if( (currentTime - badMessages[badMessageCount]) < 10.0f || badMessageCount >= 4 ) 
			{
                // kick on 5th bad message or 2nd in 10 seconds
				Disconnect();
				return;
			}
			badMessageCount++;
			badMessages[badMessageCount] = currentTime;
		}
}
	
Message* Client::GetMessage ()
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
				if (result == NULL)
				{
				    BadMessage();
				}
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
