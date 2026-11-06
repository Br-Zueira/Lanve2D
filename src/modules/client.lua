-- Client.lua
local Player = require "modules.player"
local enet = require "enet"
local host = enet.host_create()
local server = host:connect("localhost:6789")

local myId = nil
local playerList = {}

local function clientUpdate(selfPlayer, inputs)
    local event = host:service(0)
    while event do
        if event.type == "receive" then
            local newId = event.data:match("^your_id:(%d+)$")
            if newId then
                myId = tonumber(newId)
            end

            local id, x, y = event.data:match("^update_player:(%d+):([%d%.%-]+):([%d%.%-]+)$")
            if id and x and y then
                id = tonumber(id)
                x = tonumber(x)
                y = tonumber(y)
                if playerList[id] then
                    playerList[id].x = x
                    playerList[id].y = y
                elseif id == myId then
                    playerList[id] = selfPlayer
                    selfPlayer.x = x
                    selfPlayer.y = y
                else
                    playerList[id] = Player.new(x, y, {1.0, 0.0, 0.0, 1.0})
                end
            end

            local disconnectedId = event.data:match("^player_disconnected:(%d+)$")
            if disconnectedId then
                disconnectedId = tonumber(disconnectedId)
                playerList[disconnectedId] = nil
            end
        elseif event.type == "connect" then
            event.peer:send("ping")
        elseif event.type == "disconnect" then
            myId = nil
            playerList = {}
        end
        event = host:service(0)
    end

    server:send("input:" .. table.concat(inputs, " "))

    return playerList
end

return clientUpdate