if SERVER then
    local painaddDrainRate = 10
    local adrenalinePainaddPassiveRate = 12
    local adrenalinePainaddPassiveCap = 1
    local adrenalinePainaddPassiveMin = 15

    hook.Add("Org Think", "ImmediatePainApply", function(owner, org, timeValue)
        if not org.painadd or org.painadd <= 0 then return end
        local adrenaline = math.min(org.adrenaline or 0, adrenalinePainaddPassiveCap)
        local add = math.min(org.painadd, timeValue * painaddDrainRate)
        local passiveDrain = 0
        if adrenaline > adrenalinePainaddPassiveMin then
            passiveDrain = math.min(org.painadd - add, timeValue * adrenalinePainaddPassiveRate * adrenaline)
        end
        org.avgpain = math.min(org.avgpain + add, 150)
        org.painadd = math.max(org.painadd - add - passiveDrain, 0)
        org.pain = org.avgpain * math.max(1 - (org.adrenaline or 0) / 4, 0.75) * math.max(1 - (org.analgesia or 0), 0)
        org.pain = math.min(org.pain, 150)
    end, HOOK_MONITOR_HIGH)
    hook.Add("Org Think", "ImmediatePainDrainBoost", function(owner, org, timeValue)
        if org.avgpain <= 0 then return end
        local extraSub = timeValue * ( (org.painkiller or 0) * 2 + (org.analgesia or 0) * 4 ) * 2
        if org.naloxone and org.naloxone > 0 then
            extraSub = extraSub * math.max(0, 1 - org.naloxone * 0.5)
        end
        org.avgpain = math.max(org.avgpain - extraSub, 0)
        org.pain = org.avgpain * math.max(1 - (org.adrenaline or 0) / 4, 0.75) * math.max(1 - (org.analgesia or 0), 0)
        org.pain = math.min(org.pain, 150)
    end, HOOK_MONITOR_LOW)
end
