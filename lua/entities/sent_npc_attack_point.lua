AddCSLuaFile()

ENT.PrintName = "NPC Attack Point"
ENT.Category = "Fun + Games"
ENT.Base = "base_ai"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

ENT.SC_Type 	= 0
ENT.SC_TurnOn 	= 0
ENT.SC_Effect 	= 0
ENT.SC_Dist 	= 5000
ENT.SC_Death 	= 0

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "SCNAPType", {
		KeyName = "scnap_type",
		Edit = {
			category = "NPC Attack Point",
			title  = "NPC Type",
			type = "Combo",
			order = 3,
			text = "None",
			values = {
				Resistance = 5,
				Combine = 4,
				Antlion = 3,
				Zombie = 2,
				Everyone = 1,
				None = 0
			}
		}
	} )
	
	self:NetworkVar( "Float", 0, "SCNAPHealth", {
		KeyName = "scnap_health",
		Edit = {
			category = "NPC Attack Point",
			title = "Health",
			type = "Int",
			order = 3,
			min = 1,
			max = 10000
		}
	} )
	
	self:NetworkVar( "Vector", 0, "SCNAPColor", {
		KeyName = "scnap_color",
		Edit = {
			category = "NPC Attack Point",
			title = "Color",
			type = "VectorColor",
			order = 6
		}
	} )
	
	self:NetworkVar( "Int", 2, "SCNAPEffect", {
		KeyName = "scnap_effect",
		Edit = {
			category = "NPC Attack Point",
			title = "Smoke Effect",
			type = "Boolean",
			order = 2
		}
	} )
	
	self:NetworkVar( "Int", 1, "SCNAPOn", {
		KeyName = "scnap_on",
		Edit = {
			category = "NPC Attack Point",
			title = "Active",
			type = "Boolean",
			order = 1
		}
	} )
	
	self:NetworkVar( "Float", 1, "SCNAPDist", {
		KeyName = "scnap_dist",
		Edit = {
			category = "NPC Attack Point",
			title = "Distance",
			type = "Int",
			min = 0,
			max = 10000,
			order = 5
		}
	} )

	if SERVER then
		
		self:SetSCNAPColor( Vector( self:GetColor().r, self:GetColor().g, self:GetColor().b ) )
		self:SetSCNAPHealth( self:GetMaxHealth() )
		self:SetSCNAPOn( self.SC_TurnOn )
		self:SetSCNAPEffect( self.SC_Effect )
		self:SetSCNAPType( self.SC_Type )
		self:SetSCNAPDist( self.SC_Dist )
		
		self:NetworkVarNotify( "SCNAPColor", self.SCNAP_SwitchColor )
		self:NetworkVarNotify( "SCNAPHealth", self.SCNAP_SwitchHealth )
		self:NetworkVarNotify( "SCNAPOn", self.SCNAP_SwitchOn )
		self:NetworkVarNotify( "SCNAPEffect", self.SCNAP_SwitchEffect )
		self:NetworkVarNotify( "SCNAPDist", self.SCNAP_SwitchDist )
		self:NetworkVarNotify( "SCNAPType", self.SCNAP_SwitchType )
		
	end

end

if SERVER then

	function ENT:SCNAP_SwitchColor( var_name, var_old, var_new )
	
		if var_old == var_new then return end
		
		local col = var_new
		
		self:SetColor( Color( col.x * 255, col.y * 255, col.z * 255, 255 ) )
	
	end
	
	function ENT:SCNAP_SwitchHealth( var_name, var_old, var_new )
	
		if var_old == var_new then return end
		
		self:SetMaxHealth( math.Round( var_new ) )
		self:SetHealth( self:GetMaxHealth() )
	
	end
	
	function ENT:SCNAP_SwitchOn( var_name, var_old, var_new )
	
		if var_old == var_new then return end
		
		if var_new == 1 then self:EmitSound( "Buttons.snd3" ) else self:EmitSound( "Buttons.snd2" ) end
		
		self.SC_TurnOn = var_new

	end
	
	function ENT:SCNAP_SwitchEffect( var_name, var_old, var_new )
	
		if var_old == var_new then return end
		
		self:EmitSound( "k_lab.techbutton" )
		
		self.SC_Effect = var_new
		
	end
	
	function ENT:SCNAP_SwitchDist( var_name, var_old, var_new )
	
		if var_old == var_new then return end

		self.SC_Dist = var_new
		
	end
	
	function ENT:SCNAP_SwitchType( var_name, var_old, var_new )
	
		if var_old == var_new then return end
		
		self:EmitSound( "k_lab.techbutton" )

		self.SC_Type = var_new
		
	end
	
