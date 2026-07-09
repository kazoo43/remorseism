hg.armor = {}
local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like first-person camera view", 0, 1)

local vecAdjust2 = Vector(5, -6.3, -5)
local function DrawFirstPersonHelmet(ply, strModel, vecAdjust, fFov, setMat)
	if ply:GetNetVar("headcrab") then return end
	if not ply:Alive() then return end
	if ply.organism and ply.organism.otrub then return end

	if not IsValid(ply.FirstPersonHelmetModel) then
		ply.FirstPersonHelmetModel = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel:SetNoDraw(true)
		return
	end

	if not IsValid(ply.FirstPersonHelmetModel2) then
		ply.FirstPersonHelmetModel2 = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel2:SetNoDraw(true)
		ply.FirstPersonHelmetModel2:SetModelScale(1.05)
		return
	end

	local mdl = ply.FirstPersonHelmetModel
	local mdl2 = ply.FirstPersonHelmetModel2

	if mdl:GetModel() != strModel then
		mdl:SetModel(strModel)
	end

	if mdl2:GetModel() != strModel then
		mdl2:SetModel(strModel)
	end
	
	if setMat and !mdl.matseted1 then
		mdl:SetSubMaterial(0,setMat)
		mdl.matseted = false
		mdl.matseted1 = true
		--print('huy')
	elseif !setMat and !mdl.matseted then
		--print("huy")
		mdl:SetSubMaterial(0,nil)
		mdl.matseted = true
		mdl.matseted1 = false
	end

	local gp = hg_gopro:GetBool()

	local view = render.GetViewSetup()
	cam.Start3D(view.origin,view.angles,view.fov + fFov,nil,nil,nil,nil,1,10)
		--cam.IgnoreZ(true)
		local viewpunching = GetViewPunchAngles() / 2
		local ang = view.angles + viewpunching
		mdl:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
		mdl:SetRenderAngles(ang)
		mdl2:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
		mdl2:SetRenderAngles(ang)
		mdl:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
		render.SetColorModulation(1,1,1)
			render.SetStencilWriteMask( 0xFF )
			render.SetStencilTestMask( 0xFF )
			render.SetStencilReferenceValue( 0 )
			render.SetStencilCompareFunction( STENCIL_ALWAYS )
			render.SetStencilPassOperation( STENCIL_KEEP )
			render.SetStencilFailOperation( STENCIL_KEEP )
			render.SetStencilZFailOperation( STENCIL_KEEP )
			render.ClearStencil()

			-- Enable stencils
			render.SetStencilEnable( true )
			-- Set everything up everything draws to the stencil buffer instead of the screen
			render.SetStencilReferenceValue( 1 )
			render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
			render.SetStencilPassOperation( STENCIL_REPLACE )
			render.SetBlend(0)
				mdl2:DrawModel()
			render.SetBlend(1)
			render.SetStencilCompareFunction( STENCIL_EQUAL )
			mdl:DrawModel()
			DrawBokehDOF(8,0.9,15)
			-- Let everything render normally again
			render.SetStencilEnable( false )
		render.SetColorModulation(1,1,1)
		--cam.IgnoreZ(false)
	cam.End3D()
end

