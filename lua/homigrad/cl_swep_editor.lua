local cv_edit = CreateClientConVar("hg_swep_edit", "0", true, false, "Enable SWEP position editor overlay")
local cv_step = CreateClientConVar("hg_swep_edit_step", "0.5", true, false, "Adjustment step per tick")
local cv_group = CreateClientConVar("hg_swep_edit_group", "1", true, false, "Property group: 1=HoldPos/Ang, 2=HandOffset, 3=Ragdoll")

local function MakeCV(name, def)
	return CreateClientConVar("hg_swep_edit_" .. name, tostring(def), true, false)
end

local cv = {
	px = MakeCV("px", 0), py = MakeCV("py", 0), pz = MakeCV("pz", 0),
	ap = MakeCV("ap", 0), ay = MakeCV("ay", 0), ar = MakeCV("ar", 0),
	hpx = MakeCV("hpx", 0), hpy = MakeCV("hpy", 0), hpz = MakeCV("hpz", 0),
	hap = MakeCV("hap", 0), hay = MakeCV("hay", 0), har = MakeCV("har", 0),
	rpx = MakeCV("rpx", 0), rpy = MakeCV("rpy", 0), rpz = MakeCV("rpz", 0),
	rap = MakeCV("rap", 0), ray = MakeCV("ray", 0), rar = MakeCV("rar", 0),
}

local groups = {
	{
		name = "HoldPos / HoldAng",
		axes = {
			{ cv = cv.px, name = "Pos X", convar = "hg_swep_edit_px" },
			{ cv = cv.py, name = "Pos Y", convar = "hg_swep_edit_py" },
			{ cv = cv.pz, name = "Pos Z", convar = "hg_swep_edit_pz" },
			{ cv = cv.ap, name = "Ang P", convar = "hg_swep_edit_ap" },
			{ cv = cv.ay, name = "Ang Y", convar = "hg_swep_edit_ay" },
			{ cv = cv.ar, name = "Ang R", convar = "hg_swep_edit_ar" },
		},
	},
	{
		name = "Hand Offset (RH/LH)",
		axes = {
			{ cv = cv.hpx, name = "Hand X", convar = "hg_swep_edit_hpx" },
			{ cv = cv.hpy, name = "Hand Y", convar = "hg_swep_edit_hpy" },
			{ cv = cv.hpz, name = "Hand Z", convar = "hg_swep_edit_hpz" },
			{ cv = cv.hap, name = "Hand P", convar = "hg_swep_edit_hap" },
			{ cv = cv.hay, name = "Hand Y", convar = "hg_swep_edit_hay" },
			{ cv = cv.har, name = "Hand R", convar = "hg_swep_edit_har" },
		},
	},
	{
		name = "Ragdoll (lpos/lang)",
		axes = {
			{ cv = cv.rpx, name = "RD X", convar = "hg_swep_edit_rpx" },
			{ cv = cv.rpy, name = "RD Y", convar = "hg_swep_edit_rpy" },
			{ cv = cv.rpz, name = "RD Z", convar = "hg_swep_edit_rpz" },
			{ cv = cv.rap, name = "RD P", convar = "hg_swep_edit_rap" },
			{ cv = cv.ray, name = "RD Y", convar = "hg_swep_edit_ray" },
			{ cv = cv.rar, name = "RD R", convar = "hg_swep_edit_rar" },
		},
	},
}

local selected = 1

