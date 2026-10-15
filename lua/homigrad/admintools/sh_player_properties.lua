local function check(self, ent, ply)
	if not IsValid(ply) or not ply:ZCTools_GetAccess() then return false end
	if ( !IsValid( ent ) ) then return false end
	if ( ent:IsPlayer() ) then return true end
    local pEnt = hg.RagdollOwner( ent )
    if ( ent:IsRagdoll() ) and pEnt and pEnt:IsPlayer() and pEnt:Alive() then return true end
end

local function getOrganismTarget(ent)
	if not IsValid(ent) then return end

	ent = hg.RagdollOwner(ent) or hg.GetCurrentCharacter(ent) or ent
	if not IsValid(ent) then return end

	return ent, istable(ent.organism) and ent.organism or nil
end

local function sendOrganismToPlayer(org)
	if not istable(org) or not hg.send_organism or not IsValid(org.owner) then return end

	local owner = org.owner
	if not owner:IsPlayer() then
		owner = hg.RagdollOwner(owner) or owner:GetNWEntity("ply")
	end

	if IsValid(owner) and owner:IsPlayer() then
		hg.send_organism(org, owner)
	end
end
properties.Add( "notify", {
	MenuLabel = "Notify", -- Name to display on the context menu
	Order = 1, -- The order to display this property relative to other properties
	MenuIcon = "icon16/note_add.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_StringRequest(
            "Notify ".. ent:GetPlayerName(), 
            "Write a message",
            "",
            function(text) 
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteString( text )
                self:MsgEnd()
            end
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        local text = net.ReadString()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent

		ent:Notify( text, 0 )
		print(tostring(ply:Nick() or ply) .." has notfied ".. tostring(ent:Nick() or ent) .." with the following message; "..text)
	end 
} )

properties.Add( "givegun", {
	MenuLabel = "Give", -- Name to display on the context menu
	Order = 2, -- The order to display this property relative to other properties
	MenuIcon = "icon16/gun.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_StringRequest(
            "Give ".. ent:GetPlayerName(), 
            "Write a entity class name",
            "",
            function(text) 
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteString( text )
                self:MsgEnd()
            end
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        local text = net.ReadString()
		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent

		local spawned = ent:Give( text )
        if not IsValid(spawned) then return end
        spawned:Use(ent)
		print(tostring(ply:Nick() or ply) .." has given ".. tostring(ent:Nick() or ent) .." a SWEP; "..text)
	end 
} )

properties.Add( "strip", {
	MenuLabel = "Strip", -- Name to display on the context menu
	Order = 3, -- The order to display this property relative to other properties
	MenuIcon = "icon16/basket_delete.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_Query(
            "The player will be stripped down to only their fists.",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
            end,
        	"No"
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent
		ent:StripWeapons( )
        ent:Give("weapon_hands_sh")
		print(tostring(ply:Nick() or ply) .." has stripped ".. tostring(ent:Nick() or ent) .." of their weapons.")
	end 
} )

properties.Add( "fullstrip", {
	MenuLabel = "Full Strip", -- Name to display on the context menu
	Order = 4, -- The order to display this property relative to other properties
	MenuIcon = "icon16/lorry_delete.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_Query(
            "All weapons, including fists, will be stripped.",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
            end,
        	"No"
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent

		ent:StripWeapons( )
		print(tostring(ply:Nick() or ply) .." has full stripped ".. tostring(ent:Nick() or ent) .." of their weapons and fist.")
	end 
} )

properties.Add( "reset_org", {
	MenuLabel = "Reset organism", -- Name to display on the context menu
	Order = 5, -- The order to display this property relative to other properties
	MenuIcon = "icon16/heart_add.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_Query(
            "Organism will be new like a respawn",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
            end,
        	"No"
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
		ent = hg.RagdollOwner( ent ) or ent
		if not istable(ent.organism) then return end

		hg.organism.Clear(ent.organism)
		sendOrganismToPlayer(ent.organism)
		print(tostring(ply:Nick() or ply) .." reset the health of ".. tostring(ent:Nick() or ent))
	end 
} )

