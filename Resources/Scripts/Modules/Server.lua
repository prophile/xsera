-- These are functions that Lua needs if this computer is a server

local msgQueue = {} -- outgoing messages
local cmdQueue = {} -- incoming messages

function sendToClients()
	-- return a boolean indicating successful sending to the client(s) or not
		-- on a local game, sendToClients should work in coordination with Client.lua
	-- this should only execute on the pre-determined frequency (12Hz?) for multiplayer games
		-- does this mean that this function should check to see if the alloted time is up?
end

function receivedFromClients()
	-- return a boolean on whether or not a message has come in from any client(s) since the last time checked
end

function readClientMsgs()
	-- read from cmdQueue what the client(s) sent
end

function addMsg(msg)
	msgQueue[#msgQueue + 1] = msg
end