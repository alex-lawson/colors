Game = class()

function Game:init()
    math.randomseed(os.time())
    self.canvas = love.graphics.newCanvas()
    MainCamera.view_center = MainCamera.screen_center
    self.timer = 0
end

function Game:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self:generate_new_palette()
        self.timer = 2
    end
end

function Game:render_world()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0)
end

function Game:render_interface()

end

function Game:uninit()

end

function Game:mouse_pressed(pos, button)
    self:generate_new_palette()
end

function Game:mouse_released(pos, button)

end

function Game:mouse_wheel_moved(x, y)

end

function Game:key_pressed(key)
    if key == "space" then
        self:generate_new_palette()
    end
end

function Game:key_released(key)

end

function Game:generate_new_palette()
    self.palette_tones = math.random(2, 4)
    self.palette_values = math.random(3, 5)

    self.palette = make_palette(self.palette_tones, self.palette_values)

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    local w, h = love.graphics.getDimensions()
    local palette_size = self.palette_tones * self.palette_values
    local step_size = w / palette_size
    for t = 1, self.palette_tones do
        for v = 1, self.palette_values do
            love.graphics.setColor(unpack(self.palette[t][v]))

            local bar_num = (t - 1) * self.palette_values + v
            love.graphics.rectangle("fill", step_size * (bar_num - 1), 0, step_size * bar_num, h)
        end
    end

    love.graphics.setCanvas()
end
