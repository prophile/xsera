#include "Net.h"
#include "enetadapt.h"

namespace Net
{

namespace MessageEncoding
{

ENetPacket* Encode ( const Message& message );
Message* Decode ( ENetPacket* packet );

}

}
