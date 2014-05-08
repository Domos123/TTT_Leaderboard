
function LoadData( ply )
	MsgAll( "Handling join for " .. ply:UniqueID() )
	local f = file.Open( "lb_data/" .. ply:UniqueID() .. ".txt" , "r" , "DATA" )
	if ( f ) then
		MsgAll( "Loading Data for " .. ply:Nick() )
		local Data = string.Explode( "," , f:ReadString( f:Size() ) )
		f:Close()
		ply:SetNWInt( "innocentkills" , data[1] )
		ply:SetNWInt( "detectivekills" , data[2] )
		ply:SetNWInt( "traitorkills" , data[3] )
		ply:SetNWInt( "rdm" , data[4] )
		ply:SetNWInt( "wins" , data[5] )
		ply:SetNWInt( "losses" , data[6] )
		ply:SetNWInt( "score" , data[7] )
	else
		MsgAll( "Creating Data for " .. ply:Nick() )
		local f = file.Open( "lb_data/" .. ply:UniqueID() .. ".txt" , "w" , "DATA" )
		f:Write( "0,0,0,0,0,0,0" )
		f:Close()
		ply:SetNWInt( "detectivekills" , 0 )
		ply:SetNWInt( "traitorkills" , 0 )
		ply:SetNWInt( "rdm" , 0 )
		ply:SetNWInt( "wins" , 0 )
		ply:SetNWInt( "losses" , 0 )
		ply:SetNWInt( "score" , 0 )
	end
end

function SaveData( ply )
	MsgAll( "Saving Data for " .. ply:Nick() )
	local data = ply:GetNWInt("innocentkills") ..",".. ply:GetNWInt("detectivekills") ..",".. ply:GetNWInt("traitorkills") ..",".. ply:GetNWInt("rdm") ..",".. ply:GetNWInt("wins") ..",".. ply:GetNWInt("losses") ..",".. ply:GetNWInt("score")
	local f = file.Open( "lb_data/" .. ply:UniqueID() .. ".txt" , "w" , "DATA" )
	f:Write( data )
	f:Close()
end

function CalculateScore ()
	for k, v in pairs(player.GetAll()) do
		innocentkills = v:GetNWInt("innocentkills") + 0
		detectivekills = v:GetNWInt("detectivekills") + 0
		traitorkills = v:GetNWInt("traitorkills") + 0
		rdm = v:GetNWInt("rdm") + 0
		wins = v:GetNWInt("wins") + 0
		losses = v:GetNWInt("losses") + 0
		
		if (losses > 0) then
			score = ((innocentkills + (detectivekills * 1.1) + (traitorkills * 1.2) - (rdm * 1.1)) * (wins / losses)) + 0
		else
			score = 0
		end
		v:SetNWInt("score", score)
	end
end

function GiveWinOrLoss ( result )
	for k, v in pairs(player.GetAll()) do
		if v:IsTraitor() then
			if result == WIN_INNOCENT then
				v:SetNWInt("losses", v:GetNWInt("losses") + 1)
			elseif result == WIN_TRAITOR then
				v:SetNWInt("wins", v:GetNWInt("wins") + 1)
			end
		else
			if result == WIN_INNOCENT then
				v:SetNWInt("wins", v:GetNWInt("wins") + 1)
			elseif result == WIN_TRAITOR then
				v:SetNWInt("losses", v:GetNWInt("losses") + 1)
			end
		end
		SaveData( v )
	end
end

function HandleDeath ( victim, inflictor, attacker )
	if attacker then
		if attacker:IsPlayer() and attacker != victim then
			if attacker:IsTraitor() then
				if victim:IsTraitor() then
					attacker:SetNWInt("rdm", attacker:GetNWInt("rdm") + 1)
				elseif victim:IsDetective() then
					attacker:SetNWInt("detectivekills", attacker:GetNWInt("detectivekills") + 1)
				else
					attacker:SetNWInt("innocentkills", attacker:GetNWInt("innocentkills") + 1)
				end
			else
				if victim:IsTraitor() then
					attacker:SetNWInt("traitorkills", attacker:GetNWInt("traitorkills") + 1)
				else
					attacker:SetNWInt("rdm", attacker:GetNWInt("rdm") + 1)
				end
			end
			SaveData( attacker )
		end
	end
end

MsgAll( "Loaded Leaderboard Server Addon\n" ) 
hook.Add( "PlayerInitialSpawn", "LoadPlayerData", LoadData )
hook.Add( "PlayerDisconnected", "SavePlayerData", SaveData )
hook.Add( "PlayerDeath", "HandleDeath", HandleDeath( victim, inflictor, attacker ) )
hook.Add( "TTTEndRound", "EndOfRound", GiveWinOrLoss( result ) )