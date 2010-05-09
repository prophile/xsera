#include "Test.h"

using namespace XNet;

int main()
{
	LocalOnlySocketProvider* provider = new LocalOnlySocketProvider();
	Peer* peer = new Peer(provider, 1025);

	ASSERT_NULL(peer->HighestPlugin(), "highest plugin is null on entry");
	ASSERT_NULL(peer->LowestPlugin(),  "lowest plugin is null on entry");

	Plugins::AllowingConnections* ACP = new Plugins::AllowingConnections();
	ASSERT_NOT_NULL(ACP, "failed to allocate first plugin");
	peer->AttachPlugin(ACP);

	ASSERT_EQUAL(peer->HighestPlugin(), ACP, "peer got incorrect highest plugin");
	ASSERT_EQUAL(peer->LowestPlugin(),  ACP, "peer got incorrect lowest plugin");

	delete peer;
	delete ACP;
	delete provider;
	return 0;
}
