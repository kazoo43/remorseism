//===========================\\
//===Made by TRAVIESO========\\
//==Inmersive Battle Cleanup=\\
//===========================\\
local ConVars = {}
ConVars[1] = {"General_Cleanup_Interval",1}
ConVars[2] = {"General_Cleanup_facing",0}
ConVars[3] = {"General_Cleanup_VJBase",1}	
ConVars[4] = {"Ragdoll_Cleanup_RemoveSmall",1}
ConVars[5] = {"Ragdoll_Cleanup_RemoveMedium",1}
ConVars[6] = {"Ragdoll_Cleanup_RemoveBig",1}
ConVars[7] = {"Ragdoll_Cleanup_RemoveAll",0}
ConVars[8] = {"Ragdoll_Cleanup_MinTime",15}
ConVars[9] = {"Ragdoll_Cleanup_MaxEnts",20}
ConVars[10] = {"Ragdoll_Cleanup_FadeTime",1}
ConVars[11] = {"Ragdoll_Cleanup_NoCollide",1}
ConVars[12] = {"Ragdoll_Cleanup_NoCollideBig",0}
ConVars[13] = {"Ragdoll_Cleanup_NoCollideCorpses",0}
ConVars[14] = {"Weapon_Cleanup_Enabled",1}
ConVars[15] = {"Weapon_Cleanup_MinTime",8}
ConVars[16] = {"Weapon_Cleanup_MaxEnts",6}
ConVars[17] = {"Weapon_Cleanup_FadeTime",2}
ConVars[18] = {"Item_Cleanup_Enabled",1}
ConVars[19] = {"Item_Cleanup_MaxEnts",10}
ConVars[20] = {"Debris_Cleanup_Enabled",1}
ConVars[21] = {"Debris_Cleanup_MaxEnts",30}
ConVars[22] = {"Ragdoll_Cleanup_RemoveCombineTurrets",0}
for i=1,#ConVars do
	if !ConVarExists(ConVars[i][1]) then
		CreateConVar(ConVars[i][1],ConVars[i][2],FCVAR_ARCHIVE)
	end
	cvars.AddChangeCallback(ConVars[i][1], function () 
		IBC_RefreshTables()
	end)
end

local ProtectWeaponsMapTime = CurTime() + 3
local NextCleanup = 0
local FadindRagdolls = false
local FadindDebris = false
local FadindWeapons = false
local FadindItems = false
local NPCRagdolls = {}
local NPCDebris = {}
local DroppedWeapons = {}
local DroppedItems = {}

local MediumRagdolls = {
	"models/sc/shark.mdl","models/piratecat_npc/blue_shark_ragdoll/blue_shark.mdl",
	"models/piratecat_npc/hammerhead_shark.mdl","models/opfor/gonome.mdl",
	"models/opfor/strooper.mdl","models/half-life/agrunt.mdl","models/devilsquid.mdl",
	"models/half-life/blacsquid.mdl","models/half-life/bullsquid.mdl","models/half-life/poissquid.mdl",
	"models/toxicsquid.mdl","models/frostsquid.mdl","models/half-life/mrfriendly.mdl"}

local BigAndBossesRagdolls = {
	"models/vehicles/m1a1abrams_chasis.mdl","models/vehicles/m1a1abrams_turret.mdl",
	"models/gibs/apache_gibs/apachb_fueselage.mdl","models/piratecat_npc/white_shark_ragdoll/shark_a.mdl",
 	"models/combine_strider.mdl","models/antlion_guard.mdl","models/decay/sblack.mdl",
 	"models/half-life/sblack.mdl","models/decay/sentry.mdl","models/half-life/sentry.mdl",
    "models/hunter.mdl","models/npc/dragon/npc_dragon.mdl","models/opfor/voltigore.mdl",
    "models/babygarg.mdl","models/gargantua.mdl","models/half-life/big_mom.mdl",
    "models/xenians/ichthyosaur.mdl","models/half-life/kingpin.mdl","models/half-life/icky.mdl",
    "models/tor.mdl","models/strider_parts/strider_brain.mdl","models/gibs/strider_head.mdl",
    "models/gibs/strider_weapon.mdl","models/gibs/strider_back_leg.mdl",
    "models/gibs/strider_left_leg.mdl","models/gibs/strider_right_leg.mdl","models/gunship.mdl"}

