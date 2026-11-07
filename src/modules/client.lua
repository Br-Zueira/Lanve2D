-- Client.lua
local Player = require "modules.player"
local enet = require "enet"
local socket = require "socket"
local host = enet.host_create()

-- Local playerList (includes itself) and client's own id (yet to be received)
local myId = nil
local playerList = {}

-- Searches LAN for server
local server = nil
local serverList = {}
local isOnMatch = false

local discovery = socket.udp()
local discoveryTimer = 0
discovery:setoption("broadcast", true)
discovery:setsockname("*", 0)
discovery:settimeout(0)

local function clientUpdate(selfPlayer, inputs, dt)
    if not isOnMatch and not server then
        discoveryTimer = discoveryTimer + dt
        if discoveryTimer >= 2 then
            discoveryTimer = 0
            discovery:sendto("LANVE2D_DISCOVER", "127.0.0.1", 6788)
            discovery:sendto(
                "LANVE2D_DISCOVER",
                "255.255.255.255",
                6788
            )
            for ip, _ in pairs(serverList) do
                print("Found: " .. ip)
            end
        end
        while true do
            local message, ip, port = discovery:receivefrom()

            if not message then
                break
            end

            if message == "LANVE2D_HOST" then
                serverList[ip] = {
                    ip = ip,
                    port = port
                }
            end
        end
        return {}
    end

    serverList = {}

    -- Captures events
    local event = host:service(0)
    while event do
        -- If it received a message from the server
        if event.type == "receive" then
            -- If its a new id message, assigns it to itself
            local newId = event.data:match("^your_id:(%d+)$")
            if newId then
                myId = tonumber(newId)
            end

            -- If its an update player order, update the said player
            local id, x, y = event.data:match("^update_player:(%d+):([%d%.%-]+):([%d%.%-]+)$")
            if id and x and y then -- Ensures the fields aren't null
                id = tonumber(id)
                x = tonumber(x)
                y = tonumber(y)
                if playerList[id] then
                    -- Updates player data
                    playerList[id].x = x
                    playerList[id].y = y
                else
                    -- If its to update itself, adds itself to playerList
                    if id == myId then
                        playerList[id] = selfPlayer
                        selfPlayer.x = x
                        selfPlayer.y = y
                    else
                        -- If its a new player, create it
                        playerList[id] = Player.new(x, y, {1.0, 0.0, 0.0, 1.0})
                    end
                end
            end

            -- If its a player that disconnected, removes it from playerList
            local disconnectedId = event.data:match("^player_disconnected:(%d+)$")
            if disconnectedId then
                disconnectedId = tonumber(disconnectedId)
                playerList[disconnectedId] = nil
            end

        -- If it connected to a new server, pings it
        elseif event.type == "connect" then
            event.peer:send("ping")

        -- if it disconnected from a server, ensure match data is erased
        elseif event.type == "disconnect" then
            myId = nil
            playerList = {}
        end
        event = host:service(0)
    end

    -- Sends its own inputs every frame
    server:send("input:" .. table.concat(inputs, " "))

    return playerList
end

return clientUpdate