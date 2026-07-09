--made by mrrp :3

hg = hg or {}
hg.zchatConVars = hg.zchatConVars or {}

local maxLength = GetConVar("zchat_maxmessagelength")

local NoDrop = CreateClientConVar("zchat_dropcharacters", 0, true, false, "Play the character dropping animation when erasing text", 0, 1)
local ShowTextBoxInactive = CreateClientConVar("zchat_showtextboxinactive", 1, true, false, "Showing your text in textbox while chat is turned off", 0, 1)

hg.zchatConVars["zchat_dropcharacters"] = {
	name = "zchat_dropcharacters",
	default = "0",
	description = "Show erased characters briefly when deleting text",
	min = 0,
	max = 1,
	type = "bool",
	decimals = 0
}

hg.zchatConVars["zchat_showtextboxinactive"] = {
	name = "zchat_showtextboxinactive",
	default = "1",
	description = "Show your unsent text while chat is inactive",
	min = 0,
	max = 1,
	type = "bool",
	decimals = 0
}

hg.zchatConVars["zchat_opaquebackground"] = nil

local function CallbackBind(self, callback)
	return function(_, ...)
		return callback(self, ...)
	end
end

local function PaintMarkupOverride(text, font, x, y, color, alignX, alignY, alpha)
	alpha = alpha or 255

	-- background for easier reading
	surface.SetTextPos(x + 1, y + 1)
	surface.SetTextColor(0, 0, 0, alpha)
	surface.SetFont(font)
	surface.DrawText(text)

	surface.SetTextPos(x, y)
	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.SetFont(font)
	surface.DrawText(text)
end

local function MenuUnit(num)
	return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local settingsOutlineColor = Color(255, 255, 255, 255)
local settingsFillColor = Color(0, 0, 0, 245)
local settingsOverlayColor = Color(0, 0, 0, 170)
local settingsColorWhite = Color(255, 255, 255, 240)
local settingsColorText = Color(225, 225, 225)
local settingsColorTextDim = Color(160, 160, 160)
local chatBoxColor = Color(0, 0, 0, 245)
local chatPanelColor = Color(0, 0, 0, 255)
local chatOutlineColor = Color(255, 255, 255, 80)
local chatInnerOutlineColor = Color(255, 255, 255, 28)
local chatVignetteColor = Color(120, 120, 120, 95)
local chatButtonIdle = Color(0, 0, 0, 255)
local chatButtonHover = Color(30, 30, 30, 255)
local settingsIcon = Material("radialmenu/settings.png")
local gradient_d = Material("vgui/gradient-d")
local chatBoundsCookiePrefix = "zchat_bounds_"
local chatResizeEdge = 8
local chatTopGrip = 26
local chatMinWidth = 260
local chatMinHeight = 140
local chatHatHeight = 20
local chatHatGap = 0
local chatHatWidthPadding = 0
local settingsRowHeight = 36
local settingsSliderWidth = 120
local settingsNumberWidth = 60
local settingsStringWidth = 170
local function RunZChatConVar(name, value)
	RunConsoleCommand(name, tostring(value))
end

local function GetZChatSettingTitle(data)
	if data.name == "zchat_font" then return "Font" end
	if data.name == "zchat_fontaa" then return "Anti-Aliasing" end
	if data.name == "zchat_fontsize" then return "Font Size" end
	if data.name == "zchat_fontweight" then return "Font Weight" end
	if data.name == "zchat_maxmessagelength" then return "Message Length" end
	if data.name == "zchat_dropcharacters" then return "Delete Effect" end
	if data.name == "zchat_showtextboxinactive" then return "Show Inactive Text" end

	local text = data.name:gsub("^zchat_", ""):gsub("_", " ")
	return text:gsub("(%a)([%w_']*)", function(first, rest)
		return string.upper(first) .. string.lower(rest)
	end)
end

local function PaintSettingRow(self, w, h)
	surface.SetDrawColor(20, 20, 30, 120)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(settingsColorWhite.r, settingsColorWhite.g, settingsColorWhite.b, 90)
	surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
end

