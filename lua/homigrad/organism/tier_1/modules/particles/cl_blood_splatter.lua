-- Blood Splatter System for Pain/Injury Effects
-- Creates blood splatter decals on screen when player takes damage

local CurTime = CurTime
local math_random = math.random
local math_Rand = math.Rand
local table_insert = table.insert
local table_remove = table.remove
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectRotated = surface.DrawTexturedRectRotated
local render_SetMaterial = render.SetMaterial
local render_DrawScreenQuad = render.DrawScreenQuad

-- Convars for customization
local hg_blood_splatter_enable = ConVarExists("hg_blood_splatter_enable") and GetConVar("hg_blood_splatter_enable") or CreateClientConVar("hg_blood_splatter_enable", "1", true, false, "Enable blood splatter effects", 0, 1)
local hg_blood_splatter_intensity = ConVarExists("hg_blood_splatter_intensity") and GetConVar("hg_blood_splatter_intensity") or CreateClientConVar("hg_blood_splatter_intensity", "1.0", true, false, "Blood splatter intensity multiplier", 0.1, 3.0)
local hg_blood_splatter_duration = ConVarExists("hg_blood_splatter_duration") and GetConVar("hg_blood_splatter_duration") or CreateClientConVar("hg_blood_splatter_duration", "3.0", true, false, "Blood splatter duration in seconds", 0.5, 10.0)

-- Blood splatter data structure
hg.bloodSplatters = hg.bloodSplatters or {}

-- Create custom blood materials using zSH textures
local function CreateBloodMaterial(texturePath)
    local mat = CreateMaterial("hg_blood_splatter_" .. util.CRC(texturePath), "UnlitGeneric", {
        ["$basetexture"] = texturePath,
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1,
        ["$ignorez"] = 1
    })
    return mat
end

-- Materials for blood splatter effects (using organism blood textures)
local bloodMaterials = {
    CreateBloodMaterial("zbattle/blood"),
    CreateBloodMaterial("decals/blood1"),
    CreateBloodMaterial("decals/blood2"),
    CreateBloodMaterial("decals/blood3"),
    CreateBloodMaterial("decals/blood4"),
    CreateBloodMaterial("decals/blood5")
}

-- Arterial blood materials for heavy bleeding
local arterialBloodMaterials = {
    CreateBloodMaterial("zbattle/blood"),
    CreateBloodMaterial("decals/blood6"),
    CreateBloodMaterial("decals/blood7"),
    CreateBloodMaterial("decals/blood8")
}

-- Create a custom blood splatter material
local bloodSplatterMat = Material("effects/blood_core")

-- Add blood splatter to screen
local function AddBloodSplatter(intensity, damageType, isArterial)
    if not hg_blood_splatter_enable:GetBool() then return end
    
    local lply = LocalPlayer()
    if not IsValid(lply) then return end
    
    -- Check if player is in otrub (unconscious)
    local org = lply.organism
    if org and org.otrub then return end
    
    -- Adjust intensity based on convar
    intensity = intensity * hg_blood_splatter_intensity:GetFloat()
    
    -- Choose appropriate material based on bleeding type
    local materialList = isArterial and arterialBloodMaterials or bloodMaterials
    
    -- Special handling for small bleedings to make them more visible
    local isSmallBleeding = intensity < 0.3
    local sizeMultiplier = isSmallBleeding and 3.0 or (isArterial and 2.0 or 1.5)
    local alphaMultiplier = isSmallBleeding and 1.2 or 1.0
    
    -- Create blood splatter entry
    local splatter = {
        startTime = CurTime(),
        duration = hg_blood_splatter_duration:GetFloat() * math_Rand(0.8, 1.2),
        intensity = intensity,
        material = table.Random(materialList),
        x = math_Rand(0.1, 0.9), -- Position on screen (0-1)
        y = math_Rand(0.1, 0.9),
        size = math_Rand(200, 500) * intensity * sizeMultiplier, -- Larger for small bleedings
        rotation = math_Rand(0, 360),
        alpha = 255 * alphaMultiplier, -- More opaque for small bleedings
        fadeSpeed = math_Rand(0.4, 0.8), -- Slower fade for more visibility
        damageType = damageType or DMG_GENERIC,
        isArterial = isArterial or false,
        isSmallBleeding = isSmallBleeding,
        drips = {} -- Blood drip effects
    }
    
    -- Add blood drips for more realistic effect
    local dripCount = math_random(2, 5) -- More drips
    for i = 1, dripCount do
        table_insert(splatter.drips, {
            x = splatter.x + math_Rand(-0.15, 0.15), -- Wider spread
            y = splatter.y + math_Rand(0.05, 0.25),
            length = math_Rand(40, 120) * intensity, -- Longer drips
            width = math_Rand(4, 10) * intensity, -- Thicker drips
            speed = math_Rand(80, 200), -- Faster movement
            delay = math_Rand(0, 0.3)
        })
    end
    
    table_insert(hg.bloodSplatters, splatter)
    
    -- Limit maximum splatters to prevent performance issues
    if #hg.bloodSplatters > 20 then
        table_remove(hg.bloodSplatters, 1)
    end
