if not (wOS and wOS.DynaBase and WOS_DYNABASE) then return end
if wOS.DynaBase._zshBeatrunParkourRegistered then return end

local ANIMATION_SET = "models/new_climbanim.mdl"
if not file.Exists(ANIMATION_SET, "GAME") then return end

wOS.DynaBase._zshBeatrunParkourRegistered = true
wOS.DynaBase:RegisterSource({
    Name = "Beatrun Parkour (ZSh Bridge)",
    Type = WOS_DYNABASE.EXTENSION,
    Shared = ANIMATION_SET
})

hook.Add("PreLoadAnimations", "wOS.DynaBase.MountBeatrunParkourZSh", function(gender)
    if gender ~= WOS_DYNABASE.SHARED then return end
    IncludeModel(ANIMATION_SET)
end)
