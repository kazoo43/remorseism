
local PLAYER = FindMetaTable("Player")
util.AddNetworkString("hg_headcrab")
function PLAYER:AddHeadcrab(headcrab)
	if self.PlayerClassName == "headcrabzombie" then return end
	if not self.organism then return end
    --self.organism.headcrabon = headcrab
    self:SetNetVar("headcrab",headcrab)
   
    self.organism.headcrabon = headcrab and CurTime()
	self.organism.headcrabevent = false

    --[[net.Start("hg_headcrab")
    net.WriteEntity(self)
    net.WriteString(headcrab)
    net.Broadcast()--]]
end

hook.Add("RagdollDeath","headcrab",function(ply,rag)
    rag:SetNetVar("headcrab", ply:GetNetVar("headcrab"))
    ply:SetNetVar("headcrab", false)
	ply.organism.noHead = false
end)

hook.Add("Org Clear", "removeheadcrab", function(org)
    org.headcrabon = nil
	org.headcrabevent = false
	if IsValid(org.owner) then
		org.owner:SetNetVar("headcrab", false)
	end
	org.noHead = false
end)

local fallbackMats = {
	["Rebel"] = {
		["main"] = "models/zombie_classic/zombie_classic_sheet",
		["pants"] = "models/zombie_classic/zombie_classic_sheet",
		["boots"] = "models/zombie_classic/zombie_classic_sheet",
	},
	["Metrocop"] = {
		["main"] = "models/balaclava_hood/berd_diff_018_a_uni",
		["pants"] = "models/humans/male/group02/lambda",
		["boots"] = "models/humans/male/group01/formal"
	},
	["Combine"] = {
		["main"] = "models/zombie_classic/combinesoldiersheet_zombie",
		["pants"] = "models/gruchk_uwrist/css_seb_swat/swat/gear2",
		["boots"] = "models/humans/male/group01/formal"
	},
}

local clr_red, lerpAng = Color(150, 0, 0), Angle(0, 0, 0)
hook.Add("Org Think", "Headcrab",function(owner, org, timeValue)
    if not IsValid(owner) then return end
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not org.headcrabon then return end

    local curTime = CurTime()

	if (org.headcrabon + 30) < curTime and org.brain != 1 and owner.organism.spine3 != 1 then
		local ent = hg.GetCurrentCharacter(owner) or owner
		local mul = ((org.headcrabon + 60) - curTime) / 60
		if mul > 0 and IsValid(ent) then
			local count = ent:GetPhysicsObjectCount()
			if count > 0 then
				local phys = ent:GetPhysicsObjectNum(math.random(count) - 1)
				if IsValid(phys) then phys:ApplyForceCenter(VectorRand(-750 * mul,750 * mul)) end
			end
		end
	end

	if owner:IsPlayer() then
			owner.noHead = true
			owner:SetNWString("PlayerName", "Body with headcrab")
			org.brain = 0.3

			if org.alive then
				lerpAng = LerpAngle(FrameTime() * 3, lerpAng, AngleRand(-90, 90))
				lerpAng.r = 0
				owner:SetEyeAngles(owner:EyeAngles() + lerpAng)
			end

			if (org.headcrabon + 60) < curTime and org.alive and not org.headcrabevent then
				owner:EmitSound("npc/zombie/zombie_alert" .. math.random(3) .. ".wav", 80, math.random(60, 70))
				owner:EmitSound("neck_snap_01.wav", 80, 80, 1, CHAN_AUTO)
				owner:SetPlayerClass("headcrabzombie")
				org.painadd = org.painadd + 5

				hg.StunPlayer(owner, 5)
				if zb and zb.GiveRole then
					zb.GiveRole(owner, "Zombie", clr_red)
				end

				org.headcrabevent = true
				org.headcrabon = nil
				org.headcrabevent = false
				org.noHead = false

				hg.FakeUp(owner, true)
				owner:SetNetVar("headcrab", false)
			end

        if org.alive and org.headcrabon and (org.headcrabon + 20) < curTime then
			if (org.headcrabon + 30) > curTime then
				owner:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 80, math.random(80, 90))
				org.painadd = org.painadd + 15
				hg.StunPlayer(owner, 5)
			end
		end

        if org.alive and org.headcrabon and (org.headcrabon + 60) < curTime then
			owner:SetNWString("PlayerName", "Body with headcrab")
			org.alive = false
		end
    end
end)
