MODE.name = "riot"
MODE.PrintName = "Riot"

MODE.OverideSpawnPos = true
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03
MODE.VoteTime = 10
MODE.start_time = 19

local riotWeapons = {
    "weapon_leadpipe",
    "weapon_hg_extinguisher",
    "weapon_hg_sledgehammer",
    "weapon_hatchet",
    "weapon_hg_crowbar",
    "weapon_hammer",
    "weapon_pocketknife",
    "weapon_hg_machete",
    "weapon_hg_shovel",
    "weapon_bat",
    "weapon_metalbat"
}

local riotConsumables = {
    "weapon_bigconsumable",
    "weapon_smallconsumable",
    "weapon_ducttape",
    "weapon_matches",
    "weapon_bandage_sh",
    "weapon_hg_smokenade_tpik",
    "weapon_hg_shuriken"
}

local riotContainedConsumables = {
    "weapon_bigconsumable",
    "weapon_smallconsumable",
    "weapon_ducttape",
    "weapon_matches",
    "weapon_bandage_sh",
    "weapon_hg_shuriken"
}

local riotAnarchySupport = {
    "weapon_bandage_sh",
    "weapon_medkit_sh",
    "weapon_hg_type56_tpik",
    "weapon_hg_pipebomb_tpik",
}

local riotAnarchyWeapons = {
    "weapon_revolver2",
    "weapon_revolver357",
    "weapon_rpk",
    "weapon_ruger",
    "weapon_vpo136",
    "weapon_vpo209",
    "weapon_remington870_long",
    "weapon_remington870_sawed_off",
    "weapon_remington870",
    "weapon_p22",
    "weapon_pm9",
    "weapon_pl15",
    "weapon_px4beretta",
    "weapon_tec9",
    "weapon_tokarev"
}

local riotArmorChance = 40

local lawWeapons = {
    "weapon_hg_tonfa",
    "weapon_taser",
    "weapon_walkie_talkie",
    "weapon_handcuffs",
    "weapon_handcuffs_key"
}

local lawArmor = {
    "ent_armor_vest2",
    "ent_armor_helmet3"
}

local swatWeapons = {
    {"weapon_m4a1", {"holo15","grip3","laser4"}},
    {"weapon_hk416", {"holo15","grip3","laser4"}},
    {"weapon_p90", {}},
    {"weapon_mp7", {"holo14"}},
    {"weapon_m4a1", {"optic2","grip3","supressor7"}}
}

local swatItems = {
    "weapon_medkit_sh",
    "weapon_tourniquet",
    "weapon_walkie_talkie",
    "weapon_combatknife",
    "weapon_handcuffs",
    "weapon_hg_flashbang_tpik"
}

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
    return 1, true
end

util.AddNetworkString("riot_start")
util.AddNetworkString("riot_roundend")
util.AddNetworkString("riot_start_vote")
util.AddNetworkString("riot_vote_update")
util.AddNetworkString("riot_vote_result")
util.AddNetworkString("riot_show_selected_mode")
util.AddNetworkString("riot_change_vote")

local function RemoveVoteTimers()
    timer.Remove("riot_vote_end")
    timer.Remove("riot_vote_update")
end

local function GiveWeaponWithAmmo(ply, class, ammoMul)
    local wep = ply:Give(class)
    if IsValid(wep) and wep.GetMaxClip1 then
        local maxClip = wep:GetMaxClip1()
        local ammoType = wep:GetPrimaryAmmoType()
        if maxClip and maxClip > 0 and ammoType and ammoType >= 0 then
            ply:GiveAmmo(maxClip * (ammoMul or 3), ammoType, true)
        end
    end
    return wep
end

local function GiveWeaponNoReserve(ply, class)
    return ply:Give(class)
end

local function GiveSling(ply)
    local inv = ply:GetNetVar("Inventory")
    if not istable(inv) then return end
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    ply:SetNetVar("Inventory", inv)
end

local function GetIntensityData(index)
    local intensities = RIOT_INTENSITIES or {}
    return intensities[index] or intensities[2] or {
        id = "ESCALATED",
        name = "Escalated",
        description = "Some people are armed, the fire is rising."
    }
end

local function GetRiotTeam(ply)
    return ply.RiotAssignedTeam or ply:Team()
end

local function SetRiotTeam(ply, teamId)
    ply.RiotAssignedTeam = teamId
    ply:SetTeam(teamId)
end

