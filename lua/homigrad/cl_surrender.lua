if not CLIENT then return end
hg = hg or {}
if hg._zsh_surrender_cl_loaded then return end
hg._zsh_surrender_cl_loaded = true

if not GetConVar("surrender_text") then
    CreateClientConVar("surrender_text", "1", true, false, "Show surrender/kneel chat messages (1=on, 0=off)")
end
if not GetConVar("surrender_voicel") then
    CreateClientConVar("surrender_voicel", "1", true, false, "Play scared voice line when surrendering (1=on, 0=off)")
end
local function SurrText()   return GetConVar("surrender_text"):GetBool()   end
local function SurrVoicel() return GetConVar("surrender_voicel"):GetBool() end

local SURR_VARIANTS = {
    { "G_Surrender",  "g_surrenderloopArms",  "G_Surrenderend"  },
    { "G_Surrender2", "g_surrenderloopArms2", "G_Surrenderend2" },
    { "G_Surrender3", "g_surrenderloopArms3", "G_Surrenderend3" },
}
local SURR_RANDOM_MAX = 2

local KNEEL_VARIANTS = {
    { "kneeldown",  "kneeldownloop",  "kneeldownEND"  },
    { "kneeldown2", "kneeldown2loop", "kneeldown2END" },
    { "kneeldown3", "kneeldown3loop", "kneeldown3end" },
}

local KNEEL_HBH_TRANSITIONS = {
    [1] = { "kneeldownTransition",  "kneeldownTransitionBack"  },
    [2] = { "kneeldown2Transition", "kneeldown2TransitionBack" },
}

local SURR_BEGIN_DURATION      = 0.8
local SURR_LOOP_DURATION       = 1.8
local SURR_EXIT_DURATION       = 0.6
local KNEEL_BEGIN_DURATION     = 1.3
local KNEEL_LOOP_DURATION      = 1.8
local KNEEL_EXIT_DURATION      = 1.3
local INTERRUPT_HOLD_TIME      = 0.5
local HBH_KNEEL_TRANSITION_DURATION = 0.39
local HBH_TRANSITION_TIME  = 0.5

local KNEEL_CD        = 2.0
local HBH_CD          = 1.2
local SURR_CD_TIME    = 4.0
local STAND_CD        = 1.5
local WEAPON_LOCK_TIME = 10

local MIN_SURRENDER_TIME = 5.0

net.Receive("hg_surrender_min_time_sync", function()
    local newVal = net.ReadFloat()
    MIN_SURRENDER_TIME = newVal
    local ply = LocalPlayer()
    if IsValid(ply) and SurrText() then
        ply:ChatPrint("[Surrender] Minimum hold time updated to " .. newVal .. "s by the server.")
    end
end)

local kneelCD         = 0
local hbhCD           = 0
local standCD         = 0

local SURR_SLOT  = GESTURE_SLOT_ATTACK_AND_RELOAD
local KNEEL_SLOT = GESTURE_SLOT_CUSTOM

local surrenderCD             = 0
local inSurrender             = false
local currentSurrVariantIndex  = 1
local previousSurrVariantIndex = 1
local inHandsBehindHead       = false
local hbhTransitioning        = false
local surrenderStartTime      = 0
local surrenderInterruptAllow = 0

local inKneel                 = false
local kneelExiting            = false
local kneelReady              = false
local currentKneelVariantIndex = 1
local kneelBaseYaw            = 0

local weaponAllowTime    = 0
local weaponReachActive  = false
local forcedExiting      = false

local remoteKneeling = {}

local function ResolveSeq(ply, seqName, actFallback)
    local seq = ply:LookupSequence(seqName)
    if seq and seq ~= -1 then return seq, false end
    return actFallback, true
end

local function PlayOnSlot(ply, slot, seqOrAct, actMode, loop)
    if actMode then
        ply:AnimRestartGesture(slot, seqOrAct, loop or false)
    else
        ply:AddVCDSequenceToGestureSlot(slot, seqOrAct, 0, loop or false)
    end
end

local function PlaySurrBegin(ply, vi)
    local v = SURR_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[1], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
    PlayOnSlot(ply, SURR_SLOT, seq, act, false)
end

