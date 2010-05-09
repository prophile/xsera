#include "Test.h"
#include <arpa/inet.h>

using namespace XNet;

int main()
{
	LocalOnlySocketProvider* provider = new LocalOnlySocketProvider();
	Socket* sender = provider->NewSocket(1025);
	Socket* receiver = provider->NewSocket(1026);
	uint32_t localhost = provider->ResolveHost("localhost");
	ASSERT_NOT_EQUAL(localhost, 0, "failed to look up localhost");
	sender->Send(localhost, 1026, (const void*)"blah", 4);
	uint32_t receiveHost;
	uint16_t receivePort;
	size_t receiveLength;
	void* receiveData = receiver->Receive(receiveHost, receivePort, receiveLength);
	ASSERT_NOT_NULL(receiveData, "failed to receive message");
	ASSERT_EQUAL(receivePort, 1025, "got message on wrong port (expected 1025, got " << receivePort << ")");
	ASSERT_EQUAL(receiveHost, localhost, "got message from wrong host");
	ASSERT_EQUAL(0, memcmp(receiveData, (const void*)"blah", 4), "got wrong data");
	free(receiveData);
	delete receiver;
	delete sender;
	delete provider;
	return 0;
}
