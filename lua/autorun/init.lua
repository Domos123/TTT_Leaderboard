if SERVER then
      AddCSLuaFile("cl_leaderboard.lua")
	  include("sv_leaderboard.lua")
else
      include("cl_leaderboard.lua")
end