local function GetIntroRoleName(ply, intensityId)
    if GetRiotTeam(ply) == 0 then
        return "a Rioter"
    end

    if intensityId == "ANARCHY" then
        return "SWAT"
    end

    return "Law Enforcement"
end

function MODE:Intermission()
    game.CleanUpMap()

    RemoveVoteTimers()
    self.VoteInProgress = false
    self.CurrentIntensity = nil
    self.RoundSetupTime = nil
    self.HasAppliedLoadout = false
    self.VoteResults = {[1] = 0, [2] = 0, [3] = 0}

    for _, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ply.HasVoted = nil
        ply.RiotAssignedTeam = nil
        if ply:Alive() then
            ply:KillSilent()
        end
    end

    self:StartVoting()
end

function MODE:StartVoting()
    self.VoteInProgress = true
    self.VoteResults = {[1] = 0, [2] = 0, [3] = 0}

    net.Start("riot_start_vote")
    net.WriteFloat(CurTime() + self.VoteTime)
    net.Broadcast()

    timer.Create("riot_vote_end", self.VoteTime, 1, function()
        local mode = CurrentRound()
        if mode and mode.name == "riot" then
            mode:EndVoting()
        end
    end)

    timer.Create("riot_vote_update", 1, self.VoteTime, function()
        local mode = CurrentRound()
        if not mode or mode.name ~= "riot" or not mode.VoteInProgress then return end
        net.Start("riot_vote_update")
        net.WriteTable(mode.VoteResults)
        net.Broadcast()
    end)
end

