"use strict";
//based on the implementation of pong described here: http://gamedev.stackexchange.com/questions/4253/in-pong-how-do-you-calculate-the-balls-direction-when-it-bounces-off-the-paddl

var PADDLESPEED = 15;

function Score( event )
{
	var scorePanel = $.GetContextPanel().FindChildInLayoutFile( "score" + event.score_team );
	var score = scorePanel.GetAttributeInt( "score", 0 );
	scorePanel.text = event.current_score;
}

function Update( event )
{
	var parentPanel = $.GetContextPanel();
	var leftPaddlePanel = parentPanel.FindChildInLayoutFile( "left_paddle" );
	var rightPaddlePanel = parentPanel.FindChildInLayoutFile( "right_paddle" );
	var ballPanel = parentPanel.FindChildInLayoutFile( "ball" );
	
	leftPaddlePanel.style.marginTop = event.leftPanelY + "px";
	rightPaddlePanel.style.marginTop = event.rightPanelY + "px";
	ballPanel.style.marginLeft = event.ballX + "px";
	ballPanel.style.marginTop = event.ballY + "px";
}

function OnUpArrowPressed( )
{
	var team = Game.GetLocalPlayerInfo().player_team_id;
	GameEvents.SendCustomGameEventToServer( "player_input", { "teamID": team, "velocity": -PADDLESPEED } );
}

function OnUpArrowReleased()
{
	var team = Game.GetLocalPlayerInfo().player_team_id;
	GameEvents.SendCustomGameEventToServer( "player_input", { "teamID": team, "velocity": 0 } );
}

function OnDownArrowPressed( )
{
	var team = Game.GetLocalPlayerInfo().player_team_id;
	GameEvents.SendCustomGameEventToServer( "player_input", { "teamID": team, "velocity": PADDLESPEED } );
}

function OnDownArrowReleased()
{
	var team = Game.GetLocalPlayerInfo().player_team_id;
	GameEvents.SendCustomGameEventToServer( "player_input", { "teamID": team, "velocity": 0 } );
}

GameEvents.Subscribe( "game_status_update", Update);
GameEvents.Subscribe( "score", Score);
Game.AddCommand( "+CustomGameTestButton", OnUpArrowPressed, "", 0 );
Game.AddCommand( "-CustomGameTestButton", OnUpArrowReleased, "", 0 );
Game.AddCommand( "+CustomGameTestButton2", OnDownArrowPressed, "", 0 );
Game.AddCommand( "-CustomGameTestButton2", OnDownArrowReleased, "", 0 );