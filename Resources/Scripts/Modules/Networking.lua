--import('GlobalVars')
--import('PrintRecursive')

--[[
	These are functions that Lua needs if this computer is a client (or is a server, thus also a client)
--]]
client = {
	cmdQueue = {}, -- incoming messages

	receivedMsg = function()
		-- return a boolean on whether or not a message has come in from the server since the last time checked
		return #cmdQueue ~= 0
	end,

	readMsg = function()
		-- this function should read what's in the cmdQueue and do it (or call those functions to run)
		if #cmdQueue ~= 0 then
			oldCmds = deepcopy(cmdQueue)
			print("There's something in the command queue from the server!")
			for i = 1, #cmdQueue do
				table.remove(cmdQueue, 1)
			end
		end
		return oldCmds
	end,

	addMsg = function(msg)
		-- process the message and send it to the C++ side
		if not isMultiplayer then
			server.receiveMsg(msg)
		else
			-- send message to enet
		end
	end,

	receiveMsg = function(msg)
		-- get the client messages from enet
		if type(msg) == "table" then
			for i = 1, #msg + 1 do
				if cmdQueue == nil then
					cmdQueue = { msg }
				else
					cmdQueue[#cmdQueue + 1] = msg[i]
				end
			end
		else
			if cmdQueue == nil then
				cmdQueue = { msg }
			else
				cmdQueue[#cmdQueue + 1] = msg
			end
		end
	end
}

--[[
	These are functions that Lua needs if this computer is a server
--]]

server = {
	cmdQueue = {}, -- incoming messages

	receivedMsg = function()
		-- return a boolean on whether or not a message has come in from any client(s) since the last time checked
		return #cmdQueue ~= 0
	end,

	readMsg = function()
		-- read from cmdQueue what the client(s) sent
		if #cmdQueue ~= 0 then
			oldCmds = deepcopy(cmdQueue)
			print("There's something in the command queue from the client!")
			for i = 1, #cmdQueue do
				table.remove(cmdQueue, 1)
			end
		end
		return oldCmds
	end,

	addMsg = function(msg)
		-- process the message and send it to the C++ side
		if not isMultiplayer then
			client.receiveMsg(msg)
		else
			-- send message to enet
		end
	end,

	receiveMsg = function(msg)
		-- get the server's messages from enet
		if type(msg) == "table" then
			for i = 1, #msg + 1 do
				if cmdQueue == nil then
					cmdQueue = { msg }
				else
					cmdQueue[#cmdQueue + 1] = msg[i]
				end
			end
		else
			if cmdQueue == nil then
				cmdQueue = { msg }
			else
				cmdQueue[#cmdQueue + 1] = msg
			end
		end
	end
}