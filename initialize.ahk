#include, functions.ahk

if !A_IsAdmin && !%False%
{
    Run *RunAs "%A_ScriptFullPath%",, UseErrorLevel
    if !ErrorLevel
        ExitApp
}

for n, param in A_Args
{
    MsgBox Parameter number %n% is %param%.
}

if !ProcessExist("RiotClientServices.exe")
    goto isLeague
else
    SetTimer, isLeague, 2000

IfNotExist, %A_ScriptDir%\Data
{
    FileCreateDir, %A_ScriptDir%\Data
    FileCreateDir, %A_ScriptDir%\Data\ChampIcons
    FileCreateDir, %A_ScriptDir%\Data\Assets
}

IfNotExist, favChamps.txt
    FileAppend,, favChamps.txt

Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel
Menu, Tray, Tip, LeagueTool
Menu, Tray, Add, Reload, ReloadSub
Menu, Tray, Add, Exit, ExitSub
Menu, Tray, Add
global req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global Enabled := ComObjError(false)
staticData := "https://127.0.0.1:2999/liveclientdata/allgamedata"
eventData  := "https://127.0.0.1:2999/liveclientdata/eventdata"
statsData  := "https://127.0.0.1:2999/liveclientdata/gamestats"
path := detectRG()
global timeDic := {"a" : 0, "b" : 0, "c" : 0, "d" : 0, "e" : 0, "f" : 0, "g" : 0, "h" : 0}
inhibList := ["Barracks_T1_L1"
            , "Barracks_T1_C1"
            , "Barracks_T1_R1"
            , "Barracks_T2_L1"
            , "Barracks_T2_C1"
            , "Barracks_T2_R1"]
firstTime := 1
buttonOn := !buttonOn
assetsInDir := ["level4", "level5", "level6", "level7", "chest", "ownedChest"]
localPlayer := {"summonerName": "localName", "summonerID": 0}
fav := []
arrayAscii := {}
champNameId := {}
buttonState := {"ON": "Bench ✔️", "OFF": "Bench ❌"}
assetsDisplay := "Loading Assets"
recountModule := "                 RECOUNT - DAMAGE                 "
buffs := {"elder": 150, "baron": 180, "inhiSR": 300, "inhiARAM": 250}
tftCreate = {"queueId": 1110}
lobCreate = {"customGameLobby": {"configuration": {"gameMode": "PRACTICETOOL", "gameTypeConfig": {"id": 1}, "mapId": 11, "teamSize": 5}, "lobbyName": "W E L L"}, "isCustom": true}
loop 8
    toggle%A_Index% := 1

; global minimapElement1
; global minimapElement2
; global minimapElement3
; global minimapElement4
; global minimapElement5
; global minimapElement6
; global minimapElement7
; global minimapElement8

FileRead, vText, ascii.txt
Loop, Parse, vText, `n, `r
{
    if % InStr(A_LoopField, " = ") != 0
        splitString := StrSplit(A_LoopField, " = ")
    else
    {
        if % InStr(A_LoopField, chr(0302 0205)) != 0
            split .= A_LoopField "\n"
        if A_LoopField =
        { 
            StringTrimRight, split, split, 4
            arrayAscii[splitString[1]] := "{""body"": """ . split . """,""type"": ""chat""}"
            split := ""
        }
    }
}
for k in arrayAscii
    Menu, Submenu1, Add, %k%, asciiLines

Menu, Submenu3, Add, TFT Test, tft
Menu, Submenu3, Add, Info, lobInfo

if (Admin == True)
    Menu, tray, Add, Zoomies, zoomies

Menu, tray, Add, Ascii, :Submenu1
Menu, tray, Disable, Ascii
Menu, tray, Add, LobbyTools, :Submenu3
Menu, tray, Disable, LobbyTools
Menu, tray, Add, Loot Emporium, lootManage
Menu, tray, Add, Restart UX, resUX
Menu, tray, Add, Build, builds
Menu, tray, Disable, Build
Menu, tray, Add, U.gg, opgg


ChampDataObj := getDDragon("https://ddragon.leagueoflegends.com/api/versions.json")

DDver := ChampDataObj.version

IfNotExist, %A_ScriptDir%\Data\ChampIcons\Zyra.png
{
    SetTimer, Assets, 1000
    refreshAssets := 1
}
    

For k,v in ChampDataObj.data
{
    n2 := v.name
    n3 := v.key
    champNameId[n2] := n3
    IfNotExist, %A_ScriptDir%\Data\ChampIcons\%n2%.png
    {
        urlchamp := "http://ddragon.leagueoflegends.com/cdn/" . DDver . "/img/champion/" . v.id . ".png"
        UrlDownloadToFile, %urlchamp%, %A_ScriptDir%\Data\ChampIcons\%n2%.png
    }
}

For k, v in assetsInDir
    IfNotExist, %A_ScriptDir%\Data\Assets\%v%.png
    {
        switch v
        {
            case "level4":
                urlAssets := "https://i.ibb.co/txBh4KB/level4.png"
            case "level5":
                urlAssets := "https://i.ibb.co/prWzLW8/level5.png"
            case "level6":
                urlAssets := "https://i.ibb.co/mt565z1/level6.png"
            case "level7":
                urlAssets := "https://i.ibb.co/tb7xqz0/level7.png"
            case "chest":
                urlAssets := "https://i.ibb.co/LQYqYsz/chest.png"
            case "ownedChest":
                urlAssets := "https://i.ibb.co/DC112LX/owned-Chest.png"
        }
        UrlDownloadToFile, %urlAssets%, %A_ScriptDir%\Data\Assets\%v%.png
    }

Loop
{
    FileReadLine, line, %A_ScriptDir%\favChamps.txt, %A_Index%
    if ErrorLevel
        break
    for nameLine, idLine in champNameId
        if % line == nameLine
            fav.Push(idLine)
}

for kfav, vfav in fav
    for kChampName, vChampID in champNameId
    if % vfav == vChampID
{
    Menu, Submenu5, Insert, , %kChampName%, favvvv
    Menu, Submenu5, Icon, %kfav%&, %A_ScriptDir%\Data\ChampIcons\%kChampName%.png,,30
}
Menu, Submenu5, Insert, , DUMMY, favvvv
Menu, tray, Add, Favorites, :Submenu5
Menu, tray, Add, TurnOffFavs, favsoff

If refreshAssets
{
    SetTimer, Assets, off
    TransSplashText_Off()
    Reload
}
