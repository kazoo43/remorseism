-- 
util.AddNetworkString("Get_Appearance")
util.AddNetworkString("OnlyGet_Appearance")
hg.Appearance = hg.Appearance or {}
local APmodule = hg.Appearance

hg.PointShop = hg.PointShop or {}
local PSmodule = hg.PointShop

local function CheckAttachments(ply,tbl)
    if !IsValid(ply) or !ply:IsPlayer() then return end
    --print(ply:PS_HasItem(uid))
    if hg.Appearance.GetAccessToAll(ply) then return tbl end
    for i = 1, #tbl.AAttachments do
        local uid = tbl.AAttachments[i]
        if PSmodule.Items[uid] and (!ply:PS_HasItem(uid) and ply:IsPlayer()) then
            tbl.AAttachments[i] = ""
            ply:ChatPrint(uid .. " - not bought, removed")
        end

        if hg.Accessories[uid] and hg.Accessories[uid].disallowinappearance then
            tbl.AAttachments[i] = ""
            if ply.ChatPrint then ply:ChatPrint(uid .. " - is disallowed in default appearance, removed") end
        end
    end

    local tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel] or tbl.AModel
    tbl.ABodygroups = tbl.ABodygroups or {}
    for k,v in pairs(tbl.ABodygroups) do
        if not hg.Appearance.Bodygroups[k] then continue end
        if not hg.Appearance.Bodygroups[k][tMdl.sex and 2 or 1] then continue end
        local bodygroup = hg.Appearance.Bodygroups[k][tMdl.sex and 2 or 1][v]

        if not bodygroup then continue end

        local uid = bodygroup["ID"]
        --print(bodygroup[2],uid,PSmodule.Items[uid],ply:PS_HasItem(uid))
        if bodygroup[2] and uid and PSmodule.Items[uid] and (!ply:PS_HasItem(uid) and ply:IsPlayer()) then
            tbl.ABodygroups[k] = nil
            ply:ChatPrint(v .. " - not bought, removed")
        end
    end

    return tbl
end

local function ForceApplyAppearance(ply, tbl, noModelChange)
    local classModelLocked = {
        bloodz = true,
        combine = true,
        commanderforces = true,
        furry = true,
        gordon = true,
        groove = true,
        headcrabzombie = true,
        infection_zombie = true,
        metrocop = true,
        nationalguard = true,
        police = true,
        rebel = true,
        refugee = true,
        slugcat = true,
        swat = true,
        ukr = true,
        wagner = true
    }

    local function getRoundName()
        if zb and isstring(zb.CROUND) and zb.CROUND ~= "" then
            return string.lower(zb.CROUND)
        end
        local rnd = CurrentRound and CurrentRound() or nil
        if istable(rnd) and isstring(rnd.name) then
            return string.lower(rnd.name)
        end
        return ""
    end

    local function shouldUseAccessoriesOnly(ent)
        if not IsValid(ent) or not ent:IsPlayer() then return false end

        local roundName = getRoundName()
        if roundName == "survival" or roundName == "superfighters" then
            return false
        end

        local className = string.lower(ent.PlayerClassName or "")
        if className == "" then return false end
        return classModelLocked[className] == true
    end

    tbl.AAttachmentColors = tbl.AAttachmentColors or {}
    local accessoriesOnly = shouldUseAccessoriesOnly(ply)

    local tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel] or tbl.AModel
    local mdl = istable(tMdl) and tMdl.mdl or tMdl
    if mdl ~= ply:GetModel() and !noModelChange and not accessoriesOnly then
        ply:SetModel(mdl)
    end

    if not accessoriesOnly then
        local clr = tbl.AColor
        local vecColor = Vector(clr.r / 255,clr.g / 255,clr.b / 255)
        if ply.SetPlayerColor then
            ply:SetPlayerColor(vecColor)
        end
        ply:SetNWVector( "PlayerColor", vecColor )

        ply:SetSubMaterial()

        local mats = ply:GetMaterials()
        --PrintTable(mats)
        if istable(tMdl) then
            for k, v in pairs(tMdl.submatSlots) do
                --print(k)
                local slot = 1
                for i = 1, #mats do
                    --print(mats[i], v,mats[i] == v, i)
                    if mats[i] == v then slot = i-1 break end
                end
                ply:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] or hg.Appearance.Clothes[tMdl.sex and 2 or 1]["normal"] )
                ply:SetNWString("Colthes" .. k,tbl.AClothes[k] or "normal")
                --print("true")
            end
        end
        for i = 1, #mats do
            if hg.Appearance.FacemapsSlots[mats[i]] and hg.Appearance.FacemapsSlots[mats[i]][tbl.AFacemap] then
                ply:SetSubMaterial(i - 1, hg.Appearance.FacemapsSlots[mats[i]][tbl.AFacemap])
            end
        end

        ply:SetNWString("PlayerName", tbl.AName)
        ply:SetBodyGroups( "00000000000000000000" )

        local bodygroups = ply:GetBodyGroups()
        tbl.ABodygroups = tbl.ABodygroups or {}
        for k, v in ipairs(bodygroups) do
            if !v.name then continue end
            if !tbl.ABodygroups[v.name] then continue end
            if !hg.Appearance.Bodygroups[v.name] then continue end
            for i = 0, #v.submodels do
                local b = v.submodels[i]
                if !hg.Appearance.Bodygroups[v.name][tMdl.sex and 2 or 1][tbl.ABodygroups[v.name]] then continue end
                if hg.Appearance.Bodygroups[v.name][tMdl.sex and 2 or 1][tbl.ABodygroups[v.name]][1] != b then continue end
                ply:SetBodygroup(k-1,i)
            end
        end
    end

    ply:SetNetVar("Accessories", tbl.AAttachments)
    ply:SetNetVar("AccessoryColors", tbl.AAttachmentColors)

    ply.CurAppearance = {}
    table.CopyFromTo(tbl, ply.CurAppearance)
