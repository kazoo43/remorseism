if not CLIENT then return end

local function IsWearing(ply)
	ply = ply or LocalPlayer()
	if not IsValid(ply) then return false end
	local armors = ply.armors or ply:GetNetVar("Armor", {})
	return armors["back"] == "aqualung"
end

local BREATH_SOUND = "player/suit_drown.wav"
local BREATH_INTERVAL = SoundDuration(BREATH_SOUND)

local function StopBreath()
	timer.Remove("aqualung_breath_loop")
	if IsValid(LocalPlayer()) then
		LocalPlayer():StopSound(BREATH_SOUND)
	end
end

local function StartBreath()
	StopBreath()
	if not IsValid(lply) then return end

	local function playOnce()
		if not IsValid(lply) or not IsWearing(lply) then
			StopBreath()
			return
		end
		lply:EmitSound(BREATH_SOUND, 60, 100, 0.65)
	end

	playOnce()
	timer.Create("aqualung_breath_loop", math.max(BREATH_INTERVAL, 1), 0, playOnce)
end

hook.Add("OnNetVarSet", "aqualung_breath_sound", function(index, key, var)
	if key ~= "Armor" then return end
	if not IsValid(lply) or Entity(index) ~= lply then return end
	if var and var["back"] == "aqualung" then
		StartBreath()
	else
		StopBreath()
	end
end)

hook.Add("LocalPlayerDeath", "aqualung_breath_stop_death", function() StopBreath() end)
hook.Add("ShutDown", "aqualung_breath_stop_shutdown", function() StopBreath() end)

hook.Add("OnNetVarSet", "aqualung_menu_refresh", function(index, key)
	if key ~= "Armor" then return end
	if not IsValid(hg and hg.armorMenuPanel) then return end
	if Entity(index) ~= lply then return end
	timer.Simple(0.05, function()
		if IsValid(hg.armorMenuPanel) and hg.armorMenuPanel.RefreshTbl then
			hg.armorMenuPanel:RefreshTbl()
		end
	end)
end)

print("[Акваланг] Клиентский модуль загружен (интеграция с hg.armor)")
