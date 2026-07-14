local MODE = MODE

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.RIOT_TDM_LAW = zb.Points.RIOT_TDM_LAW or {}
zb.Points.RIOT_TDM_LAW.Color = Color(0,0,150)
zb.Points.RIOT_TDM_LAW.Name = "RIOT_TDM_LAW"

zb.Points.RIOT_TDM_RIOTERS = zb.Points.RIOT_TDM_RIOTERS or {}
zb.Points.RIOT_TDM_RIOTERS.Color = Color(150,95,0)
zb.Points.RIOT_TDM_RIOTERS.Name = "RIOT_TDM_RIOTERS"

RIOT_INTENSITIES = RIOT_INTENSITIES or {
	[1] = {
		id = "CONTAINED",
		name = "Contained",
		color = Color(120, 170, 255),
		description = "Things are getting aggressive."
	},
	[2] = {
		id = "ESCALATED",
		name = "Escalated",
		color = Color(255, 190, 90),
		description = "Some people are armed, the fire is rising."
	},
	[3] = {
		id = "ANARCHY",
		name = "Anarchy",
		color = Color(255, 90, 90),
		description = "This is civil war now."
	}
}
