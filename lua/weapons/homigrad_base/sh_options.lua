if CLIENT then
	hook.Add("PlayerButtonDown", "hg_inspect_key", function(ply, button)
		if button ~= KEY_R then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end
		local canInspect = wep.AllowedInspect
		if not isfunction(canInspect) then return end
		if not canInspect(wep) then return end
		wep:PlayAnim("inspect", 5, false)
		RunConsoleCommand("hg_inspect")
	end)

	concommand.Add("hg_unload_ammo", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		if wep and ishgweapon(wep) and wep:Clip1() > 0 and wep:CanUse() then
			net.Start("unload_ammo")
			net.WriteEntity(wep)
			net.SendToServer()
			wep:SetClip1(0)
			wep.drawBullet = nil
		end
	end)

	concommand.Add("hg_change_ammotype", function(ply, cmd, args)
	    local wep = ply:GetActiveWeapon()
	    local type_ = math.Round(args[1])
	    if wep and ishgweapon(wep) and (wep:Clip1() == 0 or wep.AllwaysChangeAmmo) and wep:CanUse() and wep.AmmoTypes and wep.AmmoTypes[type_] then
	        ply:ChatPrint("Changed ammotype to: " .. wep.AmmoTypes[type_][1])
	        net.Start("changeAmmoType")
	        net.WriteEntity(wep)
	        net.WriteInt(type_, 4)
	        net.SendToServer()
	    end
	end)

	net.Receive("unload_ammo",function()
		local wep = net.ReadEntity()
		if wep.AnimList["unload"] then
			wep:PlayAnim("unload", wep.UnloadAnimTime)
		else
			wep:AttachAnim()
		end
		if wep.Unload then
			wep:Unload()
		end
	end)
else
	util.AddNetworkString("unload_ammo")
	util.AddNetworkString("changeAmmoType")

	net.Receive("unload_ammo", function(len, ply)
		local wep = net.ReadEntity()
        if ply:GetNWFloat("willsuicide", 0) > 0 then return end -- you cant escape.
        wep.drawBullet = nil
        if wep and wep:GetOwner() == ply and ishgweapon(wep) and wep:Clip1() > 0 and wep:CanUse() then
			ply:GiveAmmo(wep:Clip1(), wep:GetPrimaryAmmoType(), true)
			wep:SetClip1(0)
			if wep.Unload then
				wep:Unload()
			end
			net.Start("unload_ammo")
			net.WriteEntity(wep)
			net.Broadcast()
			hg.GetCurrentCharacter(ply):EmitSound("snd_jack_hmcd_ammotake.wav")
		end
	end)

	net.Receive("changeAmmoType", function(len, ply)
	    local wep = net.ReadEntity()
	    local type_ = net.ReadInt(4)
	    if not IsValid(wep) then return end
	    if wep:GetOwner() ~= ply then return end
	    if not ishgweapon(wep) then return end
	    if not wep:CanUse() then return end
	    if not wep.AmmoTypes or not wep.AmmoTypes[type_] then return end
	    if not wep.AllwaysChangeAmmo and wep:Clip1() ~= 0 then return end
	    wep:ApplyAmmoChanges(type_)
	end)
end

hg.postures = {
    [0] = "Regular hold",
    [1] = "Hipfire",
    [2] = "Left shoulder",
    [3] = "High ready",
    [4] = "Low ready",
    [5] = "Point shooting",
    [6] = "Shooting from cover",
    [7] = {"Gangsta",isPistolOnly = true},
    [8] = {"One-handed",isPistolOnly = true},
	[9] = "Somalian",
}

if CLIENT then
	local printed

	concommand.Add("hg_change_posture", function(ply, cmd, args)
		if not args[1] and not isnumber(args[1]) and not printed then print([[Change your gun posture:
0 - regular hold
1 - hipfire
2 - left shoulder
3 - high ready
4 - low ready
5 - point shooting
6 - shooting from cover
7 - gangsta shooting
8 - one-handed shooting
9 - somalian shooting
]]) printed = true end
		local pos = math.Round(args[1] or -1)
		net.Start("change_posture")
		net.WriteInt(pos, 8)
		net.SendToServer()
	end)

	net.Receive("change_posture", function()
		local ply = net.ReadEntity()
		local pos = net.ReadInt(8)
		
		ply.posture = pos
	end)
