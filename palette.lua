local hue_offset_range = {40, 60}
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

local apparent_brightness = {
    {0, 0.3},
    {60, 1.0},
    {120, 0.75},
    {180, 0.9},
    {210, 0.2},
    {240, 0},
    {300, 0.6},
    {360, 0.3}
}

function hue_apparent_brightness(hue)
    for i, p in ipairs(apparent_brightness) do
        if p[1] > hue then
            local last_p = apparent_brightness[i - 1]
            local ratio = (hue - last_p[1]) / (p[1] - last_p[1])
            return lerp(ratio, last_p[2], p[2])
        end
    end
end

local base_min_value = 0.25
local min_value_bab_influence = -0.15
local base_max_value = 1.0
local max_value_bab_influence = -0.10
local hue_top = 80
local hue_bottom = 225
local hueshift_amount = 45
local base_desaturate_threshold = 0.55
local desaturate_threshold_ab_influence = 0.15
local desaturate_amount = 0.65
local desaturate_ab_bonus = 0.10
local min_saturation = 0.20
local function ramp_from_hue(base_hue, base_saturation, num_values)
    if num_values == 1 then
        return {
            {base_hue, base_saturation, max_value}
        }
    end

    printf("creating ramp for hue %s", base_hue)

    local hueshift_dir
    if base_hue < hue_bottom and base_hue > hue_top then
        hueshift_dir = -1
    else
        hueshift_dir = 1
    end

    local bab = hue_apparent_brightness(base_hue)
    local min_value = base_min_value + bab * min_value_bab_influence
    local max_value = base_max_value + bab * max_value_bab_influence

    local ramp = {}
    for i = 1, num_values do
        local base_ratio = (i - 1) / (num_values - 1)
        local h = (base_hue + (base_ratio - 0.5) * hueshift_amount * hueshift_dir) % 360
        local ab = hue_apparent_brightness(h)

        local desaturate_threshold = base_desaturate_threshold + ab * desaturate_threshold_ab_influence

        local desaturate_ratio = math.max(0, (base_ratio - desaturate_threshold) / (1.0 - desaturate_threshold))
        local desaturate = desaturate_ratio * (desaturate_amount + ab * desaturate_ab_bonus)
        local s = math.max(min_saturation, base_saturation * (1.0 - desaturate))

        local value_ratio = clamp(base_ratio / desaturate_threshold, 0, 1)
        local v = lerp(value_ratio, min_value, max_value)

        printf("r %.2f, h %.2f s %.2f v %.2f, ab %.2f, min %.2f, max %.2f, desat %.2f", base_ratio, h, s, v, ab, min_value, max_value, desaturate_threshold)

        -- printf("adjusting hue %.2f for ratio %.2f", (base_ratio - 0.5) * hueshift_amount * hueshift_dir, base_ratio)

        local r, g, b = hsv_to_rgb(h, s, v)

        table.insert(ramp, {r, g, b})
    end

    return ramp
end

local base_saturation_range = {0.8, 1.0}
function make_palette(num_tones, num_values)
    local base_saturation = lerp(math.random(), base_saturation_range[1], base_saturation_range[2])

    local ramps = map(
        make_hues(num_tones),
        function(hue)
            return ramp_from_hue(hue, base_saturation, num_values)
        end)

    return ramps
end
