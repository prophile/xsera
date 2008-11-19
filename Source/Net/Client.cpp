#include <enet/enet.h>
#include "Net.h"

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
	size_t packetLength = 2 + msg.message.length() + 4 + msg.dataLength;
	unsigned char* packetData = (unsigned char*)malloc(packetLength);
	
	uint16_t messageIDLength = msg.message.length();
	messageIDLength = htons(messageIDLength);
	memcpy(packetData, &messageIDLength, 2);
	memcpy(packetData + 2, msg.message.data(), msg.message.length());
	uint32_t messagePayloadLength = msg.dataLength;
	messagePayloadLength = htonl(messagePayloadLength);
	memcpy(packetData + 2 + msg.message.length(), &messagePayloadLength, 4);
	memcpy(packetData + 2 + msg.message.length() + 4, msg.data, msg.dataLength);
	
	ENetPacket* packet = enet_packet_create(packetData, packetLength, ENET_PACKET_FLAG_RELIABLE);
	enet_peer_send(clientPeer, 0, packet);
	free((void*)packetData);
}

static Message* HandlePacket ( const unsigned char* data, size_t length )
{
	// todo: this needs security
	uint16_t messageIDLength;
	memcpy(&messageIDLength, data, 2);
	messageIDLength = ntohs(messageIDLength);
	char* messageID = (char*)alloca(messageIDLength + 1);
	messageID[messageIDLength] = 0;
	memcpy(messageID, data + 2, messageIDLength);
	uint32_t messageLength;
	memcpy(&messageLength, data + 2 + messageIDLength, 4);
	messageLength = ntohl(messageLength);
	void* messageBuffer = malloc(messageLength);
	memcpy(messageBuffer, data + 2 + messageIDLength + 4, messageLength);
	Message* result = new Message(std::string(messageID, messageIDLength), messageBuffer, messageLength);
	free(messageBuffer);
	return result;
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
				result = HandlePacket((const unsigned char*)event.packet->data, event.packet->dataLength);
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
