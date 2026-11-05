local client = require 'modules.client'
local server = require 'modules.server'

local isServer = false

function love.load(args)
    if args[1] == "server" then
        isServer = true
        love.window.setTitle("Lanve2D: Server")
    else
        love.window.setTitle("Lanve2D: Client")
    end
end

function love.update(dt)
    vw, vh = love.graphics.getDimensions()
    if isServer then
        server()
    else
        client()
    end
end

function love.draw()
    love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
end