properties.Add( "freeze", {
	MenuLabel = "Freeze", -- Name to display on the context menu
	Order = 6, -- The order to display this property relative to other properties
	MenuIcon = "icon16/control_pause_blue.png", -- The icon to display next to the property

	Filter = function( self, ent, ply )
        if not ply:ZCTools_GetAccess() then return false end 
	    if ( !IsValid( ent ) ) then return false end
        local pEnt = hg.RagdollOwner( ent ) or ent
        self.MenuLabel = pEnt:IsPlayer() and pEnt:IsFrozen() and "Unfreeze" or "Freeze"
        self.MenuIcon = pEnt:IsPlayer() and pEnt:IsFrozen() and "icon16/control_pause.png" or "icon16/control_pause_blue.png"
	    if ( ent:IsPlayer() ) then return true end
        if ( ent:IsRagdoll() ) and pEnt and pEnt:IsPlayer() and pEnt:Alive() then return true end
    end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent
        
		ent:Freeze(not ent:IsFrozen())
		print(tostring(ply:Nick() or ply) .. (not ent:IsFrozen() and " has frozen " or " has unfrozen ").. tostring(ent:Nick() or ent))
	end 
} )

properties.Add( "snatch", {
	MenuLabel = "Snatch", -- Name to display on the context menu
	Order = 7, -- The order to display this property relative to other properties
	MenuIcon = "icon16/cross.png", -- The icon to display next to the property

	Filter = function(self, ent, ply)
        if !CurrentRound then return false end
        
        return check(self, ent, ply)
    end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
        Derma_Query(
            "If no players are around, he will simply disappear.",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
            end,
        	"No"
        )

	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent

		local bot = ents.Create("bot_fear")
        bot.Victim = ent
        bot:Spawn()
		print(tostring(ply:Nick() or ply) .." has snatched ".. tostring(ent:Nick() or ent))
	end 
} )

properties.Add( "ragdollize", {
	MenuLabel = "Stun/Get up", -- Name to display on the context menu
	Order = 8, -- The order to display this property relative to other properties
	MenuIcon = "icon16/anchor.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		if not self:Filter(ent, ply) then return end
        ent = hg.RagdollOwner(ent) or ent

		if not IsValid(ent.FakeRagdoll) then
			print(tostring(ply:Nick() or ply) .." has stunned ".. tostring(ent:Nick() or ent))
			hg.LightStunPlayer(ent, 5)
		else
			print(tostring(ply:Nick() or ply) .." has unstunned ".. tostring(ent:Nick() or ent))
			hg.FakeUp(ent)
		end
	end 
} )

properties.Add( "vomit", {
	MenuLabel = "Make vomit", -- Name to display on the context menu
	Order = 9, -- The order to display this property relative to other properties
	MenuIcon = "pluv/pluv51.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		if not self:Filter(ent, ply) then return end
        ent = hg.RagdollOwner(ent) or ent
		if not istable(ent.organism) or not hg.organism or not hg.organism.Vomit then return end

		hg.organism.Vomit(ent)
		print(tostring(ply:Nick() or ply) .." forced ".. tostring(ent:Nick() or ent) .." to vomit.")
	end 
} )

properties.Add( "lobotomize", {
	MenuLabel = "Lobotomize", -- Name to display on the context menu
	Order = 10, -- The order to display this property relative to other properties
	MenuIcon = "pluv/pluv51.png", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        
		if not self:Filter(ent, ply) then return end
        ent = hg.RagdollOwner(ent) or ent
		if not istable(ent.organism) then return end

		ent.organism.brain = math.min((ent.organism.brain or 0) + 0.05, 1)
		sendOrganismToPlayer(ent.organism)
        ply:ChatPrint("Lobotomized brain to "..math.Round(ent.organism.brain * 100).."%")
        print(tostring(ply:Nick() or ply) .." has lobotomized ".. tostring(ent:Nick() or ent))

        if ent.organism.brain >= 0.25 and ent.organism.brain < 0.3 then
            ply:ChatPrint("Consciousness loss on the next lobotomization!")
        end
    end 
} )

