
-- Scrw, Scrh = ScrW(), ScrH()

-- local leaderBoard = vgui.Create( "DPanel" )
-- leaderBoard:SetPos( Scrw * 0.2, Scrh * 0.2 )
-- leaderBoard:SetSize( Scrw * 0.6, Scrh * 0.6 )
-- leaderBoard:SetTitle( "Leaderboard" )
-- leaderBoard:SetVisible( true )
-- leaderBoard:SetDraggable( false )
-- leaderBoard:ShowCloseButton( true )

-- local playerList = vgui.Create( "DListView" )
-- playerList:SetParent( LeaderBoard )
-- playerList:SetPos( 25,50 )
-- playerList:SetSize( (Scrw * 0.6) - 50, (Scrh * 0.6) - 100 )
-- playerList:SetMultiSelect( false )
-- playerList:SortByColumn( 8 )
-- playerList:AddColumn( "Name" )
-- playerList:AddColumn( "I Kills" )
-- playerList:AddColumn( "D Kills" )
-- playerList:AddColumn( "T Kills" )
-- playerList:AddColumn( "Bad Kills" )
-- playerList:AddColumn( "Wins" )
-- playerList:AddColumn( "Losses" )
-- playerList:AddColumn( "Score" )

-- for k, v in pairs(player.GetAll()) do
	-- playerList:AddLine(v:Nick(),v:GetNWInt("innocentkills"),v:GetNWInt("detectivekills"),v:GetNWInt("traitorkills"),v:GetNWInt("rdm"),v:GetNWInt("wins"),v:GetNWInt("losses"),v:GetNWInt("score"))
-- end

concommand.Add( "Leaderboard", function() 
		hook.Run("UpdateLeaderboard")
		local ply = LocalPlayer()
		chat.AddText( ply:GetNWInt("innocentkills") )
		chat.AddText( ply:GetNWInt("detectivekills") )
		chat.AddText( ply:GetNWInt("traitorkills") )
		chat.AddText( ply:GetNWInt("rdm") )
		chat.AddText( ply:GetNWInt("wins") )
		chat.AddText( ply:GetNWInt("losses") )
		chat.AddText( ply:GetNWInt("wins") )
		chat.AddText( ply:GetNWInt("score") )
		end )

-- hook.Add( "PlayerSay", 0, function ( ply, text, team )
    -- if ( text == "!leaderboard" ) then
        -- leaderBoard:MakePopup()) 
    -- end
-- end )