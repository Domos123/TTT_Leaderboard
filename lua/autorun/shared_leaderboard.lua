
print( "Loaded Leaderboard v0.2" )
if SERVER then
	AddCSLuaFile("cl_leaderboard.lua")
	include("sv_leaderboard.lua")
else
	include("cl_leaderboard.lua")
end

function DoLeaderboard( ply )

	if SERVER then
		SendData( ply )
	else
		GetDataFromServer()
		DrawLeaderboard()
	end

end 

concommand.Add( "TTTLB", function( ply, cmd, args )	DoLeaderboard( ply ); end )

hook.Add( "PlayerSay", "TTTLB ChatCommand", function( ply, txt, public )
	if ( string.sub( text, 1, 6 ) == "!TTTLB") then
         DoLeaderboard( ply )
    end
end )