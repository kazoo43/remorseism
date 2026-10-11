COMMANDS.sendtospawn = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 0 and args[1] or ply:Name()
		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				ply2:Spawn()
				ply:ChatPrint( ply2:Name().. " | Sended to random spawn..." )
			end
		end
	end,
	0
}

COMMANDS.give = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 1 and args[1] or ply:Name()
		local wep = #args > 1 and args[2] or args[1]
		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				local ent = ply2:Give( wep )
                if not IsValid(ent) then return end

                ent:Use(ply2)
				ply:ChatPrint( ply2:Name().. " | Weapon given" )
			end
		end
	end,
	0
}

COMMANDS.respawn = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 0 and args[1] or ply:Name()
		for i, ply2 in pairs(player.GetListByName(plya)) do
			ply2:Spawn()
            ApplyAppearance( ply2 )
			local hands = ply2:Give("weapon_hands_sh")
			ply2:SelectWeapon(hands)

			ply:ChatPrint( ply2:Name().. " | Respawned" )
		end
	end,
	0
}

util.AddNetworkString("ZB_AdminStatsRequest")
util.AddNetworkString("ZB_AdminStatsSend")
util.AddNetworkString("ZB_AdminStatsSave")
util.AddNetworkString("ZB_AdminStatsSaveResult")

local function AdminStatsAllowed(ply)
    return IsValid(ply) and ply:IsSuperAdmin()
end

local function FindPlayerBySteamID64(steamID64)
    for _, ply in player.Iterator() do
        if ply:SteamID64() == steamID64 then return ply end
    end
end

local function AdminStatsSQLReady()
    return mysql and (mysql.module == "sqlite" or mysql.connection)
end

local function AdminStatsNumber(value, fallback, whole, minimum)
    if isstring(value) then
        value = value:gsub(",", ""):gsub("%s+", "")
    end

    local number = tonumber(value)
    if number == nil then number = tonumber(fallback) or 0 end
    if whole then number = math.floor(number) end
    if minimum then number = math.max(number, minimum) end

    return number
end

local function GetAchievementValues(data)
    local values = util.JSONToTable(data or "") or {}
    local filtered = hg and hg.achievements and hg.achievements.FilterPlayerAchievements and hg.achievements.FilterPlayerAchievements(values) or values
    local output = {}

    if hg and hg.achievements and hg.achievements.GetAchievements then
        for key, info in pairs(hg.achievements.GetAchievements() or {}) do
            output[key] = tonumber(info.start_value) or 0
        end
    end

    for key, val in pairs(filtered) do
        output[key] = tonumber(istable(val) and val.value or val) or 0
    end

    return output
end

