
function FileName( ply )
	return ("lb_data/" .. ply:UniqueID() .. ".txt")
end

function LoadData( ply )
	if (not file.IsDir("lb_data", "DATA" )) then
		file.CreateDir("lb_data")
	end
	if file.Exists( FileName( ply ), "DATA"  ) and ( file.Size( FileName( ply ), "DATA"  ) > 1 ) then
		return string.Explode( "," , file.Read( FileName( ply ), "DATA"  ) )
	else
		file.Write( FileName( ply ), "0,0,0,0,0,0,0" )
		return {0,0,0,0,0,0,0}
	end
end

function SaveData( ply, data )
	if (not file.IsDir("lb_data", "DATA" )) then
		file.CreateDir("lb_data")
	end
	local datastr = data[1] .. "," .. data[2] .. "," .. data[3] .. "," .. data[4] .. "," .. data[5] .. "," .. data[6] .. "," .. data[7]
	file.Write( FileName( ply ), datastr )
end

function CalculateScore ( ply, data )
	innocentkills = data[1] + 0
	detectivekills = data[2] + 0
	traitorkills = data[3] + 0
	rdm = data[4] + 0
	wins = data[5] + 0
	losses = data[6] + 0
	if (losses > 0) then
		data[7] = ((innocentkills + (detectivekills * 1.1) + (traitorkills * 1.2) - (rdm * 1.1)) * (wins / losses)) + 0
	else
		data[7] = ((innocentkills + (detectivekills * 1.1) + (traitorkills * 1.2) - (rdm * 1.1)) * (wins * 1.5)) + 0
	end
	return data
end

function GiveWinOrLoss ( result )
	for k, v in pairs(player.GetAll()) do
		data = LoadData( v )
		if v:IsTraitor() then
			if result == WIN_INNOCENT then
				data[6] = data[6] + 1
			elseif result == WIN_TRAITOR then
				data[5] = data[5] + 1
			end
		elseif !v:IsSpec() then
			if result == WIN_INNOCENT then
				data[5] = data[5] + 1
			elseif result == WIN_TRAITOR then
				data[6] = data[6] + 1
			end
		else
		end
		data = CalculateScore( v, data )
		SaveData( v, data )
	end
end

function HandleDeath ( victim, inflictor, attacker )
	if !IsValid(attacker) then
		return nil
	end
	if GAMEMODE.round_state != ROUND_ACTIVE then
		return nil
	end
	if attacker:IsPlayer() then
		if attacker != victim then
			data = LoadData( attacker )
			if attacker:IsTraitor() then
				if victim:IsTraitor() then
					data[4] = data[4] + 1
				elseif victim:IsDetective() then
					data[2] = data[2] + 1
				else
					data[1] = data[1] + 1
				end
			else
				if victim:IsTraitor() then
					data[3] = data[3] + 1
				else
					data[4] = data[4] + 1
				end
			end
			data = CalculateScore( attacker, data )
			SaveData( attacker, data )
		end
	end
	return nil
end

function SendDataToAll()
	--MsgAll( "Sending Data to Clients" )
	netdata = {}
	for k, ply in pairs( player.GetAll() ) do
		thisplayer = LoadData( ply )
		thisplayer[8] = ply:Nick()
		table.insert( netdata, thisplayer )
	end
	
	net.Start( "TTTLBData" )
		net.WriteTable( netdata )
	net.Broadcast()
end

util.AddNetworkString( "TTTLBData" )

MsgAll( "Loaded Leaderboard Server Addon\n" )

hook.Add( "PlayerDeath", "TTTLB HandleDeath", HandleDeath)
hook.Add( "TTTEndRound", "TTTLB EndOfRound", function( result ) GiveWinOrLoss( result ); SendDataToAll(); return nil; end )
