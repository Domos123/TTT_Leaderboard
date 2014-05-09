
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
	PlayerList:AddColumn( "Score" )
	PlayerList:SortByColumn( 8 )
	
	for k, ply in pairs(data) do
		PlayerList:AddLine(ply[8],ply[1],ply[2],ply[3],ply[4],ply[5],ply[6],ply[7])
	end
	
	LBPanel:MakePopup()
end

concommand.Add( "TTTLB", DrawLeaderboard )

timer.Create( "TTTLBDataSyncClient", 1, 0, function() 
	net.Receive( "TTTLBData", function( len )
		data = net.ReadTable()
	end)
end )