end

function ENT:Initialize()

	if CLIENT then return end

	self:SetModel( "models/props_c17/oildrum001.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():Wake()
	self:SetSkin( 1 )
	self:DrawShadow( true )
	
	self:GetPhysicsObject():SetMass( 1000 )
	
	self:SetHullType( HULL_MEDIUM )
	self:SetHullSizeNormal()
	
	self:SetMaxHealth( 100 )
	self:SetHealth( self:GetMaxHealth() )
	
	self.SC_TurnOn 	= 0
	self.SC_Effect 	= 0
	self.SC_Death 	= 0
	self.SC_Dist 	= 5000
	self.SC_Type 	= 0

end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo, target )

	if CLIENT then return end
	
	if self.SC_Death == 1 then return end
	
	self:TakePhysicsDamage( dmginfo )
	
	self:SetHealth( math.max( 0, self:Health() - dmginfo:GetDamage() ) )
	
	if self:Health() <= 0 then
	
		self.SC_Death = 1
		
		hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
		
		local expl = ents.Create( "env_explosion" )
		expl:SetPos( self:GetPos() + self:GetUp()*15 )
		expl:SetAngles( self:GetAngles() )
		expl:SetKeyValue( "iMagnitude", 100 )
		expl:SetKeyValue( "iRadiusOverride", 200 )
		expl:SetKeyValue( "DamageForce", 1000 )
		expl:SetOwner( self )
		expl:Fire( "Explode" )
		
		local ar2 = ents.Create( "env_ar2explosion" )
		ar2:SetPos( self:GetPos() + self:GetUp()*15 )
		ar2:SetOwner( self )
		ar2:Fire( "Explode" )
		
		local effect = EffectData()
		effect:SetOrigin( self:GetPos() + self:GetUp() * 15 )
		effect:SetNormal( Vector( 0, 0, 1 ) )
		effect:SetStart( self:GetPos() )
		effect:SetMagnitude( math.random( 2, 5 ) )
		effect:SetEntity( self )
		effect:SetScale( 1 )
		effect:SetRadius( math.random( 3, 6 ) )
		util.Effect( "Sparks", effect )
		
		SafeRemoveEntityDelayed( self, 0.1 )
		
	end

end

