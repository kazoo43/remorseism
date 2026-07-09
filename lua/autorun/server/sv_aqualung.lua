if not SERVER then return end

util.AddNetworkString("aqualung_toggle")
util.AddNetworkString("aqualung_drop")

local function IsWearing(ply)
	return IsValid(ply) and ply.armors and ply.armors["back"] == "aqualung"
end

net.Receive("aqualung_toggle", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end

	if (ply._aq_cd or 0) > CurTime() then return end
	ply._aq_cd = CurTime() + 1

	if IsWearing(ply) then
		if hg.DropArmor(ply, "aqualung") then
			ply:EmitSound("items/suit_power_down.wav", 75, 90)
		end
	else
		if hg.AddArmor(ply, "aqualung") then
			ply:EmitSound("items/suit_power_up.wav", 100, 90)
		end
	end
end)

net.Receive("aqualung_drop", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end
	if not IsWearing(ply) then return end
	if (ply.DropCD or 0) > CurTime() then return end

	if hg.DropArmor(ply, "aqualung") then
		ply:EmitSound("items/suit_power_down.wav", 75, 90)
	end
end)

hook.Add("Org Think", "z_aqualung_o2", function(owner, org)
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not IsWearing(owner) then return end
	if not org or not org.o2 then return end

	if org.holdingbreath then return end

	org.o2[1] = org.o2.range
	org.o2.curregen = org.o2.regen or 4
end)

print("[Акваланг] Серверный модуль загружен (интеграция с hg.armor)")