local function GetGroup()
	return groups[math.Clamp(cv_group:GetInt(), 1, #groups)]
end

function hg.SWEPEditor_IsActive()
	return cv_edit:GetBool()
end

function hg.SWEPEditor_Apply(wep)
	if not cv_edit:GetBool() then return end
	wep.HoldPos = Vector(cv.px:GetFloat(), cv.py:GetFloat(), cv.pz:GetFloat())
	wep.HoldAng = Angle(cv.ap:GetFloat(), cv.ay:GetFloat(), cv.ar:GetFloat())
	wep.handPosOffset = Vector(cv.hpx:GetFloat(), cv.hpy:GetFloat(), cv.hpz:GetFloat())
	wep.handAngOffset = Angle(cv.hap:GetFloat(), cv.hay:GetFloat(), cv.har:GetFloat())
	wep.lpos = Vector(cv.rpx:GetFloat(), cv.rpy:GetFloat(), cv.rpz:GetFloat())
	wep.lang = Angle(cv.rap:GetFloat(), cv.ray:GetFloat(), cv.rar:GetFloat())
end

concommand.Add("hg_swep_print", function()
	local g = GetGroup()
	print("=== " .. g.name .. " ===")
	if cv_group:GetInt() == 1 then
		print(string.format("SWEP.HoldPos = Vector(%g, %g, %g)", cv.px:GetFloat(), cv.py:GetFloat(), cv.pz:GetFloat()))
		print(string.format("SWEP.HoldAng = Angle(%g, %g, %g)", cv.ap:GetFloat(), cv.ay:GetFloat(), cv.ar:GetFloat()))
	elseif cv_group:GetInt() == 2 then
		print(string.format("SWEP.handPosOffset = Vector(%g, %g, %g)", cv.hpx:GetFloat(), cv.hpy:GetFloat(), cv.hpz:GetFloat()))
		print(string.format("SWEP.handAngOffset = Angle(%g, %g, %g)", cv.hap:GetFloat(), cv.hay:GetFloat(), cv.har:GetFloat()))
	elseif cv_group:GetInt() == 3 then
		print(string.format("SWEP.lpos = Vector(%g, %g, %g)", cv.rpx:GetFloat(), cv.rpy:GetFloat(), cv.rpz:GetFloat()))
		print(string.format("SWEP.lang = Angle(%g, %g, %g)", cv.rap:GetFloat(), cv.ray:GetFloat(), cv.rar:GetFloat()))
	end
	chat.AddText(Color(100, 255, 100), "Values printed to console (F10)")
end)

concommand.Add("hg_swep_reset", function()
	local g = GetGroup()
	for _, data in ipairs(g.axes) do
		RunConsoleCommand(data.convar, "0")
	end
end)

concommand.Add("hg_swep_group", function(ply, cmd, args)
	local val = tonumber(args[1]) or 1
	RunConsoleCommand("hg_swep_edit_group", tostring(math.Clamp(val, 1, #groups)))
	selected = 1
end)

concommand.Add("hg_swep_next", function()
	local g = GetGroup()
	selected = (selected % #g.axes) + 1
end)

concommand.Add("hg_swep_prev", function()
	local g = GetGroup()
	selected = ((selected - 2) % #g.axes) + 1
end)

concommand.Add("hg_swep_up", function(ply, cmd, args)
	local step = cv_step:GetFloat()
	local dir = tonumber(args[1]) or step
	local data = GetGroup().axes[selected]
	RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() + dir))
end)

concommand.Add("hg_swep_down", function(ply, cmd, args)
	local step = cv_step:GetFloat()
	local dir = tonumber(args[1]) or step
	local data = GetGroup().axes[selected]
	RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() - dir))
end)

hook.Add("PlayerBindPress", "SWEP_Editor_Bind", function(ply, bind, pressed)
	if not cv_edit:GetBool() then return end
	if not pressed then return end

	local g = GetGroup()

	if bind == "invnext" then
		if ply:KeyDown(IN_SPEED) then
			RunConsoleCommand("hg_swep_edit_group", tostring((cv_group:GetInt() % #groups) + 1))
			selected = 1
		else
			selected = (selected % #g.axes) + 1
		end
		return true
	elseif bind == "invprev" then
		if ply:KeyDown(IN_SPEED) then
			RunConsoleCommand("hg_swep_edit_group", tostring(((cv_group:GetInt() - 2) % #groups) + 1))
			selected = 1
		else
			selected = ((selected - 2) % #g.axes) + 1
		end
		return true
	elseif bind == "+attack" then
		local step = cv_step:GetFloat()
		local data = g.axes[selected]
		RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() + step))
		return true
	elseif bind == "+attack2" then
		local step = cv_step:GetFloat()
		local data = g.axes[selected]
		RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() - step))
		return true
	elseif bind == "+use" then
		local step = cv_step:GetFloat() * 5
		local data = g.axes[selected]
		RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() + step))
		return true
	elseif bind == "+reload" then
		local step = cv_step:GetFloat() * 5
		local data = g.axes[selected]
		RunConsoleCommand(data.convar, tostring(data.cv:GetFloat() - step))
		return true
	end
end)

hook.Add("HUDPaint", "SWEP_Editor_HUD", function()
	if not cv_edit:GetBool() then return end

	local scrW, scrH = ScrW(), ScrH()
	local cx, cy = scrW / 2, scrH / 2

	surface.SetDrawColor(255, 255, 0, 180)
	surface.DrawRect(cx - 20, cy - 1, 40, 2)
	surface.DrawRect(cx - 1, cy - 20, 2, 40)

	local g = GetGroup()
	local boxW, boxH = 230, 175
	local bx, by = 20, 20

	draw.RoundedBox(4, bx - 5, by - 5, boxW + 10, boxH + 10, Color(0, 0, 0, 180))
	surface.SetDrawColor(255, 255, 0, 200)
	surface.DrawOutlinedRect(bx - 5, by - 5, boxW + 10, boxH + 10, 1)

	local y = by
	draw.SimpleText("SWEP EDITOR", "DermaDefaultBold", bx + boxW / 2, y, Color(255, 255, 0), TEXT_ALIGN_CENTER)
	y = y + 18

	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) then
		draw.SimpleText(wep:GetClass(), "DermaDefault", bx + boxW / 2, y, Color(200, 200, 200), TEXT_ALIGN_CENTER)
		y = y + 14
	end

	local groupCol = Color(100, 200, 255)
	draw.SimpleText("[" .. cv_group:GetInt() .. "/" .. #groups .. "] " .. g.name, "DermaDefault", bx + boxW / 2, y, groupCol, TEXT_ALIGN_CENTER)
	y = y + 18

	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawRect(bx, y, boxW, 1)
	y = y + 6

	for i, data in ipairs(g.axes) do
		local sel = (i == selected)
		local col = sel and Color(255, 255, 0) or Color(200, 200, 200)
		local prefix = sel and "> " or "  "
		local val = data.cv:GetFloat()
		draw.SimpleText(string.format("%s%s: %g", prefix, data.name, val), "DermaDefault", bx, y, col)
		y = y + 16
	end

	y = y + 4
	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawRect(bx, y, boxW, 1)
	y = y + 6

	draw.SimpleText(string.format("Step: %g", cv_step:GetFloat()), "DermaDefault", bx, y, Color(150, 150, 150))
	y = y + 16
	draw.SimpleText("Scroll = select | LMB = +step", "DermaDefault", bx, y, Color(120, 120, 120))
	y = y + 14
	draw.SimpleText("RMB = -step | E = +5x | R = -5x", "DermaDefault", bx, y, Color(120, 120, 120))
	y = y + 14
	draw.SimpleText("Shift+Scroll = group", "DermaDefault", bx, y, Color(120, 120, 120))
end)

concommand.Add("hg_swep_edit_help", function()
	print("=== SWEP Editor ===")
	print("hg_swep_edit 1              - Enable editor")
	print("hg_swep_edit 0              - Disable editor")
	print("hg_swep_edit_group <1-3>    - Switch property group")
	print("  1 = HoldPos / HoldAng")
	print("  2 = HandOffset (RH/LH)")
	print("  3 = Ragdoll (lpos/lang)")
	print("hg_swep_print               - Print SWEP code for current group")
	print("hg_swep_reset               - Reset current group to 0")
	print("hg_swep_step <value>        - Set step size")
	print("")
	print("In-game (when editor active):")
	print("  Scroll         - Select axis in group")
	print("  Shift+Scroll   - Switch group")
	print("  LMB            - +step")
	print("  RMB            - -step")
	print("  E (use)        - +step*5")
	print("  R (reload)     - -step*5")
end)