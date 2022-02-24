DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")
shell := ComObjCreate("wscript.shell")
exec := (shell.exec(comspec " /c wmic process where ""caption='LeagueClientUx.exe'"" get Commandline"))
cmd := exec.stdout.readall()
port := SubStr(cmd, InStr(cmd, "--app-port=") + 11, 5)
tokenStr := SubStr(cmd, InStr(cmd, "--remoting-auth-token=") + 22, 22)
token := "riot:" . tokenStr
global tokenENC := b64Encode(token)
URL := "https://127.0.0.1:" . port

spells := URL . "/lol-champ-select/v1/session/my-selection"
gameFlow := URL . "/lol-gameflow/v1/gameflow-phase"
currSum := URL . "/lol-summoner/v1/current-summoner"
conver := URL . "/lol-chat/v1/conversations"
sessionCS := URL . "/lol-champ-select/v1/session"
accept := URL . "/lol-matchmaking/v1/ready-check/accept"
lobby := URL . "/lol-lobby/v2/lobby"
restartUX := URL . "/riotclient/kill-and-restart-ux"
refreshLoot := URL . "/lol-loot/v1/refresh?force=true"
slotID := URL . "/lol-champ-select/v1/pin-drop-notification"
eogStatsBlock := URL . "/lol-end-of-game/v1/eog-stats-block"
playerLoot := URL . "/lol-loot/v1/player-loot-map"
friendList := URL . "/lol-chat/v1/friends"
reroll := URL . "/lol-champ-select/v1/session/my-selection/reroll"
swapBench := URL . "/lol-champ-select/v1/session/bench/swap/"
tokenCraft := [URL . "/lol-loot/v1/recipes/CHAMPION_TOKEN_6_redeem_withshard/craft", URL . "/lol-loot/v1/recipes/CHAMPION_TOKEN_7_redeem_withshard/craft", URL . "/lol-loot/v1/recipes/CHAMPION_RENTAL_disenchant/craft"]