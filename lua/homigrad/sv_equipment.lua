util.AddNetworkString("hg_add_equipment")
util.AddNetworkString("hg_drop_equipment")

local armorBreakShotRanges = {
	head = {1, 5},
	face = {1, 5},
	default = {10, 35}
}

local armorBrokenProtectionRange = {0.1, 0.2}
local armorBreakSound = "rem_armorbreak.mp3"
local armorBreakSoundLevel = 140
local armorBreakSoundVolume = 2

local function getArmorShotRange(equipment)
	local placement = hg.GetArmorPlacement(equipment)
	local range = armorBreakShotRanges[placement] or armorBreakShotRanges.default

	return range[1], range[2]
end

function hg.GetArmorBreakShotCount(equipment)
	local minShots, maxShots = getArmorShotRange(equipment)

	return math.random(minShots, maxShots)
end

local function getBrokenArmorProtectionMul()
	return math.Rand(armorBrokenProtectionRange[1], armorBrokenProtectionRange[2])
end

local function markArmorBroken(owner, equipment, mul)
	if not IsValid(owner) then return end

	owner.armors_broken = owner.armors_broken or {}
	owner.armors_broken_mul = owner.armors_broken_mul or {}
	owner.armors_broken[equipment] = true
	owner.armors_broken_mul[equipment] = mul or owner.armors_broken_mul[equipment] or getBrokenArmorProtectionMul()
end

function hg.SetArmorBrokenEntity(ent)
	if not IsValid(ent) then return end

	ent.broken = true
	ent:SetNWBool("ArmorBroken", true)
end

function hg.PlayArmorBreakSound(ent)
	if not IsValid(ent) then return end

	sound.Play(armorBreakSound, ent:GetPos(), armorBreakSoundLevel, 100, armorBreakSoundVolume)
end

local function getArmorDropTransform(ent, equipment, pos)
	if not IsValid(ent) then return pos or vector_origin, angle_zero end

	local placement = hg.GetArmorPlacement(equipment)
	local armorData = placement and hg.armor[placement] and hg.armor[placement][equipment]
	if not armorData then return pos or ent:GetPos(), ent:GetAngles() end

	local bone = ent:LookupBone(armorData.bone or "")
	local matrix = bone and ent:GetBoneMatrix(bone)
	if not matrix then return pos or ent:GetPos(), ent:GetAngles() end

	local bonePos = matrix:GetTranslation()
	local boneAng = matrix:GetAngles()
	local dropPos, dropAng = LocalToWorld(armorData[3] or vector_origin, armorData[4] or angle_zero, bonePos, boneAng)

	return pos or dropPos, dropAng
end

local function getArmorDropVelocity(dmgInfo)
	if not dmgInfo then return end

	local force = dmgInfo:GetDamageForce()
	if not force or force:LengthSqr() <= 0 then return end

	force = force:GetNormalized() * math.Clamp(force:Length() * 0.02, 100, 250)
	force.z = force.z + 35

	return force
end

function hg.BreakArmor(ent, equipment, pos, dmgInfo)
	if not IsValid(ent) then return false end
	if not ent.armors or not table.HasValue(ent.armors, equipment) then return false end

	local placement = hg.GetArmorPlacement(equipment)
	local brokenMul = ent.armors_broken_mul and ent.armors_broken_mul[equipment] or getBrokenArmorProtectionMul()
	ent.armors_shots = ent.armors_shots or {}
	ent.armors_health = ent.armors_health or {}
	markArmorBroken(ent, equipment, brokenMul)

	if placement ~= "head" and placement ~= "face" then
		ent.armors_shots[equipment] = nil
		hg.PlayArmorBreakSound(ent)
		syncLinkedArmor(ent)
		return true
	end

	local equipmentEnt = hg.DropArmorForce(ent, equipment, pos, nil, getArmorDropVelocity(dmgInfo), brokenMul)

	ent.armors_shots[equipment] = nil
	ent.armors_health[equipment] = nil
	if ent.armors_broken then
		ent.armors_broken[equipment] = nil
	end
	if ent.armors_broken_mul then
		ent.armors_broken_mul[equipment] = nil
	end

	if not IsValid(equipmentEnt) then return false end

	hg.SetArmorBrokenEntity(equipmentEnt)
	hg.PlayArmorBreakSound(equipmentEnt)

	return true
end

