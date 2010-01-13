-- These are functions that Lua needs if this computer is a client (or is a server, thus also a client)

local cmdQueue = {} -- incoming messages

function sendToServer()
	-- return a boolean indicating successful sending to the server or not
		-- on a local game, sendToServer should work in coordination with Server.lua
end

function receivedFromServer()
	-- return a boolean on whether or not a message has come in from the server since the last time checked
	-- if true, put the messages into cmdQueue
end

function doServerCmds()
	-- this function should read what's in the cmdQueue and do it (or call those functions to run)
end

function addClientMsg(msg)
	-- process the message and send it to the C++ side
	-- for singleplayer, do not send to C++, instead send it to...?
end