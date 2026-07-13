-- MTsвЂ‘255 (СЂРµРІРѕР»СЊРІРµСЂРЅРѕРµ СЂСѓР¶СЊС‘, 12/70)
-- Р±Р°Р·Р°: weapon_m4super

SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MTs-255"
SWEP.Author = "KBP"
SWEP.Instructions = "5-round revolving shotgun. Double-action."
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10

-- РњРћР”Р•Р›Р
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/zcity/w_shot_m3juper90.mdl"
SWEP.WorldModelFake = "models/weapons/c_mts255.mdl"
SWEP.WorldModelReal = "models/weapons/c_mts255.mdl"

-- РџРћР—РР¦РР
SWEP.FakePos = Vector(-14, 3.6, 6.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.ViewPunchDiv = 425

-- Р‘РћР”РР“Р РЈРџРџР«
SWEP.FakeBodyGroups = "011111011111"
SWEP.FakeBodyGroupsPresets = { "011111011111" }

SWEP.CantFireFromCollision = true
SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mts255.png")
SWEP.IconOverride = "entities/arc9_eft_mts255.png"

SWEP.LocalMuzzlePos = Vector(27.739, 0.09, 5.098)
SWEP.LocalMuzzleAng = Angle(0.2, 0, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

-- Р“РР›Р¬Р—Р«
SWEP.CustomShell = "12x70"
SWEP.ShellEject = nil -- СЂРµРІРѕР»СЊРІРµСЂ, РіРёР»СЊР·С‹ РЅРµ РІС‹Р»РµС‚Р°СЋС‚ РїСЂРё РІС‹СЃС‚СЂРµР»Рµ

SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

-- РҐРђР РђРљРўР•Р РРЎРўРРљР
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Damage = 14 * 8
SWEP.Primary.Force = 10
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.04
SWEP.Primary.NumShots = 8
SWEP.Primary.Wait = 0.4

local path = "weapons/darsu_eft/mts255/"

-- Длительности анимаций (в секундах) — меняй тут
SWEP.AnimDurations = {
    ["fistful_start__0"]    = 1.25,
    ["sg_reload_start1__0"] = 3.25,
    ["sg_reload_start2__0"] = 2.95,
    ["sg_reload_start3__0"] = 2.65,
    ["sg_reload_start4__0"] = 2.35,
}

-- Р—Р’РЈРљР Р’Р«РЎРўР Р•Р›Рђ
SWEP.Primary.Sound = {path .. "mts255_outdoor_close.ogg", 90, 100, 100}
SWEP.SupressedSound = {path .. "mts255_indoor_close.ogg", 80, 100, 100}

SWEP.DeploySnd = {path .. "mr133_draw.ogg", 55, 100, 100}
SWEP.HolsterSnd = {path .. "mr133_holster.ogg", 55, 100, 100}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.HoldType = "shotgun"
SWEP.ZoomPos = Vector(0, -0.69, 5.2)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.8
SWEP.Penetration = 5

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)

-- РЎРџРРЎРћРљ Р‘РђР—РћР’Р«РҐ РђРќРРњРђР¦РР™
SWEP.AnimList = {
    ["idle"]          = "idle",
    ["draw"]          = "draw__0",
    ["holster"]       = "holster__0",
    ["ready"]         = "draw__0",
    ["fire"]          = "fire_da__0",
    ["fire_empty"]    = "fire_dry__0",
    ["dryfire"]       = "fire_dry__0",
    ["reload"]        = "fistful_insert5", -- Р·Р°РіР»СѓС€РєР°

    -- РѕСЃРјРѕС‚СЂ С‡РµСЂРµР· look__3 (РёРјРµРЅРЅРѕ СЌС‚Р° Р°РЅРёРјР°С†РёСЏ РјРѕРґРµР»Рё)
    ["inspect"]       = "look__0",
    ["inspect_empty"] = "look__0",
}

function SWEP:AllowedInspect()
    if not self:CanUse() then return end
    if self.isReloading then return end
    if self:Clip1() < self.Primary.ClipSize then return end
    if self.drawBullet == false then return end
    return true
end


local path = "weapons/darsu_eft/mts255/"
SWEP.AnimsEvents = {
    ["inspect"] = {
        [0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
    },
    ["draw__0"] = {
        [0.05] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
    },
    ["holster__0"] = {
        [0.05] = function(self) self:EmitSound(path .. "mr133_holster.ogg") end,
    },
    ["fistful_start__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "mts255_baraban_open.ogg") end,
        [0.25] = function(self) self:EmitSound(path .. "mts255_baraban_purge_all.ogg") end,
    },
    ["sg_reload_start1__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "mts255_baraban_open.ogg") end,
        [0.4] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.55] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.65] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.95] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,

    },
    ["sg_reload_start2__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "mts255_baraban_open.ogg") end,
        [0.5] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.65] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.85] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
    },
    ["sg_reload_start3__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "mts255_baraban_open.ogg") end,
        [0.5] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
        [0.75] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
    },
    ["sg_reload_start4__0"] = {
        [0.1] = function(self) self:EmitSound(path .. "mts255_baraban_open.ogg") end,
        [0.6] = function(self) self:EmitSound(path .. "mts255_baraban_purge_single.ogg") end,
    },
}