end

-- Network receiver for blood splatter events
net.Receive("hg_blood_splatter", function()
    local intensity = net.ReadFloat()
    local damageType = net.ReadUInt(8)
    local isArterial = net.ReadBool()
    print("[zSH] Blood splatter received: intensity=" .. intensity .. ", type=" .. damageType .. ", arterial=" .. tostring(isArterial))
    AddBloodSplatter(intensity, damageType, isArterial)
end)

-- Render blood splatters on screen
hook.Add("HUDPaint", "hg_blood_splatter_render", function()
    if not hg_blood_splatter_enable:GetBool() then return end
    
    local lply = LocalPlayer()
    if not IsValid(lply) then return end
    
    -- Check if player is in otrub (unconscious)
    local org = lply.organism
    if org and org.otrub then return end
    
    local curTime = CurTime()
    local screenW = ScrW()
    local screenH = ScrH()
    
    -- Disable depth testing and set up screen overlay rendering
    cam.Start2D()
    
    -- Render each active blood splatter
    for i = #hg.bloodSplatters, 1, -1 do
        local splatter = hg.bloodSplatters[i]
        
        -- Remove expired splatters
        if curTime > splatter.startTime + splatter.duration then
            table_remove(hg.bloodSplatters, i)
            continue
        end
        
        -- Calculate fade alpha
        local elapsed = curTime - splatter.startTime
        local lifeRatio = elapsed / splatter.duration
        local fadeAlpha = 255 * (1 - lifeRatio) * splatter.fadeSpeed
        
        -- Main blood splatter with screen overlay effect
        local alpha = math.min(fadeAlpha, splatter.alpha)
        local x = splatter.x * screenW
        local y = splatter.y * screenH
        local size = splatter.size * (1 + lifeRatio * 0.3) -- More growth over time
        
        -- Special rendering for small bleedings
        if splatter.isSmallBleeding then
            -- Extra bright color for small bleedings
            surface_SetDrawColor(255, 120, 120, alpha * 0.95) -- Very bright
            surface_SetMaterial(splatter.material)
            surface_DrawTexturedRectRotated(x, y, size, size, splatter.rotation)
            
            -- Add extra bright glow for small bleedings
            surface_SetDrawColor(255, 200, 200, alpha * 0.6) -- Bright glow
            surface_DrawTexturedRectRotated(x, y, size * 1.4, size * 1.4, splatter.rotation)
            
            -- Add multiple bright overlays for small bleedings
            for i = 1, 4 do -- Extra layer for small bleedings
                local overlaySize = size * (1.2 - i * 0.15)
                local overlayAlpha = alpha * (0.5 - i * 0.08)
                local offsetX = x + math_Rand(-25, 25) * i
                local offsetY = y + math_Rand(-25, 25) * i
                local offsetRotation = splatter.rotation + math_Rand(-70, 70) * i
                
                surface_SetDrawColor(255 - i * 20, 100 - i * 10, 100 - i * 10, overlayAlpha)
                surface_SetMaterial(splatter.material)
                surface_DrawTexturedRectRotated(offsetX, offsetY, overlaySize, overlaySize, offsetRotation)
            end
        else
            -- Normal rendering for medium/large bleedings
            surface_SetDrawColor(255, 80, 80, alpha * 0.9) -- Brighter red color
            surface_SetMaterial(splatter.material)
            surface_DrawTexturedRectRotated(x, y, size, size, splatter.rotation)
            
            -- Add multiple overlay layers for more dramatic effect
            for i = 1, 3 do
                local overlaySize = size * (1.0 - i * 0.2)
                local overlayAlpha = alpha * (0.4 - i * 0.1)
                local offsetX = x + math_Rand(-20, 20) * i
                local offsetY = y + math_Rand(-20, 20) * i
                local offsetRotation = splatter.rotation + math_Rand(-60, 60) * i
                
                surface_SetDrawColor(220 - i * 30, 20 + i * 10, 20 + i * 10, overlayAlpha)
                surface_SetMaterial(splatter.material)
                surface_DrawTexturedRectRotated(offsetX, offsetY, overlaySize, overlaySize, offsetRotation)
            end
        end
        
        -- Add bright red glow effect for arterial bleeding
        if splatter.isArterial then
            local glowAlpha = splatter.isSmallBleeding and 0.5 or 0.4
            local glowSize = splatter.isSmallBleeding and 1.5 or 1.3
            surface_SetDrawColor(255, 150, 150, alpha * glowAlpha)
            surface_DrawTexturedRectRotated(x, y, size * glowSize, size * glowSize, splatter.rotation)
        end
        
        -- Render blood drips with enhanced visibility
        for _, drip in ipairs(splatter.drips) do
            if curTime > splatter.startTime + drip.delay then
                local dripY = drip.y * screenH + (curTime - splatter.startTime - drip.delay) * drip.speed
                local dripAlpha = alpha * 0.8 -- More visible drips
                
                -- Enhanced rendering for small bleedings
                if splatter.isSmallBleeding then
                    -- Extra bright and thick drips for small bleedings
                    surface_SetDrawColor(255, 150, 150, dripAlpha * 0.95) -- Very bright
                    surface_SetMaterial(bloodSplatterMat)
                    surface_DrawTexturedRectRotated(
                        drip.x * screenW, 
                        dripY, 
                        drip.width * 2.0, -- Much thicker
                        drip.length * 1.2, -- Longer
                        90
                    )
                    
                    -- Add extra bright glow for small bleeding drips
                    surface_SetDrawColor(255, 220, 220, dripAlpha * 0.5) -- Very bright glow
                    surface_DrawTexturedRectRotated(
                        drip.x * screenW, 
                        dripY, 
                        drip.width * 3.5, 
                        drip.length * 0.9, 
                        90
                    )
                else
                    -- Normal drip rendering for medium/large bleedings
                    surface_SetDrawColor(255, 100, 100, dripAlpha)
                    surface_SetMaterial(bloodSplatterMat)
                    surface_DrawTexturedRectRotated(
                        drip.x * screenW, 
                        dripY, 
                        drip.width * 1.5, -- Thicker
                        drip.length, 
                        90
                    )
                    
                    -- Add drip glow effect
                    surface_SetDrawColor(255, 200, 200, dripAlpha * 0.3)
                    surface_DrawTexturedRectRotated(
                        drip.x * screenW, 
                        dripY, 
                        drip.width * 2.5, 
                        drip.length * 0.8, 
                        90
                    )
                end
            end
        end
    end
    
    cam.End2D()
end)

