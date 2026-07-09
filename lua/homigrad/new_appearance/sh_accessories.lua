hg = hg or {}
local a = Material("mats_jack_gmod_sprites/respirator_vignette.png")
local bandanamat = Material("mats_jack_gmod_sprites/respirator_vignette.png") -- Add this line (use correct path)
hg.Accessories = {
	["none"] = {},

    ["eyeglasses"] = {
        model = "models/captainbigbutt/skeyler/accessories/glasses01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = { Vector(3,-2.9,0), Angle(0,-70,-90), .9},
        fempos = {Vector(2.1,-2.7,0),Angle(0,-70,-90),.8},
        skin = 0,
        norender = true,
        placement = "face",
    },
    
    ["pluv mask"] = {
    model = "models/props/pluvmask.mdl",
    bone = "ValveBiped.Bip01_Head1",
    malepos = {Vector(-6,-1.8,0),Angle(180,-80,-90), 1},
    fempos = {Vector(-6,-1.8,0),Angle(180,-80,-90), 1},
    skin = 0,
    norender = true,
    placement = "head",
   },

   ["black hood with mask"] = {
        model = "models/balaclava_hood/balaclava_hood.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-30,-8.8,0),Angle(0,-75,-90), 1.12},
        fempos = {Vector(-31,-8.8,0),Angle(0,-75,-90), 1.125},
        skin = 0,
        norender = true,
        placement = "head",
    },
    
    ["meowl"] = {
    model = "models/catowl/catowl.mdl",
    bone = "ValveBiped.Bip01_Head1",
    malepos = {Vector(10,0,0),Angle(0,-80,-90), 1},
    fempos = {Vector(-6,-1.8,0),Angle(180,-80,-90), 1},
    skin = 0,
    norender = true,
    placement = "head",
   },
    
  ["long ass glasses"] = {
    model = "models/props/bigglass.mdl",
    bone = "ValveBiped.Bip01_Head1",
    malepos = {Vector(5,-13.5,0),Angle(180,-80,-90), 0.5},
    fempos = {Vector(5,-13.5,0),Angle(180,-80,-90), 0.5},
    skin = 0,
    norender = true,
    placement = "face",
   },
    
    ["bugeye sunglasses"] = {
        model = "models/captainbigbutt/skeyler/accessories/glasses04.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.2,-3.3,0),Angle(0,-70,-90),.9},
        fempos = {Vector(2.2,-3.3,0),Angle(0,-70,-90),.8},
        skin = 0,
        norender = true,
        placement = "face",
    },

    ["aviators"] = {
        model = "models/arctic_nvgs/aviators.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.7,0,0),Angle(0,-80,-90),1},
        fempos = {Vector(0.25,0,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "face",
        vpos = Vector(0,0,0)
    },

    ["nerd glasses"] = {
        model = "models/gmod_tower/klienerglasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-2.2,0),Angle(0,-80,-90),1},
        fempos = {Vector(2.5,-2.5,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "face",
    },

    ["headphones"] = {
        model = "models/gmod_tower/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.6,-1,0),Angle(0,-80,-90),.85},
        fempos = {Vector(2.4,-1,0),Angle(0,-85,-90),.8},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["baseball cap"] = {
        model = "models/gmod_tower/jaseballcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0,0),Angle(0,-75,-90), 1.12},
        fempos = {Vector(4,-0.1,0),Angle(0,-75,-90), 1.125},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["fedora"] = {
        model = "models/captainbigbutt/skeyler/hats/fedora.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.5,-0.2,0),Angle(0,-80,-90), 0.7},
        fempos = {Vector(4.5,-0.2,0),Angle(0,-75,-90), 0.7},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["stetson"] = {
        model = "models/captainbigbutt/skeyler/hats/cowboyhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(6.2,0.6,0),Angle(0,-60,-90), 0.7},
        fempos = {Vector(5.2,0.5,0),Angle(0,-65,-90), 0.65},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["straw hat"] = {
        model = "models/captainbigbutt/skeyler/hats/strawhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.2,-0.4,0),Angle(0,-70,-90), 0.85},
        fempos = {Vector(4.5,-0.5,0),Angle(0,-75,-90), 0.8},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["sun hat"] = {
        model = "models/captainbigbutt/skeyler/hats/sunhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.2,2,0),Angle(0,-90,-90), 0.8},
        fempos = {Vector(3.4,2,0),Angle(0,-90,-90), 0.75},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["bling cap"] = {
        model = "models/captainbigbutt/skeyler/hats/zhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.9,0.1,0),Angle(0,-80,-90), 0.75},
        fempos = {Vector(3.5,0.2,0),Angle(-10,-80,-90), 0.75},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["top hat"] = {
        model = "models/player/items/humans/top_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0,-1.5,0),Angle(0,-80,-90), 1},
        fempos = {Vector(-0.8,-1.8,0),Angle(0,-80,-90), 1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["backpack"] = {
        model = "models/makka12/bag/jag.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-3,0,0),Angle(0,90,90),.75},
        fempos = {Vector(-3,-1,0),Angle(0,90,90),.6},
        skin = 0,
        norender = false,
        placement = "spine2",
    },

    ["backpack hellokitty"] = {
        model = "models/gleb/backpack_pink.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine2",
        vpos = Vector(0,0,0)
    },

    ["kickme sticker"] = {
        model = "models/gleb/kickme.mdl",
        bone = "ValveBiped.Bip01_Pelvis",
        malepos = {Vector(0,4,-6.8),Angle(-75,-90,0),1},
        fempos = {Vector(0,4,-5.8),Angle(-65,-90,0),1},
        skin = 0,
        norender = false,
        placement = "spine2",
        bonemerge = true,
    },

    ["nerd tooths"] = {
        model = "models/gleb/nerd.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.3,-0.4,0),Angle(0,-85,-90),1},
        fempos = {Vector(1.9,-0.8,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "spine",
        bonemerge = true,
    },

    ["purse"] = {
        model = "models/props_c17/BriefCase001a.mdl",
        bone = "ValveBiped.Bip01_Spine1",
        malepos = {Vector(-7,1,7),Angle(0,90,100),.5},
        fempos = {Vector(-7,0,7),Angle(0,90,100),.5},
        skin = 0,
        norender = false,
        placement = "back",
    },
    --CAPS
    ["ZCity cap"] = {
        model = "models/gleb/zcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["gray cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["light gray cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["light gray cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["white cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

    ["green cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.5,0.1),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["cap gta0alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["cap gta1alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 1,
        norender = true,
        placement = "head",
    },

    ["cap gta2alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["cap gta3alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

    ["cap gta4alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["cap gta5alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 5,
        norender = true,
        placement = "head",
    },

    ["cap gta6alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 6,
        norender = true,
        placement = "head",
    },

    ["cap gta7alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 7,
        norender = true,
        placement = "head",
    },

    ["cap gta8alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 8,
        norender = true,
        placement = "head",
    },

    ["cap gta9alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 9,
        norender = true,
        placement = "head",
    },

    ["cap gta10alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 10,
        norender = true,
        placement = "head",
    },

    ["cap gta11alt"] = {
        model = "models/hat02/hat02.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 11,
        norender = true,
        placement = "head",
    },
    
    ["cap gta0"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["cap gta1"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 1,
        norender = true,
        placement = "head",
    },

    ["cap gta2"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["cap gta3"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

    ["cap gta4"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["cap gta5"] = {
        model = "models/hat01/hat01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,0.3,0.1),Angle(0,90,90),1},
        fempos = {Vector(0.3,0.3,0.1),Angle(0,90,90),1},
        skin = 5,
        norender = true,
        placement = "head",
    },

    ["dark green cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 5,
        norender = true,
        placement = "head",
    },

    ["brown cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 6,
        norender = true,
        placement = "head",
    },

    ["blue cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 7,
        norender = true,
        placement = "head",
    },

    ["beanie gta0"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.8,-0.7,0),Angle(180,-90,0),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["beanie gta1"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 1,
        norender = true,
        placement = "head",
    },

        ["beanie gta2"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

        ["beanie gta3"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

        ["beanie gta4"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 4,
        norender = true,
        placement = "head",
    },
    
        ["beanie gta5"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 5,
        norender = true,
        placement = "head",
    },

        ["beanie gta6"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 6,
        norender = true,
        placement = "head",
    },

        ["beanie gta7"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 7,
        norender = true,
        placement = "head",
    },

        ["beanie gta8"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 8,
        norender = true,
        placement = "head",
    },

        ["beanie gta9"] = {
        model = "models/beanie/beanie.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,0,0),Angle(180,-90,0),1},
        fempos = {Vector(-0.5,-0.7,0),Angle(180,-90,0),1},
        skin = 9,
        norender = true,
        placement = "head",
    },
    
    -- FaceMasks

    ["black balaclava"] = {
        model = "models/balaclava/balaclava.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-30,-8.8,0),Angle(0,-75,-90), 1.12},
        fempos = {Vector(-31,-8.8,0),Angle(0,-75,-90), 1.125},
        skin = 0,
        norender = true,
        placement = "face2",
    },


    ["gaiter"] = {
        model = "models/gaiter/gaiter.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-8.3,.15),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8.3,0),Angle(180,105,90),.9},
        skin = 0,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta0"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 0,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta1"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 1,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta2"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 2,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta3"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 3,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta4"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 4,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta5"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 5,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta6"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 6,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta7"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 7,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta8"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 8,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["bandana gta9"] = {
        model = "models/bandana01/bandana01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-26.5,-9,-0.2),Angle(180,105,90),1},
        fempos = {Vector(-24.5,-8,0),Angle(180,105,90),.9},
        skin = 9,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
    },

    ["arctic_balaclava"] = {
        model = "models/d/balaklava/arctic_reference.mdl",
        femmodel = "models/distac/feminine_mask.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1.1},
        fempos = {Vector(-1,-0.8,0),Angle(180,105,90),1.05},
        skin = 0,
        norender = true,
        disallowinapperance = true,
        bonemerge = true,
    },

    ["phoenix_balaclava"] = {
        model = "models/d/balaklava/phoenix_balaclava.mdl",
        femmodel = "models/distac/feminine_mask.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,-0.95,0),Angle(180,100,90),0.95},
        fempos = {Vector(-0.6,-0.6,0),Angle(180,100,90),0.95},
        skin = 0,
        norender = true,
        disallowinapperance = true,
        bonemerge = true,
    },
    ["terrorist_band"] = {
        model = "models/distac/band_team.mdl",
        femmodel = "models/distac/band_team_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,-0.95,0),Angle(180,100,90),0.95},
        fempos = {Vector(-0.6,-0.6,0),Angle(180,100,90),0.95},
        skin = 0,
        disallowinapperance = true,
        bonemerge = true,
        needcoolRender = true,
        flex = true,
    },

    ["chain0"] = {
        model = "models/ls/ls.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-19.2,8.3,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),9},
        skin = 0,
        norender = false,
        placement = "spine"
    },

    ["chain1"] = {
        model = "models/ls/ls.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-19.2,8.3,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),9},
        skin = 1,
        norender = false,
        placement = "spine"
    },

    ["chain2"] = {
        model = "models/teef/teef.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-19,8.3,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),9},
        skin = 1,
        norender = false,
        placement = "spine"
    },
    -- scarfs
    ["white scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 0,
        norender = false,
        hideWhenAim = true,
        placement = "spine"
    },

    ["gray scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 1,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },

    ["black scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 2,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },

    ["blue scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 3,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },

    ["red scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 4,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },

    ["green scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 5,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },

    ["pink scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 6,
        norender = false,
        hideWhenAim = true,
        placement = "spine",
    },
    -- earmuffs
    ["red earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 0,
        norender = true,
        placement = "ears",
    },

    ["green earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 2,
        norender = true,
        placement = "ears",
    },

    ["yellow earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 3,
        norender = true,
        placement = "ears",
    },
    -- fedoras

    ["gray fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["black fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
    },

    ["white fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["beige fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

    ["black/red fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 5,
        norender = true,
        placement = "head",
    },

    ["blue fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 7,
        norender = true,
        placement = "head",
    },
    -- beanies

    ["striped beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["striped beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
    },

    ["periwinkle beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
    },

    ["fuschia beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
    },

    ["white beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,100,90),1},
        skin = 3,
        norender = true,
        placement = "head",
    },

    ["gray beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,100,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },
    -- backpacks
    ["large red backpack"] = {
        model = "models/modified/backpack_1.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5.2,0),Angle(0,80,90),1},
        fempos = {Vector(-8,4,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine2",
    },

    ["large gray backpack"] = {
        model = "models/modified/backpack_1.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5.2,0),Angle(0,80,90),1},
        fempos = {Vector(-8,4,0),Angle(0,80,90),0.9},
        skin = 1,
        norender = false,
        placement = "spine2",
    },

    ["robberybag"] = {
        model = "models/robberybag/robberybag.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag0"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag1"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 1,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag2"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 2,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag3"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 3,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag4"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 4,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag5"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 5,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag6"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 6,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag7"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 7,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag8"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 8,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag9"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 9,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag10"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 10,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag11"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 11,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag12"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 12,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag13"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 13,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag14"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 14,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag15"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 15,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag16"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 16,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag17"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 17,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag18"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 18,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag19"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 19,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag20"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 20,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag21"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 21,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag22"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 22,
        norender = false,
        placement = "spine2",
    },

    ["dufflebag23"] = {
        model = "models/sportbag4/sportbag4.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-17.5,12,2),Angle(0,60,95),1},
        fempos = {Vector(-19,6,0),Angle(0,80,90),0.9},
        skin = 23,
        norender = false,
        placement = "spine2",
    },

    ["medium backpack"] = {
        model = "models/modified/backpack_3.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,4,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine2",
    },

    ["medium gray backpack"] = {
        model = "models/modified/backpack_3.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,4,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 1,
        norender = false,
        placement = "spine2",
    },

    ["monokl"] = {
        model = "models/distac/monokl.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.05,-4.8,-1.3),Angle(180,100,90),1},
        fempos = {Vector(-1,-0.8,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "face",
        vpos = Vector(0,0,69)
    },
    
    ["china hat"] = {
        model = "models/distac/china_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.5,-0.35,0),Angle(180,100,90),1},
        fempos = {Vector(3,-0.8,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        vpos = Vector(0,0,0)
    },

    ["helicopter cap"] = {
        model = "models/distac/cap_helecopterkid.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-70,-13.5,0),Angle(180,100,90),1.1},
        fempos = {Vector(-63,-18.5,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "head",
        vpos = Vector(0,0,69)
    },
    
    ["welding glasses"] = {
        model = "models/distac/glassis_welding glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        vpos = Vector(0,0,69)
    },

    ["big glasses"] = {
        model = "models/distac/big_ahhh_glassis.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },
    
    ["eyeglasses gta0"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta1"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 1,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta2"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 2,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta3"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 3,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta4"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 4,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta5"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 5,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta6"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 6,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta7"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 7,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta8"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 8,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta9"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 9,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta10"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 10,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["eyeglasses gta11"] = {
        model = "models/eyeglasses_03/eyeglasses_03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-0.5,-0.8,0.1),Angle(0,-70,-90),1},
        fempos = {Vector(-0.6,-0.4,0.1),Angle(0,-80,-90),1},
        skin = 11,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses0"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses1"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 1,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses2"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 2,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses3"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 3,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses4"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 4,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses5"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 5,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses6"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 6,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["exclusive glasses7"] = {
        model = "models/exclusive_glasses/exclusive_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 7,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses0"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses1"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 1,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses2"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 2,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses3"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 3,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses4"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 4,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses5"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 5,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses6"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 6,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["business glasses7"] = {
        model = "models/business_nerd_glasses_01/business_nerd_glasses_01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.1,0.3,0.1),Angle(0,90,-90),1},
        fempos = {Vector(-0.5,-0.6,0.1),Angle(0,103,-90),1},
        skin = 7,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta0"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta1"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 1,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta2"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 2,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta3"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 3,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta4"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 4,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta5"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 5,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["snowboard gta6"] = {
        model = "models/biker_glasses/biker_glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.4,-0.4,-0),Angle(0,100,90),1},
        fempos = {Vector(-0.5,-0.4,-0.1),Angle(0,100,90),1},
        skin = 6,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["glasses with nose"] = {
        model = "models/distac/glasses_with_mustache.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },
["tv head"] = {
        model = "models/player/carnage/android_head.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-3,-0.2,0),Angle(0,-95,-90),1.1},
        fempos = {Vector(-3,0,0),Angle(0,-95,-90),1},
        skin = 0,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5),
        -- Dynamic texture function based on organism parameters
        -- Returns material path or submaterial index to change TV screen texture
        GetDynamicTexture = function(ply, model)
            if not IsValid(ply) or not ply.organism then
                return nil -- Return nil to use default texture
            end
            
            local org = ply.organism
            local materialPath = nil -- Placeholder: change this to your material path
            local subMaterialIndex = nil -- Placeholder: submaterial index if using SetSubMaterial
            local skinIndex = nil -- Placeholder: skin index if using SetSkin
            
            -- Example: Check organism parameters and set texture accordingly
            -- You can customize this based on your needs
            
            -- Check if player is dead or unconscious
            if not ply:Alive() or (org.otrub and org.otrub == true) then
                skinIndex = 8
            elseif org.pain and org.pain > 60 then
                skinIndex = 22
            elseif org.anger and org.anger > 0.5 then
                skinIndex = 7
            elseif org.fear and org.fear > 0.5 then
                skinIndex = 28
            elseif org.happiness and org.happiness > 0.5 then
                skinIndex = 16
            elseif org.sorrow and org.sorrow > 0.5 then
                skinIndex = 27
            elseif org.rage and org.rage > 0.5 then
                skinIndex = 4
            elseif org.anxiety and org.anxiety > 0.5 then
                skinIndex = 47
            elseif org.relief and org.relief > 0.5 then
                skinIndex = 41
            elseif org.calm and org.calm > 0.5 then
                skinIndex = 0
            elseif org.hope and org.hope > 0.5 then
                skinIndex = 0
            end
            
            -- Return table with texture information
            -- You can use SetSubMaterial(model, subMaterialIndex, materialPath) or SetSkin(skinIndex)
            return {
                material = materialPath,
                subMaterialIndex = subMaterialIndex,
                skin = skinIndex
            }
        end
    },
    ["glasses fmf"] = {
        model = "models/distac/street_kid_fmf.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        vpos = Vector(0,0,69)
    },

    ["warmcap"] = {
        model = "models/distac/warmcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        flex = true,
        vpos = Vector(0,0,69)
    },
    -- SCUGS!!!
    ["slugcat"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "0",
        vpos = Vector(0,0,0)
    },
    ["slugcat monk"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.6,5,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "1",
        vpos = Vector(0,0,0)
    },
    ["slugcat gourmand"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "2",
        vpos = Vector(0,0,0)
    },
    ["slugcat arti"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "3",
        vpos = Vector(0,0,0)
    },
    ["slugcat rivulet"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "4",
        vpos = Vector(0,0,0)
    },
    ["slugcat speermaster"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "5",
        vpos = Vector(0,0,0)
    },
    ["slugcat saint"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "6",
        vpos = Vector(0,0,0)
    },
    ["headband"] = {
        model = "models/distac/headband.mdl",
        femmodel = "models/distac/headband_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        vpos = Vector(0,0,69)
    },
    ["occluder"] = {
        model = "models/distac/occluder.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = true,
        bonemerge = false,
        placement = "face",
        vpos = Vector(0,0,69)
    },
    ["shapka ushanka"] = {
        model = "models/eft_props/gear/headwear/head_ushanka.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.7,-0.6,0.1),Angle(180,105,90),1},
        fempos = {Vector(2,-1,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "head",
        vpos = Vector(0,0,69)
    },
    ["cap gop"] = {
        model = "models/distac/cap_gop.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "head",
        vpos = Vector(0,0,69)
    },
    ["glasses viktor"] = {
        model = "models/distac/viktor.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "face",
        vpos = Vector(0,0,69)
    },
    ["glasses folding"] = {
        model = "models/distac/folding.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = false,
        placement = "face",
        vpos = Vector(0,0,69)
    },
    ["headband kamikadze"] = {
        model = "models/distac/headband.mdl",
        femmodel = "models/distac/headband_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        vpos = Vector(0,0,69)
    },

    ["mfdoom mask"] = {
        model = "models/distac/mfdoom.mdl",
        femmodel = "models/distac/mfdoom.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "face",
        norender = true,
        bonemerge = true,
        vpos = Vector(0,0,69)
    },

    ["hood"] = {
        model = "models/distac/kapishon.mdl",
        femmodel = "models/distac/kapishon.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
        vpos = Vector(0,0,69)
    },

    ["christmas hat"] = {
        model = "models/grinchfox/head_wear/christmas_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.5,0),Angle(180,90,90),1},
        fempos = {Vector(0.2,0,0),Angle(180,90,90),1},
        skin = 0,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
    },

    ["cap deeper"] = {
        model = "models/grinchfox/head_wear/caphat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 7,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["cap nurse"] = {
        model = "models/grinchfox/head_wear/caphat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 9,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["deal glasses"] = {
        model = "models/grinchfox/head_wear/dealglasses_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.5,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.5,0),Angle(0,-90,-90),1.1},
        skin = 0,
        norender = true,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["cool glasses"] = {
        model = "models/grinchfox/head_wear/fancyglasses2.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 0,
        norender = true,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["retro glasses"] = {
        model = "models/grinchfox/head_wear/fancyglasses3.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 0,
        norender = true,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["tophat white"] = {
        model = "models/grinchfox/head_wear/tophat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
        skin = 1,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        vpos = Vector(0,0,5)
    },

    ["baseball hub"] = {
        model = "models/grinchfox/head_wear/baseballhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1.1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 6,
        norender = false,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,  
        vpos = Vector(0,0,5)
    },

    ["beard 1"] = {
        model = "models/mosi/fallout4/character/facialhair/smoothoperator.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-4.89,0),Angle(0,-70,-90),1},
        fempos = {Vector(2.5,-2.5,0),Angle(0,-85,-90),.95},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "face2",
    },

    ["beard 2"] = {
        model = "models/mosi/fallout4/character/facialhair/survivalist.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.9,-5,0),Angle(0,-70,-90),1},
        fempos = {Vector(2.5,-2.5,0),Angle(0,-85,-90),.95},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "face2",
    },
    ["haircut"] = {
        model = "models/mosi/fallout4/character/female/femalehair22.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.5,-1,0),Angle(180,105,90),1},
        fempos = {Vector(0.2,-0.9,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
        //bPointShop = true,
        price = 1000,
        name = "haircut"
    },

    ["long haircut"] = {
        model = "models/mosi/fallout4/character/male/malehair28.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.69,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.3,-0.9,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },

    ["The witcher haircut"] = {
        model = "models/mosi/fallout4/character/male/malehair16.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.7,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.4,-1.1,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },

    ["Half haircut"] = {
        model = "models/mosi/fallout4/character/female/femalehair31.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.5,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.4,-1.1,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },
    ["leather bag"] = {
        model = "models/distac/bag.mdl",
        femmodel = "models/distac/bagf.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine2",
        bonemerge = true,
        vpos = Vector(0,0,42),
    },

    ["mustache"] = {
        model = "models/eft_props/gear/facecover/facecover_mustache.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.864,-0.5,0),Angle(0,-80,-90),.95},
        fempos = {Vector(0,-5.2,0),Angle(0,-85,-90),.95},
        skin = 1,
        norender = true,
        placement = "face2",
    },

    ["GP5"] = {
        model = "models/eft_props/gear/facecover/facecover_gasmask_gp5.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,-0.6,0.1),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["Usec cap"] = {
        model = "models/eft_props/gear/headwear/cap_usec_black.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.7,-0.6,0.1),Angle(180,105,90),1},
        fempos = {Vector(2,-1,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["pompon"] = {
        model = "models/eft_props/gear/headwear/head_pompon.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.7,-0.6,0.1),Angle(180,105,90),1},
        fempos = {Vector(2,-1,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },

    ["Daypack"] = {
        model = "models/eft_props/gear/backpacks/bp_daypack.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-6.8,3.5,0),Angle(0,90,90),.75},
        fempos = {Vector(-9,1.9,0),Angle(0,90,90),.75},
        skin = 0,
        bodygroups = "13",
        norender = false,
        placement = "spine2",
    },
    ["Allah"] = {
        model = "models/eft_props/gear/facecover/facecover_shemagh.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.9,-0.6,0.1),Angle(180,105,90),1},
        fempos = {Vector(1,-1,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "face2",
    },
    ["bomber"] = {
        model = "models/eft_props/gear/headwear/head_bomber.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.2,-0.4,0.1),Angle(180,90,90),1},
        fempos = {Vector(1.5,-0.5,0),Angle(180,90,90),1},
        skin = 4,
        norender = true,
        placement = "head",
    },
    ["haircut gorshok"] = {
        model = "models/mosi/fallout4/character/male/malehair03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.5,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.4,-1.1,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },
    ["modcut"] = {
        model = "models/mosi/fallout4/character/male/malehair06.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.5,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.4,-1.1,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },
    ["mohawk (dlya daynov)"] = {
        model = "models/mosi/fallout4/character/male/malehair43.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.5,-1,0),Angle(180,105,90),1},
        fempos = {Vector(-0.4,-1.1,0),Angle(180,105,90),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "head1",
    },
    

    ["anon mask"] = {
            model = "models/rawjesus/wear/anon.mdl",
            femmodel = "models/rawjesus/wear/anon.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(0,-0.8,0),Angle(180,100,90),1},
            fempos = {Vector(-1.2,-0.8,0),Angle(180,100,90),1},
            skin = 0,
            placement = "face",
            norender = true,
            bonemerge = true,
            vpos = Vector(0,0,0),
            name = "Anonymous Mask"
        },

    ["burger king crown"] = {
            model = "models/roblox_assets/burger_king_crown.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(7.8,-0.1,0),Angle(-90,-80,-90),0.7},
            fempos = {Vector(7.8,-0.1,0),Angle(-90,-80,-90),0.7},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,
            bSetColor = false,
            vpos = Vector(0,0,5),
            name = "Burger King Crown"
        },

    ["cap brain"] = {
            model = "models/distac/cap_brain.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(1.5,1.5,0),Angle(180,80,90),1},
            fempos = {Vector(0.5,1.5,0),Angle(180,80,90),1},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,

            vpos = Vector(0,0,0),
            name = "Brain Cap"
        },

    ["cap cool"] = {
            model = "models/distac/cap_brain.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(1.5,1.5,0),Angle(180,80,90),1},
            fempos = {Vector(0.5,1.5,0),Angle(180,80,90),1},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,
            vpos = Vector(0,0,0),
            SubMat = "distac/41/cap_fire",
            name = "Cool Cap"
        },

    ["cap payot"] = {
            model = "models/grinchfox/head_wear/jewhat.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
            fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,
            bSetColor = false,
            vpos = Vector(0,0,5),
            name = "Payot Cap"
        },

    ["coolPro headphone"] = {
            model = "models/distac/headphone.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
            fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,
            vpos = Vector(0,0,69),
            name = "Headphones coolPro"
        },

    ["hockey mask"] = {
            model = "models/rawjesus/wear/jason.mdl",
            femmodel = "models/rawjesus/wear/jason.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(0.5,-0.8,0),Angle(180,100,90),1},
            fempos = {Vector(-0.5,-0.8,0),Angle(180,100,90),1},
            skin = 0,
            placement = "face",
            norender = true,
            bonemerge = true,
            vpos = Vector(0,0,0),
            name = "Hockey Mask"
        },

    ["medieval hood"] = {
            model = "models/distac/kapishom_m.mdl",
            femmodel = "models/distac/kapishom_f.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
            fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
            skin = 0,
            placement = "head",
            norender = true,
            bonemerge = true,
            bSetColor = true,
            vpos = Vector(0,0,69),
            name = "Medieval hood"
        },

    ["pink earmuffs"] = {
            model = "models/modified/headphones.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
            fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
            skin = 1,
            norender = true,
            name = "Pink Earmuffs"
        },

    ["pinklizard"] = {
            model = "models/zcity/lizard.mdl",
            bone = "ValveBiped.Bip01_Spine4",
            malepos = {Vector(2,1,-6),Angle(100,0,0),1},
            fempos = {Vector(1,0,-5),Angle(70,180,180),1},
            skin = 0,
            placement = "spine",
            vpos = Vector(0,0,0),
            name = "Pink Lizard"
        },

    ["starglassis"] = {
            model = "models/distac/starglassis.mdl",
            bone = "ValveBiped.Bip01_Head1",
            malepos = {Vector(-64,-0.3,0),Angle(180,90,90),1},
            fempos = {Vector(-64,-0.3,0),Angle(180,90,90),1},
            skin = 0,
            placement = "face",
            norender = true,
            bonemerge = true,
            vpos = Vector(0,0,69),
            name = "Star Glassis"
        },
        
    ["Slingbag"] = {
        model = "models/gruchk/jmod_dayz/backpacks/bt_hip_pack.mdl",
        bone = "ValveBiped.Bip01_Pelvis",
        malepos = {Vector(1,-2,-1),Angle(2000,550,90),1},
        fempos = {Vector(1,-2,-1),Angle(2000,550,90),1},
        skin = 0,
        placement = "spine2",
        norender = true,
        bonemerge = true,
        bPointShop = false,
        price = 2000,
        vpos = Vector(0,0,0),
        name = "Sling Bag"
	},
    ["BackpackSurvivor"] = {
        model = "models/gruchk/jmod_dayz/backpacks/bp_hunter_backpack.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-10.5,-5,0),Angle(0,80,90),1},
        fempos = {Vector(-12,-7,0),Angle(0,80,90),1},
        skin = 0,
        placement = "spine2",
        norender = true,
        bonemerge = true,
        vpos = Vector(0,0,0),
        name = "Survivor Backpack"
    },

    ["cap_colorable"] = {
        model = "models/griggs/cap_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Baseball Cap"
    },
    ["fedora_colorable"] = {
        model = "models/griggs/fedora_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
        fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Fedora"
    },
    ["fedora_line_colorable"] = {
        model = "models/griggs/fedora_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
        fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
        skin = 1,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Fedora (Line)"
    },
    ["fedora_black_line_colorable"] = {
        model = "models/griggs/fedora_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
        fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
        skin = 2,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Black Fedora (Line)"
    },
    ["earmuffs_colorable"] = {
        model = "models/griggs/headphones_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1200,
        name = "Colorable Earmuffs"
    },
    ["scarf_colorable"] = {
        model = "models/griggs/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 0,
        norender = true,
        placement = "torso",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Scarf"
    },
    ["tophat_colorable"] = {
        model = "models/griggs/tophat_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Tophat"
    },
    ["tophat_white_line_colorable"] = {
        model = "models/griggs/tophat_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
        skin = 1,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Tophat White (Line)"
    },
    ["tophat_black_line_colorable"] = {
        model = "models/griggs/tophat_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
        skin = 2,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Tophat Black (Line)"
    },
    ["fancyglasses_colorable"] = {
        model = "models/griggs/fancyglasses_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 0,
        norender = true,
        placement = "face",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Cool Glasses"
    },
    ["fancyglasses_nt_colorable"] = {
        model = "models/griggs/fancyglasses_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 1,
        norender = true,
        placement = "face",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Cool Glasses (Not Transparent)"
    },
    ["hat03_colorable"] = {
        model = "models/griggs/hat03_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Beanie"
    },
    ["hat03_line_colorable"] = {
        model = "models/griggs/hat03_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Stripped Beanie"
    },
    ["hat03_double_line_colorable"] = {
        model = "models/griggs/hat03_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Double-Stripped Beanie"
    },
    ["hat01_colorable"] = {
        model = "models/griggs/hat01_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Cap"
    },
    ["hat01_white_line_colorable"] = {
        model = "models/griggs/hat01_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable White Cap (Line)"
    },
    ["hat01_black_line_colorable"] = {
        model = "models/griggs/hat01_colorable.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
        bSetColor = true,
        bPointShop = true,
        price = 1500,
        name = "Colorable Black Cap (Line)"
    },
    ["bandana colorable"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 4500,
        name = "Bandana colorable"
    },

    -- remors additions
    ["bandana"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        bSetColor = true,
        vecColorOveride = Vector(0.2,0.2,0.2),
        norender = true,
        placement = "face2",
        ScreenSpaceEffects = function()
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1000,
        name = "Bandana"
    },

    ["bandana groove"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 3,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1400,
        name = "Groove Bandana"
    },

    ["bandana crips"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 1,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1400,
        name = "Crips Bandana"
    },

    ["bandana white"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1100,
        name = "White Bandana"
    },

    ["bandana ghost"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 10,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 2500,
        name = "Ghost Bandana"
    },

    ["bandana hm"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 11,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1100,
        name = "HM Bandana"
    },

    ["bandana evil"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 5,
        bSetColor = false,
        norender = true,
        placement = "face2",
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1500,
        name = "Evil Bandana"
    },

    ["hood v2"] = {
        model = "models/distac/kapishon2.mdl",
        femmodel = "models/distac/kapishon2_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
        vpos = Vector(0,0,69),
        name = "Hood v2"
    },
}


--ass pointshop

hook.Add("Think", "RemoveME", function()
    hg.PointShop = hg.PointShop or {}
    local b = hg.PointShop
    b.Items = {}
    for c, d in pairs(hg.Accessories) do
        if not d.bPointShop then continue end
        b:CreateItem(c, string.NiceName(d.name or c), d.model, d.bodygroups, d.skin, d.vpos or Vector(0, 0, 0), d.price, d.isdpoint)
    end
    hook.Remove("Think", "RemoveME")
end)
