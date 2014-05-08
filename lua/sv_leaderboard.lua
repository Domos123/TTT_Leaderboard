
function LoadData( ply )
	if ( file.Exists( "lb_data/" .. ply:UniqueID() .. ".csv" , "DATA" )) then
		print( "Loading Data for " .. ply:Nick() )
		local Data = string.Explode(",",file.Read( "lb_data/" .. ply:UniqueID() .. ".csv" , "DATA" ));
		ply:SetNWInt( "innocentkills",data[1] )
		ply:SetNWInt( "detectivekills",data[2] )
		ply:SetNWInt( "traitorkills",data[3] )
		ply:SetNWInt( "rdm",data[4] )
		ply:SetNWInt( "wins",data[5] )
		ply:SetNWInt( "losses",data[6] )
		ply:SetNWInt( "score",data[7] )
	else
		print( "Creating Data for " .. ply:Nick() )
		file.Write( "lb_data/" .. ply:UniqueID() .. ".csv" , "0,0,0,0,0,0,0" )
		LoadData( ply )
	end
end

function SaveData( ply )
	print( "Saving Data for " .. ply:Nick() )
	local filename = "lb_data/" .. ply:UniqueID() .. ".csv"
	local data = ply:GetNWInt("innocentkills") ..",".. ply:GetNWInt("detectivekills") ..",".. ply:GetNWInt("traitorkills") ..",".. ply:GetNWInt("rdm") ..",".. ply:GetNWInt("wins") ..",".. ply:GetNWInt("losses") ..",".. ply:GetNWInt("score")
	file.Write( filename, data )
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
			else
				v:SetNWInt("wins", v:GetNWInt("wins") + 1)
			end
		else
			if result == WIN_INNOCENT then
				v:SetNWInt("wins", v:GetNWInt("wins") + 1)
			else
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
 
hook.Add( "PlayerInitialSpawn", "LoadPlayerData", LoadData )
hook.Add( "PlayerDisconnected", "SavePlayerData", SaveData )
hook.Add( "PlayerDeath", "HandleDeath", HandleDeath( victim, inflictor, attacker ) )
hook.Add( "TTTEndRound", "EndOfRound", GiveWinOrLoss( result ) )
hook.Add( "UpdateLeaderboard", "UpdateLeaderboard", CalculateScore )