properties.Add("killsilent", {
	MenuLabel = "Kill (Silent)",
	Order = 11,
	MenuIcon = "icon16/cross.png",

	Filter = check,
	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent
		print(tostring(ply:Nick() or ply) .." has silently killed ".. tostring(ent:Nick() or ent))
		ent:Kill()
	end 
})

properties.Add("removeply", {
	MenuLabel = "Remove",
	Order = 12,
	MenuIcon = "icon16/cross.png",

	Filter = check,
	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if ( !self:Filter( ent, ply ) ) then return end
        ent = hg.RagdollOwner( ent ) or ent
		print(tostring(ply:Nick() or ply) .." has removed ".. tostring(ent:Nick() or ent))
		ent:KillSilent()
		ent:Remove()
	end 
})

properties.Add( "setplayerclass", {
	MenuLabel = "Set player class", -- Name to display on the context menu
	Order = 15, -- The order to display this property relative to other properties
	MenuIcon = "vgui/entities/npc_nukude_proto_h", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	PlayerClass = function( self, ent, name )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteString( name )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end -- this line was not here before
		local class = net.ReadString( )

		ent = hg.RagdollOwner(ent) or hg.GetCurrentCharacter(ent) or ent
		if IsValid(ent) and ent:IsPlayer() and player.classList[class] then
			ent:SetPlayerClass(class)
		end
	end,
	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()

		for name, tbl in pairs(player.classList) do
			local opt = submenu:AddOption(name)
			opt:SetRadio(true)
			opt:SetChecked(ent.PlayerClassName == name)
			opt:SetIsCheckable(true)
			opt.OnChecked = function(s, checked)
				self:PlayerClass(ent, name)
			end	
		end
	end
} )

