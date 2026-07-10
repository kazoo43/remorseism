function hg.GetCurrentArmor(ply)
	return ply:GetNetVar("Armor",{})
end

if CLIENT then
	local whitelist = {
		weapon_physgun = true,
		gmod_tool = true,
		gmod_camera = true,
		weapon_crowbar = true,
		weapon_pistol = true,
		weapon_crossbow = true
	}
	
	local models_female = {
		["models/player/group01/female_01.mdl"] = true,
		["models/player/group01/female_02.mdl"] = true,
		["models/player/group01/female_03.mdl"] = true,
		["models/player/group01/female_04.mdl"] = true,
		["models/player/group01/female_05.mdl"] = true,
		["models/player/group01/female_06.mdl"] = true,
		["models/player/group03/female_01.mdl"] = true,
		["models/player/group03/female_02.mdl"] = true,
		["models/player/group03/female_03.mdl"] = true,
		["models/player/group03/female_04.mdl"] = true,
		["models/player/group03/female_05.mdl"] = true,
		["models/player/group03/police_fem.mdl"] = true
	}
	
	local PixVis
	hook.Add("Initialize", "SetupPixVis", function() PixVis = util.GetPixelVisibleHandle() end)
	local islply

	local blmodels = {
		["models/monolithservers/kerry/swat_male_02.mdl"] = true,
		["models/monolithservers/kerry/swat_male_04.mdl"] = true,
		["models/monolithservers/kerry/swat_male_07.mdl"] = true,
		["models/monolithservers/kerry/swat_male_08.mdl"] = true,
		["models/monolithservers/kerry/swat_male_09.mdl"] = true,
		["models/dejtriyev/smo/ukr_soldier.mdl"] = true,
		["models/dejtriyev/smo/zuperzoldat.mdl"] = true,
		["models/pms/quantum_break/characters/operators/monarchoperator01playermodel.mdl"] = true,
	}

	local blVestmodels = {
		["models/player/group03m/male_01.mdl"] = true,
    	["models/player/group03m/male_02.mdl"] = true,
    	["models/player/group03m/male_03.mdl"] = true,
    	["models/player/group03m/male_04.mdl"] = true,
    	["models/player/group03m/male_05.mdl"] = true,
    	["models/player/group03m/male_06.mdl"] = true,
    	["models/player/group03m/male_07.mdl"] = true,
    	["models/player/group03m/male_08.mdl"] = true,
    	["models/player/group03m/male_09.mdl"] = true,
    	["models/player/group03m/female_01.mdl"] = true,
    	["models/player/group03m/female_02.mdl"] = true,
    	["models/player/group03m/female_03.mdl"] = true,
    	["models/player/group03m/female_04.mdl"] = true,
    	["models/player/group03m/female_05.mdl"] = true,
    	["models/player/group03m/female_06.mdl"] = true,
		["models/player/group03/male_01.mdl"] = true,
    	["models/player/group03/male_02.mdl"] = true,
    	["models/player/group03/male_03.mdl"] = true,
    	["models/player/group03/male_04.mdl"] = true,
    	["models/player/group03/male_05.mdl"] = true,
    	["models/player/group03/male_06.mdl"] = true,
    	["models/player/group03/male_07.mdl"] = true,
    	["models/player/group03/male_08.mdl"] = true,
    	["models/player/group03/male_09.mdl"] = true,
    	["models/player/group03/female_01.mdl"] = true,
    	["models/player/group03/female_02.mdl"] = true,
    	["models/player/group03/female_03.mdl"] = true,
    	["models/player/group03/female_04.mdl"] = true,
    	["models/player/group03/female_05.mdl"] = true,
    	["models/player/group03/female_06.mdl"] = true,

        ["models/1000shells/hl2rp/rebels/rebels_standart/van.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/ted.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/joe.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/eric.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/art.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/sandro.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/mike.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/vance.mdl"] = true,
        ["models/1000shells/hl2rp/rebels/rebels_standart/erdim.mdl"] = true,

		["models/romka/player/combine_super_soldier.mdl"] = true,
		["models/romka/player/combine_soldier.mdl"] = true
	}

	function RenderArmors(ply, armors, ent)

		if not IsValid(ply) or not armors then return end
	
		--if armors and #armors < 1 then return end
		
		local wep = ply:IsPlayer() and ply:GetActiveWeapon()
		
		islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer())) and GetViewEntity() == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer()))
	
		if islply and IsValid(wep) and whitelist[wep:GetClass()] then
			if not ent.modelArmor then return end
			for k,v in ipairs(ent.modelArmor) do
				if IsValid(v) then
					v:Remove()
					v = nil
				end
			end
			return
		end
		
	
		if not ent.shouldTransmit or ent.NotSeen then
			if not ent.modelArmor then return end
			for k,v in ipairs(ent.modelArmor) do
				if IsValid(v) then
					v:Remove()
					v = nil
				end
			end
			return
		end
		
		DrawArmors(ply,armors,ent)

	end	

	function DrawArmors(ply, armors, ent)
		if not IsValid(ply) or not armors then return end
		if blmodels[ply:GetModel()] then return end
		local lply = LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect")
		islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == lply and (LocalPlayer():Alive() and (GetViewEntity() == lply) or (viewmode == 1))
		
		for placement, armor in pairs(armors) do
			if placement == "torso" and blVestmodels[ply:GetModel()] then continue end
			local armorGroup = hg.armor[placement]
			if not armorGroup or not armor then continue end
			local armorData = armorGroup[armor]
			if not armorData then continue end

			if armorData["model"] == "" then continue end

			ply.modelArmor = ply.modelArmor or {}
			local fem = ThatPlyIsFemale(ent)

			if not IsValid(ply.modelArmor[armor]) then
				ply.modelArmor[armor] = ClientsideModel(armorData["model"])
				local model = ply.modelArmor[armor]
				model:SetNoDraw(true)
				model:SetModelScale( (fem and armorData.femscale) or armorData.scale or 1 )
				local fallback_mat = istable(armorData.material) and armorData.material[1] or armorData.material
				if model.materialset != ply:GetNWString("ArmorMaterials" .. armor, fallback_mat) then
					model.materialset = ply:GetNWString("ArmorMaterials" .. armor, fallback_mat)
					model:SetSubMaterial(0, ply:GetNWString("ArmorMaterials" .. armor, fallback_mat))
				end

				if ent:GetNWInt("ArmorSkins" .. armor, 0) and not model.skinset then
					model.skinset = true
					model:SetSkin(ply:GetNWInt("ArmorSkins" .. armor, 0))
				end
				if not armorData.nobonemerge then
					model:AddEffects(EF_BONEMERGE)
				end
				
				ply:CallOnRemove("removearmors"..placement,function()
					if ply.modelArmor and IsValid(model) then
						model:Remove()
						model = nil
					end
				end)
				ent:CallOnRemove("removearmors"..placement,function()
					if ent.modelArmor and IsValid(model) then
						model:Remove()
						model = nil
					end
				end)

				ply.modelArmorBroken = ply.modelArmorBroken or {}
				if not IsValid(ply.modelArmorBroken[armor]) then
					local omodel = ClientsideModel(armorData["model"])
					omodel:SetNoDraw(true)
					omodel:SetModelScale((fem and armorData.femscale or armorData.scale or 1) * 1.01)
					omodel:SetSubMaterial(0, "armor/brokenarmor")
					omodel:SetRenderMode(RENDERMODE_TRANSALPHA)
					omodel:SetColor(Color(255, 255, 255, 0))
					if not armorData.nobonemerge then
						omodel:AddEffects(EF_BONEMERGE)
					end
					ply.modelArmorBroken[armor] = omodel
				end
			end
			
			local ent = hg.GetCurrentCharacter(ply)
	
			if not IsValid(ent) then return end
	
			local model = ply.modelArmor[armor]
			
			if not IsValid(model) then return end
			
			if ent.NotSeen or not ent.shouldTransmit then
				return
			end

			local mdl = string.Split(string.sub(ent:GetModel(),1,-5),"/")[#string.Split(string.sub(ent:GetModel(),1,-5),"/")]
			if mdl and model:GetFlexIDByName(mdl) then
				model:SetFlexWeight(model:GetFlexIDByName(mdl),1)
			end
			
			local matrix = ent:GetBoneMatrix(ent:LookupBone(armorData["bone"]))
			if not matrix then
				return
			end
			
			local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()
			bonePos:Add(boneAng:Forward() * (fem and armorData.femPos[1] or 0) + boneAng:Up() * (fem and armorData.femPos[2] or 0) + boneAng:Right() * (fem and armorData.femPos[3] or 0))
			local pos, ang = LocalToWorld(armorData[3], armorData[4], bonePos, boneAng)
			model:SetRenderOrigin(pos)
			model:SetRenderAngles(ang)

			model:SetParent(ent,ent:LookupBone(armorData["bone"]))
			
			--model:SetupBones()
			
			if not (islply and armorData.norender) then
				model:DrawModel()
			end

			local omodel = ply.modelArmorBroken and ply.modelArmorBroken[armor]
			if IsValid(omodel) then
				local wear = ply:GetNWFloat("ArmorWear" .. armor, 0)
				if wear > 0.01 and not (islply and armorData.norender) then
					omodel:SetRenderOrigin(pos)
					omodel:SetRenderAngles(ang)
					omodel:SetParent(ent, ent:LookupBone(armorData["bone"]))
					omodel:SetColor(Color(255, 255, 255, math.Clamp(wear, 0, 1) * 255))
					omodel:DrawModel()
				end
			end
		end
	end
	
	hook.Add("OnNetVarSet","ArmorVarSet",function(index, key, var)
		if key == "Armor" then
			timer.Simple(.1,function()
				local ent = Entity(index)

				local armors = ent.armors or {}

				for k,v in pairs(ent.modelArmor or {}) do
					if IsValid(ent.modelArmor[k]) then
						ent.modelArmor[k]:Remove()
					end
					ent.modelArmor[k] = nil
				end

				if ent.modelArmorBroken then
					for k,v in pairs(ent.modelArmorBroken) do
						if IsValid(ent.modelArmorBroken[k]) then
							ent.modelArmorBroken[k]:Remove()
						end
						ent.modelArmorBroken[k] = nil
					end
				end

				ent.armors = var
			end)
		end
	end)

	local droppedBrokenOverlays = {}

	local function EnsureDroppedBrokenOverlay(ent)
		if not IsValid(ent) then return end
		local idx = ent:EntIndex()
		if droppedBrokenOverlays[idx] then return end
		local mdl = ent:GetModel()
		if not mdl or mdl == "" or mdl == "models/error.mdl" then return end
		local omodel = ClientsideModel(mdl)
		if not IsValid(omodel) then return end
		omodel:SetNoDraw(true)
		omodel:SetModelScale(1.01)
		omodel:SetSubMaterial(0, "armor/brokenarmor")
		omodel:SetRenderMode(RENDERMODE_TRANSALPHA)
		omodel:SetColor(Color(255, 255, 255, 230))
		droppedBrokenOverlays[idx] = omodel
	end

	hook.Add("OnNetVarSet", "BrokenDroppedArmorOverlay", function(index, key, var)
		if key ~= "ArmorBroken" or not var then return end
		EnsureDroppedBrokenOverlay(Entity(index))
	end)

	hook.Add("OnEntityCreated", "BrokenDroppedArmorCheck", function(ent)
		if not IsValid(ent) then return end
		local cls = ent:GetClass()
		if not (cls and (cls:find("ent_armor") or cls == "armor_base")) then return end
		timer.Simple(0.1, function()
			if IsValid(ent) and ent:GetNWBool("ArmorBroken", false) then
				EnsureDroppedBrokenOverlay(ent)
			end
		end)
	end)

	hook.Add("PostDrawTranslucentRenderables", "DroppedBrokenOverlayDraw", function()
		for idx, omodel in pairs(droppedBrokenOverlays) do
			local parent = Entity(idx)
			if not IsValid(parent) then
				omodel:Remove()
				droppedBrokenOverlays[idx] = nil
			else
				omodel:SetRenderOrigin(parent:GetPos())
				omodel:SetRenderAngles(parent:GetAngles())
				omodel:DrawModel()
			end
		end
	end)
	
	local mat = Material("sprites/mat_jack_hmcd_helmover")
	loopingsound = nil

	local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0

	local function BlurScreen(density,alpha)
		local layers, density, alpha = 1, density or .4, alpha or 255
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(blurMat2)
		local FrameRate, Num, Dark = 1 / FrameTime(), 3, 150

		for i = 1, Num do
			blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)
			blurMat2:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)
	end

	local BlurAfterNVG = 5
	local CustomSndPlayed = false
	local NVGEnabled = false
	local cd = 0

	hook.Add( "Think", "NVGEnabling", function( )
		--print(lply:GetNWBool("NVG_Enabled", false))
		if lply:GetNWBool("NVG_Enabled", false) != NVGEnabled then
			--if cd > CurTime() then return end
			--cd = CurTime() + 1
			local armors = LocalPlayer().armors
			if armors and armors["face"] and hg.armor.face[armors["face"]].NVGRender then
				BlurAfterNVG = 5
				NVGEnabled = lply:GetNWBool("NVG_Enabled", false)
			end
		end
	end )

	local white = Material("color/white")
	local brainhemorrhage = Material( "overlays/brainhemorrhageoverlay.png" )

	local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like first-person camera view", 0, 1)
	hook.Add("Post Pre Post Processing", "renderHelmetThingy", function()
		cam.IgnoreZ(true)
		//cam.Start2D()
		local armors = lply.armors

		if lply.soundhuy and not (armors["face"] and hg.armor.face[armors["face"]].loopsound) then
			lply:StopSound(lply.soundhuy)
			lply.soundhuy = nil
		end

		if GetViewEntity() != lply then
			return
		end
	
		lply.NVGEnabled = NVGEnabled

		if armors and armors["face"] then

			if hg.armor.face[armors["face"]].NVGRender and NVGEnabled then
				hg.armor.face[armors["face"]].NVGRender()

				if BlurAfterNVG > 0.01 then
					BlurScreen(BlurAfterNVG,BlurAfterNVG*125)
					local color = color_black
					color.a = BlurAfterNVG*75
					draw.RoundedBox(0,-1,-1,ScrW()+2, ScrH()+2,color)
					BlurAfterNVG = Lerp(0.5*FrameTime(),BlurAfterNVG,0)
				end
			end
			if hg.armor.face[armors["face"]].CustomSnd and not CustomSndPlayed and NVGEnabled then
				surface.PlaySound("snds_jack_gmod/equip2.wav")
				timer.Simple(0.6,function()
					surface.PlaySound(hg.armor.face[armors["face"]].CustomSnd)
					ViewPunch2(Angle(1,1,-2))
				end)
				CustomSndPlayed = true
			end

			if hg.armor.face[armors["face"]].viewmaterial and !hg_gopro:GetBool() then
				local custommat = hg.armor.face[armors["face"]].viewmaterial

				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(custommat or mat)
				surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
				
				if lply:GetNetVar("zableval_masku", false) and lply.organism and not lply.organism.otrub then
					draw.NoTexture()
					surface.SetDrawColor(100,0,0,240)
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(brainhemorrhage)
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				end
			end

			if hg.armor.face[armors["face"]].loopsound and (lply.organism and lply.organism.pulse <= 85) then
				if not lply.soundhuy then
					//lply.soundhuy = lply.organism and lply.organism.pulse > 80 and "scp cb/breath1gas.wav" or hg.armor.face[armors["face"]].loopsound
					lply.soundhuy = hg.armor.face[armors["face"]].loopsound
					lply:StartLoopingSound(lply.soundhuy)
				end
			end
		end
		
		//local shouldplaysnd = lply.organism and lply.organism.pulse > 80 and "scp cb/breath1gas.wav" or hg.armor.face[armors["face"]].loopsound
		if lply.soundhuy and ((not (armors["face"] and hg.armor.face[armors["face"]].loopsound)) or (lply.organism and lply.organism.pulse > 85)) then// or shouldplaysnd != lply.soundhuy) then
			lply:StopSound(lply.soundhuy)
			lply.soundhuy = nil
		end

		if armors and armors["head"] then
			local custommat = hg.armor.head[armors["head"]].viewmaterial
			
			if custommat != false then
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(custommat or mat)
				surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
			end
			
			local customviewfunc = armors["head"] and hg.armor.head[armors["head"]].customviewrender
			if customviewfunc then
				customviewfunc(lply)
			end
		end

		if IsValid(lply.EZNVGlamp) and armors and ((not armors["face"]) or (armors["face"] and !NVGEnabled)) then
			CustomSndPlayed = false
			lply.EZNVGlamp:Remove()
			surface.PlaySound("snds_jack_gmod/equip1.wav")
			BlurAfterNVG = 5
			NVGEnabled = false
			ViewPunch2(Angle(-2,-1,2))
			hook.Add("RenderScreenspaceEffects","renderblur",function()
				BlurScreen(BlurAfterNVG,BlurAfterNVG*55)
				local color = color_black
				color.a = BlurAfterNVG*55
				draw.RoundedBox(0,-1,-1,ScrW()+2, ScrH()+2,color)
				BlurAfterNVG = Lerp(0.5*FrameTime(),BlurAfterNVG,0)
				if BlurAfterNVG <= 0.01 or IsValid(lply.EZNVGlamp) then
					hook.Remove("RenderScreenspaceEffects","renderblur")
					BlurAfterNVG = 5
				end
			end)
		end
		cam.IgnoreZ(false)
		//cam.End2D()
	end)

	hook.Add("Player_Death", "stopgasmasksound", function(ply)
		if ply == lply and lply.soundhuy then
			lply:StopSound(lply.soundhuy)
			lply.soundhuy = nil
		end
	end)
	
	local function equipmentMenu()
		RunConsoleCommand("hg_get_equipment")

		return 0
	end
	
	hook.Add("radialOptions", "equipment", function()
		local armors = LocalPlayer().armors or {}
		local inventory = LocalPlayer():GetNetVar("Inventory",{})
		inventory["Weapons"] = inventory["Weapons"] or {}
		local organism = LocalPlayer().organism or {}
	
		local tbl = table.Copy(armors)
		if inventory["Weapons"]["hg_flashlight"] then
			tbl["hg_flashlight"] = inventory["Weapons"]["hg_flashlight"]
		end

		if inventory["Weapons"]["hg_sling"] then
			tbl["hg_sling"] = inventory["Weapons"]["hg_sling"]
		end

		if inventory["Weapons"]["hg_brassknuckles"] then
			tbl["hg_brassknuckles"] = inventory["Weapons"]["hg_brassknuckles"]
		end
	
		if not organism.otrub and table.Count(tbl) > 0 then
			hg.radialOptions = hg.radialOptions or {}
			local newEntry = {equipmentMenu, "Drop Equipment"}
			hg.radialOptions[#hg.radialOptions + 1] = newEntry
		end
	end)
	
	
	concommand.Add("hg_add_equipment", function(ply, cmd, args)
		local att = args[1]
		net.Start("hg_add_equipment")
		net.WriteString(att)
		net.SendToServer()
	end)
	
	concommand.Add("hg_drop_equipment", function(ply, cmd, args)
		local att = args[1]
		net.Start("hg_drop_equipment")
		net.WriteString(att)
		net.SendToServer()
	end)

	local CreateMenu
	local function dropArmor(arm)
		RunConsoleCommand("hg_drop_equipment", arm)
	end

	local plyEquipment = plyEquipment or {}
	local armors = plyEquipment or {}
	local drop = true
	local gray = Color(200, 200, 200)
	local blue = Color(200, 200, 255)
	local red = Color(75,25,25)
	local redselected = Color(150,0,0)
	local whitey = Color(255, 255, 255)
	local menuPanel
	local chosen2

	local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
	BlurBackground = BlurBackground or hg.DrawBlur

	local function refreshtbl()
		local tblcpy = {}

		local tbl = lply:GetNetVar("Armor", {})
		local inventory = lply:GetNetVar("Inventory", {})

		inventory["Weapons"] = inventory["Weapons"] or {}

		for i, att in pairs(tbl) do
			if !att then continue end
			table.insert(tblcpy, att)
		end

		if inventory["Weapons"]["hg_flashlight"] then
			tblcpy["hg_flashlight"] = inventory["Weapons"]["hg_flashlight"]
		end

		if inventory["Weapons"]["hg_sling"] then
			tblcpy["hg_sling"] = inventory["Weapons"]["hg_sling"]
		end

		if inventory["Weapons"]["hg_brassknuckles"] then
			tblcpy["hg_brassknuckles"] = inventory["Weapons"]["hg_brassknuckles"]
		end

		return tblcpy
	end

	hook.Add("OnNetVarSet", "equipmentPanelRefresh", function(index, key, var)
		if IsValid(hg.armorMenuPanel) and (key == "Armor" or key == "Inventory") then
			if hg.armorMenuPanel.RefreshTbl and Entity(index) == lply then
				hg.armorMenuPanel:RefreshTbl()
			end
		end
	end)

	local mat = Material("homigrad/vgui/gradient_left.png")
	local equipmentMenuGradient = Material("vgui/gradient-d")
	local equipmentMenuOutline = Color(255, 255, 255, 255)
	local equipmentMenuFill = Color(0, 0, 0, 245)
	local equipmentMenuGradientColor = Color(40, 40, 40, 55)
	local equipmentMenuButtonIdle = Color(20, 20, 20, 235)
	local equipmentMenuButtonHover = Color(34, 34, 34, 235)

	local function PaintEquipmentFrame(self, w, h)
		hg.DrawBlur(self, 2)
		surface.SetDrawColor(equipmentMenuFill)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(equipmentMenuGradientColor)
		surface.SetMaterial(equipmentMenuGradient)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(equipmentMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintEquipmentButton(self, w, h)
		surface.SetDrawColor(self:IsHovered() and equipmentMenuButtonHover or equipmentMenuButtonIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(equipmentMenuGradientColor)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(equipmentMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintEquipmentClose(self, w, h)
		surface.SetDrawColor(self:IsHovered() and equipmentMenuButtonHover or equipmentMenuButtonIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(equipmentMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		draw.SimpleText(self:GetText(), "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local function StyleEquipmentScroll(scroll)
		scroll.Paint = PaintEquipmentFrame

		local sbar = scroll:GetVBar()
		sbar:SetHideButtons(true)

		function sbar:Paint(w, h)
			surface.SetDrawColor(18, 18, 18, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(equipmentMenuOutline)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		function sbar.btnGrip:Paint(w, h)
			self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.35, self:IsHovered() and 0.65 or 0.35)
			local col = 255 * self.lerpcolor
			surface.SetDrawColor(col, col, col, 255)
			surface.DrawRect(0, 0, w, h)
		end
	end

	CreateMenu = function()
		if IsValid(hg.armorMenuPanel) then
			hg.armorMenuPanel:Remove()
			hg.armorMenuPanel = nil
		end
	
		local tblcpy = refreshtbl()

		local frame = vgui.Create( "ZFrame" )
		hg.armorMenuPanel = frame
		frame:SetTitle("")
		frame:SetSize( math.min(ScrW() * 0.38, 560), math.min(ScrH() * 0.58, 520) )
		frame:SetPos( ScrW() * 0.5 - frame:GetWide() * 0.5,ScrH() + 500 )
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(false)
		frame:SetColorBG(equipmentMenuFill)
		frame:SetColorBR(equipmentMenuOutline)
		frame.Paint = PaintEquipmentFrame
		if IsValid(frame.btnClose) then
			frame.btnClose:SetVisible(false)
			frame.btnClose:SetMouseInputEnabled(false)
		end

		local close = frame:Add("DButton")
		close:SetPos(frame:GetWide() - 38, 10)
		close:SetSize(28, 28)
		close:SetText("X")
		close.Paint = PaintEquipmentClose
		close.DoClick = function()
			frame:Close()
		end

		local title = vgui.Create("DLabel", frame)
		title:SetPos(14, 12)
		title:SetTextColor(color_white)
		title:SetText("equipment")
		title:SetFont("ZCity_Menu_Settings_Small")
		title:SizeToContents()

		frame:SetAlpha(0)
	
		frame:MoveTo(frame:GetX(), ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function() end)
		frame:AlphaTo( 255, 0.2, 0.1, nil )

		function frame:First()
		end

		local lbl = vgui.Create("DLabel", frame)
		lbl:SetText( "" )
		lbl:SetFont("ZCity_Tiny")
		lbl:SetSize(0, ScreenScaleH(18))
		lbl:Dock(BOTTOM)
		lbl:DockMargin(10,0,10,10)

		lbl.Paint = function(self, w, h)
			draw.SimpleText("LMB - Drop equipment", "ZCity_Tiny", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local scroll = vgui.Create("DScrollPanel",frame)
		scroll:Dock(FILL)
		scroll:DockMargin(10, 44, 10, 8)
		frame.scroll = scroll
		StyleEquipmentScroll(scroll)

		function frame:RefreshTbl()
			tblcpy = refreshtbl()

			if IsValid(scroll) then
				scroll:Remove()
			end

			scroll = vgui.Create("DScrollPanel", frame)
			scroll:Dock(FILL)
			scroll:DockMargin(10, 44, 10, 8)
			frame.scroll = scroll
			StyleEquipmentScroll(scroll)
			
			for k, v in pairs(tblcpy) do
				if !hg.armorNames[v] and isnumber(k) then continue end
				//if hg.armor[v][k].nodrop then continue end
				local but = vgui.Create("DButton")
				local prefix = string.find(k, "_")
				if prefix then
					k = string.sub(k, prefix + 1)
				end

				but:SetText( hg.armorNames[v] or string.NiceName(k) )
				but:SetFont("ZCity_Tiny")
				but:Dock( TOP )
				but:DockMargin( 6, 6, 6, 0 )
				but:SetSize(0, ScreenScaleH(24))

				but.Paint = function(self, w, h)
					PaintEquipmentButton(self, w, h)
				end
	
				local img = vgui.Create("DImage", but)
				img:SetSize(ScreenScaleH(22), ScreenScaleH(22))
				img:Dock(LEFT)
				img:DockMargin( 8, 1, 0, 1 )
				if hg.armorIcons[v] then img:SetImage( hg.armorIcons[v] ) end
	
				but.DoClick = function()
					dropArmor(isnumber(k) and v or k)
				end
	
				scroll:AddItem(but)
			end
		end

		frame:RefreshTbl()
	end

	concommand.Add("hg_get_equipment", function(ply, cmd, args)
		if ply == LocalPlayer() then
			CreateMenu()
		end
	end)

	hook.Add("radialOptions", "9NVG", function()
		local ply = LocalPlayer()
		local organism = ply.organism or {}
		local armors = ply.armors
		if !armors or !armors["face"] or !hg.armor.face[armors["face"]].NVGRender then return end
		if ply:Alive() and not organism.otrub then
			local tbl = {function(mouseClick)
				RunConsoleCommand("hg_enable_nvg")
			end, ply:GetNWBool("NVG_Enabled", false) and "Disable NVG" or "Enable NVG"}
			hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
	end)
end

if SERVER then
	concommand.Add("hg_enable_nvg", function( ply, cmd, args )
		if ply.NVG_CD and ply.NVG_CD > CurTime() then return end
		local armors = ply.armors
		if !armors or !armors["face"] or !hg.armor.face[armors["face"]].NVGRender then return end

		ply.NVG_CD = CurTime() + 1
		hg.RunZManipAnim( ply, "visordown", ply:GetNWBool("NVG_Enabled", false), ply:GetNWBool("NVG_Enabled", false) and 1 or 1.5 )
		timer.Simple(0.5,function()
			if not IsValid(ply) then return end
			ply:SetNWBool("NVG_Enabled", !ply:GetNWBool("NVG_Enabled", false))
		end)
	end)

	hook.Add("PlayerDeath","NVG_DisableAfterDeath",function(ply)
		if ply:GetNWBool("NVG_Enabled", false) then
			ply:SetNWBool("NVG_Enabled", false)
		end
	end)
end
