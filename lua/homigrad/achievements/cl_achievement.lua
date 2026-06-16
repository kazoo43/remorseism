hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

hg.achievements.MenuPanel = hg.achievements.MenuPanel or nil

local achievement_active_key

concommand.Add("hg_achievements", function()
    print("use esc menu")
end)

local function MenuUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local function AchievementFontName()
    return "Verily Serif Mono"
end

local function CreateAchievementFonts()
    local scale = math.min(ScrW(), ScrH()) / 1000
    local usefont = AchievementFontName()

    surface.CreateFont("ZCity_Ach_Title", {
        font = usefont,
        size = math.max(18, math.floor(34 * scale)),
        weight = 300
    })

    surface.CreateFont("ZCity_Ach_Medium", {
        font = usefont,
        size = math.max(16, math.floor(26 * scale)),
        weight = 300
    })

    surface.CreateFont("ZCity_Ach_Small", {
        font = usefont,
        size = math.max(14, math.floor(20 * scale)),
        weight = 300
    })

    surface.CreateFont("ZCity_Ach_Tiny", {
        font = usefont,
        size = math.max(12, math.floor(16 * scale)),
        weight = 300
    })
end

hook.Add("OnScreenSizeChanged", "ZCity_Achievement_Fonts", CreateAchievementFonts)
CreateAchievementFonts()

local achievement_header_height = 70
local achievement_color_white = Color(255,255,255,240)
local achievement_color_dim = Color(60,60,60,180)
local achievement_color_text = Color(225,225,225)
local achievement_color_text_dim = Color(160,160,160)
local achievement_color_accent = Color(192,57,43)
local achievement_gradient_right = Color(18,18,18,65)
local achievement_overlay = Color(100,100,100,35)
local achievement_bg = Color(10,10,19,235)
local achievement_card = Color(20,20,30,120)
local achievement_card_strong = Color(15,15,20,120)
local achievement_border = Color(255,255,255,90)
local achievement_placeholder = Material("homigrad/vgui/models/star.png", "smooth")
local gradient_u = Material("vgui/gradient-u")
local tex_gradient_d = surface.GetTextureID("vgui/gradient-d")
local tex_gradient_r = surface.GetTextureID("vgui/gradient-r")
local tex_gradient_l = surface.GetTextureID("vgui/gradient-l")

local function AchievementGetLocalTable()
    if not hg or not hg.achievements or not hg.achievements.GetLocalAchievements then
        return {}
    end
    return hg.achievements.GetLocalAchievements() or {}
end

local function AchievementGetSortedEntries()
    local created = hg and hg.achievements and hg.achievements.achievements_data and hg.achievements.achievements_data.created_achevements or {}
    local localach = AchievementGetLocalTable()
    local entries = {}

    for key, ach in pairs(created or {}) do
        local startValue = tonumber(ach.start_value) or 0
        local neededValue = math.max(tonumber(ach.needed_value) or 1, 1)
        local currentValue = localach[key] and tonumber(localach[key].value) or startValue
        local denominator = math.max(neededValue - startValue, 1)
        local normalized = math.Clamp((currentValue - startValue) / denominator, 0, 1)
        local completed = currentValue >= neededValue
        local percent = math.Clamp(math.Round(normalized * 100), 0, 100)

        entries[#entries + 1] = {
            key = key,
            data = ach,
            name = tostring(ach.name or "Achievement"),
            description = tostring(ach.description or ""):gsub("\\n", "\n"),
            image = isstring(ach.img) and Material(ach.img, "smooth") or ach.img or achievement_placeholder,
            current = currentValue,
            needed = neededValue,
            progress = normalized,
            percent = percent,
            completed = completed,
            status = completed and "Completed" or (percent > 0 and "In Progress" or "Locked")
        }
    end

    table.sort(entries, function(a, b)
        if a.completed ~= b.completed then
            return a.completed and not b.completed
        end
        if a.progress ~= b.progress then
            return a.progress > b.progress
        end
        return a.name < b.name
    end)

    return entries
end

