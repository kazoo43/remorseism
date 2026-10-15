hg.organism = hg.organism or {}
--local Organism = hg.organism
hg.organism.list = hg.organism.list or {}
local hook_Run = hook.Run
function hg.organism.EnsureO2(org)
	if not istable(org) then return end

	local o2 = org.o2
	if istable(o2) then
		if not isnumber(o2.range) then o2.range = 30 end
		if not isnumber(o2.regen) then o2.regen = 4 end
		if not isnumber(o2.k) then o2.k = 0.5 end
		if not isnumber(o2[1]) then o2[1] = o2.range end
		if not isnumber(o2.curregen) then o2.curregen = o2.regen end
		return o2
	end

	o2 = {
		[1] = isnumber(o2) and o2 or 30,
		range = 30,
		regen = 4,
		k = 0.5,
		curregen = 4
	}
	org.o2 = o2
	return o2
end

function hg.organism.Add(ent)
	ent.organism = {
		owner = ent
	}

	local org = ent.organism
	org.owner = ent
	hg.organism.list[ent] = org
	return org
end

function hg.organism.Clear(org)
	if not istable(org) then return end
	hook_Run("Org Clear", org)//.owner.organism_internal)
	if IsValid(org.owner) then org.owner.fullsend = true end
	hg.send_organism(org)
end

function hg.organism.Remove(ent)
	local org = hg.organism.list[ent]
	if org then org.owner = nil end
	hg.organism.list[ent] = nil
end

hook.Add("PlayerInitialSpawn", "homigrad-organism", function(ply) hg.organism.Add(ply) end)
hook.Add("Player Spawn", "homigrad-organism", function(ply) hg.organism.Clear(ply.organism) end)
hook.Add("PlayerDisconnected", "homigrad-organism", function(ply) hg.organism.Remove(ply) end)
hook.Add("PostPlayerDeath", "homigrad-organism", function(ply)
	local ragdoll = ply:GetNWEntity("RagdollDeath")
	
	if not IsValid(ragdoll) then ragdoll = ply.FakeRagdoll end

	if IsValid(ragdoll) then
		local newOrg = hg.organism.Add(ragdoll)
		table.Merge(newOrg, ply.organism)

		hook.Run("RagdollDeath", ply, ragdoll)

		table.Merge(zb.net.list[ragdoll], zb.net.list[ply])

		newOrg.alive = false
		newOrg.owner = ragdoll
		ragdoll:CallOnRemove("organism", hg.organism.Remove, ragdoll)
		newOrg.owner.fullsend = true
		hg.send_bareinfo(newOrg)
	end

	hg.organism.Clear(ply.organism)

	hook.Run("PostPostPlayerDeath", ply, ragdoll)
end)

local tickrate = 1 / 10
local delay = 0
local time, mulTime, start
local CurTime = CurTime
local SysTime = SysTime
timer.Create("homigrad-organism", tickrate, 0, function()
	time = CurTime()
	local tickrate2 = tickrate// / math.max(game.GetTimeScale(), 0.01)
	//print(delay ,time + tickrate)
	if delay + tickrate2 > time then return end

	delay = time

	if not start then
		start = SysTime()
		return
	end
	
	local sysTime = SysTime()
	mulTime = (sysTime - start) * game.GetTimeScale()

	start = sysTime
	for owner, org in pairs(hg.organism.list) do -- теперь ясно почему от трупов лагает...
		if not IsValid(owner) or org.owner ~= owner then hg.organism.list[owner] = nil continue end
		if not istable(org.o2) then hg.organism.EnsureO2(org) end
		if org.godmode then continue end
		hook_Run("Org Think", owner, org, mulTime)
	end
end)

local lastcall = SysTime()
hook.Add("Org Think Call", "homigrad-organism", function(owner, org)
	if not IsValid(owner) or not org or org.owner ~= owner then return end
	local sysTime = SysTime()
	if (sysTime - lastcall) < tickrate then return end
	lastcall = sysTime
	if not istable(org.o2) then hg.organism.EnsureO2(org) end
	hook_Run("Org Think", owner, org, 0.00001)
end)


hook.Add("Fake", "organism", function(ply, ragdoll)
	ragdoll.organism = ply.organism
	--zb.net.list[ragdoll] = zb.net.list[ply]
end)
