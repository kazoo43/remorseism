--
zb = zb or {}

zb.Experience = zb.Experience or {}

zb.Experience.SkillMedals = {
    {
        icon = Material("vgui/mats_jack_awards/pt"),
        name = "Pt",
        skill = { 4.6, 99999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/au"),
        name = "Au",
        skill = { 3.7, 4.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/pd"),
        name = "Pd",
        skill = { 2.9, 3.7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ir"),
        name = "Ir",
        skill = { 2.2, 2.9 }
    },
    {
        icon = Material("vgui/mats_jack_awards/os"),
        name = "Os",
        skill = { 1.6, 2.2 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ru"),
        name = "Ru",
        skill = { 1.1, 1.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ag"),
        name = "Ag",
        skill = { .7, 1.1 }
    },
    {
        icon = Material("vgui/mats_jack_awards/sn"),
        name = "Sn",
        skill = { .4, .7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ni"),
        name = "Ni",
        skill = { .2, .4 }
    },
    {
        icon = Material("vgui/mats_jack_awards/cu"),
        name = "Cu",
        skill = { 0, .2 }
    },
}

zb.Experience.Bands = {
    {
        icon = Material("vgui/mats_jack_awards/10"),
        name = "",
        skill = { 15360, 999999999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/9"),
        name = "",
        skill = { 7680, 15360 }
    },
    {
        icon = Material("vgui/mats_jack_awards/8"),
        name = "",
        skill = { 3840, 7680 }
    },
    {
        icon = Material("vgui/mats_jack_awards/7"),
        name = "",
        skill = { 1920, 3840 }
    },
    {
        icon = Material("vgui/mats_jack_awards/6"),
        name = "",
        skill = { 960, 1920 }
    },
    {
        icon = Material("vgui/mats_jack_awards/5"),
        name = "",
        skill = { 480, 960 }
    },
    {
        icon = Material("vgui/mats_jack_awards/4"),
        name = "",
        skill = { 240, 480 }
    },
    {
        icon = Material("vgui/mats_jack_awards/3"),
        name = "",
        skill = { 120, 240 }
    },
    {
        icon = Material("vgui/mats_jack_awards/2"),
        name = "",
        skill = { 60, 120 }
    },
    {
        icon = Material("vgui/mats_jack_awards/1"),
        name = "",
        skill = { 0, 60 }
    },
}

for i, b in ipairs(zb.Experience.Bands) do
    if b.name == "" then b.name = tostring(i) end
end

local SHTable = zb.Experience

function zb.Experience.GetAwards( self )
    local skill = self.skill or 0
    local exp = self.exp or 0
    --print(skill,exp)
    --print(MedalTab.skill[1])
    local Medal = nil
    for i = 1, #SHTable.SkillMedals do
        local MedalTab = SHTable.SkillMedals[i]
        if skill >= tonumber( MedalTab.skill[1] ) and skill < tonumber( MedalTab.skill[2] ) then 
            Medal = table.Copy( MedalTab )
            break 
        end
    end

    local Band = nil
    for i = 1, #SHTable.Bands do
        local BandTab = SHTable.Bands[i]
        if exp >= tonumber( BandTab.skill[1] ) and exp < tonumber( BandTab.skill[2] ) then 
            Band = table.Copy( BandTab )
            break 
        end
    end
    

    return Band, Medal
end


local plyMeta = FindMetaTable("Player")

function plyMeta:GetAwards()
    if CLIENT then
        net.Start("zb_xp_get")
            net.WriteEntity(self)
        net.SendToServer()
    end
    return zb.Experience.GetAwards( self )
end

function plyMeta:GetStatVal(dataName, fallback)
    if not CLIENT then return end
    net.Start("get_svPData")
        net.WriteEntity( self )
        net.WriteString( dataName )
    net.SendToServer()
    if self.SvDB and self.SvDB[dataName] then
        return self.SvDB[dataName] 
    end
    return fallback
end

if SERVER then
    util.AddNetworkString("get_svPData")

    net.Receive( "get_svPData", function( len, ply )
        local ent = net.ReadEntity()
        local dataName = net.ReadString()
        if not ent["Get"..dataName] then return end
        net.Start("get_svPData")
            net.WriteEntity( ent )
            net.WriteString( dataName )
            net.WriteFloat( ent["Get"..dataName] and ent["Get"..dataName](ent) or 0 )
        net.Send(ply)
    end)

    hook.Add("PlayerDeath","ZB_GiveKills", function(ply, infl, attacker)
        if engine.ActiveGamemode() ~= "zcity" then return end
        timer.Simple(.1,function()
            if not IsValid(ply) then return end
            local most_harm,biggest_attacker = 0,nil
                --print(ply)
            for attacker,attacker_harm in pairs((zb.HarmDone and zb.HarmDone[ply]) or {}) do
                --print(attacker)
                if not IsValid(attacker) then continue end
                if most_harm < attacker_harm then
                    most_harm = attacker_harm
                    biggest_attacker = attacker
                end
            end
            -- Фолбэк для режимов без zb.HarmDone (сандбокс): берём атакера напрямую из PlayerDeath
            if not IsValid(biggest_attacker) and IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply then
                biggest_attacker = attacker
            end
            ply:GiveDeaths(1)
            if IsValid(biggest_attacker) then
                if biggest_attacker == ply then
                    biggest_attacker:GiveSuicides(1)
                else
                    biggest_attacker:GiveKills(1)
                end
            end
        end)
    end)

    -- Опыт/скилл за стройку и килы в сандбоксе (и прочих гейммодах без своей системы опыта).
    -- В zcity опыт раздаётся режимами, здесь не дублируем.
    local function ZB_IsZCity()
        return engine.ActiveGamemode() == "zcity"
    end

    local ZB_BuildCooldown = 2
    local ZB_lastBuild = {}

    local function ZB_GiveBuildXP(ply)
        if ZB_IsZCity() then return end
        if not IsValid(ply) or not ply:IsPlayer() or not ply.GetSandboxExp then return end
        local t = CurTime()
        if (ZB_lastBuild[ply] or 0) > t then return end
        ZB_lastBuild[ply] = t + ZB_BuildCooldown
        ply:GiveSandboxExp(math.random(1, 3))
        ply:GiveSandboxSkill(math.Rand(0.005, 0.02))
    end

    -- Стройка: спавн пропов/регдоллов/эффектов/SENT/NPC (в т.ч. через Tool Gun)
    hook.Add("PlayerSpawnedProp", "zb_sandbox_build_xp", ZB_GiveBuildXP)
    hook.Add("PlayerSpawnedRagdoll", "zb_sandbox_build_xp_rag", ZB_GiveBuildXP)
    hook.Add("PlayerSpawnedEffect", "zb_sandbox_build_xp_eff", ZB_GiveBuildXP)
    hook.Add("PlayerSpawnedSENT", "zb_sandbox_build_xp_sent", ZB_GiveBuildXP)
    hook.Add("PlayerSpawnedNPC", "zb_sandbox_build_xp_npc", ZB_GiveBuildXP)

    -- Явное использование Tool Gun (применение инструмента к сущности)
    hook.Add("PlayerCanTool", "zb_sandbox_tool_xp", function(ply, tr, toolname)
        ZB_GiveBuildXP(ply)
        return
    end)

    local function ZB_ResolveKiller(attacker, infl)
        local killer = attacker
        if not (IsValid(killer) and killer:IsPlayer()) then
            killer = infl
        end
        if IsValid(killer) and killer:IsPlayer() then return killer end
        return nil
    end

    -- В этом фреймворке параметры PlayerDeath/PlayerTakeDamage и zb.HarmDone ненадёжны
    -- (в PlayerDeath приходит сама жертва, HarmDone не наполняется в сандбоксе).
    -- Самый надёжный источник реального атакера — EntityTakeDamage + dmgInfo:GetAttacker(),
    -- который файрит для всех сущностей (включая fake-ragdoll систему homigrad).
    local ZB_LastDamager = {}
    local ZB_LastDamageTime = {}

    hook.Add("EntityTakeDamage", "zb_sandbox_damage_tracker", function(ent, dmgInfo)
        if ZB_IsZCity() then return end
        if not IsValid(ent) then return end

        -- Реальная жертва: игрок, NPC, либо владелец fake-ragdoll'а
        local victim = nil
        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
            victim = ent
        else
            victim = (hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or nil
            if not IsValid(victim) then return end
        end

        local attacker = dmgInfo:GetAttacker()
        if not IsValid(attacker) then return end

        local dmgAttacker = attacker
        if not dmgAttacker:IsPlayer() then
            -- Проп/тул-ганг: пробуем взять владельца inflictor
            local infl = dmgInfo:GetInflictor()
            local owner = (IsValid(infl) and infl.GetOwner and infl:GetOwner()) or nil
            if IsValid(owner) and owner:IsPlayer() then
                dmgAttacker = owner
            else
                return
            end
        end

        -- Самоурон: считаем суицидом только если активен флаг ply.suiciding
        -- (команда suicide в этом фреймворке — это toggled флаг, смерть приходит
        -- от самострела с Attacker=Entity(0), пока suiciding ещё true).
        -- Обычный самоурон (падение и т.п.) suiciding == false → не суицид.
        if dmgAttacker == victim then
            if victim.suiciding then
                ZB_LastDamager[victim] = victim
                ZB_LastDamageTime[victim] = CurTime()
            end
            return
        end

        ZB_LastDamager[victim] = dmgAttacker
        ZB_LastDamageTime[victim] = CurTime()
    end)

    hook.Add("PlayerSpawn", "zb_sandbox_reset_damager", function(ply)
        ZB_LastDamager[ply] = nil
        ZB_LastDamageTime[ply] = nil
    end)

    hook.Add("PlayerDeath", "zb_sandbox_kill_xp", function(victim, infl, attacker)
        if ZB_IsZCity() then return end
        if not IsValid(victim) or not victim.GetSandboxDeaths then return end

        victim:GiveSandboxDeaths(1)

        -- Киллер из отслеживания урона (EntityTakeDamage) — самый надёжный источник
        local killer = nil
        local lastDmgTime = ZB_LastDamageTime[victim] or -10
        if IsValid(ZB_LastDamager[victim]) and (CurTime() - lastDmgTime) < 10 then
            killer = ZB_LastDamager[victim]
        elseif IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
            -- Фолбэк: прямой атакер из PlayerDeath (исключаем самого жертву)
            killer = attacker
        end

        ZB_LastDamager[victim] = nil
        ZB_LastDamageTime[victim] = nil

        if IsValid(killer) and killer == victim then
            -- Самоубийство (команда suicide: урон самим себе при включённом suiciding)
            victim:GiveSandboxSuicides(1)
        elseif IsValid(killer) then
            killer:GiveSandboxKills(1)
            killer:GiveSandboxExp(math.random(10, 20))
            killer:GiveSandboxSkill(math.Rand(0.05, 0.15))
        end
        -- Смерть от мира без игрока-атакера — только deaths, без суицида
    end)

    -- Убийство NPC тоже даёт опыт/килы в сандбоксе
    hook.Add("OnNPCKilled", "zb_sandbox_npc_xp", function(npc, attacker, infl)
        if ZB_IsZCity() then return end
        local killer = ZB_LastDamager[npc]
        if not IsValid(killer) then killer = ZB_ResolveKiller(attacker, infl) end
        ZB_LastDamager[npc] = nil
        if not IsValid(killer) then return end
        killer:GiveSandboxKills(1)
        killer:GiveSandboxExp(math.random(10, 20))
        killer:GiveSandboxSkill(math.Rand(0.05, 0.15))
    end)
else
    net.Receive( "get_svPData", function()
        local ent = net.ReadEntity()
        local dataName = net.ReadString()
        local dataType = net.ReadFloat()
        ent.SvDB = ent.SvDB or {}
        ent.SvDB[dataName] = dataType
        if IsValid(zb.Experience.OpenedAccount) then
            zb.Experience.OpenedAccount:Udpate(ent)
        end
    end)
end