local cvarName = "remastered_realistic_combine_ai"
local sharedFlags = { FCVAR_ARCHIVE, FCVAR_REPLICATED }
local hookName = "r_cmb_ai"
local npcTbl = {}
local reloadSchedules = {SCHED_RELOAD, SCHED_HIDE_AND_RELOAD}
local failedSchedules = {89, 81}
local hl2Weapons = {
    weapon_smg1 = true,
    weapon_ar2 = true,
    weapon_pistol = true,
    weapon_shotgun = true
}
local convars = {
    {
        name = "addon",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Realistic Combine AI Remastered (Whole Addon).]]
    },
    {
        name = "moregunshots",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable More Gunshots for Soldiers.]]
    },
    {
        name = "morethantwoshoot",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable More Than Two Soldiers to Shoot.]]
    },
    {
        name = "weaponaccuracy",
        default = 2,
        flags = sharedFlags,
        desc = [[1 (Worst) to 5 (Best) Accuracy for Combine Soldiers. 2 = slightly worse than the 3 baseline.]]
    },
    {
        name = "movementspeed",
        default = 1.2,
        flags = sharedFlags,
        desc = [[Speed up Combine Movement. 1 for Default Speed.]]
    },
    {
        name = "avoidcrosshair",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Avoid Player Crosshair.]]
    },
    {
        name = "avoiddamage",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Take Cover When Taking Damage.]]
    },
    {
        name = "enemytooclose",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Take Cover When Near Enemy.]]
    },
    {
        name = "suppressionfire",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Suppress Fire on Enemy if Enemy Is Taking Cover.]]
    },
    {
        name = "fov",
        default = 80,
        flags = sharedFlags,
        desc = [[Adjust Field of View of Soldiers.]]
    },
    {
        name = "improvedshotgunners",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Shotgun Soldiers to Not Be Stupid.]]
    },
    {
        name = "retreatbehavior",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Retreat Behavior if the Soldier Is Injured or Alone With an Armed Enemy.]]
    },
    {
        name = "reloadlow",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Crouch When Reloading Their Weapon.]]
    },
    {
        name = "stealthbehavior",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Be Stealthy Around Its Enemy.]]
    },
    {
        name = "improvedgrenade",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Throw Grenades Tactically (Cooldown Limited).]]
    },
    {
        name = "allowjump",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Have the Capability to Jump.]]
    },
    {
        name = "allowclimb",
        default = 0,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Have the Capability to Climb.]]
    },
    {
        name = "allow_shoot_while_moving",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Have the Capability to Shoot While Moving.]]
    },
    {
        name = "additionalhealth",
        default = 0,
        flags = sharedFlags,
        desc = [[Addition Health for Soldiers.]]
    },
    {
        name = "fastmelee",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Have Fast Melee Attacks.]]
    },
    {
        name = "avoidbullet",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Avoid Bullets.]]
    },
    {
        name = "flashlight_detection",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Detect Flashlight From Players.]]
    },
    {
        name = "shoot_long",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Shoot From Far Away Normally.]]
    },
    {
        name = "runfrom_dead",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Run Away if They See a Soldier Just Died.]]
    },
    {
        name = "goto_footstep",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers to Go to the Position of the Footstep.]]
    },
    {
        name = "damage_smg1",
        default = 1,
        flags = sharedFlags,
        desc = [[Scale Damage for SMG Soldiers.]]
    },
    {
        name = "damage_ar2",
        default = 1,
        flags = sharedFlags,
        desc = [[Scale Damage for AR2 Soldiers.]]
    },
    {
        name = "damage_shotgun",
        default = 1,
        flags = sharedFlags,
        desc = [[Scale Damage for Shotgun Soldiers.]]
    },
    {
        name = "morechatter",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers To Chatter More Than Usual.]]
    },
    {
        name = "retreat_grenade",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers To Retreat From A Grenade More Effectively.]]
    },
    {
        name = "target_nearest",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers To Target Nearest Enemy.]]
    },
    {
        name = "nerf_omniscient",
        default = 1,
        flags = sharedFlags,
        desc = [[Enable Soldiers To Nerf Knowing Your Location When You Noclip Outside The Map.]]
    },
    {
        name = "engage_delay",
        default = 0.5,
        flags = sharedFlags,
        desc = [[Seconds a Soldier waits after first seeing an enemy before opening fire. Prevents instant kills.]]
    },
    {
        name = "navmesh_pathfinding",
        default = 1500,
        flags = sharedFlags,
        desc = [[How Far AI Search for Cover Using the Navmesh.]]
    },
    {
        name = "ainodes_pathfinding",
        default = 1500,
        flags = sharedFlags,
        desc = [[How Far AI Search for Cover Using the AI Nodes.]]
    }
}

local function fullName(suffix)
    return cvarName .. "_" .. suffix
end

for _, v in ipairs(convars) do
    local fullVarName = fullName(v.name)
    if not ConVarExists(fullVarName) then
        CreateConVar(fullVarName, v.default, v.flags, v.desc)
    end
end

cvars.AddChangeCallback(fullName("allowjump"), function(name, old, new)
    for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
        if GetConVar(fullName("allowjump")):GetBool() then
            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
        else
            npc:CapabilitiesRemove(CAP_MOVE_JUMP)
        end
    end
end)

cvars.AddChangeCallback(fullName("allowclimb"), function(name, old, new)
    for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
        if GetConVar(fullName("allowclimb")):GetBool() then
            npc:CapabilitiesAdd(CAP_MOVE_CLIMB)
        else
            npc:CapabilitiesRemove(CAP_MOVE_CLIMB)
        end
    end
end)

cvars.AddChangeCallback(fullName("allow_shoot_while_moving"), function(name, old, new)
    for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
        if not GetConVar(fullName("allow_shoot_while_moving")):GetBool() then
            npc:CapabilitiesRemove(CAP_MOVE_SHOOT)
        else
            npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
        end
    end
end)

cvars.AddChangeCallback(fullName("fov"), function(name, old, new)
    for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
        npc:SetFOV(GetConVar(fullName("fov")):GetFloat())
    end
end)

