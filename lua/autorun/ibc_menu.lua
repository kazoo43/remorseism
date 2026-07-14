//===========================\\
//===Made by TRAVIESO========\\
//===========================\\

function IBC_CheckPlayersView(ent)
	local players = player:GetAll()
	for k,ply in pairs(players) do
		local wantedangle = (ent:GetPos() - ply:GetPos()):Angle()
		local anglediff =  math.AngleDifference(wantedangle.y,ply:GetAimVector():Angle().y)
		//print("IBC_CheckPlayersView: anglediff: ", anglediff, ent:GetModel())
		if anglediff < 80 && anglediff > -80 then
			//print("angulo entro de vista ", ent:GetModel())
			local tracedata = {}
			tracedata.start = ply:EyePos()
			tracedata.endpos = ent:GetPos()
			tracedata.filter = ent
			local trace = util.TraceLine(tracedata)
			//print("trace.HitWorld: ", trace.HitWorld)
			if !trace.HitWorld then
				//print("IBC_CheckPlayersView: return TRUE para ", ent:GetModel())
				return true // el cadaver esta a la vista
			end
		end
	end
	//print("IBC_CheckPlayersView: return FALSE para ", ent:GetModel())
	return false // el cadaver NO esta a la vista
end

local function IBC_Menu(Panel)
	Panel:ClearControls()
	local Params = {}
	Params.Label = "Check entities interval on map"
	Params.Command = "General_Cleanup_Interval"
	Params.Type = "Float"
	Params.Min = "0.1"
	Params.Max = "1"
	Panel:AddControl( "Slider", Params)

	local Params = {}
	Params.Label = "Clear entities in player view"
	Params.Command = "General_Cleanup_facing"
	Panel:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Clear VJ Base NPC Corpses"
	Params.Command = "General_Cleanup_VJBase"
	Panel:AddControl( "CheckBox", Params)

	local params = {}
	params.Text = "Clear all decals"
	params.Command = "r_cleardecals"
	Panel:AddControl("Button", params)

	local RagdollsP = Panel:AddControl("ControlPanel", {Label = "Corpses", Closed = false})

	local Params = {}
	Params.Label = "Clean small corpses of NPCs"
	Params.Command = "Ragdoll_Cleanup_RemoveSmall"
	RagdollsP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Clean medium corpses of NPCs"
	Params.Command = "Ragdoll_Cleanup_RemoveMedium"
	RagdollsP:AddControl( "CheckBox", Params)

    local Params = {}
	Params.Label = "Clean big and bosses corpses of NPCs"
	Params.Command = "Ragdoll_Cleanup_RemoveBig"
	RagdollsP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Remove Combine Turrets/Barnacles"
	Params.Command = "Ragdoll_Cleanup_RemoveCombineTurrets"
	RagdollsP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Remove player-created ragdolls"
	Params.Command = "Ragdoll_Cleanup_RemoveAll"
	RagdollsP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Min time to eliminate each corpse"
	Params.Command = "Ragdoll_Cleanup_MinTime"
	Params.Type = "Float"
	Params.Min = "1"
	Params.Max = "20"
	RagdollsP:AddControl( "Slider", Params)

	local Params = {}
	Params.Label = "Max number of bodies allowed"
	Params.Command = "Ragdoll_Cleanup_MaxEnts"
	Params.Type = "Integer"
	Params.Min = "1"
	Params.Max = "50"
	RagdollsP:AddControl( "Slider", Params)

	local Params = {}
	Params.Label = "Disappearance effect time"
	Params.Command = "Ragdoll_Cleanup_FadeTime"
	Params.Type = "Float"
	Params.Min = "0"
	Params.Max = "5"
	RagdollsP:AddControl( "Slider", Params)

	local RagdollsCP = Panel:AddControl("ControlPanel", {Label = "Corpses Collisions", Closed = false})
	local Params = {}
	Params.Label = "Not collide with NPC corpses"
	Params.Command = "Ragdoll_Cleanup_NoCollide"
	RagdollsCP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Not collide with big NPC corpses"
	Params.Command = "Ragdoll_Cleanup_NoCollideBig"
	RagdollsCP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Disable collisions between NPC corpses"
	Params.Command = "Ragdoll_Cleanup_NoCollideCorpses"
	RagdollsCP:AddControl( "CheckBox", Params)

	local DebrisP = Panel:AddControl("ControlPanel", {Label = "NPC Debris", Closed = false})
	local Params = {}
	Params.Label = "Clean debris pieces from dead NPCs"
	Params.Command = "Debris_Cleanup_Enabled"
	DebrisP:AddControl( "CheckBox", Params)	

	local Params = {}
	Params.Label = "Max debris pieces allowed"
	Params.Command = "Debris_Cleanup_MaxEnts"
	Params.Type = "Integer"
	Params.Min = "1"
	Params.Max = "200"
	DebrisP:AddControl( "Slider", Params)

	local WeaponP = Panel:AddControl("ControlPanel", {Label = "Weapons", Closed = false})
	local Params = {}
	Params.Label = "Clean weapons from downed NPCs"
	Params.Command = "Weapon_Cleanup_Enabled"
	WeaponP:AddControl( "CheckBox", Params)	

	local Params = {}
	Params.Label = "Time to remove each weapon"
	Params.Command = "Weapon_Cleanup_MinTime"
	Params.Type = "Float"
	Params.Min = "1"
	Params.Max = "60"
	WeaponP:AddControl( "Slider", Params)

	local Params = {}
	Params.Label = "Max number of weapons allowed"
	Params.Command = "Weapon_Cleanup_MaxEnts"
	Params.Type = "Integer"
	Params.Min = "1"
	Params.Max = "50"
	WeaponP:AddControl( "Slider", Params)

	local Params = {}
	Params.Label = "Disappearance effect time"
	Params.Command = "Weapon_Cleanup_FadeTime"
	Params.Type = "Float"
	Params.Min = "0"
	Params.Max = "5"
	WeaponP:AddControl( "Slider", Params)

	local itemP = Panel:AddControl("ControlPanel", {Label = "Items", Closed = false})
	local Params = {}
	Params.Label = "Remove dropped Items"
	Params.Description = "Remove Ar2 Altfire"
	Params.Command = "Item_Cleanup_Enabled"
	itemP:AddControl( "CheckBox", Params)

	local Params = {}
	Params.Label = "Max number of items allowed"
	Params.Command = "Item_Cleanup_MaxEnts"
	Params.Type = "Integer"
	Params.Min = "1"
	Params.Max = "50"
	itemP:AddControl( "Slider", Params)
end

local function StartIBCMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "IBCOptions", "Inmersive Battle Cleanup", "", "", IBC_Menu)
end
hook.Add( "PopulateToolMenu", "PopulateIBCMenu", StartIBCMenu )