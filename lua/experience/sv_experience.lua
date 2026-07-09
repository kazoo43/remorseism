--
if zb and zb.Experience and zb.Experience._loaded then return end

zb = zb or {}

zb.Experience = zb.Experience or {}
zb.Experience.PlayerInstances = zb.Experience.PlayerInstances or {}
zb.Experience.Active = zb.Experience.Active or false
zb.Experience._loaded = true

hook.Add("DatabaseConnected", "ExperienceCreateData", function()
	local query

	query = mysql:Create("zb_experience")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:Create("skill", "FLOAT NOT NULL")
		query:Create("experience", "INT NOT NULL") -- Надо перевести в большие числа INT НЕ ХВАТАЕТ!!! - хватает просто кое-кто придурок да салат?
        query:Create("deaths", "INT NOT NULL")
        query:Create("kills", "INT NOT NULL")
        query:Create("suicides", "INT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    zb.Experience.Active = true
end)

--local query = mysql:Drop("zb_experience")
--query:Execute()

hook.Add( "PlayerInitialSpawn","ZB_Exp_OnInitSpawn", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not zb.Experience.Active then
        if not zb.Experience.PlayerInstances[steamID64] then
            zb.Experience.PlayerInstances[steamID64] = {}
        end
        local inst = zb.Experience.PlayerInstances[steamID64]
        inst.sandbox_experience = inst.sandbox_experience or 0
        inst.sandbox_skill = inst.sandbox_skill or 0
        inst.sandbox_kills = inst.sandbox_kills or 0
        inst.sandbox_deaths = inst.sandbox_deaths or 0
        inst.sandbox_suicides = inst.sandbox_suicides or 0
        return
    end 

	local query = mysql:Select("zb_experience")
		query:Select("skill")
		query:Select("experience")
        query:Select("deaths")
        query:Select("kills")
        query:Select("suicides")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].experience) then
				local updateQuery = mysql:Update("zb_experience")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

                zb.Experience.PlayerInstances[steamID64] = {}

                zb.Experience.PlayerInstances[steamID64].sandbox_experience = 0
                zb.Experience.PlayerInstances[steamID64].sandbox_skill = 0
                zb.Experience.PlayerInstances[steamID64].sandbox_kills = 0
                zb.Experience.PlayerInstances[steamID64].sandbox_deaths = 0
                zb.Experience.PlayerInstances[steamID64].sandbox_suicides = 0
                zb.Experience.PlayerInstances[steamID64].skill = tonumber(result[1].skill)
                zb.Experience.PlayerInstances[steamID64].experience = tonumber(result[1].experience)
                zb.Experience.PlayerInstances[steamID64].deaths = tonumber(result[1].deaths)
                zb.Experience.PlayerInstances[steamID64].kills = tonumber(result[1].kills)
                zb.Experience.PlayerInstances[steamID64].suicides = tonumber(result[1].suicides)

			else
				local insertQuery = mysql:Insert("zb_experience")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("skill", 0)
		            insertQuery:Insert("experience", 0)
                    insertQuery:Insert("deaths", 0)
		            insertQuery:Insert("kills", 0)
                    insertQuery:Insert("suicides", 0)
				insertQuery:Execute()

				zb.Experience.PlayerInstances[steamID64] = {}

				zb.Experience.PlayerInstances[steamID64].sandbox_experience = 0
				zb.Experience.PlayerInstances[steamID64].sandbox_skill = 0
				zb.Experience.PlayerInstances[steamID64].sandbox_kills = 0
				zb.Experience.PlayerInstances[steamID64].sandbox_deaths = 0
				zb.Experience.PlayerInstances[steamID64].sandbox_suicides = 0
				zb.Experience.PlayerInstances[steamID64].skill = 0
                zb.Experience.PlayerInstances[steamID64].experience = 0
                zb.Experience.PlayerInstances[steamID64].deaths = 0
                zb.Experience.PlayerInstances[steamID64].kills = 0
                zb.Experience.PlayerInstances[steamID64].suicides = 0

			end
		end)
	query:Execute()

end)

local plyMeta = FindMetaTable("Player")

function plyMeta:GetExp()

    return math.Round(zb.Experience.PlayerInstances[self:SteamID64()].experience) or 0

