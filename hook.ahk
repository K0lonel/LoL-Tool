DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")
shell := ComObjCreate("wscript.shell")
exec := (shell.exec(comspec " /c wmic process where ""caption='LeagueClientUx.exe'"" get Commandline"))
cmd := exec.stdout.readall()
port := SubStr(cmd, InStr(cmd, "--app-port=") + 11, 5)
tokenStr := SubStr(cmd, InStr(cmd, "--remoting-auth-token=") + 22, 22)
token := "riot:" . tokenStr

global tokenENC := b64Encode(token)
global URL := "https://127.0.0.1:" . port