if SERVER then
    resource.AddSingleFile("resource/fonts/Race Sport.ttf")
    local function OEC(ent)
        local combine = ent:GetClass() == "npc_combine_s"
        local index = ent:EntIndex()
        if combine then
            ent:SetNWFloat("LastSuppressionTime", math.Rand(1,3))
            timer.Simple(0, function()
                if IsValid(ent) and combine then
                    ent:CapabilitiesAdd( bit.bor(
                        CAP_USE,
                        CAP_FRIENDLY_DMG_IMMUNE
                    ) )
                    ent:SetFOV(GetConVar(fullName("FOV")):GetFloat())
                    if not GetConVar(fullName("allow_shoot_while_moving")):GetBool() then
                        ent:CapabilitiesRemove(CAP_MOVE_SHOOT)
                    end
                    if GetConVar(fullName("allowclimb")):GetBool() then
                        ent:CapabilitiesAdd(CAP_MOVE_CLIMB)
                    end
                    if GetConVar(fullName("allowjump")):GetBool() then
                        ent:CapabilitiesAdd(CAP_MOVE_JUMP)
                    end
                    ent:SetHealth(ent:Health() + GetConVar(fullName("additionalhealth")):GetInt())
                end
            end)
        end
    end

    local function npcEnemyIsValid(npc)
        local enemy = npc:GetEnemy()
        if IsValid(enemy) and (enemy:IsPlayer() or enemy:IsNPC()) then
            return true, enemy
        else
            return false, nil
        end
    end

    local function npcIsUsingSchedule(npc, scheduleList)
        for _, sched in ipairs(scheduleList) do
            if npc:IsCurrentSchedule(sched) then
                return true
            end
        end
        return false
    end

    local function npcCheckDistance(npc, npc2)
        local pos2 = IsValid(npc2) and npc2:GetPos() or npc2
        if not pos2 then return 0 end
        return (npc:GetPos():Distance(pos2))
    end

    local function npcIsRangingAttack(npc)
        return (npcIsUsingSchedule(npc, {SCHED_RANGE_ATTACK1}))
    end

    local function npcIsReloadingButBeingSeen(npc, enemy)
        return (npcIsUsingSchedule(npc, reloadSchedules) and npc:Visible(enemy))
    end

    local function npcEstablishLineOfSightButBeingSeen(npc, enemy)
        return (npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE, 118}) and npc:Visible(enemy))
    end

    local function npcAndEnemyValid(npc, enemy)
        return (IsValid(npc) and IsValid(enemy))
    end

    local function npcIsShotgunner(npc)
        return (IsValid(npc:GetActiveWeapon()) and npc:GetActiveWeapon():GetHoldType()=='shotgun')
    end

    local function npcEnemyNotTooFar(npc)
        return (!npc:HasCondition(27))
    end

    local function npcVelocityMathEnemy(npc, enemy)
        local startPos = npc:GetPos()
        local targetPos = enemy:GetPos()
        local direction = (targetPos - startPos):GetNormalized()
        local distance = startPos:Distance(targetPos)
        local horizontalOffset = targetPos - startPos
        horizontalOffset.z = 0
        local horizontalDistance = horizontalOffset:Length()
        local heightDifference = targetPos.z - startPos.z
        local upwardScale = math.Clamp(horizontalDistance * 0.2 + heightDifference * 2, 100, 300)
        local upwardBoost = Vector(0, 0, upwardScale)
        local velocity = direction * distance + upwardBoost
        return velocity
    end

    local function npcIsRunning(npc)
        return (npc:GetActivity()==10 or npc:GetActivity()==11 or npc:GetActivity()==12)
    end

    local function enemyIsInSight(npc, enemy, pos)
        local eyePos = enemy:EyePos()
        local eyeDir = enemy:GetAimVector()
        local toNPC = (npc:GetPos() - eyePos):GetNormalized()
        local distance = enemy:GetPos():Distance(npc:GetPos())

        local dot = eyeDir:Dot(toNPC)
        local inCone = dot >= math.cos(math.rad(55))

        if inCone and distance <= 6000 and enemy:VisibleVec(pos) then
            return true
        end

        return false
    end

    local function npcIsThereGrenade(npc)
        for _, ent in ipairs(ents.FindByClass("npc_grenade_frag")) do
            return (npcCheckDistance(npc, ent) <= 200)
        end
        return false
    end

    local AI_Nodes = {}
    local SIZEOF_INT = 4
    local SIZEOF_SHORT = 2
    local AINET_VERSION_NUMBER = 37
    local NUM_HULLS = 10

    local function toUShort(b)
        local i = {string.byte(b, 1, SIZEOF_SHORT)}
        return i[1] + i[2] * 256
    end

    local function toInt(b)
        local i = {string.byte(b, 1, SIZEOF_INT)}
        i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
        if i > 2147483647 then return i - 4294967296 end
        return i
    end

    local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
    local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end

    local function ParseAINFile()
        local f = file.Open("maps/graphs/" .. game.GetMap() .. ".ain", "rb", "GAME")
        if not f then return end

        local ainet_ver = ReadInt(f)
        local map_ver = ReadInt(f)
        if ainet_ver ~= AINET_VERSION_NUMBER then
            MsgN("Unknown graph file")
            return
        end

        local numNodes = ReadInt(f)
        if numNodes < 0 then
            MsgN("Graph file has an unexpected amount of nodes")
            return
        end

        for i = 1, numNodes do
            local pos = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat())
            local yaw = f:ReadFloat()
            local offsets = {}
            for i = 1, NUM_HULLS do
                offsets[i] = f:ReadFloat()
            end
            local nodetype = f:ReadByte()
            local nodeinfo = ReadUShort(f)
            local zone = f:ReadShort()

            if nodetype == 2 then table.insert(AI_Nodes, pos) end
        end
    end
    ParseAINFile()

    local function npcIsUsingHL2Weapon(npc)
        local wep = npc:GetActiveWeapon()
        if not IsValid(wep) then return false end

        return hl2Weapons[wep:GetClass()]==true
    end

    local function fixFailRandomCover(npc)
        if npcIsUsingSchedule(npc, failedSchedules) then
            npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
        end
    end

    local function npcTracePos(npc, startpos)
        local npcStart = startpos
        local npcForward = npc:GetForward()
        local traceLength = 150

        local npcTraceData = {
            start = npcStart,
            endpos = npcStart + npcForward * traceLength,
            filter = npc
        }

        local npcTraceResult = util.TraceLine(npcTraceData)
        return npcTraceResult
    end

    local function npcSuppressionTrace(npc, enemy)
        local startPos = enemy:GetPos() + Vector(0, 0, 40)
        local traceLength = 150
        local npcTraceResult = npcTracePos(npc, npc:EyePos())
        local npcStart = npcTraceResult.StartPos

        local wallTooClose = npcTraceResult.Hit and npcStart:DistToSqr(npcTraceResult.HitPos) < (traceLength * 0.5)^2

        local directions = {
            Vector(1, 0, 0), Vector(-1, 0, 0),
            Vector(0, 1, 0), Vector(0, -1, 0),
            Vector(0, 0, 1), Vector(0, 0, -1),

            Vector(1, 1, 0), Vector(1, -1, 0),
            Vector(-1, 1, 0), Vector(-1, -1, 0),

            Vector(1, 0, 1), Vector(1, 0, -1),
            Vector(-1, 0, 1), Vector(-1, 0, -1),

            Vector(0, 1, 1), Vector(0, 1, -1),
            Vector(0, -1, 1), Vector(0, -1, -1),

            Vector(1, 1, 1), Vector(1, 1, -1),
            Vector(1, -1, 1), Vector(1, -1, -1),
            Vector(-1, 1, 1), Vector(-1, 1, -1),
            Vector(-1, -1, 1), Vector(-1, -1, -1),
        }

        for _, dir in ipairs(directions) do
            local endPos = startPos + dir:GetNormalized() * traceLength
            local traceData = {
                start = startPos,
                endpos = endPos,
                filter = enemy
            }

            local traceResult = util.TraceLine(traceData)

            if npc:VisibleVec(traceResult.HitPos) then
                npc:UpdateEnemyMemory(enemy, traceResult.HitPos)
                npc:SetLastPosition(traceResult.HitPos)
                return not wallTooClose
            end
        end

        return false
    end

    local function npcSpeedUp(npc)
        local speedfloat = GetConVar(fullName("movementspeed")):GetFloat()
        local running = npcIsRunning(npc)
        if npc:IsMoving() and running then
            npc:SetSaveValue( "m_flTimeLastMovement", npc:GetInternalVariable("m_flTimeLastMovement") * speedfloat )
        end
    end

    local function moveToRandomCover(npc, hasEnemy, enemy)
        local enemypos = hasEnemy and enemy:GetPos() or npc:GetPos()
        local navmesh_pathfinding = GetConVar(fullName("navmesh_pathfinding")):GetFloat()
        local ainodes_pathfinding = GetConVar(fullName("ainodes_pathfinding")):GetFloat()
        local target = hasEnemy and enemy or npc
        local allAreas = navmesh.Find(enemypos, navmesh_pathfinding, 300, 300)
        local validAreas = {}
        local invalidAreas = {}
        if #allAreas > 0 then
            for _, area in ipairs(allAreas) do
                local center = area:GetCenter()
                local distance = enemypos:Distance(center)
                local closeDist = distance > 270 and distance < navmesh_pathfinding
                if closeDist and area:IsValid() then
                    local trace = util.TraceLine({
                        start = center + Vector(0,0,10),
                        endpos = center + (9999 * Vector(0, 0, 10)),
                        mask = MASK_VISIBLE_AND_NPCS
                    })
                    if !enemyIsInSight(npc, target, center) and !area:IsUnderwater() and npc:NavSetGoal(center) then
                        table.insert(invalidAreas, center)
                    end
                end
            end

            if #invalidAreas > 0 then
                local randomIndex = math.random(1, #invalidAreas)
                local selectedArea = invalidAreas[randomIndex]
                npc:SetLastPosition(selectedArea)
                npc:SetSchedule(SCHED_FORCED_GO_RUN)
            end
        else
            for k,area in ipairs(AI_Nodes) do
                local distance = enemypos:Distance(area)
                local closeDist = distance > 270 and distance < ainodes_pathfinding
                if closeDist then
                    local trace = util.TraceLine({
                        start = area + Vector(0,0,10),
                        endpos = area + (9999 * Vector(0, 0, 10)),
                        mask = MASK_VISIBLE_AND_NPCS
                    })
                    if !enemyIsInSight(npc, target, area) and npc:NavSetGoal(area) then
                        table.insert(validAreas, area)
                    end
                end
            end

            if #validAreas > 0 then
                local randomIndex = math.random(1, #validAreas)
                local selectedArea = validAreas[randomIndex]
                npc:SetLastPosition(selectedArea)
                npc:SetSchedule(SCHED_FORCED_GO_RUN)
            end
        end
    end

    local function npcSuppressFire(npc, enemy)
        local npcCanShootCover = npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE}) and !npc:Visible(enemy) and npcSuppressionTrace(npc, enemy) and npcCheckDistance(npc,enemy) <= 6000 and (!npc:HasCondition(3) or !npc:HasCondition(4)) and enemy:IsInWorld()
        if npcCanShootCover then
            npc:SetSchedule(SCHED_SHOOT_ENEMY_COVER)
        end
    end

    local function npcEstablishLOSAfterSF(npc,enemy)
        if npcIsUsingSchedule(npc, {SCHED_SHOOT_ENEMY_COVER}) and !npc:Visible(enemy) then
            npc:SetSchedule(SCHED_ESTABLISH_LINE_OF_FIRE)
        end
    end

    local function npcSuppressionFireAction(npc, enemy)
        local time = npc:GetNWFloat("LastSuppressionTime")
        timer.Simple(time, function()
            if npcAndEnemyValid(npc, enemy) then
                npcSuppressFire(npc, enemy)
                timer.Simple(6, function()
                    if npcAndEnemyValid(npc, enemy) then
                        npcEstablishLOSAfterSF(npc, enemy)
                    end
                end)
            end
        end)
    end

    local function improvedMoveCover(npc, hasEnemy, enemy)
        fixFailRandomCover(npc)
        if npcIsRangingAttack(npc) or npcIsReloadingButBeingSeen(npc, enemy) then
            moveToRandomCover(npc, hasEnemy, enemy)
        elseif npcEstablishLineOfSightButBeingSeen(npc, enemy) then
            timer.Simple(1, function()
                if npcAndEnemyValid(npc, enemy) then
                    moveToRandomCover(npc, hasEnemy, enemy)
                end
            end)
        end
    end

    local function avoidCrosshair(npc, hasEnemy, enemy)
        local avoidcrosshair = GetConVar(fullName("avoidcrosshair"))
        if avoidcrosshair:GetBool() then
            if enemy:IsPlayer() then
                local tr = enemy:GetEyeTrace()
                local ent = tr.Entity
                if (ent == npc) then
                    improvedMoveCover(npc, hasEnemy, enemy)
                end
            end
        end
    end

    local function enemyTooClose(npc, hasEnemy, enemy)
        local enemytooclose = GetConVar(fullName("enemytooclose"))
        if enemytooclose:GetBool() then
            if npcCheckDistance(npc, enemy) <= 130 and !npc:IsMoving() then
                moveToRandomCover(npc, hasEnemy, enemy)
            end
        end
    end

    local function npcSuppressionFire(npc, enemy)
        local suppressionfire = GetConVar(fullName("suppressionfire"))
        local enemyvisible = npc:Visible(enemy)
        if suppressionfire:GetBool() then
            if (npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE}) and !npc:Visible(npc:GetEnemy())) then
                npcSuppressionFireAction(npc, enemy)
            end

            if npcIsUsingSchedule(npc, {SCHED_SHOOT_ENEMY_COVER}) then
                if enemyvisible then
                    npc:ClearSchedule()
                end
            end

            if (npc:GetCurrentSchedule()==109 or npc:GetCurrentSchedule()==114)  and !enemyvisible then
                npc:SetSchedule(120)
            end
        end
    end

    local function npcAccurateWeapon(npc, enemy)
        local accuracyLevel = GetConVar(fullName("weaponaccuracy")):GetInt()
        local distance = npcCheckDistance(npc, enemy)
        local proficiencyTable = {
            [1] = { far = 0, close = 1 },
            [2] = { far = 1, close = 2 },
            [3] = { far = 2, close = 3 },
            [4] = { far = 3, close = 4 },
            [5] = { far = 4, close = 4 }
        }
        local profValues = proficiencyTable[accuracyLevel]

        if accuracyLevel == 0 then
            npc:SetSaveValue("m_CurrentWeaponProficiency", 0)
            return
        end

        if not profValues then return end

        if !npcIsUsingSchedule(npc, {SCHED_SHOOT_ENEMY_COVER}) then
            if distance > 900 then
                npc:SetSaveValue("m_CurrentWeaponProficiency", profValues.far)
            else
                if npcIsShotgunner(npc) and accuracyLevel == 5 then
                    npc:SetSaveValue("m_CurrentWeaponProficiency", 2)
                else
                    npc:SetSaveValue("m_CurrentWeaponProficiency", profValues.close)
                end
            end
        else
            npc:SetSaveValue("m_CurrentWeaponProficiency", 0)
        end
    end

    local function npcMoreThanTwoShoot(npc)
        local morethantwoshoot = GetConVar(fullName("morethantwoshoot"))
        if morethantwoshoot:GetBool() then
            npc:SetSaveValue("m_iMySquadSlot", 1)
        end
    end

    local function npcMoreGunshots(npc)
        local moregunshots = GetConVar(fullName("moregunshots"))
        local isusinghl2weapon = npcIsUsingHL2Weapon(npc)
        if moregunshots:GetBool() then
            npc:SetSaveValue("m_nShots", npc:GetInternalVariable("m_nShots") + 1)
        end
    end

    local function npcImprovedShotgunner(npc, enemy)
        local condition = npcIsShotgunner(npc) and (npc:GetCurrentSchedule() == 119 or npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE, 98})) and npc:Visible(enemy) and npcEnemyNotTooFar(npc) and GetConVar(fullName("improvedshotgunners")):GetBool()
        if condition then
            timer.Simple(0.3, function()
                if npcAndEnemyValid(npc, enemy) and condition then
                    npc:SetSchedule(SCHED_RANGE_ATTACK1)
                end
            end)
        end
    end

    local function npcReloadLow(npc, enemy)
        local bool = GetConVar(fullName("reloadlow")):GetBool()
        local cond = npc:GetMovementActivity(ACT_RELOAD) and npcIsUsingSchedule(npc, reloadSchedules) and !npc:Visible(enemy) and !npc:IsMoving()
        if bool and cond then
            npc:SetActivity(ACT_RELOAD_LOW)
        end
    end

    local function npcStayInCover(npc, enemy)
        local isInAmbush = npcIsUsingSchedule(npc, {SCHED_AMBUSH})
        local isLOS = npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE})
        local isEnemyVisible = npc:Visible(enemy)
        local hearsDanger = npc:HasCondition(50)
        if isLOS and !isEnemyVisible then
            npc:SetSchedule(SCHED_AMBUSH)
        elseif isInAmbush and isEnemyVisible then
            npc:ClearSchedule()
        elseif isInAmbush and !isEnemyVisible then
            npc:SetActivity(ACT_COVER_LOW)
        end
        if isInAmbush and hearsDanger then
            npc:ClearSchedule()
        end
    end

    local function npcRetreatAction(npc, hasEnemy, enemy)
        local random = math.Rand(3,6)
        local grenadeValid = npcIsThereGrenade(npc)
        if !npc:IsMoving() and npc:Visible(enemy) and !grenadeValid then
            improvedMoveCover(npc, hasEnemy, enemy)
        end
        if CurTime() >= npc:GetNWFloat("LastSentenceTimeAlone") and !IsValid(npc:GetNearestSquadMember()) then
            npc:SetNWFloat("LastSentenceTimeAlone", CurTime() + random)
        end
        npcStayInCover(npc, enemy)
    end

    local function npcRetreatBehavior(npc, hasEnemy, enemy)
        local bool = GetConVar(fullName("retreatbehavior")):GetBool()
        local condition = npc:Health() < 30 or !IsValid(npc:GetNearestSquadMember()) and IsValid(enemy:GetActiveWeapon())
        local isInAmbush = npcIsUsingSchedule(npc, {SCHED_AMBUSH})
        if (bool and condition) then
            npcRetreatAction(npc, hasEnemy, enemy)
        elseif not condition then
            if isInAmbush then
                npc:ClearSchedule()
            end
        end
    end

    local npcGrenadeCooldown = {}

    local function npcImprovedGrenadeThrow(npc, enemy)
        if !GetConVar(fullName("improvedgrenade")):GetBool() then return end
        local distance = npcCheckDistance(npc, enemy)
        if distance < 250 or distance > 1300 then return end
        if !npc:Visible(enemy) then return end
        local last = npcGrenadeCooldown[npc] or 0
        if CurTime() < last then return end
        local enemyArmed = IsValid(enemy:GetActiveWeapon())
        local inCover = npcIsUsingSchedule(npc, {SCHED_ESTABLISH_LINE_OF_FIRE}) and !npc:Visible(enemy)
        if !enemyArmed and !inCover then return end
        if math.random() > 0.55 then return end
        npcGrenadeCooldown[npc] = CurTime() + math.Rand(16, 24)
        npc:SetSaveValue("m_flNextGrenadeCheck", 0)
        npc:SetSaveValue("m_hForcedGrenadeTarget", enemy)
    end

    local function npcShootLong(npc, enemy)
        local bool = GetConVar(fullName("shoot_long")):GetBool()
        local cond = !npcEnemyNotTooFar(npc) and npcEstablishLineOfSightButBeingSeen(npc, enemy) and npcCheckDistance(npc,enemy) <= 6000 and IsValid(npc:GetNearestSquadMember()) and npc:Health() >= 30
        if cond and bool then
            npc:UpdateEnemyMemory(enemy, enemy:GetPos())
            timer.Simple(1, function()
                if npcAndEnemyValid(npc, enemy) and cond then
                    npc:SetSchedule(SCHED_RANGE_ATTACK1)
                end
            end)
        end
    end

    local function npcCanPerformImprovedBehavior(npc, hasEnemy, enemy)
        local bool2 = GetConVar(fullName("retreatbehavior")):GetBool()
        local condition = npc:Health() >= 30 and enemy:Health() >= 40 and IsValid(enemy:GetActiveWeapon()) and IsValid(npc:GetNearestSquadMember())
        if (condition and bool2) or not bool2 then
            avoidCrosshair(npc, hasEnemy, enemy)
            enemyTooClose(npc, hasEnemy, enemy)
            npcSuppressionFire(npc, enemy)
            npcImprovedGrenadeThrow(npc, enemy)
        end
    end

    local function npcStealthMovement(npc, enemy)
        local running = npcIsRunning(npc)
        local grenadeValid = npcIsThereGrenade(npc)
        local bool =  GetConVar(fullName("stealthbehavior")):GetBool()
        local pos = npc:GetPos()
        local enemyvisible = enemyIsInSight(npc, enemy, pos)
        local crouching = npc:GetActivity()==12
        local hearsDanger = npc:HasCondition(50)
        local mustrun = (enemyvisible or grenadeValid or hearsDanger)
        if bool then
            if running and !mustrun then
                npc:SetMovementActivity(ACT_RUN_CROUCH)
            else
                timer.Simple(0.5, function()
                    if npcAndEnemyValid(npc, enemy) and crouching and mustrun then
                        npc:SetMovementActivity(10)
                    end
                end)
            end
        end
    end

    local function npcFastMelee(npc)
        local cond = GetConVar(fullName("fastmelee")):GetBool() and npcIsUsingSchedule(npc, {SCHED_MELEE_ATTACK1})
        if cond then
            npc:SetPlaybackRate(1.5)
        end
    end

    local function npcDamage(npc, dmginfo)
        if not IsValid(npc) then return end

        local avoidDamageConVar = GetConVar(fullName("avoiddamage"))
        local attacker = dmginfo:GetAttacker()
        local weapon = dmginfo:GetWeapon()

        if avoidDamageConVar:GetBool() and npc:GetClass() == "npc_combine_s" then
            local hasEnemy, enemy = npcEnemyIsValid(npc)

            if not npc:IsMoving() then
                moveToRandomCover(npc, hasEnemy, enemy)
            end
        end

        if IsValid(attacker) and attacker:GetClass() == "npc_combine_s" then
            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weaponClass == "weapon_smg1" then
                    dmginfo:ScaleDamage(GetConVar(fullName("damage_smg1")):GetFloat())
                elseif weaponClass == "weapon_ar2" then
                    dmginfo:ScaleDamage(GetConVar(fullName("damage_ar2")):GetFloat())
                elseif weaponClass == "weapon_shotgun" then
                    dmginfo:ScaleDamage(GetConVar(fullName("damage_shotgun")):GetFloat())
                end
            end
        end
    end

    local function npcDangerGTFO(npc)
        local grenadeValid = npcIsThereGrenade(npc)
        local bool = GetConVar(fullName("retreat_grenade")):GetBool()
        if grenadeValid and bool and !npc:IsMoving() and !npcIsUsingSchedule(npc,{SCHED_TAKE_COVER_FROM_ORIGIN}) then
            npc:SetSchedule(SCHED_TAKE_COVER_FROM_ORIGIN)
        end
    end

    local function npcAvoidBullet(npc, data)
        for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
            local pos = data.Trace.HitPos
            local dist = pos:Distance(npc:GetPos())
            local idlemode = npc:GetNPCState() == NPC_STATE_IDLE or npc:GetNPCState() == NPC_STATE_ALERT
            if dist <= 245 and !npc:IsMoving() and idlemode then
                moveToRandomCover(npc, hasEnemy, enemy)
            end
        end
    end

    local function npcFlashlight(npc, ply)
        local cvarBool = GetConVar("ai_disabled"):GetBool()==true
        or GetConVar("ai_ignoreplayers"):GetBool()==true
        or GetConVar(fullName("flashlight_detection")):GetBool()==false
        local flashlightOn = ply:FlashlightIsOn() and ply:Visible(npc)
        if cvarBool then return end
        if flashlightOn then
            npc:SetEnemy(ply)
            npc:UpdateEnemyMemory(ply, npc:GetPos())
        end
    end

    local function npcFlashlightDetection(npc)
        for k, ent in pairs(player.GetAll()) do
            local dist = npcCheckDistance(npc, ent) <= 1365
            local isNpc = ent:IsNPC()
            local isPlayer = ent:IsPlayer()
            if dist then
                npcFlashlight(npc, ent)
            end
        end
    end

    local function npcWalkToSound(sound)
        if GetConVar(fullName("goto_footstep")):GetBool() then
            for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
                local soundstring = sound.Volume >= 0.5 and (string.find(sound.SoundName:lower(), "foot") or string.find(sound.SoundName:lower(), "metropolice/gear"))
                local idlemode = npc:GetNPCState() == NPC_STATE_IDLE or npc:GetNPCState() == NPC_STATE_ALERT
                local sndPos = IsValid(sound.Entity) and sound.Entity:GetPos() or sound.Pos
                local dist = sndPos and npcCheckDistance(npc, sndPos) <= 2048
                local poss = sndPos
                timer.Simple(1, function()
                    if soundstring and IsValid(npc) then
                        if not npc:IsMoving() and (npc:GetNPCState()==1 or npc:GetNPCState()==2) and dist then
                            npc:SetLastPosition(poss)
                            npc:SetSchedule(SCHED_FORCED_GO_RUN)
                        end
                    end
                end)
            end
        end
    end

    local function OnNPCKilled(npc, attacker, inflictor)
        if GetConVar(fullName("runfrom_dead")):GetBool() then
            if npc:GetClass()=="npc_combine_s" then
                for _, npc1 in pairs(ents.FindByClass("npc_combine_s")) do
                    local hasEnemy, enemy = npcEnemyIsValid(npc1)
                    timer.Simple(0, function()
                        local cond = IsValid(npc) and IsValid(npc1) and npc1:Visible(npc) and !npc1:IsMoving() and enemyIsInSight(npc, npc1, npc:GetPos()) and npcCheckDistance(npc1,npc) <= 6000
                        if cond then
                            moveToRandomCover(npc1, hasEnemy, enemy)
                        end
                    end)
                end
            end
        end
    end

    local function SoldierMoreChatter(npc)
        if IsValid(npc) and npc:GetClass()=="npc_combine_s" then
            local hasEnemy, enemy = npcEnemyIsValid(npc)
            local canChat = npc:GetNWBool( "SoldierCanChat" )
            local bool = GetConVar(fullName("morechatter")):GetBool()
            if hasEnemy and bool then
                local function talk(time, sentence)
                    if !canChat then
                        npc:PlaySentence(sentence, 0, 1 )
                        npc:SetNWBool("SoldierCanChat", true)
                        timer.Simple(time, function()
                            if IsValid(npc) then
                                npc:SetNWBool("SoldierCanChat", false)
                            end
                        end)
                    end
                end
                if enemy:IsPlayer() then
                    if npc:IsSquadLeader() then
                        talk(3, "COMBINE_MONST")
                    else
                        talk(3, "COMBINE_MONST_CITIZENS")
                    end
                else
                    if IsValid(enemy:GetActiveWeapon()) then
                        if npc:IsSquadLeader() then
                            talk(3, "COMBINE_MONST")
                        else
                            talk(3, "COMBINE_MONST_CITIZENS")
                        end
                    end
                end
            end
        end
    end

    local function npcNerfLocation(npc, enemy)
        if GetConVar(fullName("nerf_omniscient")):GetBool() then
            if !enemy:IsInWorld() then
                npc:ClearEnemyMemory()
                timer.Simple(3, function()
                    if IsValid(npc) then
                        npc:SetSaveValue("m_hForcedGrenadeTarget", nil)
                    end
                end)
            end
        end
    end

    local function npcTargetNearest(npc, enemy)
        if GetConVar(fullName("target_nearest")):GetBool() then
            local closestEnt = nil
            local closestDist = math.huge
            local npcPos = npc:GetPos()

            for _, ent in ipairs(npc:GetKnownEnemies()) do
                local dist = npcPos:DistToSqr(ent:GetPos())
                if dist < closestDist and npc:Visible(ent) then
                    closestDist = dist
                    closestEnt = ent
                end
            end

            if IsValid(closestEnt) then
                npc:SetEnemy(closestEnt)
                npc:UpdateEnemyMemory(closestEnt, closestEnt:GetPos())
            end
        end
    end

    local function npcEngageDelay(npc, enemy)
        local delay = npc:GetNWFloat("engageDelay", 0)
        if delay == 0 then
            npc:SetNWFloat("engageDelay", CurTime() + GetConVar(fullName("engage_delay")):GetFloat())
            return true
        end
        if CurTime() < delay then return true end
        return false
    end

    local function combatBehavior(npc)
        local hasEnemy, enemy = npcEnemyIsValid(npc)
        local validWep = IsValid(npc:GetActiveWeapon())
        if hasEnemy and validWep then
            local justAcquired = npcEngageDelay(npc, enemy)
            if CurTime() >= npc:GetNWFloat("LastThinkTimeCombat") then
                npc:SetNWFloat("LastThinkTimeCombat", CurTime() + 0.09)
                npcRetreatBehavior(npc, hasEnemy, enemy)
                npcCanPerformImprovedBehavior(npc, hasEnemy, enemy)
                npcAccurateWeapon(npc, enemy)
                if !justAcquired then
                    npcImprovedShotgunner(npc, enemy)
                    npcShootLong(npc, enemy)
                end
                npcReloadLow(npc, enemy)
                npcStealthMovement(npc, enemy)
                npcFastMelee(npc)
                npcNerfLocation(npc, enemy)
                npcTargetNearest(npc, enemy)
            end
            npcMoreThanTwoShoot(npc)
            npcMoreGunshots(npc)
        else
            if npc:GetNWFloat("engageDelay", 0) != 0 then
                npc:SetNWFloat("engageDelay", 0)
            end
        end
    end

    local function generalBehavior(npc)
        npcSpeedUp(npc)
        if CurTime() >= npc:GetNWFloat("LastThinkTimeGeneralBehavior") then
            npc:SetNWFloat("LastThinkTimeGeneralBehavior", CurTime() + 0.09)
            npcDangerGTFO(npc)
        end
    end

    local function idleBehavior(npc)
        local idlemode = npc:GetNPCState() == NPC_STATE_IDLE or npc:GetNPCState() == NPC_STATE_ALERT
        if idlemode then
            if CurTime() >= npc:GetNWFloat("LastThinkTimeIdleBehavior") then
                npc:SetNWFloat("LastThinkTimeIdleBehavior", CurTime() + 0.09)
                npcFlashlightDetection(npc)
            end
        end
    end

    local function improvedAI(npc)
        combatBehavior(npc)
        idleBehavior(npc)
        generalBehavior(npc)
    end

    local function Think()
        for _, npc in pairs(ents.FindByClass("npc_combine_s")) do
            if IsValid(npc) then
                improvedAI(npc)
            end
        end
    end

    hook.Add("OnEntityCreated", hookName, function(ent)
        if GetConVar(fullName("addon")):GetBool() then
            OEC(ent)
        end
    end)

    hook.Add("Think", hookName, function()
        if GetConVar(fullName("addon")):GetBool() then
            Think()
        end
    end)

    hook.Add( "EntityTakeDamage", hookName, function( npc, dmginfo )
        if GetConVar(fullName("addon")):GetBool() then
            npcDamage(npc,dmginfo)
        end
    end)

    hook.Add( "PostEntityFireBullets", hookName, function( npc, data )
        if GetConVar(fullName("addon")):GetBool() then
            npcAvoidBullet(npc,data)
            SoldierMoreChatter(npc)
        end
    end)

    hook.Add( "EntityEmitSound", hookName, function( sound )
        if GetConVar(fullName("addon")):GetBool() then
            npcWalkToSound(sound)
        end
    end)

    hook.Add( "OnNPCKilled", hookName, function( npc, attacker, inflictor )
        if GetConVar(fullName("addon")):GetBool() then
            OnNPCKilled(npc, attacker, inflictor)
        end
    end)
