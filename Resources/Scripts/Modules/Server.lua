import('Server.lua')
import('GlobalVars.lua')

-- These are functions that Lua needs if this computer is a server

local cmdQueue = {} -- incoming messages

function receivedFromClients()
	-- return a boolean on whether or not a message has come in from any client(s) since the last time checked
	return #cmdQueue ~= 0
end

function readClientMsgs()
	-- read from cmdQueue what the client(s) sent
		while cmdQueue[1] ~= nil do
			print(cmdQueue[1])
			table.remove(1, cmdQueue)
		end
end

function addServerMsg(msg)
	-- process the message and send it to the C++ side
	if not isMultiplayer then
		receiveServerMsg(msg)
	else
		
	end
end

function receiveClientMsg(msg)
	-- get the client messages from enet
	if msg.type == table then
		for i = 1 to #msg + 1 do
			cmdQueue.add(msg[i])
		end
	else
		cmdQueue.add(msg)
	end
end