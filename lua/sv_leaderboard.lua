

function Initialize ()
	CreateTable()
end

function CalculateScore ()
	for k, v in pairs(player.GetAll()) do
		innocentkills = v:GetNWInt("innocentkills") + 0
		detectivekills = v:GetNWInt("detectivekills") + 0
		traitorkills = v:GetNWInt("traitorkills") + 0
		rdm = v:GetNWInt("rdm") + 0
		wins = v:GetNWInt("wins") + 0
		losses = v:GetNWInt("losses") + 0
		
		if (wins > 0) then
			score = ((innocentkills + (detectivekills * 1.1) + (traitorkills * 1.2) - (rdm * 1.1)) * (wins / losses)) + 0
		else
			score = 0
		end
		
		v:SetNWInt("score", score)
	end
end

function CreateTable ()
	if not (sql.TableExists("player_info")) then
		sql.Query( "DROP TABLE player_info" )
		query = "CREATE TABLE player_info ( unique_id varchar(255), innocentkills int, detectivekills int, traitorkills int, rdm int, wins int, losses int, score int)"
		result = sql.Query( query )
	end
end

function PlayerInitialSpawn ( ply )
		timer.Create("Steam_id_delay", 1, 1, function()
		SteamID = ply:SteamID()
		ply:SetNWString("SteamID", SteamID)
		timer.Create("SaveStats", 10, 0, function() SaveStats( ply ) end)	
		PlayerExists( ply )
	end) 
end

function PlayerExists ( ply )
	steamID = ply:GetNWString("SteamID")
	result = sql.Query("SELECT unique_id, innocentkills, detectivekills, traitorkills, rdm, wins, losses, score FROM player_info WHERE unique_id = '"..steamID.."'")
	if (result) then
		GetStats( ply )
	else
		NewPlayer( steamID, ply ) 
	end
end

function NewPlayer ( SteamID, ply )
	print( "Created row for "..ply:Nick())
	steamID = SteamID
	sql.Query( "INSERT INTO player_info (`unique_id`, `innocentkills`, `detectivekills`, `traitorkills`, `rdm`, `wins`, `losses`, `score`) VALUES ('"..steamID.."', '0', '0', '0', '0', '0', '0', '0')" )
	result = sql.Query( "SELECT unique_id, innocentkills, detectivekills, traitorkills, rdm, wins, losses, score FROM player_info WHERE unique_id = '"..steamID.."'" )
	if (result) then
		GetStats( ply )
	end
end

function GetStats ( ply )
	unique_id = sql.QueryValue("SELECT unique_id FROM player_info WHERE unique_id = '"..steamID.."'")
	innocentkills = sql.QueryValue("SELECT innocentkills FROM player_info WHERE unique_id = '"..steamID.."'")
	detectivekills = sql.QueryValue("SELECT detectivekills FROM player_info WHERE unique_id = '"..steamID.."'")
	traitorkills = sql.QueryValue("SELECT traitorkills FROM player_info WHERE unique_id = '"..steamID.."'")
	rdm = sql.QueryValue("SELECT rdm FROM player_info WHERE unique_id = '"..steamID.."'")
	wins = sql.QueryValue("SELECT wins FROM player_info WHERE unique_id = '"..steamID.."'")
	losses = sql.QueryValue("SELECT losses FROM player_info WHERE unique_id = '"..steamID.."'")
	score = sql.QueryValue("SELECT score FROM player_info WHERE unique_id = '"..steamID.."'")
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("innocentkills", innocentkills)
	ply:SetNWInt("detectivekills", detectivekills)
	ply:SetNWInt("traitorkills", traitorkills)
	ply:SetNWInt("rdm", rdm)
	ply:SetNWInt("wins", wins)
	ply:SetNWInt("losses", losses)
	ply:SetNWInt("score", score)
end

function SaveStats ( ply )
	unique_id = ply:GetNWString("SteamID")
	innocentkills = ply:GetNWInt("innocentkills")
	detectivekills = ply:GetNWInt("detectivekills")
	traitorkills = ply:GetNWInt("traitorkills")
	rdm = ply:GetNWInt("rdm")
	wins = ply:GetNWInt("wins")
	losses = ply:GetNWInt("losses")
	CalculateScore()
	score = ply:GetNWInt("score")
	sql.Query("UPDATE player_info SET innocentkills = "..innocentkills..", detectivekills = "..detectivekills..", traitorkills = "..traitorkills..", rdm = "..rdm..", wins = "..wins..", losses = "..losses..", score = "..score.." WHERE unique_id = '"..unique_id.."'")
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
		SaveStats( v )
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
			SaveStats( attacker )
		end
	end
end
 
hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn", PlayerInitialSpawn )
hook.Add( "Initialize", "Initialize", Initialize )
hook.Add( "PlayerDeath", "HandleDeath", HandleDeath( victim, inflictor, attacker ) )
hook.Add( "TTTEndRound", "EndOfRound", GiveWinOrLoss( result ) )
hook.Add( "UpdateLeaderboard", "UpdateLeaderboard", function() 
	SaveStats()
	GetStats()
	end)