local function AchievementCreateReturnButton(sidebar, ParentPanel)
    local backBtn = vgui.Create("DLabel", sidebar)
    backBtn:Dock(BOTTOM)
    backBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(20))
    backBtn:SetFont("ZCity_Ach_Small")
    backBtn:SetTextColor(achievement_color_text)
    backBtn:SetText(string.rep("#", #"<- Return"))
    backBtn:SetMouseInputEnabled(true)
    backBtn:SizeToContents()
    backBtn:SetTall(MenuUnit(42))
    backBtn.OpenTime = CurTime()
    backBtn.HoverLerp = 0
    backBtn.LineLerp = 0

    function backBtn:DoClick()
        if IsValid(ParentPanel) then
            local luaMenu = ParentPanel:GetParent()
            ParentPanel:AlphaTo(0, 0.2, 0, function()
                if IsValid(ParentPanel) then ParentPanel:Remove() end
            end)
            if IsValid(luaMenu) then
                for _, child in ipairs(luaMenu:GetChildren()) do
                    if child ~= ParentPanel then
                        child:SetVisible(true)
                        child:AlphaTo(255, 0.2, 0)
                    end
                end
                if luaMenu.panelparrent then
                    luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
                    luaMenu.panelparrent:SetPos(0, 0)
                    luaMenu.panelparrent:SetSize(ScrW(), ScrH())
                    luaMenu.panelparrent:MoveToFront()
                    luaMenu.panelparrent:SetMouseInputEnabled(false)
                    luaMenu.panelparrent.Paint = function() end
                end
                if luaMenu.ResetCurrentPanel then
                    luaMenu:ResetCurrentPanel()
                end
            else
                ParentPanel:Remove()
            end
        end
    end

    function backBtn:Think()
        local isHovered = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)
        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local target = "<- Return"
        local len = #target
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    function backBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = achievement_color_text
        local outlineColor = Color(0, 0, 0, 255)
        if isHovered then
            local v = flash * 255
            textColor = Color(v, v, v, 255)
            local inv = 255 - v
            outlineColor = Color(inv, inv, inv, 255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * 0.008
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        cam.PopModelMatrix()
        return true
    end

    return backBtn
end

local function AchievementCreateHeaderReturnButton(parent, ParentPanel)
    local backBtn = vgui.Create("DLabel", parent)
    backBtn:SetFont("ZCity_Ach_Small")
    backBtn:SetTextColor(achievement_color_text)
    backBtn:SetText(string.rep("#", #"<- Return"))
    backBtn:SetMouseInputEnabled(true)
    backBtn:SizeToContents()
    backBtn:SetTall(MenuUnit(42))
    backBtn.OpenTime = CurTime()
    backBtn.HoverLerp = 0
    backBtn.LineLerp = 0

    function backBtn:DoClick()
        if IsValid(ParentPanel) then
            local luaMenu = ParentPanel:GetParent()
            ParentPanel:AlphaTo(0, 0.2, 0, function()
                if IsValid(ParentPanel) then ParentPanel:Remove() end
            end)
            if IsValid(luaMenu) then
                for _, child in ipairs(luaMenu:GetChildren()) do
                    if child ~= ParentPanel then
                        child:SetVisible(true)
                        child:AlphaTo(255, 0.2, 0)
                    end
                end
                if luaMenu.panelparrent then
                    luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
                    luaMenu.panelparrent:SetPos(0, 0)
                    luaMenu.panelparrent:SetSize(ScrW(), ScrH())
                    luaMenu.panelparrent:MoveToFront()
                    luaMenu.panelparrent:SetMouseInputEnabled(false)
                    luaMenu.panelparrent.Paint = function() end
                end
                if luaMenu.ResetCurrentPanel then
                    luaMenu:ResetCurrentPanel()
                end
            else
                ParentPanel:Remove()
            end
        end
    end

    function backBtn:Think()
        local isHovered = self:IsHovered()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
        self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)
        local elapsed = CurTime() - self.OpenTime
        local charsToShow = math.floor(elapsed * 15)
        local target = "<- Return"
        local len = #target
        if charsToShow > len then charsToShow = len end
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            surface.PlaySound("shitty/tap-resonant.wav")
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    function backBtn:Paint(w, h)
        local isHovered = self:IsHovered()
        local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
        local textColor = achievement_color_text
        local outlineColor = Color(0, 0, 0, 255)
        if isHovered then
            local v = flash * 255
            textColor = Color(v, v, v, 255)
            local inv = 255 - v
            outlineColor = Color(inv, inv, inv, 255)
        end
        surface.SetFont(self:GetFont())
        local tw, th = surface.GetTextSize(self:GetText())
        local scale = 1 + (self.HoverLerp or 0) * 0.008
        local matrix = Matrix()
        matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
        if self.LineLerp and self.LineLerp > 0.01 then
            surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
            surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
        end
        cam.PopModelMatrix()
        return true
    end

    return backBtn
end

local function AchievementGetMarqueeOffset(text, fontName, availableWidth, rowWidth)
    surface.SetFont(fontName)
    local textWidth = surface.GetTextSize(text or "")
    if textWidth <= availableWidth then
        return 0, textWidth
    end

    local overflow = textWidth - availableWidth
    local pause = 0.8
    local travelTime = math.max(overflow / 45, 1.6)
    local cycle = pause + travelTime + pause + travelTime
    local t = CurTime() + (rowWidth or 0) * 0.0005
    local progress = t % cycle

    if progress < pause then
        return 0, textWidth
    end

    progress = progress - pause
    if progress < travelTime then
        return -overflow * (progress / travelTime), textWidth
    end

    progress = progress - travelTime
    if progress < pause then
        return -overflow, textWidth
    end

    progress = progress - pause
    return -overflow * (1 - progress / travelTime), textWidth
end

function hg.DrawAchievmentsMenu(ParentPanel)
    if not IsValid(ParentPanel) then return end

    hg.achievements.LoadAchievements()

    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:Remove()
        hg.achievements.MenuPanel = nil
    end

    ParentPanel:SetAlpha(0)
    ParentPanel.Paint = function(self, w, h)
        if hg.DrawBlur then hg.DrawBlur(self, 5) end
        draw.RoundedBox(0, 0, 0, w, h, achievement_bg)
        surface.SetDrawColor(achievement_gradient_right)
        surface.SetTexture(tex_gradient_r)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(achievement_bg)
        surface.SetTexture(tex_gradient_l)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(achievement_overlay)
        surface.SetTexture(tex_gradient_d)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    ParentPanel:AlphaTo(255, 0.15, 0)

    local root = vgui.Create("DPanel", ParentPanel)
    root:SetSize(ParentPanel:GetWide(), ParentPanel:GetTall())
    root:SetPos(0, 0)
    root.Paint = function() end
    hg.achievements.MenuPanel = root

    local mainPanel = vgui.Create("DPanel", root)
    mainPanel:SetSize(ScrW(), ScrH())
    mainPanel:SetPos(0, 0)
    mainPanel.TargetX = 0
    mainPanel.Think = function(self)
        local curX, curY = self:GetPos()
        if math.abs(curX - self.TargetX) > 0.5 then
            self:SetPos(Lerp(FrameTime() * 8, curX, self.TargetX), curY)
        else
            self:SetPos(self.TargetX, curY)
        end
    end
    mainPanel.Paint = function() end

    local header = vgui.Create("DPanel", mainPanel)
    header:Dock(TOP)
    header:SetTall(MenuUnit(achievement_header_height))
    header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, achievement_card_strong)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local backBtn = AchievementCreateHeaderReturnButton(header, ParentPanel)
    backBtn:SetPos(MenuUnit(25), MenuUnit(16))

    local headerTitle = vgui.Create("DLabel", header)
    headerTitle:SetFont("ZCity_Ach_Title")
    headerTitle:SetTextColor(achievement_color_white)
    headerTitle:SetText("ACHIEVEMENTS")
    headerTitle:SizeToContents()

    local headerHint = vgui.Create("DLabel", header)
    headerHint:SetFont("ZCity_Ach_Tiny")
    headerHint:SetTextColor(achievement_color_text_dim)
    headerHint:SetText("")
    headerHint:SetVisible(false)

    header.Think = function(self)
        if not IsValid(backBtn) or not IsValid(headerTitle) then return end
        local titleX = backBtn:GetX() + backBtn:GetWide() + MenuUnit(18)
        headerTitle:SetPos(titleX, MenuUnit(18))
        if IsValid(headerHint) then
            headerHint:SetPos(titleX, MenuUnit(48))
        end
    end

    local contentHolder = vgui.Create("DPanel", mainPanel)
    contentHolder:Dock(FILL)
    contentHolder:DockMargin(MenuUnit(22), MenuUnit(22), MenuUnit(22), MenuUnit(22))
    contentHolder.Paint = function() end

    local body = vgui.Create("DPanel", contentHolder)
    body:Dock(FILL)
    body.Paint = function() end

    local listCard = vgui.Create("DPanel", body)
    listCard:Dock(LEFT)
    listCard:SetWide(math.max(MenuUnit(430), math.floor(ScrW() * 0.5)))
    listCard:DockMargin(0, 0, MenuUnit(14), 0)
    listCard.Paint = function(self, w, h)
        surface.SetDrawColor(achievement_card.r, achievement_card.g, achievement_card.b, achievement_card.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 70)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local listHeader = vgui.Create("DPanel", listCard)
    listHeader:Dock(TOP)
    listHeader:SetTall(MenuUnit(54))
    listHeader.Paint = function(self, w, h)
        surface.SetDrawColor(achievement_card_strong.r, achievement_card_strong.g, achievement_card_strong.b, achievement_card_strong.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 70)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local listTitle = vgui.Create("DLabel", listHeader)
    listTitle:SetPos(MenuUnit(14), MenuUnit(10))
    listTitle:SetFont("ZCity_Ach_Small")
    listTitle:SetTextColor(achievement_color_white)
    listTitle:SetText("ALL ACHIEVEMENTS")
    listTitle:SizeToContents()

    local listHint = vgui.Create("DLabel", listHeader)
    listHint:SetPos(MenuUnit(14), MenuUnit(30))
    listHint:SetFont("ZCity_Ach_Tiny")
    listHint:SetTextColor(achievement_color_text_dim)
    listHint:SetText("Completed entries rise to the top")
    listHint:SizeToContents()

    local listScroll = vgui.Create("DScrollPanel", listCard)
    listScroll:Dock(FILL)
    listScroll:DockMargin(MenuUnit(10), MenuUnit(10), MenuUnit(10), MenuUnit(10))
    listScroll.Paint = function() end

    local listBar = listScroll:GetVBar()
    listBar:SetWide(MenuUnit(4))
    listBar:SetHideButtons(true)
    function listBar:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 80)
        surface.DrawRect(0, 0, w, h)
    end
    function listBar.btnGrip:Paint(w, h)
        local col = self:IsHovered() and achievement_color_white or achievement_color_dim
        draw.RoundedBox(2, 1, 1, w - 2, h - 2, col)
    end

    local detailCard = vgui.Create("DPanel", body)
    detailCard:Dock(FILL)
    detailCard.Paint = function(self, w, h)
        surface.SetDrawColor(achievement_card.r, achievement_card.g, achievement_card.b, achievement_card.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 70)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local detailHeader = vgui.Create("DPanel", detailCard)
    detailHeader:Dock(TOP)
    detailHeader:SetTall(MenuUnit(54))
    detailHeader.Paint = function(self, w, h)
        surface.SetDrawColor(achievement_card_strong.r, achievement_card_strong.g, achievement_card_strong.b, achievement_card_strong.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 70)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local detailHeaderTitle = vgui.Create("DLabel", detailHeader)
    detailHeaderTitle:SetPos(MenuUnit(14), MenuUnit(10))
    detailHeaderTitle:SetFont("ZCity_Ach_Small")
    detailHeaderTitle:SetTextColor(achievement_color_white)
    detailHeaderTitle:SetText("DETAILS")
    detailHeaderTitle:SizeToContents()

    local detailHeaderHint = vgui.Create("DLabel", detailHeader)
    detailHeaderHint:SetPos(MenuUnit(14), MenuUnit(30))
    detailHeaderHint:SetFont("ZCity_Ach_Tiny")
    detailHeaderHint:SetTextColor(achievement_color_text_dim)
    detailHeaderHint:SetText("Selected achievement overview")
    detailHeaderHint:SizeToContents()

    local detailContent = vgui.Create("DPanel", detailCard)
    detailContent:Dock(FILL)
    detailContent:DockMargin(MenuUnit(18), MenuUnit(18), MenuUnit(18), MenuUnit(18))
    detailContent.Paint = function() end

    local detailIcon = vgui.Create("DPanel", detailContent)
    detailIcon:SetSize(MenuUnit(120), MenuUnit(120))
    detailIcon.IconMat = achievement_placeholder
    detailIcon.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 60)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.IconMat or achievement_placeholder)
        surface.DrawTexturedRect(MenuUnit(16), MenuUnit(16), w - MenuUnit(32), h - MenuUnit(32))
    end

    local detailName = vgui.Create("DPanel", detailContent)
    detailName.DisplayText = "No achievements loaded"
    detailName.Paint = function(self, w, h)
        local text = self.DisplayText or ""
        local textOffset = AchievementGetMarqueeOffset(text, "ZCity_Ach_Title", w, w)
        local clipX1, clipY1 = self:LocalToScreen(0, 0)
        local clipX2, clipY2 = self:LocalToScreen(w, h)
        render.SetScissorRect(clipX1, clipY1, clipX2, clipY2, true)
        draw.SimpleText(text, "ZCity_Ach_Title", textOffset, h * 0.5, achievement_color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    local detailStatus = vgui.Create("DLabel", detailContent)
    detailStatus:SetFont("ZCity_Ach_Small")
    detailStatus:SetTextColor(achievement_color_text)
    detailStatus:SetText("Waiting for achievement data")
    detailStatus:SizeToContents()

    local detailDesc = vgui.Create("DLabel", detailContent)
    detailDesc:SetFont("ZCity_Ach_Tiny")
    detailDesc:SetTextColor(achievement_color_text_dim)
    detailDesc:SetWrap(true)
    detailDesc:SetAutoStretchVertical(true)
    detailDesc:SetText("Open the menu again if achievements do not appear immediately.")

    local detailProgress = vgui.Create("DLabel", detailContent)
    detailProgress:SetFont("ZCity_Ach_Tiny")
    detailProgress:SetTextColor(achievement_color_text_dim)
    detailProgress:SetText("")
    detailProgress:SizeToContents()

    local detailBar = vgui.Create("DPanel", detailContent)
    detailBar.Progress = 0
    detailBar.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 160)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(achievement_color_accent.r, achievement_color_accent.g, achievement_color_accent.b, 220)
        surface.DrawRect(0, 0, math.floor(w * (self.Progress or 0)), h)
        surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 80)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local detailMeta = vgui.Create("DLabel", detailContent)
    detailMeta:SetFont("ZCity_Ach_Tiny")
    detailMeta:SetTextColor(achievement_color_text_dim)
    detailMeta:SetText("")
    detailMeta:SizeToContents()

    detailContent.PerformLayout = function(self, w, h)
        local iconSize = math.min(MenuUnit(140), math.floor(w * 0.22))
        detailIcon:SetSize(iconSize, iconSize)
        detailIcon:SetPos(0, 0)

        local textX = iconSize + MenuUnit(18)
        local textW = math.max(MenuUnit(220), w - textX)

        detailName:SetPos(textX, 0)
        detailName:SetWide(textW)
        detailName:SetTall(MenuUnit(40))

        detailStatus:SetPos(textX, MenuUnit(40))
        detailStatus:SetWide(textW)
        detailStatus:SizeToContentsY()

        detailDesc:SetPos(textX, MenuUnit(68))
        detailDesc:SetWide(textW)
        detailDesc:InvalidateLayout(true)

        local descBottom = detailDesc:GetY() + detailDesc:GetTall() + MenuUnit(18)
        local blockTop = math.max(iconSize + MenuUnit(20), descBottom)

        detailProgress:SetPos(0, blockTop)
        detailProgress:SetWide(w)
        detailProgress:SizeToContentsY()

        detailBar:SetPos(0, blockTop + MenuUnit(22))
        detailBar:SetSize(w, MenuUnit(12))

        detailMeta:SetPos(0, blockTop + MenuUnit(44))
        detailMeta:SetWide(w)
        detailMeta:SizeToContentsY()
    end

    function root:GetActiveEntry()
        if not self.Entries or #self.Entries == 0 then return nil end
        for _, entry in ipairs(self.Entries) do
            if entry.key == achievement_active_key then
                return entry
            end
        end
        achievement_active_key = self.Entries[1].key
        return self.Entries[1]
    end

    function root:RefreshList()
        listScroll:Clear()

        if not self.Entries or #self.Entries == 0 then
            local empty = vgui.Create("DLabel", listScroll)
            empty:Dock(TOP)
            empty:SetTall(MenuUnit(40))
            empty:SetFont("ZCity_Ach_Tiny")
            empty:SetTextColor(achievement_color_text_dim)
            empty:SetContentAlignment(5)
            empty:SetText("NO ACHIEVEMENTS AVAILABLE")
            return
        end

        for _, entry in ipairs(self.Entries) do
            local row = vgui.Create("DButton", listScroll)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, MenuUnit(8))
            row:SetTall(MenuUnit(74))
            row:SetText("")
            row.Entry = entry
            row.HoverLerp = 0

            row.DoClick = function(self)
                achievement_active_key = self.Entry.key
                surface.PlaySound("shitty/tap_depress.wav")
                root:RefreshDetail()
                root:RefreshList()
            end

            row.Think = function(self)
                local active = achievement_active_key == self.Entry.key
                self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, (self:IsHovered() or active) and 1 or 0)
            end

            row.Paint = function(self, w, h)
                local active = achievement_active_key == self.Entry.key
                local alpha = 110 + math.floor((self.HoverLerp or 0) * 40)
                local percentText = self.Entry.percent .. "%"
                local percentFont = "ZCity_Ach_Tiny"
                local nameFont = "ZCity_Ach_Small"
                surface.SetFont(percentFont)
                local percentW = surface.GetTextSize(percentText)
                local nameX = MenuUnit(12)
                local nameY = MenuUnit(16)
                local rightPadding = MenuUnit(12)
                local nameAvailable = math.max(10, w - nameX - rightPadding - percentW - MenuUnit(16))
                local nameOffset = AchievementGetMarqueeOffset(self.Entry.name, nameFont, nameAvailable, w)
                surface.SetDrawColor(20, 20, 30, alpha)
                surface.DrawRect(0, 0, w, h)
                if active then
                    surface.SetDrawColor(achievement_color_accent.r, achievement_color_accent.g, achievement_color_accent.b, 220)
                    surface.DrawRect(0, 0, MenuUnit(2), h)
                end
                surface.SetDrawColor(achievement_color_white.r, achievement_color_white.g, achievement_color_white.b, 55 + math.floor((self.HoverLerp or 0) * 60))
                surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
                local clipX1, clipY1 = self:LocalToScreen(nameX, nameY - MenuUnit(14))
                local clipX2, clipY2 = self:LocalToScreen(nameX + nameAvailable, nameY + MenuUnit(14))
                render.SetScissorRect(clipX1, clipY1, clipX2, clipY2, true)
                draw.SimpleText(self.Entry.name, nameFont, nameX + nameOffset, nameY, achievement_color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                render.SetScissorRect(0, 0, 0, 0, false)
                draw.SimpleText(self.Entry.status, "ZCity_Ach_Tiny", MenuUnit(12), MenuUnit(38), achievement_color_text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(percentText, percentFont, w - MenuUnit(12), MenuUnit(16), achievement_color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(0, 0, 0, 160)
                surface.DrawRect(MenuUnit(12), h - MenuUnit(18), w - MenuUnit(24), MenuUnit(6))
                surface.SetDrawColor(achievement_color_accent.r, achievement_color_accent.g, achievement_color_accent.b, 220)
                surface.DrawRect(MenuUnit(12), h - MenuUnit(18), math.floor((w - MenuUnit(24)) * self.Entry.progress), MenuUnit(6))
            end
        end
    end

    function root:RefreshDetail()
        local entry = self:GetActiveEntry()
        if not entry then
            detailIcon.IconMat = achievement_placeholder
            detailName.DisplayText = "No achievements loaded"
            detailStatus:SetText("Waiting for achievement data")
            detailDesc:SetText("Open the menu again if achievements do not appear immediately.")
            detailProgress:SetText("")
            detailMeta:SetText("")
            detailBar.Progress = 0
            detailContent:InvalidateLayout(true)
            return
        end

        detailIcon.IconMat = entry.image or achievement_placeholder
        detailName.DisplayText = string.upper(entry.name)
        detailStatus:SetText(entry.status)
        detailDesc:SetText(entry.description ~= "" and entry.description or "No description provided.")
        detailProgress:SetText(entry.current .. " / " .. entry.needed .. " progress")
        detailMeta:SetText(entry.completed and "This achievement is already unlocked." or "Keep playing to finish this achievement.")
        detailBar.Progress = entry.progress
        detailContent:InvalidateLayout(true)
    end

    function root:UpdateValues()
        self.Entries = AchievementGetSortedEntries()

        local total = #self.Entries
        local completed = 0
        local inProgress = 0
        for _, entry in ipairs(self.Entries) do
            if entry.completed then
                completed = completed + 1
            elseif entry.progress > 0 then
                inProgress = inProgress + 1
            end
        end
        if self.Entries[1] and not achievement_active_key then
            achievement_active_key = self.Entries[1].key
        end

        if achievement_active_key then
            local exists = false
            for _, entry in ipairs(self.Entries) do
                if entry.key == achievement_active_key then
                    exists = true
                    break
                end
            end
            if not exists then
                achievement_active_key = self.Entries[1] and self.Entries[1].key or nil
            end
        end

        self:RefreshList()
        self:RefreshDetail()
    end

    root:UpdateValues()
end

local time_wait = 0
function hg.achievements.LoadAchievements()
    if time_wait > CurTime() then return end
    time_wait = CurTime() + 2

    net.Start("req_ach")
    net.SendToServer()
end

function hg.achievements.GetLocalAchievements()
    return hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())]
end

net.Receive("req_ach",function()
    hg.achievements.achievements_data.created_achevements = net.ReadTable()
    hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())] = net.ReadTable()
    
    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:UpdateValues()
    end