function ENT:SelectSchedule()

	return true
	
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.01 )
	
	if !SERVER or self.SC_Death == 1 then return end

	if type != self.SC_Type then self:SetSCNAPType( self.SC_Type ) end
	if colo != Vector( self:GetColor().r / 255, self:GetColor().g / 255, self:GetColor().b / 255 ) then self:SetSCNAPColor( Vector( self:GetColor().r / 255, self:GetColor().g / 255, self:GetColor().b / 255 ) ) end
	if onon != self.SC_TurnOn then self:SetSCNAPOn( self.SC_TurnOn ) end
	if heal != self:GetMaxHealth() then self:SetSCNAPHealth( self:GetMaxHealth() ) end
	if dist != self.SC_Dist then self:SetSCNAPDist( self.SC_Dist ) end
	if effe != self.SC_Effect then self:SetSCNAPEffect( self.SC_Effect ) end
	
	if self.SC_Effect == 1 and self.SC_TurnOn == 1 then

		local effect = EffectData()
		effect:SetOrigin( self:GetPos() + self:GetUp() * 50 )
		effect:SetNormal( Vector( 0, 0, 1 ) )
		effect:SetStart( self:GetPos() )
		effect:SetMagnitude( 1 )
		effect:SetEntity( self )
		effect:SetScale( 1 )
		effect:SetRadius( 1 )
		util.Effect( "SCNAP_Effect", effect )
		
	end
	
	local resi = {
		CLASS_PLAYER_ALLY,
		CLASS_PLAYER_ALLY_VITAL,
		CLASS_CITIZEN_PASSIVE,
		CLASS_CITIZEN_REBEL,
		CLASS_VORTIGAUNT,
		CLASS_HACKED_ROLLERMINE,
		CLASS_HUMAN_PASSIVE
	}
	
	local comb = {
		CLASS_COMBINE,
		CLASS_COMBINE_GUNSHIP,
		CLASS_MANHACK,
		CLASS_METROPOLICE,
		CLASS_MILITARY,
		CLASS_SCANNER,
		CLASS_STALKER,
		CLASS_PROTOSNIPER,
		CLASS_COMBINE_HUNTER,
	}
	
	local anti = {
		CLASS_ANTLION,
	}
	
	local zomb = {
		CLASS_HEADCRAB,
		CLASS_ZOMBIE,
	}
	
	for k, v in pairs( ents.FindByClass( "npc_*" ) ) do
	
		if v:IsValid() and v:IsNPC() and v:Classify() and v:GetNPCState() and v:GetNPCState() != NPC_STATE_DEAD and v:GetPos():Distance( self:GetPos() ) < self.SC_Dist then
		
			local cl = v:Classify()
			local tb = table
			
			if self.SC_Type == 0 then tb = table end
			if self.SC_Type == 2 then tb = zomb end
			if self.SC_Type == 3 then tb = anti end
			if self.SC_Type == 4 then tb = comb end
			if self.SC_Type == 5 then tb = resi end
			
			local r1 = v:Disposition( self )
			local r2 = self:Disposition( v )
			
			if self.SC_Type != 1 and self.SC_Type != 0 and self.SC_TurnOn == 1 then
			
				if table.HasValue( tb, cl ) then
					
					if r1 != D_HT then
					
						v:AddEntityRelationship( self, D_HT, 99 )
						
					end
					
					if r2 != D_HT then
					
						self:AddEntityRelationship( v, D_HT, 99 )
						
					end
					
					v:UpdateEnemyMemory( self, self:GetPos() )
					
					if !v:GetEnemy() or ( v:GetEnemy() and !v:GetEnemy():IsValid() ) then
					
						v:SetEnemy( self )
						v:SetSchedule( SCHED_CHASE_ENEMY )

					end
					
					if v:GetEnemy() and v:GetEnemy():IsValid() and v:GetEnemy() == self and v:GetCurrentSchedule() and v:GetCurrentSchedule() == SCHED_ALERT_STAND then
					
						self:SetSchedule( SCHED_CHASE_ENEMY )
						
					end
					
				else
				
					if r1 != D_LI then
					
						v:AddEntityRelationship( self, D_LI, 99 )
						
					end
					
					if r2 != D_LI then
					
						self:AddEntityRelationship( v, D_LI, 99 )
						
					end
				
				end
			
			elseif self.SC_Type == 1 and self.SC_TurnOn == 1 then
			
				if r1 != D_HT then
				
					v:AddEntityRelationship( self, D_HT, 99 )
					
				end
				
				if r2 != D_HT then
				
					self:AddEntityRelationship( v, D_HT, 99 )
					
				end
				
				v:UpdateEnemyMemory( self, self:GetPos() )
				
				if !v:GetEnemy() or ( v:GetEnemy() and !v:GetEnemy():IsValid() ) then
				
					v:SetEnemy( self )
					v:SetSchedule( SCHED_CHASE_ENEMY )

				end
			
			elseif self.SC_Type == 0 or self.SC_TurnOn == 0 then
			
				if r1 != D_LI then
				
					v:AddEntityRelationship( self, D_LI, 99 )
					
				end
				
				if r2 != D_LI then
				
					self:AddEntityRelationship( v, D_LI, 99 )
					
				end
			
			end
		
		end
	
	end
	
end

if CLIENT then

	local EFFECT = {}
	
	function EFFECT:Init( data )

		local Ori = data:GetOrigin()
		local Sta = data:GetStart()
		local Sca = data:GetScale()
		local Ent = data:GetEntity()
		local Nor = data:GetNormal()

		if Ori and Sca then

			local emitter = ParticleEmitter( Ori, false )

			for i=1, 1 do

				if emitter:IsValid() then

					local particle = emitter:Add( "particle/smokestack", Ori )
					
					if ( particle ) then
					
						particle:SetAngles( Nor:Angle() )
						
						if Ent:IsValid() then
						
							particle:SetVelocity( Nor:Angle():Forward() * 100 + VectorRand():GetNormal() * 50 )
							
						end

						particle:SetLifeTime( 0 )
						particle:SetDieTime( 5 )

						particle:SetStartAlpha( 200 )
						particle:SetEndAlpha( 0 )

						local Size = 20
						particle:SetStartSize( Size )
						particle:SetEndSize( Size * 0.5 )

						particle:SetAirResistance( 200 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						
						local color = Vector( 255, 255, 255 )
						
						if Ent:IsValid() then
						
							color.x = Ent:GetColor().r
							color.y = Ent:GetColor().g
							color.z = Ent:GetColor().b

						end

						particle:SetColor( color.x, color.y, color.z )

						particle:SetCollide( false )

						particle:SetBounce( 0 )
						particle:SetLighting( false )

					end
					
					emitter:Finish()
					
				end
				
			end
			
		end
		
	end

	function EFFECT:Think()
	
		return false
		
	end

	function EFFECT:Render()
	
	end
	
	effects.Register( EFFECT, "SCNAP_Effect" )
	
end