#include "XNet.h"
#include "DataSerialiser.h"
#include <string.h>
#include <stdlib.h>

namespace XNet
{

void* Message::Encode(size_t& length) const
{
	DataSerialiser serialiser;
	serialiser << id << data;
	serialiser.Sync();
	const void* buf = serialiser.DataValue(length);
	void* buffer = malloc(length);
	memcpy(buffer, buf, length);
	return buffer;
}

Message Message::Decode(const void* data, size_t length)
{
	Message aMessage;
	//DataUnserialiser unserialiser(data, length);
	//unserialiser >> aMessage.id;
	//unserialiser >> aMessage.data;
	return aMessage;
}

}