hg.armor.torso = {
	["vest1"] = {
		"torso",
		"models/combataegis/body/ballisticvest_d.mdl",
		Vector(19, 3, 0),
		Angle(0, 90, 90),
		protection = 14.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/combataegis/body/ballisticvest.mdl",
		femPos = Vector(-4, 0, 1),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 10,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest2"] = {
		"torso",
		"models/eu_homicide/armor_prop.mdl",
		Vector(-1, 2, 0),
		Angle(0, 90, 90),
		protection = 6.7,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eu_homicide/armor_on.mdl",
		femPos = Vector(-2.4, 0, 1.1),
		femscale = 0.94,
		effect = "Impact",
		surfaceprop = 77,
		mass = 3,
		ScrappersSlot = "Armor",
	},
	["vest3"] = {
		"torso",
		"models/jworld_equipment/kevlar.mdl",
		Vector(-9, 3.2, 0),
		Angle(0, 90, 90),
		protection = 9.8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/lightvest/lightvest.mdl",
		material = {"models/lightvest/accs_diff_000_b_uni",
		"models/lightvest/accs_diff_000_c_uni", "models/lightvest/accs_diff_000_c_uni",
		"models/lightvest/accs_diff_000_d_uni", "sal/acc/armor01_4", "sal/acc/armor01_5"},
		femPos = Vector(2.5, 0, 1),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 77,
		mass = 5,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest4"] = {
		"torso",
		"models/jworld_equipment/kevlar.mdl",
		Vector(-9, 3.2, 0),
		Angle(0, 90, 90),
		protection = 13.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/lightvest/lightvest.mdl",
		material = {"models/lightvest/accs_diff_000_a_uni",
		"models/lightvest/accs_diff_000_h_uni", "models/lightvest/accs_diff_000_f_uni",
		"models/lightvest/accs_diff_000_e_uni", "sal/acc/armor01_3"},
		femPos = Vector(2.5, 0, 1),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest5"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b13_flora.mdl",
		Vector(0, 2.7, 0),
		Angle(0, 90, 90),
		protection = 13,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b13_flora.mdl",
		femPos = Vector(-1, 0, 1.2),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
	},--models/eft_props/gear/armor/ar_paca.mdl
	["vest6"] = {
		"torso",
		"models/eft_props/gear/armor/ar_paca.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 9.9,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_paca.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		Spawnable = false,
	},
	["vest7"] = {
		"torso",
		"models/eft_props/gear/armor/ar_untar.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 10.2,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_untar.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
	},
	["vest8"] = {
		"torso",
		"models/monolithservers2/kerry/sswat_armor.mdl",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 12.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/monolithservers2/kerry/sswat_armor.mdl",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest9"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_arscpc.mdl",
		Vector(-0.6, 3, 0),
		Angle(0, 92, 90),
		protection = 15.5, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_arscpc.mdl",
		femPos = Vector(0, 0, 1.2),
		scale = 0.93,
		femscale = 0.77,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest10"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_mmac.mdl",
		Vector(-1, 2.9, 0),
		Angle(0, 92, 90),
		protection = 15.5, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_mmac.mdl",
		femPos = Vector(-0.7, 0, 1.3),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest11"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_osprey_defence.mdl",
		Vector(-1.0, 2.7, 0),
		Angle(0, 92, 90),
		protection = 18.5, // бр 5
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_osprey_defence.mdl",
		femPos = Vector(-0.7, 0, 1.2),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest12"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_shellback_tactical_banshee.mdl",
		Vector(-1.5, 2.8, 0),
		Angle(0, 92, 90),
		protection = 15.5, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_shellback_tactical_banshee.mdl",
		femPos = Vector(0, 0, 0.9),
		scale = 0.96,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest13"] = {
		"torso",
		"models/eft_props/gear/armor/ar_thor_intcar.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 20.5, // 6 бр
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_thor_intcar.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest14"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_bae_rbav_af.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 15.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_bae_rbav_af.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.96,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest15"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_ars_arma_18.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 15.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_ars_arma_18.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest16"] = {
		"torso",
		"models/eft_props/gear/armor/ar_korundvm.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 18.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_korundvm.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest17"] = {
		"torso",
		"models/eft_props/gear/armor/ar_redut_m.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 18.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_redut_m.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest18"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_precision_bigpipe.mdl",
		Vector(-0.1, 3, 0),
		Angle(0, 92, 90),
		protection = 18.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_precision_bigpipe.mdl",
		femPos = Vector(-0.4, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest19"] = {
		"torso",
		"models/eft_props/gear/armor/ar_iotv.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 20.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_iotv.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest20"] = {
		"torso",
		"models/parts hl2/medic_kevlar.mdl",
		Vector(-4.75, 3.2, -0.65),
		Angle(0, 90, 90),
		protection = 13.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/parts hl2/medic_kevlar.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/parts hl2/medic_kevlar.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest21"] = {
		"torso",
		"models/parts hl2/hl2_kevlar.mdl",
		Vector(-4.65, 3.7, -1.15),
		Angle(0, 90, 90),
		protection = 13.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/parts hl2/hl2_kevlar.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/parts hl2/hl2_kevlar.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.89,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest22"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_chestplate.mdl",
		Vector(0.2, 3.2, 0),
		Angle(0, 90, 90),
		protection = 20.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_chestplate.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/vest/vt_chestplate.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.1, 0, 1.2),
		scale = 0.95,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest23"] = {
		"torso",
		"models/combataegis/body/ballisticvest_d.mdl",
		Vector(19, 3, 0),
		Angle(0, 90, 90),
		protection = 14.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/combataegis/body/ballisticvest.mdl",
		femPos = Vector(-4, 0, 1),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 10,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest25"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_stab_vest.mdl",
		Vector(1.5, 3.2, 0),
		Angle(0, 90, 90),
		protection = 5.8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_stab_vest.mdl",
		femPos = Vector(41.5, 0, 1.5),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 77,
		mass = 5,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest26"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl",
		Vector(2.35, 3.2, 0),
		Angle(0, 90, 90),
		protection = 13.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl",
		skins = {"1","2","3","4","5"},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest28"] = {
		"torso",
		"models/eft_props/gear/armor/ar_paca.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 9.9,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_paca.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		Spawnable = false,
	},
	["vest30"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_tactical_vest_black.mdl",
		Vector(-0.5, 2.8, 0),
		Angle(0, 92, 90),
		protection = 12.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_tactical_vest_black.mdl",
		femPos = Vector(-1, 0, 0.8),
		scale = 0.95,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["gordon_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 16.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["cmb_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["ego_equalizer"] = {
		"torso",
		"models/monolithservers2/kerry/sswat_armor.mdl",
		Vector(-8, 2.5, 0),
		Angle(0, 92, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/monolithservers2/kerry/sswat_armor.mdl",
		-- material = "models/shiny",
		material = "models/lightvest/accs_diff_000_d_uni", -- "models/props_c17/paper01"
		femPos = Vector(0, 0, 0),
		scale = 0.95,
		femscale = 0.95,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		AdminOnly = true
	},
}
local vectors = {
	[1] = Vector(-2,0,-1.5),
	[2] = Vector(-4,0,0.2),
	[3] = Vector(-5,0,0),
	[4] = Vector(-2,0,0),
	[5] = Vector(-4.5,0,-2)
}
hg.armor.head = {
	["helmet1"] = {
		"head",
		"models/barney_helmet.mdl",
		Vector(1, -2, 0),
		Angle(180, 110, 90),
		protection = 9.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/barney_helmet.mdl",
		femPos = Vector(-1, 0, 0),
		material = {"sal/hanker", "models/jacky_camouflage/digi",
		"models/jacky_camouflage/digi2", "models/lightvest/accs_diff_000_g_uni",
		"sal/acc/armor01_2", "sal/acc/armor01_3", "sal/acc/armor01_4", "sal/acc/armor01_5"},
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/barney_helmet.mdl", vectors[1], -40, "sal/hanker")
		end,
		viewmaterial = false,
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 2,
		ScrappersSlot = "Armor",
	},
	["helmet2"] = {
		"head",
		"models/dean/gtaiv/helmet.mdl",
		Vector(2.6, 0, 0),
		Angle(180, 110, 90),
		protection = 4.2,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/dean/gtaiv/helmet.mdl",
		femPos = Vector(-1, 0, 0),
		norender = true,
		skins = {0,1,3,7,10,11,14},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/dean/gtaiv/helmet.mdl", vectors[2], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		cantsight = true,
		breakable = true,
		durability = 220,
		breakThreshold = 150,
		absorbMultiplier = 0.2,
		durabilityDamageMul = 5,
		impactProtectionMul = 1.65,
		impactDamageScale = 0.1,
		crushFallProtectionMul = 2.35,
		crushFallDamageScale = 0.04,
		crushFallDisorientPower = 10,
		crushFallDisorientTime = 9,
	},
	["helmet3"] = {
		"head",
		"models/eu_homicide/helmet.mdl",
		Vector(2, 0.2, 0),
		Angle(180, 110, 90),
		protection = 4,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eu_homicide/helmet.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eu_homicide/helmet.mdl", vectors[3], 25)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		cantsight = true
	},
	["helmet4"] = {
		"head",
		"models/props_interiors/pot02a.mdl",
		Vector(7, -3.8, -3.8),
		Angle(-45, -65, 90),
		protection = 3,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/props_interiors/pot02a.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet5"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_achhc_b.mdl",
		Vector(2.2,-1, 0),
		Angle(180, 100, 90),
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_achhc_b.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		effect = "Impact",
		surfaceprop = 67,
		scale = 0.9,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet6"] = {
		"head",
		"models/monolithservers2/kerry/swat_hat.mdl",
		Vector(0, 0, 0),
		Angle(180, 100, 90),
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/monolithservers2/kerry/swat_hat.mdl",
		femPos = Vector(0, 0, 0),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/monolithservers2/kerry/swat_hat.mdl", vectors[5], 0)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		scale = 1,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet7"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		Vector(2.5, -0.8, 0),
		Angle(180, 95, 90),
		protection = 12,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		femPos = Vector(-0.6, 0, 0.3),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_s_sh_68.mdl", vectors[4], 0)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1.8,
		ScrappersSlot = "Armor",
	},
	["helmet8"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_un.mdl",
		Vector(2.2,-1, 0),
		Angle(180, 100, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_un.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet9"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ops_core_fast_black.mdl",
		Vector(2.5,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ops_core_fast_black.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet10"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_hops_core_fast.mdl",
		Vector(2.5,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_hops_core_fast.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet11"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ops_core_fast_tan.mdl",
		Vector(2.5,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ops_core_fast_tan.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet12"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ulach_b.mdl",
		Vector(2.9,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ulach_b.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet13"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ulach_c.mdl",
		Vector(2.9,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ulach_c.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet14"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_diamond_age_bastion.mdl",
		Vector(2.55,-1.17, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_diamond_age_bastion.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet15"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_galvion_applique.mdl",
		Vector(2.4,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_galvion_applique.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet16"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_mich2001.mdl",
		Vector(2.5,-1, 0),
		Angle(180, 100, 90),
		scale = 0.88,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_mich2001.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet17"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_msa_gallet.mdl",
		Vector(2.6,-0.91, 0),
		Angle(180, 100, 90),
		scale = 0.90,
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_msa_gallet.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet18"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl",
		Vector(1.85, -1, 0.1),
		Angle(180, 110, 90),
		protection = 15.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl",
		femPos = Vector(0, 0, -0.5),
		norender = true,
		skins = {1,2,3,4,5,6},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl", vectors[2], 0)
		end,
		viewmaterial = false,
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
	},
	["helmet19"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_norsehelm.mdl",
		Vector(1.1, -1.25, 0.1),
		Angle(180, 110, 90),
		protection = 11.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_norsehelm.mdl",
		femPos = Vector(0, 0, 0),
		norender = true,
		skins = {1,2,3,4,5,6},
		viewmaterial = false,
		scale = 0.99,
		femscale = 0.99,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
	},
	["helmet20"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl",
		Vector(0.75, -1, 0.1),
		Angle(180, 110, 90),
		protection = 9.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl",
		femPos = Vector(0, 0, 0),
		material = "sal/hanker",
		norender = true,
		skins = {1,2,3,4,5,6},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl", vectors[1], 25)
		end,
		viewmaterial = false,
		scale = 0.95,
		femscale = 0.99,
		effect = "Impact",
		surfaceprop = 67,
		mass = 2,
		ScrappersSlot = "Armor",
		breakable = true,
		durability = 280,
		breakThreshold = 180,
		absorbMultiplier = 0.16,
		durabilityDamageMul = 5,
		impactProtectionMul = 1.75,
		impactDamageScale = 0.08,
		crushFallProtectionMul = 2.6,
		crushFallDamageScale = 0.03,
		crushFallDisorientPower = 12,
		crushFallDisorientTime = 10,
		ballisticProtectionMul = 0.85,
		ballisticDamageScale = 0.23
	},
	["helmet25"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl",
		Vector(2.27, -0.7, 0),
		Angle(180, 100, 90),
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl",
		skins = {1},
		femPos = Vector(-1, 0, 0.1),
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl", vectors[2], 25)
		end,
		viewmaterial = false,
		norender = true,
		effect = "Impact",
		surfaceprop = 67,
		scale = 0.95,
		femscale = 0.95,
		mass = 1,
		ScrappersSlot = "Armor",
		breakable = true,
		durability = 200,
		breakThreshold = 170,
		absorbMultiplier = 0.2,
		durabilityDamageMul = 5,
		impactProtectionMul = 0.75,
		impactDamageScale = 0.3,
		ballisticProtectionMul = 1.2,
		ballisticDamageScale = 0.16
	},
	["gordon_helmet"] = {
		"head",
		"models/dpfilms/props/hev_helmet.mdl",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 16,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/dpfilms/props/hev_helmet.mdl",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		whitelistClasses = {
			["Gordon"] = true,
		},
		norender = true,
		AdminOnly = true
	},
	["cmb_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 7,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["protovisor"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		voice_change = false,
		nodrop = true,
		Spawnable = false,
	},
}

hg.armor.ears = {
	["headphones1"] = {
		"ears",
		"models/eft_props/gear/headsets/headset_msa.mdl",
		Vector(2.2, 0, 0),
		Angle(0, 100, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/headsets/headset_msa.mdl",
		femPos = Vector(-0.5, 0, 1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		scale = 0.9,
		femscale = 0.85,
		SoundlevelAdd = 15,
		VolumeAdd = 0.2,
		NormalizeSnd = {0.75,0.2}
	}
}

local function DrawNoise(amt, alpha)
	local W, H = ScrW(), ScrH()

	for i = 0, amt do
		local Bright = math.random(0, 255)
		surface.SetDrawColor(Bright, Bright, Bright, alpha)
		local X, Y = math.random(0, W), math.random(0, H)
		surface.DrawRect(X, Y, 1, 1)
	end
end

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

local custommat = Material("overlays/nvg_scene_opticf2.png")

sound.Add( {
	name = "breath_normal",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 55,
	pitch = 100,
	sound = "breath_normal.wav"
} )

local colormodify01 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local colormodify02 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hg.armor.face = {
	["mask1"] = {
		"face", -- "face"
		"models/jmod/ballistic_mask.mdl",
		Vector(4.55, -0.8, 0),
		Angle(180, 90, 90),
		protection = 9.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/jmod/ballistic_mask.mdl",
		femPos = Vector(-1.2, 0, 0.15),
		material = {"sal/hanker","griggs/models/ballistic_mask_2011x","griggs/models/ballistic_mask_collector",
					"griggs/models/ballistic_mask_cute","griggs/models/ballistic_mask_golden_guard",
					"griggs/models/ballistic_mask_grunt","griggs/models/ballistic_mask_peace",
					"griggs/models/ballistic_mask_phonky","griggs/models/ballistic_mask_steamhappy",
					"griggs/models/ballistic_mask_z", "griggs/models/ballistic_mask_pluvmaska",
					"griggs/models/ballistic_mask_coolkid_01","griggs/models/ballistic_mask_coolkid_02",
					"sosoda/models/ballistic_mask_manhunt"},
		norender = true,
		scale = 1,
		femscale = 0.97,
		viewmaterial = Material("sprites/mat_jack_hmcd_narrow"),
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		voice_change = true,
		requireEquipped = {
			placement = "head",
		},
	},
	["mask2"] = {
		"face", -- "face"
		"models/gasmasksfix/m40_drop.mdl",
		Vector(3,-2,-0.5),
		Angle(-90, 90, 0),
		protection = 1.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gasmasksfix/m40_fix.mdl",
		femPos = Vector(-1,0,0),
		norender = true,
		scale = 1,
		femscale = 1,
		viewmaterial = Material("overlays/ba_gasmask"),
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask3"] = {
		"face", -- "face"
		"models/props_silo/welding_helmet.mdl",
		Vector(0, 0.3, 0),
		Angle(-90, 180, 90),
		protection = 7,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/props_silo/welding_helmet.mdl",
		femPos = Vector(-1, 0, 0.5),
		norender = true,
		scale = 1.03,
		femscale = 1,
		viewmaterial = Material("sprites/mat_jack_hmcd_narrow"),
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 2,
		ScrappersSlot = "Armor",
		voice_change = true,
		PhysModel = "models/hunter/blocks/cube025x025x025.mdl",
		PhysPos = Vector(1, 0, 5),
		PhysAng = Angle(0, 90, 0),
	},
	["mask4"] = {
		"face", -- "face"
		"models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl",
		Vector(1,0.2,0),
		Angle(180, 90, 90),
		protection = 1.5,
		femPos = Vector(0,0.1,0.5),
		femscale = 0.98,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl",
		skins = {1,2,3,4,5},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl", vectors[4], 25)
		end,
		viewmaterial = false,
		norender = true,
		scale = 1.04,
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		restricted = {"face"},
		requireEquipped = {
			placement = "head",
			armor = "helmet20"
		},
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask5"] = {
		"face", -- "face"
		"models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl",
		Vector(2,-2.2, 0.07),
		Angle(180, 90, 90),
		protection = 1.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl",
		femPos = Vector(-1,0,0),
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl", vectors[1], 25)
		end,
		norender = true,
		scale = 0.9,
		femscale = 1,
		viewmaterial = Material("vision_sprites_dayz/gasmask.png"),
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["nightvision1"] = {
		"face", -- "face"
		"models/arctic_nvgs/nvg_gpnvg.mdl",
		Vector(1.6, 0.6, 0),
		Angle(0, -90, -90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/arctic_nvgs/nvg_gpnvg.mdl",
		femPos = Vector(-1, 0, 0.5),
		norender = true,
		scale = 0.95,
		femscale = 0.92,
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		custommat = Material("overlays/nvg_scene_opticf2.png"),
		NVGRender = function()
			 
			if not IsValid(lply.EZNVGlamp) then
				lply.EZNVGlamp = ProjectedTexture()
				lply.EZNVGlamp:SetTexture("effects/flashlight001")
				lply.EZNVGlamp:SetBrightness(.06)
				lply.EZNVGlamp:SetEnableShadows(false)
				local FoV = lply:GetFOV()
				lply.EZNVGlamp:SetFOV(FoV + 45)
				lply.EZNVGlamp:SetFarZ(500000 / FoV)
				lply.EZNVGlamp:SetConstantAttenuation(.1)
			else
				local Ang = EyeAngles()
				lply.EZNVGlamp:SetPos(lply:EyePos())
				lply.EZNVGlamp:SetAngles(Ang)
				lply.EZNVGlamp:Update()
			end

			BlurScreen(0.2,65)

			DrawColorModify(colormodify01)
			DrawColorModify(colormodify02)

			DrawBloom(0.4, 1, 4, 4, 1, 0, 12, 12, 6)
			DrawNoise(500,25)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(custommat or mat)
			local viewpunching = GetViewPunchAngles()
			local w, h = ScrW(), ScrH()
			surface.DrawTexturedRect(-w + (w * 1.5) / 2 - viewpunching.r * 6, -20 - viewpunching.x * 6, w * 1.5, h + 40)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-w + (w * 1.5) / 2, (h + 20) - viewpunching.x * 6, w * 1.5, h + 40)
			surface.DrawRect(-w + (w * 1.5) / 2, -(h + 40) - viewpunching.x * 6, w * 1.5, h + 40)
		end,
		CustomSnd = "snds_jack_gmod/tinycapcharge.wav",
		AfterPickup = function(ply)
			--timer.Simple(1,function()
			--	if IsValid(ply) and ply:IsPlayer() then
			--		ply:Notify("Enable \\ Disable NVG - С + E",nil,nil,0)
			--	end
			--end)
		end
	}
}

hg.armor.back = {
	["aqualung"] = {
		"back",
		"models/ceejae_scuba/wet_suit.mdl",
		Vector(5.5, 3.2, 0),
		Angle(0, 92, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/ceejae_scuba/wet_suit.mdl",
		femPos = Vector(0, 0, 0),
		scale = 0.91,
		femscale = 0.91,
		effect = "Impact",
		surfaceprop = 67,
		mass = 5,
		ScrappersSlot = "Armor",
	}
}

if CLIENT then
	net.Receive("AddFlash", function()
		local pos = net.ReadVector()
		local time = net.ReadFloat()
		local size = net.ReadInt(20)
		if not IsValid(lply) then return end
		hg.AddFlash(hg.eye(lply), 1, pos, time, size)
	end)
end

local armorNames = {
	["vest1"] = "Plate Body Armor IV",
	["helmet1"] = "ACH Helmet III",
	["helmet2"] = "Biker Helmet",
	["helmet3"] = "Riot Helmet",
	["helmet4"] = "Pot",
	["helmet7"] = "SSh-68",
	["helmet8"] = "UNTAR Helmet",
	["helmet9"] = "OPS-CORE Helmet",
	["helmet10"] = "OPS-CORE Olive Helmet",
	["helmet11"] = "OPS-CORE Tan Helmet",
	["helmet12"] = "Ulach Black Helmet",
	["helmet13"] = "Ulach Tan Helmet",
	["helmet14"] = "Bastion Helmet",
	["helmet15"] = "Galvion Helmet",
	["helmet16"] = "TC-2001 Helmet",
	["helmet17"] = "MSA Gallet Helmet",
	["helmet18"] = "Great Helmet",
	["helmet19"] = "Norce Helmet",
	["helmet20"] = "Enduro Helmet",
	["helmet25"] = "Tactical MVD Helmet",
	["vest2"] = "Police Riot Vest",
	["vest3"] = "Kevlar IIIA Vest",
	["vest4"] = "Kevlar III Vest",
	["mask1"] = "Balistic Mask",
	["mask2"] = "M40 Gas Mask",
	["mask3"] = "Welding Mask",
	["mask4"] = "Enduro Mask",
	["mask5"] = "Combat GasMask",
	["aqualung"] = "Scuba Suit",
	["vest5"] = "6B13",
	["nightvision1"] = "NVG GPNVG 18",
	["vest6"] = "PACA Soft Armor",
	["vest7"] = "MF-UNTAR Body Armor",
	["vest9"] = "ArsCpc Vest",
	["vest10"] = "MMAC Vest",
	["vest11"] = "Osprey Vest",
	["vest12"] = "Banshee Vest",
	["vest13"] = "THOR Vest",
	["vest14"] = "RBAF Vest",
	["vest15"] = "A18 Skanda Vest",
	["vest16"] = "Korund-VM Vest",
	["vest17"] = "Redut-M Vest",
	["vest18"] = "PlateFrame GE Vest",
	["vest19"] = "IOTV Gen4 Vest",
	["vest20"] = "Rebel Medic Vest",
	["vest21"] = "Rebel Vest",
	["vest22"] = "Iron ChestPlate",
	["vest23"] = "TV-110 Vest",
	["vest25"] = "MVD RIOT Vest",
	["vest26"] = "Plate Carrier Vest III",
	["vest28"] = "Strandhogg Vest",
	["vest30"] = "MVD Tactical Vest",
	["headphones1"] = "MSA Sordin Supreme PRO-X/L",
	["helmet5"] = "HighCom Striker ACHHC IIIA helmet",
	["vest8"] = "SWAT Balistic Vest",
	["ego_equalizer"] = "[HE] Equalizer",
	["helmet6"] = "SWAT Balistic Helmet",
	["gordon_helmet"] = "HEV Suit Helmet",
}
hg.armorNames = armorNames
local armorIcons = {
	["vest1"] = "scrappers/armor1.png",
	["helmet1"] = "vgui/icons/helmet.png",
	["helmet2"] = "vgui/icons/mothelmet.png",
	["helmet3"] = "vgui/icons/riothelm.png",
	["helmet4"] = "entities/ent_jack_gmod_ezarmor_bomber.png",
	["helmet7"] = "entities/ent_jack_gmod_ezarmor_ssh68.png",
	["helmet8"] = "entities/ent_jack_gmod_ezarmor_untarhelm.png",
	["helmet9"] = "entities/ent_jack_gmod_ezarmor_fastmtblack.png",
	["helmet10"] = "entities/ent_jack_gmod_ezarmor_cryeairframe.png",
	["helmet11"] = "entities/ent_jack_gmod_ezarmor_fastmttan.png",
	["helmet12"] = "entities/ent_jack_gmod_ezarmor_ulach.png",
	["helmet13"] = "entities/ent_jack_gmod_ezarmor_ulachcoyote.png",
	["helmet14"] = "entities/ent_jack_gmod_ezarmor_bastion.png",
	["helmet15"] = "entities/ent_jack_gmod_ezarmor_caimanapplique.png",
	["helmet16"] = "entities/ent_jack_gmod_ezarmor_mich2001.png",
	["helmet17"] = "entities/ent_jack_gmod_ezarmor_tc800.png",
	["helmet18"] = "entities/ent_jack_gmod_ezarmor_greathelm.png",
	["helmet19"] = "entities/ent_jack_gmod_ezarmor_norsehelm.png",
	["helmet20"] = "entities/ent_jack_gmod_ezarmor_enduroblack.png",
	["helmet25"] = "entities/ent_jack_gmod_ezarmor_ballistichelmet.png",
	["vest2"] = "vgui/icons/policevest.png",
	["vest3"] = "vgui/icons/armor01.png",
	["vest4"] = "vgui/icons/armor02.png",
	["mask1"] = "vgui/icons/ballisticmask",
	["mask2"] = "vgui/icons/gasmask",
	["mask3"] = "entities/ent_jack_gmod_ezarmor_weldingkill.png",
	["mask4"] = "entities/ent_jack_gmod_ezarmor_enduromouthblack.png",
	["mask5"] = "entities/ent_jack_gmod_ezarmor_nbcgas.png",
	["aqualung"] = "entities/ent_aqualung.png",
	["ego_equalizer"] = "entities/ent_jack_gmod_ezarmor_hazmat.png",
	["vest5"] = "entities/ent_jack_gmod_ezarmor_6b13flora.png",
	["nightvision1"] = "vgui/icons/nvg",
	["vest6"] = "entities/ent_jack_gmod_ezarmor_paca.png",
	["vest7"] = "entities/ent_jack_gmod_ezarmor_untar.png",
	["vest9"] = "entities/ent_jack_gmod_ezarmor_aacpc.png",
	["vest10"] = "entities/ent_jack_gmod_ezarmor_mmac.png",
	["vest11"] = "entities/ent_jack_gmod_ezarmor_ospreyass.png",
	["vest12"] = "entities/ent_jack_gmod_ezarmor_banshee.png",
	["vest13"] = "entities/ent_jack_gmod_ezarmor_thoricvest.png",
	["vest14"] = "entities/ent_jack_gmod_ezarmor_rbavaf.png",
	["vest15"] = "entities/ent_jack_gmod_ezarmor_arsarmaa18.png",
	["vest16"] = "entities/ent_jack_gmod_ezarmor_korundvm.png",
	["vest17"] = "entities/ent_jack_gmod_ezarmor_redutm.png",
	["vest18"] = "entities/ent_jack_gmod_ezarmor_plateframege.png",
	["vest19"] = "entities/ent_jack_gmod_ezarmor_iotvvest.png",
	["vest20"] = "entities/ent_jack_gmod_ezarmor_rebelmedtorso.png",
	["vest21"] = "entities/ent_jack_gmod_ezarmor_rebeltorso.png",
	["vest22"] = "entities/ent_jack_gmod_ezarmor_chestplate.png",
	["vest23"] = "entities/ent_jack_gmod_ezarmor_tv110.png",
	["vest25"] = "entities/ent_jack_gmod_ezarmor_stab.png",
	["vest26"] = "entities/ent_jack_gmod_ezarmor_plateblack.png",
	["vest28"] = "entities/ent_jack_gmod_ezarmor_strandhogg.png",
	["vest30"] = "entities/ent_jack_gmod_ezarmor_tacticalblack.png",
	["headphones1"] = "entities/ent_jack_gmod_ezarmor_sordin.png",
	["helmet5"] = "entities/ent_jack_gmod_ezarmor_achhcblack.png",
	["vest8"] = "vgui/icons/armor01.png",
	["helmet6"] = "vgui/icons/helmet.png",
}
hg.armorIcons = armorIcons

local entityMeta = FindMetaTable("Entity")
function entityMeta:SyncArmor()
	if self.armors then
		self:SetNetVar("Armor", self.armors)
		local rag = hg.GetCurrentCharacter(self)
		if IsValid(rag) and rag:IsRagdoll() then
			rag.armors = table.Copy(self.armors)
			rag.armors_shots = table.Copy(self.armors_shots or {})
			rag.armors_health = table.Copy(self.armors_health or {})
			rag.armors_broken = table.Copy(self.armors_broken or {})
			rag.armors_broken_mul = table.Copy(self.armors_broken_mul or {})
			rag:SetNetVar("Armor", self.armors)
			rag:SetNetVar("HideArmorRender", self:GetNetVar("HideArmorRender", false))
		end
	end
end

local function initArmor()
	for possibleArmor, armors in pairs(hg.armor) do
		for armorkey, armorData in pairs(armors) do
			if CLIENT then language.Add(armorkey, armorNames[armorkey] or armorkey) end
			if armorData.inbuilt then continue end
			
			local armor = {}
			armor.Base = "armor_base"
			armor.PrintName = CLIENT and language.GetPhrase(armorkey) or armorkey
			armor.name = armorkey
			armor.Category = "ZCity Armor"
			armor.Spawnable = true
			if armorData.Spawnable != nil then
				armor.Spawnable = false
			end
			if armorData.AdminOnly then
				armor.AdminOnly = true
			end
			armor.Model = armorData[2]
			armor.WorldModel = armorData[2]
			armor.SubMats = armorData[4]
			armor.armor = armorData
			armor.placement = armorData[1]
			armor.IconOverride = armorIcons[armorkey]
			armor.PhysModel = armorData.PhysModel or nil
			armor.PhysPos = armorData.PhysPos or nil
			armor.PhysAng = armorData.PhysAng or nil
			armor.material = armorData.material or nil
			armor.skins = armorData.skins or nil
			scripted_ents.Register(armor, "ent_armor_" .. armorkey)
		end
	end
end

function hg.GetArmorPlacement(armor)
	if istable(armor) then return end
	armor = string.Replace(armor,"ent_armor_","")
	
	local found
	for i,armplc in pairs(hg.armor) do
		for i2,armor2 in pairs(armplc) do
			if i2 == armor then found = i end
		end
	end
	return found
end

local stringToNum = {
	["torso"] = 1,
	["head"] = 2,
	["face"] = 3,
}

function hg.GetArmorPlacementNum(armor)
	return stringToNum[hg.GetArmorPlacement(armor)]
end

initArmor()
hook.Add("Initialize", "init-atts", initArmor)
