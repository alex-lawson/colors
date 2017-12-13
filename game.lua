Game = class()

function Game:init()
    -- math.randomseed(1)
    math.randomseed(os.time())
    self.canvas = love.graphics.newCanvas()
    MainCamera.view_center = MainCamera.screen_center

    self.auto_cycle_time = 2
    self.auto_cycle_timer = 0
    self.auto_cycle_enabled = false

    self:generate_new_palette()
end

function Game:update(dt)
    if self.auto_cycle_enabled then
        self.auto_cycle_timer = self.auto_cycle_timer - dt
        if self.auto_cycle_timer <= 0 then
            self:generate_new_palette()
            self.auto_cycle_timer = self.auto_cycle_time
        end
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
    elseif key == "return" then
        self.auto_cycle_enabled = not self.auto_cycle_enabled
        self.auto_cycle_timer = self.auto_cycle_time
    elseif key == "f12" then
        local screenshot = love.graphics.newScreenshot();
        math.randomseed(os.time())
        local ss_name = string.format("%08d.png", math.random(1, 99999999))
        screenshot:encode('png', ss_name);
        Log:message("Screenshot saved as %s", love.filesystem.getSaveDirectory() .. '/' .. ss_name)
    end
end

function Game:key_released(key)

end

function Game:generate_new_palette()
    self.palette_tones = math.random(3, 4)
    self.palette_values = math.random(4, 5)

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
