local NET_NAME = "hg_brainfuck_posture_maker"

local models = {
	{name = "Male 09", key = "male09", model = "models/player/group01/male_09.mdl", offset = Vector(0, -24, 42)},
	{name = "Female 06", key = "female06", model = "models/player/group01/female_06.mdl", offset = Vector(0, 24, 42)}
}

local bones = {
	{1, "Spine", "ValveBiped.Bip01_Spine2"},
	{2, "Right Upper Arm", "ValveBiped.Bip01_R_UpperArm"},
	{3, "Left Upper Arm", "ValveBiped.Bip01_L_UpperArm"},
	{4, "Left Forearm", "ValveBiped.Bip01_L_Forearm"},
	{5, "Left Hand", "ValveBiped.Bip01_L_Hand"},
	{6, "Right Forearm", "ValveBiped.Bip01_R_Forearm"},
	{7, "Right Hand", "ValveBiped.Bip01_R_Hand"},
	{8, "Right Thigh", "ValveBiped.Bip01_R_Thigh"},
	{9, "Right Calf", "ValveBiped.Bip01_R_Calf"},
	{10, "Head", "ValveBiped.Bip01_Head1"},
	{11, "Left Thigh", "ValveBiped.Bip01_L_Thigh"},
	{12, "Left Calf", "ValveBiped.Bip01_L_Calf"},
	{13, "Left Foot", "ValveBiped.Bip01_L_Foot"},
	{14, "Right Foot", "ValveBiped.Bip01_R_Foot"}
}

local boneNames = {}
for i = 1, #bones do
	boneNames[bones[i][1]] = bones[i][3]
end

local function roundNumber(value)
	if math.abs(value) < 0.0005 then value = 0 end
	return string.format("%.3f", value)
end

local function vectorString(value)
	return "Vector(" .. roundNumber(value.x) .. ", " .. roundNumber(value.y) .. ", " .. roundNumber(value.z) .. ")"
end

local function angleString(value)
	return "Angle(" .. roundNumber(value.p) .. ", " .. roundNumber(value.y) .. ", " .. roundNumber(value.r) .. ")"
end

