hg = hg or {}
hg.Appearance = hg.Appearance or {}

local APmodule = hg.Appearance
APmodule.Sliders = APmodule.Sliders or {}

if APmodule.Sliders.__CoreLoaded then return end
APmodule.Sliders.__CoreLoaded = true

APmodule.HeightMin = APmodule.HeightMin or 95
APmodule.HeightMax = APmodule.HeightMax or 110
APmodule.HeightDefault = APmodule.HeightDefault or 100
APmodule.Sliders.EnableConVarName = APmodule.Sliders.EnableConVarName or "hg_appearance_sliders_enabled"

if SERVER and not ConVarExists(APmodule.Sliders.EnableConVarName) then
    CreateConVar(
        APmodule.Sliders.EnableConVarName,
        "1",
        bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY),
        "Enable Cub sliders runtime scaling",
        0,
        1
    )
end

function APmodule.Sliders.GetEnableConVar()
    if not ConVarExists(APmodule.Sliders.EnableConVarName) then return nil end
    return GetConVar(APmodule.Sliders.EnableConVarName)
end

function APmodule.Sliders.IsEnabled()
    local cvar = APmodule.Sliders.GetEnableConVar()
    if not cvar then return true end
    return cvar:GetBool()
end

local function PatchSkeletonDefaults()
    APmodule.SkeletonAppearanceTable = APmodule.SkeletonAppearanceTable or {}

    if APmodule.SkeletonAppearanceTable.ABodySize == nil then
        APmodule.SkeletonAppearanceTable.ABodySize = APmodule.HeightDefault
    end

    if APmodule.SkeletonAppearanceTable.ABodySizeResizeHead == nil then
        APmodule.SkeletonAppearanceTable.ABodySizeResizeHead = false
    end

    if APmodule.SkeletonAppearanceTable.AHeight == nil then
        APmodule.SkeletonAppearanceTable.AHeight = APmodule.HeightDefault
    end

    if APmodule.SkeletonAppearanceTable.AHeightResizeHead == nil then
        APmodule.SkeletonAppearanceTable.AHeightResizeHead = false
    end
end

PatchSkeletonDefaults()

function APmodule.NormalizeHeight(height)
    height = tonumber(height) or APmodule.HeightDefault
    return math.Clamp(math.Round(height), APmodule.HeightMin, APmodule.HeightMax)
end

function APmodule.GetHeightScale(height)
    return APmodule.NormalizeHeight(height) / 100
end

function APmodule.BuildScaleCacheKey(modelName, tbl)
    tbl = istable(tbl) and tbl or {}

    return table.concat({
        tostring(modelName or ""),
        tostring(APmodule.NormalizeHeight(tbl.ABodySize)),
        tostring(tobool(tbl.ABodySizeResizeHead)),
        tostring(APmodule.NormalizeHeight(tbl.AHeight)),
        tostring(tobool(tbl.AHeightResizeHead))
    }, "|")
end

function APmodule.GetHeadBoneScale(tbl)
    tbl = APmodule.NormalizeAppearanceTable and APmodule.NormalizeAppearanceTable(tbl) or tbl or {}

    local bodyScale = APmodule.GetHeightScale(tbl.ABodySize)
    local heightScale = APmodule.GetHeightScale(tbl.AHeight)
    local headScale = tbl.ABodySizeResizeHead and bodyScale or 1

    if not tbl.AHeightResizeHead then
        headScale = headScale / heightScale
    end

    return Vector(headScale, headScale, headScale)
end

local previousNormalize = APmodule.NormalizeAppearanceTable
if not APmodule.Sliders.__NormalizeWrapped then
    APmodule.Sliders.__NormalizeWrapped = true

    function APmodule.NormalizeAppearanceTable(tblAppearance)
        PatchSkeletonDefaults()

        local normalized
        if isfunction(previousNormalize) then
            normalized = previousNormalize(tblAppearance)
        else
            normalized = istable(tblAppearance) and table.Copy(tblAppearance) or {}
        end

        normalized = istable(normalized) and normalized or {}

        if not istable(normalized.AClothes) then
            normalized.AClothes = table.Copy(APmodule.SkeletonAppearanceTable.AClothes or {})
        end

        normalized.AAttachments = istable(normalized.AAttachments) and table.Copy(normalized.AAttachments) or {}
        normalized.ABodygroups = istable(normalized.ABodygroups) and table.Copy(normalized.ABodygroups) or {}
        normalized.ABodySize = APmodule.NormalizeHeight(normalized.ABodySize)
        normalized.ABodySizeResizeHead = tobool(normalized.ABodySizeResizeHead)
        normalized.AHeight = APmodule.NormalizeHeight(normalized.AHeight)
        normalized.AHeightResizeHead = tobool(normalized.AHeightResizeHead)

        return normalized
    end
end

local previousValidator = APmodule.AppearanceValidater
if not APmodule.Sliders.__ValidatorWrapped then
    APmodule.Sliders.__ValidatorWrapped = true

    function APmodule.AppearanceValidater(tblAppearance)
        if isfunction(previousValidator) and not previousValidator(tblAppearance) then
            return false
        end

        if not istable(tblAppearance) then return false end

        local normalized = APmodule.NormalizeAppearanceTable(tblAppearance)
        local validBodySize = isnumber(normalized.ABodySize) and normalized.ABodySize >= APmodule.HeightMin and normalized.ABodySize <= APmodule.HeightMax
        local validHeight = isnumber(normalized.AHeight) and normalized.AHeight >= APmodule.HeightMin and normalized.AHeight <= APmodule.HeightMax

        return validBodySize and validHeight
            and isbool(normalized.ABodySizeResizeHead)
            and isbool(normalized.AHeightResizeHead)
    end
end
