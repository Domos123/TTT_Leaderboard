
print( "Loaded Leaderboard v0.2" )
if SERVER then

	if (not file.IsDir("lb_data", "DATA" )) then
		file.CreateDir("lb_data")
	end
	if (not file.IsDir("lb_tempdata", "DATA" )) then
		file.CreateDir("lb_tempdata")
	end
	if (not file.IsDir("lb_dmdata", "DATA" )) then
		file.CreateDir("lb_dmdata")
	end
	
	AddCSLuaFile("cl_leaderboard.lua")
	include("sv_leaderboard.lua")
else
	include("cl_leaderboard.lua")
end
