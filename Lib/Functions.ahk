#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

;HotKeys
F1:: {
    moveWindow()
}
F2:: {
    InitializeMacro()
}
F3:: {
    Reload()
}
F4:: {
    ;DetectSlayerTask()
    TogglePause()
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}
 
 ;Minimizes the UI
 minimizeUI(*){
    aaMainUI.Minimize()
 }
 
 Destroy(*){
    aaMainUI.Destroy()
    ExitApp
 }

 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
 ;Gets the current time
 getCurrentTime() {
     currentHour := A_Hour
     currentMinute := A_Min
     currentSecond := A_Sec
 
     return Format("{:d}h.{:02}m.{:02}s", currentHour, currentMinute, currentSecond)
 }



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text
    
    ; Hide all dropdowns first
    BossDropDown.Visible := false
    MonsterDropDown.Visible := false
    MinigameDropDown.Visible := false
    SlayerDropDown.Visible := false
    
    if (selected = "Bosses") {
        BossDropDown.Visible := true
        mode := "Bosses"
    } else if (selected = "Monsters") {
        MonsterDropDown.Visible := true
        mode := "Monsters"
    } else if (selected = "Minigames") {
        MinigameDropDown.Visible := true
        mode := "Minigames"
    } else if (selected = "Slayer") {
        SlayerDropDown.Visible := true
        mode := "Slayer"
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }
    if (ModeDropdown.Text = "Bosses") {
        if (BossDropDown.Text = "") {
            AddToLog("Please select a Boss before confirming")
            return
        }
        AddToLog("Selected " BossDropDown.Text)
    }
    else if (ModeDropdown.Text = "Monsters") {
        if (MonsterDropDown.Text = "") {
            AddToLog("Please select a Monster before confirming")
            return
        }
        AddToLog("Selected " MonsterDropDown.Text)
    } else {
        AddToLog("Selected " ModeDropdown.Text " mode")
    }

    AddToLog("Please make sure your Runelite resolution is 816 x 638")

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    BossDropDown.Visible := false
    MonsterDropDown.Visible := false
    MinigameDropDown.Visible := false
    SlayerDropDown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    Hotkeytext3.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

FixClickWithSleep(x, y, timer, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(timer)
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

FindAndClickColor(targetColor, searchArea := [0, 0, GetWindowCenter(gameID).Width, GetWindowCenter(gameID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 1)) {
        ; Color found, click on the detected coordinates
        FixClick(foundX + 10, foundY + 5, "Left")
        AddToLog("Color found and clicked at: X" foundX " Y" foundY)
        return true

    }
}

FindAndClickMob(targetColor, searchArea := [61, 73, 538, 389]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 2)) {
        ; Color found, click on the detected coordinates
        FixClick(foundX + 5, foundY + 10, "Left")
        AddToLog("Mob found and clicked at: X" foundX " Y" foundY)
        return true

    }
}

FindAndClickMobs(targetColors, searchArea := [61, 73, 538, 389]) {
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    for color in targetColors {
        if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 2)) {
            FixClick(foundX + 5, foundY + 10, "Left")
            AddToLog("Mob found and clicked at: X" foundX " Y" foundY " with color: " color)
            return true
        }
    }
}

FindAndClickMobsWithVerify(targetColors, searchArea := [61, 73, 538, 389], verifyColor := 0xFFFF0000) {
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    for color in targetColors {
        if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 0)) {
            MouseMove(foundX, foundY)
            Sleep (700)
            ; Perform secondary search for verification color in a wider area
            if (PixelSearch(&verifyX, &verifyY, foundX - 25, foundY - 25, foundX + 25, foundY + 25, verifyColor, 2)) {
                FixClick(foundX, foundY, "Left")
                AddToLog("Mob found and verified! Clicked at: X" foundX " Y" foundY)
                return true
            } else {
                AddToLog("Color match found, but verification color not detected. Skipping click.")
            }
        }
    }

    return false  ; No valid mob found
}

