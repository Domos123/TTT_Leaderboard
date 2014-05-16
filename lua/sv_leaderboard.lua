
local cachedata = {}

function FileName( ply )
	return ("lb_data/" .. ply:UniqueID() .. ".txt")
end

function TempFileName( ply )
	return ("lb_data/" .. ply:UniqueID() .. "Temp.txt")
end

function LoadData( ply )
	if (not file.IsDir("lb_data", "DATA" )) then
		file.CreateDir("lb_data")
	end
	if file.Exists( FileName( ply ), "DATA"  ) and ( file.Size( FileName( ply ), "DATA"  ) > 1 ) then
		return string.Explode( "," , file.Read( FileName( ply ), "DATA"  ) )
	else
		file.Write( FileName( ply ), "0,0,0,0,0,0,0,0" )
		return {0,0,0,0,0,0,0}
	end
end

function SaveData( ply, data )
	if (not file.IsDir("lb_data", "DATA" )) then
		file.CreateDir("lb_data")
	end
	local datastr = data[1] .. "," .. data[2] .. "," .. data[3] .. "," .. data[4] .. "," .. data[5] .. "," .. data[6] .. "," .. data[7] .. "," .. ( data[8] or "0" )
	file.Write( FileName( ply ), datastr )
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

function CacheData()
	netdata = {}
	for k, ply in pairs( player.GetAll() ) do
		DoLogout( ply )
		thisplayer = LoadData( ply )
		thisplayer[9] = ply:Nick()
		table.insert( netdata, thisplayer )
	end
	cachedata = netdata
end

function SendData( ply )	
	net.Start( "TTTLBData" )
		if next( cachedata ) == nil then
			MsgAll( "Data is not cached yet" )
		else
			net.WriteTable( cachedata )
		end
	net.Send( ply )
end

function DoLeaderboard( ply )
	MsgAll( "Updating " .. ply:Nick() )
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

util.AddNetworkString( "TTTLBData" )

concommand.Add( "TTTLBUpdate", function( ply, cmd, args )	DoLeaderboard( ply ); end )

hook.Add( "PlayerAuthed", "TTTLB HandleLogin", function( ply, steamid, uniqueid ) DoLogin( ply ); return nil; end )
hook.Add( "PlayerDisconnected", "TTTLB HandleLogout", function( ply ) DoLogout( ply ); return nil; end )
hook.Add( "PlayerDeath", "TTTLB HandleDeath", HandleDeath )
hook.Add( "TTTEndRound", "TTTLB EndOfRound", function( result ) GiveWinOrLoss( result ); CacheData(); return nil; end )
