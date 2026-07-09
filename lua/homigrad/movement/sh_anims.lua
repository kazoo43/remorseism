local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
--\\ Custom running anim rate
	hook.Add("UpdateAnimation", "NormAnimki", function(ply, vel, maxSeqGroundSpeed)
		if not IsValid(ply) or not ply:Alive() or not ply:OnGround() then return end

		if ply.hg_isJogging then
			ply:SetPlaybackRate(0.8)
			return ply, vel, maxSeqGroundSpeed
		end

		if vel:LengthSqr() >= 77000 and vel:LengthSqr() < 110000 then
			ply:SetPlaybackRate(1.2)
			return ply, vel, maxSeqGroundSpeed
		end

		if vel:LengthSqr() >= 77000 then
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
		if (not ply:InVehicle()) and ply:IsOnGround() and vel:Length() > 180 and wep and runHoldTypes[wep:GetHoldType()] and not isAmputated then
			local isFurry = ply.PlayerClassName == "furry"
			local anim = ACT_HL2MP_RUN_FAST
			
			if ply.hg_isJogging then
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

			return anim, -1
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