end)

hg.achievements.NewAchievements = hg.achievements.NewAchievements or {}
local AchTable = hg.achievements.NewAchievements 
net.Receive("hg_NewAchievement",function()
    local Ach = {time = CurTime() + 7.5,name = net.ReadString(),img = net.ReadString()}
    table.insert(AchTable,1,Ach)
	surface.PlaySound("homigrad/vgui/achievement_earned.wav")
end)

local ach_clr1 , ach_clr2 = Color(200,25,25), Color(100,25,25)
hook.Add("HUDPaint","hg_NewAchievement", function()
    local frametime = FrameTime() * 10
    for i = 1, #AchTable do
        local ach = AchTable[i]
        if not ach then continue end
        local txt = "Achievement! "..ach.name
        ach.img = isstring(ach.img) and Material(ach.img) or ach.img
        local wt, _ = surface.GetTextSize(txt)

        ach.Lerp = Lerp( frametime, ach.Lerp or 0, math.min( ach.time - CurTime(), 1 ) * i )
        WSize, HSize = (ScrW() * 0.1) + (wt), ScrH() * 0.05
        local HPos = ScrH() - ( HSize * ach.Lerp )
        draw.RoundedBox( 0, 2, HPos + 2, WSize - 4, HSize - 4, ach_clr2 )
		
		surface.SetDrawColor(155, 0, 0, 255)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect( 0, HPos, WSize, HSize )
	
		surface.SetDrawColor( 150, 0, 0, 255)
		surface.DrawOutlinedRect( 0, HPos, WSize, HSize, 2.5 )

        surface.SetFont("HomigradFontMedium")
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(HSize*1.25,(HPos + ( HSize/2 ) - ( HSize/4 )) )
        surface.DrawText(txt)
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(2,HPos+2,HSize-4,HSize-4)
        if ach.time < CurTime() then 
            table.remove(AchTable,i)
        end
    end
end)