local function GetActiveAdminStatsRows()
    local rows = {}

    for _, ply2 in player.Iterator() do
        local steamID64 = ply2:SteamID64()
        local exp = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[steamID64] or {}

        rows[#rows + 1] = {
            steamid = steamID64,
            name = ply2:Name(),
            active = true,
            skill = tonumber(exp.skill) or 0,
            experience = tonumber(exp.experience) or 0,
            deaths = tonumber(exp.deaths) or 0,
            kills = tonumber(exp.kills) or 0,
            suicides = tonumber(exp.suicides) or 0,
            headshots = tonumber(ply2:GetPData("Headshots", 0)) or 0,
            karma = ply2.guilt_GetValue and ply2:guilt_GetValue() or ply2.Karma or 100,
            achievements = GetAchievementValues(util.TableToJSON(hg and hg.achievements and hg.achievements.GetPlayerAchievements and hg.achievements.GetPlayerAchievements(ply2) or {}))
        }
    end

    table.sort(rows, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return rows
end

local ADMIN_STATS_CHUNK_SIZE = 15

local function SendAdminStatsRows(ply, rows)
    local total = #rows
    local chunks = math.max(1, math.ceil(total / ADMIN_STATS_CHUNK_SIZE))

    for index = 1, chunks do
        local from = (index - 1) * ADMIN_STATS_CHUNK_SIZE + 1
        local to = math.min(from + ADMIN_STATS_CHUNK_SIZE - 1, total)
        local part = {}

        for i = from, to do
            part[#part + 1] = rows[i]
        end

        net.Start("ZB_AdminStatsSend")
            net.WriteUInt(total, 16)
            net.WriteUInt(chunks, 16)
            net.WriteUInt(index, 16)
            net.WriteString(util.TableToJSON(part))
        net.Send(ply)
    end
end

local function SendAdminStatsSaveResult(ply, ok, message)
    if not IsValid(ply) then return end

    net.Start("ZB_AdminStatsSaveResult")
        net.WriteBool(ok)
        net.WriteString(message or "")
    net.Send(ply)
end

local function SendAdminStatsLiveXP(ply, target, exp)
    if not IsValid(ply) or not IsValid(target) then return end

    net.Start("zb_xp_get")
        net.WriteEntity(target)
        net.WriteFloat(exp.skill or 0)
        net.WriteUInt(math.Clamp(exp.experience or 0, 0, 4294967295), 32)
    net.Send(ply)
end

local function SendAdminStats(ply)
    if not AdminStatsAllowed(ply) then return end

    if not AdminStatsSQLReady() then
        SendAdminStatsRows(ply, GetActiveAdminStatsRows())
        return
    end

    local active = {}
    for _, ply2 in player.Iterator() do
        active[ply2:SteamID64()] = ply2
    end

    mysql:RawQuery([[SELECT e.steamid, e.steam_name, e.skill, e.experience, e.deaths, e.kills, e.suicides, g.value AS karma, a.achievements FROM zb_experience e LEFT JOIN zb_guilt g ON g.steamid = e.steamid LEFT JOIN hg_achievements a ON a.steamid = e.steamid]], function(result)
        if not AdminStatsAllowed(ply) then return end

        local rows = {}
        local seen = {}

        for _, data in ipairs(result or {}) do
            local steamID64 = tostring(data.steamid or "")
            local ply2 = active[steamID64]
            local exp = IsValid(ply2) and zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[steamID64] or nil
            local achievements = IsValid(ply2) and hg and hg.achievements and hg.achievements.GetPlayerAchievements and hg.achievements.GetPlayerAchievements(ply2) or nil

            seen[steamID64] = true
            rows[#rows + 1] = {
                steamid = steamID64,
                name = IsValid(ply2) and ply2:Name() or tostring(data.steam_name or "Unknown"),
                active = IsValid(ply2),
                skill = exp and tonumber(exp.skill) or tonumber(data.skill) or 0,
                experience = exp and tonumber(exp.experience) or tonumber(data.experience) or 0,
                deaths = exp and tonumber(exp.deaths) or tonumber(data.deaths) or 0,
                kills = exp and tonumber(exp.kills) or tonumber(data.kills) or 0,
                suicides = exp and tonumber(exp.suicides) or tonumber(data.suicides) or 0,
                headshots = IsValid(ply2) and (tonumber(ply2:GetPData("Headshots", 0)) or 0) or 0,
                karma = tonumber(data.karma) or (IsValid(ply2) and ply2.guilt_GetValue and ply2:guilt_GetValue() or 100),
                achievements = GetAchievementValues(achievements and util.TableToJSON(achievements) or data.achievements)
            }
        end

        for steamID64, ply2 in pairs(active) do
            if not seen[steamID64] then
                local exp = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[steamID64] or {}
                rows[#rows + 1] = {
                    steamid = steamID64,
                    name = ply2:Name(),
                    active = true,
                    skill = tonumber(exp.skill) or 0,
                    experience = tonumber(exp.experience) or 0,
                    deaths = tonumber(exp.deaths) or 0,
                    kills = tonumber(exp.kills) or 0,
                    suicides = tonumber(exp.suicides) or 0,
                    headshots = tonumber(ply2:GetPData("Headshots", 0)) or 0,
                    karma = ply2.guilt_GetValue and ply2:guilt_GetValue() or 100,
                    achievements = GetAchievementValues(util.TableToJSON(hg and hg.achievements and hg.achievements.GetPlayerAchievements and hg.achievements.GetPlayerAchievements(ply2) or {}))
                }
            end
        end

        table.sort(rows, function(a, b)
            if a.active ~= b.active then return a.active end
            return a.name:lower() < b.name:lower()
        end)

        SendAdminStatsRows(ply, rows)
    end)
end

net.Receive("ZB_AdminStatsRequest", function(len, ply)
    SendAdminStats(ply)
end)

net.Receive("ZB_AdminStatsSave", function(len, ply)
    if not AdminStatsAllowed(ply) then
        SendAdminStatsSaveResult(ply, false, "Access denied")
        return
    end

    local steamID64 = net.ReadString()
    local data = net.ReadTable()
    if steamID64 == "" or not istable(data) then
        SendAdminStatsSaveResult(ply, false, "Invalid stats data")
        return
    end

    local target = FindPlayerBySteamID64(steamID64)
    local name = IsValid(target) and target:Name() or tostring(data.name or "Unknown")
    local currentExp = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[steamID64] or {}
    local currentGuilt = zb.GuiltSQL and zb.GuiltSQL.PlayerInstances and zb.GuiltSQL.PlayerInstances[steamID64] or {}
    local exp = {
        skill = AdminStatsNumber(data.skill, currentExp.skill),
        experience = AdminStatsNumber(data.experience, currentExp.experience, true, 0),
        deaths = AdminStatsNumber(data.deaths, currentExp.deaths, true, 0),
        kills = AdminStatsNumber(data.kills, currentExp.kills, true, 0),
        suicides = AdminStatsNumber(data.suicides, currentExp.suicides, true, 0)
    }
    local karma = AdminStatsNumber(data.karma, currentGuilt.value or 100)
    local headshots = AdminStatsNumber(data.headshots, IsValid(target) and target:GetPData("Headshots", 0) or 0, true, 0)

    if zb.Experience and zb.Experience.PlayerInstances then
        zb.Experience.PlayerInstances[steamID64] = table.Copy(exp)
    end

    if zb.GuiltSQL and zb.GuiltSQL.PlayerInstances then
        zb.GuiltSQL.PlayerInstances[steamID64] = zb.GuiltSQL.PlayerInstances[steamID64] or {}
        zb.GuiltSQL.PlayerInstances[steamID64].value = karma
    end

    if IsValid(target) then
        target.Karma = karma
        target:SetNetVar("Karma", karma)
        target:SetPData("Headshots", headshots)
        target:SetNWInt("Headshots", headshots)
        target.exp = nil
        target.skill = nil
        SendAdminStatsLiveXP(ply, target, exp)
        SendAdminStatsLiveXP(target, target, exp)

        if AdminStatsSQLReady() and target.guilt_SetValue then
            target:guilt_SetValue(karma)
        end

        if hg and hg.achievements and hg.achievements.SetPlayerAchievement then
            hg.achievements.SetPlayerAchievement(target, "gollavo", headshots)
        end
    end

    if hg and hg.achievements then
        local achievements = {}
        local oldAchievements = hg.achievements.achievements_data and hg.achievements.achievements_data.player_achievements and hg.achievements.achievements_data.player_achievements[steamID64] or {}

        for key, value in pairs(oldAchievements) do
            achievements[key] = {value = AdminStatsNumber(istable(value) and value.value or value, 0)}
        end

        if istable(data.achievements) then
            for key, value in pairs(data.achievements) do
                achievements[key] = {value = AdminStatsNumber(value, 0)}
            end
        end

        achievements.gollavo = {value = headshots}

        achievements = hg.achievements.FilterPlayerAchievements and hg.achievements.FilterPlayerAchievements(achievements) or achievements

        if IsValid(target) then
            hg.achievements.achievements_data.player_achievements[steamID64] = achievements
        end
    end

    if not AdminStatsSQLReady() then
        SendAdminStatsSaveResult(ply, true, "Saved in memory")
        SendAdminStatsRows(ply, GetActiveAdminStatsRows())
        return
    end

    local insertExp = mysql:InsertIgnore("zb_experience")
        insertExp:Insert("steamid", steamID64)
        insertExp:Insert("steam_name", name)
        insertExp:Insert("skill", exp.skill)
        insertExp:Insert("experience", exp.experience)
        insertExp:Insert("deaths", exp.deaths)
        insertExp:Insert("kills", exp.kills)
        insertExp:Insert("suicides", exp.suicides)
    insertExp:Execute()

    local updateExp = mysql:Update("zb_experience")
        updateExp:Update("steam_name", name)
        updateExp:Update("skill", exp.skill)
        updateExp:Update("experience", exp.experience)
        updateExp:Update("deaths", exp.deaths)
        updateExp:Update("kills", exp.kills)
        updateExp:Update("suicides", exp.suicides)
        updateExp:Where("steamid", steamID64)
    updateExp:Execute()

    local insertGuilt = mysql:InsertIgnore("zb_guilt")
        insertGuilt:Insert("steamid", steamID64)
        insertGuilt:Insert("steam_name", name)
        insertGuilt:Insert("value", karma)
    insertGuilt:Execute()

    local updateGuilt = mysql:Update("zb_guilt")
        updateGuilt:Update("steam_name", name)
        updateGuilt:Update("value", karma)
        updateGuilt:Where("steamid", steamID64)
    updateGuilt:Execute()

    if hg and hg.achievements then
        local achievements = {}
        local oldAchievements = hg.achievements.achievements_data and hg.achievements.achievements_data.player_achievements and hg.achievements.achievements_data.player_achievements[steamID64] or {}

        for key, value in pairs(oldAchievements) do
            achievements[key] = {value = AdminStatsNumber(istable(value) and value.value or value, 0)}
        end

        if istable(data.achievements) then
            for key, value in pairs(data.achievements) do
                achievements[key] = {value = AdminStatsNumber(value, 0)}
            end
        end

        achievements.gollavo = {value = headshots}

        achievements = hg.achievements.FilterPlayerAchievements and hg.achievements.FilterPlayerAchievements(achievements) or achievements

        if IsValid(target) then
            hg.achievements.achievements_data.player_achievements[steamID64] = achievements
            hg.achievements.SaveToSQL(target, achievements)
        else
            local json = util.TableToJSON(achievements)
            local insertAch = mysql:InsertIgnore("hg_achievements")
                insertAch:Insert("steamid", steamID64)
                insertAch:Insert("steam_name", name)
                insertAch:Insert("achievements", json)
            insertAch:Execute()

            local updateAch = mysql:Update("hg_achievements")
                updateAch:Update("steam_name", name)
                updateAch:Update("achievements", json)
                updateAch:Where("steamid", steamID64)
            updateAch:Execute()
        end
    end

    timer.Simple(1, function()
        SendAdminStatsSaveResult(ply, true, "Stats saved")
        SendAdminStats(ply)
    end)
end)
