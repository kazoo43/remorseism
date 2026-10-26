hg = hg or {}

local HITSTOP_NET = "hg_hitstop"

if SERVER then
    util.AddNetworkString(HITSTOP_NET)

    function hg.Hitstop(attacker, target, duration, position)
        if not IsValid(attacker) or not IsValid(target) then return end
        if duration <= 0 then return end

        local weapon = attacker:GetActiveWeapon()
        if not IsValid(weapon) then return end

        net.Start(HITSTOP_NET)
            net.WriteEntity(attacker)
            net.WriteEntity(target)
            net.WriteEntity(weapon)
            net.WriteFloat(duration)
        net.SendPVS(position or target:GetPos())
    end
else
    hg.HitstopEntities = hg.HitstopEntities or {}
    hg.HitstopWeapons = hg.HitstopWeapons or {}

    function hg.HitstopVisualTime(wep)
        if not IsValid(wep) or (wep.hgHitstopUntil or 0) <= RealTime() then
            return CurTime()
        end

        local now = RealTime()
        wep.hgHitstopOffset = (wep.hgHitstopOffset or 0) + now - (wep.hgHitstopLastTime or now)
        wep.hgHitstopLastTime = now

        return CurTime() - wep.hgHitstopOffset
    end

    net.Receive(HITSTOP_NET, function()
        local attacker = net.ReadEntity()
        local target = net.ReadEntity()
        local weapon = net.ReadEntity()
        local untilTime = RealTime() + net.ReadFloat()

        if IsValid(attacker) then
            attacker.hgHitstopUntil = math.max(attacker.hgHitstopUntil or 0, untilTime)
            attacker.hgHitstopPlaybackRate = attacker.hgHitstopPlaybackRate or attacker:GetPlaybackRate()
            attacker:SetPlaybackRate(0)
            hg.HitstopEntities[attacker] = true
        end

        if IsValid(target) and not target:IsWorld() then
            target.hgHitstopUntil = math.max(target.hgHitstopUntil or 0, untilTime)
            target.hgHitstopPlaybackRate = target.hgHitstopPlaybackRate or target:GetPlaybackRate()
            target:SetPlaybackRate(0)
            hg.HitstopEntities[target] = true
        end

        local wep = IsValid(weapon) and weapon or IsValid(attacker) and attacker:GetActiveWeapon()
        if IsValid(wep) then
            wep.hgHitstopUntil = math.max(wep.hgHitstopUntil or 0, untilTime)
            wep.hgHitstopOffset = 0
            wep.hgHitstopLastTime = RealTime()
            hg.HitstopWeapons[wep] = true
        end
    end)

    hook.Add("Think", "HG.HitstopRestorePlayback", function()
        local now = RealTime()

        for ent in pairs(hg.HitstopEntities) do
            if not IsValid(ent) then
                hg.HitstopEntities[ent] = nil
            elseif (ent.hgHitstopUntil or 0) <= now then
                ent:SetPlaybackRate(ent.hgHitstopPlaybackRate or 1)
                ent.hgHitstopPlaybackRate = nil
                ent.hgHitstopUntil = nil
                hg.HitstopEntities[ent] = nil
            end
        end

        for wep in pairs(hg.HitstopWeapons) do
            if not IsValid(wep) then
                hg.HitstopWeapons[wep] = nil
            elseif (wep.hgHitstopUntil or 0) <= now then
                wep.hgHitstopUntil = nil
                wep.hgHitstopOffset = nil
                wep.hgHitstopLastTime = nil
                hg.HitstopWeapons[wep] = nil
            end
        end
    end)
end
