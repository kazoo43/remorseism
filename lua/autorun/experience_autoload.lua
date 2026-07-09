-- Загрузка системы опыта / медалей во всех гейммодах (включая sandbox)
-- Файлы лежат в lua/experience и грузятся независимо от zcity-геймода.

local dir = "experience"

local prefixSides = {
	["sv_"] = "sv_",
	["sh_"] = "sh_",
	["cl_"] = "cl_",
}

local function AddFile(File, path)
	local side = prefixSides[string.lower(string.Left(File, 3))]

	if side == "sv_" then
		if SERVER then include(path) end
	elseif side == "sh_" then
		if SERVER then AddCSLuaFile(path) end
		include(path)
	elseif side == "cl_" then
		if SERVER then AddCSLuaFile(path) else include(path) end
	else
		if SERVER then AddCSLuaFile(path) end
		include(path)
	end
end

local function IncludeDir(d)
	local files, dirs = file.Find(d .. "/*", "LUA")

	for _, f in ipairs(files or {}) do
		if string.EndsWith(f, ".lua") then AddFile(f, d .. "/" .. f) end
	end

	for _, sub in ipairs(dirs or {}) do
		IncludeDir(d .. "/" .. sub)
	end
end

IncludeDir(dir)
