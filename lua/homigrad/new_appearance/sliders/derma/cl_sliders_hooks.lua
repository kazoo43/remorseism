if SERVER then return end

hg = hg or {}
hg.Appearance = hg.Appearance or {}

local APmodule = hg.Appearance
APmodule.Sliders = APmodule.Sliders or {}

if APmodule.Sliders.__HooksLoaded then
    hook.Remove("HG_AppearanceMenuReady", "HG.Appearance.SlidersAttachReady")
    timer.Remove("HG.Appearance.SlidersAttachFallback")
end
APmodule.Sliders.__HooksLoaded = true

local function AttachToPanel(panel)
    if not IsValid(panel) then return false end

    APmodule.Sliders.AttachScaleBlock(panel)
    APmodule.Sliders.RefreshScaleBlock(panel)

    return IsValid(panel.__HGAppearanceScalePanel)
end

hook.Add("HG_AppearanceMenuReady", "HG.Appearance.SlidersAttachReady", function(panel)
    AttachToPanel(panel)
end)

timer.Create("HG.Appearance.SlidersAttachFallback", 0.25, 20, function()
    if not IsValid(zpan) then return end

    if AttachToPanel(zpan) then
        timer.Remove("HG.Appearance.SlidersAttachFallback")
    end
end)
