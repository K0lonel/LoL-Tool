#NoEnv
#SingleInstance, Force
#Persistent
SendMode Input
CoordMode Screen
CoordMode Mouse, Relative
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8

#include, <JSON>
#include, initialize.ahk
#include, endpoints.ahk

localPlayer.summonerName := APICall("GET", currSum).displayName, localPlayer.ID := APICall("GET", currSum).summonerID
chest := URL . "/lol-collections/v1/inventories/" . localPlayer.ID . "/champion-mastery"

SetTimer, checkGameState, 500
continueRun:

if % champSelect == 1 || endOfGame == 1
{
    SetTimer, checkGameState, off
    recheckingConv:
    sleep 100
    conversation := APICall("GET", conver)
    convNr := conversation[conversation.Length()]

    if (convNr.type = "championSelect" || convNr.type = "postGame" || convNr.type = "customGame")
    {
        msgs := URL . "/lol-chat/v1/conversations/" . convNr.id . "/messages"
        Menu, tray, Enable, Ascii

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
            Menu, tray, Disable, Ascii
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
        friendsIngame := []

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

        SetTimer, refreshData, 1000
        Gui timer:Color, 1a1a1a
        Gui timer:Font, s10 cDCDDD8, Arial Black
        Gui timer:+LastFound +AlwaysOnTop +ToolWindow
        WinSet, TransColor, 1a1a1a
        Gui timer:-Caption
        Gui timer:Add, Text, y+20 vT2 w70 BackgroundTrans,

        if % notUpdateGame.gameData.mapName == "Map11"
        {
            respawnTimer := 300
            Gui timer:Add, Text, yp-20 vT1 w80 BackgroundTrans,
            Gui timer:Add, Text, yp+40 vT3 w80 BackgroundTrans,
            Gui timer:Add, Text, yp+20 vElderBuff w80 BackgroundTrans,
            Gui timer: Add, Text, yp+20 vBaronBuff w90 BackgroundTrans,
            map := "Map11"
        }
        Else
        {
            map := "notSr"
            respawnTimer := 250
        }
        Gui timer: Show, NA x0 y120 w100 h100
        for k, v in notUpdateGame.allPlayers
            if % v.summonerName == localPlayer.summonerName
                ownerTeam := v.team
        if % ownerTeam == "ORDER"
            inhiDisplay := "Barracks_T2"
        else
            inhiDisplay := "Barracks_T1"
        conversations := APICall("GET", conver)
        for kConver, vConver in conversations
            for kFriendName, vFriendName in gameCombined
                if % vConver.gameName == kFriendName
                    friendsIngame.Push(vConver.id)
        loop
        {
            sleep 1000
            for k,v in currentGame.events.Events
            {
                if % (v.EventName == "InhibKilled")
                    if % currentGame.gameData.gameTime <= v.EventTime + respawnTimer
                    {
                        laneInhi := v.InhibKilled
                        if % laneInhi == inhiDisplay . "_C1"
                        {
                            midTimer := "Mid " floor(v.EventTime + respawnTimer - currentGame.gameData.gameTime) "s"
                            GuiControl, timer:, T2, % midTimer
                        }
                        if % currentGame.gameData.mapName == "Map11"
                        {
                            if % laneInhi == inhiDisplay . "_L1"
                            {
                                topTimer := "Top " floor(v.EventTime + respawnTimer - currentGame.gameData.gameTime) "s"
                                GuiControl, timer:, T1, % topTimer
                            }
                            if % laneInhi == inhiDisplay . "_R1"
                            {
                                botTimer := "Bot " floor(v.EventTime + respawnTimer - currentGame.gameData.gameTime) "s"
                                GuiControl, timer:, T3, % botTimer
                            }
                        }
                    }
                if % (v.DragonType == "Elder")
                    if % currentGame.gameData.gameTime <= v.EventTime + buffs.elder
                    {
                        elderBuffTimer := "Elder " floor(v.EventTime + buffs.elder - currentGame.gameData.gameTime) "s"
                        GuiControl, timer:, ElderBuff, % elderBuffTimer
                    }
                if % (v.EventName == "BaronKill")
                    if % currentGame.gameData.gameTime <= v.EventTime + buffs.baron
                    {
                        baronBuffTimer := "Baron " floor(v.EventTime + buffs.baron - currentGame.gameData.gameTime) "s"
                        GuiControl, timer:, BaronBuff, % baronBuffTimer
                    }
            }
            if httpstatus =
            {
                SetTimer, refreshData, off
                Gui timer: Destroy
                midTimer := ""
                topTimer := ""
                topTimer := ""
                elderBuffTimer := ""
                baronBuffTimer := ""
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
            Menu, tray, Disable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Enable, LobbyTools
            Goto, continueRun
        return
        case "ReadyCheck":
            APICall("POST", accept)
            Goto, continueRun
        return
        case "ChampSelect":
            champSelect := 1
            Menu, tray, Disable, LobbyTools
            Goto, continueRun
        return
        case "InProgress":
            inGame := 1
            Menu, tray, Disable, Ascii
            Menu, tray, Disable, Build
            Menu, tray, Disable, LobbyTools
            Goto, continueRun
        return
        case "EndOfGame":
            endOfGame := 1
            Goto, continueRun
        return
    }
return

asciiLines:
    requestBodyLOL := arrayAscii[A_ThisMenuItem]
    APICall("POST", msgs, requestBodyLOL)
return

$F8::
    for kFriendsInGame, vFriendsInGame in friendsIngame
    {
        msgss := URL . "/lol-chat/v1/conversations/" . vFriendsInGame . "/messages"
        if % map == "Map11"
            dataFriends = {"body": "\n %topTimer% \n %midTimer% \n %botTimer% \n %elderBuffTimer% \n %baronBuffTimer%","type": "chat"}
        else
            dataFriends = {"body": "\n %midTimer%","type": "chat"}
        APICall("POST", msgss, dataFriends)
    }
return

$F9::
    if % (actualState == "Lobby" || actualState == "Matchmaking")
    {
        conversation := APICall("GET", conver)
        convNr := conversation[conversation.Length()]
        if % convNr.type == "customGame"
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
            run % "https://lolalytics.com/lol/" . lowered . "/build/"
        }
return

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

assets:
    if % assetsDisplay == "Loading Assets..."
    {
        TransSplashText_Off()
        assetsDisplay := "Loading Assets"
    }
    else
        assetsDisplay := assetsDisplay . "."
    TransSplashText_On(assetsDisplay, "Arial Black")
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

ExitSub:
    ExitApp
return

ReloadSub:
    Reload
return

^r::Reload