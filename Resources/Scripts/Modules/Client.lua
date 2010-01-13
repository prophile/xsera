import('Server.lua')
import('GlobalVars.lua')

-- These are functions that Lua needs if this computer is a client (or is a server, thus also a client)

local cmdQueue = {} -- incoming messages

function receivedFromServer()
	-- return a boolean on whether or not a message has come in from the server since the last time checked
	return #cmdQueue ~= 0
end

function doServerCmds()
	-- this function should read what's in the cmdQueue and do it (or call those functions to run)
	if #cmdQueue ~= 0 then
		print("There's something in the command queue from the server!")
		for i = 1 in #cmdQueue do
			print(cmdQueue[1])
			table.remove(1, cmdQueue)
		end
	end
end

function addClientMsg(msg)
	-- process the message and send it to the C++ side
	if not isMultiplayer then
		receiveClientMsg(msg)
	else
		-- send message to enet
	end
end

function receiveServerMsg(msg)
	-- get the client messages from enet
	if msg.type == table then
		for i = 1 to #msg + 1 do
			cmdQueue.add(msg[i])
		end
	else
		cmdQueue.add(msg)
	end
end