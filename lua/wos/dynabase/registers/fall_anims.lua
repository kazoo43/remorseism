 wOS.DynaBase:RegisterSource({
        Name = "Ram Fall Animation",
        Type =  WOS_DYNABASE.EXTENSION,
        Shared = "models/ram/fall.mdl"
    })

    hook.Add( "PreLoadAnimations", "wOS.DynaBase.Ram", function( gender )
        if gender != WOS_DYNABASE.SHARED then return end
        IncludeModel( "models/ram/fall.mdl" )
    end )
