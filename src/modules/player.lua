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

    for _, input in ipairs(inputs) do
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

    end

    self.x = self.x + (self.speedX * dt)
    self.y = self.y + (self.speedY * dt)
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

return Player