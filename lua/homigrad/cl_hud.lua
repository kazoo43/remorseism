local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudDamageIndicator"] = true,
	["CHudGeiger"] = true,
	["CHudSquadStatus"] = true,
	["CHudTrain"] = true,
	["CHudZoom"] = true,
	["CHudSuitPower"] = true,
	["CHUDQuickInfo"] = true,
	["CHudHistoryResource"] = true,
}

local gordon_hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudSuitPower"] = true,
}

hook.Add("HUDShouldDraw", "homigrad", function(name)
	if hide[name] or lply.PlayerClassName and lply.PlayerClassName == "Gordon" and gordon_hide[name] then
		return false
	end
end)
hook.Add("HUDDrawTargetID", "homigrad", function()
	return false
end)

hook.Add("DrawDeathNotice", "homigrad", function()
	return false
end)

hook.Add("HUDWeaponPickedUp", "HidePickedStuff", function(wep)
	--if not IsValid(lply) or not lply:Alive() then return end
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	--[[if not IsValid(wep) then return end
	if not wep.GetPrintName then return end
	
	lply:Notify("+ " .. wep:GetPrintName(), 0)]]

	return false
end)

hook.Add("HUDAmmoPickedUp", "HidePickedStuff", function(ammoname, amt)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

hook.Add("HUDItemPickedUp", "HidePickedStuff", function(itemname)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

hook.Add("HUDDrawPickupHistory", "HidePickedStuff", function()
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font_default = "Lora"
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", hg_font_default, true, false, "Change UI text font")
local hg_oldradialmenu = ConVarExists("hg_oldradialmenu") and GetConVar("hg_oldradialmenu") or CreateClientConVar("hg_oldradialmenu", "0", true, false, "Use the old radial menu style", 0, 1)

if hg_font:GetString() != hg_font_default then
	RunConsoleCommand("hg_font", hg_font_default)
end

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Courier Prime"
    return hg_font_default
end

--atlaschat.coolvetica
surface.CreateFont("HomigradFont", {
	font = font(),
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

surface.CreateFont("ScoreboardPlayer", {
	font = font(),
	size = ScreenScale(7),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBig", {
	font = font(),
	size = ScreenScale(12),
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("HomigradFontMedium", {
	font = font(),
	size = ScreenScale(8),
	weight = 1100,
	outline = false,
})

surface.CreateFont("HomigradFontRadialOld", {
	font = font(),
	size = ScreenScale(11),
	weight = 1100,
	outline = false,
})

surface.CreateFont("HomigradFontRadialCenter", {
	font = font(),
	size = ScreenScale(14),
	weight = 1100,
	outline = false,
})

surface.CreateFont("HomigradFontLarge", {
	font = font(),
	size = ScreenScale(15),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontGigantoNormous", {
	font = font(),
	size = ScreenScale(25),
	weight = 1100,
	outline = false,
	shadow = false
})

surface.CreateFont("HomigradFontSmall", {
	font = font(),
	size = 17,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontVSmall", {
	font = font(),
	size = 12,
	weight = 400,
	outline = false
})

surface.CreateFont("ZCity_Veteran", {
	font = "x14y24pxHeadUpDaisy",
	size = ScreenScale(10),
	weight = 500,
	outline = false
})

local w, h

hook.Add("HUDPaint", "homigrad-dev", function()
	if engine.ActiveGamemode() ~= "sandbox" then return end
	w, h = ScrW(), ScrH()
end)

--draw.SimpleText(lply:Health(),"HomigradFontBig",100,h - 50,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
function draw.CirclePart(x, y, radius, seg, parts, pos)
	local cir = {}
	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360 / parts - pos * 360 / parts) + math.pi
		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
		--draw.DrawText("asd","HomigradFontBig",x + math.sin(a) * radius,y + math.cos(a) * radius)
	end

	--local a = math.rad(0)
	--table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(cir)
	render.PopFilterMin()
end

if IsValid(MENUPANELHUYHUY) then
	MENUPANELHUYHUY:Remove()
	MENUPANELHUYHUY = nil
end

hg.radialOptions = hg.radialOptions or {}
local colBlack = Color(0, 0, 0, 152)
local colOption = Color(40, 0, 55, 152)
local colWhite = Color(255, 255, 255, 255)
local colWhiteTransparent = Color(176, 40, 40, 100)
local colTransparent = Color(0, 0, 0, 0)
local matHuy = Material("vgui/white")
local vecXY = Vector(0, 0)
local vecDown = Vector(0, 1)
local isMouseIntersecting = false
local isMouseOnRadial = false
local current_option = 1
local current_option_select = 1
local hook_Run = hook.Run

local incoentCol = Color(128,0,0)
local taitorCol = Color(155,0,0)

local menuPanel

local colBack = Color(0,0,0)
local surface, draw, hook, IsColor, IsValid, math, input = surface, draw, hook, IsColor, IsValid, math, input
local radialBackgroundColor = Color(0, 0, 0, 220)
local radialRingColor = Color(0, 0, 0, 255)
local radialInnerColor = Color(0, 0, 0, 0)
local radialOutlineColor = Color(255, 255, 255, 255)
local radialTextColor = Color(245, 245, 245, 255)
local radialFallbackTextColor = Color(18, 18, 18, 255)
local radialCenterTextAlpha = 0
local radialDrawSegments = 144
local radialSpinAngle = 0
local radialSpinSpeed = 10
local radialRollDrumSpinDuration = 0.32
local radialRollDrumSpinAngle = 540
local oldRadialSliceColor = Color(26, 26, 30, 170)
local oldRadialHoverColor = Color(230, 230, 235, 95)
local oldRadialTextColor = Color(245, 245, 245, 255)
local oldRadialIconSizeMul = 0.05
local oldRadialTextRadiusMul = 0.76
local oldRadialLabelGap = 0.008
local radialModernRadiusMul = 0.215
local radialModernInnerRadiusMul = 0.84
local radialModernIconSizeMul = 0.09
local radialModernHudScaleStrength = 0.3
local radialCenterTextWidthMul = 1.62
local radialCenterTextScaleMin = 0.5
local radialCenterTextScaleMax = 1.05
local radialIconMaterials = {
	["weapon menu"] = Material("radialmenu/weaponmenu.png", "smooth mips"),
	["attachments menu"] = Material("radialmenu/attachments.png", "smooth mips"),
	["drop equipment"] = Material("radialmenu/droparmor.png", "smooth mips"),
	["inspect"] = Material("radialmenu/inspect.png", "smooth mips"),
	["drop weapon"] = Material("radialmenu/dropstuff.png", "smooth mips"),
	["drop ammo"] = Material("radialmenu/dropammo.png", "smooth mips"),
	["do phrase rmb menu"] = Material("radialmenu/scream.png", "smooth mips"),
	["change posture rmb menu"] = Material("radialmenu/changeposture.png", "smooth mips"),
	["reset posture"] = Material("radialmenu/resetposture.png", "smooth mips"),
	["yell in pain"] = Material("radialmenu/scream.png", "smooth mips"),
	["moan in pain"] = Material("radialmenu/scream.png", "smooth mips"),
	["meow"] = Material("radialmenu/scream.png", "smooth mips"),
	["do gesture rmb menu"] = Material("radialmenu/surrender.png", "smooth mips"),
	["unload"] = Material("radialmenu/unload.png", "smooth mips"),
	["roll drum"] = Material("radialmenu/spindrum.png", "smooth mips"),
	["fix dislocation"] = Material("radialmenu/broken.png", "smooth mips"),
}

local function NormalizeRadialText(txt)
	txt = string.lower((txt or ""):gsub("\n", " "))
	txt = txt:gsub("[^%w%s]", "")
	txt = txt:gsub("%s+", " ")
	return string.Trim(txt)
end

local function DrawFilledCircle(x, y, radius, segments, color)
	local poly = {
		{
			x = x,
			y = y
		}
	}

	for i = 0, segments do
		local ang = math.rad((i / segments) * -360)
		poly[#poly + 1] = {
			x = x + math.sin(ang) * radius,
			y = y + math.cos(ang) * radius
		}
	end

	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(poly)
end

local function DrawCircleRing(x, y, innerRadius, outerRadius, segments, color)
	draw.NoTexture()
	surface.SetDrawColor(color)

	for i = 0, segments - 1 do
		local ang1 = math.rad((i / segments) * -360)
		local ang2 = math.rad(((i + 1) / segments) * -360)
		local sin1 = math.sin(ang1)
		local cos1 = math.cos(ang1)
		local sin2 = math.sin(ang2)
		local cos2 = math.cos(ang2)

		surface.DrawPoly({
			{ x = x + sin1 * outerRadius, y = y + cos1 * outerRadius },
			{ x = x + sin2 * outerRadius, y = y + cos2 * outerRadius },
			{ x = x + sin2 * innerRadius, y = y + cos2 * innerRadius },
			{ x = x + sin1 * innerRadius, y = y + cos1 * innerRadius }
		})
	end
end

local function GetRadialIcon(option)
	if isfunction(option[5]) then
		local mat = option[5](option)
		if mat and type(mat) == "IMaterial" then
			return mat
		end
	end

	if option[5] and type(option[5]) == "IMaterial" then
		return option[5]
	end

	local txt = NormalizeRadialText(option[2])
	if txt == "" then return nil end

	if radialIconMaterials[txt] then
		return radialIconMaterials[txt]
	end

	for key, mat in pairs(radialIconMaterials) do
		if string.find(txt, key, 1, true) then
			return mat
		end
	end
end

local function GetRadialText(option)
	local txt = option and option[2]
	if isfunction(txt) then
		txt = txt(option)
	end

	return txt or ""
end

local function GetRadialIconAngle(option)
	local txt = NormalizeRadialText(GetRadialText(option))
	if txt != "roll drum" then return 0 end

	local startTime = hg.radialRollDrumSpinStart or 0
	local delta = CurTime() - startTime
	if delta < 0 or delta > radialRollDrumSpinDuration then return 0 end

	local progress = math.Clamp(delta / radialRollDrumSpinDuration, 0, 1)
	local remain = 1 - progress

	return remain * remain * remain * radialRollDrumSpinAngle
end

local function GetRadialFallbackText(txt)
	txt = string.Trim((txt or ""):gsub("\n", " "))
	if txt == "" then return "?" end

	local out = {}
	for word in string.gmatch(txt, "[^%s%-_]+") do
		out[#out + 1] = string.upper(string.sub(word, 1, 1))
		if #out >= 2 then break end
	end

	if #out == 0 then
		return string.upper(string.sub(txt, 1, 2))
	end

	return table.concat(out)
end

local function DrawOldRadialLabel(centerX, centerY, angleRad, radius, text, icon, scaleMul)
	local baseX = centerX + math.sin(angleRad) * radius * oldRadialTextRadiusMul
	local baseY = centerY + math.cos(angleRad) * radius * oldRadialTextRadiusMul
	local iconSize = ScrH() * oldRadialIconSizeMul * scaleMul
	local textY = baseY

	if icon then
		surface.SetMaterial(icon)
		surface.SetDrawColor(oldRadialTextColor)
		surface.DrawTexturedRect(baseX - iconSize * 0.5, baseY - iconSize - ScrH() * oldRadialLabelGap * scaleMul, iconSize, iconSize)
		textY = textY + iconSize * 0.1
	end

	draw.DrawText(text, "HomigradFontRadialOld", baseX, textY, oldRadialTextColor, TEXT_ALIGN_CENTER)
end

local function GetModernRadialHudScale()
	return 1 + math.max(ScreenScale(10) / 22.5 - 1, 0) * radialModernHudScaleStrength
end

local function DrawModernRadialCenterText(text, x, y, maxWidth, color)
	text = string.Trim((text or ""):gsub("\n", " "))
	if text == "" then return end

	surface.SetFont("HomigradFontRadialCenter")
	local textW, textH = surface.GetTextSize(text)
	if textW <= 0 or textH <= 0 then return end

	local scale = math.Clamp(maxWidth / textW, radialCenterTextScaleMin, radialCenterTextScaleMax)
	local matrix = Matrix()
	matrix:Translate(Vector(x, y, 0))
	matrix:Scale(Vector(scale, scale, 1))
	matrix:Translate(Vector(-textW * 0.5, -textH * 0.5, 0))

	cam.PushModelMatrix(matrix, true)
	draw.SimpleText(text, "HomigradFontRadialCenter", 0, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	cam.PopModelMatrix()
end

local function CreateRadialMenu(options_arg, bAutoClose)
	local sizeX, sizeY = ScrW(), ScrH()
	hg.radialOptions = {}
	local paining = lply.organism and lply.organism.pain and (lply.organism.pain > 100 or lply.organism.brain > 0.2) or false
	
	if !options_arg then
		local functions = hook.GetTable()["radialOptions"]
		for i, func in SortedPairs(functions) do
			func()
		end
	end

	//hook_Run("radialOptions")
	local options1 = options_arg or hg.radialOptions

	hg.radialOptions = options1
	
	if IsValid(MENUPANELHUYHUY) then
		MENUPANELHUYHUY:Remove()
		MENUPANELHUYHUY = nil
	end

	local scrH, scrW = ScrH(), ScrW()

	MENUPANELHUYHUY = vgui.Create("DPanel")
	menuPanel = MENUPANELHUYHUY
	menuPanel:SetPos(scrW / 2 - sizeX / 2, scrH / 2 - sizeY / 2)
	menuPanel:SetSize(sizeX, sizeY)
	menuPanel:MakePopup()
	menuPanel:SetKeyBoardInputEnabled(false)
	menuPanel:SetAlpha(0)
	menuPanel:AlphaTo(255,0.2)
	menuPanel.bAutoClose = bAutoClose
	menuPanel.bIsNested = options_arg ~= nil
	radialSpinAngle = 0
	if !options_arg then input.SetCursorPos(sizeX / 2, sizeY / 2) end

	function menuPanel:Close()
		if not IsValid(menuPanel) then return end
		menuPanel:AlphaTo(0,0.1,0,function()
			if IsValid(menuPanel) then
				menuPanel:Remove()
				menuPanel = nil
			end
		end)
	end

	local thinkwait = 0
	if !options_arg then
		menuPanel.Think = function()
			if menuPanel:GetAlpha() < 255 then return end
			if thinkwait > CurTime() then return end
			thinkwait = CurTime() + 0.25
			table.Empty(hg.radialOptions)
			local functions = hook.GetTable()["radialOptions"]
			
			for i, func in SortedPairs(functions) do
				//if i == "zmeyka_test" then continue end
				func()
			end
		end
	end
	
	local sizePan = 0
	local optionSelected = {}
	menuPanel.Paint = function(self, w, h)
		local x, y = input.GetCursorPos()
		local centerX, centerY = w / 2, h / 2
		x = x - centerX
		y = y - centerY
		
		local options = {}
		if paining then
			options[#options + 1] = {function() RunConsoleCommand("hg_phrase") end, ""}
		else
			options = options1
		end

		sizePan = LerpFT( menuPanel:GetAlpha() > 100 and 0.05 or 0.25,sizePan,(menuPanel:GetAlpha()/255))
		local viewLerp = Lerp(math.ease.OutExpo(sizePan),0,1)
		local optionCount = #options
		local distance = math.sqrt(x ^ 2 + y ^ 2)
		local partDeg = optionCount > 0 and (360 / optionCount) or 360
		local useOldRadial = hg_oldradialmenu:GetBool()
		local hasMultiButtons = false
		for _, option in ipairs(options) do
			if option[3] then
				hasMultiButtons = true
				break
			end
		end

		if useOldRadial or hasMultiButtons then
			vecXY.x = x
			vecXY.y = y
			local deg = (vecXY:GetNormalized() - vecDown):Angle()
			deg = math.NormalizeAngle((deg[2] - 180) * 2) + 180

			for num, option in ipairs(options) do
				local oldNum = num - 1
				local r = scrH * (options_arg ~= nil and 0.4 or 0.45) * viewLerp
				isMouseOnRadial = distance <= r and distance > 4
				isMouseIntersecting = isMouseOnRadial and deg > oldNum * partDeg and deg < (oldNum + 1) * partDeg
				if isMouseIntersecting then current_option = oldNum + 1 end

				optionSelected[oldNum] = optionSelected[oldNum] or 0
				optionSelected[oldNum] = LerpFT(0.1, optionSelected[oldNum], isMouseIntersecting and 1 or 0)

				if option[3] then
					surface.SetMaterial(matHuy)
					surface.SetDrawColor(useOldRadial and oldRadialSliceColor or colBlack)
					draw.CirclePart(centerX, centerY, r, 40, optionCount, oldNum)
					local count = #option[4]
					local selectedPart = count - (math.floor((r - distance) / (r / count)))
					current_option_select = math.Clamp(selectedPart, 1, count)

					for i, opt in pairs(option[4]) do
						local selected = current_option_select == i
						surface.SetMaterial(matHuy)
						surface.SetDrawColor((selected and isMouseIntersecting) and (useOldRadial and oldRadialHoverColor or colWhiteTransparent) or colTransparent)
						draw.CirclePart(centerX, centerY, r * (i / count), 40, optionCount, oldNum)
						local a = -partDeg * oldNum - partDeg / 2
						a = math.rad(a) + math.pi

						if paining then
							math.randomseed(math.Round(CurTime() / 5 + oldNum + i, 0))
							opt = ""
							math.randomseed(os.time())
						end

						draw.DrawText(opt, useOldRadial and "HomigradFontRadialOld" or "HomigradFont", centerX + math.sin(a) * r * (i / count - 0.5 / count), centerY + math.cos(a) * r * (i / count - 0.5 / count), useOldRadial and oldRadialTextColor or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					surface.SetMaterial(matHuy)
					if option[6] and IsColor(option[6]) then
						if option[7] and IsColor(option[7]) then
							surface.SetDrawColor(option[7]:Lerp(option[6], 1 - optionSelected[oldNum]))
						else
							surface.SetDrawColor((useOldRadial and oldRadialHoverColor or colWhiteTransparent):Lerp(option[6], 1 - optionSelected[oldNum]))
						end
					else
						if option[7] and IsColor(option[7]) then
							surface.SetDrawColor(option[7]:Lerp(options_arg ~= nil and (useOldRadial and oldRadialSliceColor or colOption) or (useOldRadial and oldRadialSliceColor or colBlack), 1 - optionSelected[oldNum]))
						else
							surface.SetDrawColor((useOldRadial and oldRadialHoverColor or colWhiteTransparent):Lerp(options_arg ~= nil and (useOldRadial and oldRadialSliceColor or colOption) or (useOldRadial and oldRadialSliceColor or colBlack), 1 - optionSelected[oldNum]))
						end
					end

					draw.CirclePart(centerX, centerY, r * (1 + 0.1 * optionSelected[oldNum]), 30, optionCount, oldNum)
					local a = -partDeg * oldNum - partDeg / 2
					a = math.rad(a) + math.pi

					if useOldRadial then
						local txt = GetRadialText(option)
						local icon = GetRadialIcon(option)
						if paining then
							math.randomseed(math.Round(CurTime() / 5 + oldNum, 0))
							txt = hg.get_status_message(lply)
							math.randomseed(os.time())
						end
						DrawOldRadialLabel(centerX, centerY, a, r, txt, icon, viewLerp)
					elseif option[5] then
						surface.SetMaterial(option[5])
						surface.SetDrawColor(color_white)
						local sizeW = scrW / 2.25 + math.sin(a) * r * 0.7
						local sizeH = scrH / 2.2 + math.cos(a) * r * 0.7
						surface.DrawTexturedRect(sizeW, sizeH, scrW * 0.1, scrH * 0.1)
					else
						local txt = GetRadialText(option)
						if paining then
							math.randomseed(math.Round(CurTime() / 5 + oldNum, 0))
							txt = hg.get_status_message(lply)
							math.randomseed(os.time())
						end
						draw.DrawText(txt, "HomigradFont", centerX + math.sin(a) * r * 0.75, centerY + math.cos(a) * r * 0.75, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
			end

			if !paining then
				draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",scrW * 0.0215* viewLerp,scrH * 0.042, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,scrW * 0.0215 * viewLerp,scrH * 0.098, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				local col = lply:GetPlayerColor():ToColor()
				draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",scrW * 0.02 * viewLerp,scrH * 0.04, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,scrW * 0.02 * viewLerp,scrH * 0.095, lply.role and lply.role.color or incoentCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			return
		end

		local angle = math.deg(math.atan2(y, x)) + 90
		if angle < 0 then
			angle = angle + 360
		end

		local modernHudScale = GetModernRadialHudScale()
		local outerRadius = scrH * radialModernRadiusMul * modernHudScale * viewLerp
		local innerRadius = outerRadius * radialModernInnerRadiusMul
		local slotOrbit = (outerRadius + innerRadius) * 0.5
		local iconSizeBase = scrH * radialModernIconSizeMul * modernHudScale * viewLerp
		local hoverBand = iconSizeBase * 0.85

		isMouseOnRadial = optionCount > 0 and distance >= (slotOrbit - hoverBand) and distance <= (slotOrbit + hoverBand)
		isMouseIntersecting = false
		current_option_select = 1

		if not isMouseOnRadial then
			radialSpinAngle = (radialSpinAngle + FrameTime() * radialSpinSpeed) % 360
		end

		local spinAngle = radialSpinAngle

		if isMouseOnRadial then
			local relativeAngle = math.NormalizeAngle(angle - spinAngle)
			if relativeAngle < 0 then
				relativeAngle = relativeAngle + 360
			end
			current_option = math.Clamp(math.floor(relativeAngle / partDeg) + 1, 1, optionCount)
			isMouseIntersecting = true
		end

		surface.SetDrawColor(0, 0, 0, radialBackgroundColor.a * viewLerp * 0.85)
		surface.DrawRect(0, 0, w, h)

		DrawFilledCircle(centerX, centerY, outerRadius, radialDrawSegments, Color(radialRingColor.r, radialRingColor.g, radialRingColor.b, radialRingColor.a * viewLerp))
		DrawCircleRing(centerX, centerY, outerRadius, outerRadius + ScrH() * 0.0016 * viewLerp, radialDrawSegments, Color(radialOutlineColor.r, radialOutlineColor.g, radialOutlineColor.b, radialOutlineColor.a * viewLerp))
		DrawCircleRing(centerX, centerY, innerRadius - ScrH() * 0.0016 * viewLerp, innerRadius, radialDrawSegments, Color(radialOutlineColor.r, radialOutlineColor.g, radialOutlineColor.b, radialOutlineColor.a * viewLerp))

		local hoveredText = nil

		for index, option in ipairs(options) do
			optionSelected[index] = optionSelected[index] or 0

			local selected = isMouseOnRadial and current_option == index
			optionSelected[index] = LerpFT(0.12, optionSelected[index], selected and 1 or 0)

			local angleDeg = -90 + spinAngle + partDeg * (index - 1) + partDeg * 0.5
			local angleRad = math.rad(angleDeg)
			local slotX = centerX + math.cos(angleRad) * slotOrbit
			local slotY = centerY + math.sin(angleRad) * slotOrbit
			local slotScale = 1 + optionSelected[index] * 0.12

			local icon = GetRadialIcon(option)
			local iconSize = iconSizeBase * slotScale
			if icon then
				surface.SetMaterial(icon)
				surface.SetDrawColor(255, 255, 255, (selected and 255 or 225) * viewLerp)
				local iconAngle = GetRadialIconAngle(option)
				if iconAngle != 0 then
					surface.DrawTexturedRectRotated(slotX, slotY, iconSize, iconSize, iconAngle)
				else
					surface.DrawTexturedRect(slotX - iconSize * 0.5, slotY - iconSize * 0.5, iconSize, iconSize)
				end
			else
				draw.SimpleText(GetRadialFallbackText(GetRadialText(option)), "HomigradFont", slotX, slotY, Color(radialTextColor.r, radialTextColor.g, radialTextColor.b, 255 * viewLerp), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if selected then
				hoveredText = GetRadialText(option)
			end
		end

		radialCenterTextAlpha = LerpFT(0.12, radialCenterTextAlpha, hoveredText and 1 or 0)
		if hoveredText then
			DrawModernRadialCenterText(hoveredText, centerX, centerY, innerRadius * radialCenterTextWidthMul, Color(radialTextColor.r, radialTextColor.g, radialTextColor.b, 255 * radialCenterTextAlpha * viewLerp))
		end
		if !paining then
			draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",scrW * 0.0215* viewLerp,scrH * 0.042, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,scrW * 0.0215 * viewLerp,scrH * 0.098, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			local col = lply:GetPlayerColor():ToColor()
			draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",scrW * 0.02 * viewLerp,scrH * 0.04, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,scrW * 0.02 * viewLerp,scrH * 0.095, lply.role and lply.role.color or incoentCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

local function PressRadialMenu(mouseClick)
	local options = hg.radialOptions
	--print(options[current_option][1])
	--[[if lply.organism and lply.organism.pain and lply.organism.pain > 100 then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end

		return
	end--]]

	hook_Run("RadialMenuPressed")

	local needed_mouseclick
	if IsValid(menuPanel) and options[current_option] and isMouseOnRadial then
		local func = options[current_option][1]
		if isfunction(func) then needed_mouseclick = func(mouseClick, current_option_select) end
	end

	if needed_mouseclick != -1 and IsValid(menuPanel) and (mouseClick != (needed_mouseclick or 2) or (menuPanel.bIsNested and needed_mouseclick == nil)) and not menuPanel.bAutoClose then
		menuPanel:Close()
	end
end

hg.CreateRadialMenu = CreateRadialMenu
hg.PressRadialMenu = PressRadialMenu

local firstTime = true
local firstTime2 = true
local firstTime3 = true
local firstTime4 = true
local firstTime5 = true
local firstTime6 = true

-- first time?..

hook.Add("HG_OnOtrub", "resetshit", function(ply)
	if ply == lply then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end
	end
end)

hook.Add( "PlayerBindPress", "PlayerBindPressExample2huy", function( ply, bind, pressed )
	if string.find(bind, "+menu") then

		if (lply.organism and lply.organism.otrub) then
			return (bind == "+menu") or nil
		end

		if (bind == "+menu") then
			if pressed and !IsValid(MENUPANELHUYHUY) then
				CreateRadialMenu()
			else
				PressRadialMenu(1)
			end
		else
			if lply:IsAdmin() then return end
		end

		return true
	end
end)

hook.Add("Think", "hg-radial-menu", function()
	if (lply.organism and lply.organism.otrub) then

		if IsValid(menuPanel) then
			hook_Run("RadialMenuPressed")
			menuPanel:Close()
		end

		return
	end
	
	if (engine.ActiveGamemode() ~= "sandbox" and input.IsKeyDown(KEY_Q)) or (engine.ActiveGamemode() == "sandbox" and input.IsKeyDown(KEY_C)) then
		if firstTime then
			firstTime = false
			--CreateRadialMenu()
		end

		firstTime4 = true
	else
		if firstTime4 then
			firstTime4 = false
			--PressRadialMenu()
		end

		firstTime = true
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		if firstTime2 then
			firstTime2 = false
			--print("pressed")
		end

		firstTime3 = true
	else
		if firstTime3 then
			firstTime3 = false
			--print("released")
			PressRadialMenu(1)
		end

		firstTime2 = true
	end

	if input.IsMouseDown(MOUSE_RIGHT) then
		if firstTime5 then
			firstTime5 = false
			--print("pressed")
		end

		firstTime6 = true
	else
		if firstTime6 then
			firstTime6 = false
			--print("released")
			PressRadialMenu(2)
		end

		firstTime5 = true
	end
end)

local function dropWeapon()
	RunConsoleCommand("drop")
end

hook.Add("radialOptions", "77", function()
	local organism = lply.organism or {}
	if not organism.otrub and IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon():GetClass() ~= "weapon_hands_sh" then
		local tbl = {dropWeapon, "Drop Weapon"}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

local randomGestures = {
	{"hello", function() RunConsoleCommand("hg_hand_gesture", "hello") end},
	{"acknowledge", function() RunConsoleCommand("hg_hand_gesture", "acknowledge") end},
	{"wait", function() RunConsoleCommand("hg_hand_gesture", "wait") end},
	{"danger", function() RunConsoleCommand("hg_hand_gesture", "danger") end},
	{"thanks", function() RunConsoleCommand("hg_hand_gesture", "thanks") end},
	{"on my way", function() RunConsoleCommand("hg_hand_gesture", "omw") end},
	{"regroup", function() RunConsoleCommand("hg_hand_gesture", "regroup") end},
	{"help", function() RunConsoleCommand("hg_hand_gesture", "help") end},
	{"point", function() RunConsoleCommand("hg_hand_gesture", "point_of") end},
	{"fuck you", function() RunConsoleCommand("hg_hand_gesture", "fuckyou") end},
	{"thumb up", function() RunConsoleCommand("hg_hand_gesture", "thumb_up") end},
}

concommand.Add("hg_randomgesture",function()
	randomGesture()
end)

hook.Add("radialOptions", "7", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

		if ply:Alive() and not organism.otrub and hg.GetCurrentCharacter(ply) == ply then
        if ply.GetPlayerClass and ply:GetPlayerClass() and ply:GetPlayerClass().CanUseGestures ~= nil and not ply:GetPlayerClass().CanUseGestures then return end
		local tbl = {function(mouseClick)
			if mouseClick == 1 then
				local pick = randomGestures[math.random(#randomGestures)]
				pick[2]()
				if (ply.NextFoley or 0) < CurTime() then
					ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
					ply.NextFoley = CurTime() + 1
				end
			else
				local commands = {}
				for i, str in ipairs(randomGestures) do
					commands[i] = {
						[1] = function()
							str[2]()
						end,
						[2] = string.NiceName(str[1])
					}
				end

				local danceOption = hg.GetDanceRadialOption and hg.GetDanceRadialOption(ply)
				if danceOption then
					commands[#commands + 1] = danceOption
				end

				local surrenderOption = hg.GetSurrenderRadialOption and hg.GetSurrenderRadialOption(ply)
				if surrenderOption then
					commands[#commands + 1] = surrenderOption
				end

				CreateRadialMenu(commands)
			end
		end, "Do Gesture\nRMB - Menu"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

local font_size = 50
surface.CreateFont("HG_font", {
	font = "Arial",
	extended = false,
	size = font_size,
	weight = 500,
	outline = true
})

local CurTime = CurTime

local vector_one = Vector( 1, 1, 1 )

local function CopyRight( text, font, x, y, color, ang, scale )
	--render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	--render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	local m = Matrix()
	m:Translate( Vector( x, y, 0 ) )
	m:Rotate( Angle( 0, ang, 0 ) )
	m:Scale( vector_one * ( scale or 1 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	m:Translate( Vector( -(w / 2)-25, -h / 2, 0 ) )

	cam.PushModelMatrix( m, true )
		draw.RoundedBox(5,0,2,w+52,h+2,Color(0,0,0))
		draw.RoundedBox(5,0,2,w+50,h,Color(255,0,0))
		draw.DrawText( text, font, 25, 0, color )	
	cam.PopModelMatrix()

	--render.PopFilterMag()
	--render.PopFilterMin()
end

--hook.Add("HUDPaint","homigrad-copyright",function()
	--local i = 1
	--CopyRight("ЖДИ ДОКС ЖДИ СВАТ","HomigradFontBig",ScrW()/2 +(math.cos(CurTime()*1)*15*i),ScrH()/2+(math.sin(CurTime()*1)*55*i)+15,Color(255,255,255),math.cos(CurTime()*1)*1,2+math.sin(CurTime()*1)*0.5)
--end)

hook.Add("HUDPaint","Identifier",function()
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	if lply:GetNetVar("disappearance", nil) then return end 
	
	local trace = hg.eyeTrace(lply)
	
	if not trace then return end

	local Size = math.max(math.min(1 - trace.Fraction, 1), 0.1)
	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y

	if trace.Hit and (trace.Entity:IsRagdoll() or trace.Entity:IsPlayer()) then
		if trace.Entity.PlayerClassName == "sc_infiltrator" then return end
		if trace.Entity:GetNetVar("disappearance", nil) then return end

		draw.NoTexture()

		local col = trace.Entity:GetPlayerColor():ToColor()
		col.a = 255 * Size * 1.5

		local coloutline = (col.r < 50 and col.g < 50 and col.b < 50) and Color(100,100,100) or Color(0,0,0)
		coloutline.a = 255 * Size * 1

		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x + 1, y + 31, coloutline, TEXT_ALIGN_CENTER)

		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x, y + 30, col, TEXT_ALIGN_CENTER)
	end
end)

--sound.PlayURL("https://cdn.discordapp.com/attachments/1254022273661145108/1257385761414582382/pon_pon_016eb317d_1.mp4?ex=66882bbe&is=6686da3e&hm=429f0e4427bdc9d80673d3bfa2eccf48221ae5572ec508fb7699274c2c7041ef&","",function() end)

function scare()
	-- hook.Add("RenderScreenspaceEffects","Scare",function()
		-- for i = 1, 5 do
		-- CopyRight("Плывиски","HomigradFontBig",ScrW()/2 +(math.cos(CurTime()*1)*15*i),ScrH()/2+(math.sin(CurTime()*1)*55*i)+15,Color(255,255,255),math.cos(CurTime()*1)*1,2+math.sin(CurTime()*1)*0.5)
		-- end
	-- end)
	-- for i = 1, 15 do
		-- sound.PlayURL("https://cdn.discordapp.com/attachments/1254022273661145108/1257385761414582382/pon_pon_016eb317d_1.mp4?ex=66882bbe&is=6686da3e&hm=429f0e4427bdc9d80673d3bfa2eccf48221ae5572ec508fb7699274c2c7041ef&","",function() end)
	-- end
end

local hint
local hg_hints = ConVarExists("hg_hints") and GetConVar("hg_hints") or CreateClientConVar("hg_hints", "1", true, false, "Toggle UI hints")

local HintBackgroundColor = Color( 0, 0, 0, 200 )

hook.Add("HUDPaint","EntHints",function()
	if not hg_hints:GetBool() then return end 
	if HGSuppressEntityHints then return end
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local trace = hg.eyeTrace(lply)

	if not trace then return end

	HintBackgroundColor.a = LerpFT(0.1, HintBackgroundColor.a, (IsValid(trace.Entity) and trace.Entity.HudHintMarkup) and 200 or 0)

	hg.BasicHudHint(trace.Entity, trace, hint)
end)

function hg.BasicHudHint(ent, trace)
	hint = (IsValid(ent) and ent.HudHintMarkup) or hint

	if not hint then return end

	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
	y = y + 145 + -45

	draw.RoundedBox(2, x - hint:GetWidth() / 2 - 2.5, y - 2.5, hint:GetWidth() + 5, hint:GetHeight() + 5, HintBackgroundColor)
	
	hint:Draw(x, y, TEXT_ALIGN_CENTER, nil, 175 * (HintBackgroundColor.a / 200), TEXT_ALIGN_CENTER)

	if ent.AdditionalInfoFunc then
		local str = ent.AdditionalInfoFunc()

		local w, h = surface.GetTextSize(str)
		surface.SetFont("ZCity_Tiny")
		surface.SetTextColor(color_white)
		surface.SetTextPos(x - w * 0.5, y + hint:GetHeight() + h)
		surface.DrawText(str)
	end
end

local leg = Material("zbattle/medical/broken_bone.png", "")

local white = Color(255, 255, 255, 255)
local bkg = Color(43, 30, 30)
hook.Add("HUDPaint","afflictionlist",function()
	--[[if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local org = lply.organism

	if org.lleg >= 0.99 then
		local w, h = 200, 200

		local ent = hg.GetCurrentCharacter(lply)
		local lkp = ent:LookupBone("ValveBiped.Bip01_R_Thigh")
		local matrix = ent:GetBoneMatrix(lkp)

		if matrix then
			local pos = matrix:GetTranslation() + matrix:GetForward() * ent:BoneLength(lkp + 1) * 0.5
			local scrpos = pos:ToScreen()

			surface.SetMaterial(leg)
			surface.SetDrawColor(white)
			--surface.DrawRect(sw / 2 - w / 2, sh / 2 - h / 2, w, h)
			surface.SetDrawColor(white)
			surface.DrawTexturedRect(scrpos.x - w / 2, scrpos.y - h / 2, w, h)
		end
	end--]]
end)

local observe_state = {
	active = false,
	stage = 1,
	stage_start = 0,
	target = nil,
	data_target = nil,
	last_health = 0,
	last_hurt = 0,
	last_painadd = 0,
	was_alive = true,
	require_admire_reset = false
}
local observe_parts = {"Arms", "Torso", "Legs"}
local observe_stage_time = 4.5
local observe_text_delay = 1.8
local observe_type_speed = 28
local observe_line_color = Color(0, 0, 0, 255)
local observe_box_color = Color(0, 0, 0, 220)
local observe_text_color = Color(255, 255, 255, 255)
local observe_line_screen = 50
local observe_line_screen_up = 22
local observe_font = "ZCity_Veteran"

local observe_bone_sets = {
	Arms = {
		{
			label = "Left Arm",
			bones = {"ValveBiped.Bip01_L_Forearm"},
			side = -1,
			offset = 12,
			fracture_keys = {"larm"},
			dis_key = "larmdislocation",
			hitgroups = {
				[HITGROUP_LEFTARM] = true
			}
		},
		{
			label = "Right Arm",
			bones = {"ValveBiped.Bip01_R_Forearm"},
			side = 1,
			offset = 12,
			fracture_keys = {"rarm"},
			dis_key = "rarmdislocation",
			hitgroups = {
				[HITGROUP_RIGHTARM] = true
			}
		},
		{
			label = "Left Wrist",
			bones = {"ValveBiped.Bip01_L_Wrist", "ValveBiped.Bip01_L_Hand"},
			side = -1,
			offset = 8,
			fracture_keys = {"lwrist"},
			dis_key = "lwristdislocation",
			hitgroups = {
				[HITGROUP_LEFTARM] = true
			}
		},
		{
			label = "Right Wrist",
			bones = {"ValveBiped.Bip01_R_Wrist", "ValveBiped.Bip01_R_Hand"},
			side = 1,
			offset = 8,
			fracture_keys = {"rwrist"},
			dis_key = "rwristdislocation",
			hitgroups = {
				[HITGROUP_RIGHTARM] = true
			}
		}
	},
	Torso = {
		{
			label = "Torso",
			bones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis"},
			side = 1,
			offset = 12,
			fracture_keys = {"chest", "spine1", "spine2", "spine3", "pelvis", "brokenribs"},
			hitgroups = {
				[HITGROUP_CHEST] = true,
				[HITGROUP_STOMACH] = true,
				[HITGROUP_GENERIC] = true
			}
		}
	},
	Legs = {
		{
			label = "Left Leg",
			bones = {"ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Foot"},
			side = -1,
			fracture_keys = {"lleg"},
			dis_key = "llegdislocation",
			hitgroups = {
				[HITGROUP_LEFTLEG] = true
			}
		},
		{
			label = "Right Leg",
			bones = {"ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Foot"},
			side = 1,
			fracture_keys = {"rleg"},
			dis_key = "rlegdislocation",
			hitgroups = {
				[HITGROUP_RIGHTLEG] = true
			}
		}
	}
}

local function get_observe_target(ply, admiring)
	local fake = (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or (IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll"))
	if IsValid(fake) then
		return fake, ply
	end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.CarryEnt and IsValid(wep.CarryEnt) then
		if wep.CarryEnt:IsRagdoll() then
			local owner = hg.RagdollOwner(wep.CarryEnt)
			return wep.CarryEnt, (IsValid(owner) and owner or wep.CarryEnt)
		end
		if wep.CarryEnt:IsPlayer() then
			return wep.CarryEnt, wep.CarryEnt
		end
	end
	local carry = ply:GetNetVar("carryent")
	if IsValid(carry) then
		if carry:IsRagdoll() then
			local owner = hg.RagdollOwner(carry)
			return carry, (IsValid(owner) and owner or carry)
		end
		if carry:IsPlayer() then
			if IsValid(carry.FakeRagdoll) then
				return carry.FakeRagdoll, carry
			end
			return carry, carry
		end
	end
	local tr = hg.eyeTrace(ply, 120)
	if tr and IsValid(tr.Entity) then
		local ent = tr.Entity
		if ent:IsRagdoll() then
			local owner = hg.RagdollOwner(ent)
			return ent, (IsValid(owner) and owner or ent)
		end
		if ent:IsPlayer() then
			if IsValid(ent.FakeRagdoll) then
				return ent.FakeRagdoll, ent
			end
			return ent, ent
		end
	end
	if admiring then
		return ply, ply
	end
end

local function get_hitgroup(ent, bone)
	if not bone then return end
	if not hg or not hg.bonetohitgroup then return end
	local bonename = bone
	if isnumber(bone) and IsValid(ent) then
		bonename = ent:GetBoneName(bone)
	end
	return bonename and hg.bonetohitgroup[bonename] or nil
end

local function count_wounds_for_groups(ent, wounds, groups)
	local count = 0
	if wounds then
		for i = 1, #wounds do
			local bone = wounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function count_arterial_for_groups(ent, arterialwounds, groups)
	local count = 0
	if arterialwounds then
		for i = 1, #arterialwounds do
			local bone = arterialwounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function has_fracture(org, keys)
	for i = 1, #keys do
		local key = keys[i]
		if key == "brokenribs" then
			if org.brokenribs and org.brokenribs > 0 then
				return true
			end
		else
			local v = org[key]
			if v then
				local threshold = 1
				if hg and hg.organism then
					local fake_key = hg.organism["fake_" .. key]
					if fake_key then
						threshold = fake_key
					end
				end
				if v >= threshold then
					return true
				end
			end
		end
	end
	return false
end

local function get_bleeding_label(count)
	if count <= 0 then return nil end
	if count == 1 then return "Minor bleeding" end
	if count <= 3 then return "Bleeding" end
	return "Intense bleeding"
end

local function get_bone_pos(ent, bones)
	ent:SetupBones()
	for i = 1, #bones do
		local id = ent:LookupBone(bones[i])
		if id then
			local pos = ent:GetBonePosition(id)
			if isvector(pos) then
				return pos
			end
		end
	end
	local center = ent:OBBCenter()
	if isvector(center) then
		return ent:LocalToWorld(center)
	end
end

local function build_observe_text(entry, ent)
	if not IsValid(ent) then
		return entry.label .. ": No target"
	end
	local org = ent.organism or ent.new_organism or {}
	local wounds = ent.wounds or ent:GetNetVar("wounds") or {}
	local arterialwounds = ent.arterialwounds or ent:GetNetVar("arterialwounds") or {}
	if not ent.organism and not ent.new_organism then
		return entry.label .. ": No data"
	end

	local amputated = false
	if entry.label == "Left Arm" and (org.larmamputated or org.lhandamputated) then
		amputated = true
	elseif entry.label == "Right Arm" and (org.rarmamputated or org.rhandamputated) then
		amputated = true
	elseif entry.label == "Left Leg" and org.llegamputated then
		amputated = true
	elseif entry.label == "Right Leg" and org.rlegamputated then
		amputated = true
	elseif entry.label == "Head" and org.headamputated then
		amputated = true
	end

	if amputated then
		return entry.label .. ": Amputated"
	end

	local fracture = has_fracture(org, entry.fracture_keys or {})
	local dislocation = entry.dis_key and (org[entry.dis_key] or false) or false
	local woundcount = count_wounds_for_groups(ent, wounds, entry.hitgroups or {})
	local arterialcount = count_arterial_for_groups(ent, arterialwounds, entry.hitgroups or {})
	if not fracture and not dislocation and woundcount <= 0 and arterialcount <= 0 then
		return entry.label .. ": All fine."
	end
	local parts = {}
	if fracture then parts[#parts + 1] = "Fracture" end
	if dislocation then parts[#parts + 1] = "Dislocated" end
	local bleeding = get_bleeding_label(woundcount)
	if bleeding then parts[#parts + 1] = bleeding end
	if arterialcount > 0 then parts[#parts + 1] = "Arterial bleeding" end
	return entry.label .. ": " .. table.concat(parts, ", ")
end

hook.Add("HUDPaint", "mcd_admire_observe", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local alive = ply:Alive() and ply:Health() > 0 and not (ply.organism and ply.organism.alive == false) and not IsValid(ply:GetNWEntity("spect"))
	local view_ent = GetViewEntity()
	local function reset_observe(require_reset)
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		observe_state.stage = 1
		observe_state.stage_start = 0
		observe_state.last_health = 0
		observe_state.last_hurt = 0
		observe_state.last_painadd = 0
		if require_reset then
			observe_state.require_admire_reset = true
			ply.mcd_admire_local_cancel = true
			if ply:GetNWBool("mcd_admiring", false) then
				RunConsoleCommand("mcd_admire", "cancel")
			end
		end
	end
	if observe_state.was_alive and not alive then
		reset_observe(true)
	end
	if not observe_state.was_alive and alive then
		reset_observe(false)
	end
	observe_state.was_alive = alive
	if not alive then
		reset_observe(false)
		return
	end
	if view_ent ~= ply then
		reset_observe(true)
		return
	end
	local in_fake = IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) or IsValid(ply:GetNWEntity("FakeRagdollOld")) or IsValid(ply:GetNWEntity("RagdollDeath")) or IsValid(ply.RagdollDeath)
	if in_fake then
		reset_observe(true)
		return
	end
	if not ply:OnGround() then
		reset_observe(true)
		return
	end
	local org = ply.organism or ply.new_organism
	local hurt = org and org.hurt or 0
	local painadd = org and org.painadd or 0
	if observe_state.last_painadd and painadd > observe_state.last_painadd + 0.01 then
		reset_observe(true)
		observe_state.last_painadd = painadd
		return
	end
	observe_state.last_painadd = painadd
	if observe_state.last_hurt and hurt > observe_state.last_hurt + 0.01 then
		reset_observe(true)
		observe_state.last_hurt = hurt
		return
	end
	observe_state.last_hurt = hurt
	local health = ply:Health()
	if observe_state.last_health and health < observe_state.last_health then
		reset_observe(true)
		observe_state.last_health = health
		return
	end
	observe_state.last_health = health
	local admiring = ply:GetNWBool("mcd_admiring", false)
	if observe_state.require_admire_reset then
		if admiring then return end
		observe_state.require_admire_reset = false
		ply.mcd_admire_local_cancel = false
	end
	if not admiring then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		ply.mcd_admire_local_cancel = false
		return
	end
	local draw_ent, data_ent = get_observe_target(ply, admiring)
	if not admiring and not IsValid(draw_ent) then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		return
	end

	if observe_state.target ~= draw_ent or not observe_state.active then
		observe_state.active = true
		observe_state.target = draw_ent
		observe_state.data_target = data_ent
		observe_state.stage = 1
		observe_state.stage_start = CurTime()
		observe_state.last_health = ply:Health()
	end

	local elapsed = CurTime() - observe_state.stage_start
	if elapsed >= observe_stage_time then
		observe_state.stage = observe_state.stage + 1
		if observe_state.stage > #observe_parts then
			observe_state.stage = 1
		end
		observe_state.stage_start = CurTime()
		elapsed = 0
	end

	local part = observe_parts[observe_state.stage]
	local entries = observe_bone_sets[part]
	if not entries or not IsValid(draw_ent) then return end
	local t = math.Clamp(elapsed / observe_stage_time, 0, 1)
	local fade = t <= 0.5 and (t * 2) or ((1 - t) * 2)
	local fade_alpha = math.Clamp(fade, 0, 1)
	if fade_alpha <= 0 then return end

	local offscreen_count = 0
	for i = 1, #entries do
		local entry = entries[i]
		local bone_pos = get_bone_pos(draw_ent, entry.bones)
		if bone_pos then
			if entry.offset and entry.offset ~= 0 then
				bone_pos = bone_pos + draw_ent:GetForward() * entry.offset
			end
			local screen = bone_pos:ToScreen()
			local is_offscreen = not screen.visible or screen.x < 0 or screen.x > ScrW() or screen.y < 0 or screen.y > ScrH()
			
			local end_x, end_y
			if is_offscreen then
				offscreen_count = offscreen_count + 1
				end_x = ScrW() * 0.5
				end_y = ScrH() - 20 - (offscreen_count * 40)
			else
				end_x = screen.x + observe_line_screen * (entry.side or 1)
				end_y = screen.y - observe_line_screen_up
				surface.SetDrawColor(observe_line_color.r, observe_line_color.g, observe_line_color.b, math.floor(255 * fade_alpha))
				surface.DrawLine(screen.x, screen.y, end_x, end_y)
			end

			local full_text
			local type_elapsed
			if elapsed < observe_text_delay then
				full_text = entry.label .. ": Observing..."
				type_elapsed = elapsed
			else
				full_text = build_observe_text(entry, observe_state.data_target or draw_ent)
				type_elapsed = elapsed - observe_text_delay
			end
			local max_chars = math.floor(type_elapsed * observe_type_speed)
			local text = string.sub(full_text, 1, math.Clamp(max_chars, 0, #full_text))

			surface.SetFont(observe_font)
			local tw, th = surface.GetTextSize(text)
			local pad = 6
			local box_w = tw + pad * 2
			local box_h = th + pad * 2
			local box_x = end_x - box_w * 0.5
			local box_y = end_y - box_h * 0.5
			draw.RoundedBox(0, box_x, box_y, box_w, box_h, Color(observe_box_color.r, observe_box_color.g, observe_box_color.b, math.floor(observe_box_color.a * fade_alpha)))
			draw.SimpleText(text, observe_font, end_x, end_y, Color(observe_text_color.r, observe_text_color.g, observe_text_color.b, math.floor(observe_text_color.a * fade_alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

-- Now playable :steamhappy:
-- No. fuc kyouy
if game.SinglePlayer() then
	hook.Add("HUDPaint","Exit the singleplayer",function()
		draw.SimpleText("Z-City is not meant to be played in singleplayer, in map selection menu change SINGLEPLAYER (green button top right corner) to 2 players or any.", "HomigradFontMedium", ScrW() / 2,ScrH() / 2, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("A lot of stuff won't work and we won't provide any fixes to singleplayer EVER", "HomigradFontMedium", ScrW() / 2,ScrH() * 7 / 12, nil,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end