-- Debug function to test blood splatter
concommand.Add("hg_test_blood_splatter", function()
    AddBloodSplatter(0.8, DMG_GENERIC)
    print("[zSH] Blood splatter test triggered")
end)

-- Movement-based blood loss indicator
hook.Add("HUDPaint", "hg_movement_bleed_indicator", function()
    local lply = LocalPlayer()
    if not IsValid(lply) or not lply:Alive() then return end
    
    local org = lply.organism
    if not org or not org.bleed or org.bleed <= 0 then return end
    
    -- Check if movement multiplier is active
    local multiplier = org.movementBleedMultiplier or 1.0
    if multiplier > 1.1 then
        local screenW = ScrW()
        local screenH = ScrH()
        
        -- Calculate warning intensity based on multiplier
        local warningLevel = (multiplier - 1.0) / 2.0 -- Normalize to 0-1
        local alpha = math.min(warningLevel * 255, 200)
        
        -- Draw warning indicator
        local text = "Кровотечение усилено движением!"
        local font = "TargetID"
        
        -- Calculate text position
        surface.SetFont(font)
        local textW, textH = surface.GetTextSize(text)
        local x = screenW - textW - 20
        local y = screenH * 0.3 -- Upper part of screen
        
        -- Draw background
        draw.RoundedBox(4, x - 5, y - 2, textW + 10, textH + 4, Color(150, 0, 0, alpha * 0.8))
        
        -- Draw text with pulsing effect
        local pulse = math.sin(CurTime() * 3) * 0.3 + 0.7
        draw.DrawText(text, font, x, y, Color(255, 100, 100, alpha * pulse), TEXT_ALIGN_LEFT)
        
        -- Draw multiplier indicator
        local multiplierText = string.format("x%.1f", multiplier)
        local mulW, mulH = surface.GetTextSize(multiplierText)
        draw.DrawText(multiplierText, font, x + textW - mulW, y + textH + 5, Color(255, 150, 150, alpha * 0.8), TEXT_ALIGN_LEFT)
    end
end)

