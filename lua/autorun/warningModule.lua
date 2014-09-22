if SERVER then
	AddCSLuaFile("warning/cl_init.lua")
	include("warning/init.lua")
end

if CLIENT then
	include("warning/cl_init.lua")
end