local CollisionBigRagdolls = {
	"models/vehicles/m1a1abrams_chasis.mdl","models/vehicles/m1a1abrams_turret.mdl",
	"models/gibs/apache_gibs/apachb_fueselage.mdl","models/piratecat_npc/white_shark_ragdoll/shark_a.mdl",
	"models/half-life/kingpin.mdl","models/combine_strider.mdl","models/antlion_guard.mdl",
	"models/npc/dragon/npc_dragon.mdl","models/opfor/voltigore.mdl","models/babygarg.mdl",
	"models/gargantua.mdl","models/half-life/big_mom.mdl","models/gunship.mdl",
	"models/xenians/ichthyosaur.mdl","models/half-life/icky.mdl"}

local SizeTables = {MediumRagdolls, BigAndBossesRagdolls}
local StaticCorpses = {
	["models/combine_turrets/ceiling_turret.mdl"] = true,
	["models/combine_camera/combine_camera.mdl"] = true,
	["models/barnacle.mdl"] = true
}
local Items = {"item_*","vj_*"}
local Weapons = {
	"weapon_*","ai_weapon_*","gmod_tool*","gmod_camera*","manhack_welder*",
	"tfa_*",      -- TFA Base
	"m9k_*",      -- M9K Specialties
	"cw_*",       -- Customizable Weaponry 2.0
	"arc9_*",     -- Arctic's Customizable Weapons
	"arccw_*",    -- Arctic's Customizable Weapons
	"vj_*",       -- VJ Base
	"meleearts*"  -- Melee Arts 2
}
local Corpses = {
	"prop_ragdoll",
	"prop_ragdoll_attached",
	"raggib",
	"npc_barnacle",
	"npc_turret_ceiling",
	"npc_combine_camera"
}
local Debris = {
	"npc_helicoptersensor", //helicopter gibs
	"gib", //helicopter, APC and barnacles gibs
	"helicopter_chunk" //helicopter gibs
}

function IBC_Main()
	if CurTime() >= NextCleanup then
		NextCleanup = CurTime() + GetConVar("General_Cleanup_Interval"):GetFloat()

		if GetConVar("Weapon_Cleanup_Enabled"):GetBool() then
			IBC_GetDroppedWeapons()
			if table.Count(DroppedWeapons) >  GetConVar("Weapon_Cleanup_MaxEnts"):GetInt() then
				//print("mas weapons de los permitidos, entrado a delete")
				DroppedWeapons = IBC_DeleteEntity(DroppedWeapons,"Weapon")
			end
		end

		if GetConVar("Item_Cleanup_Enabled"):GetBool() then
			IBC_GetDroppedItems()
			if table.Count(DroppedItems) >  GetConVar("Item_Cleanup_MaxEnts"):GetInt() then
				//print("mas items de los permitidos, entrado a delete")
				DroppedItems = IBC_DeleteEntity(DroppedItems,"Item")
			end
		end

		if GetConVar("Debris_Cleanup_Enabled"):GetBool() then
			IBC_GetDebrisGibs()
			if table.Count(NPCDebris) > GetConVar("Debris_Cleanup_MaxEnts"):GetInt() then
				//print("mas debris de los permitidos, entrado a delete")
				NPCDebris = IBC_DeleteEntity(NPCDebris,"Debris")
			end
		end

		if GetConVar("Ragdoll_Cleanup_RemoveSmall"):GetBool() || 
			GetConVar("Ragdoll_Cleanup_RemoveMedium"):GetBool() || 
			GetConVar("Ragdoll_Cleanup_RemoveBig"):GetBool() || 
			GetConVar("Ragdoll_Cleanup_NoCollide"):GetBool() || 
			GetConVar("Ragdoll_Cleanup_NoCollideBig"):GetBool() then
			IBC_GetDeadRagdolls()
			if table.Count(NPCRagdolls) > GetConVar("Ragdoll_Cleanup_MaxEnts"):GetInt() then
				//print("mas Ragdolls de los permitidos, entrado a delete")
				NPCRagdolls = IBC_DeleteEntity(NPCRagdolls,"Ragdoll")
			end
		end
	end

	if FadindRagdolls then //print("Entrando a fadethink de Ragdoll")
		NPCRagdolls = IBC_FadeThink(NPCRagdolls,"Ragdoll") // y llamamos a fadethink para que vaya desapareciendo los seleccionados
	end

	if FadindDebris then //print("Entrando a fadethink de Debris")
		NPCDebris = IBC_FadeThink(NPCDebris,"Debris")
	end

	if FadindWeapons then //print("Entrando a fadethink de Weapon")
		DroppedWeapons = IBC_FadeThink(DroppedWeapons,"Weapon")
	end

	if FadindItems then //print("Entrando a fadethink de Item")
		DroppedItems = IBC_FadeThink(DroppedItems,"Item")
	end
