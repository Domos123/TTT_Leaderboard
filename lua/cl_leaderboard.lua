
function DrawLeaderboard()
	local LBPanel = vgui.Create( "DFrame" )
	Scrw = ScrW()
	Scrh = ScrH()
	LBPanel:SetPos( Scrw * 0.15, Scrh * 0.15 ) -- Position form on your monitor
	LBPanel:SetSize( Scrw * 0.7, math.Clamp( 75 + ( 20 * table.getn( player.GetAll() ) ), 0, Scrh * 0.7 ) ) -- Size form
	LBPanel:SetTitle( "Leaderboard" ) -- Form set name
	LBPanel:SetVisible( true ) -- Form rendered ( true or false )
	LBPanel:SetDraggable( false ) -- Form draggable
	LBPanel:ShowCloseButton( true ) -- Show buttons panel
	
	local PlayerList = vgui.Create( "DListView", LBPanel )
	PlayerList:SetPos( 20,40 )
	PlayerList:SetSize( ( Scrw * 0.7 ) - 40, math.Clamp( 15 + ( 20 * table.getn( player.GetAll() ) ), 0, ( Scrh * 0.7 ) - 60 ) )
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
	
	for k, v in pairs(player.GetAll()) do
		PlayerList:AddLine(v:Nick(),v:GetNWInt("innocentkills"),v:GetNWInt("detectivekills"),v:GetNWInt("traitorkills"),v:GetNWInt("rdm"),v:GetNWInt("wins"),v:GetNWInt("losses"),v:GetNWInt("score"))
	end
	
	LBPanel:MakePopup()
end

concommand.Add( "TTTLB", DrawLeaderboard )
