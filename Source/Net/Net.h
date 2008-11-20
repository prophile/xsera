#ifndef __xsera_net_h
#define __xsera_net_h

#include <string>
#include <string.h>

namespace Net
{

struct Message
{
	Message ( std::string _message, void* _data, size_t _len ) : message(_message), dataLength(_len), clientID(0) { data = malloc(_len); memcpy(data, _data, _len); }
	~Message () { free(data); }
	unsigned int clientID; // only for server use
	std::string message;
	void* data;
	size_t dataLength;
};

namespace Client
{

void Connect ( const std::string& host, unsigned short port, const std::string& password );
void Disconnect ();
bool IsConnected ();

void SendMessage ( const Message& msg );
Message* GetMessage ();

}

namespace Server
{

void Startup ( unsigned short port, const std::string& password );
void Shutdown ();
bool IsRunning ();
unsigned ClientCount ();

void KillClient ( unsigned int clientID );
bool IsConnected ( unsigned int clientID );

void SendMessage ( unsigned int clientID, const Message& msg );
void BroadcastMessage ( const Message& msg );
Message* GetMessage ();

}

}

#endif