else
	util.AddNetworkString("change_posture")
	net.Receive("change_posture", function(len, ply)
		local pos = net.ReadInt(8)

		if (ply.change_posture_cooldown or 0) > CurTime() then return end
		ply.change_posture_cooldown = CurTime() + 0.1

		local gun = ply:GetActiveWeapon()
		if IsValid(gun) and ishgweapon(gun) then
			ply:EmitSound("weapons/zmirli/shared/foley_light" .. math.random(1,4) .. ".wav", 45, math.random(95,105))
		end

		if pos ~= -1 then
			if pos == ply.posture then
				ply.posture = 0
				pos = 0
			else
				ply.posture = pos
			end
		else
			ply.posture = ply.posture or 0
			ply.posture = (ply.posture + 1) > #hg.postures and 0 or ply.posture + 1
		end
		net.Start("change_posture")
		net.WriteEntity(ply)
		net.WriteInt(ply.posture, 9)
		net.Broadcast()
	end)
end

if SERVER then
	util.AddNetworkString("hg_viewgun")

	concommand.Add("hg_inspect", function(ply, cmd, args)
		local gun = ply:GetActiveWeapon()
		if not IsValid(gun) or not gun then return end
		local canInspect = gun.AllowedInspect
		if not isfunction(canInspect) then return end
		if not canInspect(gun) then return end
		gun.inspect = CurTime() + 5
		gun:PlayAnim("inspect", 5, false)
		net.Start("hg_viewgun")
		net.WriteEntity(gun)
		net.WriteFloat(gun.inspect)
		net.Broadcast()
	end)
else
	net.Receive("hg_viewgun", function() 
		local ent = net.ReadEntity()
		local time = net.ReadFloat()
		ent.inspect = time
		ent.hudinspect = time
	end)
end