properties.Add( "break_limb", {
	MenuLabel = "Break Limb",
	Order = 13,
	MenuIcon = "pluv/pluv51.png",

	Filter = check,
	MenuOpen = function( self, option, ent, tr )
		local org
		ent, org = getOrganismTarget(ent)
		if not org then return end

		local submenu = option:AddSubMenu()

		local neck = submenu:AddOption("Neck")
		neck:SetRadio(true)
		neck:SetChecked((org.spine3 or 0) > 0)
		neck:SetIsCheckable(true)
		neck.OnChecked = function(s, checked) self:BreakLimb(ent, 0) end

		local larm = submenu:AddOption("Left Arm")
		larm:SetRadio(true)
		larm:SetChecked((org.larm or 0) > 0)
		larm:SetIsCheckable(true)
		larm.OnChecked = function(s, checked) self:BreakLimb(ent, 1) end

		local rarm = submenu:AddOption("Right Arm")
		rarm:SetRadio(true)
		rarm:SetChecked((org.rarm or 0) > 0)
		rarm:SetIsCheckable(true)
		rarm.OnChecked = function(s, checked) self:BreakLimb(ent, 2) end

		local lleg = submenu:AddOption("Left Leg")
		lleg:SetRadio(true)
		lleg:SetChecked((org.lleg or 0) > 0)
		lleg:SetIsCheckable(true)
		lleg.OnChecked = function(s, checked) self:BreakLimb(ent, 3) end

		local rleg = submenu:AddOption("Right Leg")
		rleg:SetRadio(true)
		rleg:SetChecked((org.rleg or 0) > 0)
		rleg:SetIsCheckable(true)
		rleg.OnChecked = function(s, checked) self:BreakLimb(ent, 4) end

		local spine1 = submenu:AddOption("Spine 1")
		spine1:SetRadio(true)
		spine1:SetChecked((org.spine1 or 0) > 0)
		spine1:SetIsCheckable(true)
		spine1.OnChecked = function(s, checked) self:BreakLimb(ent, 5) end

		local spine2 = submenu:AddOption("Spine 2")
		spine2:SetRadio(true)
		spine2:SetChecked((org.spine2 or 0) > 0)
		spine2:SetIsCheckable(true)
		spine2.OnChecked = function(s, checked) self:BreakLimb(ent, 6) end

		local spine3 = submenu:AddOption("Spine 3")
		spine3:SetRadio(true)
		spine3:SetChecked((org.spine3 or 0) > 0)
		spine3:SetIsCheckable(true)
		spine3.OnChecked = function(s, checked) self:BreakLimb(ent, 7) end
	end,

	BreakLimb = function( self, ent, id )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( id, 8 )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		local limb = net.ReadUInt( 8 )
        
		if not self:Filter(ent, ply) then return end
		local org
		ent, org = getOrganismTarget(ent)
		if not ent or not org or not hg.organism or not hg.organism.input_list then return end
		if limb < 0 or limb > 7 then return end

		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(100)
		-- The bone handlers treat generic/crush damage as blunt impact, which
		-- is intentionally damped or may amputate limbs instead of breaking them.
		dmgInfo:SetDamageType(DMG_BULLET)
		dmgInfo:SetAttacker(game.GetWorld())
		dmgInfo:SetInflictor(game.GetWorld())
		if limb == 0 then
            hg.BreakNeck(ent)
		elseif limb == 1 then
			if not hg.organism.input_list.larmup then return end
			hg.organism.input_list.larmup(org, 0, 100, dmgInfo)
		elseif limb == 2 then
			if not hg.organism.input_list.rarmup then return end
			hg.organism.input_list.rarmup(org, 0, 100, dmgInfo)
		elseif limb == 3 then
			if not hg.organism.input_list.llegup then return end
			hg.organism.input_list.llegup(org, 0, 100, dmgInfo)
		elseif limb == 4 then
			if not hg.organism.input_list.rlegup then return end
			hg.organism.input_list.rlegup(org, 0, 100, dmgInfo)
		elseif limb == 5 then
			if not hg.organism.input_list.spine1 then return end
			hg.organism.input_list.spine1(org, 0, 100, dmgInfo)
		elseif limb == 6 then
			if not hg.organism.input_list.spine2 then return end
			hg.organism.input_list.spine2(org, 0, 100, dmgInfo)
		elseif limb == 7 then
			if not hg.organism.input_list.spine3 then return end
			hg.organism.input_list.spine3(org, 0, 100, dmgInfo)
		end
		if limb ~= 0 and ent:Alive() then sendOrganismToPlayer(org) end
	end
} )

