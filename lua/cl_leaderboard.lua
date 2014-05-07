
Scrw, Scrh = ScrW(), ScrH()

local LeaderBoard = vgui.Create( "DScrollPanel" )
LeaderBoard:SetPos( Scrw * 0.2, Scrh * 0.2 )
LeaderBoard:SetSize( Scrw * 0.6, Scrh * 0.6 )
LeaderBoard:SetTitle( "Leaderboard" )
LeaderBoard:SetVisible( true )
LeaderBoard:SetDraggable( false )
LeaderBoard:ShowCloseButton( true )
LeaderBoard:SetMouseInputEnabled(true)

local PlayerList = vgui.Create( "DListView" )
PlayerList:SetParent( LeaderBoard )
PlayerList:SetPos( 25,50 )
PlayerList:SetSize( (Scrw * 0.6) - 50, (Scrh * 0.6) - 100 )
PlayerList:SetMultiSelect( false )
PlayerList:SortByColumn( 8 )
PlayerList:AddColumn( "Name" )
PlayerList:AddColumn( "I Kills" )
PlayerList:AddColumn( "D Kills" )
PlayerList:AddColumn( "T Kills" )
PlayerList:AddColumn( "Bad Kills" )
PlayerList:AddColumn( "Wins" )
PlayerList:AddColumn( "Losses" )
PlayerList:AddColumn( "Score" )

for k, v in pairs(player.GetAll()) do
	PlayerList:AddLine(v:Nick(),v:GetNWInt("innocentkills"),v:GetNWInt("detectivekills"),v:GetNWInt("traitorkills"),v:GetNWInt("rdm"),v:GetNWInt("wins"),v:GetNWInt("losses"),v:GetNWInt("score"))
end

concommand.Add( "Leaderboard", function() LeaderBoard:MakePopup() end )

hook.Add( "PlayerSay", 0, function ( ply, text, team )
    if ( text == "!leaderboard" ) then
        LeaderBoard:MakePopup()
    end
end )