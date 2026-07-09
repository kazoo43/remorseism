if CLIENT then return end

hg = hg or {}
hg.Appearance = hg.Appearance or {}

local APmodule = hg.Appearance
APmodule.Sliders = APmodule.Sliders or {}

if APmodule.Sliders.__ServerRuntimeLoaded then return end
APmodule.Sliders.__ServerRuntimeLoaded = true

local HULL_RADIUS = 10
local HULL_MAXS = Vector(HULL_RADIUS, HULL_RADIUS, 72)
local HULL_MINS = -Vector(HULL_RADIUS, HULL_RADIUS, 0)
local HULL_DUCK_MAXS = Vector(HULL_RADIUS, HULL_RADIUS, 36)
local HULL_DUCK_MINS = -Vector(HULL_RADIUS, HULL_RADIUS, 0)
local VIEW_OFFSET = Vector(0, 0, 64)
local VIEW_OFFSET_DUCKED = Vector(0, 0, 38)
local HEAD_BONE_NAME = "ValveBiped.Bip01_Head1"
local VEC_FULL = Vector(1, 1, 1)

function APmodule.ResetPlayerScale(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local boneCount = ply:GetBoneCount() or 0

    ply:SetModelScale(1, 0)

    for boneID = 0, boneCount - 1 do
        ply:ManipulateBoneScale(boneID, VEC_FULL)
    end

    ply:SetHull(HULL_MINS, HULL_MAXS)
    ply:SetHullDuck(HULL_DUCK_MINS, HULL_DUCK_MAXS)
    ply:SetViewOffset(VIEW_OFFSET)
    ply:SetViewOffsetDucked(VIEW_OFFSET_DUCKED)

    ply:SetNWFloat("hg_appearance_height_scale", 1)
    ply:SetNWFloat("hg_appearance_body_scale", 1)
    ply:SetNWBool("hg_appearance_height_head", false)
    ply:SetNWBool("hg_appearance_body_head", false)
    ply._hgAppearanceScaleCache = nil
end

function APmodule.BuildTemporaryScaleAppearance(ply, height, bodySize)
    local baseAppearance = APmodule.NormalizeAppearanceTable((IsValid(ply) and (ply.CurAppearance or ply.CachedAppearance)) or APmodule.GetRandomAppearance())
    baseAppearance.AHeight = APmodule.NormalizeHeight(height)
    baseAppearance.ABodySize = APmodule.NormalizeHeight(bodySize)
    baseAppearance.AHeightResizeHead = false
    baseAppearance.ABodySizeResizeHead = false
    return baseAppearance
end

function APmodule.ApplyPlayerScale(ply, tbl)
    if not IsValid(ply) or not ply:IsPlayer() or IsValid(ply.FakeRagdoll) then return end
    if not APmodule.Sliders.IsEnabled() then
        APmodule.ResetPlayerScale(ply)
        return
    end

    tbl = APmodule.NormalizeAppearanceTable(tbl)

    local heightScale = APmodule.GetHeightScale(tbl.AHeight)
    local bodyScale = APmodule.GetHeightScale(tbl.ABodySize)
    local bodyScaleVec = Vector(bodyScale, bodyScale, bodyScale)
    local headScaleVec = APmodule.GetHeadBoneScale(tbl)
    local boneCount = ply:GetBoneCount() or 0

    ply:SetModelScale(heightScale, 0)

    for boneID = 0, boneCount - 1 do
        local boneName = ply:GetBoneName(boneID)
        ply:ManipulateBoneScale(boneID, boneName == HEAD_BONE_NAME and headScaleVec or bodyScaleVec)
    end

    ply:SetHull(HULL_MINS * heightScale, HULL_MAXS * heightScale)
    ply:SetHullDuck(HULL_DUCK_MINS * heightScale, HULL_DUCK_MAXS * heightScale)
    ply:SetViewOffset(VIEW_OFFSET * heightScale)
    ply:SetViewOffsetDucked(VIEW_OFFSET_DUCKED * heightScale)

    ply:SetNWFloat("hg_appearance_height_scale", heightScale)
    ply:SetNWFloat("hg_appearance_body_scale", bodyScale)
    ply:SetNWBool("hg_appearance_height_head", tbl.AHeightResizeHead)
    ply:SetNWBool("hg_appearance_body_head", tbl.ABodySizeResizeHead)
    ply._hgAppearanceScaleCache = APmodule.BuildScaleCacheKey(ply:GetModel(), tbl)
end

function APmodule.ScheduleScaleReapply(ply, tbl, delay)
    timer.Simple(delay or 0, function()
        if not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end
        if not APmodule.Sliders.IsEnabled() then
            APmodule.ResetPlayerScale(ply)
            return
        end

        APmodule.ApplyPlayerScale(ply, tbl or ply._hgAppearanceTemporaryScale or ply.CurAppearance or ply.CachedAppearance or APmodule.GetRandomAppearance())
    end)
end

function APmodule.ApplyTemporaryPlayerScale(ply, height, bodySize)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply._hgAppearanceTemporaryScale = APmodule.BuildTemporaryScaleAppearance(ply, height, bodySize)

    if ply:Alive() and not IsValid(ply.FakeRagdoll) then
        APmodule.ApplyPlayerScale(ply, ply._hgAppearanceTemporaryScale)
    end
end

function APmodule.ClearTemporaryPlayerScale(ply)
    if not IsValid(ply) then return end
    ply._hgAppearanceTemporaryScale = nil
end

local previousForceApplyAppearance = APmodule.ForceApplyAppearance
if isfunction(previousForceApplyAppearance) and not APmodule.Sliders.__ForceApplyWrapped then
    APmodule.Sliders.__ForceApplyWrapped = true

    function APmodule.ForceApplyAppearance(ply, tbl, noModelChange, ...)
        APmodule.ClearTemporaryPlayerScale(ply)
        local results = {previousForceApplyAppearance(ply, tbl, noModelChange, ...)}
        if APmodule.Sliders.IsEnabled() then
            APmodule.ScheduleScaleReapply(ply, tbl, 0)
        else
            APmodule.ResetPlayerScale(ply)
        end
        return unpack(results)
    end
end

hook.Add("Player Activate", "HG.Appearance.SlidersActivate", function(ply)
    APmodule.ScheduleScaleReapply(ply, nil, 0)
end)

hook.Add("Player Spawn", "HG.Appearance.SlidersSpawn", function(ply)
    APmodule.ScheduleScaleReapply(ply, nil, 0)
end)

hook.Add("Fake Up", "HG.Appearance.SlidersFakeUp", function(ply)
    APmodule.ScheduleScaleReapply(ply, nil, 0)
end)

hook.Add("Player Think", "HG.Appearance.SlidersScaleSync", function(ply)
    if not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end
    if not APmodule.Sliders.IsEnabled() then
        if ply._hgAppearanceScaleCache ~= nil
            or ply:GetNWFloat("hg_appearance_height_scale", 1) ~= 1
            or ply:GetNWFloat("hg_appearance_body_scale", 1) ~= 1 then
            APmodule.ResetPlayerScale(ply)
        end
        return
    end

    local appearance = ply._hgAppearanceTemporaryScale or ply.CurAppearance
    if not appearance then return end

    local normalized = APmodule.NormalizeAppearanceTable(appearance)
    local wantedCache = APmodule.BuildScaleCacheKey(ply:GetModel(), normalized)
    if ply._hgAppearanceScaleCache ~= wantedCache then
        APmodule.ApplyPlayerScale(ply, normalized)
    end
end)

local function RegisterToggleCallback()
    if APmodule.Sliders.__RuntimeToggleCallbackRegistered then return end

    local convarName = APmodule.Sliders.EnableConVarName
    if not isstring(convarName) or convarName == "" then return end
    if not ConVarExists(convarName) then return end

    APmodule.Sliders.__RuntimeToggleCallbackRegistered = true

    cvars.AddChangeCallback(convarName, function(_, _, newValue)
        local enabled = tobool(tonumber(newValue) or newValue)

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end

            if enabled then
                APmodule.ScheduleScaleReapply(ply, nil, 0)
            else
                APmodule.ResetPlayerScale(ply)
            end
        end
    end, "HG.Appearance.SlidersRuntimeToggle")
end

RegisterToggleCallback()
timer.Simple(0, RegisterToggleCallback)