end

function IBC_GetDeadRagdolls()
	local RagdollRemoveAll = GetConVar("Ragdoll_Cleanup_RemoveAll"):GetBool()
	local RagdollRemoveSmall = GetConVar("Ragdoll_Cleanup_RemoveSmall"):GetBool()
	local RagdollRemoveMedium = GetConVar("Ragdoll_Cleanup_RemoveMedium"):GetBool()
    local RagdollRemoveBig = GetConVar("Ragdoll_Cleanup_RemoveBig"):GetBool()
	local RagdollSolid = GetConVar("Ragdoll_Cleanup_NoCollide"):GetBool()
	local RagdollSolidBig = GetConVar("Ragdoll_Cleanup_NoCollideBig"):GetBool()
	local RagdollNoCollideBetweenCorpses = GetConVar("Ragdoll_Cleanup_NoCollideCorpses"):GetBool()
	local collisionType = COLLISION_GROUP_WEAPON
	local ragdolltable = IBC_ConstructTableCorpses()
	if RagdollNoCollideBetweenCorpses then collisionType = COLLISION_GROUP_DEBRIS else collisionType = COLLISION_GROUP_WEAPON end

	for k,ragdoll in pairs(ragdolltable) do
		//print("!ragdoll:GetNWBool(IBCChecked,false) es ", !ragdoll:GetNWBool("IBCChecked",false), ragdoll:IsValid())
		if ragdoll and ragdoll:IsValid() && !ragdoll:GetNWBool("IBCChecked",false) then
			local isSpecialCase = (ragdoll:GetClass() == "prop_ragdoll_attached" || (GetConVar("Ragdoll_Cleanup_RemoveCombineTurrets"):GetBool() && StaticCorpses[ragdoll:GetModel()]))
		   	local ragmodel = ragdoll:GetModel()
		   	local ragsize = 1 // 1=Small, 2=Medium, 3=BigOrBoss
		   	local IsVJBaseCorpse = false
		   	//print("Cadaver nuevo encontrado: ", ragmodel)
		   	if ragdoll:GetTable().OnDieFunctions then 
		   		IsVJBaseCorpse = (ragdoll:GetTable().OnDieFunctions["vj_".. ragdoll:EntIndex()] != nil) && GetConVar("General_Cleanup_VJBase"):GetBool()
			end
		   	/*PrintTable(ragdolltable)
		   	print("ragdoll:GetTable().OnDieFunctions: ", ragdoll:GetTable().OnDieFunctions)
		   	if ragdoll:GetTable().OnDieFunctions != nil then 
		   		PrintTable(ragdoll:GetTable().OnDieFunctions)
		   		print("VALOR: ", ragdoll:GetTable().OnDieFunctions["vj_".. ragdoll:EntIndex()])
		   		print("ragdoll.EntIndex() ", ragdoll:EntIndex())
		   	end*/
		   	if (!ragdoll:GetTable().OnDieFunctions || IsVJBaseCorpse) && (RagdollSolid || RagdollSolidBig) then
				local surface_body = 0
				local physobj
				for i=0,ragdoll:GetPhysicsObjectCount()-1 do
					physobj = ragdoll:GetPhysicsObjectNum(i)
					surface_body = surface_body + physobj:GetSurfaceArea()
				end
				local IsBig = (surface_body >= 21000)
				if !IsBig then
					for dir,model in pairs(CollisionBigRagdolls) do
						if ragmodel == model then
							IsBig = true
							break
						end
					end
				end
				if (IsBig && RagdollSolidBig) || (!IsBig && RagdollSolid) then
					ragdoll:SetCollisionGroup(collisionType)
				end
		   	end

		    if ((!ragdoll:GetTable().OnDieFunctions || IsVJBaseCorpse) || RagdollRemoveAll || isSpecialCase) && (RagdollRemoveSmall || RagdollRemoveMedium || RagdollRemoveBig) then
		    	local temp = 1
		    	for k,tble in pairs(SizeTables) do
					temp = temp+1
					for j,model in pairs(tble) do
						if ragmodel == model then
							ragsize = temp
							temp = 0
							break
						end
					end
					if temp == 0 then
						break
					end
				end

				if (ragsize == 1 && RagdollRemoveSmall) || (ragsize == 2 && RagdollRemoveMedium) || (ragsize == 3 && RagdollRemoveBig) then
					local Entry = { Entity = ragdoll, EntryTime = CurTime() }
					table.insert(NPCRagdolls, Entry)
					//print("agregando nuevo...")
				end
			end

		    ragdoll:SetNWBool("IBCChecked",true)
			if ragdoll:GetName() != "" && string.StartWith(ragdoll:GetName(),"HL2Features_") then
				ragdoll:SetName("") // fix for HL2Features Helicopter Bombing and Striders Cannon
			end
		end
	end
