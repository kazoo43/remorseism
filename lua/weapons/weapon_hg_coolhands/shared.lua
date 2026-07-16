SWEP.Base = "weapon_tpik_base"
local function RagdollOwner(ent)
	return hg.RagdollOwner(ent)
end
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/z_city/nmrih/weapons/fists/v_me_fists.mdl"
SWEP.WorldModelReal = "models/z_city/nmrih/weapons/fists/v_me_fists.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 40
SWEP.HomicideSWEP = true
SWEP.NoDrop = true
SWEP.ShockMultiplier = 1
SWEP.PainMultiplier = 1
SWEP.BreakBoneMul = 0.33
SWEP.Penetration = 1
SWEP.DamageMul = 0.9
SWEP.animtime = 0
SWEP.WorkWithFake = false
SWEP.supportTPIK = true
SWEP.ismelee = true
SWEP.SwingAng = -5

hg = hg or {}

local string_lower = string.lower
local string_find = string.find

local function UseDefaultHands(ply)
        if not IsValid(ply) then return false end

        local className = string_lower(ply.PlayerClassName or "")

        if className == "furry" then
                return false
        end

        return string_find(className, "zombie", 1, true) == nil
end

function hg.GetHandsWeaponClass(ply)
        if not UseDefaultHands(ply) then
                return "weapon_hands_sh"
        end

        return "weapon_hg_coolhands"
end

function hg.GetHandsWeapon(ply)
        if not IsValid(ply) then return NULL end

        local class = hg.GetHandsWeaponClass(ply)
        local wep = ply:GetWeapon(class)

        if SERVER and class == "weapon_hg_coolhands" and not IsValid(wep) then
                wep = ply:Give(class)
        end

        if SERVER and class == "weapon_hg_coolhands" and ply:HasWeapon("weapon_hands_sh") then
                ply:StripWeapon("weapon_hands_sh")
        end

        if IsValid(wep) then
                return wep
        end

        return ply:GetWeapon("weapon_hands_sh")
end

if SERVER then
        hook.Add("WeaponEquip", "hg_coolhands_fallback", function(wep, ply)
                if not IsValid(wep) or wep:GetClass() != "weapon_hands_sh" then return end
                if not IsValid(ply) or hg.GetHandsWeaponClass(ply) != "weapon_hg_coolhands" then return end

                timer.Simple(0, function()
                        if not IsValid(ply) then return end

                        local wasActive = ply:GetActiveWeapon() == wep

                        if ply:HasWeapon("weapon_hands_sh") then
                                ply:StripWeapon("weapon_hands_sh")
                        end

                        local hands = ply:GetWeapon("weapon_hg_coolhands")

                        if not IsValid(hands) then
                                hands = ply:Give("weapon_hg_coolhands")
                        end

                        if wasActive and IsValid(hands) then
                                ply:SelectWeapon("weapon_hg_coolhands")
                        end
                end)
        end)
end

local math = math -- owo
local math_random, math_Clamp, CurTime, Color = math.random, math.Clamp, CurTime, Color

-- read if cute :3

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
	self:NetworkVar("Bool", 5, "Blocking")
	self:NetworkVar("Float", 6, "LastBlocked")
	self:NetworkVar("Float", 7, "StartedBlocking")
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 0.44)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
end

local ang1 = Angle(90,-15,180)
local ang2 = Angle(90,15,0)

local ang4 = Angle(0,0,180)
local ang5 = Angle(0,0,0)

local ang3 = Angle(0,0,180)
local clamp = math_Clamp

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end
	local class = ent:GetClass()
	if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) then return true end
	return false
end

SWEP.blockSound = nil
function SWEP:IsClient()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:UpdateNextIdle(t)
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	self:SetNextIdle(CurTime() + (t or 0.44 * (ply.organism.stamina[1] / ply.organism.stamina.max)))
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

function SWEP:Holster( wep )
	if not IsFirstTimePredicted() then return true end
	local owner = self:GetOwner()

	if owner:GetNetVar("handcuffed",false) then return false end

	return true
end
