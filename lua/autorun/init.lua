
print( "Loaded Leaderboard v0.1" )
if SERVER then
	print( "Serverside code running" )
	AddCSLuaFile("cl_leaderboard.lua")
	include("sv_leaderboard.lua")
else
	print( "Clientside Code Running" )
	include("cl_leaderboard.lua")
end
