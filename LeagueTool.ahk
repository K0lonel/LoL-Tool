#NoEnv
#SingleInstance, Force
#Persistent
SetBatchLines -1
SendMode Input
CoordMode Screen
CoordMode Mouse, Relative
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8

#Include, <JSONcoco>
#Include, <JSONFile>
#Include, hook.ahk
#Include, endpoints.ahk
#include, functions.ahk

if !A_IsAdmin && !%False%
{
    Run *RunAs "%A_ScriptFullPath%",, UseErrorLevel
    if !ErrorLevel
        ExitApp
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
recountModule := "                  RECOUNT - DAMAGE                  "
buffs := {"elder": 150, "baron": 180, "inhiSR": 300, "inhiARAM": 250}
tftCreate = {"queueId": 1110}
lobCreate = {"customGameLobby": {"configuration": {"gameMode": "PRACTICETOOL", "gameTypeConfig": {"id": 1}, "mapId": 11, "teamSize": 5}, "lobbyName": "W E L L"}, "isCustom": true}
loop 8
    toggle%A_Index% := 1

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

max_champs := ChampDataObj.data.Count()
For k,v in ChampDataObj.data
{
    n2 := v.name
    n3 := v.key
    champNameId[n2] := n3
    IfNotExist, %A_ScriptDir%\Data\ChampIcons\%n2%.png
    {
        TransSplashText_On("Loading assets: `n" A_Index "/" max_champs, "Arial Black")
        urlchamp := "http://ddragon.leagueoflegends.com/cdn/" . DDver . "/img/champion/" . v.id . ".png"
        UrlDownloadToFile, %urlchamp%, %A_ScriptDir%\Data\ChampIcons\%n2%.png
        TransSplashText_Off()
        refreshAssets := 1
    }
}
For k, v in assetsInDir
    IfNotExist, %A_ScriptDir%\Data\Assets\%v%.png
    {
        TransSplashText_On("Loading assets: `n" A_Index "/" assetsInDir.MaxIndex(), "Arial Black")
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
        TransSplashText_Off()
        refreshAssets := 1
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
    Reload

localPlayer.summonerName := APICall("GET", currSum).displayName, localPlayer.ID := APICall("GET", currSum).summonerID
chest := URL . "/lol-collections/v1/inventories/" . localPlayer.ID . "/champion-mastery"

SetTimer, checkGameState, 500
continueRun:

if (champSelect == 1 || endOfGame == 1)
{
    SetTimer, checkGameState, off
    recheckingConv:
    sleep 100
    conversation := APICall("GET", conver)
    convNr := conversation[conversation.Length()]

    if (convNr.type = "championSelect" || convNr.type = "postGame" || convNr.type = "customGame")
    {
        msgs := URL . "/lol-chat/v1/conversations/" . convNr.id . "/messages"

        if champSelect = 1
        {
            requestBody := JSON.Dump({"body": "Trash IRL","type": "celebration"})
            APICall("POST", msgs, requestBody)
            sessionChampSelect := APICall("GET", sessionCS)
            namesCS := []

            loop 5
                namesCS.Push(APICall("GET", URL . "/lol-summoner/v1/summoners/" . sessionChampSelect.myTeam[A_Index].summonerId).internalName)
            
            opggURL := "https://u.gg/multisearch?summoners=" . namesCS[1] . "," . namesCS[2] . "," . namesCS[3] . "," . namesCS[4] . "," . namesCS[5] . "&region=eun1"
            opggURLSelf := "https://u.gg/lol/profile/eun1/" . localPlayer.summonerName . "/live-game"
            Menu, tray, Enable, Build
            sessionChampSelect := APICall("GET", slotID)
            for k, v in sessionChampSelect.pinDropSummoners
                if % v.isLocalSummoner == true
                    champIDcall := URL . "/lol-champ-select/v1/summoners/" . v.slotId
            
            Gui collection:Color, 1a1a1a
            Gui collection:Font, s10 cDCDDD8, Arial Black
            Gui collection:+LastFound +AlwaysOnTop +ToolWindow
            WinSet, TransColor, 1a1a1a
            Gui collection:-Caption
            Gui collection:Add, Picture, vChangePicChest x0 y0 w20 h-1, %A_ScriptDir%\Data\Assets\chest.png
            Gui collection:Add, Picture, vChangePicCrest xp+20 w20 h-1, %A_ScriptDir%\Data\Assets\level4.png
            Gui collection:Add, Text, xp+3 yp-1 center vTextTokens w14 BackgroundTrans,
            Gui collection:Add, Text, xp+20 vTextPoints w120 BackgroundTrans,

            if buttonOn
                buttonStateV := buttonState.ON
            else
                buttonStateV := buttonState.OFF

            Gui collection:Add, Text, xp+1030 yp+7 center section vBench gBenchTURN BackgroundTrans, % buttonStateV
            Gui collection:Add, Text, xs-70 ys center gShuffleChamps BackgroundTrans, Shuffle

            SetTimer, refreshLeagueState, 10
            collection := APICall("GET", chest)
            SetTimer, refreshCS, 100
            repeatChampSearch:
            champID := StrSplit(StrSplit(detailChampSlot.championIconStyle, "champion-icons/")[2], ".")[1]
            if % champID == "" && httpstatus != 404
                goto repeatChampSearch
            if WinActive("ahk_exe LeagueClientUx.exe") && httpstatus != 404
            {
                for k,v in collection
                    if % (v.championId == champID && champID != champIDold)
                    {
                        champIDold := champID
                        if % v.chestGranted == true
                            GuiControl, collection:, ChangePicChest, %A_ScriptDir%\Data\Assets\chest.png
                        else
                            GuiControl, collection:, ChangePicChest, %A_ScriptDir%\Data\Assets\ownedChest.png
                        loop 7
                            if % v.championLevel == A_Index
                            {
                                masteryLevel := A_Index
                                if % A_Index <= 4
                                    masteryLevel := 4
                                GuiControl, collection:, ChangePicCrest, %A_ScriptDir%\Data\Assets\level%masteryLevel%.png
                                if % v.tokensEarned == 0
                                    GuiControl, collection:, TextTokens,
                                else
                                    GuiControl, collection:, TextTokens, % v.tokensEarned
                                if masteryLevel = 4
                                    GuiControl, collection:, TextPoints, % v.formattedChampionPoints " / " v.formattedMasteryGoal
                                else
                                    GuiControl, collection:, TextPoints, % v.formattedChampionPoints
                                break
                            }
                    }
            }
            if % benchCALL.benchEnabled == True && buttonOn && httpstatus != 404
                for kChamp, vChamp in fav
                    for kbench, vbench in benchCALL.benchChampionIds
                        if % vChamp == vbench
                        {
                            if % HasVal(fav, champID) == False
                            {
                                APICall("POST", swapBench . vbench)
                                break, 2
                            }
                            else
                                for kkChamp, vvChamp in fav
                            {
                                if % vvChamp == champID
                                    if % kChamp < kkChamp
                                    APICall("POST", swapBench . vbench)
                            }
                            champID := StrSplit(StrSplit(detailChampSlot.championIconStyle, "champion-icons/")[2], ".")[1]
                        }
            if httpstatus = 404
            {
                SetTimer, refreshCS, off
                SetTimer, refreshLeagueState, off
                Gui collection:Destroy
                champSelect := 0
                champIDold := ""
                SetTimer, checkGameState, 500
            }
            else
                goto repeatChampSearch
}

if endOfGame = 1
{
    global eogChampName := []
    global eogTotalDamage := []
    global totalTeamDPS := 0
    sleep 500
    eogStats := APICall("GET", eogStatsBlock)
    loop 5
    {
        for k, v in eogStats.teams[1].players[A_Index]
            if % k == "championName"
            {
                if % v == "Nunu & Willump"
                    v := "Nunu"
                eogChampName.Push(v)
            }
                
        for k, v in eogStats.teams[1].players[A_Index].stats
            if % k == "TOTAL_DAMAGE_DEALT_TO_CHAMPIONS"
                eogTotalDamage.Push(v)
    }
    for k, v in eogTotalDamage
        totalTeamDPS := v + totalTeamDPS

    APICall("POST", msgs, displayDPS(recountModule, "celebration"))
    loop
    {
        sleep 300
        actualStateEND := APICall("GET", gameFlow)
        if (actualStateEND = "None" || actualStateEND = "Lobby" || actualStateEND = "Matchmaking")
        {
            endOfGame := 0
            break
        }
    }

    SetTimer, checkGameState, 500
    }
}
else
    goto recheckingConv
}

if inGame = 1
{
    SetTimer, checkGameState, off
    gameCombined := {}
    loop
    {
        APICall("GET", staticData)
        sleep 500
        if httpstatus = 200
        {
            sleep 2000
            notUpdateGame := APICall("GET", staticData)
            break
        }
    }
    for k,v in notUpdateGame.allPlayers
        gameCombined[v.summonerName] := v.championName

    SetTimer, refresher, 3000
    SetTimer, oneSec, 1000

    WinGetPos,,, W, H, ahk_exe League of Legends.exe
    Gui timer:Color, 1a1a1a
    Gui timer:Font, s10 cLime, Arial Black
    Gui timer:+LastFound +AlwaysOnTop +ToolWindow +Disabled
    WinSet, TransColor, 1a1a1a
    Gui timer:-Caption
    Gui timer:Margin, 0, 0

    loop 8
        Gui timer:Add, Text, xm ym w30 center section BackgroundTrans vminimapElement%A_Index%, 
    
    if % notUpdateGame.gameData.mapName == "Map11"
    {
        respawnTimer := 300
        map := "Map11"
    }
    Else
    {
        respawnTimer := 250
        map := "notSr"
    }

    loop
    {
        sleep 3000
        if httpstatus =
        {
            SetTimer, refresher, off
            SetTimer, oneSec, off
            Gui timer: Destroy

            loop 8
                toggle%A_Index% := 1

            firstTime := 1
            inGame := 0
            endOfGame := 0
            champSelect := 0
            break
        }
    }
    SetTimer, checkGameState, 500
}
return



checkGameState:
    actualState := APICall("GET", gameFlow)
    switch actualState
    {
        case "None":
            Menu, tray, Disable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
        case "Lobby":
            Menu, tray, Enable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
        case "Matchmaking":
            Menu, tray, Enable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
        case "ReadyCheck":
            APICall("POST", accept)
            Menu, tray, Disable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
        case "ChampSelect":
            champSelect := 1
            Menu, tray, Enable, Ascii
            Menu, tray, Enable, Build
            Menu, tray, Disable, LobbyTools
            Goto, continueRun
        return
        case "InProgress":
            inGame := 1
            Menu, tray, Disable, Ascii
            Menu, tray, Enable, Build
            Menu, tray, Disable, LobbyTools
            Goto, continueRun
        return
        case "EndOfGame":
            endOfGame := 1
            Menu, tray, Enable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
    }
return

asciiLines:
    conversation := APICall("GET", conver)
    loop % conversation.Length()
    {
        convNr := conversation[A_Index]
        if (convNr.type == "Matchmaking" || convNr.type == "lobby")
            break
    }
    msgs := URL . "/lol-chat/v1/conversations/" . convNr.id . "/messages"
    requestBodyLOL := arrayAscii[A_ThisMenuItem]
    APICall("POST", msgs, requestBodyLOL)
return

$F9::
    if % (actualState == "Lobby" || actualState == "Matchmaking" || actualState == "CheckedIntoTournament")
    {
        conversation := APICall("GET", conver)
        convNr := conversation[conversation.Length()]
        if % (convNr.type == "customGame" || convNr.type == "clash")
            msgs := URL . "/lol-chat/v1/conversations/" . convNr.id . "/messages"
    }
    APICall("POST", msgs, displayDPS(recountModule, "chat"))
return

opgg:
    if % actualState == "InProgress"
        run %opggURLSelf%
    else
    {
        if opggURL !=
            run %opggURL%
        else
            run % "https://u.gg/lol/profile/eun1/" . localPlayer.summonerName . "/overview"
    }
return

builds:
    for k, v in champNameId
        if % champID == v
        {
            StringLower, lowered, k
            lowered := StrReplace(lowered, ".", "")
            lowered := StrReplace(lowered, "'", "")
            lowered := StrReplace(lowered, A_Space, "")
            lowered := StrReplace(lowered, "glasc", "")
            lowered := StrReplace(lowered, "&willump", "")
            ; lowered := RegexReplace(x, "\.|'|&|willump|glasc")
            run % "https://lolalytics.com/lol/" . lowered . "/build/"
        }
return

$F8::
lootManage:
    APICall("POST", refreshLoot)
    deChampID := {}
    playerAllLoot := APICall("GET", playerLoot)
    collection := APICall("GET", chest)
    for kLoot, vLoot in playerAllLoot
    {
        if % vLoot.displayCategories == "CHAMPION"
            if % vLoot.count > 2
            {
                lootID := vLoot.lootId
                lootID2 = ["%lootID%"]
                APICall("POST", tokenCraft[3], lootID2)
            }
            Else
                deChampID[vLoot.storeItemId] := vLoot.count
        if % vLoot.displayCategories == "CHEST" && vLoot.refId > 0
            if % vLoot.lootName == "CHAMPION_TOKEN_6" && vLoot.count == 2
            {
                refID := vLoot.refId
                lootID2 = ["CHAMPION_TOKEN_6-%refID%", "CHAMPION_RENTAL_%refID%"]
                APICall("POST", tokenCraft[1], lootID2)
            }
            else if % vLoot.lootName == "CHAMPION_TOKEN_7" && vLoot.count == 3
            {
                refID := vLoot.refId
                lootID2 = ["CHAMPION_TOKEN_7-%refID%", "CHAMPION_RENTAL_%refID%"]
                APICall("POST", tokenCraft[2], lootID2)
            }
    }
    for kChamp, vChamp in collection
        for kChampID, vChampID in deChampID
            if % vChamp.championId == kChampID
            {
                if % vChamp.championLevel == 6
                    if % vChampID == 2
                {
                    lootID2 = ["CHAMPION_RENTAL_%kChampID%"]
                    APICall("POST", tokenCraft[3], lootID2)
                }
                if % vChamp.championLevel == 7
                {
                    lootID2 = ["CHAMPION_RENTAL_%kChampID%"]
                    loop % vChampID
                        APICall("POST", tokenCraft[3], lootID2)
                }
            }
return

$+`::
pt:
    APICall("POST", lobby, lobCreate)
return

tft:
    APICall("POST", lobby, tftCreate)
return

resUX:
    APICall("POST", restartUX)
return

lobInfo:
    clipboard := JSON.Dump(APICall("GET", lobby))
    run "https://jsonformatter.org/json-parser"
return

refreshLeagueState:
    WinGetPos, xLOL, yLOL,,, ahk_exe LeagueClientUx.exe
    if WinActive("ahk_exe LeagueClientUx.exe")
        if !WinExist("ahk_class AutoHotkeyGUI")
        Gui collection:Show, NA x%xLOL% y%yLOL% w1200 h30
    else
        WinMove, %xLOL%, %yLOL%
    else if !WinActive("ahk_exe LeagueClientUx.exe") && WinExist("ahk_class AutoHotkeyGUI")
        Gui collection:Hide
return

benchTURN:
    buttonOn := !buttonOn
    if buttonOn
        GuiControl,, Bench, % buttonState.ON
    else
        GuiControl,, Bench, % buttonState.OFF
return

favvvv:
    if GetKeyState("Shift")
        goto deleteSubmenu
    for kChampName, vChampID in champNameId
        if % champID == vChampID && HasVal(fav, champID) == False
    {
        Menu, Submenu5, Insert, %A_ThisMenuItem%, %kChampName%, favvvv
        minusOne := A_ThisMenuItemPos - 1
        Menu, Submenu5, Icon, %minusOne%&, %A_ScriptDir%\Data\ChampIcons\%kChampName%.png,,30
        fav.InsertAt(minusOne, champID)
        goto deleteChampion
    }
return

deleteSubmenu:
    for kChampName, vChampID in champNameId
        if % kChampName == A_ThisMenuItem
        fav.RemoveAt(A_ThisMenuItemPos)
    Menu, Submenu5, Delete, %A_ThisMenuItem%
    goto deleteChampion
return

deleteChampion:
    FileDelete, %A_ScriptDir%\favChamps.txt
    for kDel, vDel in fav
        for kChampName, vChampID in champNameId
        if % vDel == vChampID
        varr .= kChampName "`n"
    FileAppend, %varr%, %A_WorkingDir%\favChamps.txt
    varr := ""
return

isLeague:
    If !ProcessExist("LeagueClientUx.exe")
    {
        SetTimer, isLeague, off
        TransSplashText_On("League was not detected, program will exit.", "Segoe UI")
        sleep 3000
        ExitApp
    }
    if (buff := WinExist("BUFF App - Startgame")) || (buff := WinExist("BUFF App - Endgame"))
        WinClose, ahk_id %buff%
return

ShuffleChamps:
    SetTimer, refreshCS, off
    loop 3
        for kbenchChampionIds, vbenchChampionIds in benchCALL.benchChampionIds
            APICall("POST", swapBench . vbenchChampionIds)
    SetTimer, refreshCS, 100
return

refreshCS:
    detailChampSlot := APICall("GET", champIDcall)
    benchCALL := APICall("GET", sessionCS)
return

refreshData:
    currentGame := APICall("GET", staticData)
return

spellPicker:
    loop 55
    {
        spellList = {"spell1Id": 4, "spell2Id": %A_Index%}
        APICall("PATCH", spells, spellList)
        tooltip % A_Index
        sleep 100
        tooltip,
    }
return

refresher:
liveEvents := APICall("GET", eventData)
liveStats  := APICall("GET", statsData)


jf := new JSONFile(path)
for k, v in jf.Object().files[1].sections
    if (v.name == "HUD")
        for k, v in v.settings
            if (v.name == "MinimapScale")
                mapScale := v.value

wh := 155 + mapScale*51.66
scaleM := -200 - 101*mapScale*0.66

if (oldMapScale != mapScale) || firstTime
{
    oldMapScale := mapScale
    if firstTime
        firstTime := ""
    minimapElementPOS:= {"1drake"   : "x" wh/1.63 "y" wh/1.5
                        ,"2baron"   : "x" wh/3.5  "y" wh/3.8
                        ,"3b_Tinhi" : "x" wh/30   "y" wh/1.37
                        ,"4b_Minhi" : "x" wh/6.1  "y" wh/1.33
                        ,"5b_Binhi" : "x" wh/5.4  "y" wh/1.13
                        ,"6r_Tinhi" : "x" wh/1.43 "y" wh/20
                        ,"7r_Minhi" : "x" wh/1.37 "y" wh/5.6
                        ,"8r_Binhi" : "x" wh/1.16 "y" wh/5}

    Gui timer:Show, % "x" W + scaleM "y" H + scaleM "w" wh "h" wh "NoActivate", minimapCover

    for monster, xy in minimapElementPOS
        GuiControl, timer:Move, minimapElement%A_Index%, % xy
}

if (map == "Map11")
    for k,v in liveEvents.Events
    {
        if (toggle1 == True) && (v.DragonType == "Elder") && (liveStats.gameTime <= v.EventTime + buffs.elder)
        {
            timeDic.a := floor(v.EventTime + buffs.elder - liveStats.gameTime)
            toggle1 := "toggle1"
        }
        if (toggle2 == True) && (v.EventName == "BaronKill") && (liveStats.gameTime <= v.EventTime + buffs.baron)
        {
            timeDic.b := floor(v.EventTime + buffs.baron - liveStats.gameTime)
            toggle2 := "toggle2"  
        }

        if (v.EventName == "InhibKilled")
            if (liveStats.gameTime <= v.EventTime + respawnTimer)
            {
                loop 6
                {
                    index :=  A_Index + 2
                    letter2 := chr(index + 96)
                    if (toggle%index% == True) && (v.InhibKilled == inhibList[A_Index])
                    {
                        timeDic[letter2] := floor(v.EventTime + respawnTimer - liveStats.gameTime)
                        toggle%index% := "toggle" index
                    }  
                }
            }
    }
else
    for k,v in liveEvents.Events
        if (v.EventName == "InhibKilled")
            if (liveStats.gameTime <= v.EventTime + respawnTimer)
            {
                loop 2
                {
                    index :=  A_Index * 3 + 1
                    letter2 := chr(index + 96)
                    if (toggle%index% == True) && (v.InhibKilled == inhibList[index - 2])
                    {
                        timeDic[letter2] := floor(v.EventTime + respawnTimer - liveStats.gameTime)
                        toggle%index% := "toggle" index
                    }  
                }
            }
return



oneSec:

loop 8
{
    if (toggle%A_Index% != True)
    {
        letter := chr(A_Index + 96)
        toggle%A_Index% := timeEdit(toggle%A_Index%, letter, timeDic[letter], A_Index)
    }
}        
return

ExitSub:
    ExitApp
return

ReloadSub:
    Reload
return

^r::Reload