end

function plyMeta:GiveExp( ammout )

    local steamID64 = self:SteamID64()

    if !zb.Experience or !zb.Experience.PlayerInstances or !zb.Experience.PlayerInstances[steamID64] then return end

    zb.Experience.PlayerInstances[steamID64].experience =  math.max( (zb.Experience.PlayerInstances[steamID64].experience or 0) + ammout, 0 )

	if zb.Experience.Active then
		local updateQuery = mysql:Update("zb_experience")
			updateQuery:Update("experience", self:GetExp(),0)
			updateQuery:Where("steamid", steamID64)
		updateQuery:Execute()
	end

	local points = math.min(ammout / 5, 10) * (1 + (self.EA_HasAccess and self:EA_HasAccess() and 2 or 0))
	local mul = math.min(player.GetCount() / 10, 1)
	if self.PS_AddPoints then
		self:PS_AddPoints(math.Round(points * mul, 0))
	end
    --self:SetNWInt( "experience", exp + ammout )
end


function plyMeta:GetSkill()

    return zb.Experience.PlayerInstances[self:SteamID64()].skill or 0

end

function plyMeta:GiveSkill( ammout )

    local steamID64 = self:SteamID64()

    if not zb.Experience.PlayerInstances[steamID64] then zb.Experience.PlayerInstances[steamID64] = {} end

    zb.Experience.PlayerInstances[steamID64].skill = math.max( (zb.Experience.PlayerInstances[steamID64].skill or 0) + ammout, 0 )

	if zb.Experience.Active then
		local updateQuery = mysql:Update("zb_experience")
			updateQuery:Update("skill", self:GetSkill())
			updateQuery:Where("steamid", steamID64)
		updateQuery:Execute()
	end
    --self:SetNWFloat( "skill", skill + ammout )
    
end

function plyMeta:GetDeaths()

    if engine.ActiveGamemode() ~= "zcity" then return self:GetSandboxDeaths() end

    return zb.Experience.PlayerInstances[self:SteamID64()].deaths or 0

end

function plyMeta:GiveDeaths( ammout )

    local steamID64 = self:SteamID64()

    if not zb.Experience.PlayerInstances[steamID64] then zb.Experience.PlayerInstances[steamID64] = {} end

    zb.Experience.PlayerInstances[steamID64].deaths = math.max( (zb.Experience.PlayerInstances[steamID64].deaths or 0) + ammout, 0 )

	if zb.Experience.Active then
		local updateQuery = mysql:Update("zb_experience")
			updateQuery:Update("deaths", self:GetDeaths())
			updateQuery:Where("steamid", steamID64)
		updateQuery:Execute()
	end
    --self:SetNWInt( "experience", exp + ammout )
end

function plyMeta:GetKills()

    if engine.ActiveGamemode() ~= "zcity" then return self:GetSandboxKills() end

    return zb.Experience.PlayerInstances[self:SteamID64()].kills or 0

end

function plyMeta:GiveKills( ammout )

    local steamID64 = self:SteamID64()

    if not zb.Experience.PlayerInstances[steamID64] then zb.Experience.PlayerInstances[steamID64] = {} end

    zb.Experience.PlayerInstances[steamID64].kills = math.max( (zb.Experience.PlayerInstances[steamID64].kills or 0) + ammout, 0 )

	if zb.Experience.Active then
		local updateQuery = mysql:Update("zb_experience")
			updateQuery:Update("kills", self:GetKills())
			updateQuery:Where("steamid", steamID64)
		updateQuery:Execute()
	end
    --self:SetNWInt( "experience", exp + ammout )
end


function plyMeta:GetSuicides( ammout )

    if engine.ActiveGamemode() ~= "zcity" then return self:GetSandboxSuicides() end

    return zb.Experience.PlayerInstances[self:SteamID64()].suicides or 0

end

function plyMeta:GiveSuicides( ammout )

    local steamID64 = self:SteamID64()

    if not zb.Experience.PlayerInstances[steamID64] then zb.Experience.PlayerInstances[steamID64] = {} end

    zb.Experience.PlayerInstances[steamID64].suicides =  math.max( (zb.Experience.PlayerInstances[steamID64].suicides or 0) + ammout, 0 )

	if zb.Experience.Active then
		local updateQuery = mysql:Update("zb_experience")
			updateQuery:Update("suicides", self:GetSuicides())
			updateQuery:Where("steamid", steamID64)
		updateQuery:Execute()
	end
    --self:SetNWInt( "experience", exp + ammout )