local function PlaySurrLoop(ply, vi)
    local v = SURR_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[2], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
    PlayOnSlot(ply, SURR_SLOT, seq, act, false)
end

local function PlaySurrExit(ply, vi)
    local v = SURR_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[3], ACT_GMOD_GESTURE_ITEM_PLACE)
    PlayOnSlot(ply, SURR_SLOT, seq, act, false)
    timer.Simple(SURR_EXIT_DURATION, function()
        if IsValid(ply) then ply:AnimResetGestureSlot(SURR_SLOT) end
    end)
end

local function PlayKneelBegin(ply, vi)
    local v = KNEEL_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[1], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
    PlayOnSlot(ply, KNEEL_SLOT, seq, act, false)
end

local function PlayKneelLoop(ply, vi)
    local v = KNEEL_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[2], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
    PlayOnSlot(ply, KNEEL_SLOT, seq, act, false)
end

local function PlayKneelExit(ply, vi)
    local v = KNEEL_VARIANTS[vi]
    if not v then return end
    local seq, act = ResolveSeq(ply, v[3], ACT_GMOD_GESTURE_ITEM_PLACE)
    PlayOnSlot(ply, KNEEL_SLOT, seq, act, false)
    timer.Simple(KNEEL_EXIT_DURATION, function()
        if IsValid(ply) then ply:AnimResetGestureSlot(KNEEL_SLOT) end
    end)
end

