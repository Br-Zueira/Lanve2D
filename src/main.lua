-- Main.lua
local client = require 'modules.client'
local server = require 'modules.server'
local Player = require 'modules.player'

local isServer = false

local selfPlayer = {}

local playerList = {}

function love.load(args)
    -- Decides whether the game instance will be a server or a client
    if args[1] == "server" then
        isServer = true
        love.window.setTitle("Lanve2D: Server")
    else
        love.window.setTitle("Lanve2D: Client")
    end

    -- Physics setup
    love.physics.setMeter(32)
    World = love.physics.newWorld(0, 0, true)

    -- Creates the game instance player
    selfPlayer = Player.new(0, 0)
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
        playerList = client.clientUpdate(selfPlayer, inputs, dt)
    end

    -- Updates physics
    World:update(dt)
end

function love.draw()
    -- Resets color
    love.graphics.setColor(0.0, 0.0, 0.0, 1.0)

    -- Different ways of accessing the player:draw function depending if its server or client
    if isServer then
        selfPlayer:draw(selfPlayer.x, selfPlayer.y)
        for _, client in pairs(playerList) do
            client.player:draw(selfPlayer.x, selfPlayer.y)
        end
    else
        for _, player in pairs(playerList) do
            player:draw(selfPlayer.x, selfPlayer.y)
        end
        client.selectServerUI()
    end
end