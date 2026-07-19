local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local function IsJogging(ply, vel)
	local speed = vel:Length()
	if speed >= 170 and speed < 270 and hg.KeyDown(ply, IN_SPEED) and hg.KeyDown(ply, IN_FORWARD) then return true end
	if CLIENT and ply == LocalPlayer() then return ply.hg_isJogging == true end
	return ply.hg_isJogging or ply:GetNWBool("hg_isJogging", false)
end
--\\ Custom running anim rate
	hook.Add("UpdateAnimation", "NormAnimki", function(ply, vel, maxSeqGroundSpeed)
		if not IsValid(ply) or not ply:Alive() or not ply:OnGround() then return end
		local lenSqr = vel:LengthSqr()
		local jogging = IsJogging(ply, vel)
		if CLIENT and ply == LocalPlayer() then
			local target = lenSqr
			if (ply.hg_isSprinting or ply.hg_isJogging) and ply:KeyDown(IN_FORWARD) then target = math.max(target, jogging and 65000 or 90000) end
			ply.hg_animSpeedSqr = math.Approach(ply.hg_animSpeedSqr or target, target, FrameTime() * 220000)
			lenSqr = ply.hg_animSpeedSqr
		end

		if jogging then
			ply:SetPlaybackRate(0.8)
			return ply, vel, maxSeqGroundSpeed
		end

		if lenSqr >= 77000 and lenSqr < 110000 then
			ply:SetPlaybackRate(1.2)
			return ply, vel, maxSeqGroundSpeed
		end

		if lenSqr >= 77000 then
			ply:SetPlaybackRate(1.4)
			return ply, vel, maxSeqGroundSpeed
		end
	end)
--//

--\\ Custom running anim activity
	local runHoldTypes = {
		["normal"] = true,
		["slam"] = true,
		["grenade"] = true
	}

	hook.Add( "CalcMainActivity", "RunningAnim", function(ply, vel)
		local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon()
		local isAmputated = ply:IsBerserk() and ply.organism and (ply.organism.llegamputated or ply.organism.rlegamputated)
		local speed = vel:Length()
		local jogging = IsJogging(ply, vel)
		if CLIENT and ply == LocalPlayer() and (ply.hg_isSprinting or ply.hg_isJogging) and ply:KeyDown(IN_FORWARD) then speed = math.max(speed, jogging and 210 or 280) end
		if (not ply:InVehicle()) and ply:IsOnGround() and speed > 180 and wep and runHoldTypes[wep:GetHoldType()] and not isAmputated then
			local isFurry = ply.PlayerClassName == "furry"
			local anim = ACT_HL2MP_RUN_FAST
			if jogging then
				anim = ACT_HL2MP_RUN
			elseif ply:IsOnFire() then
				anim = ACT_HL2MP_RUN_PANICKED
			elseif isFurry then
				if hg.KeyDown(ply, IN_WALK) and not hg.KeyDown(ply, IN_BACK) then
					anim = ACT_HL2MP_RUN_ZOMBIE_FAST
				else
					anim = ACT_HL2MP_RUN_FAST
				end
			else
				anim = ACT_HL2MP_RUN_FAST
			end

			local sequence = jogging and ply:LookupSequence("run_all_01") or -1
			return anim, sequence >= 0 and sequence or -1
		end

		if (not ply:InVehicle()) and ply:IsOnGround() and isAmputated then
			local anim = ACT_HL2MP_WALK_ZOMBIE_06
			if vel:Length() > 250 then
				anim = ACT_HL2MP_RUN_ZOMBIE_FAST
			end
			return anim, -1
		end
	end)
--//
