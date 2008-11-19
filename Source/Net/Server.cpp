#include <enet/enet.h>
#include "Net.h"

namespace Server
{

void Startup ( unsigned short port, const std::string& password );
void Shutdown ();
bool IsRunning ();
unsigned ClientCount ();

void KillClient ( unsigned int clientID );

void SendMessage ( unsigned int clientID, const Message& msg );
void BroadcastMessage ( const Message& msg );
Message* GetMessage ();

}
