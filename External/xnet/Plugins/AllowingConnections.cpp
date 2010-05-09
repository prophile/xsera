#include "AllowingConnections.h"

bool XNet::Plugins::AllowingConnections::AuditConnection(const std::string& hostname, uint16_t port)
{
	return true;
}
