#include "Test.h"

using namespace XNet;

Peer* SetupPeer(SocketProvider* provider, uint16_t port)
{
	Peer* peer = new Peer(provider, port);
	// allocate plugins
	Plugins::AllowingConnections* plugin0 = new Plugins::AllowingConnections();
	Plugins::Logging* plugin1 = new Plugins::Logging();
	// attach plugins
	peer->AttachPlugin(plugin1);
	peer->AttachPlugin(plugin0);
	// return
	return peer;
}

class MessageReceiverPlugin : public XNet::Plugin
{
private:
	bool* flag;
public:
	MessageReceiverPlugin(bool* ptr) : flag(ptr) {}

	virtual void DidReceiveMessage(ConnectionID source, const Message& message)
	{
		if (message.id == MID_TEST_HARNESS_0)
		{
			fprintf(stderr, "GOT THE MESSAGE!\n");
			ASSERT_EQUAL(message.data, "moof", "message data got garbled");
			*flag = true;
			return;
		}
		ASSERT_UNREACHABLE("got the wrong message: " << message.id);
		Plugin::DidReceiveMessage(source, message);
	}
};

int main()
{
	bool received0 = false, received1 = false;

	SocketProvider* provider = new LocalOnlySocketProvider();
	Peer* peer0 = SetupPeer(provider, 1025);
	Peer* peer1 = SetupPeer(provider, 1026);

	ASSERT_NOT_NULL(peer0, "allocation of peer0 failed");
	ASSERT_NOT_NULL(peer1, "allocation of peer1 failed");

	peer0->AttachPlugin(new MessageReceiverPlugin(&received0));
	peer1->AttachPlugin(new MessageReceiverPlugin(&received1));

	std::cerr << "instructing peer1 to listen" << std::endl;	
	peer1->BeginListening();
	std::cerr << "instructing peer0 to connect" << std::endl;
	ASSERT_TRUE(peer0->Connect("localhost", 1026), "connection denied");

	std::cerr << "going into first update cycle" << std::endl;

	for (int i = 0; i < 50; ++i)
	{
		peer0->Update(10);
		peer1->Update(10);
	}

	std::cerr << "sending a single message each way" << std::endl;

	Message msg;
	msg.id = MID_TEST_HARNESS_0;
	msg.data = "moof";

	peer0->SendMessage(msg, 1);
	peer1->SendMessage(msg, 1);

	std::cerr << "going into second update cycle" << std::endl;

	for (int i = 0; i < 150; ++i)
	{
		peer0->Update(10);
		peer1->Update(10);
	}

	ASSERT_TRUE(received0, "peer0 failed to receive message");
	ASSERT_TRUE(received1, "peer1 failed to receive message");

	std::cerr << "leaving update cycle" << std::endl;

	delete peer1;
	delete peer0;

	delete provider;
	return 0;
}
