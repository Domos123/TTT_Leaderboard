
print( "Loaded Leaderboard v0.2" )
if SERVER then
	AddCSLuaFile("cl_leaderboard.lua")
	include("sv_leaderboard.lua")
else
	include("cl_leaderboard.lua")
end

concommand.Add( "TTTLB", function( ply, cmd, args )

	if SERVER then
		SendData( ply )
	else
		GetDataFromServer()
		DrawLeaderboard()
	end

end )