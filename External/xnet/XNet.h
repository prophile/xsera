#ifndef __XNET__
#define __XNET__

#include <string>
#include <map>
#include "System/SocketProvider.h"
#include <inttypes.h>

namespace XNet
{

typedef uint16_t MessageID;
typedef unsigned int ConnectionID;

const ConnectionID NOBODY = 0;

class Peer;

struct Message
{
private:
	std::map<std::string, std::string>* metadata;
public:
	MessageID id;
	std::string data;
	bool reliable, ordered, sequenced;

	Message(MessageID mid = 0, const std::string& payload = "", bool isReliable = true, bool isOrdered = true, bool isSequenced = false)
	: id(mid),
	  data(payload),
	  reliable(isReliable),
	  ordered(isOrdered),
	  sequenced(isSequenced),
	  metadata(0)
	{
	}

	Message(const Message& om)
	: id(om.id),
	  data(om.data),
	  reliable(om.reliable),
	  ordered(om.ordered),
	  sequenced(om.sequenced)
	{
		if (om.metadata)
		{
			metadata = new std::map<std::string, std::string>(*om.metadata);
		}
		else
		{
			metadata = 0;
		}
	}
	
	~Message()
	{
		if (metadata) delete metadata;
	}

	std::string GetMetadata(const std::string& key) const
	{
		if (!metadata) return "";
		std::map<std::string, std::string>::const_iterator iter;
		if ((iter = metadata->find(key)) == metadata->end())
		{
			return "";
		}
		else
		{
			return iter->second;
		}
	}

	void SetMetadata(const std::string& key, const std::string& value)
	{
		if (!metadata)
			metadata = new std::map<std::string, std::string>();
		metadata->insert(std::make_pair(key, value));
	}

	void CopyMetadata(const Message& source)
	{
		ordered = source.ordered;
		reliable = source.reliable;
		sequenced = source.sequenced;
		if (metadata)
			delete metadata;
		if (source.metadata)
			metadata = new std::map<std::string, std::string>(*(source.metadata));
		else
			metadata = 0;
	}

	void* Encode(size_t& length) const;
	static Message Decode(const void* data, size_t length);
};

class Plugin
{
private:
	friend class Peer;
	Plugin* lower;
	Plugin* higher;
	Peer* peer;
protected:
	Plugin* NextLower() const;
	Plugin* NextHigher() const;
public:
	Plugin();
	virtual ~Plugin() = 0;

	Peer* AttachedPeer() const { return peer; }

	// called on all plugins
	virtual void Update(unsigned long dt);
	// called on all plugins
	virtual void DidAttach();
	// called on all plugins
	virtual void DidDetach();
	// lower->higher
	virtual void DidConnect(ConnectionID connectionID, const std::string& hostname, uint16_t port);
	// lower->higher
	virtual void DidDisconnect(ConnectionID connectionID);
	// lower->higher
	virtual void DidReceiveMessage(ConnectionID connectionID, const Message& message);
	// higher->lower
	virtual bool AuditConnection(const std::string& hostname, uint16_t port);
	// higher->lower
	virtual bool AuditOutgoingMessage(ConnectionID connectionID, const Message& message);
};

class Peer
{
private:
	Plugin* highestPlugin;
	Plugin* lowestPlugin;
	SocketProvider* socketProvider;
	Socket* primarySocket;
	bool acceptNewConnections;
	std::map<ConnectionID, std::pair<uint32_t, uint16_t> > connections;
	ConnectionID nextConnectionID;
public:
	Peer(SocketProvider* provider, uint16_t port);
	~Peer();

	void Update(unsigned long dt);
	void BeginListening() { acceptNewConnections = true; }
	void EndListening() { acceptNewConnections = false; }
	bool Connect(const std::string& remote, uint16_t port);
	void Disconnect(ConnectionID connection);
	void SendMessage(const Message& message,
	                 ConnectionID target,
	                 Plugin* source = NULL);
	Plugin* HighestPlugin() const { return highestPlugin; }
	Plugin* LowestPlugin() const { return lowestPlugin; }
	void AttachPlugin(Plugin* plugin, Plugin* lowerThan = NULL);
	void DetachPlugin(Plugin* plugin);
	void ReceiveMessage(ConnectionID source, const Message& message, Plugin* plugin = NULL);
};

}

#endif
