
local MODE = MODE

MODE.MapSize = 7500
MODE.ZoneTimeToShrink = 120

function MODE.GetZoneRadius()
	if !zonedistance or !isnumber(zonedistance) then return 0xFFFFFFFF /*UUUUUUUUUUUUUUUUUCK*/ end
	local dist = zonedistance + 2048
	
	return (dist * math.max(((zb.ROUND_START + MODE.ZoneTimeToShrink) - CurTime()) / MODE.ZoneTimeToShrink, 0.025))
end

function MODE:HG_MovementCalc_2( mul, ply, cmd, mv )
    if (zb.ROUND_START or 0) + 20 > CurTime() and cmd then 
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_ATTACK2)
        if mv then
            mv:RemoveKey(IN_ATTACK)
            mv:RemoveKey(IN_ATTACK2)
        end

        local hands = IsValid(ply) and (hg.GetHandsWeapon and hg.GetHandsWeapon(ply) or ply:GetWeapon("weapon_hands_sh"))
        if IsValid(hands) then
            cmd:SelectWeapon(hands)
            if SERVER then ply:SelectWeapon(hands:GetClass()) end
        end
    end
end

function MODE:PlayerCanLegAttack( ply )
	if (zb.ROUND_START or 0) + 20 > CurTime() then
		return false
	end
end