else
    local cvarPrefix = cvarName.."_"
    local frame = nil

    local sliderConfig = {
        weaponaccuracy = {min = 1, max = 5, decimals = 0, color = Vector(180, 220, 255)},
        movementspeed = {min = 0.5, max = 2, decimals = 3, color = Vector(180, 220, 255)},
        fov = {min = 30, max = 120, decimals = 0, color = Vector(180, 220, 255)},
        additionalhealth = {min = 0, max = 200, decimals = 0, color = Vector(180, 220, 255)},
        damage_smg1 = {min = 1, max = 15, decimals = 0, color = Vector(180, 220, 255)},
        damage_ar2 = {min = 1, max = 15, decimals = 0, color = Vector(180, 220, 255)},
        damage_shotgun = {min = 1, max = 15, decimals = 0, color = Vector(180, 220, 255)},
        engage_delay = {min = 0, max = 2, decimals = 2, color = Vector(180, 220, 255)},
        navmesh_pathfinding = {min = 0, max = 10000, decimals = 0, color = Vector(180,0,0)},
        ainodes_pathfinding = {min = 0, max = 10000, decimals = 0, color = Vector(180,0,0)}
    }

    local function CreatePresetButtons(parent, controlMap)
        local btnPanel = vgui.Create("DPanel", parent)
        btnPanel:Dock(BOTTOM)
        btnPanel:SetTall(40)
        btnPanel.Paint = nil

        local saveBtn = vgui.Create("DButton", btnPanel)
        saveBtn:SetText("Save ...")
        saveBtn:SetFont("CombineUIFont")
        saveBtn:Dock(LEFT)
        saveBtn:DockMargin(5, 5, 5, 5)
        saveBtn.DoClick = function()
            Derma_StringRequest("Save Preset", "Enter a preset name:", "", function(presetName)
                if not presetName or presetName == "" then return end
                presetName = string.gsub(presetName, "[^a-zA-Z0-9_%-]", "_")

                local preset = {}
                for _, data in ipairs(convars) do
                    local fullName = cvarPrefix .. data.name
                    local cvar = GetConVar(fullName)
                    if cvar then
                        preset[data.name] = cvar:GetString()
                    end
                end

                file.CreateDir("combine_ai_presets")
                file.Write("combine_ai_presets/" .. presetName .. ".json", util.TableToJSON(preset, true))
                surface.PlaySound("buttons/button15.wav")
                parent:Close()
                timer.Simple(0, function()
                    RunConsoleCommand("open_combine_ai_ui")
                end)
            end)
        end

        local loadBtn = vgui.Create("DComboBox", btnPanel)
        loadBtn:SetFont("CombineUIFont")
        loadBtn:SetWide(140)
        loadBtn:SetPos((btnPanel:GetWide() / 2) - 165, 5)
        loadBtn:SetSize(80, 30)
        loadBtn:SetValue("Load ...")

        btnPanel.Think = function()
            loadBtn:SetPos((btnPanel:GetWide() / 2) - 165, 5)
        end

        if file.Exists("combine_ai_presets", "DATA") then
            local files = file.Find("combine_ai_presets/*.json", "DATA")
            for _, fname in ipairs(files) do
                local presetName = string.StripExtension(fname)
                loadBtn:AddChoice(presetName)
            end
        end

        loadBtn.OnSelect = function(_, _, selected)
            local path = "combine_ai_presets/" .. selected .. ".json"
            if not file.Exists(path, "DATA") then return end

            local json = file.Read(path, "DATA")
            local data = util.JSONToTable(json or "")
            if not data then return end

            for name, value in pairs(data) do
                local fullName = cvarPrefix .. name
                RunConsoleCommand(fullName, value)
            end

            surface.PlaySound("buttons/button14.wav")
            parent:Close()
            timer.Simple(0, function()
                RunConsoleCommand("open_combine_ai_ui")
            end)
        end

        local resetBtn = vgui.Create("DButton", btnPanel)
        resetBtn:SetText("Reset")
        resetBtn:SetFont("CombineUIFont")
        resetBtn:Dock(RIGHT)
        resetBtn:DockMargin(5, 5, 5, 5)
        resetBtn.DoClick = function()
            for name, value in pairs(convars) do
                local fullName = cvarPrefix .. value.name
                RunConsoleCommand(fullName, value.default)
            end
            surface.PlaySound("buttons/button19.wav")
            parent:Close()
            timer.Simple(0, function()
                RunConsoleCommand("open_combine_ai_ui")
            end)
        end

        local delBtn = vgui.Create("DButton", btnPanel)
        delBtn:SetText("Delete")
        delBtn:SetFont("CombineUIFont")
        delBtn:Dock(RIGHT)
        delBtn:SetSize(75)
        delBtn:DockMargin(5, 5, 5, 5)
        delBtn.DoClick = function()
            local files = file.Find("combine_ai_presets/*.json", "DATA")
            if #files == 0 then return end

            local menu = DermaMenu()
            for _, fname in ipairs(files) do
                local presetName = string.StripExtension(fname)

                menu:AddOption("Delete: " .. presetName, function()
                    file.Delete("combine_ai_presets/" .. presetName .. ".json")
                    surface.PlaySound("buttons/button10.wav")
                    parent:Close()
                    timer.Simple(0, function()
                        RunConsoleCommand("open_combine_ai_ui")
                    end)
                end)
            end
            menu:Open()
        end
    end

    local function CreateCombineAIPanel()
        frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(500, 600)
        frame:Center()
        frame:SetDraggable(false)
        frame:MakePopup()
        frame:SetAlpha(0)
        frame:SetSize(500 * 0.8, 600 * 0.8)

        local controlMap = {}

        local anim = Derma_Anim("OpenPanel", frame, function(pnl, anim, delta)
            pnl:SetAlpha(255 * delta)
            local scale = Lerp(delta, 0.8, 1)
            pnl:SetSize(500 * scale, 600 * scale)
            pnl:Center()
        end)
        anim:Start(0.3)
        frame.Think = function(self) if anim:Active() then anim:Run() end end

        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 20, 240))
            draw.SimpleText("Combine AI Settings", "CombineUIFont", 15, 10, Color(0, 180, 255), TEXT_ALIGN_LEFT)
        end

        surface.PlaySound("ui/buttonclickrelease.wav")

        local dragZone = vgui.Create("DButton", frame)
        dragZone:SetText("")
        dragZone:SetPos(0, 0)
        dragZone:SetSize(465, 60)
        dragZone:SetZPos(100)
        dragZone:SetDrawBackground(false)
        dragZone:SetCursor("sizeall")

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 40, 10, 10)

        dragZone.Think = function()
            if input.IsMouseDown(MOUSE_LEFT) and dragZone:IsHovered() then
                frame.isDragging = true
                frame.dragOffset = {
                    x = gui.MouseX() - frame.x,
                    y = gui.MouseY() - frame.y
                }
            else
                frame.isDragging = false
            end
        end

        frame.Think = function(self)
            if anim:Active() then anim:Run() end
            if self.isDragging then
                local mx, my = gui.MouseX(), gui.MouseY()
                local px, py = self:GetPos()
                local w, h = self:GetSize()

                local newX = mx - self.dragOffset.x
                local newY = my - self.dragOffset.y

                local scrW, scrH = ScrW(), ScrH()
                newX = math.Clamp(newX, 0, scrW - w)
                newY = math.Clamp(newY, 0, scrH - h)

                self:SetPos(newX, newY)
            end
        end

        frame.OnSizeChanged = function()
            dragZone:SetSize(465, 60)
        end

        local about = scroll:Add("DLabel")
        about:SetFont("CombineUIFont")
        about:SetTextColor(Color(0, 180, 255))
        about:SetWrap(true)
        about:SetAutoStretchVertical(true)
        about:SetText(
            "Realistic Combine Soldier AI: Remastered (Z-City build).\n\n" ..
            "Smarter, mobile Combine that fight from cover, suppress, retreat when hurt or alone, and use grenades tactically (cooldown limited).\n\n" ..
            "Tuned for fair, interesting fights: no instant headshots, no grenade spam."
        )
        about:SetContentAlignment(7)
        about:Dock(TOP)
        about:DockMargin(10, 0, 10, 10)

        for _, data in ipairs(convars) do
            local name = data.name
            local fullName = cvarPrefix .. name
            local convar = GetConVar(fullName)
            if not convar then continue end

            local control

            if sliderConfig[name] then
                local cfg = sliderConfig[name]
                local clr = cfg.color
                control = scroll:Add("DNumSlider")
                control:SetText(name)
                control:SetMin(cfg.min)
                control:SetMax(cfg.max)
                control:SetDecimals(cfg.decimals)
                control:SetValue(convar:GetFloat())
                control:Dock(TOP)
                control:DockMargin(0, 5, 0, 2)
                control.Label:SetFont("CombineUIFont")
                control.Label:SetTextColor(Color(clr:Unpack()))
                control.OnValueChanged = function(_, val)
                    RunConsoleCommand(fullName, tostring(val))
                end
            elseif (convar:GetInt() == 0 or convar:GetInt() == 1) then
                control = scroll:Add("DCheckBoxLabel")
                control:SetText(name)
                control:SetFont("CombineUIFont")
                control:SetTextColor(Color(180, 200, 255))
                control:SetChecked(convar:GetBool())
                control:Dock(TOP)
                control:DockMargin(0, 5, 0, 2)
                control.OnChange = function(_, val)
                    RunConsoleCommand(fullName, val and "1" or "0")
                end
            else
                control = scroll:Add("DTextEntry")
                control:SetFont("CombineUIFont")
                control:SetText(name .. ": " .. convar:GetString())
                control:Dock(TOP)
                control:DockMargin(0, 5, 0, 2)
                control.OnEnter = function(self)
                    local val = string.match(self:GetText(), ": (.+)$")
                    if val then
                        RunConsoleCommand(fullName, val)
                    end
                end
            end

            controlMap[name] = control

            if data.desc then
                local desc = scroll:Add("DLabel")
                desc:SetText(data.desc)
                desc:SetFont("CombineUIFont_Small")
                desc:SetTextColor(Color(180, 180, 200))
                desc:SetWrap(true)
                desc:SetAutoStretchVertical(true)
                desc:SetContentAlignment(7)
                desc:Dock(TOP)
                desc:DockMargin(10, 0, 10, 10)
            end
        end

        CreatePresetButtons(frame, controlMap)
    end

    concommand.Add("open_combine_ai_ui", function()
        if IsValid(frame) and frame:IsVisible() then
            frame:MakePopup()
            return
        end

        CreateCombineAIPanel()
    end)

    surface.CreateFont("CombineUIFont", {
        font = "Race Sport",
        size = 18,
        weight = 0,
        antialias = true,
    })

    surface.CreateFont("CombineUIFont_Small", {
        font = "Tahoma",
        size = 14,
        weight = 500,
        antialias = true,
    })

    local function saaaAI_Panel(panel)
        local ply = LocalPlayer()

        if not ply:IsAdmin() then
            return
        end
        panel:Button( "Open Realistic Combine Soldier AI Settings", "open_combine_ai_ui" )
    end

    hook.Add("PopulateToolMenu",hookName, function(panel)
        spawnmenu.AddToolMenuOption("Options","Realistic Combine Soldier AI: Remastered", hookName.."_settings","Realistic Combine Soldier AI: Remastered Options","","", saaaAI_Panel)
    end)
end
