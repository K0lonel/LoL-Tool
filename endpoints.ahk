﻿DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")
shell := ComObjCreate("wscript.shell")
exec := (shell.exec(comspec " /c wmic process where ""caption='LeagueClientUx.exe'"" get Commandline"))
cmd := exec.stdout.readall()
port := SubStr(cmd, InStr(cmd, "--app-port=") + 11, 5)
tokenStr := SubStr(cmd, InStr(cmd, "--remoting-auth-token=") + 22, 22)
token := "riot:" . tokenStr
global tokenENC := b64Encode(token)
global URL := "https://127.0.0.1:" . port

global spells := URL . "/lol-champ-select/v1/session/my-selection"
global gameFlow := URL . "/lol-gameflow/v1/gameflow-phase"
global currSum := URL . "/lol-summoner/v1/current-summoner"
global conver := URL . "/lol-chat/v1/conversations"
global sessionCS := URL . "/lol-champ-select/v1/session"
global accept := URL . "/lol-matchmaking/v1/ready-check/accept"
global lobby := URL . "/lol-lobby/v2/lobby"
global restartUX := URL . "/riotclient/kill-and-restart-ux"
global refreshLoot := URL . "/lol-loot/v1/refresh?force=true"
global slotID := URL . "/lol-champ-select/v1/pin-drop-notification"
global eogStatsBlock := URL . "/lol-end-of-game/v1/eog-stats-block"
global playerLoot := URL . "/lol-loot/v1/player-loot-map"
global friendList := URL . "/lol-chat/v1/friends"
global reroll := URL . "/lol-champ-select/v1/session/my-selection/reroll"
global swapBench := URL . "/lol-champ-select/v1/session/bench/swap/"
global tokenCraft := [URL . "/lol-loot/v1/recipes/CHAMPION_TOKEN_6_redeem_withshard/craft", URL . "/lol-loot/v1/recipes/CHAMPION_TOKEN_7_redeem_withshard/craft", URL . "/lol-loot/v1/recipes/CHAMPION_RENTAL_disenchant/craft"]