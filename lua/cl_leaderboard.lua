
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

--concommand.Add( "Leaderboard", function() 
	--local ply = LocalPlayer()
	--plyTable = hook.Call( "UpdateTTTLeaderboard" )
	--PrintTable( plyTable )
--end )
	
--timer.Create( "UpdateLeaderboard" , 10 , function()
	--net.Recieve( "LBData", function( len )
		--plyData = net.ReadTable()
		--for k,ply in pairs( plyData ) do
			
		--end
	--end)
--end)

-- hook.Add( "PlayerSay", 0, function ( ply, text, team )
    -- if ( text == "!leaderboard" ) then
        -- leaderBoard:MakePopup()) 
    -- end
-- end )

concommand.Add( "Leaderboard", function()
ply = LocalPlayer()
chat.AddText( ply:GetNWInt("innocentkills") ..",".. ply:GetNWInt("detectivekills") ..",".. ply:GetNWInt("traitorkills") ..",".. ply:GetNWInt("rdm") ..",".. ply:GetNWInt("wins") ..",".. ply:GetNWInt("losses") ..",".. ply:GetNWInt("score") )
end)