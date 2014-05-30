local tttdata = {}
local dmdata = {}
local data = {}

function DrawLeaderboard()
	if data[1] == nil or tttdata[1] == nil or dmdata[1] == nil then
		drawText( "Data Not Cached - Wait for End of Round", nil, nil, nil )
		return
	end
	
	local LBPanel = vgui.Create( "DFrame" )
	local Scrw = ScrW()
	local Scrh = ScrH()
	local left = Scrw * 0.1
	local top = Scrh * 0.1
	local wide = Scrw * 0.8
	local tall = math.Clamp( 52 + ( 17 * table.getn( tttdata ) ), 0, Scrh * 0.8 )
	
	LBPanel:SetPos( left,top ) -- Position form on your monitor
	LBPanel:SetSize( wide,tall ) -- Size form
	LBPanel:SetTitle( "Leaderboard" ) -- Form set name
	LBPanel:SetVisible( true ) -- Form rendered ( true or false )
	LBPanel:SetDraggable( false ) -- Form draggable
	LBPanel:ShowCloseButton( false ) -- Show buttons panel
	
	local Tabs = vgui.Create( "DPropertySheet", LBPanel )
	Tabs:SetPos( 0,0 )
	Tabs:SetSize( wide, tall )
	
	local PlayerList = vgui.Create( "DListView", Tabs )
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
	
	local DmPlayerList = vgui.Create( "DListView", Tabs )
	DmPlayerList:SetMultiSelect( false )
	DmPlayerList:AddColumn( "Name" )
	DmPlayerList:AddColumn( "Kills" )
	DmPlayerList:AddColumn( "Deaths" )
	DmPlayerList:AddColumn( "Ratio" )
	DmPlayerList.OnClickLine = function(parent,selected,isselected) parent:ClearSelection() end
	
	local DButton = vgui.Create( "DButton", LBPanel )
	DButton:SetPos( wide - 37, 2 )
	DButton:SetText( "X" )
	DButton:SetSize( 35, 17 )
	DButton.DoClick = function()
		LBPanel:Remove()
	end
		
	table.sort( tttdata, function( a,b ) return (a[7] + 0) > (b[7] + 0) end )
	table.sort( dmdata, function( a,b ) return (a[3] + 0) > (b[3] + 0) end )
	
	for k, ply in pairs(tttdata) do
		ply[8] = FormatTime( ply[8] )
		PlayerList:AddLine(ply[9],ply[1],ply[2],ply[3],ply[4],ply[5],ply[6],ply[8],ply[7])
	end
	
	for k, ply in pairs(dmdata) do
		ply[3] = math.floor((ply[3] * 1000) + 0.5) / 1000
		DmPlayerList:AddLine(ply[4],ply[1],ply[2],ply[3])
	end
	
	Tabs:AddSheet( "Leaderboard", PlayerList, "icon16/medal_gold_2.png" )
	Tabs:AddSheet( "Deathmatch", DmPlayerList, "icon16/star.png" )
	
	LBPanel:MakePopup()
end

function GetDataFromServer()
	net.Receive( "TTTLBData", function( len )
		data = net.ReadTable()
		if not(data[1] == nil) then
			tttdata = data[1]
		end
		if not(data[2] == nil) then
			dmdata = data[2]
		end
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
		timer.Simple( 0.5, DrawLeaderboard )
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

function drawText( msg, color, duration, fade ) -- "Borrowed" from ULib's csayDraw
	color = color or Color( 255, 255, 255, 255 )
	duration = duration or 5
	fade = fade or 0.5
	local start = CurTime()

	local function drawToScreen()
		local alpha = 255
		local dtime = CurTime() - start

		if dtime > duration then -- Our time has come :'(
			hook.Remove( "HUDPaint", "TTTLB Draw" )
			return
		end

		if fade - dtime > 0 then -- beginning fade
			alpha = (fade - dtime) / fade -- 0 to 1
			alpha = 1 - alpha -- Reverse
			alpha = alpha * 255
		end

		if duration - dtime < fade then -- ending fade
			alpha = (duration - dtime) / fade -- 0 to 1
			alpha = alpha * 255
		end
		color.a  = alpha

		draw.DrawText( msg, "TargetID", ScrW() * 0.5, ScrH() * 0.25, color, TEXT_ALIGN_CENTER )
	end

	hook.Add( "HUDPaint", "TTTLB Draw", drawToScreen )
end

concommand.Add( "TTTLB", function( ply, cmd, args )	DoLeaderboard( ply ); end )

hook.Add( "PlayerSay", "TTTLB ChatCommand", function( ply, txt, public )
	if ( txt == "!TTTLB") then
        ply:ConCommand( "TTTLB" )
		timer.Simple( 0.2, DrawLeaderboard )
    end
end )
hook.Add("Think", "TTTLB Think", CheckKeys )
