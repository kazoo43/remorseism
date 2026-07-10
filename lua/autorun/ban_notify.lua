if SERVER then
	util.AddNetworkString("remorseism_ban_notify")

	hook.Add("ULibPlayerBanned", "remorseism_ban_notify", function(steamid, minutes, reason, admin, name)
		if minutes ~= 0 then return end

		local displayName = name or steamid
		local displayReason = (reason and reason ~= "") and reason or "No reason given"

		PrintMessage(HUD_PRINTTALK, displayName .. " has been permanently banned. Reason: " .. displayReason)

		net.Start("remorseism_ban_notify")
			net.WriteString(displayName)
			net.WriteString(displayReason)
		net.Broadcast()
	end)
end

if CLIENT then
	local banMsg = nil
	local DURATION = 5
	local FADE_IN = 0.4
	local SHAKE_DUR = 0.6

	sound.Add({
		name = "remorseism_banished",
		channel = CHAN_AUTO,
		volume = 1.0,
		level = 80,
		sound = "sound/rem_banished.ogg"
	})

	net.Receive("remorseism_ban_notify", function()
		banMsg = {
			name = net.ReadString(),
			reason = net.ReadString(),
			startTime = CurTime()
		}
		surface.PlaySound("sound/rem_banished.ogg")
	end)

	local fontCache = {}
	local function getFont(name, size, weight)
		if fontCache[name] then return end
		surface.CreateFont(name, { font = "Verily Serif Mono", size = size, weight = weight })
		fontCache[name] = true
	end

	hook.Add("HUDPaint", "remorseism_ban_notify", function()
		if not banMsg then return end

		local elapsed = CurTime() - banMsg.startTime
		if elapsed > DURATION then
			banMsg = nil
			return
		end

		local alpha
		if elapsed < FADE_IN then
			alpha = (elapsed / FADE_IN) * 255
		elseif elapsed > DURATION - 0.5 then
			alpha = ((DURATION - elapsed) / 0.5) * 255
		else
			alpha = 255
		end
		alpha = math.Clamp(alpha, 0, 255)

		local ox, oy = 0, 0
		if elapsed < SHAKE_DUR then
			local intensity = math.Lerp(elapsed / SHAKE_DUR, 14, 0)
			ox = math.random(-intensity, intensity)
			oy = math.random(-intensity, intensity)
		end

		local sw, sh = ScrW(), ScrH()
		local bigSize = math.Clamp(math.floor(sw / 22), 28, 96)
		local smallSize = math.Clamp(math.floor(sw / 32), 20, 64)
		local bigFont = "RBN_Big_" .. bigSize
		local smallFont = "RBN_Small_" .. smallSize

		getFont(bigFont, bigSize, 900)
		getFont(smallFont, smallSize, 700)

		local line1 = banMsg.name .. " has been permanently banned"
		local line2 = "Reason: " .. banMsg.reason
		local topY = sh * 0.06

		local blink = (math.sin(elapsed * 4) + 1) / 2
		local r1 = math.floor(math.Lerp(blink, 120, 220))
		local r2 = math.floor(math.Lerp(blink, 80,  180))

		local fadeAlpha = alpha
		if elapsed > DURATION - 1.5 then
			fadeAlpha = alpha * ((DURATION - elapsed) / 1.5)
		end
		fadeAlpha = math.Clamp(fadeAlpha, 0, 255)

		local function drawCentered(text, font, y, r, g, b)
			surface.SetFont(font)
			local tw = surface.GetTextSize(text)
			local x = sw / 2 - tw / 2
			draw.SimpleText(text, font, x + ox + 2, y + oy + 2, Color(0, 0, 0, fadeAlpha * 0.7), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(text, font, x + ox, y + oy, Color(r, g, b, fadeAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		drawCentered(line1, bigFont,   topY,                          r1, 0, 0)
		drawCentered(line2, smallFont, topY + bigSize + sh * 0.01,    r2, 0, 0)
	end)
end
