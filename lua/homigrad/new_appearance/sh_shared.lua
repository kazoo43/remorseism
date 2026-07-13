hg.Appearance = hg.Appearance or {}
hg.PointShop = hg.PointShop or {}
hg.Accessories = hg.Accessories or {}
local PLUGIN = hg.PointShop
PLUGIN.Items = PLUGIN.Items or {}

-- Validate function for custom name
local allowed = {
	' ',
	'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я',
	'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}
local function IsInvalidName(name)
	local trimmedName = string.Trim(name)
	if trimmedName == "" then return true end
	if #trimmedName < 2 then return true end
	if utf8.len(name) > 25 then return true end
	local symblos = utf8.len(name)
	for k = 1, symblos do
		if not table.HasValue(allowed, utf8.GetChar(name, k)) then return true end
	end

	local ret = hook.Run("ZB_IsInvalidName", name)
	if ret ~= nil then return ret end

	return false
end

hg.Appearance.IsInvalidName = IsInvalidName

-- Random name generator
-- in misc/sh_names.lua
local function GenerateRandomName(iSex)
	local sex = iSex or math.random(1, 2)
	local randomName = hg.Appearance.RandomNames[sex][math.random(1, #hg.Appearance.RandomNames[sex])]
	return randomName
end

hg.Appearance.GenerateRandomName = GenerateRandomName

-- Check access to all
local access = {}
--["STEAM_0:1:163575696"] = true -- distac our custom model creator
local hg_appearance_access_for_all = ConVarExists("hg_appearance_access_for_all") and GetConVar("hg_appearance_access_for_all") or CreateConVar("hg_appearance_access_for_all", 1, {FCVAR_REPLICATED, FCVAR_NEVER_AS_STRING, FCVAR_ARCHIVE}, "Toggle free items in appearance for everyone", 0, 1)
if SERVER then
	cvars.AddChangeCallback("hg_appearance_access_for_all", function(convar_name, value_old, value_new) SetGlobalBool("hg_appearance_access_for_all", hg_appearance_access_for_all:GetBool()) end)
	SetGlobalBool("hg_appearance_access_for_all", hg_appearance_access_for_all:GetBool())
end

local function GetAccessToAll(ply)
	return GetGlobalBool("hg_appearance_access_for_all") or ply:IsSuperAdmin() or ply:IsAdmin() or access[ply:SteamID()]
end

hg.Appearance.GetAccessToAll = GetAccessToAll

-- Appearance models
local PlayerModels = {
	[1] = {},
	[2] = {}
}

local function AppAddModel(strName, strMdl, bFemale, tSubmaterialSlots)
	PlayerModels[bFemale and 2 or 1][strName] = {
		mdl = strMdl,
		submatSlots = tSubmaterialSlots,
		sex = bFemale
	}
end

AppAddModel("Male 01", "models/zcityadodser/m/male_01.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 02", "models/zcityadodser/m/male_02.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 03", "models/zcityadodser/m/male_03.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 04", "models/zcityadodser/m/male_04.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 05", "models/zcityadodser/m/male_05.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 06", "models/zcityadodser/m/male_06.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 07", "models/zcityadodser/m/male_07.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 08", "models/zcityadodser/m/male_08.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Male 09", "models/zcityadodser/m/male_09.mdl", false, { main = "models/humans/male/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })

AppAddModel("Female 01", "models/zcityadodser/f/female_01.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Female 02", "models/zcityadodser/f/female_02.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Female 03", "models/zcityadodser/f/female_03.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Female 04", "models/zcityadodser/f/female_04.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Female 05", "models/zcityadodser/f/female_07.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })
AppAddModel("Female 06", "models/zcityadodser/f/female_06.mdl", true, { main = "models/humans/female/group01/players_sheet", pants = "distac/gloves/pants", boots = "distac/gloves/cross", hands = "distac/gloves/hands" })

hg.Appearance.PlayerModels = PlayerModels
hg.Appearance.FuckYouModels = {{}, {}}
for name, tbl in pairs(hg.Appearance.PlayerModels[1]) do hg.Appearance.FuckYouModels[1][tbl.mdl] = tbl end
for name, tbl in pairs(hg.Appearance.PlayerModels[2]) do hg.Appearance.FuckYouModels[2][tbl.mdl] = tbl end

-- Clothes
hg.Appearance.Clothes = {}
hg.Appearance.Clothes[1] = {
	adidas = "models/humans/male/group01/adidas_colorable",
	alpha_bomber = "models/humans/male/group01/alphaindustry",
	alpha_hoodie = "models/humans/male/group01/alphahoodie",
	antisocial = "models/humans/male/group01/antisocial",
	Army_Shirt = "models/humans/male/group01/armyshirt",
	bean = "models/humans/male/group01/bean",
	bomber_jacket1 = "models/humans/male/group01/bomberjacket1",
	camo_variant2 = "models/humans/male/group01/camo2",
	camoflage = "models/humans/male/group01/camoflage_colorable",
	casual = "models/humans/male/group01/casual",
	cold = "models/humans/male/group01/cold",
	comfy = "models/humans/male/group01/comfy_colorable",
	farmer = "models/humans/male/group01/farmer_colorable",
	Flecktarn = "models/humans/male/group01/flecktarn",
	formal = "models/humans/male/group01/formal",
	formal_only_vest = "models/humans/male/group01/formal_only_vest_colorable",
	formal_vest = "models/humans/male/group01/formal_vest_colorable",
	formal_vest_full = "models/humans/male/group01/formal_vest_full_colorable",
	golden_adidas = "models/humans/male/group01/goldenadidas",
	Hawaiian_Shirt = "models/humans/male/group01/tommy",
	Hawaiian_Shirt2 = "models/humans/male/group01/Hawaiian1",
	Hello_Kitty = "models/humans/male/group01/hello_kitty",
	homeless = "models/humans/male/group01/homeless_colorable",
	hussar_jacket = "models/humans/male/group01/hussar",
	Lambda = "models/humans/male/group01/lambda",
	leather_jacket = "models/humans/male/group01/jacket",
	lonsdale_hoodie = "models/humans/male/group01/LondsdaleHoodie",
	mailman = "models/humans/male/group01/mailman_colorable",
	medic1 = "models/humans/male/group01/medic1",
	miami = "models/humans/male/group01/miami_colorable",
	normal = "models/humans/male/group01/normal",
	Office_Worker = "models/humans/male/group01/OfficeWorker",
	peacefulhooligan = "models/humans/male/group01/peacefulhooligan",
	pilot_jacket = "models/humans/male/group01/pilotjacket",
	plaid = "models/humans/male/group01/plaid",
	polska = "models/humans/male/group01/polska",
	rama = "models/humans/male/group01/rama_colorable",
	rockmountain = "models/humans/male/group01/rockmountain_shirt_colorable",
	russian_army = "models/humans/male/group01/russianarmy",
	Sadsalat = "models/humans/male/group01/sadsalat",
	Security_Officer = "models/humans/male/group01/Security_Officer",
	sport1 = "models/humans/male/group01/sport1_colorable",
	sport4 = "models/humans/male/group01/sport4_colorable",
	striped = "models/humans/male/group01/striped",
	sweater_xmas = "models/humans/male/group01/sweater",
	tactical_outfit = "models/humans/male/group01/tacticalgop",
	Tshirt1 = "models/humans/male/group01/promised",
	Tshirt2 = "models/humans/male/group01/simon",
	Tshirt3 = "models/humans/male/group01/bersk",
	wagner_group = "models/humans/male/group01/wagner",
	warpoint = "models/humans/male/group01/warpoint_jacket_colorable",
	winter = "models/humans/male/group01/winter_colorable",
	wolker = "models/humans/male/group01/wolker_colorable",
	worker = "models/humans/male/group01/worker",
	y2k = "models/humans/male/group01/y2k",
	young = "models/humans/male/group01/young",
	Zcity_Hoodie = "models/humans/male/group01/zcityhoodie",
	zekee_sport = "models/humans/male/group01/zekee_sport_clothes_colorable",
}
hg.Appearance.Clothes[2] = {
	adidas_tracksuit = "models/humans/female/group01/adidas",
	camoflage_f = "models/humans/female/group01/camoflage_colorable",
	casual = "models/humans/female/group01/casual",
	cold = "models/humans/female/group01/cold",
	formal = "models/humans/female/group01/formal",
	Hawaiian_Shirt1 = "models/humans/female/group01/Hawaiian1",
	mailwomen_f = "models/humans/female/group01/mailwomen_colorable",
	normal = "models/humans/female/group01/normal",
	official_f = "models/humans/female/group01/official_colorable",
	plaid = "models/humans/female/group01/plaid",
	rama_f = "models/humans/female/group01/rama_colorable",
	rockmountain_f = "models/humans/female/group01/rockmountain_shirt_colorable",
	sport1_f = "models/humans/female/group01/sport1_colorable",
	sport4_f = "models/humans/female/group01/sport4_colorable",
	striped = "models/humans/female/group01/striped",
	sweater_xmas = "models/humans/female/group01/sweater",
	swiss = "models/humans/female/group01/swiss",
	Tshirt1 = "models/humans/female/group01/flowers",
	Tshirt2 = "models/humans/female/group01/skullshirt",
	Tshirt3 = "models/humans/female/group01/skeletal",
	Tshirt4 = "models/humans/female/group01/redskull",
	warpoint_f = "models/humans/female/group01/warpoint_jacket_colorable",
	wolker_f = "models/humans/female/group01/wolker_colorable",
	young = "models/humans/female/group01/young",
}

hg.Appearance.ClothesDesc = {
	normal = { desc = "Garry's Mod default citizen outfit" },
	formal = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	plaid = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	striped = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	young = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	cold = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	casual = { desc = "from orignial Jack's Homicide gamemode.\nForever." },
	sweater_xmas = {
		desc = "by Wontairr from steam workshop\nRMB to open link",
		link = "https://steamcommunity.com/sharedfiles/filedetails/?id=3621630161"
	},
	worker = {
		desc = "by Chervo93 from steam workshop\nRMB to open link",
		link = "https://steamcommunity.com/sharedfiles/filedetails/?id=3540506879"
	},

	-- Custom Descriptions Overrides
	adidassheet = { desc = "adidas clothes from workshop" },
	stoneisland = { desc = "stone island clothes from dobrograd content" },
	turtleneck_f = { desc = "turtleneck clothes from dobrograd content" },
	formalshirt_f = { desc = "formal shirt clothes from dobrograd content" },
}

-- Colorable Clothes additions (manual merge)
hg.Appearance.Clothes[1]["adidas_cl"] = "models/humans/male/group01/adidas_colorable"
hg.Appearance.Clothes[1]["aphex_white_cl"] = "models/humans/male/fun/aphex_white_colorable"
hg.Appearance.Clothes[1]["alpha_industry_cl"] = "models/humans/male/group01/alphaindustry_colorable"
hg.Appearance.Clothes[1]["camouflage_cl"] = "models/humans/male/group01/camoflage_colorable"
hg.Appearance.Clothes[1]["comfy_cl"] = "models/humans/male/group01/comfy_colorable"
hg.Appearance.Clothes[1]["farmer_cl"] = "models/humans/male/group01/farmer_colorable"
hg.Appearance.Clothes[1]["formal_only_vest_cl"] = "models/humans/male/group01/formal_only_vest_colorable"
hg.Appearance.Clothes[1]["formal_partly_cl"] = "models/humans/male/group01/formal_partly"
hg.Appearance.Clothes[1]["formal_vest_cl"] = "models/humans/male/group01/formal_vest_colorable"
hg.Appearance.Clothes[1]["formal_vest_full_cl"] = "models/humans/male/group01/formal_vest_full_colorable"
hg.Appearance.Clothes[1]["formal_white_cl"] = "models/humans/male/group01/formal_white"
hg.Appearance.Clothes[1]["yakudza_cl"] = "models/humans/male/group01/yakudza_colorable"
hg.Appearance.Clothes[1]["yakudza_suit_cl"] = "models/humans/male/group01/yakudza_suit_colorable"
hg.Appearance.Clothes[1]["half_strip_cl"] = "models/humans/male/group01/half_strip_colorable"
hg.Appearance.Clothes[1]["homeless_cl"] = "models/humans/male/group01/homeless_colorable"
hg.Appearance.Clothes[1]["mailman_cl"] = "models/humans/male/group01/mailman_colorable"
hg.Appearance.Clothes[1]["miami_cl"] = "models/humans/male/group01/miami_colorable"
hg.Appearance.Clothes[1]["old_sport_cl"] = "models/humans/male/group01/old_sport_colorable"
hg.Appearance.Clothes[1]["rama_cl"] = "models/humans/male/group01/rama_colorable"
hg.Appearance.Clothes[1]["rockmountain_cl"] = "models/humans/male/group01/rockmountain_shirt_colorable"
hg.Appearance.Clothes[1]["sport_cl"] = "models/humans/male/group01/sport1_colorable"
hg.Appearance.Clothes[1]["sweatshirt_cl"] = "models/humans/male/group01/sport4_colorable"
hg.Appearance.Clothes[1]["warpoint_cl"] = "models/humans/male/group01/warpoint_jacket_colorable"
hg.Appearance.Clothes[1]["winter_cl"] = "models/humans/male/group01/winter_colorable"
hg.Appearance.Clothes[1]["wolker_cl"] = "models/humans/male/group01/wolker_colorable"
hg.Appearance.Clothes[1]["zekee_sport_cl"] = "models/humans/male/group01/zekee_sport_clothes_colorable"

hg.Appearance.Clothes[2]["adidas_cl"] = "models/humans/female/group01/adidas_colorable"
hg.Appearance.Clothes[2]["aphex_white_cl"] = "models/humans/female/fun/aphex_white_colorable"
hg.Appearance.Clothes[2]["camouflage_cl"] = "models/humans/female/group01/camoflage_colorable"
hg.Appearance.Clothes[2]["comfy_cl"] = "models/humans/female/group01/comfy_colorable"
hg.Appearance.Clothes[2]["formal_partly_cl"] = "models/humans/female/group01/formal_partly"
hg.Appearance.Clothes[2]["formal_white_cl"] = "models/humans/female/group01/formal_white"
hg.Appearance.Clothes[2]["mailwomen_cl"] = "models/humans/female/group01/mailwomen_colorable"
hg.Appearance.Clothes[2]["official_cl"] = "models/humans/female/group01/official_colorable"
hg.Appearance.Clothes[2]["rama_cl"] = "models/humans/female/group01/rama_colorable"
hg.Appearance.Clothes[2]["rockmountain_cl"] = "models/humans/female/group01/rockmountain_shirt_colorable"
hg.Appearance.Clothes[2]["sport_cl"] = "models/humans/female/group01/sport1_colorable"
hg.Appearance.Clothes[2]["sweatshirt_cl"] = "models/humans/female/group01/sport4_colorable"
hg.Appearance.Clothes[2]["warpoint_cl"] = "models/humans/female/group01/warpoint_jacket_colorable"
hg.Appearance.Clothes[2]["wolker_cl"] = "models/humans/female/group01/wolker_colorable"

-- Автозаполнение недостающих описаний
for category, tbl in pairs(hg.Appearance.Clothes) do
	for id, path in pairs(tbl) do
		if not hg.Appearance.ClothesDesc[id] then
			if string.find(id, "halloween") or string.find(id, "winter") or string.find(path, "dobrograd") then
				hg.Appearance.ClothesDesc[id] = { desc = "clothes from dobrograd content" }
			else
				hg.Appearance.ClothesDesc[id] = { desc = "from zcity content." }
			end
		end
	end
end

-- Facemaps
hg.Appearance.FacemapsSlots = hg.Appearance.FacemapsSlots or {}
hg.Appearance.FacemapsModels = hg.Appearance.FacemapsModels or {}
local function AddFacemap(matOverride, strName, matMaterial, model)
	hg.Appearance.FacemapsSlots[matOverride] = hg.Appearance.FacemapsSlots[matOverride] or {}
	local tbl = hg.Appearance.FacemapsSlots[matOverride]
	tbl[strName] = matMaterial
	if model then hg.Appearance.FacemapsModels[model] = matOverride end
end

-----------------------------------Female------------------------------------------------
local female01facemap = "models/humans/female/group01/joey_facemap"
AddFacemap(female01facemap, "Default", "", "models/zcityadodser/f/female_01.mdl") -- female 01
AddFacemap(female01facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/joey_facemap")
for i = 2, 6 do AddFacemap(female01facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/joey_facemap" .. i) end

local female02facemap = "models/humans/female/group01/kanisha_cylmap"
AddFacemap(female02facemap, "Default", "", "models/zcityadodser/f/female_02.mdl") -- female 02
AddFacemap(female02facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/kanisha_cylmap")
for i = 2, 6 do AddFacemap(female02facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/kanisha_cylmap" .. i) end

local female03facemap = "models/humans/female/group01/kim_facemap"
AddFacemap(female03facemap, "Default", "", "models/zcityadodser/f/female_03.mdl") -- female 03
AddFacemap(female03facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap")
AddFacemap(female03facemap, "Face " .. 5, "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap" .. 6)
for i = 2, 4 do AddFacemap(female03facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap" .. i) end

local female04facemap = "models/humans/female/group01/chau_facemap"
AddFacemap(female04facemap, "Default", "", "models/zcityadodser/f/female_04.mdl") -- female 04
AddFacemap(female04facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/chau_facemap")
for i = 2, 5 do AddFacemap(female04facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/chau_facemap" .. i) end

local female05facemap = "models/humans/female/group01/naomi_facemap"
AddFacemap(female05facemap, "Default", "", "models/zcityadodser/f/female_07.mdl") -- female 05 -- why it's female 07... idk dude
AddFacemap(female05facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/naomi_facemap")
for i = 2, 6 do AddFacemap(female05facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/naomi_facemap" .. i) end

local female06facemap = "models/humans/female/group01/lakeetra_facemap"
AddFacemap(female06facemap, "Default", "", "models/zcityadodser/f/female_06.mdl") -- female 06
AddFacemap(female06facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/lakeetra_facemap")
for i = 2, 5 do AddFacemap(female06facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/lakeetra_facemap" .. i) end

-----------------------------------Male--------------------------------------------------
local male01facemap = "models/humans/male/group01/van_facemap"
AddFacemap(male01facemap, "Default", "", "models/zcityadodser/m/male_01.mdl") -- male 01
AddFacemap(male01facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/van_facemap")
for i = 2, 8 do AddFacemap(male01facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/van_facemap" .. i) end

local male02facemap = "models/humans/male/group01/ted_facemap"
AddFacemap(male02facemap, "Default", "", "models/zcityadodser/m/male_02.mdl") -- male 02
AddFacemap(male02facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/ted_facemap")
for i = 2, 10 do AddFacemap(male02facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/ted_facemap" .. i) end
AddFacemap(male02facemap, "Face 11", "models/humans/modern/male/male_02/facemap_01")

local male03facemap = "models/humans/male/group01/joe_facemap"
AddFacemap(male03facemap, "Default", "", "models/zcityadodser/m/male_03.mdl") -- male 03
AddFacemap(male03facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/joe_facemap")
for i = 2, 9 do AddFacemap(male03facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/joe_facemap" .. i) end
AddFacemap(male03facemap, "Face 10", "models/humans/modern/male/male_03/facemap_03")
AddFacemap(male03facemap, "Face 11", "models/humans/modern/male/male_03/facemap_04")
AddFacemap(male03facemap, "Face 12", "models/humans/modern/male/male_03/facemap_06")

local male04facemap = "models/humans/male/group01/eric_facemap"
AddFacemap(male04facemap, "Default", "", "models/zcityadodser/m/male_04.mdl") -- male 04
AddFacemap(male04facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/eric_facemap")
for i = 2, 9 do AddFacemap(male04facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/eric_facemap" .. i) end
AddFacemap(male04facemap, "Face 10", "models/humans/modern/male/male_04/facemap_01")
AddFacemap(male04facemap, "Face 11", "models/humans/modern/male/male_04/facemap_02")
AddFacemap(male04facemap, "Face 12", "models/humans/modern/male/male_04/facemap_03")
AddFacemap(male04facemap, "Face 13", "models/humans/modern/male/male_04/facemap_04")
AddFacemap(male04facemap, "Face 14", "models/characters/citizen/male/facemaps/eric_facemap")
AddFacemap(male04facemap, "Face 15", "models/humans/slav/dobrogradstuff/lacharro_face")
AddFacemap(male04facemap, "Face 16", "models/humans/slav/dobrogradstuff/mikel_red")
AddFacemap(male04facemap, "Face 17", "models/humans/slav/dobrogradstuff/serface")
AddFacemap(male04facemap, "Face 18", "models/humans/slav/dobrogradstuff/xv_simonrus_bandizam")

local male05facemap = "models/humans/male/group01/art_facemap"
AddFacemap(male05facemap, "Default", "", "models/zcityadodser/m/male_05.mdl") -- male 05
AddFacemap(male05facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/art_facemap")
for i = 2, 9 do AddFacemap(male05facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/art_facemap" .. i) end
AddFacemap(male05facemap, "Face 10", "models/humans/modern/male/male_05/facemap_05")
AddFacemap(male05facemap, "Face 11", "models/humans/slav/art/art_facemap1")
AddFacemap(male05facemap, "Face 12", "models/humans/slav/art/art_facemap2")
AddFacemap(male05facemap, "Face 13", "models/humans/slav/art/art_facemap3")
AddFacemap(male05facemap, "Face 14", "models/humans/slav/art/art_facemap4")

local male06facemap = "models/humans/male/group01/sandro_facemap"
AddFacemap(male06facemap, "Default", "", "models/zcityadodser/m/male_06.mdl") -- male 06
AddFacemap(male06facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/sandro_facemap")
for i = 2, 10 do AddFacemap(male06facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/sandro_facemap" .. i) end
AddFacemap(male06facemap, "Face 11", "models/humans/modern/male/male_06/facemap_02")
AddFacemap(male06facemap, "Face 12", "models/humans/modern/male/male_06/facemap_03")
AddFacemap(male06facemap, "Face 13", "models/humans/modern/male/male_06/facemap_04")
AddFacemap(male06facemap, "Face 14", "models/humans/modern/male/male_06/facemap_05")
AddFacemap(male06facemap, "Face 15", "models/characters/citizen/male/facemaps/sandro_facemap6")
AddFacemap(male06facemap, "Face 16", "models/humans/slav/tanned_facemap")
AddFacemap(male06facemap, "Face 17", "models/humans/slav/dobrogradstuff/american_face_zeeke")
AddFacemap(male06facemap, "Face 18", "models/humans/slav/dobrogradstuff/golovastik")
AddFacemap(male06facemap, "Face 19", "models/humans/slav/dobrogradstuff/golovastik_nordd1")
AddFacemap(male06facemap, "Face 20", "models/humans/slav/dobrogradstuff/xv_shirnymark_father")

local male07facemap = "models/humans/male/group01/mike_facemap"
AddFacemap(male07facemap, "Default", "", "models/zcityadodser/m/male_07.mdl") -- male 07
AddFacemap(male07facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/mike_facemap")
for i = 2, 8 do AddFacemap(male07facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/mike_facemap" .. i) end
AddFacemap(male07facemap, "Face 9",  "models/humans/modern/male/male_07/facemap_01")
AddFacemap(male07facemap, "Face 10", "models/humans/slav/dobrogradstuff/american_face_old_male07")
AddFacemap(male07facemap, "Face 11", "models/humans/slav/dobrogradstuff/harley_face_belch")
AddFacemap(male07facemap, "Face 12", "models/humans/slav/dobrogradstuff/lybitelpivasa")
AddFacemap(male07facemap, "Face 13", "models/humans/slav/dobrogradstuff/xv_erik_susig")
AddFacemap(male07facemap, "Face 14", "models/humans/slav/dobrogradstuff/xv_greg_bandizam")
AddFacemap(male07facemap, "Face 15", "models/humans/slav/dobrogradstuff/xv_nikitashevchuk_bandizam")
AddFacemap(male07facemap, "Face 16", "models/humans/slav/dobrogradstuff/facenr07")

local male08facemap = "models/humans/male/group01/vance_facemap"
AddFacemap(male08facemap, "Default", "", "models/zcityadodser/m/male_08.mdl") -- male 08
AddFacemap(male08facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/vance_facemap")
for i = 2, 9 do AddFacemap(male08facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/vance_facemap" .. i) end
AddFacemap(male08facemap, "Face 10", "models/humans/modern/male/male_08/facemap_02")
AddFacemap(male08facemap, "Face 11", "models/characters/citizen/male/facemaps/vance_facemap")
AddFacemap(male08facemap, "Face 12", "models/humans/slav/dobrogradstuff/american_face_deadkennedy")
AddFacemap(male08facemap, "Face 13", "models/humans/slav/dobrogradstuff/bobr_1")
AddFacemap(male08facemap, "Face 14", "models/humans/slav/dobrogradstuff/xv_nicholas_bandizam")

local male09facemap = "models/humans/male/group01/erdim_cylmap"
AddFacemap(male09facemap, "Default", "", "models/zcityadodser/m/male_09.mdl") -- male 09
AddFacemap(male09facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/erdim_facemap")
for i = 2, 11 do AddFacemap(male09facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/erdim_facemap" .. i) end
AddFacemap(male09facemap, "Face 12", "models/humans/modern/male/male_09/facemap_01")
AddFacemap(male09facemap, "Face 13", "models/humans/modern/male/male_09/facemap_02")
AddFacemap(male09facemap, "Face 14", "models/humans/modern/male/male_09/facemap_04")
AddFacemap(male09facemap, "Face 15", "models/characters/citizen/male/facemaps/erdim_facemap")
AddFacemap(male09facemap, "Face 16", "models/humans/slav/dobrogradstuff/advanced_aller")
AddFacemap(male09facemap, "Face 17", "models/humans/slav/dobrogradstuff/ash")
AddFacemap(male09facemap, "Face 18", "models/humans/slav/dobrogradstuff/carmine_face_belch")
AddFacemap(male09facemap, "Face 19", "models/humans/slav/dobrogradstuff/face_rama")
AddFacemap(male09facemap, "Face 20", "models/humans/slav/dobrogradstuff/facemap_kolchak")
AddFacemap(male09facemap, "Face 21", "models/humans/slav/dobrogradstuff/golova_stick")
AddFacemap(male09facemap, "Face 22", "models/humans/slav/dobrogradstuff/sergey")
AddFacemap(male09facemap, "Face 23", "models/humans/slav/dobrogradstuff/vepran")
AddFacemap(male09facemap, "Face 24", "models/humans/slav/dobrogradstuff/nrider_face")
AddFacemap(male09facemap, "Face 25", "models/humans/slav/dobrogradstuff/facenr0901")
AddFacemap(male09facemap, "Face 26", "models/humans/slav/dobrogradstuff/facenr0902")

-- Bodygroups
hg.Appearance.Bodygroups = hg.Appearance.Bodygroups or {
	TORSO = { [1] = {}, [2] = {} },
	LEGS = { [1] = {}, [2] = {} },
	HANDS = {
		[1] = {
			["None"] = {"hands", false},
		},
		[2] = {
			["None"] = {"hands", false},
		},
	},
	gloves2 = { [1] = {}, [2] = {} },
}

local function AppAddBodygroup(strBodyGroup, strName, strStringID, bFemale, bPointShop, bDonateOnly, fCost, psModel, psBodygroups, psSubmats, psStrNameOveride)
	local pointShopID = "Standard_BodyGroups_" .. (psStrNameOveride or strName)
	hg.Appearance.Bodygroups[strBodyGroup] = hg.Appearance.Bodygroups[strBodyGroup] or {}
	hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] = hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] or {}
	hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1][strName] = {
		strStringID,
		bPointShop,
		ID = pointShopID,
		bgIndex = psBodygroups or 0
	}
	if SERVER then
		PLUGIN:CreateItem(pointShopID, string.NiceName(strName), psModel or "models/zcity/gloves/degloves.mdl", psBodygroups, 0, Vector(0, 0, 0), fCost, bDonateOnly, psSubmats or {})
	end
end

local function AddBodygroupsFunc()
	-- Gloves (HANDS)
	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, { [0] = "distac/gloves/sceletgloves" })
	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, { [0] = "distac/gloves/sceletgloves" })
	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, { [0] = "distac/gloves/sceletgloves" })
	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, { [0] = "distac/gloves/sceletgloves" })
	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_glove_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)

	-----------ZCITY+ STUFF----------------------------
	AppAddBodygroup("TORSO", "Standard Top", "male_standart_top.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Wide Top", "male_standart_top_wide.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Wide More Top", "male_standart_top_wide_more.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "T-Shirt", "male_standart_tshirt.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Closed Collar", "male_standart_closed_collar.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("HANDS", "T-Shirt Hands", "handsfortshirt", false, false, false, 0, nil, 0)
	AppAddBodygroup("HANDS", "Robotic Hand", "robotichands", false, false, false, 0, nil, 0)
	AppAddBodygroup("HANDS", "Medical Gloves", "medical_gloves", false, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Odessa Jacket", "male_odessa_jacket.smd", false, false, false, 0, nil, 0)
	--PANTSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS-------
	AppAddBodygroup("LEGS", "Standard Bottom", "male_reference_bottom.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Wide Bottom", "male_reference_wide_bottom.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Boots", "male_reference_boots.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Shorts", "male_reference_bottom_shorts.smd", false, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Boots Wider", "male_reference_boots_wider.smd", false, false, false, 0, nil, 0)

	-- Female bodygroups
	AppAddBodygroup("TORSO", "Standard Top", "female_standart_top.smd", true, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Wide Top", "female_standart_top_wide.smd", true, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Wide More Top", "female_standart_top_wide_more.smd", true, false, false, 0, nil, 0)
	AppAddBodygroup("TORSO", "Mossman Jacket", "female_mossman_jacket.smd", true, false, false, 0, nil, 0)

	AppAddBodygroup("LEGS", "Standard Bottom", "female_reference_bottom.smd", true, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Wide Bottom", "female_reference_wide_bottom.smd", true, false, false, 0, nil, 0)
	AppAddBodygroup("LEGS", "Boots", "female_reference_boots.smd", true, false, false, 0, nil, 0)
end

hook.Add("ZPointshopLoaded", "AddBodygroups", AddBodygroupsFunc)

-- SkeletonTable
hg.Appearance.SkeletonAppearanceTable = {
	AModel = "Male 07",
	AClothes = {
		main = "normal",
		pants = "normal",
		boots = "normal"
	},
	AName = "John Z-City", -- JOHN GMOD
	AColor = Color(180, 0, 0),
	AAttachments = {},
	AAttachmentColors = {},
	ABodygroups = {},
	AFacemap = "Default"
}

-- GetRandomAppearance
function hg.Appearance.GetRandomAppearance()
	local randomAppearance = table.Copy(hg.Appearance.SkeletonAppearanceTable)
	local iSex = math.random(1, 2)
	local modelPool = PlayerModels[iSex]
	if not istable(modelPool) or table.IsEmpty(modelPool) then
		modelPool = PlayerModels[1] or PlayerModels[2] or {}
	end
	local tMdl, str = table.Random(modelPool)
	if not tMdl or not str then
		randomAppearance.AModel = randomAppearance.AModel or "Male 07"
		randomAppearance.AClothes = randomAppearance.AClothes or { main = "normal", pants = "normal", boots = "normal" }
		randomAppearance.AName = randomAppearance.AName or "John Z-City"
		randomAppearance.AColor = randomAppearance.AColor or Color(180, 0, 0)
		randomAppearance.AAttachments = randomAppearance.AAttachments or {}
		randomAppearance.AFacemap = randomAppearance.AFacemap or "Default"
		return randomAppearance
	end
	randomAppearance.AModel = str
	local clothesPool = hg.Appearance.Clothes and hg.Appearance.Clothes[iSex]
	if not istable(clothesPool) or table.IsEmpty(clothesPool) then
		clothesPool = hg.Appearance.Clothes and (hg.Appearance.Clothes[1] or hg.Appearance.Clothes[2]) or nil
	end
	_, str = clothesPool and table.Random(clothesPool) or nil
	str = str or "normal"
	randomAppearance.AClothes = {
		main = str,
		pants = str,
		boots = str
	}

	randomAppearance.AName = GenerateRandomName(iSex)
	randomAppearance.AColor = ColorRand(false)
	for i = 1, 1 do
		local data, k
		if istable(hg.Accessories) and not table.IsEmpty(hg.Accessories) then
			data, k = table.Random(hg.Accessories)
		end
		if not data or not k then
			k = "none"
		else
			for ii, name in ipairs(randomAppearance.AAttachments) do
				local existing = hg.Accessories[name]
				if existing and existing.placement == data.placement then k = "none" end
			end

			if data.disallowinappearance then k = "none" end
		end
		randomAppearance.AAttachments[i] = k
	end

	local facemap
	local facemapSlot = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[tMdl.mdl]
	local facemapPool = facemapSlot and hg.Appearance.FacemapsSlots and hg.Appearance.FacemapsSlots[facemapSlot]
	if istable(facemapPool) and not table.IsEmpty(facemapPool) then
		_, facemap = table.Random(facemapPool)
	end
	randomAppearance.AFacemap = facemap or randomAppearance.AFacemap or "Default"
	return randomAppearance
end

-- Validator
hg.Appearance.ValidateFunctions = {
	AModel = function(str)
		if not isstring(str) then return false end
		if not PlayerModels[1][str] and not PlayerModels[2][str] then return false end
		return true
	end,
	AClothes = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 3 then return false end
		return true
	end,
	AName = function(str)
		if not isstring(str) then return false end
		return not IsInvalidName(str)
	end,
	AColor = function(clr)
		return true
	end,
	AAttachments = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 6 then return false, "Too many" end
		local occupatedSlots = {}
		for k, v in ipairs(tbl) do
			if not hg.Accessories[v] then
				continue
			end

			if occupatedSlots[hg.Accessories[v].placement] then
				tbl[k] = "none"
				continue
			end

			if hg.Accessories[v].placement then occupatedSlots[hg.Accessories[v].placement] = true end
		end
		return true 
	end,
	AAttachmentColors = function(tbl)
		if tbl == nil then return true end
		return istable(tbl)
	end,
	ABodygroups = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 3 then return false end
		return true
	end,
	AFacemap = function(str) if not isstring(str) then return false end return true end
}

local function AppearanceValidater(tblAppearance)
	local VaildFuncs = hg.Appearance.ValidateFunctions
	local bValidAModel = VaildFuncs.AModel(tblAppearance.AModel)
	local bValidAClothes = VaildFuncs.AClothes(tblAppearance.AClothes)
	local bValidAName = VaildFuncs.AName(tblAppearance.AName)
	local bValidAColor = VaildFuncs.AColor(tblAppearance.AColor)
	local bValidAAttachments = VaildFuncs.AAttachments(tblAppearance.AAttachments)
	local bValidAAttachmentColors = VaildFuncs.AAttachmentColors(tblAppearance.AAttachmentColors)
	if bValidAModel and bValidAClothes and bValidAName and bValidAColor and bValidAAttachments and bValidAAttachmentColors then return true end
	return false
end

hg.Appearance.AppearanceValidater = AppearanceValidater

function ThatPlyIsFemale(ply)
	ply.CahceModel = ply.CahceModel or ""
	if ply.CahceModel == ply:GetModel() then return ply.bSex and true or false end
	local tSubModels = ply:GetSubModels()
	if not tSubModels then return false end
	ply.CahceModel = ply:GetModel()
	for i = 1, #tSubModels do
		local name = tSubModels[i]["name"]
		if name == "models/m_anm.mdl" then
			ply.bSex = false
			return false
		end

		if name == "models/f_anm.mdl" then
			ply.bSex = true
			return true
		end
	end
	return false
end

local plymeta = FindMetaTable("Player")
function plymeta:GetSubMaterialSlots()
	local tMdl = hg.Appearance.FuckYouModels[1][self:GetModel()] or hg.Appearance.FuckYouModels[2][self:GetModel()]
	local mats = self:GetMaterials()
	local slots = {}
	if istable(tMdl) then
		for k, v in pairs(tMdl.submatSlots) do
			local slot = 1
			for i = 1, #mats do
				if mats[i] == v then
					slot = i - 1
					break
				end
			end

			slots[#slots + 1] = slot
		end
	end
	return slots
end

local entmeta = FindMetaTable("Entity")

function entmeta:GetSubMaterialIdByName(strName)
	local mats = self:GetMaterials()
	local id = false
	for i = 1, #mats do
		if mats[i] == strName then
			id = i - 1
			break
		end
	end
	return id
end
