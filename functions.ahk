APICall(method, site, request := "", j := True)
{
    static
    req.Open(method, site, False)
    req.setRequestHeader("Content-Type", "application/json")
    req.setRequestHeader("Accept", "application/json")
    req.setRequestHeader("Authorization", "Basic " . tokenENC)
    req.Option(4) := 0x3300
    if % (method == "POST" || method == "PUT" || method == "PATCH")
        req.Send(request)
    else
        req.Send()
    global httpstatus := req.Status
    Arr := req.responseBody
    pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
    length := Arr.MaxIndex() + 1
    if % j == True
        return JSON.Load(StrGet(pData, length, "UTF-8"))
    return StrGet(pData, length, "UTF-8")
}

b64Encode(string)
{
    VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    VarSetCapacity(buf, size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    return StrGet(&buf)
}

displayDPS(module, sendtype)
{
    loop 5
        dpsLines .= TransformDigits(eogTotalDamage[A_Index]) " " calculateDPS(eogTotalDamage[A_Index]) " " eogChampName[A_Index] "`n"     
    Return JSON.Dump({"body": "­`n____________________________________`n"
            . module 
            . "`n‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾⎺`n"
            . dpsLines
            . "____________________________________","type": sendtype})
}

calculateDPS(numberDPS := 0)
{
    static a := "█"
    static b := "░"
    dpsGraphNumber := ceil(35/(round(totalTeamDPS, -3)/numberDPS))
    if % dpsGraphNumber > 16
        dpsGraphNumber := 16
    loop % dpsGraphNumber
        dpsGraph .= a
    loop % 16-dpsGraphNumber
        dpsGraph .= b
    return dpsGraph
}

TransformDigits(m := 0)
{
    n := round(m / 1000)
    loop, % StrLen(n)
        out .= Chr(Asc(SubStr(n, A_Index, 1)) + 65248)
    if % n < 10
        return "　　" out "Ｋ"
    else if % n <= 100
        return "　" out "Ｋ"
    return out "Ｋ"
}

ProcessExist(Name)
{
    Process, Exist, %Name%
    return Errorlevel
}

HasVal(haystack, needle) {
    if !(IsObject(haystack)) || (haystack.Length() = 0)
        return False
    for index, value in haystack
        if (value = needle)
        return True
    return False
}

getDDragon(url)
{
    req.Open("GET", url, false)
    req.Send()
    VersionDataObj := JSON.Load(req.ResponseText)
    ChampDataURL := "http://ddragon.leagueoflegends.com/cdn/" . VersionDataObj[1] . "/data/en_US/champion.json"
    req.Open("GET", ChampDataURL)
    req.Send()
    return JSON.Load(req.ResponseText())
}

TransSplashText_On(Text="",Font="",TC="White", TS = "20", xPos = "center", yPos = "center")
{
    Gui, 99:Font, S%TS% C%TC%, %Font%
    Gui, 99:Add, Text, x10 y10 BackgroundTrans, %Text%
    Gui, 99:Color, 1a1a1a
    Gui, 99:+LastFound +AlwaysOnTop +ToolWindow
    WinSet, TransColor, 1a1a1a
    Gui, 99:-Caption
    Gui, 99:Show, x%xPos% y%yPos% AutoSize NoActivate
    return
}

TransSplashText_Off()
{
    TransSplashText := ""
    Gui, 99:Destroy
    return
}