FindAndClickImage(imagePath, searchArea := [0, 0, A_ScreenWidth, A_ScreenHeight]) {

    AddToLog(imagePath)

    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the image search
    if (ImageSearch(&foundX, &foundY, x1, y1, x2, y2, imagePath)) {
        ; Image found, click on the detected coordinates
        FixClick(foundX, foundY, "Left")
        AddToLog("Image found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

FindAndClickText(textToFind, searchArea := [0, 0, GetWindowCenter(gameID).Width, GetWindowCenter(gameID).Height]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the text search
    if (FindText(&foundX, &foundY, x1, y1, x2, y2, textToFind)) {
        ; Text found, click on the detected coordinates
        FixClick(foundX, foundY, "Right")
        AddToLog("Text found and clicked at: X" foundX " Y" foundY)
        return true
    }
}

CheckForHealthBar() {
    ; Perform the Find Text search
    if (ok := FindText(&X, &Y, 6, 66, 130, 89, 0, 0, HealthBarNew)) {
        return true

    }
    return false
}

CheckForHealthBarNoFindText() {
    searchArea := [7, 67, 128, 89]
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, 0x1F722B, 0)) {
        Sleep (100)
        return true
    }
    return false
}

GetColorForMob(color) {
    switch color {
        case "Sarachnis": return 0x391411
        case "Electric Wyrm": return 0x0C0F1D
        case "Tormented Demons": return 0x985450 ;return 0x8D5805
        case "Snow Imps": return 0x1F54A6
        case "Vanguards" : return 0xDD5009
        case "Magma Beasts" : return 0x2D1003
        case "Elysian Nagau" : return 0x324649 ;return 0x11B0BC\
        case "Spectral Nagau" : return 0x5322B6
        case "Arcane Nagau": return 0xC25A09
    }
}

GetColorsForMob(mobName) {
    colors := Map(
        "Electric Demon", [0x0C203E, 0x0C203E],
        "Tekton", [0xDF7210, 0x282424],
        "Arcane Nagua", [0xC05708, 0xC05708],
        "Elysian Nagua", [0x324649, 0x11B0BC],
        "Spectral Nagua", [0x5322B6, 0x34255E],
        "Vanguards", [0xDD5009, 0xDD5009],
        "Electric Wyrm", [0x0C0F1D, 0x0C0F1D],
        "Magma Beast", [0x2D1003, 0x2D1003],
        "Sarachnis", [0x391411, 0x391411],
        "Galvek", [0x55120E, 0x55120E],
        "Tormented Demon", [0x985450, 0x8D5805],
        "Snow Imps", [0x1F54A6, 0x000000],
        "Shadow Corp", [0x7D8682, 0x7D8682], ;0x79827D/0x838D88/0x535A57
        "Night Beast", [0x3D7175, 0x3D7175]
    )
    return colors.Has(mobName) ? colors[mobName] : [0x000000, 0x000000]  ; Default fallback
}

ClickCoordsForPrayerPotion(PrayerPosition) {
    switch PrayerPosition {
        case "1": return { x: 635, y: 290 }
        case "2": return { x: 685, y: 290 }
        case "3": return { x: 735, y: 290 }
        case "4": return { x: 785, y: 290 }
        case "5": return { x: 635, y: 330 }
        case "6": return { x: 685, y: 330 }
        case "7": return { x: 735, y: 330 }
        case "8": return { x: 785, y: 330 }
        case "9": return { x: 635, y: 370 }
        case "10": return { x: 685, y: 370 }
        case "11": return { x: 735, y: 370 }
        case "12": return { x: 785, y: 370 }
        case "13": return { x: 635, y: 410 }
        case "14": return { x: 685, y: 410 }
        case "15": return { x: 735, y: 410 }
        case "16": return { x: 785, y: 410 }
        case "17": return { x: 635, y: 450 }
        case "18": return { x: 685, y: 450 }
        case "19": return { x: 735, y: 450 }
        case "20": return { x: 785, y: 450 }
        case "21": return { x: 635, y: 490 }
        case "22": return { x: 685, y: 490 }
        case "23": return { x: 735, y: 490 }
        case "24": return { x: 785, y: 490 }
        case "25": return { x: 635, y: 530 }
        case "26": return { x: 685, y: 530 }
        case "27": return { x: 735, y: 530 }
        case "28": return { x: 785, y: 530 }
    }
}

RestorePrayerIfNeeded(PrayerPosition) {
    foundX := foundY := 0
    if (AutoPrayerBox.Value) {
        if (PixelSearch(&foundX, &foundY, 598, 124, 616, 135, 0xFFFF00, 3) ; First color check
            || PixelSearch(&foundX, &foundY, 598, 124, 616, 135, 0xFCA607, 3)) { ; Second color check
            clickCoords := ClickCoordsForPrayerPotion(PrayerPosition)
            AddToLog("Detected low prayer, restoring...")
            FixClick(700, 560) ; Open Inventory
            Sleep(500)
            FixClick(clickCoords.x, clickCoords.y) ; Click on prayer potion
            Sleep 500
            FixClick(700, 560) ; Close Inventory
            Sleep(500)
        }
    }
}

RestoreHealthIfNeeded(FoodPosition) {
    foundX := foundY := 0
    if (AutoFoodBox.Value) {
        if (PixelSearch(&foundX, &foundY, 598, 124, 616, 135, 0xFFFF00, 3) ; First color check
            || PixelSearch(&foundX, &foundY, 598, 124, 616, 135, 0xFCA607, 3)) { ; Second color check
            clickCoords := ClickCoordsForFood(FoodPosition)
            AddToLog("Detected low health, restoring...")
            FixClick(700, 560) ; Open Inventory
            Sleep(500)
            FixClick(clickCoords.x, clickCoords.y) ; Click on prayer potion
            Sleep 500
            FixClick(700, 560) ; Close Inventory
            Sleep(500)
        }
    }
}

ClickCoordsForFood(FoodPosition) {
    switch FoodPosition {
        case "1": return { x: 635, y: 290 }
        case "2": return { x: 685, y: 290 }
        case "3": return { x: 735, y: 290 }
        case "4": return { x: 785, y: 290 }
        case "5": return { x: 635, y: 330 }
        case "6": return { x: 685, y: 330 }
        case "7": return { x: 735, y: 330 }
        case "8": return { x: 785, y: 330 }
        case "9": return { x: 635, y: 370 }
        case "10": return { x: 685, y: 370 }
        case "11": return { x: 735, y: 370 }
        case "12": return { x: 785, y: 370 }
        case "13": return { x: 635, y: 410 }
        case "14": return { x: 685, y: 410 }
        case "15": return { x: 735, y: 410 }
        case "16": return { x: 785, y: 410 }
        case "17": return { x: 635, y: 450 }
        case "18": return { x: 685, y: 450 }
        case "19": return { x: 735, y: 450 }
        case "20": return { x: 785, y: 450 }
        case "21": return { x: 635, y: 490 }
        case "22": return { x: 685, y: 490 }
        case "23": return { x: 735, y: 490 }
        case "24": return { x: 785, y: 490 }
        case "25": return { x: 635, y: 530 }
        case "26": return { x: 685, y: 530 }
        case "27": return { x: 735, y: 530 }
        case "28": return { x: 785, y: 530 }
    }
}

BankItems(LoadoutPosition) {
    FixClick(700, 580) ; Open Inventory
    Sleep(500)
    AddToLog("Checking for Frozen Fragments...")
    CheckForFrozenFragment()
    FixClick(700, 580) ; Close Inventory
    Sleep(500)
    Send("^b") ; Sends Control + B
    Sleep(1000)
    SendInput("{Enter}")
    Sleep(1500)
    FixClick(525, 150) ; Click Preset
    Sleep(1000)
    LoadPreset(LoadoutPosition) ; Click Selected Preset
    FixClick(130, 400) ; Load Preset
    Sleep(1000)
    FixClick(537, 120) ; Close Preset
    Sleep(1000)
}

LoadPreset(LoadoutPosition) {
    currentLoadout := ClickCoordsForLoadout(LoadoutPosition)
    FixClick(currentLoadout.x, currentLoadout.y)
    Sleep(1000)

}

ClickCoordsForLoadout(LoadoutPosition) {
    switch LoadoutPosition {
        case "1": return { x: 120, y: 180 }
        case "2": return { x: 120, y: 210 }
        case "3": return { x: 120, y: 240 }
    }
}

ReactivatePrayers(ProtectionPrayer, BuffPrayer) {
    if (AutoPrayerBox.Value) {
        AddToLog("Reactivating prayers...")
        curretPrayer := ClickCoordsForPrayer(ProtectionPrayer)
        curretBuffPrayer := ClickCoordsForBuffPrayer(BuffPrayer)
    
        FixClick(760, 580) ; Click Prayers
        Sleep(1000)
    
        FixClick(curretPrayer.x, curretPrayer.y)
        Sleep(1000)
    
        FixClick(curretBuffPrayer.x, curretBuffPrayer.y)
        Sleep(1000)
    
        FixClick(760, 580) ; Click Prayers to close
        Sleep(1000)
    }
}

ClickCoordsForPrayer(ProtectionPrayer) {
    switch ProtectionPrayer {
        case "Magic": return { x: 670, y: 440 }
        case "Melee": return { x: 750, y: 440 }
        case "Ranged": return { x: 710, y: 440 }
    }
}

ClickCoordsForBuffPrayer(BuffPrayer) {
    switch BuffPrayer {
        case "Augory": return { x: 710, y: 480 }
        case "Piety": return { x: 640, y: 480 }
        case "Rigour": return { x: 670, y: 480 }
    }
}

CheckForFrozenFragment() {
    ; Check for frozen fragments
    if (ok := FindText(&X, &Y, 607, 291, 799, 552, 0, 0, FrozenFragment)) {
        Sleep(500)
        AddToLog("Found some frozen fragments, claiming...")
        FixClick(X, Y)
        Sleep(1000)
        return true
    }
    return false
}

CheckInCombat() {
    loop {
        Sleep(200)
        ; Check for health bar
        if (ok := FindText(&X, &Y, 0, 34, 138, 98, 0, 0, HealthBar)) {
            AddToLog("Found Health Bar - In Combat")
            Sleep(1000)
            break
        }
        RestartStage()
    }
}

CheckForInactive() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 391, 31, 446, 54, 0, 0, InactiveWave)) {
        return true
    }
    return false
}


ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

