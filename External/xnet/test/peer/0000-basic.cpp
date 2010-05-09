#include "Test.h"

using namespace XNet;

int main()
{
	LocalOnlySocketProvider* provider = new LocalOnlySocketProvider();
	ASSERT_NOT_NULL(provider, "failed to allocate socket provider");
	Peer* peer = new Peer(provider, 1025);
	ASSERT_NOT_NULL(peer, "failed to allocate peer");
	peer->Update(10);
	delete peer;
	delete provider;
	return 0;
}