local function syncLinkedArmor(ent)
	if not IsValid(ent) then return end

	ent:SyncArmor()

	if not ent:IsRagdoll() then return end

	local owner = hg.RagdollOwner(ent)
	if not IsValid(owner) then return end

	owner.armors = table.Copy(ent.armors or owner.armors or {})
	owner.armors_shots = table.Copy(ent.armors_shots or owner.armors_shots or {})
	owner.armors_health = table.Copy(ent.armors_health or owner.armors_health or {})
	owner.armors_broken = table.Copy(ent.armors_broken or owner.armors_broken or {})
	owner.armors_broken_mul = table.Copy(ent.armors_broken_mul or owner.armors_broken_mul or {})
	owner:SyncArmor()
end

function hg.HandleArmorShot(org, placement, armor, dmgInfo, hit)
	local owner = org and org.owner

	if not IsValid(owner) then return end
	if not owner.armors or owner.armors[placement] ~= armor then return end
	if not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end
	if owner.armors_broken and owner.armors_broken[armor] then return end

	owner.armors_shots = owner.armors_shots or {}
	owner.armors_shots[armor] = owner.armors_shots[armor] or hg.GetArmorBreakShotCount(armor)
	owner.armors_shots[armor] = owner.armors_shots[armor] - 1

	if owner.armors_shots[armor] <= 0 then
		hg.BreakArmor(owner, armor, hit, dmgInfo)
	end
end

function hg.SetArmorRestrictions(ply, restrictions)
	if not IsValid(ply) then return end
	ply.ArmorRestrictions = restrictions
end

function hg.ClearArmorRestrictions(ply)
	if not IsValid(ply) then return end
	ply.ArmorRestrictions = nil
end


function hg.CanEquipArmorPiece(ply, equipment)
	if not IsValid(ply) or not ply.ArmorRestrictions or not istable(ply.ArmorRestrictions) then
		return true
	end
	
	local equipName = string.Replace(equipment, "ent_armor_", "")
	local placement = hg.GetArmorPlacement(equipName)
	
	local isRestricted = ply.ArmorRestrictions[equipName] or ply.ArmorRestrictions[placement] or ply.ArmorRestrictions["all"]
	
	return not isRestricted
end

net.Receive("hg_drop_equipment", function(len, ply)
    local equipment = net.ReadString()

    if equipment == "hg_flashlight" then
        ply:ConCommand("hg_dropflashlight")
    end

    if equipment == "hg_sling" then
        ply:ConCommand("hg_dropsling")
    end

    if equipment == "hg_brassknuckles" then
        ply:ConCommand("hg_dropkastet")
    end

    if not ply.organism.canmove then return end

    hg.DropArmor(ply, equipment)
end)

function hg.AddArmor(ply, equipment, ent)
    if not IsValid(ply) then return end

	if not hg.CanEquipArmorPiece(ply, equipment) then
		if ply:IsPlayer() then
			--ply:ChatPrint("huy")
		end
		return false
	end
	
	local can = hook.Run("CanEquipArmor", ply, equipment)
	
	if(can == false)then
		return nil
	end
	
    if equipment and istable(equipment) then
        for i,equipment1 in pairs(equipment) do
            hg.AddArmor(ply, equipment1)
        end
        return
    end
    equipment = string.Replace(equipment,"ent_armor_","")
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    if hg.armor[placement][equipment].whitelistClasses and !hg.armor[placement][equipment].whitelistClasses[ply.PlayerClassName] then return false end

    for plc, arm in pairs(ply.armors) do
        //if not hg.armor[plc] or not hg.armor[plc][arm] or not hg.armor[plc][arm].restricted then continue end

        if hg.armor[plc][arm].restricted and table.HasValue(hg.armor[plc][arm].restricted, placement) then
            if not hg.DropArmor(ply, ply.armors[plc]) then return false end
        end
        
        if hg.armor[placement][equipment].restricted and table.HasValue(hg.armor[placement][equipment].restricted, plc) then
            if not hg.DropArmor(ply, ply.armors[plc]) then return false end
        end
    end

    if ply.armors[placement] and ply:IsPlayer() then
		local currentArmorData = hg.armor[placement] and hg.armor[placement][ply.armors[placement]]
		
        if not hg.DropArmor(ply, ply.armors[placement]) then return false end
    end
    
    if hg.armor[placement][equipment].AfterPickup then
        hg.armor[placement][equipment].AfterPickup(ply)
    end

    if hg.armor[placement][equipment].voice_change then
        if eightbit and eightbit.EnableEffect and ply.UserID then
            eightbit.EnableEffect(ply:UserID(), eightbit.EFF_MASKVOICE)
        end
    end

	if ent then
		ent:ApplyData(ply,equipment)
	else
		local item = hg.armor[placement][equipment]
		local mat = istable(item.material) and item.material[1] or item.material
		ply:SetNWString("ArmorMaterials" .. equipment, mat)

		local skin = istable(item.material) and table.Random(item.material) or nil
		if item.skins then
			ply:SetNWInt("ArmorSkins" .. equipment, skin)
		end
	end

	ply.armors_shots = ply.armors_shots or {}
	if not (ply.armors_broken and ply.armors_broken[equipment]) then
		ply.armors_shots[equipment] = ply.armors_shots[equipment] or hg.GetArmorBreakShotCount(equipment)
	else
		ply.armors_shots[equipment] = nil
	end

    ply.armors[placement] = equipment
    
    ply:SyncArmor()
    return true
