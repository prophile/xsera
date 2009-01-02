#include "Net.h"
#include <enet/enet.h>

namespace Net
{

namespace MessageEncoding
{

ENetPacket* Encode ( const Message& message );
Message* Decode ( ENetPacket* packet );

}

}
