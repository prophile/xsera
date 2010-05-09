#include "Logging.h"
#include <stdio.h>

namespace XNet
{

namespace Plugins
{

Logging::Logging()
{
	fprintf(stderr, "[%p] Logging plugin constructed\n", this);
}

Logging::~Logging()
{
	fprintf(stderr, "[%p] Logging plugin destroyed\n", this);
}

void Logging::DidAttach()
{
	fprintf(stderr, "[%p] Logging plugin attached\n", this);
}

void Logging::DidDetach()
{
	fprintf(stderr, "[%p] Logging plugin detached\n", this);
}

void Logging::DidConnect(ConnectionID connectionID, const std::string& hostname, uint16_t port)
{
	fprintf(stderr, "[%p] Connection %d established to %s port %d\n", this, connectionID, hostname.c_str(), port);
	Plugin::DidConnect(connectionID, hostname, port);
}

void Logging::DidDisconnect(ConnectionID connectionID)
{
	fprintf(stderr, "[%p] Connection %d broken\n", this, connectionID);
	Plugin::DidDisconnect(connectionID);
}

void Logging::DidReceiveMessage(ConnectionID connectionID, const Message& message)
{
	fprintf(stderr, "[%p] Got message %d from connection %d, content: %s\n", this, message.id, connectionID, message.data.c_str());
	Plugin::DidReceiveMessage(connectionID, message);
}

bool Logging::AuditConnection(const std::string& hostname, uint16_t port)
{
	fprintf(stderr, "[%p] Auditing incoming connection from %s port %d\n", this, hostname.c_str(), port);
	return Plugin::AuditConnection(hostname, port);
}

bool Logging::AuditOutgoingMessage(ConnectionID connectionID, const Message& message)
{
	fprintf(stderr, "[%p] Auditing message %d to connection %d, content: %s\n", this, message.id, connectionID, message.data.c_str());
	return Plugin::AuditOutgoingMessage(connectionID, message);
}

}

}
