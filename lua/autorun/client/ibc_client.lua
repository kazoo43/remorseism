//====================================\\
//===Made by TRAVIESO=================\\
//==Immersive Battle Cleanup (client)=\\
//====================================\\
local nextclientthink = CurTime() + 10
local function IBC_Main_CL()
	if nextclientthink < CurTime() && ConVarExists("Ragdoll_Cleanup_RemoveSmall") && GetConVar("Ragdoll_Cleanup_RemoveSmall"):GetBool() then
		nextclientthink = CurTime() + 10
		local clientRagTable = ents.FindByClass("class C_ClientRagdoll")
		if table.Count(clientRagTable) > math.Round((GetConVar("Ragdoll_Cleanup_MaxEnts"):GetInt() / 2)) then
			for _, ent in pairs(clientRagTable) do
				if GetConVar("General_Cleanup_facing"):GetBool() || 
					(!GetConVar("General_Cleanup_facing"):GetBool() && !IBC_CheckPlayersView(ent)) then
					ent:Remove()
					nextclientthink = CurTime() + 0.5
					break
				end
			end
		end
	end
end
hook.Add("Think","IBC_Think_CL",IBC_Main_CL)