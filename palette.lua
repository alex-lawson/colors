local hue_offset_range = {30, 60}
local function make_hues(hue_count)
    local base_hue = math.random() * 360

    if hue_count == 1 then
        -- monochromatic
        return {base_hue}
    elseif hue_count == 2 then
        -- complementary
        return {
            base_hue,
            (base_hue + 180) % 360
        }
    elseif hue_count == 3 then
        if math.random() < 0.5 then
            -- triadic
            local complement = base_hue + 180
            local offset = math.random(hue_offset_range[1], hue_offset_range[2])
            return {
                base_hue,
                (complement + offset) % 360,
                (complement - offset) % 360
            }
        else
            -- analogic
            local offset = math.random(hue_offset_range[1], hue_offset_range[2])
            return {
                base_hue,
                (base_hue + offset) % 360,
                (base_hue - offset) % 360
            }
        end
    elseif hue_count == 4 then
        if math.random() < 0.5 then
            -- tetradic
            local offset = math.random(hue_offset_range[1], hue_offset_range[2])
            return {
                base_hue,
                (base_hue + 180) % 360,
                (base_hue + offset) % 360,
                (base_hue + offset + 180) % 360
            }
        else
            -- accented analogic
            local offset = math.random(hue_offset_range[1], hue_offset_range[2])
            return {
                base_hue,
                (base_hue + 180) % 360,
                (base_hue + offset) % 360,
                (base_hue - offset) % 360
            }
        end
    else
        -- random
        local hues = {base_hue}
        while #hues < hue_count do
            base_hue = base_hue + math.random(hue_offset_range[1], hue_offset_range[2])
            table.insert(hues, base_hue)
        end
        return hues
    end
end

local min_value_range = {10, 15}
local max_value_range = {80, 95}
local temperature_ramp_range = {15, 25}
local top_desaturate_range = {30, 50}
local function ramp_from_hue(hue, base_saturation, num_values)
    local min_value = math.random(min_value_range[1], min_value_range[2])
    local max_value = math.random(max_value_range[1], max_value_range[2])

    if num_values == 1 then
        return {
            {hue, base_saturation, max_value}
        }
    end

    local temperature_ramp = math.random(temperature_ramp_range[1], temperature_ramp_range[2])

    local top_desaturate = math.random(top_desaturate_range[1], top_desaturate_range[2])

    local ramp = {}
    for i = 0, (num_values - 1) do
        local ratio = i / (num_values - 1)

        local this_saturation = base_saturation
        if ratio > 0.5 then
            this_saturation = math.max(0, this_saturation - (ratio - 0.5) * 2 * top_desaturate)
        end

        local r, g, b = hsv_to_rgb(
            hue,
            this_saturation,
            lerp(ratio, min_value, max_value))

        r2 = clamp(math.floor(r + temperature_ramp * (ratio - 0.5)), 0, 255)
        b2 = clamp(math.floor(b + temperature_ramp * (0.5 - ratio)), 0, 255)

        -- printf("adjusting r from %s to %s and b from %s to %s (ratio %.1f)", r, r2, b, b2, ratio)

        table.insert(ramp, {r2, g, b2})
    end

    return ramp
end

local base_saturation_range = {70, 100}
function make_palette(num_tones, num_values)
    local base_saturation = math.random(base_saturation_range[1], base_saturation_range[2])

    local ramps = map(
        make_hues(num_tones),
        function(hue)
            return ramp_from_hue(hue, base_saturation, num_values)
        end)

    return ramps
end

-- converts RGB values in the range of 0-255
-- to HSV values in the range of 0-360, 0-100, and 0-100 respectively
function rgb_to_hsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255

    local min = math.min(r, g, b)
    local max = math.max(r, g, b)

    if min == max then
        return 0, 0, max
    end

    local d = max - min

    local h
    if r == max then
        h = (g - b) / d
    elseif g == max then
        h = 2 + (b - r) / d
    else
        h = 4 + (r - g) / d
    end

    h = (h * 60) % 360

    local s = (d / max) * 100
    local v = max * 100

    return h, s, v
end

-- converts HSV values in the range of 0-360, 0-100, and 0-100 respectively
-- to RGB values in the range of 0-255
function hsv_to_rgb(h, s, v)
    h, s, v = h / 360, s / 100, v / 100

    local i = math.floor(h * 6) % 6
    local f = (h * 6) - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local r, g, b
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end
