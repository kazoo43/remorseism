local smoke_mats = {}
for i = 1,9 do
    table.insert(smoke_mats, "particle/smokesprites_000" .. i)
end
for i = 10,16 do
    table.insert(smoke_mats, "particle/smokesprites_00" .. i)
end

local g_emit
local g_emitpos
local function getEmitter(pos)
    if not IsValid(g_emit) or not g_emitpos or g_emitpos:DistToSqr(pos) > 65536 then
        if IsValid(g_emit) then g_emit:Finish() end
        g_emit = ParticleEmitter(pos)
        g_emitpos = pos
    end
    return g_emit
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
    local pos = data:GetStart()
    local normal = data:GetNormal()
    local intensity = data:GetMagnitude()

    local emitter = getEmitter(pos)

    for i = 1,8*intensity do
        local smoke = emitter:Add(smoke_mats[math.random(#smoke_mats)], pos)
        
        smoke:SetStartAlpha(math.Rand(5, 10))
        smoke:SetEndAlpha(0)
        smoke:SetColor(150,115,0)
        --smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.75, 1.5)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,5*intensity do
        local droplett = emitter:Add("effects/blooddrop", pos+normal*8)

        droplett:SetStartAlpha(255)
        droplett:SetEndAlpha(0)
        droplett:SetColor(125,100,0)
        --droplett:SetLighting(true)
        droplett:SetGravity(Vector(0,0,-600))
        droplett:SetStartLength(10)
        droplett:SetEndLength(0)

        local size = math.Rand(0.75, 1.5)
        droplett:SetEndSize(size)
        droplett:SetStartSize(size)

        droplett:SetDieTime(0.66)
        droplett:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity*1.25)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------