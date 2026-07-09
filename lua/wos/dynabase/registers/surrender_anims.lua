if not (wOS and wOS.DynaBase and WOS_DYNABASE) then return end
if wOS.DynaBase._zshSurrenderRegistered then return end
wOS.DynaBase._zshSurrenderRegistered = true
wOS.DynaBase:RegisterSource({
    Name = "Surrender Animation",
    Type =  WOS_DYNABASE.REANIMATION,
    Male = "models/surrender_anim/m_surrender.mdl",
    Female = "models/surrender_anim/f_surrender.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountL4D", function( gender )
    if gender == WOS_DYNABASE.MALE then
        IncludeModel( "models/surrender_anim/m_surrender.mdl" )
    elseif gender == WOS_DYNABASE.FEMALE then
        IncludeModel( "models/surrender_anim/f_surrender.mdl" )
    end
end )
