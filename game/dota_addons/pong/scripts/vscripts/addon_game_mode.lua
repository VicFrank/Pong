require('timers')

PADDLESPEED = 15 --the relevant version of this is in the javascript
BALLSPEED = 20
MAXBOUNCEANGLE = 5*3.1416/12 --75 degrees in radians
MAXSCORE = 20

leftPanelPosition = 330
leftPanelVelocity = 0
rightPanelPosition = 330
rightPanelVelocity = 0
ballPositionX = 600
ballPositionY = 400
ballVelocityX = BALLSPEED
ballVelocityY = 0
player1score = 0
player2score = 0

if GameMode == nil then
	GameMode = class({})
end

function Precache( context )
	PrecacheResource( "soundfile", "soundevents/custom_sounds.vsndevts", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS,  1 )
end

function GameMode:InitGameMode()
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
	
	CustomGameEventManager:RegisterListener( "game_over", Dynamic_Wrap(GameMode, "GameOver") )
	CustomGameEventManager:RegisterListener( "player_input", Dynamic_Wrap(GameMode, "PlayerInput") )
end

function GameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameMode:OnGameInProgress()
	end
end

function GameMode:OnGameInProgress()
	Timers:CreateTimer(0,GameMode.Update, GameMode)
end
 
function GameMode:PlayerInput( args )
	--2 = GOODGUYS
	--3 = BADGUYS
	local team = args['teamID']
	local velocity = args['velocity']
	if(team == 2) then
		leftPanelVelocity = velocity
	elseif(team == 3) then
		rightPanelVelocity = velocity
	end
end

function GameMode:UpdateLeftPaddle()
	leftPanelPosition = leftPanelPosition + leftPanelVelocity
	if(not(leftPanelPosition <= 652 and leftPanelPosition >= 0)) then
		leftPanelPosition = leftPanelPosition - leftPanelVelocity
		leftPanelVelocity = 0
	end
end

function GameMode:UpdateRightPaddle()
	rightPanelPosition = rightPanelPosition + rightPanelVelocity
	if(not(rightPanelPosition <= 652 and rightPanelPosition >= 0)) then
		rightPanelPosition = rightPanelPosition -rightPanelVelocity
		rightPanelVelocity = 0
	end
end

function GameMode:UpdateBall()
	--left paddle collision
	if(ballPositionX >= 30 and ballPositionX + ballVelocityX < 30) then
		--find the distance of the ball from the current center of the panel
		local intersect = leftPanelPosition + (170/2) - ballPositionY
		if(math.abs(intersect) <= 170/2) then
			EmitGlobalSound("sounds/pong.vsnd")
			--normalize the distance and multiply it by the maximum bounce angle
			local normalizedIntersect = (intersect/(170/2))
			local bounceAngle = normalizedIntersect * MAXBOUNCEANGLE
			ballVelocityX = BALLSPEED*math.cos(bounceAngle)
			ballVelocityY = BALLSPEED*-math.sin(bounceAngle)
		end
	--right paddle collision
	elseif(ballPositionX <= 1140 and ballPositionX + ballVelocityX > 1140 ) then
		local intersect = rightPanelPosition + (170/2) - ballPositionY
		if(math.abs(intersect) <= 170/2) then
			EmitGlobalSound("sounds/pong.vsnd")
			local normalizedIntersect = (intersect/(170/2))
			local bounceAngle = normalizedIntersect * MAXBOUNCEANGLE
			ballVelocityX = -BALLSPEED*math.cos(bounceAngle)
			ballVelocityY = BALLSPEED*-math.sin(bounceAngle)
		end
	end
	
	--top or bottom wall collision
	if(ballPositionY >= 775 or ballPositionY <= 0) then
		ballVelocityY = -ballVelocityY
	end
	
	--left or right wall collision
	if(ballPositionX <= 0) then
		player1score = player1score + 1
		local score =
		{
			score_team = 1,
			current_score = player1score
		}
		CustomGameEventManager:Send_ServerToAllClients( "score", score )
		ballVelocityX = BALLSPEED
		ballVelocityY = 0
		ballPositionX = 600
		ballPositionY = 400
		if(player1score >= MAXSCORE) then
			GameRules:SetGameWinner(3)
		end
	elseif(ballPositionX >= 1200) then
		player2score = player2score + 1
		local score =
		{
			score_team = 2,
			current_score = player2score
		}
		CustomGameEventManager:Send_ServerToAllClients( "score", score )
		ballVelocityX = -BALLSPEED
		ballVelocityY = 0
		ballPositionX = 600
		ballPositionY = 400
		--see if someone's won
		if(player2score > MAXSCORE) then
			GameRules:SetGameWinner(3)
		end
	end
	
	ballPositionX = ballPositionX + ballVelocityX
	ballPositionY = ballPositionY + ballVelocityY
	
	--print( ballPositionX .. "," .. ballPositionY )
end

function GameMode:Update()
	GameMode:UpdateLeftPaddle()
	GameMode:UpdateRightPaddle()
	GameMode:UpdateBall()
	local game_status_update =
	{
		leftPanelY = leftPanelPosition,
		rightPanelY = rightPanelPosition,
		ballX = ballPositionX,
		ballY = ballPositionY
	}
	CustomGameEventManager:Send_ServerToAllClients( "game_status_update", game_status_update )
	return 1/30
end