end

-- Отдельный опыт/скилл для сандбокса (только в памяти, не пишется в БД zcity)
function plyMeta:GetSandboxExp()
    return math.Round(zb.Experience.PlayerInstances[self:SteamID64()].sandbox_experience or 0)
end

function plyMeta:GiveSandboxExp(ammout)
    local steamID64 = self:SteamID64()
    if not zb.Experience.PlayerInstances[steamID64] then return end
    local inst = zb.Experience.PlayerInstances[steamID64]
    inst.sandbox_experience = math.max((inst.sandbox_experience or 0) + ammout, 0)
end

function plyMeta:GetSandboxSkill()
    return zb.Experience.PlayerInstances[self:SteamID64()].sandbox_skill or 0
end

function plyMeta:GiveSandboxSkill(ammout)
    local steamID64 = self:SteamID64()
    if not zb.Experience.PlayerInstances[steamID64] then return end
    local inst = zb.Experience.PlayerInstances[steamID64]
    inst.sandbox_skill = math.max((inst.sandbox_skill or 0) + ammout, 0)
end

function plyMeta:GetSandboxKills()
    return math.Round(zb.Experience.PlayerInstances[self:SteamID64()].sandbox_kills or 0)
end

function plyMeta:GiveSandboxKills(ammout)
    local steamID64 = self:SteamID64()
    if not zb.Experience.PlayerInstances[steamID64] then return end
    local inst = zb.Experience.PlayerInstances[steamID64]
    inst.sandbox_kills = math.max((inst.sandbox_kills or 0) + ammout, 0)
end

function plyMeta:GetSandboxDeaths()
    return math.Round(zb.Experience.PlayerInstances[self:SteamID64()].sandbox_deaths or 0)
end

function plyMeta:GiveSandboxDeaths(ammout)
    local steamID64 = self:SteamID64()
    if not zb.Experience.PlayerInstances[steamID64] then return end
    local inst = zb.Experience.PlayerInstances[steamID64]
    inst.sandbox_deaths = math.max((inst.sandbox_deaths or 0) + ammout, 0)
end

function plyMeta:GetSandboxSuicides()
    return math.Round(zb.Experience.PlayerInstances[self:SteamID64()].sandbox_suicides or 0)
end

function plyMeta:GiveSandboxSuicides(ammout)
    local steamID64 = self:SteamID64()
    if not zb.Experience.PlayerInstances[steamID64] then return end
    local inst = zb.Experience.PlayerInstances[steamID64]
    inst.sandbox_suicides = math.max((inst.sandbox_suicides or 0) + ammout, 0)
end

util.AddNetworkString("zb_xp_get")

net.Receive("zb_xp_get",function(len,ply)

    local steamID64 = ply:SteamID64()

    if not zb.Experience.PlayerInstances[steamID64] then
        zb.Experience.PlayerInstances[steamID64] = {}
    end

    local get_ply = net.ReadEntity()

    if not IsValid(get_ply) or not get_ply.GetSkill or not get_ply.GetExp then
        return
    end

    local isSandbox = engine.ActiveGamemode() ~= "zcity"

    net.Start("zb_xp_get")
        --print( ply:GetExp() )
        net.WriteEntity( get_ply )
        net.WriteFloat( isSandbox and get_ply:GetSandboxSkill() or get_ply:GetSkill() )
        net.WriteInt( isSandbox and get_ply:GetSandboxExp() or get_ply:GetExp(), 19 )
    net.Send(ply)

end)


--hook.Add( "ZB_EndRound", "ZB_Exp_Give", function()
--    local exp = ply.RoundEXP or 0
--    local skill = ply.RoundSkill or 0
--
--    ply:SetPData( "zb_experience", exp )
--    ply:SetPData( "zb_skill", skill )
--
--    ply:SetNWInt( "experience", exp )
--    ply:SetNWFloat( "skill", skill )
--
--    ply.RoundEXP = 0
--    ply.RoundSkill = 0
--end)
