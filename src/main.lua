-- Main.lua
local client = require 'modules.client'
local server = require 'modules.server'
local Player = require 'modules.player'

local isServer = false

local selfPlayer = Player.new(400, 300)

local playerList = {}

function love.load(args)
    if args[1] == "server" then
        isServer = true
        love.window.setTitle("Lanve2D: Server")
    else
        love.window.setTitle("Lanve2D: Client")
    end
end

function love.update(dt)
    VW, VH = love.graphics.getDimensions()

    -- Captures every input
    local inputs = {}

    if love.keyboard.isDown('w') then table.insert(inputs, 'w') end
    if love.keyboard.isDown('a') then table.insert(inputs, 'a') end
    if love.keyboard.isDown('s') then table.insert(inputs, 's') end
    if love.keyboard.isDown('d') then table.insert(inputs, 'd') end

    -- Updates itself first
    selfPlayer:update(dt, inputs)

    -- Updates players (the way of doing it depends if its the host or a client)
    if isServer then
        playerList = server(selfPlayer, dt)
    else
        playerList = client(selfPlayer, inputs)
    end
end

function love.draw()
    -- Resets color
    love.graphics.setColor(0.0, 0.0, 0.0, 1.0)

    -- Different ways of accessing the player:draw function depending if its server or client
    if isServer then
        selfPlayer:draw()
        for _, client in pairs(playerList) do
            client.player:draw()
        end
    else
        for _, player in pairs(playerList) do
            player:draw()
        end
    end
end