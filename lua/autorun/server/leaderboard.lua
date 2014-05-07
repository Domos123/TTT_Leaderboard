

function Initialize ()
	CreateTable()
end

function CalculateScore ( ply )
	
end

function CreateTable ()
	if not (sql.TableExists("player_info")) then
		query = "CREATE TABLE player_info ( unique_id varchar(255), innocentkills int, detectivekills int, traitorkills int, rdm int, wins int, losses int)"
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
	result = sql.Query("SELECT unique_id, innocentkills, detectivekills, traitorkills, rdm, wins, losses FROM player_info WHERE unique_id = '"..steamID.."'")
	if (result) then
		GetStats( ply )
	else
		NewPlayer( steamID, ply ) 
	end
end

function NewPlayer ( SteamID, ply )
	steamID = SteamID
	sql.Query( "INSERT INTO player_info (`unique_id`, `innocentkills`, `detectivekills`, `traitorkills`, `rdm`, `wins`, `losses`)VALUES ('"..steamID.."', '0', '0', '0', '0', '0', '0')" )
	result = sql.Query( "SELECT unique_id, innocentkills, detectivekills, traitorkills, rdm, wins, losses FROM player_info WHERE unique_id = '"..steamID.."'" )
	if (result) then
		sql_value_stats( ply )
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
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("innocentkills", innocentkills)
	ply:SetNWInt("detectivekills", detectivekills)
	ply:SetNWInt("traitorkills", traitorkills)
	ply:SetNWInt("rdm", rdm)
	ply:SetNWInt("wins", wins)
	ply:SetNWInt("losses", losses)
end

function SaveStats ( ply )
	unique_id = ply:GetNWString("SteamID")
	innocentkills = ply:GetNWInt("innocentkills")
	detectivekills = ply:GetNWInt("detectivekills")
	traitorkills = ply:GetNWInt("traitorkills")
	rdm = ply:GetNWInt("rdm")
	wins = ply:GetNWInt("wins")
	losses = ply:GetNWInt("losses")
	sql.Query("UPDATE player_info SET innocentkills = "..innocentkills..", detectivekills = "..detectivekills..", traitorkills = "..traitorkills..", rdm = "..rdm..", wins = "..wins..", losses = "..losses.." WHERE unique_id = '"..unique_id.."'")
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
	end
end
 
hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn", PlayerInitialSpawn )
hook.Add( "Initialize", "Initialize", Initialize )
hook.Add( "TTTEndRound", "EndOfRound", GiveWinOrLoss( result ) )