end

local function SyncAppearanceColor(ply)
    if not IsValid(ply) then return end

    local appearance = ply.CurAppearance
    if not appearance or not appearance.AColor then return end

    local clr = appearance.AColor
    local vecColor = Vector(clr.r / 255, clr.g / 255, clr.b / 255)

    if ply.SetPlayerColor then
        ply:SetPlayerColor(vecColor)
    end

    ply:SetNWVector("PlayerColor", vecColor)
    ply:SetNetVar("AccessoryColors", appearance.AAttachmentColors or {})
end


local function WearAppearance(ply,tbl)
    local checked = CheckAttachments(ply,tbl)
    ForceApplyAppearance(ply,checked)
end

APmodule.ForceApplyAppearance = ForceApplyAppearance

local tWaitResponse = {}

function ApplyAppearance(Client,tAppearance,bRandom,bResponeIsValid,bUseCahsed)
    if not IsValid(Client) then return end
    if bRandom or (Client.IsBot and Client:IsBot()) or (Client.IsRagdoll and Client:IsRagdoll()) then
        tAppearance = APmodule.GetRandomAppearance()
        WearAppearance(Client,tAppearance)
        return
    end
    if bUseCahsed then
        tAppearance = APmodule.GetRandomAppearance()
        tAppearance = Client.CachedAppearance or tAppearance
        --Client:ChatPrint(tAppearance.AModel)
        if !APmodule.AppearanceValidater(tAppearance) then tAppearance = APmodule.GetRandomAppearance() end
        net.Start("OnlyGet_Appearance")
        net.Send(Client)
        WearAppearance(Client,tAppearance)
        return
    end

    if !bResponeIsValid then
        tWaitResponse[Client] = CurTime() + 3
        net.Start("Get_Appearance")
        net.Send(Client)
    return end
    if !tWaitResponse[Client] then return end
    if tWaitResponse[Client] < CurTime() then
        ApplyAppearance(Client,nil,true)
    return end

    if !tAppearance then ApplyAppearance(Client,nil,true) return end
    if !APmodule.AppearanceValidater(tAppearance) then ApplyAppearance(Client,nil,true) return end

    WearAppearance(Client,tAppearance)
end

net.Receive("Get_Appearance",function(len,client)
    local tAppearance = net.ReadTable()
    local bRandom = net.ReadBool()
    if !APmodule.AppearanceValidater(tAppearance) then bRandom = true end

    ApplyAppearance(client,tAppearance, table.IsEmpty(tAppearance) and true or bRandom,true)
end)

net.Receive("OnlyGet_Appearance",function(len,client)
    local tAppearance = net.ReadTable()
    local bRandom = !tAppearance or table.IsEmpty(tAppearance)
    --client:ChatPrint(bRandom)
    client.CachedAppearance = bRandom and APmodule.GetRandomAppearance() or tAppearance
    if not bRandom and APmodule.AppearanceValidater(client.CachedAppearance) then
        WearAppearance(client, table.Copy(client.CachedAppearance))
    end
end)

APmodule.ApplyAppearance = ApplyAppearance
APmodule.SyncAppearanceColor = SyncAppearanceColor

hook.Add("PlayerSpawn", "HG_AppearanceLockPlayerColor", function(ply)
    timer.Simple(0, function()
        SyncAppearanceColor(ply)
    end)

    timer.Simple(0.25, function()
        SyncAppearanceColor(ply)
    end)
end)

-- Ragdoll apply
function ApplyAppearanceRagdoll(ent, ply)
    local Appearance = ply.CurAppearance
    if !Appearance then return end
    ent:SetNWString("PlayerName", ply:GetNWString("PlayerName", Appearance.AName))
    ent:SetNetVar("Accessories", ply:GetNetVar("Accessories",""))
    ent:SetNetVar("AccessoryColors", ply:GetNetVar("AccessoryColors", Appearance.AAttachmentColors or {}))

    local tMdl = APmodule.PlayerModels[1][ent:GetModel()] or APmodule.PlayerModels[2][ent:GetModel()] or ent:GetModel()
    if istable(tMdl) then
        for k,v in pairs(tMdl.submatSlots) do
            ent:SetNWString("Colthes" .. k,ply:GetNWString("Colthes" .. k,"normal"))
        end
    end
end

-- Sandbox applyApperance 
if engine.ActiveGamemode() == "sandbox" then
    hook.Add("PlayerSpawn","SetAppearance",function(ply)
        if OverrideSpawn then return end
        timer.Simple(0,function()
            ApplyAppearance(ply,nil,nil,nil,true)
            --ply.OldAppearance = false
        end)
    end)
end
