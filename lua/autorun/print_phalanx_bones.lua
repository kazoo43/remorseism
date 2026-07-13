if CLIENT then
concommand.Add("print_phalanx_bones", function()
    local models = {
        "models/weapons/nmrih/items/phalanx/v_item_phalanx.mdl",
        "models/weapons/nmrih/items/phalanx/w_phalanx.mdl",
    }

    for _, modelPath in ipairs(models) do
        print("=== " .. modelPath .. " ===")
        local m = ClientsideModel(modelPath)
        if IsValid(m) then
            m:SetupBones()
            local count = m:GetBoneCount()
            print("Bone count: " .. tostring(count))
            for i = 0, count - 1 do
                print(i, m:GetBoneName(i))
            end
            m:Remove()
        else
            print("FAILED TO LOAD")
        end
    end
end)
end
