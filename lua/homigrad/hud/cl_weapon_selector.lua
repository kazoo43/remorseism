--
hg = hg or {}
hg.WeaponSelector = hg.WeaponSelector or {}
local WS = hg.WeaponSelector

function WS.GetPrintName( self )
    local class = self:GetClass()
    local phrase = language.GetPhrase(class)
    return phrase ~= class and phrase or self:GetPrintName() or class
end

WS.Show = 0
WS.Transparent = 0
WS.LastSelectedSlot = 0
WS.LastSelectedSlotPos = 0

WS.SelectedSlot = 0
WS.SelectedSlotPos = 0

function WS.DrawText(text, font, posX, posY, color, textAlign)
    local t = tostring(text or "")
    draw.DrawText( t, font, posX + 1, posY + 1, Color(10, 10, 10, 200), textAlign )
    draw.DrawText( t, font, posX, posY, color, textAlign )
end

function WS.GetSelectedWeapon()
    if not IsValid( LocalPlayer() ) or not LocalPlayer():Alive() then return end
    local Weapons = WS.GetWeaponTable( LocalPlayer() )
    return Weapons[WS.SelectedSlot] and Weapons[WS.SelectedSlot][WS.SelectedSlotPos] or Weapons[WS.LastSelectedSlot][WS.LastSelectedSlotPos] or Weapons[0][0]
end