SWEP.stupidgun = true

-------------------------------------------------
-- РЎР•РўР•Р’Р«Р• РџР•Р Р•РњР•РќРќР«Р•, Р‘РћР”РР“Р РЈРџРџР«
-------------------------------------------------

function SWEP:AnimHoldPost() end

function SWEP:ModelCreated(model)
    model:SetBodyGroups(self:GetRandomBodygroups() or "011111011111")
end

function SWEP:PostSetupDataTables()
    self:NetworkVar("String", 0, "RandomBodygroups")
    if CLIENT then
        self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged)
    end
end

function SWEP:OnVarChanged(name, old, new)
    if not IsValid(self:GetWM()) then return end
    if istable(new) then
        local normalized = {}
        for i = 1, #new do normalized[i] = tostring(new[i]) end
        new = table.concat(normalized, "")
    elseif not isstring(new) then
        return
    end
    self:GetWM():SetBodyGroups(new)
end

function SWEP:InitializePost()
    self:SetRandomBodygroups("011111011111")
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
    self.reloadCoolDown = 0
    self.drawBullet = true
end

function SWEP:AnimationPost()
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then sin = 1 - sin end
    sin = sin * 2
    sin = math.ease.InOutSine(sin)

    if sin > 0 then
        self.LHPos[1] = 18 - sin * 6
        self.RHPos[1] = 1 - sin * 4
        self.inanim = true
    else
        self.inanim = nil
    end

    local wep = self:GetWeaponEntity()
    if CLIENT and IsValid(wep) then
        wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false)
    end
end

function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

-------------------------------------------------
-- РЎРўР Р•Р›Р¬Р‘Рђ
-------------------------------------------------

function SWEP:PrimaryShootPost()
    self.drawBullet = true
end

-------------------------------------------------
-- РџР•Р Р•Р—РђР РЇР”РљРђ: РћР‘Р©РР™ Р¤РРќРђР›
-------------------------------------------------

local function MTS255_FinishReload(wep)
    if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end

    local startClip = wep.reloadStartClip or wep:Clip1()
    local toLoad    = wep.reloadToLoad   or 0
    local ammoType  = wep:GetPrimaryAmmoType()
    local owner     = wep:GetOwner()

    if toLoad > 0 then
        owner:RemoveAmmo(toLoad, ammoType)
    end

    local finalClip = math.min(startClip + toLoad, wep.Primary.ClipSize)
    wep:SetClip1(finalClip)

    wep:SetNetVar("shootgunReload", 0)
    wep.reloadCoolDown = CurTime()

    wep:PlayAnim("idle", 1.0, false, nil, false, true)

    wep.drawBullet = true
    net.Start("hgwep draw")
        net.WriteEntity(wep)
        net.WriteBool(true)
        net.WriteFloat(CurTime() - 10)
    net.Broadcast()

    wep.reloadStartClip = nil
    wep.reloadToLoad    = nil
end

-------------------------------------------------
-- РџРћР›РќРђРЇ РџР•Р Р•Р—РђР РЇР”РљРђ (fistful)
-------------------------------------------------

local function MTS255_PlayFistfulChain(wep, step, targetStep)
    if not IsValid(wep) then return end

    local toLoad = wep.reloadToLoad or 0
    if toLoad <= 0 then MTS255_FinishReload(wep) return end

    if step > targetStep then
        local finalClip = math.min((wep.reloadStartClip or 0) + toLoad, wep.Primary.ClipSize)
        local animEnd = "fistful_end_r" .. math.Clamp(finalClip, 1, 5)

        wep:PlayAnim(animEnd, 1.0, false, function()
            MTS255_FinishReload(wep)
        end, false, true)

        wep:EmitSound(path .. "mts255_baraban_close.ogg")
        return
    end

    local animName = "fistful_insert" .. step
    wep:PlayAnim(animName, 1.0, false, function()
        MTS255_PlayFistfulChain(wep, step + 1, targetStep)
    end, false, true)

    timer.Simple(0.4, function()
        if IsValid(wep) then
            wep:EmitSound(path .. "mts255_round_insert1.ogg")
        end
    end)
end

