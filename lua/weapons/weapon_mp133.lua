--ByLazzy
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MR-133"
SWEP.Author = "Baikal"
SWEP.Instructions = "Pump-action shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/zcity/w_shot_m3juper90.mdl"
SWEP.WorldModelFake = "models/weapons/c_mr133.mdl"
SWEP.WorldModelReal = "models/weapons/c_mr133.mdl"

SWEP.FakePos = Vector(-9, 3.6, 6.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "111100100011"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "111100100011"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

-- Р¤РµР№РєРѕРІС‹Рµ Р·РІСѓРєРё
SWEP.FakeReloadSounds = {
    [0.25] = "weapons/ak74/ak74_magout.wav",
    [0.85] = "weapons/ak74/ak74_magin.wav",
}
SWEP.FakeEmptyReloadSounds = {
    [0.25] = "weapons/ak74/ak74_magout.wav",
    [0.65] = "weapons/ak74/ak74_magin.wav",
}

SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mr133.png")
SWEP.IconOverride = "entities/arc9_eft_mr133.png"

SWEP.LocalMuzzlePos = Vector(27.739, 0.09, 5.098)
SWEP.LocalMuzzleAng = Angle(0.2, -0.0, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = "12x70"
SWEP.ReloadSound = "weapons/remington_870/870_shell_in_1.wav"
SWEP.CockSound = "weapons/darsu_eft/m870/rem870_pump_in.ogg"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

-- РҐР°СЂР°РєС‚РµСЂРёСЃС‚РёРєРё
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Damage = 16 * 8 
SWEP.Primary.Force = 12
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.04
SWEP.Primary.NumShots = 8
-- Р—РІСѓРєРё РІС‹СЃС‚СЂРµР»Р°
SWEP.Primary.Sound = {"weapons/darsu_eft/mr133/mr133_fire_close2.ogg", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/mr133/mr133_fire_silenced_close.ogg", 65, 100, 100}
SWEP.Primary.Wait = 0.8
SWEP.NumBullet = 8

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.67, 5.4)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-1, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- РЎРџРРЎРћРљ РђРќРРњРђР¦РР™
SWEP.AnimList = {
    ["idle"] = "idle",
    ["draw"] = "draw",
    ["holster"] = "holster",
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["cycle"] = "pump2",
    
    ["start"] = "reload_start2",
    ["insert"] = "reload_loop2",
    ["finish"] = "reload_end",
}

-- РџРЈРўР¬ Рљ Р—Р’РЈРљРђРњ
local path = "weapons/darsu_eft/mr133/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.01] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
        [0.63] = function(self) self:EmitSound(path .. "mr133_pump_in_fast.ogg") end,
        [0.87] = function(self) self:EmitSound(path .. "mr133_pump_out_fast.ogg") end,
    },
    ["draw"] = {
        [0.01] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound(path .. "mr133_trigger.wav") end,
    },
    ["pump2"] = { 
        [0.08] = function(self) self:EmitSound(path .. "mr133_pump_in_fast.ogg") end,
        [0.15] = function(self) self:EmitSound(path .. "pump_jam_extract.ogg") end, 
        [0.28] = function(self) self:EmitSound(path .. "mr133_pump_out_fast.ogg") end,
    },
    
    -- Р—Р’РЈРљР РџР•Р Р•Р—РђР РЇР”РљР
    ["reload_start2"] = { 
        [0.2] = function(self) self:EmitSound(path .. "mr133_shell_pickup.ogg") end,
        [0.8] = function(self) self:EmitSound(path .. "mr133_magcover.ogg") end,
        [1.0] = function(self) self:EmitSound(path .. "mr133_shell_in_port.ogg") end, 
    },
    ["reload_loop2"] = { 
        [0.2] = function(self) self:EmitSound(path .. "mr133_shell_pickup.ogg") end,
        [0.5] = function(self) self:EmitSound(path .. "mr133_magcover.ogg") end,
        [0.71] = function(self) self:EmitSound(path .. "mr133_shell_in_port.ogg") end,
    },
}

SWEP.stupidgun = true

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "111100100011") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end self:GetWM():SetBodyGroups(new) end
function SWEP:InitializePost() 
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
    self.isReloading = false -- Р¤Р»Р°Рі РїРµСЂРµР·Р°СЂСЏРґРєРё
