-- Player.lua
local Player = {
    size = 32,
    speed = 256,
    color = {1.0, 1.0, 1.0, 1.0},
    x = 0, y = 0,
    speedX = 0, speedY = 0
}
Player.__index = Player

function Player.new(x, y, customColor)
    local self = {}
    setmetatable(self, Player)
    self.x = x
    self.y = y
    if customColor then self.color = customColor end
    return self
end

function Player:update(dt, inputs)
    self.speedX = 0
    self.speedY = 0

    local alreadyProcessed = {}
    for _, input in ipairs(inputs) do
        if not alreadyProcessed[input] then
            alreadyProcessed[input] = true

            if input == 'd' then
                self.speedX = self.speedX + self.speed
            end

            if input == 'a' then
                self.speedX = self.speedX - self.speed
            end

            if input == 's' then
                self.speedY = self.speedY + self.speed
            end

            if input == 'w' then
                self.speedY = self.speedY - self.speed
            end

            table.insert(alreadyProcessed, input)
        end
    end

    -- Vector normalization to avoid diagonal faster than self.speed
    local length = math.sqrt(self.speedX ^ 2 + self.speedY ^ 2)
    if length > 0 then
        self.speedX = self.speedX / length * self.speed
        self.speedY = self.speedY / length * self.speed
    end

    self.x = self.x + (self.speedX * dt)
    self.y = self.y + (self.speedY * dt)
end

function Player:draw(offsetX, offsetY)
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill',
        -- Centralize camera on player and draws every other player relative to it
        self.x - offsetX + VW / 2 - self.size / 2,
        self.y - offsetY + VH / 2 - self.size / 2,
    self.size, self.size)
end

return Player