if CLIENT then
	local weaponMenuAmmoSectionText = "Ammo Types"
	local weaponMenuCylinderSectionText = "Cylinder"
	local weaponMenuSlotText = "Slot %d"
	local weaponMenuAmmoIconCache = {}
	local weaponMenuEmptySlotIcon = Material("radialmenu/redcross.png", "smooth mips")

	local function GetWeaponMenuAmmoIcon(ammoName)
		if not ammoName or ammoName == "" then return nil end
		if weaponMenuAmmoIconCache[ammoName] ~= nil then return weaponMenuAmmoIconCache[ammoName] end

		local ammoInfo = hg.ammotypeshuy and hg.ammotypeshuy[ammoName]
		local ammoID = ammoInfo and ammoInfo.name
		if not ammoID then
			weaponMenuAmmoIconCache[ammoName] = false
			return nil
		end

		local entClass = "ent_ammo_" .. ammoID
		local stored = scripted_ents.GetStored(entClass)
		local iconPath = stored and stored.t and stored.t.IconOverride or hg.ammoents and hg.ammoents[ammoID] and hg.ammoents[ammoID].Icon
		if not iconPath or iconPath == "" then
			weaponMenuAmmoIconCache[ammoName] = false
			return nil
		end

		local mat = Material(iconPath, "smooth mips")
		weaponMenuAmmoIconCache[ammoName] = mat

		return mat
	end

	local function BuildWeaponAmmoMenu(wep)
		local options = {}

		for index, ammoData in ipairs(wep.AmmoTypes or {}) do
			local ammoName = ammoData[1]
			options[#options + 1] = {
				[1] = function()
					RunConsoleCommand("hg_change_ammotype", index)
				end,
				[2] = ammoName,
				[5] = GetWeaponMenuAmmoIcon(ammoName)
			}
		end

		return options
	end

	local function GetWeaponMenuDrumSlotText(index, value)
		if value == 1 then
			return string.format(weaponMenuSlotText .. " - Loaded", index)
		end

		if value == -1 then
			return string.format(weaponMenuSlotText .. " - Spent", index)
		end

		return string.format(weaponMenuSlotText .. " - Empty", index)
	end

	local function BuildWeaponDrumMenu(wep)
		local options = {}
		local drum = wep:GetDrum()

		for index = 1, #drum do
			options[#options + 1] = {
				[1] = function()
					RunConsoleCommand("hg_insertbullet", index)
				end,
				[2] = function()
					if not IsValid(wep) then return GetWeaponMenuDrumSlotText(index, 0) end

					local liveDrum = wep:GetDrum()
					return GetWeaponMenuDrumSlotText(index, liveDrum[index])
				end,
				[5] = function()
					if not IsValid(wep) then return weaponMenuEmptySlotIcon end

					local liveDrum = wep:GetDrum()
					local value = liveDrum[index]
					if value == 0 then
						return weaponMenuEmptySlotIcon
					end

					return GetWeaponMenuAmmoIcon(wep.Primary and wep.Primary.Ammo)
				end
			}
		end

		return options
	end

	hook.Add("radialOptions", "weapon_manipulations", function()
		local wep = lply:GetActiveWeapon()
		local organism = lply.organism or {}
		
		if !lply:Alive() or !organism or organism.otrub or !organism.canmove then return end
		
		local attmenu = {
			[1] = function()
				RunConsoleCommand("hg_get_attachments", 0)

				return 0
			end,
			[2] = "Attachments Menu"
		}

        if !IsValid(wep) or !ishgweapon(wep) then
			if #hg.GetAttachmentsInv() > 0 then
				hg.radialOptions[#hg.radialOptions + 1] = attmenu
			end

			return
		end
		
        local tbl = {
            [1] = {
                [1] = function(mouseClick)
                    if mouseClick == 1 then
                        RunConsoleCommand("hg_change_posture", -1)
                    else
                        local tbl2 = {}

                        for i, str in pairs(hg.postures) do -- DO. NOT. CHANGE. TO. IPAIRS. kthxbye
							if istable(str) then
								if str.isPistolOnly and !wep:IsPistolHoldType() then continue end
							end
                            tbl2[#tbl2 + 1] = {
                                [1] = function()
                                    RunConsoleCommand("hg_change_posture", i)

                                end,
                                [2] = istable(str) and str[1] or str
                            }
                        end

                        hg.CreateRadialMenu(tbl2)
                    end

                    return -1
                end,
                [2] = "Change Posture\nRMB - Menu"
            },
            [2] = {
                [1] = function()
                    RunConsoleCommand("hg_change_posture", 0)
                end,
                [2] = "Reset Posture"
            },
			[3] = attmenu,
        }

        if wep.GetDrum then
            local tbl3 = {function(mouseClick)
				hg.radialRollDrumSpinStart = CurTime()
				RunConsoleCommand("hg_rolldrum")

				return -1
			end, "Roll Drum"}
            tbl[#tbl + 1] = tbl3

			local drumMenu = BuildWeaponDrumMenu(wep)
			if #drumMenu > 0 then
				tbl[#tbl + 1] = {
					[1] = function()
						hg.CreateRadialMenu(drumMenu)

						return -1
					end,
					[2] = weaponMenuCylinderSectionText,
					[5] = GetWeaponMenuAmmoIcon(wep.Primary and wep.Primary.Ammo)
				}
			end
        end

        do
            local canInspect = wep.AllowedInspect
            if isfunction(canInspect) and canInspect(wep) then
                tbl[#tbl + 1] = {
                    [1] = function()
                        RunConsoleCommand("hg_inspect")
                    end,
                    [2] = "Inspect" 
                }
            end
        end

        if wep:Clip1() > 0 then
            tbl[#tbl + 1] = {
                [1] = function()
                    RunConsoleCommand("hg_unload_ammo", 0)
                end,
                [2] = "Unload" 
            }
        elseif (wep:Clip1() == 0 or wep.AllwaysChangeAmmo) and wep.AmmoTypes and not wep.reload then
			local ammoMenu = BuildWeaponAmmoMenu(wep)
			if #ammoMenu > 0 then
				tbl[#tbl + 1] = {
					[1] = function()
						hg.CreateRadialMenu(ammoMenu)

						return -1
					end,
					[2] = weaponMenuAmmoSectionText,
					[5] = GetWeaponMenuAmmoIcon(wep.Primary and wep.Primary.Ammo) or ammoMenu[1][5]
				}
			end
        end

        local laser = wep.attachments and wep.attachments.underbarrel
        if (laser and not table.IsEmpty(laser)) or wep.laser then
			tbl[#tbl + 1] = {
                [1] = function()
                    RunConsoleCommand("hmcd_togglelaser")
                end,
                [2] = "Toggle Laser" 
            }
		end

        hg.radialOptions[#hg.radialOptions + 1] = {
            [1] = function(mouseClick)
                hg.CreateRadialMenu(tbl)

                return -1
            end,
            [2] = "Weapon Menu"
        }
    end)
end