end

function hg.DropArmorForce(ent, equipment, pos, ang, vel, brokenMul)
    if not table.HasValue(ent.armors, equipment) then return false end
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    if hg.armor[placement][equipment] then
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        local dropPos, dropAng = getArmorDropTransform(ent, equipment, pos)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(dropPos)
        equipmentEnt:SetAngles(ang or dropAng)
		equipmentEnt:ReciveData(ent,equipment)
		equipmentEnt.shotsLeft = ent.armors_shots and ent.armors_shots[equipment] or nil
		if brokenMul or ent.armors_broken and ent.armors_broken[equipment] then
			equipmentEnt.brokenProtectionMul = brokenMul or ent.armors_broken_mul and ent.armors_broken_mul[equipment]
			hg.SetArmorBrokenEntity(equipmentEnt)
		end

        if ent:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ent:SetNetVar("zableval_masku", false)
        end

        local phys = equipmentEnt:GetPhysicsObject()
		if IsValid(phys) and vel then
			phys:SetVelocity(vel)
		end

        if IsValid(equipmentEnt) then table.RemoveByValue(ent.armors, equipment) end
		if ent.armors_shots then
			ent.armors_shots[equipment] = nil
		end
		if ent.armors_broken then
			ent.armors_broken[equipment] = nil
		end
		if ent.armors_broken_mul then
			ent.armors_broken_mul[equipment] = nil
		end
        
        if hg.armor[placement][equipment].voice_change then
            if eightbit and eightbit.EnableEffect and ent.UserID then
                eightbit.EnableEffect(ent:UserID(), ent.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
            end
        end

        syncLinkedArmor(ent)
        
        return equipmentEnt
    end
end

function hg.DropArmor(ply, equipment)
    if not table.HasValue(ply.armors, equipment) then return false end
    
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if hg.armor[placement][equipment].nodrop then return false end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end

    if IsValid(ply) and ply.DropCD and ply.DropCD > CurTime() then return false end

    if hg.armor[placement][equipment] then
        ply:DoAnimationEvent((placement == "head" or placement == "ears" or placement == "face") and ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
	    ply:ViewPunch(Angle(1,-2,1))
        ply.DropCD = CurTime() + 0.35
        --timer.Simple(0.3,function()
        if not IsValid(ply) then return end
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(ply:EyePos())
        equipmentEnt:SetAngles(ply:EyeAngles())
		equipmentEnt:ReciveData(ply,equipment)
		equipmentEnt.shotsLeft = ply.armors_shots and ply.armors_shots[equipment] or nil
        
        if placement == "face" and ply:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ply:SetNetVar("zableval_masku", false)
        end
        
        local phys = equipmentEnt:GetPhysicsObject()
        if IsValid(phys) then phys:SetVelocity(ply:EyeAngles():Forward() * 150) end
        if IsValid(equipmentEnt) then table.RemoveByValue(ply.armors, equipment) end
		if ply.armors_shots then
			ply.armors_shots[equipment] = nil
		end
        
        if hg.armor[placement][equipment].voice_change then
            if eightbit and eightbit.EnableEffect and ply.UserID then
                eightbit.EnableEffect(ply:UserID(), ply.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
            end
        end

        ply:SyncArmor()
        --end)
        return true
    end
end

-- armorstuff
util.AddNetworkString("AddFlash")

local ArmorEffect
local force
local function protec(org, bone, dmg, dmgInfo, placement, armor, scale, scaleprot, punch, boneindex, dir, hit, ricochet)
	if not force and org.owner.armors[placement] ~= armor then return 0 end
	force = nil
	
	local prot = placement and hg.armor[placement] and armor and hg.armor[placement][armor] and (hg.armor[placement][armor].protection - (dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1)) or (10 - ( dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1))
	
	org.owner.armors_health = org.owner.armors_health or {}
	org.owner.armors_broken_mul = org.owner.armors_broken_mul or {}

	prot = prot * (org.owner.armors_health[armor] or 1)
	prot = prot * (org.owner.armors_broken_mul[armor] or 1)
	
	if punch then
		if org.owner:IsPlayer() and org.alive and dmgInfo:IsDamageType(DMG_BUCKSHOT + DMG_BULLET) then
			org.owner:ViewPunch(AngleRand(-30, 30))
			
			org.owner:EmitSound("homigrad/physics/shield/bullet_hit_shield_0"..math.random(7)..".wav", 80, math.random(95, 105))

			org.owner:AddTinnitus(3, true)
			net.Start("AddFlash")
				net.WriteVector(hg.eye(org.owner) + org.owner:GetForward() * 3)
				net.WriteFloat(3)
				net.WriteInt(100, 20)
			net.Send(org.owner)

			hg.ExplosionDisorientation(org.owner, 6, 6)

			hg.organism.input_list.spine3(org, bone, (dmg/100) * math.Rand(0,0.1), dmgInfo)
			--org.spine3 = org.spine3 + math.Rand(0.05,1) * dmg / 5
		end
	end
	
	scale = scale * (dmgInfo:IsDamageType(DMG_SLASH) and 0.1 or 1)
	
	ArmorEffect(placement, armor, dmgInfo, org, hit, prot)
	hg.HandleArmorShot(org, placement, armor, dmgInfo, hit)

	if prot < 0 then
		//dmgInfo:ScaleDamage(scale)
		return 0
	end

	dmgInfo:SetDamageType(DMG_CLUB)
	dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * 0.4)
	dmgInfo:ScaleDamage(0.2)

	return 0.9
end

ArmorEffect = function(placement, armor, dmgInfo, org, hit, prot)
	local armdata = placement and hg.armor[placement] and hg.armor[placement][armor] or {}
	local eff = prot < 0 and "Impact" or armdata.effect or "Impact"
	local dir = -dmgInfo:GetDamageForce()
	dir:Normalize()
	local effdata = EffectData()
	
	effdata:SetOrigin((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) - dir)
	effdata:SetNormal(dir)
	effdata:SetMagnitude(0.25)
	effdata:SetRadius(4)
	effdata:SetNormal(dir)
	effdata:SetStart((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) + dir)
	effdata:SetEntity(org.owner)
	effdata:SetSurfaceProp(prot < 0 and 67 or armdata.surfaceprop or 67)
	effdata:SetDamageType(dmgInfo:GetDamageType())

	EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav",dmgInfo:GetDamagePosition(),0,CHAN_AUTO,1,55,nil,100)
	util.Effect(eff,effdata)
end

local ArmorEffectEx = function(ent,dmgInfo,eff,surfaceprop)
	local dir = -dmgInfo:GetDamageForce()
	dir:Normalize()
	local effdata = EffectData()
	
	effdata:SetOrigin( dmgInfo:GetDamagePosition() - dir )
	effdata:SetNormal( dir )
	effdata:SetMagnitude(0.25)
	effdata:SetRadius(4)
	effdata:SetNormal(dir)
	effdata:SetStart(dmgInfo:GetDamagePosition() + dir)
	effdata:SetEntity(ent)
	effdata:SetSurfaceProp(surfaceprop or 67)
	effdata:SetDamageType(dmgInfo:GetDamageType())

	EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav",dmgInfo:GetDamagePosition(),0,CHAN_AUTO,1,55,nil,100)
	util.Effect(eff,effdata)
end

hg.ArmorEffect = ArmorEffect
hg.ArmorEffectEx = ArmorEffectEx

hg.organism = hg.organism or {}
hg.organism.input_list = hg.organism.input_list or {}
hg.organism.input_list.vest1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest1", 0.6, 0.6, false, ...)
	return protect
end

hg.organism.input_list.helmet1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet1", 1, 0.6, true, ...)
	return protect
end

hg.organism.input_list.helmet2 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet2", 1, 0.3, true, ...)
	return protect
end

hg.organism.input_list.helmet3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet3", 1, 0.25, true, ...)
	return protect
end

hg.organism.input_list.helmet5 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet5", 1, 0.4, true, ...)
	return protect
end

hg.organism.input_list.helmet6 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet6", 1, 0.5, true, ...)
	return protect
end

hg.organism.input_list.helmet7 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet7", 1, 0.4, true, ...)
	return protect
end

hg.organism.input_list.vest2 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest2", 1, 0.3, false, ...)
	return protect
end

hg.organism.input_list.vest3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest3", 0.8, 0.3, false, ...)
	return protect
end

hg.organism.input_list.vest4 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest4", 0.8, 0.3, false, ...)
	return protect
end

hg.organism.input_list.mask1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "face", "mask1", 1, 0.9, true, ...)
	return protect
end

hg.organism.input_list.mask3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "face", "mask3", 0.95, 0.92, true, ...)
	return protect
