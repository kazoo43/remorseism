util.AddNetworkString("VirusStageUpdate")

local VirusModule = {}
hg.organism.module.virus = VirusModule

function VirusModule.InfectPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() or not ply.organism then return end
    if ply.Virus and ply.Virus.Infected then return end
    ply.Virus = {
        Infected = true,
        Stage = 1,
        NextStageTime = CurTime() + 120,
        Pain = 0,
        PainTarget = 0,
        OxygenIssues = false,
        InternalBleeding = false,
        Convulsions = false,
        Damage = 0,
        LungDamage = 0,
        BrainDamage = 0,
        BrainDamageInterval = 2,
        NextBrainDamageTime = CurTime(),
        NextHPDamageTime = CurTime() + 5,
        NextLungDamageTime = CurTime() + 10,
        NextPainTime = CurTime() + 1,
        NextOxygenIssueTime = CurTime() + math.random(10, 15)
    }
    net.Start("VirusStageUpdate")
    net.WriteInt(ply.Virus.Stage, 8)
    net.Send(ply)
    --print(ply:Nick() .. " has been infected with the virus.")
end

function VirusModule.UpdateVirusStage(ply)
    local virus = ply.Virus
    if not virus or not virus.Infected then return end

    if CurTime() >= virus.NextStageTime then
        virus.Stage = math.min(virus.Stage + 1, 5)
        virus.NextStageTime = CurTime() + 120

        --print(ply:Nick() .. " has progressed to virus stage " .. virus.Stage)

        if virus.Stage == 2 then
            virus.PainTarget = 5
        elseif virus.Stage == 3 then
            virus.PainTarget = 10
            virus.OxygenIssues = true
            virus.Damage = 3
            virus.LungDamage = 0.2
        elseif virus.Stage == 4 then
            virus.OxygenIssues = true
            virus.PainTarget = 20
            virus.Damage = 5
            virus.LungDamage = 0.3
            virus.InternalBleeding = true
            ply.organism.internalBleed = math.max(ply.organism.internalBleed or 0, 10)
            ply.organism.needotrub = true
        elseif virus.Stage == 5 then
            virus.PainTarget = 30
            virus.Damage = 4
            virus.LungDamage = 0.5
            virus.BrainDamage = 0.03
            ply.organism.internalBleed = math.max(ply.organism.internalBleed or 0, 20)
            ply.organism.needotrub = true
        end

        net.Start("VirusStageUpdate")
        net.WriteInt(virus.Stage, 8)
        net.Send(ply)
    end
end

function VirusModule.ApplyVirusEffects(ply)
    local virus = ply.Virus
    if not virus or not virus.Infected or not ply.organism then return end

    if virus.Stage >= 2 then
        if CurTime() >= virus.NextHPDamageTime then
            ply:TakeDamage(2, ply, ply)
            virus.NextHPDamageTime = CurTime() + 5
        end
		if CurTime() >= virus.NextLungDamageTime then
			local lungDamage = virus.LungDamage * 0.1
			ply.organism.lungsL[1] = math.min(ply.organism.lungsL[1] + lungDamage, 1)
			ply.organism.lungsR[1] = math.min(ply.organism.lungsR[1] + lungDamage, 1)
			virus.NextLungDamageTime = CurTime() + 10
		end
    end

    if virus.Stage == 5 and CurTime() >= virus.NextBrainDamageTime then
        ply.organism.brain = math.min(ply.organism.brain + virus.BrainDamage, 1)
        virus.NextBrainDamageTime = CurTime() + virus.BrainDamageInterval
    end

    if virus.OxygenIssues and CurTime() >= virus.NextOxygenIssueTime then
        ply.organism.o2[1] = math.max(ply.organism.o2[1] - 20, 5)
        timer.Simple(5, function()
            if IsValid(ply) and ply.organism and ply.Virus == virus and virus.Infected then
                ply.organism.o2[1] = math.min(ply.organism.o2[1] + 20, 30)
                virus.NextOxygenIssueTime = CurTime() + math.random(10, 15)
            end
        end)
    end

    if virus.Convulsions and math.random(1, 100) <= 5 then
        ply.organism.needotrub = true
    end

    if virus.Pain < virus.PainTarget then
        virus.Pain = math.min(virus.Pain + 0.1, virus.PainTarget)
    elseif virus.Pain > virus.PainTarget then
        virus.Pain = math.max(virus.Pain - 0.1, virus.PainTarget)
    end

	if CurTime() >= virus.NextPainTime then
		ply.organism.painadd = math.min((ply.organism.painadd or 0) + virus.Pain * 0.15, 150)
		virus.NextPainTime = CurTime() + 1
	end
end

function VirusModule.ApplyVirusConvulsions(ply)
    local virus = ply.Virus
    if virus and virus.Convulsions and virus.Stage == 5 and ply.organism.otrub then
        local character = hg.GetCurrentCharacter(ply) or ply
        local mul = (60 - CurTime()) / 60
        if mul > 0 then
            for i = 0, character:GetPhysicsObjectCount() - 1 do
                local phys = character:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:ApplyForceCenter(VectorRand(-750 * mul, 750 * mul))
                end
            end
        end
    end
end

hook.Add("Org Think", "VirusUpdate", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    if ply:IsPlayer() and ply.Virus and ply.Virus.Infected then
        VirusModule.UpdateVirusStage(ply)
        VirusModule.ApplyVirusEffects(ply)
        VirusModule.ApplyVirusConvulsions(ply)
    end
end)

hook.Add("EntityTakeDamage", "ZombieInfect", function(target, dmginfo)
    if target:IsPlayer() and dmginfo:GetAttacker():IsNPC() then
        local attackerClass = dmginfo:GetAttacker():GetClass()
        if attackerClass == "terminator_nextbot_zambie" or attackerClass == "terminator_nextbot_zambietorso" then
            if target.Virus and target.Virus.Infected then return end
            local chance = target.VirusInfectionChance or 5
            --print(target:Nick() .. " has a " .. chance .. "% chance of being infected.")
            if math.random(1, 100) <= chance then
                VirusModule.InfectPlayer(target)
            else
                target.VirusInfectionChance = (target.VirusInfectionChance or 5) + 5
                --print(target:Nick() .. "'s infection chance increased to " .. target.VirusInfectionChance .. "%.")
            end
        end
    end
end)

hook.Add("PlayerDeath", "VirusReset", function(ply)
    ply.Virus = nil
    --print(ply:Nick() .. " has died and the virus has been reset.")
end)

hook.Add("Org Clear", "VirusClear", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        ply.Virus = nil
    end
end)