end

function IBC_GetDebrisGibs()
	local debristable = IBC_ConstructTableDebris()
	for k,debris in pairs(debristable) do
		if IsValid(debris) && !debris:GetNWBool("IBCChecked",false) then
			local Entry
			if debris:GetClass() == "helicopter_chunk" then
				Entry = {Entity = debris, EntryTime = CurTime() + 1}
			else
				Entry = {Entity = debris, EntryTime = CurTime()}
			end
			//print("metiendo uno a la tabla debris: ", debris:GetClass(), debris:GetModel())
			table.insert(NPCDebris, Entry)
            debris:SetNWBool("IBCChecked",true)
		end
	end
end

function IBC_GetDroppedWeapons()
	local weapontable = {}
    for k,v in pairs(Weapons) do
		weapontable = table.Add(weapontable, ents.FindByClass(v))
	end
    
    for k,v in pairs(weapontable) do
    	if (IsValid(v:GetCreator()) && v:GetCreator():IsPlayer()) || v:GetClass() == "gmod_cameraprop" then
    		//print("Excluyendo arma creada por jugador: ", v:GetClass())
    		v:SetNWBool("IBCChecked",true)
    		weapontable[k] = nil
    	end
    end

	for k,gun in pairs(weapontable) do
		if CurTime() < ProtectWeaponsMapTime then
			//print("Excluyendo arma de mapa!: ", gun:GetClass())
			gun:SetNWBool("IBC_isMapEntity",true)
    		weapontable[k] = nil
		elseif gun && gun:IsValid() && gun:GetOwner() == NULL && !gun:GetNWBool("IBCChecked",false) && !gun:GetNWBool("IBC_isMapEntity",false) then
			//print("agregando arma a lista de limpieza: ", gun:GetClass())
			local Entry = { Entity = gun, EntryTime = CurTime() }
			table.insert(DroppedWeapons, Entry)
            gun:SetNWBool("IBCChecked",true)
		end
	end
end

function IBC_GetDroppedItems()
	local itemtable = {}
	for k,v in pairs(Items) do
		itemtable = table.Add(itemtable, ents.FindByClass(v))
	end

	for k,v in pairs(itemtable) do
    	if v:GetClass() == "item_item_crate" || v:GetClass() == "item_ammo_crate" || (IsValid(v:GetCreator()) && v:GetCreator():IsPlayer()) then
    		v:SetNWBool("IBCChecked",true)
    		itemtable[k] = nil
    	end
    end

	for k,gun in pairs(itemtable) do
		if CurTime() < ProtectWeaponsMapTime then
			//print("Item de mapa encontrado!: ", gun:GetClass())
			gun:SetNWBool("IBC_isMapEntity",true)
    		itemtable[k] = nil
		elseif gun and gun:IsValid() and gun:GetOwner() == NULL and !gun:GetNWBool("IBCChecked",false) && !gun:GetNWBool("IBC_isMapEntity",false) then
			local Entry = { Entity = gun, EntryTime = CurTime() }
			table.insert(DroppedItems, Entry)
            gun:SetNWBool("IBCChecked",true)
		end
	end