-- Blood loss monitoring system
hook.Add("Think", "hg_blood_splatter_blood_loss_check", function()
    if not hg_blood_splatter_enable:GetBool() then return end
    
    local lply = LocalPlayer()
    if not IsValid(lply) or not lply:Alive() then return end
    
    local org = lply.organism
    if not org then return end
    
    -- Check if player is in otrub (unconscious)
    if org.otrub then return end
    
    -- Monitor blood loss rate
    local currentBleed = org.bleed or 0
    local lastBleed = lply.lastBleed or 0
    local currentBlood = org.blood or 5000
    local lastBlood = lply.lastBlood or 5000
    
    -- Check for significant blood loss
    if currentBleed > 0.01 then -- Active bleeding (lower threshold)
        local intensity = math.min(currentBleed / 1.5, 1.0) -- Normalize bleed rate to 0-1 (more sensitive)
        
        -- Check if this is arterial bleeding (high rate)
        local isArterial = currentBleed > 0.5
        
        -- Only trigger splatters periodically to avoid spam
        if not lply.nextBloodSplatter or CurTime() >= lply.nextBloodSplatter then
            if intensity > 0.05 then -- Lower threshold for small bleedings
                AddBloodSplatter(intensity, DMG_GENERIC, isArterial)
                
                -- Set next splatter time based on bleed rate
                local delay = math.Clamp(1.0 / currentBleed, 0.2, 2.0)
                lply.nextBloodSplatter = CurTime() + delay
            end
        end
    end
    
    -- Also check for sudden blood loss from external bleeding only (skip internal bleeding)
    local bloodLoss = lastBlood - currentBlood
    if bloodLoss > 10 and currentBleed > 0.01 then -- Only trigger if external bleeding is active
        local intensity = math.min(bloodLoss / 100, 1.0) -- More sensitive
        if intensity > 0.05 then -- Lower threshold
            AddBloodSplatter(intensity, DMG_GENERIC, false)
            
            -- Add extra splatters for massive blood loss
            if bloodLoss > 200 then
                timer.Simple(math_Rand(0.1, 0.3), function()
                    AddBloodSplatter(intensity * 0.7, DMG_GENERIC, false)
                end)
            end
        end
    end
    
    lply.lastBleed = currentBleed
    lply.lastBlood = currentBlood
end)

-- Clear blood splatters on respawn
hook.Add("PlayerSpawn", "hg_blood_splatter_clear", function(ply)
    if ply == LocalPlayer() then
        hg.bloodSplatters = {}
    end
end)

-- Cleanup on map change
hook.Add("PostCleanupMap", "hg_blood_splatter_cleanup", function()
    hg.bloodSplatters = {}
end)

-- Export function for manual splatter creation
hg.AddBloodSplatter = AddBloodSplatter

print("[zSH] Blood Splatter System Loaded")