function MODE:EndVoting()
    RemoveVoteTimers()

    local highestVotes = -1
    local selectedModes = {}

    for modeIndex = 1, 3 do
        local votes = self.VoteResults[modeIndex] or 0
        if votes > highestVotes then
            highestVotes = votes
            selectedModes = {modeIndex}
        elseif votes == highestVotes then
            selectedModes[#selectedModes + 1] = modeIndex
        end
    end

    local selectedMode = 2
    if highestVotes > 0 and #selectedModes > 0 then
        selectedMode = selectedModes[math.random(#selectedModes)]
    end

    self.CurrentIntensity = GetIntensityData(selectedMode)
    self.VoteInProgress = false
    self.RoundSetupTime = CurTime() + 4

    net.Start("riot_vote_result")
    net.WriteInt(selectedMode, 4)
    net.WriteTable(self.VoteResults)
    net.Broadcast()

    net.Start("riot_show_selected_mode")
    net.WriteInt(selectedMode, 4)
    net.Broadcast()

    timer.Simple(3, function()
        local mode = CurrentRound()
        if not mode or mode ~= self or mode.name ~= "riot" then return end
        mode.HasAppliedLoadout = false
        mode:GiveEquipment()
        local intensityId = mode.CurrentIntensity and mode.CurrentIntensity.id or "ESCALATED"

        for _, ply in player.Iterator() do
            if ply:Team() == TEAM_SPECTATOR then continue end

            net.Start("riot_start")
            net.WriteInt(selectedMode, 4)
            net.WriteInt(GetRiotTeam(ply), 4)
            net.WriteString(GetIntroRoleName(ply, intensityId))
            net.Send(ply)
        end
    end)
end

function MODE:CheckAlivePlayers()
    local swatPlayers = {}
    local banditPlayers = {}

    for _, ply in player.Iterator() do
        if GetRiotTeam(ply) ~= 0 then continue end
        if ply:Alive() and not (ply.organism and ply.organism.incapacitated) and not ply:GetNetVar("handcuffed", false) then
            table.insert(swatPlayers, ply)
        end
    end

    for _, ply in player.Iterator() do
        if GetRiotTeam(ply) ~= 1 then continue end
        if ply:Alive() and not (ply.organism and ply.organism.incapacitated) and not ply:GetNetVar("handcuffed", false) then
            table.insert(banditPlayers, ply)
        end
    end

    return {swatPlayers, banditPlayers}
end


function MODE:EndRound()
    RemoveVoteTimers()
    timer.Simple(2,function()
        net.Start("riot_roundend")
        net.Broadcast()
    end)
end


function MODE:ShouldRoundEnd()
    if self.VoteInProgress then return false end
    if (self.RoundSetupTime or 0) > CurTime() then return false end
    local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
    return endround
end

function MODE:RoundStart()
end

local function GiveContainedRioter(ply)
    zb.GiveRole(ply, "Rioter", Color(190, 0, 0))
    ply:SetPlayerClass("terrorist")
    ply:SetNetVar("CurPluv", "pluvmajima")
    ply:Give("weapon_hands_sh")
    ply:Give(riotContainedConsumables[math.random(#riotContainedConsumables)])
    local weapon = riotWeapons[math.random(#riotWeapons)]
    GiveWeaponWithAmmo(ply, weapon, 2)
    ply:SelectWeapon(weapon)
end

local function GiveEscalatedRioter(ply, index, shotgunIndex)
    zb.GiveRole(ply, "Rioter", Color(190, 0, 0))
    ply:SetPlayerClass("terrorist")
    ply:SetNetVar("CurPluv", "pluvmajima")
    ply:Give("weapon_hands_sh")

    if index == 1 then
        ply:Give("weapon_hg_molotov_tpik")
    elseif index == 2 then
        GiveWeaponNoReserve(ply, "weapon_mp-80")
    end

    ply:Give(riotConsumables[math.random(#riotConsumables)])

    if math.random(100) <= riotArmorChance then
        hg.AddArmor(ply, "ent_armor_helmet2")
    end

    local weapon = index == shotgunIndex and "weapon_remington870_sawed_off" or riotWeapons[math.random(#riotWeapons)]
    GiveWeaponNoReserve(ply, weapon)
    ply:SelectWeapon(weapon)
end

local function GiveAnarchyRioter(ply)
    zb.GiveRole(ply, "Rioter", Color(190, 0, 0))
    ply:SetPlayerClass("terrorist")
    ply:SetNetVar("CurPluv", "pluvmajima")
    ply:Give("weapon_hands_sh")
    ply:Give(riotAnarchySupport[math.random(#riotAnarchySupport)])

    if math.random(100) <= 35 then
        hg.AddArmor(ply, "ent_armor_vest2")
    end

    local weapon = riotAnarchyWeapons[math.random(#riotAnarchyWeapons)]
    GiveWeaponWithAmmo(ply, weapon, 3)
    ply:SelectWeapon(weapon)
end

local function GiveContainedLaw(ply, lawIndex)
    zb.GiveRole(ply, "Law Enforcement", Color(0, 0, 190))
    ply:SetPlayerClass("police")
    GiveSling(ply)
    ply:Give("weapon_hands_sh")
    ply:Give("weapon_hg_tonfa")
    if lawIndex <= 2 then
        ply:Give("weapon_taser")
    end
    ply:Give("weapon_walkie_talkie")
    ply:Give("weapon_handcuffs")
    ply:Give("weapon_handcuffs_key")
    hg.AddArmor(ply, "ent_armor_vest2")
    ply:SetNetVar("CurPluv", "pluvberet")

    if lawIndex == 1 then
        ply:Give("weapon_ram")
    end

    ply:SelectWeapon("weapon_hg_tonfa")
end

local function GiveEscalatedLaw(ply, lawIndex, glockIndex)
    zb.GiveRole(ply, "Law Enforcement", Color(0, 0, 190))
    ply:SetPlayerClass("police")
    GiveSling(ply)
    ply:Give("weapon_hands_sh")

    for _, wepName in ipairs(lawWeapons) do
        if lawIndex == glockIndex and wepName == "weapon_taser" then
            GiveWeaponNoReserve(ply, "weapon_glock17")
        else
            ply:Give(wepName)
        end
    end

    ply:SetNetVar("CurPluv", "pluvberet")
    hg.AddArmor(ply, lawArmor[1])
    hg.AddArmor(ply, lawArmor[2])

    if lawIndex == 1 then
        ply:Give("weapon_ram")
    elseif lawIndex == 2 then
        local wep = GiveWeaponNoReserve(ply, "weapon_remington870")
        timer.Simple(1, function()
            if IsValid(wep) then
                wep:SetRandomBodygroups("000010302")
                wep:ApplyAmmoChanges(2)
            end
        end)
    end

    ply:SelectWeapon("weapon_hg_tonfa")
end

local function GiveAnarchyLaw(ply)
    zb.GiveRole(ply, "SWAT", Color(0, 0, 190))
    ply:SetPlayerClass("swat")
    GiveSling(ply)
    ply:Give("weapon_hands_sh")
    hg.AddArmor(ply, "ent_armor_vest8")
    hg.AddArmor(ply, "ent_armor_helmet6")

    local weaponData = swatWeapons[math.random(#swatWeapons)]
    local primary = GiveWeaponWithAmmo(ply, weaponData[1], 3)
    if IsValid(primary) and hg.AddAttachmentForce then
        hg.AddAttachmentForce(ply, primary, weaponData[2])
    end

    GiveWeaponWithAmmo(ply, "weapon_glock17", 3)

    for _, item in ipairs(swatItems) do
        ply:Give(item)
    end

    ply:SelectWeapon(weaponData[1])
end

function MODE:GiveEquipment()
    if self.VoteInProgress or not self.CurrentIntensity or self.HasAppliedLoadout then return end

    local players = {}

    for _, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        players[#players + 1] = ply
    end

    table.Shuffle(players)
    self.HasAppliedLoadout = true

    local selectedIntensity = self.CurrentIntensity and self.CurrentIntensity.id or "ESCALATED"
    local numPlayers = #players
    local numRioters = math.ceil(numPlayers / 2)

    if selectedIntensity == "CONTAINED" then
        numRioters = math.floor(numPlayers / 2)
    elseif selectedIntensity == "ANARCHY" then
        numRioters = math.ceil(numPlayers * 5 / 8)
    end

    local numLawEnforcers = numPlayers - numRioters
    local glockIndex = numLawEnforcers > 0 and math.random(numLawEnforcers) or 1
    local shotgunIndex = numRioters > 0 and math.random(numRioters) or 1

    for i = 1, numPlayers do
        local ply = players[i]
        SetRiotTeam(ply, i <= numRioters and 0 or 1)
    end

    for i = 1, numRioters do
        local ply = players[i]
        ply:SetupTeam(0)
        if not ply:Alive() then
            ply:Spawn()
        end
        SetRiotTeam(ply, 0)

        if selectedIntensity == "CONTAINED" then
            GiveContainedRioter(ply)
        elseif selectedIntensity == "ANARCHY" then
            GiveAnarchyRioter(ply)
        else
            GiveEscalatedRioter(ply, i, shotgunIndex)
        end
    end

    for i = numRioters + 1, numPlayers do
        local ply = players[i]
        local lawIndex = i - numRioters
        ply:SetupTeam(1)
        if not ply:Alive() then
            ply:Spawn()
        end
        SetRiotTeam(ply, 1)

        if selectedIntensity == "CONTAINED" then
            GiveContainedLaw(ply, lawIndex)
        elseif selectedIntensity == "ANARCHY" then
            GiveAnarchyLaw(ply)
        else
            GiveEscalatedLaw(ply, lawIndex, glockIndex)
        end
    end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:RoundThink()
    for _, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        if ply.RiotAssignedTeam == nil then continue end
        if ply:Team() ~= ply.RiotAssignedTeam then
            ply:SetTeam(ply.RiotAssignedTeam)
        end
    end
end


function MODE:CanLaunch()
    local activePlayers = 0

    for _, ply in player.Iterator() do
        if ply:Team() ~= TEAM_SPECTATOR then
            activePlayers = activePlayers + 1
        end
    end
    
    if activePlayers < 5 then
        return false
    end

    return true
    --[[local pointsRioters = zb.GetMapPoints("RIOT_TDM_RIOTERS")
    local pointsLaw = zb.GetMapPoints("RIOT_TDM_LAW")
    return (#pointsRioters > 0) and (#pointsLaw > 0)--]]
end

net.Receive("riot_change_vote", function(_, ply)
    if not IsValid(ply) or ply:Team() == TEAM_SPECTATOR then return end
    if not ply.LastRiotVoteChange then ply.LastRiotVoteChange = 0 end
    if CurTime() - ply.LastRiotVoteChange < 0.5 then return end
    ply.LastRiotVoteChange = CurTime()

    local previousVote = net.ReadInt(4)
    local newVote = net.ReadInt(4)
    if newVote < 1 or newVote > 3 then return end

    local mode = CurrentRound()
    if not mode or mode.name ~= "riot" or not mode.VoteInProgress then return end

    if ply.HasVoted and ply.HasVoted >= 1 and ply.HasVoted <= 3 then
        mode.VoteResults[ply.HasVoted] = math.max(0, (mode.VoteResults[ply.HasVoted] or 0) - 1)
    elseif previousVote >= 1 and previousVote <= 3 then
        mode.VoteResults[previousVote] = math.max(0, (mode.VoteResults[previousVote] or 0) - 1)
    end

    mode.VoteResults[newVote] = (mode.VoteResults[newVote] or 0) + 1
    ply.HasVoted = newVote

    net.Start("riot_vote_update")
    net.WriteTable(mode.VoteResults)
    net.Broadcast()
end)

return MODE