WaitForNoHealthBar() {
    Sleep 500
    Loop {
        if !(ok := CheckForHealthBarNoFindText()) {
            Break  ; Exit loop when HP bar is gone
        }
        Sleep 1500  ; Check every 1.5 seconds
    }
}

CheckForAFKDetection() {
    afkChecks := Map(
        "Cooking", AFKCooking,
        "Smithing", AFKSmithing,
        "Farming", AFKFarming
    )
    
    for name, afkText in afkChecks {
        if FindText(&X, &Y, 0, 465, 513, 632, 0, 0, afkText) {
            AddToLog("Found " name " AFK Check")
            FixClick(X, Y)  ; Click immediately after detecting the AFK check
            return true
        }
    }
}

CheckIfInSpawn() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 322, 195, 505, 276, 0, 0, Spawn)) {
            break
        }
    }
    AddToLog("Found in spawn, restarting selected mode")
    return StartSelectedMode()
}

CheckForDisconnect() {
    global ProtectionPrayer, BuffPrayer
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    if (ok := FindText(&X, &Y, 211, 492, 444, 550, 0, 0, Login)) {
        Sleep(500)
        AddToLog("Disconnect/Server Shutdown detected, restarting selected mode")
        ClickUntilGone(0, 0, 211, 492, 444, 550, Login, 0, 0)
        Sleep(1000)
        ReactivatePrayers(currentPrayer, currentBuffPrayer)
        Sleep(1000)
        StartSelectedMode()
        return true
    }
}

CloseChat() {
    FixClickWithSleep(40, 620, 1000)
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/6DWgB9XMTV")
}