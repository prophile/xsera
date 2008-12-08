#include "MessageDecode.h"
#include <string.h>

namespace Net
{

namespace MessageEncoding
{

ENetPacket* Encode ( const Message& msg )
{
	size_t packetLength = 2 + msg.message.length() + 4 + msg.dataLength;
	unsigned char* packetData = (unsigned char*)malloc(packetLength);
	
	uint16_t messageIDLength = msg.message.length();
	messageIDLength = htons(messageIDLength);
	memcpy(packetData, &messageIDLength, 2);
	memcpy(packetData + 2, msg.message.data(), msg.message.length());
	uint32_t messagePayloadLength = msg.dataLength;
	messagePayloadLength = htonl(messagePayloadLength);
	memcpy(packetData + 2 + msg.message.length(), &messagePayloadLength, 4);
	if (messagePayloadLength)
		memcpy(packetData + 2 + msg.message.length() + 4, msg.data, msg.dataLength);
	
	ENetPacket* packet = enet_packet_create(packetData, packetLength, ENET_PACKET_FLAG_RELIABLE);
	
	free((void*)packetData);
	
	return packet;
}

Message* Decode ( ENetPacket* packet )
{
	// todo: this needs security
	const unsigned char* data = (const unsigned char*)packet->data;
	uint16_t messageIDLength;
	memcpy(&messageIDLength, data, 2);
	messageIDLength = ntohs(messageIDLength); //find supposed length of messageID
	uint32_t messageLength;
	memcpy(&messageLength, data + 2 + messageIDLength, 4); //find supposed length of message data
	messageLength = ntohl(messageLength);
	
	if(messageIDLength + messageLength == packet->dataLength && messageIDLength < (packet->dataLength - 6)) //if its a valid message, interpret
	{
		char* messageID = (char*)alloca(messageIDLength + 1);
		messageID[messageIDLength] = 0;
		memcpy(messageID, data + 2, messageIDLength);
		bool goodMessage = true;
		int i;
		
		for(i = 0; i <= messageIDLength; i++) //check messageID contents
		{//......................0........9....||...................A........Z....||...................a.........z....||................ _
			
			if( (*messageID[i] >= 48 && *messageID[i]<= 57)  ||  (*messageID[i] >= 65 && *messageID[i] <= 90)  ||  (*messageID[i] >= 97 && *messageID[i] <= 122)  ||  (*messageID[i] == 95) )
			{
			}
			else 
			{
				goodMessage = false;
				break;
			}
			
		}
		
		if(goodMessage == true)	
		{
			void* messageBuffer = NULL;
				if (messageLength)
				{
					messageBuffer = malloc(messageLength);
					memcpy(messageBuffer, data + 2 + messageIDLength + 4, messageLength);
				}
				std::string messageIDString = std::string(messageID, messageIDLength);
		
		
				Message* result = new Message(messageIDString, messageBuffer, messageLength);
				free(messageBuffer);
				return result; //this is only reached if the message passes the tests
		}
	}
		return NULL; // invalid format
}

}

}
