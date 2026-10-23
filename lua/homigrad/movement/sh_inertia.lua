local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local math_abs, math_Approach, math_AngleDifference, math_Clamp, math_cos, math_deg, math_max, math_min, math_rad, math_Round, math_sin, math_sqrt = math.abs, math.Approach, math.AngleDifference, math.Clamp, math.cos, math.deg, math.max, math.min, math.rad, math.Round, math.sin, math.sqrt
--\\ Inertia & stuff
	--\\ Antibhop accelerate (not used anyway)
		--[[hook.Add("OnPlayerHitGround", "Movement", function(ply, inWater, onFloater, speed)
			local vel = ply:GetVelocity()

			if (ply.MovementInertia and vel:LengthSqr() > 10000) then
				ply.MovementInertia = ply.MovementInertia + (vel / vel:Length() * math.abs(vel[3])) * 0.75
			end
		end)]]
	--//

	--\\ Side movement calculation
		local function calc_vector2d_angle(vector)
			return math_deg(math.atan2(vector.y, vector.x))
		end

		local function calc_forward_side_moves(inertia, ply_angles)
			local ply_angle = ply_angles.y
			local inertia_angle = calc_vector2d_angle(inertia)
			local angdiff = math_AngleDifference(inertia_angle, ply_angle)

			local rad = math_rad(angdiff)
			return math_cos(rad), -math_sin(rad)
		end

		local function calc_forward_side_moves_to_vector2d(fm, sm, ply_angles)
			local rad = math_rad(ply_angles.y)
			--ply_angle = ply_angle + (CLIENT and offsetView[2] or 0)
			local sin, cos = math_sin(rad), math_cos(rad)
			local x = fm * cos + sm * sin
			local y = fm * sin - sm * cos
			local len = math_sqrt(x * x + y * y)

			if len <= 0 then return vector_origin end
			return Vector(x / len, y / len, 0)
		end

		local function approach_vector(vector_from, vector_to, change)
			return Vector(math_Approach(vector_from.x, vector_to.x, change), math_Approach(vector_from.y, vector_to.y, change), math_Approach(vector_from.z, vector_to.z, change))
		end

		local function approach_vector_smooth(vector_from, vector_to, lerp)
			return Vector(Lerp(lerp, vector_from.x, vector_to.x), Lerp(lerp, vector_from.y, vector_to.y), Lerp(lerp, vector_from.z, vector_to.z))
		end

		hg.approach_vector = approach_vector
	--//

	local hg_movement_stamina_debuff = CreateConVar("hg_movement_stamina_debuff", "0.3", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply movement debuff when having low stamina", 0, 1)
	local hg_inertiamul = CreateConVar("hg_inertiamul", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply inertia for player movement", 0.01, 5)
	local hg_inertiaenabled = CreateConVar("hg_inertiaenabled", "0", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Enable inertia", 0, 1)
	local hg_divejump = CreateConVar("hg_divejump", "0", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Toggle dive jumps on crouch jump", 0, 1)
	local hg_movement_speed_gain_mul = CreateConVar("hg_movement_speed_gain_mul", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply speed gain", 0.01, 5)
	local hg_movement_speed_lose_mul = CreateConVar("hg_movement_speed_lose_mul", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply speed lose", 0.01, 5)
	local hg_movement_lagcomp = CreateConVar("hg_movement_lagcomp", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Compensate movement inertia for latency", 0, 1)
	local function hg_GetMovementLagComp(ply)
		if not hg_movement_lagcomp:GetBool() or not IsValid(ply) then return 1, 0 end

		local ping_time = math.Clamp(ply:Ping() / 1000, 0, 0.12)

		return math.Clamp(1 - ping_time * 1.25, 0.82, 1), ping_time
	end
	local sprint_collision_trace_mins = Vector(-12, -12, -20)
	local sprint_collision_trace_maxs = Vector(12, 12, 20)
	local sprint_collision_up = Vector(0, 0, 1)
	local sprint_collision_force_mul = 0.55
	local sprint_collision_torso_force_mul = 0.4
	local sprint_collision_upward_mul = 0.2
	local sprint_collision_full_speed_mul = 0.98
	local sprint_collision_trip_chance = 3
	local sprint_collision_stumble_slowdown = 450
	local sprint_collision_stumble_time = 0.18
	local sprint_collision_damage_mul = 0.08
	local sprint_collision_damage_time = 0.9
	local sprint_collision_sounds = {
		"raminto/ram1.wav",
		"raminto/ram2.wav",
		"raminto/ram3.wav"
	}

	local function hg_NoJogging(ply)
		return IsValid(ply) and ply:GetInfoNum("hg_nojogging", 0) >= 1
	end

	local function hg_GetSprintCollisionPhysBone(ply, hitPos)
		local localHit = ply:WorldToLocal(hitPos)
		local boneName = "ValveBiped.Bip01_Spine2"

		if localHit.z >= 54 then
			boneName = "ValveBiped.Bip01_Head1"
		elseif localHit.z <= 20 then
			boneName = localHit.y >= 0 and "ValveBiped.Bip01_L_Thigh" or "ValveBiped.Bip01_R_Thigh"
		elseif localHit.y >= 12 then
			boneName = "ValveBiped.Bip01_L_UpperArm"
		elseif localHit.y <= -12 then
			boneName = "ValveBiped.Bip01_R_UpperArm"
		end

		local bone = ply:LookupBone(boneName)
		local physbone = bone and ply:TranslateBoneToPhysBone(bone) or 0

		if not physbone or physbone < 0 then
			boneName = "ValveBiped.Bip01_Spine2"
			bone = ply:LookupBone(boneName)
			physbone = bone and ply:TranslateBoneToPhysBone(bone) or 0
		end

		return physbone, boneName
	end

	local function hg_PlaySprintCollisionSound(ply)
		if not SERVER or not IsValid(ply) then return end
		ply:EmitSound(sprint_collision_sounds[math.random(#sprint_collision_sounds)], 75, math.random(96, 104), 1)
	end

	local function hg_TriggerSprintCollisionRagdoll(ply, tr, vel, impactSpeed)
		if not SERVER or not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end

		ply.hgSprintCollisionCooldown = CurTime() + 0.45
		hg_PlaySprintCollisionSound(ply)

		local hitEnt = tr.Entity
		local impactDir

		if IsValid(hitEnt) and hitEnt:IsPlayer() then
			impactDir = ply:WorldSpaceCenter() - hitEnt:WorldSpaceCenter()
		else
			impactDir = -tr.HitNormal
		end

		if impactDir:LengthSqr() <= 0.001 then
			impactDir = -vel:GetNormalized()
		end

		impactDir.z = math.max(impactDir.z, 0.18)
		impactDir:Normalize()

		local hitPhysbone, hitBoneName = hg_GetSprintCollisionPhysBone(ply, tr.HitPos)
		local torsoBone = ply:LookupBone("ValveBiped.Bip01_Spine2")
		torsoBone = torsoBone and ply:TranslateBoneToPhysBone(torsoBone) or 0

		local clampedImpact = math.Clamp(impactSpeed, 0, 260)
		local hitMass = hg.IdealMassPlayer[hitBoneName] or 4
		local torsoMass = hg.IdealMassPlayer["ValveBiped.Bip01_Spine2"] or 4
		local contactForce = impactDir * clampedImpact * hitMass * sprint_collision_force_mul
		local torsoForce = impactDir * clampedImpact * torsoMass * sprint_collision_torso_force_mul + sprint_collision_up * clampedImpact * torsoMass * sprint_collision_upward_mul

		ply.hgSprintCollisionDamageMul = sprint_collision_damage_mul
		ply.hgSprintCollisionDamageUntil = CurTime() + sprint_collision_damage_time
		hg.AddForceRag(ply, hitPhysbone, contactForce, 0.25)
		hg.AddForceRag(ply, torsoBone, torsoForce, 0.25)
		hg.LightStunPlayer(ply, 1.35)
	end

	local function hg_TriggerSprintCollisionStumble(ply)
		if not SERVER or not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end

		ply.hgSprintCollisionCooldown = CurTime() + 0.35
		hg_PlaySprintCollisionSound(ply)
		ply:SetNetVar("slowDown", sprint_collision_stumble_slowdown)
		ply:ViewPunch(Angle(math.random(2) == 1 and -18 or 18, math.random(-2, 2), math.random(-4, 4)))

		timer.Create("hg_sprint_collision_slowdown_" .. ply:EntIndex(), sprint_collision_stumble_time, 1, function()
			if not IsValid(ply) then return end
			if ply:GetNetVar("slowDown", 0) <= sprint_collision_stumble_slowdown then
				ply:SetNetVar("slowDown", 0)
			end
		end)
	end

	hg.TriggerSprintCollisionRagdoll = hg_TriggerSprintCollisionRagdoll
	hg.TriggerSprintCollisionStumble = hg_TriggerSprintCollisionStumble

	local function hg_CheckSprintCollisionRagdoll(ply, vel, velLen)
		if not SERVER or not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end
		local curTime = CurTime()
		if ply.hgSprintCollisionNextCheck and ply.hgSprintCollisionNextCheck > curTime then return end
		ply.hgSprintCollisionNextCheck = curTime + 0.08
		if ply.hgSprintCollisionCooldown and ply.hgSprintCollisionCooldown > curTime then return end
		if ply.hg_LastLandingTime and ply.hg_LastLandingTime + 0.35 > curTime and ply:Ping() >= 45 then return end
		if ply:InVehicle() or ply:GetMoveType() != MOVETYPE_WALK or ply:WaterLevel() >= 2 then return end
		if not (ply.hg_isSprinting or (not ply:OnGround() and ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD))) then return end
		local lag_comp_mul, lag_comp_time = hg_GetMovementLagComp(ply)
		if velLen < 215 / lag_comp_mul then return end

		local fullSpeed = math.max(ply:GetRunSpeed(), ply.move or 0)
		if velLen < fullSpeed * math.Clamp(sprint_collision_full_speed_mul / lag_comp_mul, 0.78, sprint_collision_full_speed_mul) then return end

		local dir = vel:GetNormalized()
		if dir:LengthSqr() <= 0.001 then return end

		local tr = util.TraceHull({
			start = ply:WorldSpaceCenter(),
			endpos = ply:WorldSpaceCenter() + dir * math.Clamp(velLen * (engine.TickInterval() * 1.5 + lag_comp_time * 0.25), 18, 48),
			mins = sprint_collision_trace_mins,
			maxs = sprint_collision_trace_maxs,
			filter = {ply, ply:GetVehicle()},
			mask = MASK_PLAYERSOLID
		})

		if not tr.Hit or tr.HitSky or tr.StartSolid then return end

		local hitEnt = tr.Entity
		local impactSpeed = math.abs(vel:Dot(-tr.HitNormal))
		local shouldTrip = math.random(sprint_collision_trip_chance) == 1

		if IsValid(hitEnt) and hitEnt:IsPlayer() and hitEnt:Alive() then
			impactSpeed = (vel - hitEnt:GetVelocity()):Length()
			if impactSpeed >= 170 / lag_comp_mul then
				if shouldTrip then
					hg_TriggerSprintCollisionRagdoll(ply, tr, vel, impactSpeed)
				else
					hg_TriggerSprintCollisionStumble(ply)
				end
			end
			return
		end

		if IsValid(hitEnt) then
			local phys = hitEnt:GetPhysicsObject()
			if IsValid(phys) and phys:GetMass() < 8 then return end
		end

		if impactSpeed <= 0 then
			impactSpeed = velLen
		end

		if impactSpeed >= ((ply:OnGround() and 200 or 160) / lag_comp_mul) then
			if shouldTrip then
				hg_TriggerSprintCollisionRagdoll(ply, tr, vel, impactSpeed)
			else
				hg_TriggerSprintCollisionStumble(ply)
			end
		end
	end


	local vomitVPAng, vecZero = Angle(1, 0, 0), Vector()
	hook.Add("SetupMove", "HG(StartCommand)", function(ply, mv, cmd)
		local curTime = CurTime()
		local sysTime = SysTime()
		--\\ DeltaTime
			ply.LastStartCommand = ply.LastStartCommand or sysTime
		local tick_interval = engine.TickInterval()
		local delta_time = math_Clamp(sysTime - ply.LastStartCommand, 0, tick_interval * 1.25)--FrameTime()
			ply.LastStartCommand = sysTime
		--//

		if(not IsValid(ply) or not ply:Alive())then
			return
		end

		local org = ply.organism

		if( ( not org ) or ( not org.brain ) )then
			return
		end

		if !hg.RagdollCombatInUse(ply) and (IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdollOld"))) then
			if IsValid(ply.FakeRagdoll) then
				cmd:SetForwardMove(0)
				cmd:SetSideMove(0)

				mv:SetForwardSpeed(0)
				mv:SetSideSpeed(0)
			end

			mv:SetForwardSpeed(math.min(mv:GetForwardSpeed(), 50))
			mv:SetSideSpeed(math.min(mv:GetSideSpeed(), 50))

			cmd:RemoveKey(IN_JUMP)
			mv:RemoveKey(IN_JUMP)

			cmd:AddKey(IN_DUCK)
			mv:AddKey(IN_DUCK)

			if ply.MovementInertia then
				ply.MovementInertia:Zero()
			end
		end

		local moveType = ply:GetMoveType()
		if (moveType == MOVETYPE_NOCLIP) then
			hook.Run("HG_MovementCalc", vecZero, 0, 1, ply, cmd, mv)
			local mulTable = ply.hg_movement_mul or {1}
			ply.hg_movement_mul = mulTable
			mulTable[1] = 1
			hook.Run("HG_MovementCalc_2", mulTable, ply, cmd, mv)

			return
		end

		local inVehicle = ply:InVehicle()
		if(inVehicle)then
			return
		end

		local tickCount = cmd:TickCount()
		local move_time = tickCount > 0 and tickCount * tick_interval or curTime
		local in_speed = cmd:KeyDown(IN_SPEED)
		local crouching = ply:Crouching()
		local slow_walk_speed = ply:GetSlowWalkSpeed()
		local runnin_held = in_speed and not crouching and cmd:KeyDown(IN_FORWARD)
		local no_jogging = hg_NoJogging(ply)
		local command_number = cmd:CommandNumber()
		local process_input = command_number <= 0 or command_number > (ply.hg_LastMovementCommand or -1)

		if process_input then
			local speed_pressed = in_speed and not ply.was_in_speed
			ply.was_in_speed = in_speed
			ply.hg_LastMovementCommand = command_number

			if speed_pressed then
				if no_jogging or (ply.lastInSpeed and move_time - ply.lastInSpeed < 0.3) then
					ply.isSprintingState = true
					if (ply.CurrentSpeed or 0) <= slow_walk_speed * 1.5 then
						ply.sprintDebuff = move_time + 0.3
					end
				end
				ply.lastInSpeed = move_time
			end

			if not in_speed then
				ply.isSprintingState = false
			end
		end

		ply.hg_isSprinting = runnin_held and (ply.isSprintingState or no_jogging)
		ply.hg_isJogging = runnin_held and not ply.hg_isSprinting

		if SERVER then
			if ply.hg_LastIsSprinting ~= ply.hg_isSprinting then
				ply.hg_LastIsSprinting = ply.hg_isSprinting
				ply:SetNWBool("hg_isSprinting", ply.hg_isSprinting)
			end
			if ply.hg_LastIsJogging ~= ply.hg_isJogging then
				ply.hg_LastIsJogging = ply.hg_isJogging
				ply:SetNWBool("hg_isJogging", ply.hg_isJogging)
			end
		end

		local runnin = ply.hg_isSprinting or ply.hg_isJogging

		--[[if runnin then
			mv:SetSideSpeed(0) --meh
			cmd:SetSideMove(0)
			cmd:RemoveKey(IN_BACK)
		end]]

		if not IsValid(ply.FakeRagdoll) and ply:KeyDown(IN_SPEED) and not crouching and ply:KeyDown(IN_BACK) then
			cmd:RemoveKey(IN_SPEED)
		end

		local wep = ply:GetActiveWeapon()
		local vel = ply:GetVelocity()
		local velLen = vel:Length()
		local on_ground = ply:OnGround()
		if not on_ground then
			ply.hg_WasAirborne = true
		elseif ply.hg_WasAirborne then
			ply.hg_LastLandingTime = curTime
			ply.hg_WasAirborne = false
		end
		hg_CheckSprintCollisionRagdoll(ply, vel, velLen)
		local brainSway = org.brain and org.brain > 0.1 and math_sin(curTime / 2) or 1
		local fm = cmd:GetForwardMove() * brainSway
		local sm = cmd:GetSideMove() * brainSway

		local slow_walking = ply:KeyDown(IN_WALK)
		local aiming = ply:KeyDown(IN_ATTACK2) and wep and IsValid(wep) and ishgweapon(wep)
		local walk_speed = ply:GetWalkSpeed()
		local crouch_walk_speed = ply:GetCrouchedWalkSpeed()
		local run_speed = ply:GetRunSpeed()
		local weightmul = hg.CalculateWeight(ply, 140)
		local rag = hg.GetCurrentCharacter(ply)
		ply.weightmul = weightmul
		weightmul = math.max(weightmul > 0.9 and 1 or weightmul / 0.9, 0.1)

		--\\ Experimental pz-like sprint code
			--[[ply:SetRunSpeed((IsValid(wep) and wep ~= NULL and wep:GetClass() == "weapon_hands_sh" and slow_walking) and 390 or 230)
			if IsValid(wep) and wep ~= NULL and wep:GetClass() == "weapon_hands_sh" and runnin and slow_walking then
				mv:SetSideSpeed(0)
				cmd:SetSideMove(0)
				cmd:RemoveKey(IN_BACK)
			end]]
		--//

		--ply:SetRunSpeed(350)

		if ply:GetNWBool("TauntHolsterWeapons", false) then
			if IsValid(ply:GetWeapon("weapon_hands_sh")) then
				cmd:SelectWeapon(ply:GetWeapon("weapon_hands_sh"))
				if SERVER then ply:SelectWeapon(ply:GetWeapon("weapon_hands_sh")) end
			end
		end

		if org.brain and org.brain > 0.05 then
			local brainadjust = org.brain > 0.05 and math_Clamp(((org.brain - 0.05) * math_sin(curTime + 10) * 20), -2, 2) or 0

			if brainadjust > 1 then
				local in_jump = cmd:KeyDown(IN_JUMP)

				if in_jump then
					cmd:RemoveKey(IN_JUMP)
					cmd:AddKey(IN_DUCK)
					mv:RemoveKey(IN_JUMP)
					mv:AddKey(IN_DUCK)
				end
			end

			if brainadjust < -1 then
				local in_duck = cmd:KeyDown(IN_DUCK)

				if in_duck then
					cmd:RemoveKey(IN_DUCK)
					cmd:AddKey(IN_JUMP)
					mv:RemoveKey(IN_DUCK)
					mv:AddKey(IN_JUMP)
				end
			end
		end

		local vomitingEnd = ply:GetNetVar("vomiting", 0)
		if vomitingEnd > curTime then
			cmd:AddKey(IN_DUCK)
			mv:AddKey(IN_DUCK)
			if ply == lply then ViewPunch(vomitVPAng) end
		end

		--\\ Running
		ply.CurrentSpeed = ply.CurrentSpeed or walk_speed
		ply.CurrentFrictionMul = ply.CurrentFrictionMul or 1
		ply.FrictionGainMul = 0.01
		ply.FrictionLoseMul = 0.2

		ply.SpeedGainMul = 240 * weightmul * (ply.organism.superfighter and 5 or 1) * (ply:GetNWInt("SpeedGainClassMul", 1) or 1)
		ply.SpeedGainMul = ply.SpeedGainMul * hg_movement_speed_gain_mul:GetFloat()

		ply.SpeedLoseMul = 10000
		ply.SpeedLoseMul = ply.SpeedLoseMul * hg_movement_speed_lose_mul:GetFloat()

		ply.SpeedSharpLoseMul = 0.007
		ply.InertiaBlend = 2000 * weightmul * (ply.organism.superfighter and 100 or 1)
		ply.DuckingSlowdown = ply.DuckingSlowdown or 0
		-- ply.InertiaBlend = 15 * weightmul * ply.CurrentFrictionMul
		local inertia_blend_mul = 1

		if(velLen <= slow_walk_speed)then
			inertia_blend_mul = 1
		end

		--[[
		if ply.WasDucking and not ply:KeyDown(IN_DUCK) then
			ply.WasDucking = false
			ply.DuckingSlowdown = math.Approach(ply.DuckingSlowdown,5,delta_time * 5000)
		end

		ply:SetDuckSpeed(0.4 * (5 - ply.DuckingSlowdown) / 5)
		ply:SetUnDuckSpeed(0.4 * (5 - ply.DuckingSlowdown) / 5)

		ply.WasDucking = ply:KeyDown(IN_DUCK)
		ply.DuckingSlowdown = math.Approach(ply.DuckingSlowdown,0,-delta_time * 1)
		--]]

		ply.InertiaBlend = ply.InertiaBlend * inertia_blend_mul

		hook.Run("HG_MovementCalc", vel, velLen, weightmul, ply, cmd, mv)

		local target_run_speed = ply.hg_isJogging and (run_speed * 0.55) or run_speed
		local mulTable = ply.hg_movement_mul or {1}
		ply.hg_movement_mul = mulTable
		mulTable[1] = (ply.move or ply.CurrentSpeed) / target_run_speed

		hook.Run("HG_MovementCalc_2", mulTable, ply, cmd, mv)

		local mul = mulTable[1]

		if mul <= 0.01 then
			mul = 0.01
		end

		local tauntStopMoving = ply:GetNWBool("TauntStopMoving", false)
		mul = mul * (tauntStopMoving and 0.01 or 1)

		if ply.hg_isSprinting and runnin and velLen >= 10 then
			local sprint_mul = ply.sprintDebuff and ply.sprintDebuff > move_time and 0.5 or 1
			ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, (ply.move or run_speed) * mul * sprint_mul, delta_time * ply.SpeedGainMul)
		elseif ply.hg_isJogging and runnin and velLen >= 10 then
			ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, (ply.move or (run_speed * 0.55)) * mul, delta_time * ply.SpeedGainMul)
		else
			if(crouching)then
				ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, crouch_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			elseif(slow_walking)then
				ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			elseif(aiming)then
				ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			else
				ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, walk_speed * mul, delta_time * ply.SpeedLoseMul)
			end
		end
		--//

		--\\ Speed acceleration & deceleration
		ply.LastVelocity = ply.LastVelocity or vel
		ply.LastVelocityLen = ply.LastVelocityLen or velLen
		local vel1 = velLen
		local vel2 = ply.LastVelocityLen

		if(vel1 == 0)then
			vel1 = 1
		end

		if(vel2 == 0)then
			vel2 = 1
		end

		local change = math_abs(math_AngleDifference(calc_vector2d_angle(ply.LastVelocity), calc_vector2d_angle(vel))) // * (SERVER and 0 or 5)

		if ply.LastVelocity == vel and ply.LastChangeVelocity then // this is so bullshit but it works
			change = ply.LastChangeVelocity
		end

		local change_mul = math_abs(ply.CurrentSpeed - slow_walk_speed)

		ply.LastChangeVelocity = change
		ply.CurrentSpeed = math_Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * change * change_mul * ply.SpeedSharpLoseMul * 0.25 * 200)
		ply.LastVelocity = vel
		ply.LastVelocityLen = velLen
		--//

		local speed = ply.CurrentSpeed
		--\\ Inertia
		local ply_angles = cmd:GetViewAngles()

		ply.MovementInertia = ply.MovementInertia or vel

		--\\ Side & back running debuffs
			fm = fm / math_abs(fm ~= 0 and fm or 1)
			sm = sm / math_abs(sm ~= 0 and sm or 1)
			local movement_penalty = math_abs(sm * 1.2)

			if(movement_penalty == 0)then
				movement_penalty = 1
			end

			if(fm < 0)then
				movement_penalty = math_max(movement_penalty, 1.3)
			end

			--if(CLIENT)then
				speed = speed / movement_penalty
			--end
		--//

		local inertia_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles) * speed
		--\\ Air & water walking debuffs
			local water_level = ply:WaterLevel()

			if((not on_ground) and (water_level < 1))then
				if(fm ~= 0 or sm ~=0)then
					local start_pos = ply:GetPos()
					local trace_data = ply.hg_inertia_air_trace or { filter = ply }
					ply.hg_inertia_air_trace = trace_data
					trace_data.start = start_pos
					trace_data.endpos = start_pos + inertia_to / speed * 50
					trace_data.filter = ply

					if(util.TraceLine(trace_data).Hit)then
						movement_penalty = 1
					else
						movement_penalty = 5
					end

					--if(CLIENT)then
						speed = speed / movement_penalty
					--end

					inertia_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles) * speed
				end
			end
		--//

		--\\ Friction
			local consciousness = 1

			if ply.organism and ply.organism.consciousness then
				consciousness = consciousness * ply.organism.consciousness
				consciousness = consciousness * math_Clamp(ply.organism.blood / 4000, 0.5, 1)
			end

			local consmul = math_Clamp(((consciousness - 1) * 4 + 1), 0.1, 1)

			//if(water_level > 0)then
			//	ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, 0.2, delta_time * ply.FrictionLoseMul * water_level)
			//else
				// ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, consmul, delta_time * ply.FrictionGainMul * (consmul < ply.CurrentFrictionMul and 100 or 10))
			//end

			ply.CurrentFrictionMul = 0.5 / hg_inertiamul:GetFloat()
			ply.InertiaBlend = ply.InertiaBlend * ply.CurrentFrictionMul

			-- local new_inertia = LerpVector(0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
			-- local new_inertia = LerpVector(1 - 0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
			//local new_inertia = approach_vector(ply.MovementInertia, inertia_to, 1000)//SERVER and delta_time * ply.InertiaBlend * ply:Ping() / 100 or delta_time * ply.InertiaBlend)
			//local new_inertia = approach_vector_smooth(ply.MovementInertia, inertia_to, hg.lerpFrameTime2(0.075, delta_time))
		if !on_ground then
			ply.MovementInertia = ply.LastVelocity
			local ping = ply:Ping()
			if ping >= 45 and ply.MovementInertia:Length2D() > run_speed * 1.25 then
				ply.MovementInertia = ply.MovementInertia:GetNormalized() * run_speed * 1.25
			end
			end

			local new_inertia = approach_vector(ply.MovementInertia, inertia_to, delta_time * ply.InertiaBlend)

			ply.MovementInertia = new_inertia

			local inertia_len = math_sqrt(ply.MovementInertia.x * ply.MovementInertia.x + ply.MovementInertia.y * ply.MovementInertia.y)

			/*if (SERVER or (ply.huy or 0) < SysTime()) and inertia_len > 10 then
				if CLIENT then ply.huy = SysTime() + engine.ServerFrameTime() end
				print(new_inertia, inertia_to)
			end*/

			local forward_move, side_move = calc_forward_side_moves(ply.MovementInertia, ply_angles)

			if(CLIENT)then
				ply.MovementInertiaAddView = ply.MovementInertiaAddView or Angle(0,0,0)
				ply.MovementInertiaAddView.r = ply.MovementInertiaAddView.r + side_move * delta_time * inertia_len * 0.03
				ply.MovementInertiaAddView.p = ply.MovementInertiaAddView.p + math_abs(side_move) * delta_time * inertia_len * 0.01
			end
		--//

		local move = (ply.hg_isJogging and (run_speed * 0.55) or run_speed) * 1.1
		local k = 1 * weightmul
		k = k * math_Clamp(consmul, 0.7, 1)
		k = k * math_Clamp((org.temperature and (1 - (org.temperature - 38) * 0.25) or 1), 0.5, 1)
		k = k * math_Clamp((org.temperature and ((org.temperature - 35) * 0.25 + 1) or 1), 0.5, 1)
		k = k * math_Clamp(math_Round((org.stamina and org.stamina[1] or 180), 0) / 120, hg_movement_stamina_debuff:GetFloat(), 1)
		k = k * math_Clamp(5 / ((org.immobilization or 0) + 1), 0.25, 1)
		k = k * math_Clamp((org.blood or 0) / 5000, 0, 1)
		k = k * math_Clamp(10 / ((org.shock or 0) + 1), 0.25, 1)
		k = k * (math_min(math_Round((org.adrenaline or 0), 1) / 24, 0.3) + 1)
		k = k * math_Clamp((org.lleg and org.lleg >= 0.5 and math_max(1 - org.lleg, 0.6) or 1) * (org.lleg and org.rleg >= 0.5 and math_max(1 - org.rleg, 0.6) or 1) * ((org.analgesia * 1 + 1)), 0, 1)
		k = k * (org.llegdislocation and 0.75 or 1) * (org.rlegdislocation and 0.75 or 1)
		k = k * (org.pelvis == 1 and 0.4 or 1)
		local carryent = ply:GetNetVar("carryent")
		local carryent2 = ply:GetNetVar("carryent2")
		local validCarryEnt = IsValid(carryent)
		local validCarryEnt2 = IsValid(carryent2)
		k = k * ((validCarryEnt or validCarryEnt2) and math_Clamp(50 / math_max(ply:GetNetVar("carrymass", 0) + ply:GetNetVar("carrymass2", 0), 1), 0.5, 1) or 1)
		k = k * math_Clamp(20 / ((org.pain or 0) + 1), 0.01, 1)
		//k = k * (ishgweapon(wep) and not wep:IsPistolHoldType() and not wep:ReadyStance() and 0.75 or 1)

		local slwdwn = ply:GetNetVar("slowDown", 0)
		if(slwdwn > 0)then
			//if(SERVER)then
				//ply:SetNetVar("slowDown", math.Approach(slwdwn, 0, delta_time * 250))
			//end
			k = k * math_Clamp((250 - slwdwn) / 250, 0.75, 1)
		end

		k = math_max(k, 20 / 200)

		if vomitingEnd > (curTime - 3) then
			k = k * 0.25
		end

		if ply:GetNWBool("selfharming", false) then
			k = k * 0.3
		end

		local ent = validCarryEnt and carryent or validCarryEnt2 and carryent2

		if SERVER and inertia_len > 5 and (ply.hg_isSprinting or ply.hg_isJogging) then
			local mul = math_Clamp(inertia_len / 200, 0.5, 1) * 5 * (crouching and 0.01 or 1)
			if ply == rag then
				if org.pelvis == 1 then
					org.painadd = org.painadd + FrameTime() * mul
				end
				if (org.lleg == 1) or org.llegdislocation then
					org.painadd = org.painadd + FrameTime() * mul
				end

				if (org.rleg == 1) or org.rlegdislocation then
					org.painadd = org.painadd + FrameTime() * mul
				end
			end
		end

		if IsValid(ent) then
			local carrybone = ply:GetNetVar("carrybone",0)
			local bon = carrybone ~= 0 and carrybone or ply:GetNetVar("carrybone2",0)
			local bone = ent:TranslatePhysBoneToBone(bon)
			local mat = ent:GetBoneMatrix(bone)
			local pos = mat and mat:GetTranslation() or ent:GetPos()
			local lpos = validCarryEnt and ply:GetNetVar("carrypos",nil) or ply:GetNetVar("carrypos2",nil)

			if lpos then
				if not ent:IsRagdoll()then
					pos = ent:LocalToWorld(lpos)
				else
					pos = LocalToWorld(lpos, angle_zero, mat:GetTranslation(), mat:GetAngles())
				end
			end

			local eyetr = hg.eyeTrace(ply)
			local dist = pos:DistToSqr(eyetr.StartPos)
			local reachdist = weapons.GetStored("weapon_hands_sh").ReachDistance + 30
			if dist > reachdist*reachdist then
				local moving_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles)
				local dot = moving_to:Dot((pos - eyetr.StartPos):GetNormalized())
				k = k * dot
			end
		end

		move = move * k
		ply.move = move

		if SERVER and not IsValid(ply.FakeRagdoll) then
			local eyeAngles = ply:EyeAngles()
			ply.eyeAnglesOld = ply.eyeAnglesOld or eyeAngles
			local cosine = eyeAngles:Forward():Dot(ply.eyeAnglesOld:Forward())
			ply.eyeAnglesOld = eyeAngles

			if (velLen > 200 and (math.random(150) == 1 or cosine <= 0.99)) then
				local trData = ply.hg_inertia_slip_trace or { filter = ply }
				ply.hg_inertia_slip_trace = trData
				trData.start = ply:GetPos()
				trData.endpos = trData.start - vector_up * 1
				trData.filter = ply
				local tr = util.TraceLine(trData)

				if tr.SurfaceProps and util.GetSurfaceData(tr.SurfaceProps) and util.GetSurfaceData(tr.SurfaceProps).friction < 0.2 then
					local b1 = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_L_Calf"))
					local phys1 = hg.IdealMassPlayer["ValveBiped.Bip01_L_Calf"]

					local b2 = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_R_Calf"))
					local phys2 = hg.IdealMassPlayer["ValveBiped.Bip01_R_Calf"]

					local torso = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_Spine2"))
					local phystorso = hg.IdealMassPlayer["ValveBiped.Bip01_Spine2"]
					local force = vel:GetNormalized() * 150

					hg.AddForceRag(ply, torso, -force * 5 * phystorso, 0.5)
					hg.AddForceRag(ply, b1, (force * 5 - vector_up * 2) * phys1, 0.5)
					hg.AddForceRag(ply, b2, (force * 5 - vector_up * 2) * phys2, 0.5)

					timer.Simple(0,function()
						hg.StunPlayer(ply)
					end)
				end
			end
		end

		--// Dive jump
		if hg_divejump:GetBool() then
			ply.lastInDuck = ply:KeyPressed(IN_DUCK) and curTime or ply.lastInDuck or 0
			ply.lastInJump = ply:KeyPressed(IN_JUMP) and curTime or ply.lastInJump or 0
			if(SERVER && rag == ply && (ply.lastInJump + 0.1 > curTime) && (ply.lastInDuck + 0.1 > curTime))then
				local force = ply:GetAimVector() * 400
				force[3] = 0
				local torso = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_Spine2"))
				local phystorso = hg.IdealMassPlayer["ValveBiped.Bip01_Spine2"]
				hg.AddForceRag(ply, torso, force * phystorso, 0.5)
				hg.Fake(ply)
			end
		end

		--print(speed.." "..(CLIENT and "c" or "s"))
		--speed = SERVER and speed + 50 or speed

		if moveType == MOVETYPE_LADDER or moveType == MOVETYPE_NONE then
			inertia_len = 100
		end

		if org.noradrenaline and org.noradrenaline > 0 and inertia_len > 0 then
			inertia_len = inertia_len + 200 * math_Round(org.noradrenaline, 1)
		end

		if CLIENT and ply:Ping() >= 45 and ply.hg_LastLandingTime and ply.hg_LastLandingTime + 0.35 > curTime then
			inertia_len = math_min(inertia_len, run_speed * 1.1)
		end
		
		mv:SetMaxSpeed(inertia_len)
		mv:SetMaxClientSpeed(inertia_len)
		ply:SetMaxSpeed(math_max(100, inertia_len))
		ply:SetJumpPower(DEFAULT_JUMP_POWER * math_min(k, 1.1) * (not tauntStopMoving and 1 or 0) * (ply.organism.superfighter and 1.5 or 1) * (ply.JumpPowerMul or 1))

		if(CLIENT)then
			local fwangs = math_rad(GetViewPunchAngles2()[2] + GetViewPunchAngles3()[2])

			forward_move = forward_move * math_cos(fwangs) + side_move * math_sin(fwangs)
			side_move = side_move * math_cos(fwangs) + forward_move * math_sin(fwangs)

			cmd:SetForwardMove(forward_move * inertia_len)
			cmd:SetSideMove(side_move * inertia_len)
		end

		if hg_inertiaenabled:GetBool() then
			mv:SetForwardSpeed(forward_move * inertia_len)
			mv:SetSideSpeed(side_move * inertia_len)
		end
	end)
--//

--\\ Remove sandbox jump boost
	local gamemod = engine.ActiveGamemode()
	hook.Add("PlayerSpawn", "RemoveSandboxJumpBoost", function(ply)
		if (gamemod != "sandbox") then return end

		local PLAYER = baseclass.Get("player_sandbox")

		PLAYER.FinishMove           = nil       -- Disable boost
		PLAYER.StartMove           	= nil       -- Disable boost
		PLAYER.SlowWalkSpeed		= 100		-- How fast to move when slow-walking (+WALK)
		PLAYER.WalkSpeed			= 190		-- How fast to move when not running
		PLAYER.RunSpeed				= 320		-- How fast to move when running
		PLAYER.CrouchedWalkSpeed	= 0.4		-- Multiply move speed by this when crouching
		PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
		PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
		PLAYER.JumpPower			= 200		-- How powerful our jump should be
	end)
--//

--\\ Anti-gmod PVP system (anti crouch spam)
	hook.Add("StartCommand", "HG_AntiGmodPVP", function(ply, cmd)
		ply.NowCrouched = cmd:KeyDown(IN_DUCK)
		ply.OldCrouched = ply.OldCrouched or cmd:KeyDown(IN_DUCK)

		if not ply:OnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() == MOVETYPE_WALK and ply.OldCrouched != ply.NowCrouched then
			cmd:AddKey(IN_DUCK)
		end

		ply.OldCrouched = cmd:KeyDown(IN_DUCK)
	end)
--//