-------------------------------------------------
-- Р’Р«Р‘РћР РћР§РќРђРЇ РџР•Р Р•Р—РђР РЇР”РљРђ (sg_reload)
-------------------------------------------------

local function MTS255_PlaySgInsertChain(wep, idx, lastIdx)
    if not IsValid(wep) then return end

    local toLoad    = wep.reloadToLoad    or 0
    local startClip = wep.reloadStartClip or wep:Clip1()
    if toLoad <= 0 then MTS255_FinishReload(wep) return end

    -- Р’СЃРµ РЅСѓР¶РЅС‹Рµ insert'С‹ РѕС‚С‹РіСЂР°Р»Рё вЂ“ РєРѕРЅРµС†
    if idx > lastIdx then
        local finalClip = math.min(startClip + toLoad, wep.Primary.ClipSize)
        local animEnd   = "fistful_end_r" .. math.Clamp(finalClip, 1, 5)

        wep:PlayAnim(animEnd, 1.0, false, function()
            MTS255_FinishReload(wep)
        end, false, true)

        wep:EmitSound(path .. "mts255_baraban_close.ogg")
        return
    end

    local animName = "sg_reload_insert" .. idx
    wep:PlayAnim(animName, 1.0, false, function()
        MTS255_PlaySgInsertChain(wep, idx + 1, lastIdx)
    end, false, true)

    timer.Simple(0.4, function()
        if IsValid(wep) then
            wep:EmitSound(path .. "mts255_round_insert2.ogg")
        end
    end)
end

-------------------------------------------------
-- Р“Р›РђР’РќРђРЇ Р¤РЈРќРљР¦РРЇ РџР•Р Р•Р—РђР РЇР”РљР
-------------------------------------------------

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    local clip    = self:Clip1()
    local maxClip = self.Primary.ClipSize
    if clip >= maxClip then return end

    local ammoReserve = self:Ammo1()
    if ammoReserve <= 0 then return end

    if SERVER then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local need   = maxClip - clip
        local toLoad = math.min(need, ammoReserve)
        if toLoad <= 0 then return end

        self.reloadStartClip = clip
        self.reloadToLoad    = toLoad

        if clip == 0 then
            -- ПОЛНАЯ ПЕРЕЗАРЯДКА
            local targetStep = math.min(toLoad, 5)

            local fistfulDur = self.AnimDurations["fistful_start__0"] or 1.25

            local estimatedTime = fistfulDur + (targetStep * 1.2) + 1.3
            self:SetNetVar("shootgunReload", CurTime() + estimatedTime)
            self.reloadCoolDown = CurTime() + estimatedTime

            self:PlayAnim("fistful_start__0", fistfulDur, false, function()
                if not IsValid(self) then return end
                MTS255_PlayFistfulChain(self, 1, targetStep)
            end, false, true)

        else
            -- ВЫБОРОЧНАЯ ПЕРЕЗАРЯДКА
            local firstIndex = clip
            local lastIndex  = math.min(clip + toLoad - 1, 4)

            local startAnim = "sg_reload_start" .. clip .. "__0"
            local startDur = self.AnimDurations[startAnim] or 2.35

            local estimatedTime = startDur + (toLoad * 1.1) + 1.2
            self:SetNetVar("shootgunReload", CurTime() + estimatedTime)
            self.reloadCoolDown = CurTime() + estimatedTime

            self:PlayAnim(startAnim, startDur, false, function()
                if not IsValid(self) then return end
                self:EmitSound(path .. "mts255_round_extract1.ogg")
                MTS255_PlaySgInsertChain(self, firstIndex, lastIndex)
            end, false, true)
        end
    end
end

-------------------------------------------------
-- Р‘Р›РћРљРР РћР’РљРђ РЎРўР Р•Р›Р¬Р‘Р« РџР Р РџР•Р Р•Р—РђР РЇР”РљР•
-------------------------------------------------

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

-------------------------------------------------
-- РћРЎРњРћРўР 
-- (СЂСѓС‡РЅС‹Рµ РєСЂРёРІС‹Рµ РїРѕС‡С‚Рё РЅРµ РјРµС€Р°СЋС‚, РЅРѕ РµСЃР»Рё С…РѕС‡РµС€СЊ С‡РёСЃС‚Рѕ look__3 вЂ”
-- РјРѕР¶РЅРѕ СЃРѕРєСЂР°С‚РёС‚СЊ РґРѕ РѕРґРЅРѕРіРѕ СѓРіР»Р°)
-------------------------------------------------

SWEP.InspectAnimLH    = { Vector(0, 0, 0) }
SWEP.InspectAnimLHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimRH    = { Vector(0, 0, 0) }
SWEP.InspectAnimRHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimWepAng = {
    Angle(0, 0, 0),
}
