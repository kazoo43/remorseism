if CLIENT then
    local isMenuOpen = nil
    zb.availableModes = zb.availableModes or {}
    local availableModes = zb.availableModes
    
    zb.RoundList = zb.RoundList or {}
    zb.nextround = zb.nextround or nil
    local queuePanelInstance = nil 
    local selectedModes = {}

    net.Receive("ZB_SendModesInfo", function()
        zb.availableModes = net.ReadTable()
    end)
    
    net.Receive("ZB_SendRoundList", function()
        zb.RoundList = net.ReadTable()
        zb.nextround = net.ReadString()
        table.insert(zb.RoundList, 1, zb.nextround)
        zb.nextround = nil
        if IsValid(queuePanelInstance) then
            queuePanelInstance:QueueUpdate()
        end
    end)
    
    net.Receive("ZB_NotifyRoundListChange", function()
        local playerName = net.ReadString()
        
        chat.AddText(Color(180, 180, 255), playerName, Color(255, 255, 255), " has modified the game mode queue")
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end)

    local function StyleElement(element, bgColor)
        bgColor = bgColor or Color(40, 40, 40, 200)
        
        element.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            if self:IsHovered() and self.Selectable then
                draw.RoundedBox(6, 1, 1, w-2, h-2, Color(60, 60, 60, 100))
                surface.SetDrawColor(255, 165, 0, 150)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
            
            if self.Selected then
                surface.SetDrawColor(0, 255, 0, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end
    end
    
    local function CreateModeItem(parent, mode, queue, index)
        local modePanel = vgui.Create("DPanel", parent)
        modePanel:SetTall(40)
        modePanel:Dock(TOP)
        modePanel:DockMargin(5, 2, 5, 2)
        modePanel.Mode = mode
        modePanel.Index = index 
        modePanel.Selectable = true
        modePanel.Selected = selectedModes[mode.key] or false
        
        StyleElement(modePanel, Color(50, 50, 50, 200))
        
        local title = vgui.Create("DLabel", modePanel)
        title:SetFont("DermaDefaultBold")
        title:SetText(mode.name)
        title:SetTextColor(Color(255, 255, 255))
        title:Dock(LEFT)
        title:DockMargin(10, 0, 0, 0)
        title:SizeToContents()
        
        if queue then
            local posLabel = vgui.Create("DLabel", modePanel)
            posLabel:SetFont("DermaDefault")
            posLabel:SetText("#" .. index)
            posLabel:SetTextColor(Color(180, 180, 180))
            posLabel:Dock(LEFT)
            posLabel:DockMargin(5, 0, 0, 0)
            posLabel:SizeToContents()
            
            local upBtn = vgui.Create("DButton", modePanel)
            upBtn:SetSize(24, 24)
            upBtn:Dock(RIGHT)
            upBtn:DockMargin(2, 8, 5, 8)
            upBtn:SetText("▲")
            upBtn.DoClick = function()
                if index > 1 then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index - 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false) 
                    net.SendToServer()*/
                end
            end
            
            local downBtn = vgui.Create("DButton", modePanel)
            downBtn:SetSize(24, 24)
            downBtn:Dock(RIGHT)
            downBtn:DockMargin(2, 8, 2, 8)
            downBtn:SetText("▼")
            downBtn.DoClick = function()
                if index < #zb.RoundList then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index + 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false)
                    net.SendToServer()*/
                end
            end
            
            local removeBtn = vgui.Create("DButton", modePanel)
            removeBtn:SetSize(24, 24)
            removeBtn:Dock(RIGHT)
            removeBtn:DockMargin(2, 8, 2, 8)
            removeBtn:SetText("✕")
            removeBtn.DoClick = function()
                table.remove(zb.RoundList, index)
                queue:QueueUpdate()

                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
            end
        else

            modePanel.OnMousePressed = function()
                modePanel.Selected = not modePanel.Selected
                selectedModes[mode.key] = modePanel.Selected
                
                if modePanel.Selected then
                    surface.PlaySound("buttons/button9.wav")
                else
                    surface.PlaySound("buttons/button17.wav")
                end
            end
        end
        
        return modePanel
    end
    
    local function CreateQueuePanel(frame)
        local queuePanel = vgui.Create("DPanel", frame)
        queuePanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        queuePanel:Dock(RIGHT)
        queuePanel:DockMargin(5, 5, 5, 5)
        StyleElement(queuePanel, Color(30, 30, 30, 200))
        
        queuePanelInstance = queuePanel
        
        local titleLabel = vgui.Create("DLabel", queuePanel)
        titleLabel:SetText("Game Mode Queue")
        titleLabel:SetFont("DermaLarge")
        titleLabel:SetTextColor(Color(255, 200, 0))
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local queueScroll = vgui.Create("DScrollPanel", queuePanel)
        queueScroll:Dock(FILL)
        queueScroll:DockMargin(5, 5, 5, 5)
        
        local saveBtn = vgui.Create("DButton", queuePanel)
        saveBtn:SetText("Apply Queue")
        saveBtn:Dock(BOTTOM)
        saveBtn:DockMargin(5, 5, 5, 5)
        saveBtn:SetTall(30)
        saveBtn.DoClick = function()
            //if #zb.RoundList > 0 then
                local tbl = table.Copy(zb.RoundList)
                //table.insert(tbl, 1, zb.nextround)
                net.Start("ZB_UpdateRoundList")
                    net.WriteTable(tbl)
                    net.WriteBool(true)
                net.SendToServer()
                
                chat.AddText(Color(0, 255, 0), "Game mode queue has been set!")
            //else
                //chat.AddText(Color(255, 0, 0), "Game mode queue is empty!")
            //end
        end
        
        local clearBtn = vgui.Create("DButton", queuePanel)
        clearBtn:SetText("Clear Queue")
        clearBtn:Dock(BOTTOM)
        clearBtn:DockMargin(5, 5, 5, 5)
        clearBtn:SetTall(30)
        clearBtn.DoClick = function()
            zb.RoundList = {}
            queuePanel:QueueUpdate()
            
            /*net.Start("ZB_UpdateRoundList")
                net.WriteTable({})
                net.WriteBool(false)
            net.SendToServer()*/
            
            chat.AddText(Color(255, 165, 0), "Game mode queue cleared!")
        end
        
        function queuePanel:QueueUpdate()
            queueScroll:Clear()
            
            if zb.nextround and zb.nextround ~= "" then
                local nextRoundLabel = vgui.Create("DLabel", queueScroll)
                nextRoundLabel:SetText("Next Mode: " .. zb.nextround)
                nextRoundLabel:SetFont("DermaDefaultBold")
                nextRoundLabel:SetTextColor(Color(100, 255, 100))
                nextRoundLabel:Dock(TOP)
                nextRoundLabel:DockMargin(5, 0, 0, 10)
                nextRoundLabel:SizeToContents()
            end
            
            for idx, modeKey in ipairs(zb.RoundList) do
                local mode = nil
                
                for _, availableMode in ipairs(zb.availableModes) do
                    if availableMode.key == modeKey then
                        mode = availableMode
                        break
                    end
                end
                
                if not mode then
                    mode = {key = modeKey, name = modeKey}
                end
                
                CreateModeItem(queueScroll, mode, queuePanel, idx)
            end
        end
        
        queuePanel:QueueUpdate()
        return queuePanel
    end

    local function OpenModeSelection(command)
        local frame = vgui.Create("ZFrame")
        frame:SetSize(700, 500)
        frame:Center()
        frame:SetTitle("Game Mode Manager")
        frame:MakePopup()
        
        selectedModes = {}
        
        local queuePanel = CreateQueuePanel(frame)
        
        local leftPanel = vgui.Create("DPanel", frame)
        leftPanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        leftPanel:Dock(LEFT)
        leftPanel:DockMargin(5, 5, 5, 5)
        StyleElement(leftPanel, Color(30, 30, 30, 200))
        
        local titleLabel = vgui.Create("DLabel", leftPanel)
        titleLabel:SetText("Available Game Modes")
        titleLabel:SetFont("DermaLarge")
        titleLabel:SetTextColor(Color(255, 200, 0))
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local searchBar = vgui.Create("DTextEntry", leftPanel)
        searchBar:SetPlaceholderText("Search game modes...")
        searchBar:Dock(TOP)
        searchBar:DockMargin(5, 5, 5, 5)
        searchBar:SetTall(25)
        
        local dscroll = vgui.Create("DScrollPanel", leftPanel)
        dscroll:Dock(FILL)
        dscroll:DockMargin(5, 5, 5, 5)
        
        local modeItems = {}
        
        local function UpdateSearch(filter)
            filter = filter:lower()
            
            for _, item in ipairs(modeItems) do
                local visible = filter == "" or string.find(item.Mode.name:lower(), filter)
                item:SetVisible(visible)
            end
            
            dscroll:InvalidateLayout()
        end
        
        searchBar.OnChange = function(self)
            UpdateSearch(self:GetValue())
        end
        
        local allowedModes = {
            ["tdm"] = true,
            ["cstrike"] = true,
            ["hmcd"] = true,
            ["hl2dm"] = true,
            ["riot"] = true,
            ["gwars"] = true,
            ["criresp"] = true,
        }
        
        for i, mode in SortedPairsByMemberValue(zb.availableModes,"canlaunch",true) do
            if !LocalPlayer():IsSuperAdmin() and !allowedModes[mode.key] then continue end
            
            local modeBtn = CreateModeItem(dscroll, mode)
            table.insert(modeItems, modeBtn)
            
            modeBtn:SetCursor("hand")
            modeBtn:SetTooltip("Click to select/unselect mode")
            
            local inQueue = false
            for _, queuedModeKey in ipairs(zb.RoundList) do
                if queuedModeKey == mode.key then
                    inQueue = true
                    break
                end
            end

            local indicator = vgui.Create("DPanel", modeBtn)
            indicator:SetSize(16, 7)
            indicator:SetPos(8, 4)
            indicator.IndiColor = Color(0, 0, 0, 0)
            indicator.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, indicator.IndiColor)
            end

            if mode.canlaunch == 1 then
                indicator.IndiColor = Color(0,255,34)
                indicator:SetTooltip("This mode can launch")
            end

            if inQueue then
                indicator.IndiColor = Color(255, 155, 0, 255)
                indicator:SetTooltip("This mode is already in queue")
            end
     
            if mode.canlaunch == 0 then
                indicator.IndiColor = Color(255,0,0,255)
                indicator:SetTooltip("This mode can't launch")
            end
            
            if command == "setmode" or command == "setforcemode" then
                local selectBtn = vgui.Create("DButton", modeBtn)
                selectBtn:SetSize(80, 26)
                selectBtn:Dock(RIGHT)
                selectBtn:DockMargin(5, 7, 5, 7)
                selectBtn:SetText("Select")
                selectBtn.DoClick = function()
                    net.Start("AdminSetGameMode")
                    net.WriteString(command)
                    net.WriteString(mode.key)
                    net.WriteBool(false) 
                    net.SendToServer()
                    frame:Close()
                end
            end
        end
        

        local batchPanel = vgui.Create("DPanel", leftPanel)
        batchPanel:Dock(BOTTOM)
        batchPanel:DockMargin(5, 5, 5, 5)
        batchPanel:SetTall(80)
        StyleElement(batchPanel, Color(40, 40, 40, 200))
        
        local batchTitle = vgui.Create("DLabel", batchPanel)
        batchTitle:SetText("Batch Operations")
        batchTitle:SetFont("DermaDefaultBold")
        batchTitle:SetTextColor(Color(255, 255, 255))
        batchTitle:Dock(TOP)
        batchTitle:DockMargin(0, 5, 0, 5)
        batchTitle:SetContentAlignment(5)
        
        local addToQueueBtn = vgui.Create("DButton", batchPanel)
        addToQueueBtn:SetText("Add Selected to Beginning of Queue")
        addToQueueBtn:Dock(TOP)
        addToQueueBtn:DockMargin(5, 0, 5, 5)
        addToQueueBtn:SetTall(26)
        addToQueueBtn.DoClick = function()
            local selectedCount = 0
            
            local selectedKeys = {}
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(selectedKeys, 1, key) 
                    selectedCount = selectedCount + 1
                end
            end
            
            for i = 1, #selectedKeys do
                table.insert(zb.RoundList, 1, selectedKeys[i])
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "Added " .. selectedCount .. " modes to beginning of queue!")
                
                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "No modes selected!")
            end
        end
        
        local addToEndBtn = vgui.Create("DButton", batchPanel)
        addToEndBtn:SetText("Add Selected to End of Queue")
        addToEndBtn:Dock(TOP)
        addToEndBtn:DockMargin(5, 0, 5, 0)
        addToEndBtn:SetTall(26)
        addToEndBtn.DoClick = function()
            local selectedCount = 0
            
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(zb.RoundList, key)
                    selectedCount = selectedCount + 1
                end
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "Added " .. selectedCount .. " modes to end of queue!")
                

                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "No modes selected!")
            end
        end
        
        local refreshBtn = vgui.Create("DButton", leftPanel)
        refreshBtn:SetText("Refresh Data")
        refreshBtn:Dock(BOTTOM)
        refreshBtn:DockMargin(5, 5, 5, 5)
        refreshBtn:SetTall(30)
        refreshBtn.DoClick = function()
            net.Start("ZB_RequestRoundList")
            net.SendToServer()
        end
        
        timer.Create("QueueAutoRefresh", 5, 0, function()
            if IsValid(frame) then
                //net.Start("ZB_RequestRoundList")
                //net.SendToServer()
            else
                timer.Remove("QueueAutoRefresh")
            end
        end)
        
        frame.OnClose = function()
            timer.Remove("QueueAutoRefresh")
            queuePanelInstance = nil
        end
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end

    local statsPanelInstance = nil
    local adminStatsRows = {}

    local adminStatsChunks = {}

    net.Receive("ZB_AdminStatsSend", function()
        local total = net.ReadUInt(16)
        local chunks = net.ReadUInt(16)
        local index = net.ReadUInt(16)
        local json = net.ReadString()
        local part = util.JSONToTable(json) or {}

        adminStatsChunks[index] = part

        for i = 1, chunks do
            if not adminStatsChunks[i] then return end
        end

        adminStatsRows = {}
        for i = 1, chunks do
            for _, row in ipairs(adminStatsChunks[i]) do
                adminStatsRows[#adminStatsRows + 1] = row
            end
        end
        adminStatsChunks = {}

        if IsValid(statsPanelInstance) and statsPanelInstance.RefreshRows then
            statsPanelInstance:RefreshRows()
        end
    end)

    net.Receive("ZB_AdminStatsSaveResult", function()
        local ok = net.ReadBool()
        local message = net.ReadString()

        chat.AddText(ok and Color(0, 255, 0) or Color(255, 80, 80), message)
    end)

    local function OpenPlayerStatsMenu()
        if not LocalPlayer():IsSuperAdmin() then return end
        if IsValid(statsPanelInstance) then return end

        local frame = vgui.Create("ZFrame")
        statsPanelInstance = frame
        frame:SetSize(900, 560)
        frame:Center()
        frame:SetTitle("Player SQL Stats")
        frame:MakePopup()

        local topPanel = vgui.Create("DPanel", frame)
        topPanel:Dock(TOP)
        topPanel:SetTall(35)
        topPanel:DockMargin(5, 5, 5, 5)

        local search = vgui.Create("DTextEntry", topPanel)
        search:Dock(FILL)
        search:SetPlaceholderText("Search name or SteamID64")

        local refreshBtn = vgui.Create("DButton", topPanel)
        refreshBtn:Dock(RIGHT)
        refreshBtn:SetWide(100)
        refreshBtn:SetText("Refresh")
        StyleElement(refreshBtn)

        local leftPanel = vgui.Create("DPanel", frame)
        leftPanel:Dock(LEFT)
        leftPanel:SetWide(350)
        leftPanel:DockMargin(5, 0, 5, 5)

        local list = vgui.Create("DListView", leftPanel)
        list:Dock(FILL)
        list:AddColumn("Player")
        list:AddColumn("SteamID64")
        list:AddColumn("Status")

        local rightPanel = vgui.Create("DScrollPanel", frame)
        rightPanel:Dock(FILL)
        rightPanel:DockMargin(0, 0, 5, 5)

        local selectedRow
        local entries = {}
        local achievementEntries = {}

        local function AddEntry(parent, label, key, value)
            local row = vgui.Create("DPanel", parent)
            row:Dock(TOP)
            row:SetTall(28)
            row:DockMargin(0, 0, 0, 4)

            local title = vgui.Create("DLabel", row)
            title:Dock(LEFT)
            title:SetWide(110)
            title:SetText(label)
            title:SetTextColor(Color(255, 255, 255))

            local entry = vgui.Create("DTextEntry", row)
            entry:Dock(FILL)
            entry:SetText(tostring(value or 0))

            entries[key] = entry
        end

        local function AddAchievementEntry(parent, key, value)
            local row = vgui.Create("DPanel", parent)
            row:Dock(TOP)
            row:SetTall(28)
            row:DockMargin(0, 0, 0, 4)

            local title = vgui.Create("DLabel", row)
            title:Dock(LEFT)
            title:SetWide(110)
            title:SetText(key)
            title:SetTextColor(Color(255, 255, 255))

            local entry = vgui.Create("DTextEntry", row)
            entry:Dock(FILL)
            entry:SetText(tostring(value or 0))

            achievementEntries[key] = entry
        end

        local function ShowPlayer(row)
            selectedRow = row
            entries = {}
            achievementEntries = {}
            rightPanel:Clear()

            if not row then return end

            local title = vgui.Create("DLabel", rightPanel)
            title:Dock(TOP)
            title:SetTall(32)
            title:SetFont("DermaDefaultBold")
            title:SetText(row.name .. " | " .. row.steamid .. (row.active and " | ACTIVE" or ""))
            title:SetTextColor(Color(255, 255, 255))

            AddEntry(rightPanel, "XP", "experience", row.experience)
            AddEntry(rightPanel, "Skill", "skill", row.skill)
            AddEntry(rightPanel, "Deaths", "deaths", row.deaths)
            AddEntry(rightPanel, "Kills", "kills", row.kills)
            AddEntry(rightPanel, "Suicides", "suicides", row.suicides)
            AddEntry(rightPanel, "Headshots", "headshots", row.headshots)
            AddEntry(rightPanel, "Karma", "karma", row.karma)

            local achTitle = vgui.Create("DLabel", rightPanel)
            achTitle:Dock(TOP)
            achTitle:SetTall(28)
            achTitle:SetFont("DermaDefaultBold")
            achTitle:SetText("Achievements")
            achTitle:SetTextColor(Color(255, 255, 255))

            for key, value in SortedPairs(row.achievements or {}) do
                AddAchievementEntry(rightPanel, key, value)
            end

            local saveBtn = vgui.Create("DButton", rightPanel)
            saveBtn:Dock(TOP)
            saveBtn:SetTall(34)
            saveBtn:DockMargin(0, 8, 0, 0)
            saveBtn:SetText("Save Stats")
            StyleElement(saveBtn)
            saveBtn.DoClick = function()
                if not selectedRow then return end

                local data = {name = selectedRow.name}
                for key, entry in pairs(entries) do
                    data[key] = entry:GetText()
                end

                data.achievements = {}
                for key, entry in pairs(achievementEntries) do
                    data.achievements[key] = entry:GetText()
                end

                net.Start("ZB_AdminStatsSave")
                    net.WriteString(selectedRow.steamid)
                    net.WriteTable(data)
                net.SendToServer()
            end
        end

        function frame:RefreshRows()
            local needle = search:GetText():lower()
            list:Clear()

            for _, row in ipairs(adminStatsRows) do
                local name = tostring(row.name or "Unknown")
                local steamID64 = tostring(row.steamid or "")

                if needle == "" or name:lower():find(needle, 1, true) or steamID64:find(needle, 1, true) then
                    local line = list:AddLine(name, steamID64, row.active and "Online" or "Offline")
                    line.RowData = row
                end
            end
        end

        list.OnRowSelected = function(panel, index, line)
            ShowPlayer(line.RowData)
        end

        search.OnValueChange = function()
            frame:RefreshRows()
        end

        refreshBtn.DoClick = function()
            net.Start("ZB_AdminStatsRequest")
            net.SendToServer()
        end

        frame.OnClose = function()
            statsPanelInstance = nil
        end

        net.Start("ZB_AdminStatsRequest")
        net.SendToServer()
    end

    local function OpenAdminMenu()
        if IsValid(isMenuOpen) then return end

        isMenuOpen = vgui.Create("ZFrame")
        local frame = isMenuOpen
        frame:SetSize(300, 252)
        frame:Center()
        frame:SetTitle("Admin Panel")
        frame:MakePopup()

        local setModeBtn = vgui.Create("DButton", frame)
        setModeBtn:SetText("Set Next Mode")
        setModeBtn:Dock(TOP)
        setModeBtn:DockMargin(5, 10, 5, 2)
        setModeBtn:SetSize(300, 40)
        StyleElement(setModeBtn)
        setModeBtn.DoClick = function()
            OpenModeSelection("setmode") 
        end

        local setForceModeBtn = vgui.Create("DButton", frame)
        setForceModeBtn:SetText("Set Auto Next Mode")
        setForceModeBtn:Dock(TOP)
        setForceModeBtn:DockMargin(5, 2, 5, 2)
        setForceModeBtn:SetSize(300, 40)
        StyleElement(setForceModeBtn)
        setForceModeBtn.DoClick = function()
            OpenModeSelection("setforcemode")
        end
        
        local queueModeBtn = vgui.Create("DButton", frame)
        queueModeBtn:SetText("Manage Game Mode Queue")
        queueModeBtn:Dock(TOP)
        queueModeBtn:DockMargin(5, 2, 5, 2)
        queueModeBtn:SetSize(300, 40)
        StyleElement(queueModeBtn)
        queueModeBtn.DoClick = function()
            OpenModeSelection("queue")
        end

        if LocalPlayer():IsSuperAdmin() then
            local statsBtn = vgui.Create("DButton", frame)
            statsBtn:SetText("Player SQL Stats")
            statsBtn:Dock(TOP)
            statsBtn:DockMargin(5, 2, 5, 2)
            statsBtn:SetSize(300, 40)
            StyleElement(statsBtn)
            statsBtn.DoClick = function()
                OpenPlayerStatsMenu()
            end
        end

        local endRoundBtn = vgui.Create("DButton", frame)
        endRoundBtn:SetText("End Round")
        endRoundBtn:Dock(TOP)
        endRoundBtn:DockMargin(5, 2, 5, 2)
        endRoundBtn:SetSize(300, 40)
        StyleElement(endRoundBtn)
        endRoundBtn.DoClick = function()
			net.Start("AdminEndRound")
			net.SendToServer()
			frame:Close()
        end

        frame.OnClose = function()
            isMenuOpen = false
        end
        frame:InvalidateLayout(true)
        frame:SizeToChildren(false, true)
    end
    

    hook.Add("InitPostEntity", "RequestModeData", function()
        if LocalPlayer():IsAdmin() then
            timer.Simple(2, function()
                net.Start("ZB_RequestRoundList")
                net.SendToServer()
            end)
        end
    end)

    local f6Key = KEY_F6

    hook.Add("PlayerButtonDown", "OpenAdminMenuF6", function(ply, key)
        if key == f6Key and LocalPlayer():IsAdmin() and not IsValid(isMenuOpen) then
            OpenAdminMenu()
        end
    end)
end
