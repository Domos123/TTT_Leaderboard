
local cachedata = {}

function FileName( ply )
	return ("lb_data/" .. ply:UniqueID() .. ".txt")
end

function TempFileName( ply )
	return ("lb_tempdata/" .. ply:UniqueID() .. ".txt")
end

function DmFileName( ply )
	return ("lb_dmdata/" .. ply:UniqueID() .. ".txt")
end

function LoadData( ply )
	if file.Exists( FileName( ply ), "DATA"  ) and ( file.Size( FileName( ply ), "DATA"  ) > 1 ) then
		return string.Explode( "," , file.Read( FileName( ply ), "DATA"  ) )
	else
		file.Write( FileName( ply ), "0,0,0,0,0,0,0,0" )
		return {0,0,0,0,0,0,0}
	end
end

function LoadDmData( ply )
	if file.Exists( DmFileName( ply ), "DATA"  ) and ( file.Size( DmFileName( ply ), "DATA"  ) > 1 ) then
		return string.Explode( "," , file.Read( DmFileName( ply ), "DATA"  ) )
	else
		file.Write( DmFileName( ply ), "0,0" )
		return {0,0}
	end
end

function SaveData( ply, data )
	local datastr = data[1] .. "," .. data[2] .. "," .. data[3] .. "," .. data[4] .. "," .. data[5] .. "," .. data[6] .. "," .. data[7] .. "," .. ( data[8] or "0" )
	file.Write( FileName( ply ), datastr )
end

function SaveDmData( ply, data )
	local datastr = data[1] .. "," .. data[2]
	file.Write( DmFileName( ply ), datastr )
end

function CalculateScore ( ply, data )
	innocentkills = data[1] + 0
	detectivekills = data[2] + 0
	traitorkills = data[3] + 0
	rdm = data[4] + 0
	wins = data[5] + 0
	losses = data[6] + 0
	if ( losses == 0 ) then
		losses = 0.6
	end
	score = (innocentkills + detectivekills + traitorkills - (rdm * 1.5)) * (wins / losses)
	score = math.floor(score * (10^2) + 0.5) / (10^2)
	data[7] = score
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
	
	if victim:IsGhost() then
		data = LoadDmData( victim )
		data[2] = data[2] + 1
		SaveDmData( victim, data )
	end
	
	if attacker:IsGhost() then
		data = LoadDmData( attacker )
		data[1] = data[1] + 1
		SaveDmData( attacker, data )
	end
	
	if attacker:IsPlayer() then
		if (attacker != victim) and not attacker:IsSpec() and not attacker:IsGhost() then
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

function CacheData()
	alldata = {}
	tttdata = {}
	dmdata = {}
	for k, ply in pairs( player.GetAll() ) do
		DoLogout( ply )
		thisplayer = LoadData( ply )
		thisplayer[9] = ply:Nick()
		table.insert( tttdata, thisplayer )
	end
	table.insert( alldata, tttdata )
	for k, ply in pairs( player.GetAll() ) do
		thisplayer = LoadDmData( ply )
		if (thisplayer[2] + 0) < 1 then
			thisplayer[3] = thisplayer[1] / 0.5
		else
			thisplayer[3] = thisplayer[1] / thisplayer[2]
		end
		thisplayer[3] = math.floor((thisplayer[3] * 10) + 0.5) / 10
		thisplayer[4] = ply:Nick()
		table.insert( dmdata, thisplayer )
	end
	table.insert( alldata, dmdata )
	cachedata = alldata
end

function SendData( ply )	
	net.Start( "TTTLBData" )
		if next( cachedata ) == nil then
		else
			net.WriteTable( cachedata )
		end
	net.Send( ply )
end

function DoLeaderboard( ply )
	SendData( ply )
end 

function DoLogin( ply )
	file.Write( TempFileName( ply ), CurTime() )
end

function DoLogout( ply )
	logintime = file.Read( TempFileName( ply ), "DATA" )
	timeelapsed = CurTime() - ( logintime or 0 )
	data = LoadData( ply )
	data[8] = data[8] + timeelapsed
	SaveData( ply, data )
	DoLogin( ply )
end

function StatusMsg( ply, status )
	PrintMessage( HUD_PRINTTALK, ply:Nick() .. " (" .. ply:SteamID() .. ") " .. status )
end

util.AddNetworkString( "TTTLBData" )

concommand.Add( "TTTLBUpdate", function( ply, cmd, args )	DoLeaderboard( ply ); end )

hook.Add( "PlayerAuthed", "TTTLB HandleLogin", function( ply, steamid, uniqueid ) StatusMsg( ply, "Connected" ); DoLogin( ply ); return nil; end )
hook.Add( "PlayerDisconnected", "TTTLB HandleLogout", function( ply ) StatusMsg( ply, "Disconnected" ); DoLogout( ply ); return nil; end )
hook.Add( "PlayerDeath", "TTTLB HandleDeath", HandleDeath )
hook.Add( "TTTEndRound", "TTTLB EndOfRound", function( result ) GiveWinOrLoss( result ); CacheData(); return nil; end )

timer.Create( "Advert", 300, 0, function() PrintMessage( HUD_PRINTTALK, "Hit F9 or bind 'TTTLB' to view the leaderboard" ) end )
