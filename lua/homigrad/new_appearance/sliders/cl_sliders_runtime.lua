if SERVER then return end

hg = hg or {}
hg.Appearance = hg.Appearance or {}

local APmodule = hg.Appearance
APmodule.Sliders = APmodule.Sliders or {}

if APmodule.Sliders.__ClientRuntimeLoaded then return end
APmodule.Sliders.__ClientRuntimeLoaded = true

local HULL_RADIUS = 10
local HULL_MAXS = Vector(HULL_RADIUS, HULL_RADIUS, 72)
local HULL_MINS = -Vector(HULL_RADIUS, HULL_RADIUS, 0)
local HULL_DUCK_MAXS = Vector(HULL_RADIUS, HULL_RADIUS, 36)
local HULL_DUCK_MINS = -Vector(HULL_RADIUS, HULL_RADIUS, 0)
local VIEW_OFFSET = Vector(0, 0, 64)
local VIEW_OFFSET_DUCKED = Vector(0, 0, 38)
local HEAD_BONE_NAME = "ValveBiped.Bip01_Head1"
local VEC_FULL = Vector(1, 1, 1)

function APmodule.ResetPreviewScale(ent)
    if not IsValid(ent) then return end

    local boneCount = ent:GetBoneCount() or 0
    ent._hgAppearancePreviewScale = nil
    ent:SetModelScale(1, 0)

    for boneID = 0, boneCount - 1 do
        ent:ManipulateBoneScale(boneID, VEC_FULL)
    end
end

function APmodule.ApplyPreviewScale(ent, tbl)
    if not IsValid(ent) then return end
    if not APmodule.Sliders.IsEnabled() then
        APmodule.ResetPreviewScale(ent)
        return
    end

    tbl = APmodule.NormalizeAppearanceTable(tbl)

    local heightScale = APmodule.GetHeightScale(tbl.AHeight)
    local bodyScale = APmodule.GetHeightScale(tbl.ABodySize)
    local bodyScaleVec = Vector(bodyScale, bodyScale, bodyScale)
    local headScaleVec = APmodule.GetHeadBoneScale(tbl)
    local scaleKey = APmodule.BuildScaleCacheKey(ent:GetModel(), tbl)

    if ent._hgAppearancePreviewScale == scaleKey then return end
    ent._hgAppearancePreviewScale = scaleKey

    ent:SetModelScale(heightScale, 0)

    for boneID = 0, (ent:GetBoneCount() or 0) - 1 do
        local boneName = ent:GetBoneName(boneID)
        ent:ManipulateBoneScale(boneID, boneName == HEAD_BONE_NAME and headScaleVec or bodyScaleVec)
    end
end

function APmodule.ApplyLocalPlayerScale(ply)
    if not IsValid(ply) then return end

    if IsValid(ply.FakeRagdoll) then
        ply._hgAppearanceLocalScale = nil
        return
    end

    if not APmodule.Sliders.IsEnabled() then
        APmodule.ResetPreviewScale(ply)
        ply._hgAppearanceLocalScale = nil

        if ply == LocalPlayer() then
            ply:SetHull(HULL_MINS, HULL_MAXS)
            ply:SetHullDuck(HULL_DUCK_MINS, HULL_DUCK_MAXS)
            ply:SetViewOffset(VIEW_OFFSET)
            ply:SetViewOffsetDucked(VIEW_OFFSET_DUCKED)
        end
        return
    end

    local heightScale = math.Clamp(ply:GetNWFloat("hg_appearance_height_scale", 1), APmodule.HeightMin / 100, APmodule.HeightMax / 100)
    local bodyScale = math.Clamp(ply:GetNWFloat("hg_appearance_body_scale", 1), APmodule.HeightMin / 100, APmodule.HeightMax / 100)
    local heightHead = ply:GetNWBool("hg_appearance_height_head", false)
    local bodyHead = ply:GetNWBool("hg_appearance_body_head", false)
    local cacheKey = table.concat({
        tostring(ply:GetModel()),
        tostring(heightScale),
        tostring(bodyScale),
        tostring(heightHead),
        tostring(bodyHead)
    }, "|")

    if ply._hgAppearanceLocalScale == cacheKey then return end
    ply._hgAppearanceLocalScale = cacheKey

    local tbl = {
        AHeight = math.Round(heightScale * 100),
        ABodySize = math.Round(bodyScale * 100),
        AHeightResizeHead = heightHead,
        ABodySizeResizeHead = bodyHead
    }

    APmodule.ApplyPreviewScale(ply, tbl)

    if ply == LocalPlayer() then
        ply:SetHull(HULL_MINS * heightScale, HULL_MAXS * heightScale)
        ply:SetHullDuck(HULL_DUCK_MINS * heightScale, HULL_DUCK_MAXS * heightScale)
        ply:SetViewOffset(VIEW_OFFSET * heightScale)
        ply:SetViewOffsetDucked(VIEW_OFFSET_DUCKED * heightScale)
    end
end

timer.Create("HG.Appearance.SlidersLocalScaleSync", 0.25, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        APmodule.ApplyLocalPlayerScale(ply)
    end
end)

local function RegisterToggleCallback()
    if APmodule.Sliders.__ClientToggleCallbackRegistered then return end

    local convarName = APmodule.Sliders.EnableConVarName
    if not isstring(convarName) or convarName == "" then return end
    if not ConVarExists(convarName) then return end

    APmodule.Sliders.__ClientToggleCallbackRegistered = true

    cvars.AddChangeCallback(convarName, function(_, _, newValue)
        local enabled = tobool(tonumber(newValue) or newValue)

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end

            if enabled then
                APmodule.ApplyLocalPlayerScale(ply)
            else
                APmodule.ResetPreviewScale(ply)
                ply._hgAppearanceLocalScale = nil

                if ply == LocalPlayer() then
                    ply:SetHull(HULL_MINS, HULL_MAXS)
                    ply:SetHullDuck(HULL_DUCK_MINS, HULL_DUCK_MAXS)
                    ply:SetViewOffset(VIEW_OFFSET)
                    ply:SetViewOffsetDucked(VIEW_OFFSET_DUCKED)
                end
            end
        end
    end, "HG.Appearance.SlidersClientToggle")
end

RegisterToggleCallback()
timer.Simple(0, RegisterToggleCallback)