local function PlayKneelHBHTransition(ply, baseVI, direction)
    local t = KNEEL_HBH_TRANSITIONS[baseVI]
    if not t then return end
    local seqName = (direction == "enter") and t[1] or t[2]
    local seq, act = ResolveSeq(ply, seqName, ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
    PlayOnSlot(ply, KNEEL_SLOT, seq, act, false)
end

net.Receive("hg_surrender_enter", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    PlaySurrBegin(ply, vi)
    timer.Simple(SURR_BEGIN_DURATION, function() if IsValid(ply) then PlaySurrLoop(ply, vi) end end)
end)

net.Receive("hg_surrender_loop", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    PlaySurrLoop(ply, vi)
end)

net.Receive("hg_surrender_exit", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    PlaySurrExit(ply, vi)
end)

net.Receive("hg_kneel_enter", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    remoteKneeling[ply] = true
    PlayKneelBegin(ply, vi)
    timer.Simple(KNEEL_BEGIN_DURATION, function()
        if IsValid(ply) and remoteKneeling[ply] then PlayKneelLoop(ply, vi) end
    end)
end)

net.Receive("hg_kneel_loop", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    PlayKneelLoop(ply, vi)
end)

net.Receive("hg_kneel_exit", function()
    local ply = net.ReadEntity()
    local vi  = net.ReadUInt(4)
    if not IsValid(ply) or ply == LocalPlayer() then return end
    remoteKneeling[ply] = false
    PlayKneelExit(ply, vi)
end)

net.Receive("hg_kneel_hbh_transition", function()
    local ply     = net.ReadEntity()
    local baseVI  = net.ReadUInt(4)
    local dir     = net.ReadString()
    if not IsValid(ply) or ply == LocalPlayer() then return end
    PlayKneelHBHTransition(ply, baseVI, dir)
end)

hook.Add("SetupMove", "kneel_movement_lock", function(ply, mv)
    if ply ~= LocalPlayer() then return end
    if not inKneel and not kneelExiting then return end
    mv:SetForwardSpeed(0)
    mv:SetSideSpeed(0)
    mv:SetUpSpeed(0)
    local vel = mv:GetVelocity()
    mv:SetVelocity(Vector(0, 0, vel.z))
    local buttons = mv:GetButtons()
    buttons = bit.band(buttons, bit.bnot(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_JUMP))
    mv:SetButtons(buttons)
end)

hook.Add("CreateMove", "kneel_view_limit", function(cmd)
    if not inKneel then return end
    local ang = cmd:GetViewAngles()
    local yawDiff = math.NormalizeAngle(ang.y - kneelBaseYaw)
    yawDiff = math.Clamp(yawDiff, -20, 20)
    ang.y = kneelBaseYaw + yawDiff
    ang.p = math.Clamp(ang.p, -100, 100)
    cmd:SetViewAngles(ang)
end)

local function ForceHands(ply)
    if not IsValid(ply) then return end
    local hands = ply:GetWeapon("weapon_hands_sh")
    if IsValid(hands) then
        hands:Deploy()
    end
end

hook.Add("Think", "surrender_strong_weapon_lock", function()
    local ply = LocalPlayer()
    if not (inSurrender or inKneel) then return end
    if CurTime() >= weaponAllowTime then return end
    ForceHands(ply)
end)

hook.Add("PlayerSwitchWeapon", "surrender_block_switch", function(ply, old, new)
    if ply ~= LocalPlayer() then return end
    if not (inSurrender or inKneel) then return end
    if CurTime() >= weaponAllowTime then return end
    ForceHands(ply)
    return true
end)

hook.Add("PlayerSelectWeapon", "surrender_block_selectweapon", function(ply, class)
    if ply ~= LocalPlayer() then return end
    if not (inSurrender or inKneel) then return end
    if CurTime() >= weaponAllowTime then return end
    ForceHands(ply)
    return true
end)

hook.Add("CreateMove", "surrender_weapon_lock_input", function(cmd)
    if not (inSurrender or inKneel) then return end
    if CurTime() >= weaponAllowTime then return end

    local buttons = cmd:GetButtons()
    buttons = bit.band(buttons, bit.bnot(IN_USE + IN_ATTACK + IN_ATTACK2))
    cmd:SetButtons(buttons)
    cmd:SetImpulse(0)
end)

hook.Add("Think", "surrender_kneel_weapon_watch", function()
    local ply = LocalPlayer()
    if not (inSurrender or inKneel or kneelExiting) then
        weaponReachActive = false
        return
    end
    if weaponReachActive or CurTime() < weaponAllowTime then return end

    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() ~= "weapon_hands_sh" then
        weaponReachActive = true
        if inKneel then
            ExitKneel(ply, true)
            timer.Simple(KNEEL_EXIT_DURATION * 0.6, function()
                if inSurrender then ExitSurrender(ply, true) end
                timer.Simple(SURR_EXIT_DURATION, function() weaponReachActive = false end)
            end)
        else
            ExitSurrender(ply, true)
            timer.Simple(SURR_EXIT_DURATION, function() weaponReachActive = false end)
        end
    end
end)

local function StartSurrenderLoop(ply, vi)
    if not inSurrender then return end
    PlaySurrLoop(ply, vi)
    timer.Create("surrender_loop_timer", SURR_LOOP_DURATION, 0, function()
        if not inSurrender or not IsValid(ply) then
            timer.Remove("surrender_loop_timer")
            return
        end
        PlaySurrLoop(ply, currentSurrVariantIndex)
        net.Start("hg_surrender_loop") net.WriteUInt(currentSurrVariantIndex, 4) net.SendToServer()
    end)
end

local function CanExitSurrender()
    return CurTime() >= (surrenderStartTime + MIN_SURRENDER_TIME)
end

local function ExitSurrender(ply, silent)
    if not inSurrender then return end
    if not CanExitSurrender() then
        if SurrText() then ply:ChatPrint("You cannot lower your hands yet! ("..math.ceil(surrenderStartTime + MIN_SURRENDER_TIME - CurTime()).."s)") end
        return
    end

    inSurrender = false
    inHandsBehindHead = false
    hbhTransitioning = false
    timer.Remove("surrender_loop_timer")
    timer.Remove("hbh_transition_timer")
    PlaySurrExit(ply, currentSurrVariantIndex)
    net.Start("hg_surrender_exit") net.WriteUInt(currentSurrVariantIndex, 4) net.SendToServer()
    currentSurrVariantIndex  = 1
    previousSurrVariantIndex = 1
    if not silent and SurrText() then ply:ChatPrint("You lower your hands.") end
end

local function EnterSurrender(ply)
    local vi = math.random(SURR_RANDOM_MAX)
    currentSurrVariantIndex  = vi
    previousSurrVariantIndex = vi
    inSurrender = true
    inHandsBehindHead = false
    surrenderStartTime = CurTime()
    surrenderInterruptAllow = CurTime() + INTERRUPT_HOLD_TIME
    weaponAllowTime = CurTime() + WEAPON_LOCK_TIME

    PlaySurrBegin(ply, vi)
    net.Start("hg_surrender_enter") net.WriteUInt(vi, 4) net.SendToServer()

    local scaredLines = {
        "vo/episode_1/npc/male01/cit_evac_casualty10.wav", "vo/npc/male01/ohno.wav",
        "vo/npc/male01/startle01.wav", "vo/npc/male01/startle02.wav",
        "vo/episode_1/npc/male01/cit_alert_head06.wav", "vo/episode_1/npc/male01/cit_buddykilled04.wav",
        "vo/episode_1/npc/male01/cit_evac_casualty09.wav"
    }
    local phrase = scaredLines[math.random(#scaredLines)]
    if ThatPlyIsFemale(ply) then phrase = string.Replace(phrase, "male01", "female01") end
    local muffed = ply.armors and ply.armors["face"] == "mask2"
    local pitch  = ply.VoicePitch or 100

    if SurrVoicel() then
        net.Start("hg_surrender_voice")
            net.WriteString(phrase)
            net.WriteBool(muffed)
            net.WriteUInt(pitch, 8)
        net.SendToServer()
    end

    if (ply.NextFoley or 0) < CurTime() then
        ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
        ply.NextFoley = CurTime() + 2.5
    end

    if SurrText() then ply:ChatPrint("You raise your hands.") end

    timer.Create("surrender_begin_timer", SURR_BEGIN_DURATION, 1, function()
        if IsValid(ply) and inSurrender then StartSurrenderLoop(ply, vi) end
    end)
end

local function DoHandsBehindHeadTransition(ply, fromVI, toVI, onComplete)
    hbhTransitioning = true
    timer.Remove("surrender_loop_timer")
    timer.Remove("kneel_loop_timer")
    timer.Remove("hbh_transition_timer")

    if inKneel then
        local baseVI = (toVI == 3) and fromVI or toVI
        local direction = (toVI == 3) and "enter" or "exit"

        PlayKneelHBHTransition(ply, baseVI, direction)
        net.Start("hg_kneel_hbh_transition")
            net.WriteUInt(baseVI, 4)
            net.WriteString(direction)
        net.SendToServer()

        local vTo = SURR_VARIANTS[toVI]
        if vTo then
            local seq, act = ResolveSeq(ply, vTo[1], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
            PlayOnSlot(ply, SURR_SLOT, seq, act, false)
            net.Start("hg_surrender_enter") net.WriteUInt(toVI, 4) net.SendToServer()
        end

        timer.Create("hbh_transition_timer", HBH_KNEEL_TRANSITION_DURATION, 1, function()
            if not IsValid(ply) or not inSurrender then hbhTransitioning = false return end
            hbhTransitioning = false
            currentSurrVariantIndex  = toVI
            currentKneelVariantIndex = toVI

            PlayKneelLoop(ply, toVI)
            net.Start("hg_kneel_loop") net.WriteUInt(toVI, 4) net.SendToServer()

            timer.Create("kneel_loop_timer", KNEEL_LOOP_DURATION, 0, function()
                if not inKneel or not IsValid(ply) then timer.Remove("kneel_loop_timer") return end
                PlayKneelLoop(ply, currentKneelVariantIndex)
                net.Start("hg_kneel_loop") net.WriteUInt(currentKneelVariantIndex, 4) net.SendToServer()
            end)

            if onComplete then onComplete() end
            StartSurrenderLoop(ply, toVI)
        end)
    else
        local vFrom = SURR_VARIANTS[fromVI]
        if vFrom then
            local seq, act = ResolveSeq(ply, vFrom[3], ACT_GMOD_GESTURE_ITEM_PLACE)
            PlayOnSlot(ply, SURR_SLOT, seq, act, false)
            net.Start("hg_surrender_exit") net.WriteUInt(fromVI, 4) net.SendToServer()
        end

        timer.Create("hbh_transition_timer", HBH_TRANSITION_TIME, 1, function()
            if not IsValid(ply) or not inSurrender then hbhTransitioning = false return end

            local vTo = SURR_VARIANTS[toVI]
            if vTo then
                local seq, act = ResolveSeq(ply, vTo[1], ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
                PlayOnSlot(ply, SURR_SLOT, seq, act, false)
                net.Start("hg_surrender_enter") net.WriteUInt(toVI, 4) net.SendToServer()
            end

            timer.Simple(SURR_BEGIN_DURATION, function()
                if not IsValid(ply) or not inSurrender then hbhTransitioning = false return end
                hbhTransitioning = false
                currentSurrVariantIndex = toVI
                if onComplete then onComplete() end
                StartSurrenderLoop(ply, toVI)
            end)
        end)
    end
end

local function EnterHandsBehindHead(ply)
    if not inSurrender or hbhTransitioning or CurTime() < hbhCD or inHandsBehindHead then return end
    if inKneel and not kneelReady then return end
    hbhCD = CurTime() + HBH_CD
    local fromVI = currentSurrVariantIndex
    previousSurrVariantIndex = fromVI
    DoHandsBehindHeadTransition(ply, fromVI, 3, function()
        inHandsBehindHead = true
        if SurrText() then ply:ChatPrint("You put your hands behind your head.") end
    end)
end

local function ExitHandsBehindHead(ply)
    if not inSurrender or not inHandsBehindHead or hbhTransitioning or CurTime() < hbhCD then return end
    if inKneel and not kneelReady then return end
    hbhCD = CurTime() + HBH_CD
    local toVI = previousSurrVariantIndex
    DoHandsBehindHeadTransition(ply, 3, toVI, function()
        inHandsBehindHead = false
        if SurrText() then ply:ChatPrint("You raise your hands back up.") end
    end)
end

local function StartKneelLoop(ply, vi)
    if not inKneel then return end
    PlayKneelLoop(ply, vi)
    timer.Create("kneel_loop_timer", KNEEL_LOOP_DURATION, 0, function()
        if not inKneel or not IsValid(ply) then timer.Remove("kneel_loop_timer") return end
        PlayKneelLoop(ply, currentKneelVariantIndex)
        net.Start("hg_kneel_loop") net.WriteUInt(currentKneelVariantIndex, 4) net.SendToServer()
    end)
end

local function ExitKneel(ply, silent)
    if not inKneel then return end
    if CurTime() < kneelCD then return end
    if inSurrender and not CanExitSurrender() then
        if SurrText() then ply:ChatPrint("You cannot stand up yet! ("..math.ceil(surrenderStartTime + MIN_SURRENDER_TIME - CurTime()).."s)") end
        return
    end

    kneelCD = CurTime() + KNEEL_CD
    standCD = CurTime() + STAND_CD

    inKneel = false
    kneelReady = false
    kneelExiting = true
    timer.Remove("kneel_loop_timer")
    timer.Remove("kneel_begin_timer")

    PlayKneelExit(ply, currentKneelVariantIndex)
    net.Start("hg_kneel_exit") net.WriteUInt(currentKneelVariantIndex, 4) net.SendToServer()

    if (ply.NextFoley or 0) < CurTime() then
        ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
        ply.NextFoley = CurTime() + 2.5
    end

    net.Start("hg_kneel_hull") net.WriteBool(false) net.SendToServer()

    timer.Create("kneel_exit_timer", KNEEL_EXIT_DURATION, 1, function()
        kneelExiting = false
        if IsValid(ply) and not silent and SurrText() then
            ply:ChatPrint("You stand back up.")
        end
    end)
    currentKneelVariantIndex = 1
end

local function EnterKneel(ply)
    if CurTime() < kneelCD or CurTime() < standCD then return end
    kneelCD = CurTime() + KNEEL_CD

    local vi = currentSurrVariantIndex
    currentKneelVariantIndex = vi

    inKneel = true
    kneelExiting = false
    kneelReady = false
    kneelBaseYaw = ply:EyeAngles().y
    weaponAllowTime = math.max(weaponAllowTime, CurTime() + WEAPON_LOCK_TIME)

    PlayKneelBegin(ply, vi)
    net.Start("hg_kneel_enter") net.WriteUInt(vi, 4) net.SendToServer()

    if (ply.NextFoley or 0) < CurTime() then
        ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
        ply.NextFoley = CurTime() + 2.5
    end

    if SurrText() then ply:ChatPrint("You kneel down.") end

    timer.Create("kneel_begin_timer", KNEEL_BEGIN_DURATION, 1, function()
        if not IsValid(ply) or not inKneel then return end
        kneelReady = true
        StartKneelLoop(ply, vi)
        net.Start("hg_kneel_hull") net.WriteBool(true) net.SendToServer()

        if inSurrender then
            timer.Simple(0.1, function()
                if IsValid(ply) and inSurrender then
                    PlaySurrLoop(ply, currentSurrVariantIndex)
                end
            end)
        end
    end)
end

local function EnterKneelWithSurrender(ply)
    EnterSurrender(ply)
    timer.Simple(0.25, function()
        if IsValid(ply) then EnterKneel(ply) end
    end)
end

hg = hg or {}

function hg.GetSurrenderRadialOption(ply)
    ply = ply or LocalPlayer()
    if not IsValid(ply) then return end
    if not ply:Alive() or (ply.organism and ply.organism.otrub) or hg.GetCurrentCharacter(ply) ~= ply then return end

    if kneelExiting then
        return { function() return -1 end, "Getting Up..." }
    end

    if hbhTransitioning then
        return { function() return -1 end, "..." }
    end

    if inKneel then
        return {
            function(mouseClick)
                if mouseClick == 2 then
                    if inHandsBehindHead then
                        hg.CreateRadialMenu({
                            { function() ExitKneel(ply) end,           "Stand Up"          },
                            { function() ExitHandsBehindHead(ply) end, "Hands Up (normal)" },
                        })
                    else
                        hg.CreateRadialMenu({
                            { function() ExitKneel(ply) end,            "Stand Up"          },
                            { function() EnterHandsBehindHead(ply) end, "Hands Behind Head" },
                        })
                    end
                    return -1
                else
                    ExitKneel(ply)
                end
            end,
            inHandsBehindHead and "Kneeling + Hands Behind Head\nRMB - Options" or "Kneeling + Hands Up\nRMB - Options"
        }
    end

    if inSurrender then
        return {
            function(mouseClick)
                if mouseClick == 2 then
                    if inHandsBehindHead then
                        hg.CreateRadialMenu({
                            { function() ExitSurrender(ply) end,       "Stop Surrendering"  },
                            { function() EnterKneel(ply) end,          "Kneel Down"         },
                            { function() ExitHandsBehindHead(ply) end, "Hands Up (normal)"  },
                        })
                    else
                        hg.CreateRadialMenu({
                            { function() ExitSurrender(ply) end,        "Stop Surrendering" },
                            { function() EnterKneel(ply) end,           "Kneel Down"        },
                            { function() EnterHandsBehindHead(ply) end, "Hands Behind Head" },
                        })
                    end
                    return -1
                else
                    ExitSurrender(ply)
                end
            end,
            inHandsBehindHead and "Surrendering (Hands Behind Head)\nRMB - Options" or "Surrendering\nRMB - Options"
        }
    else
        local wep = ply:GetActiveWeapon()
        local hasWeapon = IsValid(wep) and wep:GetClass() ~= "weapon_hands_sh"
        return {
            function(mouseClick)
                if CurTime() < surrenderCD then return -1 end
                surrenderCD = CurTime() + SURR_CD_TIME
                if mouseClick == 2 then
                    if hasWeapon then RunConsoleCommand("dropweapon") end
                    timer.Simple(0.15, function() if IsValid(ply) then EnterKneelWithSurrender(ply) end end)
                else
                    if hasWeapon then RunConsoleCommand("dropweapon") end
                    timer.Simple(0.15, function() if IsValid(ply) then EnterSurrender(ply) end end)
                end
            end,
            "Surrender\nRMB - Kneel+Surrender"
        }
    end
end

hook.Add("Think", "surr_kneel_attack_cancel", function()
    local ply = LocalPlayer()
    if not (inSurrender or inKneel) or forcedExiting then return end
    if gui.IsGameUIVisible() or vgui.CursorVisible() then return end

    if input.IsMouseDown(MOUSE_LEFT) and CurTime() > surrenderStartTime + 0.3 then
        forcedExiting = true
        weaponAllowTime = math.max(weaponAllowTime, CurTime() + 5)

        if inKneel and inSurrender then
            ExitKneel(ply, true)
            timer.Simple(KNEEL_EXIT_DURATION, function()
                if IsValid(ply) and inSurrender then ExitSurrender(ply) end
                forcedExiting = false
            end)
        elseif inKneel then
            ExitKneel(ply)
            timer.Simple(KNEEL_EXIT_DURATION, function() forcedExiting = false end)
        elseif inSurrender then
            ExitSurrender(ply)
            timer.Simple(SURR_EXIT_DURATION, function() forcedExiting = false end)
        end
    end
end)

hook.Add("PlayerBindPress", "surrender_block_punch", function(ply, bind, pressed)
    if ply ~= LocalPlayer() then return end
    if not (inSurrender or inKneel) then return end
    if string.find(bind, "+attack") then
        return true
    end
end)

local function SurrenderForceReset(ply)
    if ply ~= LocalPlayer() or not inSurrender then return end
    timer.Remove("surrender_loop_timer")
    timer.Remove("surrender_begin_timer")
    timer.Remove("hbh_transition_timer")
    if IsValid(ply) then ply:AnimResetGestureSlot(SURR_SLOT) end
    inSurrender = false
    inHandsBehindHead = false
    hbhTransitioning = false
    currentSurrVariantIndex  = 1
    previousSurrVariantIndex = 1
    forcedExiting = false
    weaponReachActive = false
    weaponAllowTime = 0
end

local function KneelForceReset(ply)
    if ply ~= LocalPlayer() or (not inKneel and not kneelExiting) then return end
    timer.Remove("kneel_loop_timer")
    timer.Remove("kneel_begin_timer")
    timer.Remove("kneel_exit_timer")
    if IsValid(ply) then ply:AnimResetGestureSlot(KNEEL_SLOT) end
    inKneel = false
    kneelExiting = false
    kneelReady = false
    currentKneelVariantIndex = 1
    kneelBaseYaw = 0
    kneelCD = 0
    standCD = 0
    forcedExiting = false
    weaponReachActive = false
    weaponAllowTime = 0
    net.Start("hg_kneel_hull") net.WriteBool(false) net.SendToServer()
end

hook.Add("HG_OnOtrub",  "surrender_reset", SurrenderForceReset)
hook.Add("PlayerDeath", "surrender_reset_death", SurrenderForceReset)
hook.Add("PlayerSpawn", "surrender_reset_spawn", SurrenderForceReset)
hook.Add("Fake", "surrender_reset_ragdoll", function(ply)
    if ply == LocalPlayer() then SurrenderForceReset(ply) end
end)

hook.Add("HG_OnOtrub",  "kneel_reset", KneelForceReset)
hook.Add("PlayerDeath", "kneel_reset_death", KneelForceReset)
hook.Add("PlayerSpawn", "kneel_reset_spawn", KneelForceReset)
hook.Add("Fake", "kneel_reset_ragdoll", function(ply)
    if ply == LocalPlayer() then KneelForceReset(ply) end
end)

concommand.Add("surrender_toggle", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() or (ply.organism and ply.organism.otrub) or hg.GetCurrentCharacter(ply) ~= ply then return end

    if inSurrender then
        ExitSurrender(ply)
    else
        if CurTime() < surrenderCD then return end
        surrenderCD = CurTime() + SURR_CD_TIME
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() ~= "weapon_hands_sh" then RunConsoleCommand("dropweapon") end
        timer.Simple(0.15, function() if IsValid(ply) then EnterSurrender(ply) end end)
    end
end)

concommand.Add("kneel_toggle", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() or (ply.organism and ply.organism.otrub) or hg.GetCurrentCharacter(ply) ~= ply then return end

    if inKneel then
        ExitKneel(ply)
    elseif kneelExiting then
        return
    else
        if not inSurrender then
            if CurTime() < surrenderCD then return end
            surrenderCD = CurTime() + SURR_CD_TIME
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() ~= "weapon_hands_sh" then RunConsoleCommand("dropweapon") end
            timer.Simple(0.15, function() if IsValid(ply) then EnterKneelWithSurrender(ply) end end)
        else
            EnterKneel(ply)
        end
    end
end)