end
function SWEP:AnimationPost() local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1); local sin = 1 - animpos; if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end; sin = sin * 2; sin = math.ease.InOutSine(sin); if sin > 0 then self.LHPos[1] = 18 - sin * 6; self.RHPos[1] = 1 - sin * 4; self.inanim = true else self.inanim = nil end; local wep = self:GetWeaponEntity(); if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

local function cock(self, time)
    if SERVER then
        self:Draw(true)
    end
    
    if CLIENT and LocalPlayer() == self:GetOwner() then return end

    net.Start("hgwep draw")
        net.WriteEntity(self)
        net.WriteBool(self.drawBullet)
        net.WriteFloat(CurTime())
    net.Broadcast()

    self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
    self.reloadCoolDown = CurTime() + time
end

local function reloadFunc(self)
    if not SERVER then return end
    
    if self:Clip1() >= self.Primary.ClipSize or self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then
        
        self:PlayAnim(self.AnimList["finish"], 1, false, function()
            -- Р•РЎР›Р Р‘Р«Р›Рђ РџРЈРЎРўРђРЇ РџР•Р Р•Р—РђР РЇР”РљРђ (РЅРµС‚ РїР°С‚СЂРѕРЅР° РІ СЃС‚РІРѕР»Рµ), Р”Р•Р›РђР•Рњ РџРћРњРџРЈ
            if not self.drawBullet and self:Clip1() > 0 then
                self:PlayAnim(self.AnimList["cycle"], 1, false, function()
                    self.drawBullet = true
                    net.Start("hgwep draw")
                        net.WriteEntity(self)
                        net.WriteBool(true)
                        net.WriteFloat(CurTime() - 10) 
                    net.Broadcast()
                    self:SetNetVar("shootgunReload", 0)
                    self.isReloading = false -- РЎРЅРёРјР°РµРј С„Р»Р°Рі
                end, false, true)
                
                timer.Simple(0.08, function() if IsValid(self) then self:EmitSound(path .. "mr133_pump_in_fast.ogg") end end)
                timer.Simple(0.28, function() if IsValid(self) then self:EmitSound(path .. "mr133_pump_out_fast.ogg") end end)
            else
                self:SetNetVar("shootgunReload", 0)
                self.isReloading = false -- РЎРЅРёРјР°РµРј С„Р»Р°Рі
            end
        end, false, true)
        return
    end

    if SERVER then self:SetNetVar("shootgunReload", CurTime() + 0.9) end

    self:PlayAnim(self.AnimList["insert"], 1, false, function()
        if not IsValid(self) then return end
        
        self:InsertAmmo(1)
        reloadFunc(self)
    end, false, true)
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end
    
    -- Р‘Р›РћРљРР РћР’РљРђ РџРћР’РўРћР РќРћР“Рћ Р’Р«Р—РћР’Рђ
    if self.isReloading then return end

    -- РџРѕРјРїР°
    if self.drawBullet == false and SERVER then
        cock(self, 0.5)
        self:PlayAnim(self.AnimList["cycle"], 1, false, nil, false, true)
        -- Р—РІСѓРєРё РїРѕРјРїС‹
        timer.Simple(0.08, function() if IsValid(self) then self:EmitSound(path .. "mr133_pump_in_fast.ogg") end end)
        timer.Simple(0.28, function() if IsValid(self) then self:EmitSound(path .. "mr133_pump_out_fast.ogg") end end)
        return
    end

    if not self:CanReload() then return end
    if self:Clip1() >= self.Primary.ClipSize then return end

    if SERVER then
        self.isReloading = true -- РЎС‚Р°РІРёРј С„Р»Р°Рі
        self:SetNetVar("shootgunReload", CurTime() + 1.2)
        
        self:PlayAnim(self.AnimList["start"], 1, false, function()
            reloadFunc(self)
        end, false, true)
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

SWEP.InspectAnimLH = { Vector(0, 0, 0) }
SWEP.InspectAnimLHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimRH = { Vector(0, 0, 0) }
SWEP.InspectAnimRHAng = { Angle(0, 0, 0) }
SWEP.InspectAnimWepAng = {
    Angle(0, 0, 0),
    Angle(-5, 9, 5),
    Angle(-5, 9, 14),
    Angle(-5, 9, 16),
    Angle(-6, 10, 15),
    Angle(-5, 9, 16),
    Angle(-10, 15, -15),
    Angle(-2, 22, -15),
    Angle(0, 25, -32),
    Angle(0, 24, -45),
    Angle(0, 22, -55),
    Angle(0, 20, -56),
    Angle(0, 0, 0)
}
