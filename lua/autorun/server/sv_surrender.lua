if not SERVER then return end
hg = hg or {}
if hg._zsh_surrender_sv_loaded then return end
hg._zsh_surrender_sv_loaded = true
util.AddNetworkString("hg_surrender_enter")
util.AddNetworkString("hg_surrender_exit")
util.AddNetworkString("hg_surrender_loop")
util.AddNetworkString("hg_surrender_voice")
util.AddNetworkString("hg_kneel_enter")
util.AddNetworkString("hg_kneel_exit")
util.AddNetworkString("hg_kneel_loop")
util.AddNetworkString("hg_kneel_hull")
util.AddNetworkString("hg_kneel_hbh_transition")
util.AddNetworkString("hg_kneel_state")
util.AddNetworkString("hg_surrender_min_time_sync")

local kneelingPlayers = {}
local kneelTransition = {}
local kneelLockedPos = {}

local SURRENDER_MIN_TIME_CVAR = CreateConVar(
    "surrender_min_time",
    "5",
    FCVAR_NOTIFY + FCVAR_REPLICATED,
    "Minimum seconds a player must stay surrendered before they can lower their hands.",
    0,
    300
)

local function SyncMinTimeTo(ply)
    net.Start("hg_surrender_min_time_sync")
        net.WriteFloat(SURRENDER_MIN_TIME_CVAR:GetFloat())
    net.Send(ply)
end

cvars.AddChangeCallback("surrender_min_time", function(name, old, new)
    local value = tonumber(new) or 5
    net.Start("hg_surrender_min_time_sync")
        net.WriteFloat(value)
    net.Broadcast()
    print("[Surrender + Kneel] surrender_min_time changed to " .. value .. "s")
end, "surrender_min_time_broadcast")

hook.Add("PlayerInitialSpawn", "surrender_min_time_join_sync", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then SyncMinTimeTo(ply) end
    end)
end)

local SURR_VARIANTS = {
    { "G_Surrender",  "g_surrenderloopArms",  "G_Surrenderend"  },
    { "G_Surrender2", "g_surrenderloopArms2", "G_Surrenderend2" },
    { "G_Surrender3", "g_surrenderloopArms3", "G_Surrenderend3" },
}

local KNEEL_VARIANTS = {
    { "kneeldown",  "kneeldownloop",  "kneeldownEND"  },
    { "kneeldown2", "kneeldown2loop", "kneeldown2END" },
    { "kneeldown3", "kneeldown3loop", "kneeldown3end" },
}

local KNEEL_HBH_TRANSITIONS = {
    [1] = { "kneeldownTransition",  "kneeldownTransitionBack"  },
    [2] = { "kneeldown2Transition", "kneeldown2TransitionBack" },
}

local SURR_SLOT  = GESTURE_SLOT_ATTACK_AND_RELOAD
local KNEEL_SLOT = GESTURE_SLOT_CUSTOM

local SURR_EXIT_DURATION  = 0.6
local KNEEL_EXIT_DURATION = 1.3

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

net.Receive("hg_surrender_enter", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local variantIndex = net.ReadUInt(4)
    PlaySurrBegin(ply, variantIndex)
    net.Start("hg_surrender_enter")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_surrender_loop", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local variantIndex = net.ReadUInt(4)
    PlaySurrLoop(ply, variantIndex)
    net.Start("hg_surrender_loop")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_surrender_exit", function(len, ply)
    if not IsValid(ply) then return end
    local variantIndex = net.ReadUInt(4)
    PlaySurrExit(ply, variantIndex)
    net.Start("hg_surrender_exit")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_surrender_voice", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local phrase = net.ReadString()
    local muffed = net.ReadBool()
    local pitch  = net.ReadUInt(8)
    local ent    = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
    ent:EmitSound(phrase, muffed and 75 or 85, pitch, 1, CHAN_AUTO, 0, muffed and 14 or 0)
end)

net.Receive("hg_kneel_enter", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local variantIndex = net.ReadUInt(4)
    kneelingPlayers[ply] = true
    kneelTransition[ply] = CurTime() + 1.5
    kneelLockedPos[ply] = ply:GetPos()
    PlayKneelBegin(ply, variantIndex)
    
    ply.Kneeling = true
    ply:SetNWBool("Kneeling", true)
    
    net.Start("hg_kneel_enter")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_kneel_loop", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local variantIndex = net.ReadUInt(4)
    PlayKneelLoop(ply, variantIndex)
    net.Start("hg_kneel_loop")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_kneel_exit", function(len, ply)
    if not IsValid(ply) then return end
    local variantIndex = net.ReadUInt(4)
    kneelingPlayers[ply] = nil
    kneelTransition[ply] = CurTime() + 1.3
    kneelLockedPos[ply] = nil
    PlayKneelExit(ply, variantIndex)
    
    ply.Kneeling = false
    ply:SetNWBool("Kneeling", false)
    
    net.Start("hg_kneel_exit")
        net.WriteEntity(ply)
        net.WriteUInt(variantIndex, 4)
    net.SendOmit(ply)
end)

net.Receive("hg_kneel_hbh_transition", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local baseVI    = net.ReadUInt(4)
    local direction = net.ReadString()
    PlayKneelHBHTransition(ply, baseVI, direction)
    net.Start("hg_kneel_hbh_transition")
        net.WriteEntity(ply)
        net.WriteUInt(baseVI, 4)
        net.WriteString(direction)
    net.SendOmit(ply)
end)

net.Receive("hg_kneel_hull", function(len, ply)
    if not IsValid(ply) then return end
    local doKneel = net.ReadBool()
    if doKneel then
        kneelLockedPos[ply] = ply:GetPos()
    else
        kneelLockedPos[ply] = nil
    end
end)

hook.Add("SetupMove", "kneel_movement_lock_server", function(ply, mv, cmd)
    local isKneeling   = kneelingPlayers[ply]
    local inTransition = kneelTransition[ply] and kneelTransition[ply] > CurTime()

    if not (isKneeling or inTransition) then return end

    mv:SetForwardSpeed(0)
    mv:SetSideSpeed(0)
    mv:SetUpSpeed(0)
    local vel = mv:GetVelocity()
    mv:SetVelocity(Vector(0, 0, vel.z))

    local buttons = mv:GetButtons()
    buttons = bit.band(buttons, bit.bnot(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_JUMP))
    mv:SetButtons(buttons)
end)

hook.Add("FinishMove", "kneel_position_lock_server", function(ply, mv)
    local locked = kneelLockedPos[ply]
    if not locked then return end
    local cur = ply:GetPos()
    if cur.x ~= locked.x or cur.y ~= locked.y then
        ply:SetPos(Vector(locked.x, locked.y, cur.z))
    end
end)

local function ClearKneelState(ply)
    if not IsValid(ply) then return end
    kneelingPlayers[ply] = nil
    kneelTransition[ply] = nil
    kneelLockedPos[ply]  = nil
    ply.Kneeling = false
    ply:SetNWBool("Kneeling", false)
end

hook.Add("PlayerDisconnected", "kneel_cleanup",        ClearKneelState)
hook.Add("PlayerDeath",        "kneel_cleanup_death",   ClearKneelState)
hook.Add("PlayerSpawn",        "kneel_cleanup_spawn",   ClearKneelState)

hook.Add("Fake", "kneel_cleanup_ragdoll", function(ply)
    ClearKneelState(ply)
end)

-- if this breaks its not my fault, also why are you here ?
print("ZCITY / Surrender Made by adodser! c:")