function WS.GetWeaponTable( ply )
    if not IsValid( ply ) or not ply:Alive() then return end
    local WeaponsGet = ply:GetWeapons()
    local FormatedTable = {
        [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {},
    }

    table.sort(WeaponsGet, function(a, b) return (a.SlotPos or 0) > (b.SlotPos or 0) end)

    for k,wep in ipairs(WeaponsGet) do
        local tTbl = FormatedTable[wep.Slot or 0]
        local iMinPos = math.min( (wep.SlotPos and wep.SlotPos) or 1, ((#tTbl or 0) + 1)) - 1
        local iPos = tTbl[ iMinPos ] and #tTbl + 1 or iMinPos
        tTbl[ iPos ] = wep
    end
    return FormatedTable
end

local function WS_GetFontFace()
    local cv = ConVarExists("hg_font") and GetConVar("hg_font") or nil
    if cv then
        local v = tostring(cv:GetString() or "")
        if v ~= "" then return v end
    end

    return "x14y24pxHeadUpDaisy"
end

surface.CreateFont("WS_CourierNew", {
    font = WS_GetFontFace(),
    size = ScreenScale(8),
    weight = 500,
    antialias = false,
})

local scrW, scrH = ScrW(), ScrH()

local gradient_u = Material("vgui/gradient-d")

function WS.HookWeapon(wep)
    if not IsValid(wep) or wep.IsScrambledHooked then return end

    local oldPrint = wep.PrintWeaponInfo

    wep.PrintWeaponInfo = function(self, x, y, alpha)
        local oldInst = self.Instructions
        local oldPurp = self.Purpose
        local oldDesc = self.Description
        local oldAuth = self.Author
        
        -- Scramble
        self.Instructions = WS.Scramble(self.Instructions)
        self.Purpose = WS.Scramble(self.Purpose)
        self.Description = WS.Scramble(self.Description)
        self.Author = WS.Scramble(self.Author)
        
        -- Call original
        if oldPrint then
            oldPrint(self, x, y, alpha)
        elseif self.DrawWeaponInfoBox then
            self:DrawWeaponInfoBox(x, y, alpha)
        end
        
        -- Restore
        self.Instructions = oldInst
        self.Purpose = oldPurp
        self.Description = oldDesc
        self.Author = oldAuth
    end
    
    wep.IsScrambledHooked = true
end

function WS.WeaponSelectorDraw( ply )
    if not IsValid( ply ) or not ply:Alive() then return end
    local AcsentColor = hg.theme and hg.theme.c.accent or Color(55, 55, 55, 255) -- colors.presetBorder
    if WS.Show < CurTime() then 
        WS.BoxAnim = {}
        WS.TypeState = {}
        WS.SelectedSlot = WS.LastSelectedSlot 
        WS.SelectedSlotPos = -1
        
        return 
    end

    local Weapons = WS.GetWeaponTable( ply )
    local SelectedWep = WS.GetSelectedWeapon()
    if not IsValid(SelectedWep) then return end
    WS.Transparent = LerpFT( 0.2, WS.Transparent, math.min( WS.Show - CurTime(), 1 ) )
    local SuperAmmout = 0
    local AmmoutSlots = 0
    WS.BoxAnim = WS.BoxAnim or {}
    for i = 0, #Weapons do
        local slotTbl = Weapons[i]
        if table.Count(slotTbl) < 1 then continue end
        AmmoutSlots = AmmoutSlots + 1
    end


    for i = 0, #Weapons do
        local slotTbl = Weapons[i]
        if table.Count(slotTbl) < 1 then continue end
        local sizeX = scrW*0.1
        local position = scrW/2 + ( ( SuperAmmout -  (AmmoutSlots/2)) * sizeX )
        
        WS.DrawText( i+1, "WS_CourierNew", position + sizeX/2, scrH*0.02, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
        
        local Ammout = 0
        local lastPos = 0
        for Id = 0, #slotTbl do
            wepId = Id
            local wep = slotTbl[wepId]
            if not wep then continue end
            local sizeH = SelectedWep == wep and (scrH *0.12) or (scrH *0.025)
            local LastSelected = 0
            if slotTbl[wepId-1] and SelectedWep == slotTbl[wepId-1] then
                lastPos = (scrH *0.095) 
            end
            local baseY = (scrH * 0.025) * (Ammout) + (scrH * 0.05) + lastPos
            local drawX, drawY, drawW, drawH = position, baseY, sizeX, sizeH
            if SelectedWep == wep then
                WS.BoxAnim[wep] = WS.BoxAnim[wep] or {h=2}
                WS.BoxAnim[wep].h = LerpFT(0.25, WS.BoxAnim[wep].h, sizeH)
                drawH = WS.BoxAnim[wep].h
            end
            draw.RoundedBox(
                0,
                drawX,
                drawY,
                drawW,
                drawH, 
                ColorAlpha((hg.theme and hg.theme.c.panel or Color(10,10,10)),WS.Transparent*220) -- colors.secondary
            )
            surface.SetDrawColor( AcsentColor.r, AcsentColor.g, AcsentColor.b, WS.Transparent*( SelectedWep == wep and 200 or 0 )  )
            surface.SetMaterial( gradient_u )
            surface.DrawTexturedRect( drawX, drawY, drawW, drawH )
            if SelectedWep == wep then
                surface.SetDrawColor( AcsentColor.r, AcsentColor.g, AcsentColor.b, WS.Transparent*155 )
	            surface.DrawOutlinedRect( drawX, drawY, drawW, drawH, 2 )
            end
            local sizeHi = (scrH *0.025) * (Ammout) + (scrH * 0.05) + lastPos
            sizeHi = sizeHi + 2.5
            local nameKey = wep:GetClass() .. "_name"
            local descKey = wep:GetClass() .. "_desc"
            local nameText = WS.GetPrintName(wep)
            local descText = wep.Description or wep.Instructions or wep.Category or ""
            local nameY = drawY + ScreenScale(2)
            if SelectedWep == wep then
                local showName = WS.Typewriter(nameText, nameKey, 10)
                surface.SetFont("WS_CourierNew")
                local tw, th = surface.GetTextSize(showName)
                local pad = ScreenScale(2)
                local maxW = drawW - pad * 2
                WS.NameScroll = WS.NameScroll or {}
                local target = (tw > maxW) and -(tw - maxW) or 0
                WS.NameScroll[wep] = LerpFT(0.25, WS.NameScroll[wep] or 0, target)

                -- Flash name red N times on selection
                local flashDuration = 0.12
                local flashCount    = 5
                local nameColor     = Color(200, 200, 200, 255)
                local fs = WS.FlashState
                if fs and fs.start then
                    local elapsed = CurTime() - fs.start
                    local flashIdx = math.floor(elapsed / flashDuration)
                    if flashIdx < flashCount * 2 then
                        if flashIdx % 2 == 0 then
                            nameColor = Color(200, 40, 40, 255)
                        end
                    end
                end

                render.SetScissorRect(drawX, drawY, drawX + drawW, drawY + drawH, true)
                if tw <= maxW then
                    WS.DrawText( showName, "WS_CourierNew", drawX + drawW/2, nameY, nameColor, TEXT_ALIGN_CENTER)
                else
                    WS.DrawText( showName, "WS_CourierNew", drawX + pad + WS.NameScroll[wep], nameY, nameColor, TEXT_ALIGN_LEFT)
                end

                render.SetScissorRect(0, 0, 0, 0, false)
            else
                WS.DrawText( "-", "WS_CourierNew", position + sizeX/2, nameY, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
            end
            if SelectedWep == wep then
                local outline = (hg.theme and hg.theme.c.outline) or Color(55, 55, 55, 160) -- colors.presetBorder
                surface.SetDrawColor(outline.r, outline.g, outline.b, math.floor(WS.Transparent*40))
                local step = 12
                local off = (CurTime() * 6) % step
                render.SetScissorRect(drawX, drawY, drawX + drawW, drawY + drawH, true)
                for gx = drawX - off, drawX + drawW, step do surface.DrawLine(gx, drawY, gx, drawY + drawH) end
                for gy = drawY - off, drawY + drawH, step do surface.DrawLine(drawX, gy, drawX + drawW, gy) end
                render.SetScissorRect(0, 0, 0, 0, false)
            end
            Ammout = Ammout + 1

            if SelectedWep == wep and wep.DrawWeaponSelection then
                WS.HookWeapon(wep)
                wep:DrawWeaponSelection(position + 5, (scrH * 0.025) * (Ammout) + (scrH * 0.055) + lastPos, sizeX - 10, sizeH, WS.Transparent*255)
            end
        end
        SuperAmmout = SuperAmmout + 1
    end
end

-- Changer
local tAcceptKeys = {
    ["slot1"] = 1,
    ["slot2"] = 2,
    ["slot3"] = 3,
    ["slot4"] = 4,
    ["slot5"] = 5,
    ["slot6"] = 6,
}

local function GetUpper(Weapons)
    if #LocalPlayer():GetWeapons() < 1 then return end
    WS.SelectedSlot = WS.SelectedSlot < 0 and #Weapons or WS.SelectedSlot - 1
    WS.SelectedSlotPos = Weapons[WS.SelectedSlot] and #Weapons[WS.SelectedSlot] or 0

    if Weapons[WS.SelectedSlot] == nil or Weapons[WS.SelectedSlot][WS.SelectedSlotPos] == nil then
        GetUpper(Weapons)
    end

end

local function GetDown(Weapons)
    if #LocalPlayer():GetWeapons() < 1 then return end
    WS.SelectedSlot = WS.SelectedSlot > #Weapons and 0 or WS.SelectedSlot + 1
    WS.SelectedSlotPos = 0

    if Weapons[WS.SelectedSlot] == nil or Weapons[WS.SelectedSlot][WS.SelectedSlotPos] == nil then
        GetDown(Weapons)
    end

end

local LastSelected = 0

local function get_active_tool(ply, tool)
    local activeWep = ply:GetActiveWeapon()
    if not IsValid(activeWep) or activeWep:GetClass() ~= "gmod_tool" or activeWep.Mode ~= tool then return end
    return activeWep:GetToolObject(tool)
end

local function canUseSelector(ply)
    local wep = ply:GetActiveWeapon()
    local tool = get_active_tool(ply, "submaterial")
    if tool and IsValid(ply:GetEyeTraceNoCursor().Entity) then
        return true
    end

    return IsAiming(ply) or (IsValid(wep) and wep:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK)) or (lply.organism and lply.organism.pain and lply.organism.pain > 60)
 end

function WS.ChangeSelectionWep( ply, key )
    if not IsValid( ply ) or not ply:Alive() then return end
    if ply.organism and ply.organism.otrub then return end
    if canUseSelector( ply ) then return end
    local iPos = tAcceptKeys[ key ]
    if iPos or key == "invnext" or key == "invprev" or key == "lastinv" then

        local Weapons = WS.GetWeaponTable( ply )

        WS.Show = CurTime() + 4
        surface.PlaySound("arc9_eft_shared/weapon_generic_rifle_spin"..math.random(10)..".ogg")
        if iPos then
            iPos = iPos - 1
            if LastSelected ~= iPos then 
                WS.SelectedSlotPos = -1
            end
            WS.SelectedSlotPos = (Weapons[iPos] and LastSelected == iPos and WS.SelectedSlotPos + 1 > #Weapons[iPos] and 0 or math.min( WS.SelectedSlotPos + 1, #Weapons[iPos] )) or 0
            WS.SelectedSlot = iPos
            LastSelected = iPos
            WS.TypeState = {}
            WS.BoxAnim = {}
            WS.FlashState = { start = CurTime(), count = 0 }
        elseif key == "invprev" then
            WS.SelectedSlotPos = WS.SelectedSlotPos - 1
            if Weapons[WS.SelectedSlot] and WS.SelectedSlotPos < 0  then
                GetUpper(Weapons)
            end
            WS.TypeState = {}
            WS.BoxAnim = {}
            WS.FlashState = { start = CurTime(), count = 0 }
        elseif key == "invnext" then
            WS.SelectedSlotPos = WS.SelectedSlotPos + 1
            if Weapons[WS.SelectedSlot] and WS.SelectedSlotPos > #Weapons[WS.SelectedSlot] then
                GetDown(Weapons)
            end
            WS.TypeState = {}
            WS.BoxAnim = {}
            WS.FlashState = { start = CurTime(), count = 0 }
        elseif key == "lastinv" and IsValid(WS.LastInv) then
            WS.Show = 0
            WS.LastInv = WS.LastInv or "weapon_hands_sh"
            local oldwep = ply:GetActiveWeapon()
            input.SelectWeapon( WS.LastInv )
            WS.LastInv = oldwep
        end

    end
end

function WS.SetActuallyWeapon( ply, cmd )
    if not IsValid( ply ) or not ply:Alive() then return end
    if (cmd:KeyDown( IN_ATTACK ) or cmd:KeyDown( IN_ATTACK2 )) and WS.Show > CurTime() then

        if WS.Selected and WS.Selected > CurTime() then 
            cmd:RemoveKey(IN_ATTACK) 
            cmd:RemoveKey(IN_ATTACK2) 
        else
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2) 
            
            if IsValid(WS.GetSelectedWeapon()) then
                WS.LastInv = WS.LastInv ~= ply:GetActiveWeapon() and WS.LastInv or ply:GetActiveWeapon()
                input.SelectWeapon( WS.GetSelectedWeapon() )
            end
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2) 

            WS.LastSelectedSlot = WS.SelectedSlot
            WS.LastSelectedSlotPos = WS.SelectedSlotPos
            WS.Selected = CurTime() + 0.2
            WS.Show = CurTime() + 0.2
            surface.PlaySound("arc9_eft_shared/weapon_generic_spin"..math.random(1,10)..".ogg")
        end
    end
end

hook.Add( "PlayerBindPress", "WeaponSelector_PlayerBindPress", WS.ChangeSelectionWep )

hook.Add( "HUDPaint", "WeaponSelector_Draw", function()
    WS.WeaponSelectorDraw( LocalPlayer() )
end)

hook.Add( "StartCommand", "WeaponSelector_StartCommand", WS.SetActuallyWeapon )

local tHideElements = {
    ["CHudWeaponSelection"] = true
}

hook.Add("HUDShouldDraw", "WeaponSelector_HUDShouldDraw", function(sElementName)
    if tHideElements[sElementName] then return false end
end)

-- Я ТАК ЗАДОЛБАЛСЯ ПРОСТО УБЕЙТЕ МЕНЯ ХАХАХАХАХАХАХАХАХАХААХАХАХАХАХАХА
-- ПОЛЧАСА Я ПЫТАЛСЯ СДЕЛАТЬ НОРМЛАЬНОЕ ПЕРЕКЛЮЧЕНИЕ ГОВНА!!!
-- ЗАТО ПОЛУЧИЛОСЬ!!!!
-- УЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ
--[[
    /\_/\
    |_ _|
    |   |__
   /_|_____\ -- IT'S SO OVER
--]]
WS.TypeState = WS.TypeState or {}
WS.FlashState = WS.FlashState or {} -- {wep = {start=CurTime(), count=N}}
function WS.Scramble(target)
    target = tostring(target or "")
    local ply = LocalPlayer()
    if ply.organism and ply.organism.brain and ply.organism.brain > 0.05 then
        local len = #target
        local scrambled = ""
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
        for i = 1, len do
            if string.sub(target, i, i) == " " then
                scrambled = scrambled .. " "
            else
                local r = math.random(1, #chars)
                scrambled = scrambled .. string.sub(chars, r, r)
            end
        end
        return scrambled
    end
    return target
end

function WS.Typewriter(target, key, rate)
    target = WS.Scramble(target)

    local s = WS.TypeState[key] or {t=0,g=0,n=0}
    local prev = math.floor(s.t or 0)
    s.t = math.min(#target, (s.t or 0) + FrameTime() * (rate or 20))
    s.g = (s.g + 1) % 2
    WS.TypeState[key] = s
    local n = math.floor(s.t)
    if n > prev then
        local lp = LocalPlayer()
        if IsValid(lp) then lp:EmitSound("speech.mp3", 60, 100, 0.08) end
    end
    s.n = n
    local prefix = string.sub(target, 1, n)
    local glitch = (s.g == 0) and "0" or "1"
    if n < #target then return prefix .. glitch end
    return target
end