end

function IBC_DeleteEntity(enttable,type)
	local Max = GetConVar(type.."_Cleanup_MaxEnts"):GetInt()
	local RealAmount = 0 
	for k,v in pairs(enttable) do 
		if v && v.Entity:IsValid() then 
			if !v.Entity:GetNWBool("IBC_GO_FADE",false) then
				//print("RealAmount + 1")
				RealAmount = RealAmount + 1  // Contamos la cantidad de entidades que NO estan marcados ya para borrar
			end
		else
			//print("invalido encontrado, eliminando... (DeleteEntity 1)")
			enttable[k] = nil
		end
	end

	//print("RealAmount total: ", RealAmount)
	if RealAmount > Max then // si aun hay mas del maximo, eligimos la entidad mas vieja para eliminar
		//print("hay ents de mas, buscando mas viejo ")
		local MyTime = CurTime() + 1
		local MyEnt = nil
		for k,v in pairs(enttable) do
			if v && v.Entity:IsValid() then
				//print("Type: ", type)
				local cvar
				if type == "Item" then
					cvar = "Weapon_Cleanup_MinTime"
				elseif type == "Debris" then
					cvar = "Ragdoll_Cleanup_MinTime"
				else
					cvar = type.."_Cleanup_MinTime"
				end
				if !v.Entity:GetNWBool("IBC_GO_FADE",false) && 
					(v.EntryTime + GetConVar(cvar):GetFloat()) <= CurTime() then 
					//print("encontrado no marcado y tiempo vencido, verif. facing players... ", v.Entity:GetModel())
					if GetConVar("General_Cleanup_facing"):GetBool() || 
						(!GetConVar("General_Cleanup_facing"):GetBool() && !IBC_CheckPlayersView(v.Entity)) then
						//print("verificando si es el mas antiguo: ", v.Entity:GetModel())
						if MyTime > v.EntryTime then
							//print("encontrado mas viejo, marcando: ", v.Entity:GetModel())
							MyTime = v.EntryTime
							MyEnt = v.Entity
						end
					end
				end
			else
				//print("invalido encontrado, eliminando... (DeleteEntity 2)")
				enttable[k] = nil
			end
		end

		if MyEnt != nil then
			//print("mas viejo encontrado, seteando para fade: ", MyEnt:GetModel())
			if MyEnt:GetClass() == "prop_ragdoll_attached" then
				//print("es un prop_ragdoll_attached!, seteando owner nulo")
				MyEnt:SetOwner(nil)
			end
			MyEnt:SetNWBool("IBC_GO_FADE",true)
			if type == "Weapon" then
				FadindWeapons = true
			elseif type == "Ragdoll" then
				FadindRagdolls = true
			elseif type == "Debris" then
				FadindDebris = true
			elseif type == "Item" then
				FadindItems = true
			end
		end
	end
	return enttable
end

function IBC_FadeThink(enttable,type)
	local leftEntsFading = false
	local cvar
	for k,v in pairs(enttable) do
		if v and IsValid(v.Entity) then 
			if v.Entity:GetNWBool("IBC_GO_FADE",false) then	
				leftEntsFading = true
				if type == "Item" then
					cvar = "Weapon_Cleanup_FadeTime"
				elseif type == "Debris" then
					cvar = "Ragdoll_Cleanup_FadeTime"
				else
					cvar = type.."_Cleanup_FadeTime"
				end
				//print("haciendole el fade a: ", v.Entity:GetModel())
				if (type == "Weapon" || type == "Item") && v.Entity:GetOwner() != NULL then //(v.Entity:GetOwner() != NULL || v.Entity:GetName() != "") then -- Se elimino v.Entity:GetName() != "" para que se eliminaran armas de enemigos en mapas de HL2
					//print("Es arma o item, seteando transparencia: ", v.Entity:GetModel())
					v.Entity:SetColor( Color(255, 255, 255, 255) )
					v.Entity:SetRenderMode( RENDERMODE_TRANSCOLOR )
					enttable[k] = nil
				end
				if !v.Entity.EndTime then
					v.Entity.EndTime = CurTime() + GetConVar(cvar):GetFloat()
				end
				if !v.Entity:IsSolid() && type == "Ragdoll" then 
					v.Entity:SetNotSolid(true)
				end
				v.Entity:SetColor( Color(255, 255, 255, (255 * ((v.Entity.EndTime - CurTime())/GetConVar(cvar):GetFloat()))) )
				v.Entity:SetRenderMode( RENDERMODE_TRANSCOLOR )
				if v.Entity.EndTime <= CurTime() then
					//print("entidad eliminada: ", v.Entity:GetModel())
					v.Entity:Remove()
					enttable[k] = nil
				end
			end
		else
			//print("invalido encontrado, eliminando... (Fadethink)")
			enttable[k] = nil
		end
	end

	if type == "Weapon" then
		FadindWeapons = leftEntsFading
	elseif type == "Ragdoll" then
		FadindRagdolls = leftEntsFading
	elseif type == "Debris" then
		FadindDebris = leftEntsFading
	elseif type == "Item" then
		FadindItems = leftEntsFading
	end

	return enttable
