
print( "Loaded Leaderboard v0.2" )
if SERVER then
	AddCSLuaFile("cl_leaderboard.lua")
	AddCSLuaFile("sv_leaderboard.lua")
	include("sv_leaderboard.lua")
else
	include("cl_leaderboard.lua")
end
