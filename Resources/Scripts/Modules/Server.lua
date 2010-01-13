-- These are functions that Lua needs if this computer is a server

local cmdQueue = {} -- incoming messages

function sendToClients()
	-- return a boolean indicating successful sending to the client(s) or not
		-- on a local game, sendToClients should work in coordination with Client.lua
end

function receivedFromClients()
	-- return a boolean on whether or not a message has come in from any client(s) since the last time checked
	-- if true, put the messages into cmdQueue
end

function readClientMsgs()
	-- read from cmdQueue what the client(s) sent
end

function addServerMsg(msg)
	-- process the message and send it to the C++ side
	-- for singleplayer, do not send to C++, instead send it to...?
end