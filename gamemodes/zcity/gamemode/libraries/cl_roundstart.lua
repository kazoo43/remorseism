-- Shared "homicide-style" round start title card renderer.
-- Any submode can show the animated intro (slide/tilt easing, fade screen,
-- round-start sound) by calling hg.RoundStart.DrawTitle(...) in HUDPaint and
-- hg.RoundStart.Fade(...) in RenderScreenspaceEffects.

hg = hg or {}
hg.RoundStart = {
    duration = 10,
    sound = "rem_newroundcommence.mp3",
    soundEnabled = false,
}

local RS = hg.RoundStart

local lastRS = -1
local tilts = {}
local soundObj = nil

local function ease_out(x)
    return 1 - (1 - x) ^ 3
end

local function draw_text(text, fontname, x, y, r, g, b, a, ang, xalign, yalign)
    local m = Matrix()
    m:Translate(Vector(x, y, 0))
    m:Rotate(Angle(0, ang, 0))
    m:Translate(Vector(-x, -y, 0))

    cam.PushModelMatrix(m)
        draw.SimpleText(text, fontname, x, y, Color(r, g, b, a), xalign, yalign)
    cam.PopModelMatrix()
end

-- Initialise tilts + sound the first frame of a new round.
local function ensureRound(startTime, playSound)
    if startTime ~= lastRS then
        lastRS = startTime

        tilts = {}
        for i = 1, 64 do
            tilts[i] = (math.random() < 0.5) and 3 or -3
        end

        if soundObj then
            soundObj:Stop()
            soundObj = nil
        end

        if playSound and RS.sound and RS.sound ~= "" then
            soundObj = CreateSound(LocalPlayer(), RS.sound)
            if soundObj then soundObj:PlayEx(1, 100) end
        end
    end
end

local function stopSound()
    if soundObj then
        soundObj:Stop()
        soundObj = nil
    end
end

-- Draws the animated intro. content = {
--   header   = string (big title, e.g. mode name)
--   lines    = { {text=, color=, font=} }  (stacked under the header)
--   objective = string (bottom line)
--   color    = Color (accent for lines)
-- }
-- opts = { startTime = zb.ROUND_START, duration = 10 }
function hg.RoundStart.DrawTitle(content, opts)
    opts = opts or {}
    local startTime = opts.startTime or zb.ROUND_START or CurTime()
    local duration = opts.duration or RS.duration

    local t = CurTime() - startTime
    if t > duration then
        stopSound()
        return
    end

    if not lply or not IsValid(lply) then return end
    if lply:Team() == TEAM_SPECTATOR then return end

    ensureRound(startTime, opts.sound or RS.soundEnabled)
    if zb.RemoveFade then zb.RemoveFade() end

    local out_fade = math.Clamp((duration - t) / 1.5, 0, 1)
    if soundObj then soundObj:ChangeVolume(out_fade, 0) end

    local sw, sh = ScrW(), ScrH()

    RS.CursorLerpX = Lerp(FrameTime() * 6, RS.CursorLerpX or 0, (gui.MouseX() - sw * 0.5) / (sw * 0.5))
    RS.CursorLerpY = Lerp(FrameTime() * 6, RS.CursorLerpY or 0, (gui.MouseY() - sh * 0.5) / (sh * 0.5))

    local cursor_reach = ScreenScale(7)
    local cox = math.Clamp(RS.CursorLerpX, -1, 1) * cursor_reach
    local coy = math.Clamp(RS.CursorLerpY, -1, 1) * cursor_reach

    local color = content.color or Color(255, 255, 255)
    local elements = {}

    local function add(text, fontname, col, x, y, dir, delay, plx, notilt)
        elements[#elements + 1] = {
            text = text,
            font = fontname,
            r = col.r, g = col.g, b = col.b,
            x = x, y = y,
            dir = dir, delay = delay, plx = plx or 1,
            notilt = notilt,
        }
    end

    add(content.header or "", "ZB_HomicideHeader", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9)

    local cur_y = sh * 0.5
    local stack_delay = 0.7

    if content.lines then
        for _, line in ipairs(content.lines) do
            cur_y = cur_y + ScreenScale(20)
            add(line.text, line.font or "ZB_HomicideMediumLarge", line.color or color, sw * 0.5, cur_y, "right", stack_delay, 1.05)
            stack_delay = stack_delay + 0.15
        end
    end

    if content.objective and content.objective ~= "" then
        add(content.objective, "ZB_HomicideMedium", Color(255, 255, 255), sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true)
    end

    for i, el in ipairs(elements) do
        local appear = ease_out(math.Clamp((t - el.delay) / 2.0, 0, 1))
        local a = 255 * appear * out_fade

        if a > 1 then
            local slide = 1 - appear
            local x, y = el.x, el.y

            if el.dir == "left" then
                x = x - slide * ScreenScale(220)
            elseif el.dir == "right" then
                x = x + slide * ScreenScale(220)
            elseif el.dir == "bottom" then
                y = y + slide * ScreenScale(120)
            elseif el.dir == "top" then
                y = y - slide * ScreenScale(120)
            end

            x = x + cox * el.plx
            y = y + coy * el.plx

            local tilt = el.notilt and 0 or (tilts[i] or 3) * appear

            draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- Draws the black fade screen used during the intro.
-- opts = { startTime = zb.ROUND_START, duration = 10 }
function hg.RoundStart.Fade(opts)
    opts = opts or {}
    local startTime = opts.startTime or zb.ROUND_START or CurTime()
    local duration = opts.duration or RS.duration

    local time_diff = (startTime + duration) - CurTime()
    if time_diff <= 0 then return end

    local fade = math.min(time_diff / 2.5, 1)

    surface.SetDrawColor(0, 0, 0, 255 * fade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end