end

function IBC_ConstructTableCorpses()
	local ragdolltable = {}
	for k,v in pairs(Corpses) do
		ragdolltable = table.Add(ragdolltable, ents.FindByClass(v))
	end
	local physbodys = {}

	for k,v in pairs(ents.FindByClass("prop_physics")) do
		local IsVJBaseCorpse = false
	   	if v:GetTable().OnDieFunctions then 
	   		IsVJBaseCorpse = (v:GetTable().OnDieFunctions["vj_".. v:EntIndex()] != nil) && GetConVar("General_Cleanup_VJBase"):GetBool()
		end
		if v.npcbody || IsVJBaseCorpse then
			table.insert(physbodys,v)
		end
	end
	ragdolltable = table.Add(ragdolltable, physbodys)

	for k,v in pairs(ragdolltable) do
		if IsValid(v) then
			if IsValid(v.entgib) || ((v:GetClass() == "npc_combine_camera" || v:GetClass() == "npc_turret_ceiling" || v:GetClass() == "npc_barnacle") && v:Health() > 0) then
				ragdolltable[k] = nil
			end
		else
			ragdolltable[k] = nil
		end
	end
	return ragdolltable
end

function IBC_ConstructTableDebris() 
	local debristable = {}
	for k,v in pairs(Debris) do
		debristable = table.Add(debristable, ents.FindByClass(v))
	end
	local physdebris = {}
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if v.npcdebris then
			table.insert(physdebris,v)
		end
	end
	debristable = table.Add(debristable, physdebris)

	return debristable
end

function IBC_RefreshTables()
	local ragdolltable = IBC_ConstructTableCorpses()
	ragdolltable = table.Add(ragdolltable, ents.FindByClass("npc_turret_floor"))
	local debristable = IBC_ConstructTableDebris()
	local Weapontable = {}
	for k,v in pairs(Weapons) do
		Weapontable = table.Add(Weapontable, ents.FindByClass(v))
	end
	local itemtable = {}
	for k,v in pairs(Items) do
		itemtable = table.Add(itemtable, ents.FindByClass(v))
	end

	// Desmarca todas las entidades del mapa para releerlas excepto las marcadas para hacer fade
	local temptables = {ragdolltable,debristable,Weapontable,itemtable}
	for j,tble in pairs(temptables) do
		for k,v in pairs(tble) do
			if IsValid(v) && !v:GetNWBool("IBC_GO_FADE",false) && !v:GetNWBool("IBC_isMapEntity",false) then 
				v:SetNWBool("IBCChecked",false)
			end
		end
	end

	// Limpia las tablas del mod excepto de las entidades marcadas para hacer fade
	local tables = {NPCRagdolls,NPCDebris,DroppedWeapons,DroppedItems}
	for j,tble in pairs(tables) do
		for k,v in pairs(tble) do
			if IsValid(v.Entity) then 
				if !v.Entity:GetNWBool("IBC_GO_FADE",false) then
					 tble[k] = nil
				else

				end
			else
				tble[k] = nil
			end
		end
	end
end

local function IBC_AddInvividualNPC(npc)
	local Entry = { Entity = npc, EntryTime = CurTime() }
	table.insert(NPCRagdolls, Entry)
	npc:SetNWBool("IBCChecked",true)