end

hg.organism.input_list.vest5 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest5", 0.8, 0.5, false, ...)
	return protect
end
hg.organism.input_list.vest6 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest6", 0.8, 0.4, false, ...)
	return protect
end

hg.organism.input_list.vest7 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest7", 0.8, 0.5, false, ...)
	return protect
end

hg.organism.input_list.vest8 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest8", 0.7, 0.4, false, ...)
	return protect
end
-------------------------------------------------------------------

-- Gordon's armor
hg.organism.input_list.gordon_helmet = function(org, bone, dmg, dmgInfo, ...)
	local owner = hg.GetCurrentCharacter(org.owner) or org.owner
	--if owner:GetBodygroup(2) ~= 2 then return 0 end
	--owner:SetBodygroup(2,0)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "gordon_helmet", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "gordon_armor", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_arm_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "gordon_arm_armor_left", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_arm_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "gordon_arm_armor_right", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_leg_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_leg_armor_left", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_leg_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_leg_armor_right", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_calf_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_calf_armor_left", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_calf_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_calf_armor_right", 0.5, 0.3, false, ...)
	return protect
end

-------------------------------------------------------------------

-- Combine armor
hg.organism.input_list.cmb_helmet = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "cmb_helmet", 0.8, 0.7, true, ...)
	return protect
