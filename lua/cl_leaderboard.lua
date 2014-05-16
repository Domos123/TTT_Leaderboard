
local data = {}

function DrawLeaderboard()
	local LBPanel = vgui.Create( "DFrame" )
	local Scrw = ScrW()
	local Scrh = ScrH()
	LBPanel:SetPos( Scrw * 0.15, Scrh * 0.15 ) -- Position form on your monitor
	LBPanel:SetSize( Scrw * 0.7, math.Clamp( 76 + ( 17 * table.getn( data ) ), 0, Scrh * 0.7 ) ) -- Size form
	LBPanel:SetTitle( "Leaderboard" ) -- Form set name
	LBPanel:SetVisible( true ) -- Form rendered ( true or false )
	LBPanel:SetDraggable( false ) -- Form draggable
	LBPanel:ShowCloseButton( true ) -- Show buttons panel
	
	local PlayerList = vgui.Create( "DListView", LBPanel )
	PlayerList:SetPos( 20,40 )
	PlayerList:SetSize( ( Scrw * 0.7 ) - 40, math.Clamp( 16 + ( 17 * table.getn( data ) ), 0, ( Scrh * 0.7 ) - 60 ) )
	PlayerList:SetMultiSelect( false )
	PlayerList:AddColumn( "Name" )
	PlayerList:AddColumn( "Innocent Kills" )
	PlayerList:AddColumn( "Detective Kills" )
	PlayerList:AddColumn( "Traitor Kills" )
	PlayerList:AddColumn( "Bad Kills" )
	PlayerList:AddColumn( "Wins" )
	PlayerList:AddColumn( "Losses" )
	PlayerList:AddColumn( "Playtime" )
	PlayerList:AddColumn( "Score" )
	PlayerList.OnClickLine = function(parent,selected,isselected) parent:ClearSelection() end
	
	table.sort( data, function( a,b ) return (a[7] + 0) > (b[7] + 0) end )
	
	for k, ply in pairs(data) do
		ply[8] = FormatTime( ply[8] )
		PlayerList:AddLine(ply[9],ply[1],ply[2],ply[3],ply[4],ply[5],ply[6],ply[8],ply[7])
	end
	
	LBPanel:MakePopup()
end

function GetDataFromServer()
	net.Receive( "TTTLBData", function( len )
		data = net.ReadTable()
	end)
end

function FormatTime( thetime )
	seconds = math.floor( thetime + 0.5 )
	minutes = math.floor( ( seconds / 60 ) + 0.5 )
	hours = math.floor( minutes / 60 )
	minutes = math.floor( minutes - ( hours * 60 ) )
	if ( string.len( hours ) == 1 ) then
		hours = "0" .. hours
	end
	if ( string.len( minutes ) == 1 ) then
		minutes = "0" .. minutes
	end
	return hours .. ":" .. minutes
end

function DoLeaderboard( ply )
		ply:ConCommand( "TTTLBUpdate" )
		GetDataFromServer()
		timer.Simple( 0.3, DrawLeaderboard )
end 

keypressed = false
function CheckKeys()
	if input.IsKeyDown( KEY_F9 ) and not keypressed then
		keypressed = true
		DoLeaderboard( LocalPlayer() )
	elseif keypressed and not input.IsKeyDown( KEY_F9 ) then
		keypressed = false
	end
end

concommand.Add( "TTTLB", function( ply, cmd, args )	DoLeaderboard( ply ); end )

hook.Add( "PlayerSay", "TTTLB ChatCommand", function( ply, txt, public )
	if ( txt == "!TTTLB") then
        ply:ConCommand( "TTTLB" )
		timer.Simple( 0.2, DrawLeaderboard )
    end
end )
hook.Add("Think", "TTTLB Think", CheckKeys )