properties.Add( "amputate_limb", {
	MenuLabel = "Amputate Limb",
	Order = 14,
	MenuIcon = "effects/arc9_eft/evil.png",

	Filter = check,
	MenuOpen = function( self, option, ent, tr )
		local org
		ent, org = getOrganismTarget(ent)
		if not org then return end

		local submenu = option:AddSubMenu()

		local head = submenu:AddOption("Head")
		head:SetRadio(true)
		head:SetChecked(org.headamputated == true)
		head:SetIsCheckable(true)
		head.OnChecked = function(s, checked) self:AmputateLimb(ent, 0) end

		local larm = submenu:AddOption("Left Arm")
		larm:SetRadio(true)
		larm:SetChecked(org.larmamputated == true)
		larm:SetIsCheckable(true)
		larm.OnChecked = function(s, checked) self:AmputateLimb(ent, 1) end

		local rarm = submenu:AddOption("Right Arm")
		rarm:SetRadio(true)
		rarm:SetChecked(org.rarmamputated == true)
		rarm:SetIsCheckable(true)
		rarm.OnChecked = function(s, checked) self:AmputateLimb(ent, 2) end

		local lleg = submenu:AddOption("Left Leg")
		lleg:SetRadio(true)
		lleg:SetChecked(org.llegamputated == true)
		lleg:SetIsCheckable(true)
		lleg.OnChecked = function(s, checked) self:AmputateLimb(ent, 3) end

		local rleg = submenu:AddOption("Right Leg")
		rleg:SetRadio(true)
		rleg:SetChecked(org.rlegamputated == true)
		rleg:SetIsCheckable(true)
		rleg.OnChecked = function(s, checked) self:AmputateLimb(ent, 4) end

		local torso = submenu:AddOption("Amputate Torso")
		torso:SetRadio(true)
		torso:SetIsCheckable(true)
		torso.OnChecked = function(s, checked) self:AmputateLimb(ent, 5) end
	end,

	AmputateLimb = function( self, ent, id )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( id, 8 )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		local limb = net.ReadUInt( 8 )
        
		if not self:Filter(ent, ply) then return end
        ent = hg.RagdollOwner(ent) or ent
		if not IsValid(ent) or not hg.organism then return end
		if limb < 0 or limb > 5 then return end
		if limb >= 1 and limb <= 4 and not istable(ent.organism) then return end
        
        local dmgInfo = DamageInfo()
		if limb == 0 then
			if SERVER and not ent.noHead then
				hg.ExplodeHead(ent)
			end
        elseif limb == 1 then
			if not hg.organism.AmputateLimb then return end
			hg.organism.AmputateLimb(ent.organism, "larm")
		elseif limb == 2 then
			if not hg.organism.AmputateLimb then return end
			hg.organism.AmputateLimb(ent.organism, "rarm")
		elseif limb == 3 then
			if not hg.organism.AmputateLimb then return end
			hg.organism.AmputateLimb(ent.organism, "lleg")
		elseif limb == 4 then
			if not hg.organism.AmputateLimb then return end
			hg.organism.AmputateLimb(ent.organism, "rleg")
		elseif limb == 5 then
			if not hg.AmputateTorso then return end
			hg.AmputateTorso(ent, VectorRand(-250, 250), false)
		end
		if limb >= 1 and limb <= 4 then sendOrganismToPlayer(ent.organism) end
	end
} )

local function doorCheck(self, ent, ply)
    if not ply:IsAdmin() then return false end
    if not IsValid(ent) then return false end
    if not ent:GetClass():lower():find("door") then return false end
    return true
end

properties.Add( "door_toggle", {
    MenuLabel = "Toggle Door",
    Order = 7,
    MenuIcon = "icon16/door.png",
    Filter = doorCheck,
    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not self:Filter(ent, ply) then return end
        ent:Fire("toggle")
    end
})

properties.Add( "door_lock", {
    MenuLabel = "Lock Door",
    Order = 8,
    MenuIcon = "icon16/lock.png",
    Filter = doorCheck,
    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not self:Filter(ent, ply) then return end
        ent:Fire("lock")
    end
})

properties.Add( "door_unlock", {
    MenuLabel = "Unlock Door",
    Order = 9,
    MenuIcon = "icon16/lock_open.png",
    Filter = doorCheck,
    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not self:Filter(ent, ply) then return end
        ent:Fire("unlock")
    end
})

