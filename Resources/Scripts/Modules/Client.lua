-- These are functions that Lua needs if this computer is a client (or is a server, thus also a client)

local msgQueue = {} -- outgoing messages
local cmdQueue = {} -- incoming messages

function sendToServer()
	-- return a boolean indicating successful sending to the server or not
		-- on a local game, sendToServer should work in coordination with Server.lua
	-- this should only execute on the pre-determined frequency (12Hz?) for multiplayer games
		-- does this mean that this function should check to see if the alloted time is up?
end

function receivedFromServer()
	-- return a boolean on whether or not a message has come in from the server since the last time checked
end

function doServerCmds()
	-- this function should read what's in the cmdQueue and do it (or call those functions to run)
end

function addMsg(msg)
	msgQueue[#msgQueue + 1] = msg
end