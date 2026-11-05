local client = require 'modules.client'
local server = require 'modules.server'
local Player = require 'modules.player'

local isServer = false

local selfPlayer = Player.new(400, 300)

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

    local inputs = {}

    if love.keyboard.isDown('w') then table.insert(inputs, 'w') end
    if love.keyboard.isDown('a') then table.insert(inputs, 'a') end
    if love.keyboard.isDown('s') then table.insert(inputs, 's') end
    if love.keyboard.isDown('d') then table.insert(inputs, 'd') end

    selfPlayer:update(dt, inputs)

    if isServer then
        server()
    else
        client()
    end
end

function love.draw()
    love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
    selfPlayer:draw()
end