local function PaintEntryPanel(self, w, h)
	surface.SetDrawColor(0, 0, 0, 245)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(chatOutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function PaintHatPanel(self, w, h)
	surface.SetDrawColor(0, 0, 0, 245)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(chatOutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function PaintSettingsButton(self, w, h)
	surface.SetDrawColor(self:IsHovered() and chatButtonHover or chatButtonIdle)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(settingsOutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(settingsIcon)
	surface.DrawTexturedRect(math.floor((w - 16) * 0.5), math.floor((h - 16) * 0.5), 16, 16)
end

local function PaintSettingsTextButton(self, w, h)
	surface.SetDrawColor(self:IsHovered() and chatButtonHover or chatButtonIdle)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(settingsOutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	draw.SimpleText(self:GetText(), "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, settingsColorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function CreateZChatBoolRow(parent, data, convar)
	local row = parent:Add("DPanel")
	row:Dock(TOP)
	row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
	row:SetTall(MenuUnit(settingsRowHeight))
	row.Paint = PaintSettingRow

	local title = row:Add("DLabel")
	title:SetFont("ZCity_Menu_Settings_Small")
	title:SetTextColor(settingsColorText)
	title:SetText(GetZChatSettingTitle(data))
	title:SizeToContents()

	local toggle = row:Add("DButton")
	toggle:SetSize(MenuUnit(46), MenuUnit(22))
	toggle:SetText("")
	local animProgress = convar:GetBool() and 1 or 0
	local targetProgress = animProgress
	function row:PerformLayout(w, h)
		title:SetPos(MenuUnit(12), math.floor((h - title:GetTall()) * 0.5))
		toggle:SetPos(w - MenuUnit(78), math.floor((h - toggle:GetTall()) * 0.5))
	end
	function toggle:Paint(w, h)
		animProgress = Lerp(FrameTime() * 8, animProgress, targetProgress)
		local bgR = Lerp(animProgress, 60, 155)
		local bgG = Lerp(animProgress, 60, 30)
		local bgB = Lerp(animProgress, 60, 30)
		draw.RoundedBox(MenuUnit(3), 0, 0, w, h, Color(20, 20, 20, 230))
		draw.RoundedBox(MenuUnit(3), 1, 1, w - 2, h - 2, Color(bgR, bgG, bgB, 200))
		local slsize = h - MenuUnit(6)
		local slPos = Lerp(animProgress, MenuUnit(3), w - slsize - MenuUnit(3))
		draw.RoundedBox(MenuUnit(2), slPos, MenuUnit(3), slsize, slsize, Color(245, 245, 245))
	end
	function toggle:DoClick()
		local newValue = not convar:GetBool()
		RunZChatConVar(data.name, newValue and "1" or "0")
		targetProgress = newValue and 1 or 0
	end
end

local function CreateZChatNumberRow(parent, data, convar)
	local row = parent:Add("DPanel")
	row:Dock(TOP)
	row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
	row:SetTall(MenuUnit(settingsRowHeight))
	row.Paint = PaintSettingRow

	local title = row:Add("DLabel")
	title:SetFont("ZCity_Menu_Settings_Small")
	title:SetTextColor(settingsColorText)
	title:SetText(GetZChatSettingTitle(data))
	title:SizeToContents()

	local decimals = data.decimals or 0
	local min = data.min or 0
	local max = data.max or math.max(convar:GetFloat(), 1)
	local sliderW = MenuUnit(settingsSliderWidth)
	local sliderBg = row:Add("DButton")
	sliderBg:SetSize(sliderW, MenuUnit(24))
	sliderBg:SetText("")

	local curVal = decimals > 0 and convar:GetFloat() or convar:GetInt()
	local frac = math.Clamp((curVal - min) / math.max(0.0001, max - min), 0, 1)
	local isDragging = false

	local function NormalizeValue(val)
		val = math.Clamp(val, min, max)
		if decimals > 0 then
			return math.Round(val, decimals)
		end

		return math.Round(val)
	end

	local function FormatValue(val)
		if decimals > 0 then
			return string.format("%." .. decimals .. "f", val)
		end

		return tostring(math.Round(val))
	end

	local function ApplyFraction(rawFrac)
		frac = math.Clamp(rawFrac, 0, 1)
		RunZChatConVar(data.name, NormalizeValue(min + frac * (max - min)))
	end

	function sliderBg:Paint(w, h)
		local trackY = h / 2 - MenuUnit(1)
		surface.SetDrawColor(20, 20, 20, 230)
		surface.DrawRect(0, trackY, w, MenuUnit(2))
		surface.SetDrawColor(settingsColorWhite.r, settingsColorWhite.g, settingsColorWhite.b, 220)
		surface.DrawRect(0, trackY, w * frac, MenuUnit(2))
		local knobX = math.Clamp(w * frac - MenuUnit(3), 0, w - MenuUnit(6))
		draw.RoundedBox(MenuUnit(2), knobX, h / 2 - MenuUnit(4), MenuUnit(6), MenuUnit(8), Color(245, 245, 245))
	end

	function sliderBg:OnMousePressed(mouseCode)
		if mouseCode == MOUSE_LEFT then
			isDragging = true
			self:MouseCapture(true)
			ApplyFraction(self:CursorPos() / math.max(self:GetWide(), 1))
		end
	end

	function sliderBg:OnMouseReleased(mouseCode)
		if mouseCode == MOUSE_LEFT then
			isDragging = false
			self:MouseCapture(false)
		end
	end

	function sliderBg:OnCursorMoved(x)
		if isDragging then
			ApplyFraction(x / math.max(self:GetWide(), 1))
		end
	end

	function sliderBg:Think()
		if not isDragging then
			local cur = decimals > 0 and convar:GetFloat() or convar:GetInt()
			frac = math.Clamp((cur - min) / math.max(0.0001, max - min), 0, 1)
		end
	end

	local valLabel = row:Add("DTextEntry")
	valLabel:SetSize(MenuUnit(settingsNumberWidth), MenuUnit(24))
	valLabel:SetFont("ZCity_Menu_Settings_Tiny")
	valLabel:SetTextColor(settingsColorText)
	valLabel:SetText(FormatValue(curVal))
	valLabel:SetNumeric(true)
	valLabel:SetUpdateOnType(false)
	valLabel.Paint = function(self, w, h)
		surface.SetDrawColor(20, 20, 20, 240)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(settingsColorWhite.r, settingsColorWhite.g, settingsColorWhite.b, 120)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		self:DrawTextEntryText(settingsColorText, Color(120, 130, 180), settingsColorText)
	end

	local function CommitValueText()
		local numVal = tonumber(valLabel:GetText())
		if not numVal then
			local cur = decimals > 0 and convar:GetFloat() or convar:GetInt()
			valLabel:SetText(FormatValue(cur))
			return
		end

		numVal = NormalizeValue(numVal)
		RunZChatConVar(data.name, numVal)
		valLabel:SetText(FormatValue(numVal))
	end

	function valLabel:OnEnter()
		CommitValueText()
		self:KillFocus()
	end

	function valLabel:OnLoseFocus()
		CommitValueText()
	end

	function valLabel:Think()
		if not self:HasFocus() then
			local cur = decimals > 0 and convar:GetFloat() or convar:GetInt()
			local curText = FormatValue(cur)
			if self:GetText() != curText then
				self:SetText(curText)
			end
		end
	end
	function row:PerformLayout(w, h)
		local ctrlX = w - MenuUnit(32)
		title:SetPos(MenuUnit(12), math.floor((h - title:GetTall()) * 0.5))
		sliderBg:SetPos(ctrlX - sliderW, math.floor((h - sliderBg:GetTall()) * 0.5))
		valLabel:SetPos(ctrlX - sliderW - MenuUnit(settingsNumberWidth + 10), math.floor((h - valLabel:GetTall()) * 0.5))
	end
end

local function CreateZChatStringRow(parent, data, convar)
	local row = parent:Add("DPanel")
	row:Dock(TOP)
	row:DockMargin(MenuUnit(10), MenuUnit(4), MenuUnit(10), MenuUnit(4))
	row:SetTall(MenuUnit(settingsRowHeight))
	row.Paint = PaintSettingRow

	local title = row:Add("DLabel")
	title:SetFont("ZCity_Menu_Settings_Small")
	title:SetTextColor(settingsColorText)
	title:SetText(GetZChatSettingTitle(data))
	title:SizeToContents()

	local ctrlW = MenuUnit(settingsStringWidth)
	local textEntry = row:Add("DTextEntry")
	textEntry:SetSize(ctrlW, MenuUnit(24))
	textEntry:SetText(convar:GetString())
	textEntry:SetUpdateOnType(true)
	textEntry:SetFont("ZCity_Menu_Settings_Tiny")
	textEntry.Paint = function(self, w, h)
		surface.SetDrawColor(20, 20, 20, 240)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(settingsColorWhite.r, settingsColorWhite.g, settingsColorWhite.b, 120)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		self:DrawTextEntryText(color_white, Color(120, 130, 180), color_white)
	end
	function textEntry:OnValueChange(val)
		RunZChatConVar(data.name, val)
	end
	function row:PerformLayout(w, h)
		local ctrlX = w - MenuUnit(32)
		title:SetPos(MenuUnit(12), math.floor((h - title:GetTall()) * 0.5))
		textEntry:SetPos(ctrlX - ctrlW, math.floor((h - textEntry:GetTall()) * 0.5))
	end
end

local function ClampChatBounds(x, y, w, h)
	local maxW = math.max(chatMinWidth, ScrW() - 8)
	local maxH = math.max(chatMinHeight, ScrH() - 8)
	w = math.Clamp(w, chatMinWidth, maxW)
	h = math.Clamp(h, chatMinHeight, maxH)
	x = math.Clamp(x, 0, ScrW() - w)
	y = math.Clamp(y, 0, ScrH() - h)
	return math.floor(x), math.floor(y), math.floor(w), math.floor(h)
end

local function SaveChatBounds(panel)
	local x, y = panel:GetPos()
	local w, h = panel:GetSize()
	x, y, w, h = ClampChatBounds(x, y, w, h)
	cookie.Set(chatBoundsCookiePrefix .. "x", x)
	cookie.Set(chatBoundsCookiePrefix .. "y", y)
	cookie.Set(chatBoundsCookiePrefix .. "w", w)
	cookie.Set(chatBoundsCookiePrefix .. "h", h)
end

local function SyncHatPanel(panel)
	if not IsValid(panel.hatPanel) then return end

	local x, y = panel:GetPos()
	local w, h = panel:GetSize()
	panel.hatPanel:SetPos(x - math.floor(chatHatWidthPadding * 0.5), y - chatHatHeight - chatHatGap)
	panel.hatPanel:SetSize(w + chatHatWidthPadding, chatHatHeight)
	panel.hatPanel:SetAlpha(panel:GetAlpha())
end

local function GetSavedChatBounds()
	local defaultW = ScrW() * 0.3
	local defaultH = ScrH() * 0.2
	local defaultX = ScrW() * 0.02
	local defaultY = ScrH() * 0.67
	local w = cookie.GetNumber(chatBoundsCookiePrefix .. "w", defaultW)
	local h = cookie.GetNumber(chatBoundsCookiePrefix .. "h", defaultH)
	local x = cookie.GetNumber(chatBoundsCookiePrefix .. "x", defaultX)
	local y = cookie.GetNumber(chatBoundsCookiePrefix .. "y", defaultY)
	return ClampChatBounds(x, y, w, h)
end

local function OpenZChatSettings()
	if IsValid(hg.zchatSettingsOverlay) then
		hg.zchatSettingsOverlay:Remove()
	end

	local overlay = vgui.Create("DButton")
	hg.zchatSettingsOverlay = overlay
	overlay:SetText("")
	overlay:SetCursor("arrow")
	overlay:SetSize(ScrW(), ScrH())
	overlay:SetPos(0, 0)
	overlay:SetAlpha(0)
	overlay:MakePopup()
	overlay.DoClick = function()
		overlay:Remove()
	end
	function overlay:Paint(w, h)
		surface.SetDrawColor(settingsOverlayColor)
		surface.DrawRect(0, 0, w, h)
	end
	overlay:AlphaTo(255, 0.12, 0)

	local frame = vgui.Create("DPanel", overlay)
	overlay.BoxPanel = frame
	frame:SetSize(math.min(ScrW() * 0.46, 760), math.min(ScrH() * 0.68, 760))
	frame:Center()
	frame.TargetY = frame:GetY()
	frame:SetY(frame.TargetY + 10)
	frame:SetAlpha(0)
	frame:MoveTo(frame:GetX(), frame.TargetY, 0.12, 0, -1)
	frame:AlphaTo(255, 0.12, 0)
	function frame:Paint(w, h)
		surface.SetDrawColor(settingsFillColor)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(settingsOutlineColor)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		draw.SimpleText("settings", "ZCity_Menu_Settings_Small", w * 0.5, 24, settingsColorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	frame.OnMousePressed = function() end

	local close = frame:Add("DButton")
	close:SetPos(frame:GetWide() - 38, 10)
	close:SetSize(28, 28)
	close:SetText("X")
	close.Paint = PaintSettingsTextButton
	close.DoClick = function()
		overlay:Remove()
	end

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)
	scroll:DockMargin(14, 54, 14, 14)

	local settings = {}
	for name, data in pairs(hg.zchatConVars or {}) do
		if isstring(name) and name:StartWith("zchat_") then
			settings[#settings + 1] = data
		end
	end

	table.sort(settings, function(a, b)
		return a.name < b.name
	end)

	for _, data in ipairs(settings) do
		local convar = GetConVar(data.name)
		if not convar then continue end

		if data.type == "bool" then
			CreateZChatBoolRow(scroll, data, convar)
		elseif data.type == "number" then
			CreateZChatNumberRow(scroll, data, convar)
		else
			CreateZChatStringRow(scroll, data, convar)
		end
	end
end

local PANEL = {}

function PANEL:Init()
	self.text = ""
	self.alpha = 0
	self.fadeDelay = 15
	self.fadeDuration = 5
	self.yAnimDuration = 1

	self.yAnim = 5
end

function PANEL:SetMarkup(text)
	self.text = text

	self.markup = hg.markup.Parse(self.text, self:GetWide())
	self.markup.onDrawText = PaintMarkupOverride

	self:SetTall(self.markup:GetHeight())

	timer.Simple(self.fadeDelay, function()
		if (!IsValid(self)) then
			return
		end

		self:CreateAnimation(self.fadeDuration, {
			index = 3,
			target = {alpha = 0}
		})
	end)

	self:CreateAnimation(self.yAnimDuration, {
		index = 4,
		target = {yAnim = 0},
		easing = "outQuint"
	})

	self:CreateAnimation(0.5, {
		index = 3,
		target = {alpha = 255},
	})
end

function PANEL:PerformLayout(width, height)
	self.markup = hg.markup.Parse(self.text, width)
	self.markup.onDrawText = PaintMarkupOverride

	self:SetTall(self.markup:GetHeight())
end

function PANEL:Paint(width, height)
	local newAlpha

	if (hg.chat:GetActive()) then
		newAlpha = math.max(hg.chat.alpha, self.alpha)
	else
		newAlpha = self.alpha - (255 - hg.chat.realAlpha)
	end

	DisableClipping(true)
		local chatboxX, chatboxY = hg.chat:GetPos()
		local wide, tall = hg.chat:GetSize()

		render.SetScissorRect(chatboxX, chatboxY, chatboxX + wide, chatboxY + tall, true)
			self.markup:draw(0, self.yAnim, nil, nil, newAlpha)
		render.SetScissorRect(0, 0, 0, 0, false)
	DisableClipping(false)
end

vgui.Register("zChatMessage", PANEL, "Panel")

PANEL = {}

DEFINE_BASECLASS("DTextEntry")

function PANEL:Init()
	self:SetFont("zChatFont")
	self:SetUpdateOnType(true)
	self:SetHistoryEnabled(true)

	self.History = hg.chat.messageHistory
	self.droppedCharacters = {}

	self.prevText = ""

	self:SetTextColor(color_white)

	self:SetPaintBackground(false)

	self.m_bLoseFocusOnClickAway = false
end

function PANEL:AllowInput(newCharacter)
	local text = self:GetText()
	local maxLen = maxLength:GetInt()

	-- we can't check for the proper length using utf-8 since AllowInput is called for single bytes instead of full characters
	if (string.len(text .. newCharacter) > maxLen) then
		surface.PlaySound("common/talk.wav")
		return true
	end
end

function PANEL:Think()
	local text = self:GetText()
	local maxLen = maxLength:GetInt()

	if (text:utf8len() > maxLen) then
		local newText = text:utf8sub(0, maxLen)

		self:SetText(newText)
		self:SetCaretPos(newText:utf8len())
	end
end

local gradient_l = Material("vgui/gradient-l")

function PANEL:Paint(w, h)
	for k, v in ipairs(self.droppedCharacters) do
		local text = v.text
		v.alpha = v.alpha - FrameTime() * 750

		DisableClipping(true)
			surface.SetTextColor(150, 150, 150, v.alpha)
			surface.SetTextPos(v.x, v.y)
			surface.SetFont("zChatFont")
			surface.DrawText(text)
		DisableClipping(false)

		if v.alpha <= 0 then
			table.remove(self.droppedCharacters, k)
		end
	end

	if ShowTextBoxInactive:GetBool() and !hg.chat:GetActive() and self.prevText != "" then
		DisableClipping(true)
		surface.SetAlphaMultiplier(1)
			surface.SetTextColor(150, 150, 150, 55)
			surface.SetTextPos(0, 0)
			surface.SetFont("zChatFont")
			surface.DrawText(self.prevText)
		surface.SetAlphaMultiplier(0)
		DisableClipping(false)
	end

	BaseClass.Paint(self, w, h)
end

function PANEL:OnValueChange(text)
	local prevText = self.prevText

	if NoDrop:GetBool() then
		local len1, len2 = string.utf8len(prevText), string.utf8len(text)

		if len1 > len2 then
			local droppedText = string.utf8sub(prevText, self:GetCaretPos() + 1, self:GetCaretPos() + (len1 - len2))

			local droppedChars = string.Explode(utf8.charpattern, droppedText)
			for k, v in ipairs(droppedChars) do
				local data = {}
				data.text = v

				surface.SetFont("zChatFont")
				-- local tw1 = surface.GetTextSize(text)
				local tw2 = surface.GetTextSize(v)

				data.x = tw2 * (self:GetCaretPos())

				-- local panelWide = self:GetWide()

				-- if data.x > panelWide then
				-- 	data.x = data.x - (data.x - panelWide)
				-- end

				data.y = 8

				data.alpha = 255

				table.insert(self.droppedCharacters, data)
			end
		end
	end

	self.prevText = text
end

vgui.Register("zChatboxEntry", PANEL, "DTextEntry")

PANEL = {}

AccessorFunc(PANEL, "bActive", "Active", FORCE_BOOL)
AccessorFunc(PANEL, "realAlpha", "RealAlpha", FORCE_BOOL)

function PANEL:Init()
	hg.chat = self

	self.entries = {}
	self.messageHistory = {}

	self.alpha = 255
	self.realAlpha = 255
	self.dragState = nil

	local x, y, w, h = GetSavedChatBounds()
	self:SetSize(w, h)
	self:SetPos(x, y)

	self.hatPanel = vgui.Create("EditablePanel")
	self.hatPanel.Paint = PaintHatPanel

	self.settingsButton = self.hatPanel:Add("DButton")
	self.hatPanel.settingsButton = self.settingsButton
	self.settingsButton:Dock(RIGHT)
	self.settingsButton:SetWide(26)
	self.settingsButton:SetText("")
	self.settingsButton.Paint = PaintSettingsButton
	self.settingsButton.DoClick = OpenZChatSettings

	self.dragHandle = self.hatPanel:Add("DButton")
	self.dragHandle:Dock(FILL)
	self.dragHandle:DockMargin(0, 0, 4, 0)
	self.dragHandle:SetText("")
	self.dragHandle:SetCursor("sizeall")
	self.dragHandle.Paint = function() end
	self.dragHandle.DoClick = function() end
	self.dragHandle.OnMousePressed = function(_, mouseCode)
		if mouseCode == MOUSE_LEFT and self:GetActive() then
			self:BeginDrag("move")
		end
	end
	self.dragHandle.OnMouseReleased = function(_, mouseCode)
		if mouseCode == MOUSE_LEFT then
			self:StopDrag()
		end
	end

	local entryPanel = self:Add("Panel")
	self.entryPanel = entryPanel
	entryPanel:SetZPos(1)
	entryPanel:Dock(BOTTOM)
	entryPanel:DockMargin(4, 0, 4, 4)
	entryPanel:SetTall(30)
	entryPanel.Paint = PaintEntryPanel

	self.entry = entryPanel:Add("zChatboxEntry")
	self.entry:Dock(FILL)
	self.entry:DockMargin(4, 0, 4, 0)
	self.entry.OnEnter = CallbackBind(self, self.OnMessageSent)

	self.history = self:Add("DScrollPanel")
	self.history:Dock(FILL)
	self.history:DockMargin(4, 2, 4, 4)

	SyncHatPanel(self)
	self:SetActive(false)
end

local gray = Color(255, 255, 255, 100)
local black = Color(0, 0, 0, 200)

function PANEL:PerformLayout(w, h)
	SyncHatPanel(self)
end

function PANEL:RefreshFonts()
	surface.SetFont("zChatFont")
	local _, textH = surface.GetTextSize("Hg")
	self.entry:SetFont("zChatFont")
	self.entryPanel:SetTall(math.max(30, textH + 10))

	for _, panel in ipairs(self.entries) do
		if IsValid(panel) then
			panel:InvalidateLayout(true)
		end
	end

	self.history:InvalidateLayout(true)
	self:InvalidateLayout(true)
	SaveChatBounds(self)
end

function PANEL:GetResizeMask(x, y)
	local left = x <= chatResizeEdge
	local right = x >= self:GetWide() - chatResizeEdge
	local top = y <= chatResizeEdge
	local bottom = y >= self:GetTall() - chatResizeEdge

	if not left and not right and not top and not bottom then
		return nil
	end

	local cursor = "arrow"

	if (left and top) or (right and bottom) then
		cursor = "sizenwse"
	elseif (right and top) or (left and bottom) then
		cursor = "sizenesw"
	elseif left or right then
		cursor = "sizewe"
	elseif top or bottom then
		cursor = "sizens"
	end

	return {
		left = left,
		right = right,
		top = top,
		bottom = bottom,
		cursor = cursor
	}
end

function PANEL:BeginDrag(kind, mask)
	local mouseX, mouseY = gui.MousePos()
	local x, y = self:GetPos()
	local w, h = self:GetSize()

	self.dragState = {
		kind = kind,
		mask = mask,
		mouseX = mouseX,
		mouseY = mouseY,
		x = x,
		y = y,
		w = w,
		h = h
	}

	self:MouseCapture(true)
end

function PANEL:StopDrag()
	if not self.dragState then return end
	self.dragState = nil
	self:MouseCapture(false)
	SaveChatBounds(self)
	SyncHatPanel(self)
end

function PANEL:OnMousePressed(mouseCode)
	if mouseCode != MOUSE_LEFT or not self:GetActive() then return end

	local x, y = self:ScreenToLocal(gui.MousePos())
	local mask = self:GetResizeMask(x, y)

	if mask then
		self:BeginDrag("resize", mask)
		self:SetCursor(mask.cursor)
		return
	end

end

function PANEL:OnMouseReleased(mouseCode)
	if mouseCode == MOUSE_LEFT then
		self:StopDrag()
	end
end

function PANEL:Think()
	local state = self.dragState

	if state then
		local mouseX, mouseY = gui.MousePos()
		local dx = mouseX - state.mouseX
		local dy = mouseY - state.mouseY

		if state.kind == "move" then
			local x, y, w, h = ClampChatBounds(state.x + dx, state.y + dy, state.w, state.h)
			self:SetPos(x, y)
			self:SetSize(w, h)
		else
			local x = state.x
			local y = state.y
			local w = state.w
			local h = state.h
			local right = state.x + state.w
			local bottom = state.y + state.h
			local mask = state.mask

			if mask.left then
				x = math.min(state.x + dx, right - chatMinWidth)
				w = right - x
			end

			if mask.right then
				w = math.max(chatMinWidth, state.w + dx)
			end

			if mask.top then
				y = math.min(state.y + dy, bottom - chatMinHeight)
				h = bottom - y
			end

			if mask.bottom then
				h = math.max(chatMinHeight, state.h + dy)
			end

			x, y, w, h = ClampChatBounds(x, y, w, h)
			self:SetPos(x, y)
			self:SetSize(w, h)
		end

		self:InvalidateLayout()
	end

	SyncHatPanel(self)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(chatBoxColor)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(chatVignetteColor.r, chatVignetteColor.g, chatVignetteColor.b, chatVignetteColor.a + math.sin(CurTime()) * 12)
	surface.SetMaterial(gradient_d)
	surface.DrawTexturedRect(0, h * 0.5, w, h * 0.5)

	surface.SetDrawColor(chatOutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	surface.SetDrawColor(chatInnerOutlineColor)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)

	surface.SetAlphaMultiplier(1)
		self.history:PaintManual()
		local bar = self.history:GetVBar()
		bar:SetAlpha(self:GetAlpha())
	surface.SetAlphaMultiplier(self:GetAlpha() / 255)

	DisableClipping(true)
		draw.SimpleText("Hold left ALT and press ENTER to whisper", "zChatFontSmall", 5, h * 1.01 + 1, black)
		draw.SimpleText("Hold left ALT and press ENTER to whisper", "zChatFontSmall", 4, h * 1.01, gray)

		if LocalPlayer().organism and LocalPlayer().organism.otrub  then
			draw.SimpleText("Your messages are currently not visible to anyone.", "zChatFontSmall", ScrW() * 0.3 + 1, h * 1.01 + 1, black, TEXT_ALIGN_RIGHT)
			draw.SimpleText("Your messages are currently not visible to anyone.", "zChatFontSmall", ScrW() * 0.3, h * 1.01, gray, TEXT_ALIGN_RIGHT)
		end
	DisableClipping(false)

	if self.bActive then
		self:SetAlpha(self.alpha - (255 - self.realAlpha))
	end
end

function PANEL:OpenSettings()
	OpenZChatSettings()
end

function PANEL:SetActive(bActive, bRemovePrev)
	if (bActive) then
		self:SetAlpha(255)
		self:MakePopup()
		self.entry:RequestFocus()
		self.hatPanel:SetMouseInputEnabled(true)
		self.hatPanel:SetKeyboardInputEnabled(false)

		input.SetCursorPos(self:LocalToScreen(10, self:GetTall() + 10))

		hook.Run("StartChat")
	else
		self:SetAlpha(0)
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
		self.hatPanel:SetMouseInputEnabled(false)
		self.hatPanel:SetKeyboardInputEnabled(false)

		if bRemovePrev then
			self.entry:SetText("")
			self.entry.prevText = ""
		end

		gui.EnableScreenClicker(false)

		hook.Run("FinishChat")
	end

	self.bActive = bActive

	local bar = self.history:GetVBar()
	bar:SetScroll(bar.CanvasSize)
end

function PANEL:OnRemove()
	if IsValid(self.hatPanel) then
		self.hatPanel:Remove()
	end
end

function PANEL:AnimateAlpha(newAlpha)
	self:CreateAnimation(1, {
		index = 1,
		target = {alpha = newAlpha},
	})
end

function PANEL:AnimateRealAlpha(newAlpha)
	self:CreateAnimation(1, {
		index = 2,
		target = {realAlpha = newAlpha},
	})
end

function PANEL:SetRealAlpha(alpha)
	self.realAlpha = alpha
end

function PANEL:OnMessageSent()
	local text = self.entry:GetText()

	if (text:find("%S")) then
		local lastEntry = hg.chat.messageHistory[#hg.chat.messageHistory]

		-- only add line to textentry history if it isn't the same message
		if (lastEntry != text) then
			if (#hg.chat.messageHistory >= 20) then
				table.remove(hg.chat.messageHistory, 1)
			end

			hg.chat.messageHistory[#hg.chat.messageHistory + 1] = text
		end

		net.Start("zChatMessage")
			net.WriteString(text)
		net.SendToServer()
	end

	self:SetActive(false, true)
end

function PANEL:AddLine(elements)
	local buffer = {
		"<font=zChatFont>"
	}

	buffer = hook.Run("ModifyMessageBuffer", buffer, CHAT_SPEAKER) or buffer

	for _, v in ipairs(elements) do
		if (type(v) == "IMaterial") then
			local texture = v:GetName()

			if (texture) then
				buffer[#buffer + 1] = string.format("<img=%s,%dx%d> ", texture, v:Width(), v:Height())
			end
		elseif (istable(v) and v.r and v.g and v.b) then
			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>", v.r, v.g, v.b)
		elseif (type(v) == "Player") then
			local color = team.GetColor(v:Team())

			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>%s", color.r, color.g, color.b,
				v:GetName():gsub("<", "&lt;"):gsub(">", "&gt;"))
		else
			buffer[#buffer + 1] = tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end

	local panel = self.history:Add("zChatMessage")
	panel:Dock(TOP)
	panel:InvalidateParent(true)
	panel:SetMarkup(table.concat(buffer))

	if (#self.entries >= 100) then
		local oldPanel = table.remove(self.entries, 1)

		if (IsValid(oldPanel)) then
			oldPanel:Remove()
		end
	end

	local bar = self.history:GetVBar()
	local bScroll = !self:GetActive() or bar.Scroll == bar.CanvasSize -- only scroll when we're not at the bottom/inactive

	if bScroll then
		bar:SetScroll(bar.CanvasSize)
	end

	self.entries[#self.entries + 1] = panel
	return panel
end

function PANEL:AddMessage(...)
	self:AddLine({...})

	chat.PlaySound()
end

vgui.Register("zChatbox", PANEL, "EditablePanel")

concommand.Add("zchat_settings", function()
	OpenZChatSettings()
end)
