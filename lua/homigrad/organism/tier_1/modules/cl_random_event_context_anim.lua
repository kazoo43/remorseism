local CONTEXT_HAND_POSES = {
    sneeze = {
        hand = "left",
        offset = Vector(6, 3.5, -3),
        handAng = Angle(0, 90, -50),
        fist = 0.7,
    },
    cough = {
        hand = "left",
        offset = Vector(9, 3.5, -1),
        handAng = Angle(-30, 90, 80),
        fist = 1.25,
        hold = "pistol_hold2",
    },
}
local angZero = Angle(0, 0, 0)
local LEFT_FIST_CURL = {
    {"ValveBiped.Bip01_L_Finger1", 28},
    {"ValveBiped.Bip01_L_Finger11", 42},
    {"ValveBiped.Bip01_L_Finger12", 34},
    {"ValveBiped.Bip01_L_Finger2", 30},
    {"ValveBiped.Bip01_L_Finger21", 44},
    {"ValveBiped.Bip01_L_Finger22", 36},
    {"ValveBiped.Bip01_L_Finger3", 30},
    {"ValveBiped.Bip01_L_Finger31", 44},
    {"ValveBiped.Bip01_L_Finger32", 36},
    {"ValveBiped.Bip01_L_Finger4", 26},
    {"ValveBiped.Bip01_L_Finger41", 38},
    {"ValveBiped.Bip01_L_Finger42", 30},
    {"ValveBiped.Bip01_L_Finger0", -4},
    {"ValveBiped.Bip01_L_Finger01", 8},
    {"ValveBiped.Bip01_L_Finger02", 6},
}
local function ApplyLeftFist(ent, strength)
    strength = math.Clamp(strength or 1, 0, 1.4)
    for i = 1, #LEFT_FIST_CURL do
        local boneName = LEFT_FIST_CURL[i][1]
        local amount = LEFT_FIST_CURL[i][2] * strength
        local bone = ent:LookupBone(boneName)
        if not bone then continue end
        local mat = ent:GetBoneMatrix(bone)
        if not mat then continue end
        local _, newAng = LocalToWorld(vector_origin, Angle(0, -amount, 0), vector_origin, mat:GetAngles())
        mat:SetAngles(newAng)
        hg.bone_apply_matrix(ent, bone, mat)
    end
end
local function GetContextBlend(ply, untilTime)
    local now = CurTime()
    local startTime = ply:GetNWFloat("hg_context_event_start", now)
    local fadeIn = 0.08
    local fadeOut = 0.30
    local blendIn = math.Clamp((now - startTime) / fadeIn, 0, 1)
    local blendOut = math.Clamp((untilTime - now) / fadeOut, 0, 1)
    local blend = math.min(blendIn, blendOut)
    return math.ease.InOutSine(blend)
end
function hg.ApplyContextEventHandPose(ent, ply, wpn)
    if not IsValid(ent) or not IsValid(ply) then return end
    if not ply:IsPlayer() or not ply:Alive() then return end
    if ply:IsRagdoll() or ply:InVehicle() then return end
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    if ply:GetVelocity():LengthSqr() > 260 * 260 then return end
    if ply:GetNetVar("handcuffed", false) then return end
    if IsValid(ply:GetNetVar("carryent")) or IsValid(ply:GetNetVar("carryent2")) then return end
    local untilTime = ply:GetNWFloat("hg_context_event_until", 0)
    if untilTime <= CurTime() then return end
    local eventName = ply:GetNWString("hg_context_event", "")
    local pose = CONTEXT_HAND_POSES[eventName]
    if not pose then return end
    if pose.hand == "left" and not hg.CanUseLeftHand(ply) then return end
    if pose.hand == "right" and not hg.CanUseRightHand(ply) then return end
    local head = ent:LookupBone("ValveBiped.Bip01_Head1")
    if not head then return end
    local headMat = ent:GetBoneMatrix(head)
    if not headMat then return end
    local basePos = headMat:GetTranslation()
    local baseAng = ply:EyeAngles()
    local blend = GetContextBlend(ply, untilTime)
    if blend <= 0 then return end
    local targetPos = LocalToWorld(pose.offset, angZero, basePos, baseAng)
    local norm = ply:GetAimVector()
    if pose.hand == "left" then
        local lhBone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
        local lhMat = lhBone and ent:GetBoneMatrix(lhBone)
        local currentPos = lhMat and lhMat:GetTranslation() or targetPos
        local pos = LerpVector(blend, currentPos, targetPos)
        local blendedHandAng = pose.handAng * blend
        local anglh = (baseAng + Angle(0, 180, 0)) + blendedHandAng - baseAng
        hg.DragLeftHand(ent, wpn or {}, pos, norm, anglh)
        if pose.hold and hg.set_hold then
            hg.set_hold(ent, pose.hold)
        end
        ApplyLeftFist(ent, (pose.fist or 1) * blend)
    else
        hg.DragRightHand_Ex(ent, wpn or {}, targetPos, baseAng)
    end
end
