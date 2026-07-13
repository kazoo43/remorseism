COMMANDS = COMMANDS or {}

local validUserGroupSuperAdmin = {
	superadmin = true,
}

local validUserGroup = {
	admin = true,
}

function COMMAND_GETACCES(ply)
	if ply == Entity(0) then return 2 end

	local group = ply:GetUserGroup()
	if validUserGroup[group] then
		return 1
	elseif validUserGroupSuperAdmin[group] then
		return 2
	end

	return 0
end

function COMMAND_ACCES(ply,cmd)
	local access = cmd[2] or 1
	if access ~= 0 and COMMAND_GETACCES(ply) < access then return end

	return true
end

function COMMAND_GETARGS(args)
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and string.sub(text,1,1) == "\"" then
			waitClose = true

			if string.sub(text,#text,#text) == "\n" then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text)
			end

			continue
		end

		if waitClose then
			if string.sub(text,#text,#text) == "\"" then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

function COMMAND_Input(ply,args)
	local cmd = COMMANDS[args[1]]
	if not cmd then return false end
	if not COMMAND_ACCES(ply,cmd) then return true,false end

	table.remove(args,1)

	return true,cmd[1](ply,args)
end
-- Мдаааа А ПЛЕЙРСЕЙ ДЛЯ КОГО НУЖЕН????
hook.Add("HG_PlayerSay","commands-chat",function(ply, txtTbl, text)
	COMMAND_Input(ply, COMMAND_GETARGS(string.Split(string.sub(text, 2, #text), " ")))
end)

COMMANDS.help = {function(ply,args)
	local text = ""

	if args[1] then
		local cmd = COMMANDS[args[1]]
		local argsList = cmd[3]
		if argsList then argsList = " - " .. argsList else argsList = "" end

		text = text .. "	" .. args[1] .. argsList .. "\n"
	else
		local list = {}
		for name in pairs(COMMANDS) do list[#list + 1] = name end
		table.sort(list,function(a,b) return a > b end)
        
		for _,name in pairs(list) do
			local cmd = COMMANDS[name]
            if not COMMAND_ACCES(ply,cmd) then continue end
            
			local argsList = cmd[3]
			if argsList then argsList = " - " .. argsList else argsList = "" end
            
			text = text .. "	" .. name .. argsList .. "\n"
		end
	end

	text = string.sub(text,1,#text - 1)

	ply:ChatPrint(text)
end,0}

if SERVER then
    util.AddNetworkString("PunishLightningEffect")
    util.AddNetworkString("AnotherLightningEffect")
    util.AddNetworkString("PluvCommand")

    local cloakActive = false
    local zcActive = false

    local function isZc(ply)
        return ply.cloak or (ply.organism and ply.organism.godmode)
    end

    local function applyZcCollision(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if isZc(ply) and ply:GetCollisionGroup() ~= COLLISION_GROUP_DEBRIS then
            ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
    end

    local function recalcZcActive()
        zcActive = false
        for _, p in ipairs(player.GetAll()) do
            if isZc(p) then zcActive = true break end
        end
    end

    -- Clear organism visual/audio effects (concussion, noradrenaline, berserk, etc.)
    -- and force-send to client so music/sounds stop immediately
    local function clearOrganismEffects(ply)
        if not IsValid(ply) or not ply:IsPlayer() or not ply.organism then return end
        local org = ply.organism

        org.concussion = 0
        org.concussion_tinnitus = 0
        org.concussion_effects = nil
        org.disorientation = 0
        org.noradrenaline = 0
        org.noradrenalineActive = false
        org.berserk = 0
        org.berserkActive = false
        org.berserkActive2 = false
        org.otrub = false
        org.shock = 0
        org.nausea = 0
        org.immobilization = 0

        if hg.send_organism then
            hg.send_organism(org)
        end
    end

	COMMANDS.zc_god = {function(ply)
        if not ply.organism then return end
        
        ply.organism.godmode = !ply.organism.godmode

        if ply.organism.godmode then
            clearOrganismEffects(ply)
        end

        ply:SetCollisionGroup(ply.organism.godmode and COLLISION_GROUP_DEBRIS or (ply.cloak and COLLISION_GROUP_DEBRIS or COLLISION_GROUP_PLAYER))
		ply:Notify(ply.organism.godmode and "now i'm immortal..." or "now i'm mortal")

        recalcZcActive()
		return
    end,1}

	COMMANDS.zc_cloak = {function(ply)
        if not ply.organism then return end
		ply.cloak = !ply.cloak

        if ply.cloak then
            clearOrganismEffects(ply)
        end

        ply:SetMaterial(ply.cloak and "NULL" or nil)
		ply:DrawShadow(!ply.cloak)
		ply:SetCollisionGroup(ply.cloak and COLLISION_GROUP_DEBRIS or (ply.organism.godmode and COLLISION_GROUP_DEBRIS or COLLISION_GROUP_PLAYER))
		ply:RemoveAllDecals()

		if ply.cloak then
			ply:SetNoDraw(true)
			ply:AddFlags(FL_NOTARGET)
			if IsValid(ply:GetActiveWeapon()) then
				ply:GetActiveWeapon():SetNoDraw(true)
			end

			for _, npc in ipairs(ents.FindByClass("npc_*")) do
				if IsValid(npc) and npc.AddEntityRelationship then
					npc:AddEntityRelationship(ply, D_NU, 99)
					if IsValid(ply.bull) then
						npc:AddEntityRelationship(ply.bull, D_NU, 99)
					end
				end
			end
			for _, term in ipairs(ents.FindByClass("terminator_*")) do
				if IsValid(term) and term.AddEntityRelationship then
					term:AddEntityRelationship(ply, D_NU, 99)
					if IsValid(ply.bull) then
						term:AddEntityRelationship(ply.bull, D_NU, 99)
					end
				end
			end
		else
			ply:SetNoDraw(false)
			ply:RemoveFlags(FL_NOTARGET)
			if IsValid(ply:GetActiveWeapon()) then
				ply:GetActiveWeapon():SetNoDraw(false)
			end
		end

		cloakActive = false
		for _, p in ipairs(player.GetAll()) do
			if p.cloak then cloakActive = true break end
		end

        recalcZcActive()
		ply:Notify(ply.cloak and "now i'm invisible..." or "now i'm visible")
		return
    end,1}

    COMMANDS.punish = {function(ply, args)
        if #args < 1 then
            ply:ChatPrint("Give me the name of this OwO .")
            return
        end

        local targetNickPartial = string.lower(args[1]) 
        local target = nil
        for _, player in player.Iterator() do
            if string.find(string.lower(player:Nick()), targetNickPartial) then 
                target = player
                break
            end
        end

        if not IsValid(target) then
            ply:ChatPrint("I don't see that OwO .")
            return
        end

        target = hg.GetCurrentCharacter(target)

        net.Start("AnotherLightningEffect")
        net.WriteEntity(target)
        net.Broadcast()

        net.Start("PunishLightningEffect")
        net.WriteEntity(target)
        net.Broadcast()

        target:EmitSound("snd_jack_hmcd_lightning.wav")

        local dmg = DamageInfo()
        dmg:SetDamage(1000)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(DMG_SHOCK)
        target:TakeDamageInfo(dmg)

        ply:ChatPrint("Fatass " .. target:Nick() .. " has been punished.")
    end, 2, "ник игрока"}

    COMMANDS.pluv = {function(ply, args)
        net.Start("PluvCommand")
        net.Send(ply)
    end, 0}

    COMMANDS.notify = {function(ply, args)
        if #args < 2 then
            ply:ChatPrint("Usage: !notify <player> <message>")
            return
        end

        local targetNickPartial = string.lower(args[1]) 
        local target = nil
        for _, player in player.Iterator() do
            if string.find(string.lower(player:Nick()), targetNickPartial) then 
                target = player
                break
            end
        end

        if not IsValid(target) then
            ply:ChatPrint("Player not found: " .. args[1])
            return
        end
        
        table.remove(args, 1) 
        local message = table.concat(args, " ")
        
        if message == "" then
            ply:ChatPrint("Message cannot be empty!")
            return
        end
        
        target:Notify(message, 0)
        ply:ChatPrint("Sent notification to " .. target:GetName() .. ": " .. message)

    end, 2, "name; message"}

	COMMANDS.setmodel = {function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 1 and args[1] or ply:Name()
		local mdl = #args > 1 and args[2] or args[1]

		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				local Appearance = ply2.CurAppearance or hg.Appearance.GetRandomAppearance()
				Appearance.AColthes = ""
				ply2:SetNetVar("Accessories", "")
				ply2:SetModel(mdl)
				ply2:SetSubMaterial()
				ply2:SetPlayerColor(ply2:GetNWVector("PlayerColor", vector_origin))

				ply:ChatPrint(ply2:Name().. "'s model set to " .. tostring(mdl))
			end
		end
	end, 0}

	--// Aliases
	COMMANDS.model = COMMANDS.setmodel
	COMMANDS.playermodel = COMMANDS.setmodel
	COMMANDS.setplayermodel = COMMANDS.setmodel

	COMMANDS.setscale = {function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 1 and args[1] or ply:Name()
		local scale = #args > 1 and args[2] or args[1]

		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				ply2:SetModelScale(scale)

				ply:ChatPrint(ply2:Name().. "'s model scale set to " .. tostring(scale))
			end
		end
	end, 0}

	--// Aliases
	COMMANDS.setsize = COMMANDS.setscale
	COMMANDS.scale = COMMANDS.setscale
	COMMANDS.size = COMMANDS.setscale
	COMMANDS.setmodelscale = COMMANDS.setscale
	COMMANDS.modelscale = COMMANDS.setscale

	-- =============================================
	-- zc_god + zc_cloak: comprehensive protection
	-- =============================================

	-- Block ALL damage for godmode and cloak players (and their ragdolls)
	hook.Add("EntityTakeDamage", "zc_blockdamage", function(ent, dmg)
		if not IsValid(ent) then return end
		local ply
		if ent:IsPlayer() then
			ply = ent
		else
			local owner = hg.RagdollOwner and hg.RagdollOwner(ent)
			if IsValid(owner) then ply = owner end
		end
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if ply.organism and ply.organism.godmode then
			dmg:SetDamage(0)
			dmg:SetDamageForce(Vector(0, 0, 0))
			return true
		end
		if ply.cloak then
			dmg:SetDamage(0)
			dmg:SetDamageForce(Vector(0, 0, 0))
			return true
		end
	end)

	-- Re-apply cloak state after spawn/respawn (overrides sv_tier_0 PlayerSpawn reset)
	hook.Add("PlayerSpawn", "zc_reapply", function(ply)
		timer.Simple(0, function()
			if not IsValid(ply) then return end
			if isZc(ply) then
				ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				if ply.cloak then
					ply:SetNoDraw(true)
					ply:SetMaterial("NULL")
					ply:DrawShadow(false)
					ply:AddFlags(FL_NOTARGET)
					if IsValid(ply:GetActiveWeapon()) then
						ply:GetActiveWeapon():SetNoDraw(true)
					end
					for _, npc in ipairs(ents.FindByClass("npc_*")) do
						if IsValid(npc) and npc.AddEntityRelationship then
							npc:AddEntityRelationship(ply, D_NU, 99)
							if IsValid(ply.bull) then
								npc:AddEntityRelationship(ply.bull, D_NU, 99)
							end
						end
					end
					for _, term in ipairs(ents.FindByClass("terminator_*")) do
						if IsValid(term) and term.AddEntityRelationship then
							term:AddEntityRelationship(ply, D_NU, 99)
							if IsValid(ply.bull) then
								term:AddEntityRelationship(ply.bull, D_NU, 99)
							end
						end
					end
				end
			end
		end)
	end)

	-- Clean up cloakActive when cloaked player disconnects
	hook.Add("PlayerDisconnected", "zc_cloak_cleanup", function(ply)
		if not ply.cloak then return end
		timer.Simple(0, function()
			cloakActive = false
			zcActive = false
			for _, p in ipairs(player.GetAll()) do
				if isZc(p) then zcActive = true end
				if p.cloak then cloakActive = true end
			end
		end)
	end)

	-- Wrap hg.Fake to block involuntary fake for godmode players
	-- (manual "fake" concommand uses _godFakeBypass flag to work)
	-- Deferred: sv_commands.lua loads before sv_tier_0.lua where hg.Fake is defined
	local function wrapFake()
		if hg._origFakeGodWrapped then return end
		hg._origFakeGodWrapped = true
		local origFake = hg.Fake
		function hg.Fake(ply, huyragdoll, no_freemove, force)
			if IsValid(ply) and ply:IsPlayer() and ply.organism and ply.organism.godmode and not ply._godFakeBypass then
				return
			end
			return origFake(ply, huyragdoll, no_freemove, force)
		end
	end

	if hg.Fake then
		wrapFake()
	else
		timer.Simple(0, function()
			if hg.Fake then wrapFake() end
		end)
	end

	-- Wrap hg.StunPlayer to block stuns for godmode players
	-- Deferred: sv_commands.lua loads before sv_util.lua where hg.StunPlayer is defined
	local function wrapStun()
		if hg._origStunGodWrapped then return end
		hg._origStunGodWrapped = true
		local origStun = hg.StunPlayer
		function hg.StunPlayer(ply, time)
			if IsValid(ply) and ply:IsPlayer() and ply.organism and ply.organism.godmode then return end
			return origStun(ply, time)
		end
	end

	if hg.StunPlayer then
		wrapStun()
	else
		timer.Simple(0, function()
			if hg.StunPlayer then wrapStun() end
		end)
	end

	-- Wrap hg.LightStunPlayer to block light stuns for godmode players
	-- Deferred: sv_commands.lua loads before sv_util.lua where hg.LightStunPlayer is defined
	local function wrapLightStun()
		if hg._origLightStunGodWrapped then return end
		hg._origLightStunGodWrapped = true
		local origLightStun = hg.LightStunPlayer
		function hg.LightStunPlayer(ply, time)
			if IsValid(ply) and ply:IsPlayer() and ply.organism and ply.organism.godmode then return end
			return origLightStun(ply, time)
		end
	end

	if hg.LightStunPlayer then
		wrapLightStun()
	else
		timer.Simple(0, function()
			if hg.LightStunPlayer then wrapLightStun() end
		end)
	end

	-- Wrap hg.ExplosionDisorientation to block concussion/tinnitus/disorientation for godmode
	local function wrapExplosionDisorientation()
		if hg._origExplosionDisorientationGodWrapped then return end
		hg._origExplosionDisorientationGodWrapped = true
		local origFunc = hg.ExplosionDisorientation
		function hg.ExplosionDisorientation(enta, tinnitus, disorientation)
			if IsValid(enta) and enta.organism then
				local owner = (IsValid(enta.organism.owner) and enta.organism.owner) or (enta:IsPlayer() and enta)
				if IsValid(owner) and owner:IsPlayer() and owner.organism and owner.organism.godmode then return end
			end
			return origFunc(enta, tinnitus, disorientation)
		end
	end

	if hg.ExplosionDisorientation then
		wrapExplosionDisorientation()
	else
		timer.Simple(5, function()
			if hg.ExplosionDisorientation then wrapExplosionDisorientation() end
		end)
	end

	-- Wrap hg.AddForceRag to block ragdoll physics forces for godmode players
	local function wrapAddForceRag()
		if hg._origAddForceRagGodWrapped then return end
		hg._origAddForceRagGodWrapped = true
		local origFunc = hg.AddForceRag
		function hg.AddForceRag(ent, physbone, force, time)
			if IsValid(ent) then
				local owner = nil
				if ent:IsPlayer() then
					owner = ent
				elseif ent:IsRagdoll() then
					owner = ent.ply
					if not IsValid(owner) then owner = hg.RagdollOwner and hg.RagdollOwner(ent) end
				end
				if IsValid(owner) and owner:IsPlayer() and owner.organism and owner.organism.godmode then return end
			end
			return origFunc(ent, physbone, force, time)
		end
	end

	if hg.AddForceRag then
		wrapAddForceRag()
	else
		timer.Simple(5, function()
			if hg.AddForceRag then wrapAddForceRag() end
		end)
	end

	-- =============================================
	-- zc_cloak: NPC invisibility hooks
	-- =============================================

	-- New NPCs/terminators become neutral to cloaked players and their bullseyes
	hook.Add("OnEntityCreated", "zc_cloak_npc_hide", function(ent)
		if not cloakActive then return end

		timer.Simple(0, function()
			if not IsValid(ent) then return end
			local isNpc = ent:IsNPC() and ent.AddEntityRelationship
			local isTerminator = string.StartWith(ent:GetClass(), "terminator") and ent.AddEntityRelationship
			if not isNpc and not isTerminator then return end

			for _, ply in ipairs(player.GetAll()) do
				if ply.cloak and IsValid(ply) then
					ent:AddEntityRelationship(ply, D_NU, 99)
					if IsValid(ply.bull) then
						ent:AddEntityRelationship(ply.bull, D_NU, 99)
					end
				end
			end
		end)
	end)

	-- Prevent NPCs from targeting cloaked players and their bullseyes
	hook.Add("Think", "zc_cloak_npc_think", function()
		if not cloakActive then return end

		for _, npc in ipairs(ents.FindByClass("npc_*")) do
			if not IsValid(npc) then continue end
			local getEnemy = npc.GetEnemy
			if not getEnemy then continue end
			local enemy = getEnemy(npc)
			if not IsValid(enemy) then continue end

			local shouldBlock = false
			if enemy:IsPlayer() and enemy.cloak then
				shouldBlock = true
			elseif enemy:GetClass() == "npc_bullseye" and IsValid(enemy.ply) and enemy.ply.cloak then
				shouldBlock = true
			end

			if shouldBlock and npc.SetEnemy then
				npc:SetEnemy(NULL)
			end
		end
	end)

	-- Hide weapons when player switches while cloaked
	hook.Add("PlayerSwitchWeapon", "zc_cloak_hideweapon", function(ply, oldWep, newWep)
		if not ply.cloak then return end
		if IsValid(oldWep) then oldWep:SetNoDraw(false) end
		if IsValid(newWep) then newWep:SetNoDraw(true) end
	end)
end