end

local function IBC_EntityTakeDamage(victim, dmginfo)
	if IsValid(victim) && dmginfo && !victim.IBCChecked && victim:GetClass() == "prop_vehicle_apc" && victim:Health() - dmginfo:GetDamage() <= 0 then
		//print("APC Muriendo")
		local pos = victim:GetPos()
		victim.IBCChecked = true
		timer.Simple(1.2, function()
			for k,v in pairs(ents.FindInSphere(pos,500)) do
				//print("entidad clase: ", v:GetClass(), v:GetNWBool("IBCChecked",false), math.floor(v:GetCreationTime()), math.floor(CurTime()), math.floor(v:GetCreationTime())-math.floor(CurTime()), v:GetModel())
				if IsValid(v) and v:GetClass() == "prop_physics" && !v:GetNWBool("IBCChecked",false) && math.floor(v:GetCreationTime()) - math.floor(CurTime()) >= -1 then
					//print("nuevo gib de APC encontrado, añadiendo...")
					local time
					if v:GetModel() == "models/combine_apc_destroyed_gib01.mdl" then
						time = CurTime() + 1
					else
						time = CurTime()
					end
					v.npcdebris = true
					local Entry = { Entity = v, EntryTime = time }
					table.insert(NPCDebris, Entry)
					v:SetNWBool("IBCChecked",true)
				end
			end
		end)
	end 
end


hook.Add("Think","IBC_Think",IBC_Main)
hook.Add("OnNPCKilled", "IBC_OnNPCKilledTurrets", function(npc, attacker, inflictor)
	if IsValid(npc) && GetConVar("Ragdoll_Cleanup_RemoveCombineTurrets"):GetBool() && npc:GetClass() == "npc_turret_floor" then
		IBC_AddInvividualNPC(npc)
	end
end)
hook.Add( "EntityTakeDamage", "IBC_TakeDamage", IBC_EntityTakeDamage )


local function IBC_SearchEntitySpawned(pos,ply)
	local Ents = ents.FindInSphere(pos, 32)
	for k,v in pairs(Ents) do
		if IsValid(v) &&  CurTime() - v:GetCreationTime() <= 0.2 then
			local found = false
			for j,i in pairs(Items) do
				local str = string.Trim(i,"*") 
				if string.StartWith(v:GetClass(),str) then
					found = true
					break
				end
			end
			if !found then
				for j,i in pairs(Weapons) do
					local str = string.Trim(i,"*") 
					if string.StartWith(v:GetClass(),str) then
						found = true
						break
					end
				end
			end
			if found then
				//print("Seteando creator: ", v)
				v:SetCreator(ply)
				break
			end
		end
	end
end
hook.Add("InitPostEntity", "IBC_Init", function()
	if GAMEMODE.IsSandboxDerived then
		hook.Add("PlayerSpawnSENT", "BC_PlayerSpawnSENT", function(ply, none)
			timer.Simple(0.09,function() 
				IBC_SearchEntitySpawned(ply:GetEyeTrace().HitPos,ply)
			end)
		end)
		hook.Add("PlayerSpawnSWEP", "BC_PlayerSpawnSWEP", function(ply, none)
			timer.Simple(0.09,function() 
				IBC_SearchEntitySpawned(ply:GetEyeTrace().HitPos,ply)
			end)
		end)
	end
end)

local function PrintEntityTable(ply, comm, v)
	local a = nil
	if !v[1] then
		v[1] = "npcs"
	end
	if v[1] == "weapons" then
		a = DroppedWeapons
	elseif v[1] == "npcs" then
		a = NPCRagdolls
	elseif v[1] == "debris" then
		a = NPCDebris
	elseif v[1] == "items" then
		a = DroppedItems
	end
	
	if a != nil then
		print(v[1]," Table: ", table.Count(a))
		for k,v in pairs(a) do
			print("Entity: ",v.Entity)
			if IsValid(v.Entity) then
				print("Entity Model:                    -",v.Entity:GetModel())
			end
			print("EntryTime: ",v.EntryTime)
			print("-----------------------------")
			print("")
		end
	end
end
concommand.Add("IBC_table", PrintEntityTable)