local function openPostureMaker()
	if IsValid(hgPostureMaker) then hgPostureMaker:Remove() end

	local frame = vgui.Create("DFrame")
	hgPostureMaker = frame
	frame:SetSize(math.min(ScrW() - 40, 1450), math.min(ScrH() - 40, 900))
	frame:Center()
	frame:SetTitle("Ragdoll ShadowControl Posture Maker")
	frame:SetSizable(true)
	frame:SetDeleteOnClose(true)
	frame:MakePopup()

	local pose = {}
	for i = 1, #bones do
		pose[bones[i][1]] = {pos = Vector(), ang = Angle()}
	end

	local ragdolls = {}
	local selected = 2
	local activeModel = 1
	local updatingControls = false
	local sliders = {}

	local function createRagdoll(definition)
		local rag = ClientsideRagdoll(definition.model)
		if not IsValid(rag) then return end

		rag:SetNoDraw(true)
		rag:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		local reference = rag:GetPhysicsObjectNum(0)
		if not IsValid(reference) then
			rag:Remove()
			return
		end

		local referencePos, referenceAng = reference:GetPos(), reference:GetAngles()
		local targetAng = Angle(referenceAng.p, referenceAng.y + 180, referenceAng.r)
		local base = {}

		for physBone = 0, rag:GetPhysicsObjectCount() - 1 do
			local phys = rag:GetPhysicsObjectNum(physBone)
			if not IsValid(phys) then continue end

			local localPos, localAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), referencePos, referenceAng)
			local worldPos, worldAng = LocalToWorld(localPos, localAng, definition.offset, targetAng)
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
			phys:SetPos(worldPos)
			phys:SetAngles(worldAng)
			base[physBone] = {pos = localPos, ang = localAng}
		end

		return {entity = rag, definition = definition, base = base}
	end

	for i = 1, #models do
		ragdolls[i] = createRagdoll(models[i])
	end

	local function applyPose()
		for i = 1, #ragdolls do
			local data = ragdolls[i]
			if not data or not IsValid(data.entity) then continue end

			local reference = data.entity:GetPhysicsObjectNum(0)
			if not IsValid(reference) then continue end

			for physBone, change in pairs(pose) do
				local phys = data.entity:GetPhysicsObjectNum(physBone)
				local base = data.base[physBone]
				if not IsValid(phys) or not base then continue end

				local localPos = base.pos + change.pos
				local _, localAng = LocalToWorld(vector_origin, change.ang, vector_origin, base.ang)
				local worldPos, worldAng = LocalToWorld(localPos, localAng, reference:GetPos(), reference:GetAngles())
				phys:SetPos(worldPos)
				phys:SetAngles(worldAng)
			end
		end
	end

	local left = vgui.Create("DPanel", frame)
	left:Dock(LEFT)
	left:SetWide(250)
	left:DockMargin(8, 8, 4, 8)

	local boneList = vgui.Create("DListView", left)
	boneList:Dock(FILL)
	boneList:AddColumn("Phys"):SetFixedWidth(42)
	boneList:AddColumn("Limb")

	for i = 1, #bones do
		local line = boneList:AddLine(bones[i][1], bones[i][2])
		line.physBone = bones[i][1]
	end

	local right = vgui.Create("DPanel", frame)
	right:Dock(RIGHT)
	right:SetWide(320)
	right:DockMargin(4, 8, 8, 8)

	local selectedLabel = vgui.Create("DLabel", right)
	selectedLabel:Dock(TOP)
	selectedLabel:SetTall(48)
	selectedLabel:SetFont("DermaDefaultBold")
	selectedLabel:SetContentAlignment(5)

	local function refreshControls()
		local change = pose[selected]
		if not change then return end

		updatingControls = true
		sliders.posX:SetValue(change.pos.x)
		sliders.posY:SetValue(change.pos.y)
		sliders.posZ:SetValue(change.pos.z)
		sliders.angP:SetValue(change.ang.p)
		sliders.angY:SetValue(change.ang.y)
		sliders.angR:SetValue(change.ang.r)
		updatingControls = false
		selectedLabel:SetText(models[activeModel].name .. "\n" .. (boneNames[selected] or "Unknown") .. " [" .. selected .. "]")
	end

	local function addSlider(label, minimum, maximum, decimals, changed)
		local slider = vgui.Create("DNumSlider", right)
		slider:Dock(TOP)
		slider:SetTall(40)
		slider:SetText(label)
		slider:SetMinMax(minimum, maximum)
		slider:SetDecimals(decimals)
		slider.OnValueChanged = function(_, value)
			if updatingControls or not pose[selected] then return end
			changed(pose[selected], tonumber(value) or 0)
			applyPose()
		end
		return slider
	end

	sliders.posX = addSlider("Position X", -60, 60, 2, function(change, value) change.pos.x = value end)
	sliders.posY = addSlider("Position Y", -60, 60, 2, function(change, value) change.pos.y = value end)
	sliders.posZ = addSlider("Position Z", -60, 60, 2, function(change, value) change.pos.z = value end)
	sliders.angP = addSlider("Angle Pitch", -180, 180, 1, function(change, value) change.ang.p = value end)
	sliders.angY = addSlider("Angle Yaw", -180, 180, 1, function(change, value) change.ang.y = value end)
	sliders.angR = addSlider("Angle Roll", -180, 180, 1, function(change, value) change.ang.r = value end)

	local help = vgui.Create("DLabel", right)
	help:Dock(TOP)
	help:SetTall(72)
	help:SetWrap(true)
	help:SetContentAlignment(5)
	help:SetText("Left-drag moves a limb, right-drag rotates it, middle-drag rotates the camera, and the wheel moves depth. Hold Shift and use the wheel to zoom.")

	local resetSelected = vgui.Create("DButton", right)
	resetSelected:Dock(TOP)
	resetSelected:SetTall(34)
	resetSelected:SetText("Reset Selected Limb")
	resetSelected.DoClick = function()
		pose[selected] = {pos = Vector(), ang = Angle()}
		applyPose()
		refreshControls()
	end

	local resetAll = vgui.Create("DButton", right)
	resetAll:Dock(TOP)
	resetAll:SetTall(34)
	resetAll:SetText("Reset Entire Pose")
	resetAll.DoClick = function()
		for i = 1, #bones do
			pose[bones[i][1]] = {pos = Vector(), ang = Angle()}
		end
		applyPose()
		refreshControls()
	end

	local copy = vgui.Create("DButton", right)
	copy:Dock(BOTTOM)
	copy:SetTall(46)
	copy:SetText("Copy Offsets")

	local viewport = vgui.Create("DPanel", frame)
	viewport:Dock(FILL)
	viewport:DockMargin(4, 8, 4, 8)
	viewport:SetMouseInputEnabled(true)

	local cameraTarget = Vector(0, 0, 40)
	local cameraYaw = 0
	local cameraPitch = 3
	local cameraDistance = 145
	local cameraFov = 42
	local dragMode
	local lastMouseX, lastMouseY

	local function cameraPosition()
		return cameraTarget + Angle(cameraPitch, cameraYaw, 0):Forward() * cameraDistance
	end

	local function cameraAngles()
		return (cameraTarget - cameraPosition()):Angle()
	end

	local function selectFromMouse()
		local mouseX, mouseY = viewport:CursorPos()
		local width, height = viewport:GetSize()
		local angles = cameraAngles()
		local direction = util.AimVector(angles, cameraFov, mouseX, mouseY, width, height)
		local cameraPos = cameraPosition()
		local bestDistance
		local bestBone
		local bestModel

		for modelIndex = 1, #ragdolls do
			local data = ragdolls[modelIndex]
			if not data or not IsValid(data.entity) then continue end

			for i = 1, #bones do
				local physBone = bones[i][1]
				local phys = data.entity:GetPhysicsObjectNum(physBone)
				if not IsValid(phys) then continue end

				local along = (phys:GetPos() - cameraPos):Dot(direction)
				if along <= 0 then continue end

				local distance = phys:GetPos():DistToSqr(cameraPos + direction * along)
				local radius = 3.5 + along * 0.008
				if distance <= radius * radius and (not bestDistance or distance < bestDistance) then
					bestDistance = distance
					bestBone = physBone
					bestModel = modelIndex
				end
			end
		end

		if not bestBone then return false end
		selected = bestBone
		activeModel = bestModel
		refreshControls()
		return true
	end

	function viewport:Paint(width, height)
		surface.SetDrawColor(18, 20, 24, 255)
		surface.DrawRect(0, 0, width, height)

		local screenX, screenY = self:LocalToScreen(0, 0)
		local angles = cameraAngles()
		cam.Start3D(cameraPosition(), angles, cameraFov, screenX, screenY, width, height, 1, 4096)
			render.SuppressEngineLighting(true)
			render.SetColorModulation(1, 1, 1)

			for grid = -60, 60, 10 do
				render.DrawLine(Vector(-45, grid, 2), Vector(45, grid, 2), Color(45, 48, 54), true)
				render.DrawLine(Vector(grid, -70, 2), Vector(grid, 70, 2), Color(45, 48, 54), true)
			end

			for modelIndex = 1, #ragdolls do
				local data = ragdolls[modelIndex]
				if not data or not IsValid(data.entity) then continue end

				data.entity:DrawModel()

				for i = 1, #bones do
					local physBone = bones[i][1]
					local phys = data.entity:GetPhysicsObjectNum(physBone)
					if not IsValid(phys) then continue end

					local isSelected = selected == physBone and activeModel == modelIndex
					render.DrawWireframeSphere(phys:GetPos(), isSelected and 2.8 or 1.1, 8, 8, isSelected and Color(255, 190, 40) or Color(80, 180, 255), true)
				end
			end

			local active = ragdolls[activeModel]
			if active and IsValid(active.entity) then
				local phys = active.entity:GetPhysicsObjectNum(selected)
				if IsValid(phys) then
					local position, anglesSelected = phys:GetPos(), phys:GetAngles()
					render.DrawLine(position, position + anglesSelected:Forward() * 9, Color(255, 70, 70), true)
					render.DrawLine(position, position + anglesSelected:Right() * 9, Color(70, 255, 70), true)
					render.DrawLine(position, position + anglesSelected:Up() * 9, Color(70, 130, 255), true)
				end
			end

			render.SuppressEngineLighting(false)
		cam.End3D()
	end

	function viewport:OnMousePressed(code)
		if code == MOUSE_MIDDLE then
			dragMode = "camera"
			lastMouseX, lastMouseY = gui.MouseX(), gui.MouseY()
			self:MouseCapture(true)
			return
		end

		if code ~= MOUSE_LEFT and code ~= MOUSE_RIGHT then return end
		if not selectFromMouse() then return end

		dragMode = code == MOUSE_LEFT and "position" or "angle"
		lastMouseX, lastMouseY = gui.MouseX(), gui.MouseY()
		self:MouseCapture(true)
	end

	function viewport:OnMouseReleased(code)
		if code ~= MOUSE_LEFT and code ~= MOUSE_RIGHT and code ~= MOUSE_MIDDLE then return end
		dragMode = nil
		self:MouseCapture(false)
	end

	function viewport:OnMouseWheeled(delta)
		if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then
			cameraDistance = math.Clamp(cameraDistance - delta * 8, 70, 260)
			return true
		end

		if not pose[selected] then return false end

		local active = ragdolls[activeModel]
		if not active or not IsValid(active.entity) then return false end
		local reference = active.entity:GetPhysicsObjectNum(0)
		if not IsValid(reference) then return false end

		local worldDelta = cameraAngles():Forward() * delta * 2
		local localDelta = WorldToLocal(worldDelta, angle_zero, vector_origin, reference:GetAngles())
		pose[selected].pos = pose[selected].pos + localDelta
		applyPose()
		refreshControls()
		return true
	end

	function viewport:Think()
		if not dragMode or not pose[selected] then return end

		local mouseX, mouseY = gui.MouseX(), gui.MouseY()
		local deltaX, deltaY = mouseX - lastMouseX, mouseY - lastMouseY
		lastMouseX, lastMouseY = mouseX, mouseY
		if deltaX == 0 and deltaY == 0 then return end

		if dragMode == "camera" then
			cameraPitch = math.Clamp(cameraPitch + deltaY * 0.4, -80, 80)
			cameraYaw = math.NormalizeAngle(cameraYaw - deltaX * 0.4)
			return
		end

		local change = pose[selected]
		if dragMode == "angle" then
			change.ang.p = math.NormalizeAngle(change.ang.p - deltaY * 0.5)
			change.ang.y = math.NormalizeAngle(change.ang.y + deltaX * 0.5)
		else
			local active = ragdolls[activeModel]
			if not active or not IsValid(active.entity) then return end
			local reference = active.entity:GetPhysicsObjectNum(0)
			if not IsValid(reference) then return end

			local angles = cameraAngles()
			local worldDelta = angles:Right() * deltaX * 0.12 - angles:Up() * deltaY * 0.12
			local localDelta = WorldToLocal(worldDelta, angle_zero, vector_origin, reference:GetAngles())
			change.pos = change.pos + localDelta
		end

		applyPose()
		refreshControls()
	end

	boneList.OnRowSelected = function(_, _, line)
		selected = line.physBone
		refreshControls()
	end

	copy.DoClick = function()
		local output = {
			"local postureOffsets = {",
			"\treference = 0,"
		}

		for modelIndex = 1, #ragdolls do
			local data = ragdolls[modelIndex]
			if not data or not IsValid(data.entity) then continue end

			local reference = data.entity:GetPhysicsObjectNum(0)
			if not IsValid(reference) then continue end

			output[#output + 1] = "\t[\"" .. data.definition.key .. "\"] = {"
			for i = 1, #bones do
				local physBone = bones[i][1]
				local phys = data.entity:GetPhysicsObjectNum(physBone)
				if not IsValid(phys) then continue end

				local localPos, localAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), reference:GetPos(), reference:GetAngles())
				output[#output + 1] = "\t\t[" .. physBone .. "] = {bone = \"" .. boneNames[physBone] .. "\", pos = " .. vectorString(localPos) .. ", ang = " .. angleString(localAng) .. "},"
			end
			output[#output + 1] = "\t},"
		end

		output[#output + 1] = "}"
		SetClipboardText(table.concat(output, "\n"))
		notification.AddLegacy("ShadowControl posture offsets copied.", NOTIFY_GENERIC, 4)
		surface.PlaySound("buttons/button15.wav")
	end

	frame.OnRemove = function()
		for i = 1, #ragdolls do
			if ragdolls[i] and IsValid(ragdolls[i].entity) then
				ragdolls[i].entity:Remove()
			end
		end
		if hgPostureMaker == frame then hgPostureMaker = nil end
	end

	applyPose()
	refreshControls()
	boneList:SelectFirstItem()
end

net.Receive(NET_NAME, openPostureMaker)