end

hg.organism.input_list.cmb_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "cmb_armor", 0.9, 0.7, false, ...)
	return protect
end

hg.organism.input_list.cmb_arm_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "cmb_arm_armor_left", 0.9, 0.7, false, ...)
	return protect
end


hg.organism.input_list.cmb_arm_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "cmb_arm_armor_right", 0.9, 0.7, false, ...)
	return protect
end


hg.organism.input_list.cmb_leg_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "cmb_leg_armor_left", 0.9, 0.7, false, ...)
	return protect
end

hg.organism.input_list.cmb_leg_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "cmb_leg_armor_right", 0.9, 0.7, false, ...)
	return protect
end
-- metrocop armor
hg.organism.input_list.metrocop_helmet = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "metrocop_helmet", 0.9, 0.7, true, ...)
	return protect
end

hg.organism.input_list.metrocop_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "metrocop_armor", 0.9, 0.7, false, ...)
	return protect
end

-- protogen visor

hg.organism.input_list.protovisor = function(org, bone, dmg, dmgInfo, ...)
	force = true

	org.owner.armors_health = org.owner.armors_health or {}

	local protect = protec(org, bone, dmg, dmgInfo, "head", "protovisor", 0.8, 0.7, true, ...)
	
	org.owner.armors_health["protovisor"] = org.owner.armors_health["protovisor"] or 1
	org.owner.armors_health["protovisor"] = org.owner.armors_health["protovisor"] * math.max((1 - dmg * 10), 0)
	
	if org.owner.armors_health["protovisor"] == 0 then
		org.owner.armors["head"] = nil
	end
	//dmgInfo:GetAttacker():ChatPrint(tostring(org.owner.armors_health["protovisor"]))
	return protect
end

hook.Add("HG_ReplacePhrase", "MaskMuffed", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.armors and ply.armors["face"] == "mask2" then
		return ply, phrase, true, pitch
	end
end)