local defaultinv = {
    Weapons = {},
    Ammo = {},
    Armor = {},
    Attachments = {}
}
local function Respawn(ply,body)
    if ply:Alive() then
        ply:Kill()
    end
    ply.gottarespawn = true
    //OverrideSpawn = true
    timer.Simple(0.1, function()
        ply:Spawn()
        //OverrideSpawn = false
        timer.Simple(0.1, function()
            ply.inventory = table.Copy(body.inventory or defaultinv)
            --PrintTable(ply.inventory)
            
            ply:SetNetVar("Inventory", ply.inventory)
            ply:SetNetVar("Armor",body:GetNetVar( "Armor", {} ))
            ply:SetNetVar("HideArmorRender", body:GetNetVar("HideArmorRender", false))
            body:SetNetVar( "Armor", {} )
            body:SetNetVar("HideArmorRender", false)

            for k,v in pairs( ply.inventory["Weapons"] ) do
                --print(k,v)
                if v == true or not IsValid(v) then continue end
                v:SetParent( ply )
                v:SetOwner( ply )
                v:Use( ply )
            end
            for k,v in pairs( ply.inventory["Ammo"] ) do
                --print(k,v)
                ply:SetAmmo( v, k )
            end
            ply:Give( "weapon_hands_sh" )
            hg.Fake( ply, body )
            hg.LightStunPlayer( ply )

            timer.Simple(0.1,function()
                if body.CurAppearance then
                    local color = body:GetNWVector("PlayerColor", vector_origin)
                    body.CurAppearance.AColor = Color( color[1] * 255,color[2] * 255,color[3] * 255 )
                    ply:SetPlayerColor(color)
                    hg.Appearance.ForceApplyAppearance( ply, body.CurAppearance )
                    ply:SetModel(body:GetModel())
                else
                    -- prevent funny submaterial glitch
                    local Appearance = ply.CurAppearance or hg.Appearance.GetRandomAppearance()
                    Appearance.AColthes = ""
                    ply:SetNetVar("Accessories", "")
                    ply:SetModel(body:GetModel())
                    ply:SetSubMaterial()
                    ply:SetPlayerColor(ply:GetNWVector("PlayerColor", vector_origin))
                end
                ply:Give( "weapon_hands_sh" )
            end)
        end)
    end)
end

hg.RespawnIntoBody = Respawn

properties.Add( "respawn_ply_in_rag", {
	MenuLabel = "Respawn Player", -- Name to display on the context menu
	Order = 1, -- The order to display this property relative to other properties
	MenuIcon = "icon16/heart.png", -- The icon to display next to the property

	Filter = function( self, ent, ply )
        if not ply:ZCTools_GetAccess() then return false end 
	    if ( !IsValid( ent ) ) then return false end
        local pEnt = hg.RagdollOwner( ent ) or ent
        if ( pEnt:IsRagdoll() ) then return true end
    end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

        hg.DermaPlayerQuery(
            function( ply )
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteEntity( ply )
                self:MsgEnd()
        end)
        
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        local sPly = net.ReadEntity()
		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        --ent = hg.RagdollOwner( ent ) or ent
        
		Respawn(sPly,ent)
	end 
} )

properties.Add( "respawn_lply_in_rag", {
	MenuLabel = "Spawn Self", -- Name to display on the context menu
	Order = 2, -- The order to display this property relative to other properties
	MenuIcon = "icon16/heart.png", -- The icon to display next to the property

	Filter = function( self, ent, ply )
        if not ply:ZCTools_GetAccess() then return false end 
	    if ( !IsValid( ent ) ) then return false end
        local pEnt = hg.RagdollOwner( ent ) or ent
        if ( pEnt:IsRagdoll() ) then return true end
    end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

        Derma_Query(
            "You will take over this body, and respawn as this character.",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteEntity( LocalPlayer() )
                self:MsgEnd()
            end,
        	"No"
        )    
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        local sPly = net.ReadEntity()
		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        --ent = hg.RagdollOwner( ent ) or ent
        
		Respawn(sPly,ent)
	end 
} )

properties.Add( "respawn_ragply_in_rag", {
	MenuLabel = "Spawn RagOwner", -- Name to display on the context menu
	Order = 3, -- The order to display this property relative to other properties
	MenuIcon = "icon16/heart.png", -- The icon to display next to the property

	Filter = function( self, ent, ply )
        if not ply:ZCTools_GetAccess() then return false end 
	    if ( !IsValid( ent ) ) then return false end
        local pEnt = hg.RagdollOwner( ent ) or ent
        if ( pEnt:IsRagdoll() ) then return true end
    end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

        Derma_Query(
            "The Player of this ragdoll will be respawned into his body",
            "Are you sure?",
            "Yes",
            function()
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
            end,
        	"No"
        )    
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        local sPly = ent.ply
		--if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end
        if not sPly then return end
        --ent = hg.RagdollOwner( ent ) or ent
        
		Respawn(sPly,ent)
	end 
} )


--hg.Fake(owner, body)
