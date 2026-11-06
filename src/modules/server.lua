-- Server.lua
local Player = require "modules.player"
local enet = require "enet"
local host = enet.host_create("localhost:6789")

local playerList = {}
local nextId = 1

local function serverUpdate(selfPlayer, dt)
    local event = host:service(0)
    while event do
        if event.type == "receive" then
            local inputStr = event.data:match("^input:(.*)$")
            if inputStr then
                local inputList = {}
                for input in inputStr:gmatch("%S+") do
                    table.insert(inputList, input)
                end
                playerList[event.peer].inputs = inputList
            end
        elseif event.type == "connect" then
            event.peer:send("your_id:" .. nextId)
            local newPlayer =  Player.new(400, 300, {1.0, 0.0, 0.0, 1.0})
            playerList[event.peer] = { id=nextId, player=newPlayer, inputs={} }
            nextId = nextId + 1
        elseif event.type == "disconnect" then
            local player = playerList[event.peer]

            if player then
                host:broadcast("player_disconnected:" .. player.id)
                playerList[event.peer] = nil
            end
        end
        event = host:service(0)
    end

    host:broadcast("update_player:" .. 0 .. ":" .. selfPlayer.x .. ":" .. selfPlayer.y)
    for _, player in pairs(playerList) do
        if player.player then
            player.player:update(dt, player.inputs)
            host:broadcast(
                "update_player:" ..
                player.id .. ":" ..
                player.player.x .. ":" ..
                player.player.y
            )
        end
    end

    return playerList
end

return serverUpdate