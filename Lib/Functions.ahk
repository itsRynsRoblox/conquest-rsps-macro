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
    FixClick(220, 210)
    ;TogglePause()
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

LookForFireball(targetColor := 0x7B3306, searchArea := [61, 73, 538, 389]) {
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]
    if (ok :=  PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 1)) {
        MoveBackAndForth()
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

FindAndClickMobsWithVerify(targetColors, searchArea := [0, 28, 589, 469], verifyColor := 0xFFFF0000) {
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    for color in targetColors {
        if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 0)) {
            MouseMove(foundX, foundY)
            Sleep (700)
            ; Perform secondary search for verification color in a wider area
            if (PixelSearch(&verifyX, &verifyY, foundX - 25, foundY - 25, foundX + 25, foundY + 25, verifyColor, 2)) {
                global SuccessfulX, SuccessfulY  ; Allow storing the found position
                SuccessfulX := foundX
                SuccessfulY := foundY
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
        "Electric Wyrm", [0x171D38, 0x171D38],
        "Magma Beast", [0x2D1003, 0x2D1003],
        "Sarachnis", [0x812925, 0x6E221E], ;0x391411
        "Galvek", [0x55120E, 0x55120E],
        "Tormented Demon", [0x985450, 0x8D5805],
        "Snow Imps", [0x1F54A6, 0x000000],
        "Shadow Corp", [0x6D7570, 0x6D7570], ;0x79827D/0x838D88/0x535A57
        "Abyssal Kurask", [0x3D5B1D, 0x2E4316],
        "Fury Drake", [0x171414, 0xB30F06], ; Body / Red Glow
        "Night Beast", [0x1A1A26, 0x3D7175], ;Back / Glow Under
        "Shadow Nihil", [0x402E56, 0x402E56],
        "Pyrelord", [0xFF6332, 0xCB9139], ; Body / Ground Circle
        "Wyvern", [0x545F54, 0x4477AD], ; Zorkath Minion (0x545F54) 0x4A4241
        "Zorkath", [0x44AF78, 0x221E1E]
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
            CheckAndOpenPanelIfNeeded("Inventory")
            Sleep(500)
            FixClick(clickCoords.x, clickCoords.y) ; Click on prayer potion
            Sleep 500
            ;FixClick(700, 560) ; Close Inventory
            ;Sleep(500)
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
            CheckAndOpenPanelIfNeeded("Inventory")
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
    CheckAndOpenPanelIfNeeded("Inventory")
    Sleep(500)
    AddToLog("Checking for Frozen Fragments...")
    CheckForFrozenFragment()
    Sleep(500)
    Send("^b") ; Sends Control + B
    Sleep(1000)
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
    if (!AutoPrayerBox.Value) 
        return  ; Exit if AutoPrayer is not enabled
    
    AddToLog("Reactivating prayers...")

    curretPrayer := ClickCoordsForPrayer(ProtectionPrayer)
    curretBuffPrayer := ClickCoordsForBuffPrayer(BuffPrayer)

    ; Open PrayerTab if not already open
    CheckAndOpenPanelIfNeeded("PrayerTab")
    Sleep(1000)

    ; Click the prayers
    ActivatePrayerIfInactive(ProtectionPrayer)
    Sleep(1000)

    ActivatePrayerIfInactive(BuffPrayer)
    Sleep(1000)

    ; Close PrayerTab
    FixClick(760, 580)
    Sleep 1000
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

CheckForSpawn() {
    ; Check for spawn booths
    if (ok := FindText(&X, &Y, 186, 177, 231, 230, 0, 0, InformationBooth)) {
        AddToLog("Found in spawn, restarting...")
        return true
    }
    return false
}

CheckForInactive() {
    ; Check for inactive wave text
    if (ok := FindText(&X, &Y, 391, 31, 446, 54, 0, 0, InactiveWave)) {
        return true
    }
    return false
}

CheckIfAlreadyUnderAttack() {
    ; Check for under attack text
    if (ok := FindText(&X, &Y, 9, 573, 493, 590, 0, 0, UnderAttack)) {
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
    Sleep 1000
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

CheckAndOpenPanelIfNeeded(panel) {
    Panels := Map()
    Panels["PlayerPanel"] := { coords: [642, 563, 673, 595], clickCoords: [660, 580] }
    Panels["PrayerTab"] := { coords: [742, 563, 771, 594], clickCoords: [760, 580] }
    Panels["Inventory"] := { coords: [675, 564, 706, 594], clickCoords: [700, 580] }

    if !Panels.Has(panel) {
        AddToLog("Error: Couldn't find panel with that name...")
        Return false  ; Invalid panel name
    }

    x1 := Panels[panel].coords[1], y1 := Panels[panel].coords[2], x2 := Panels[panel].coords[3], y2 := Panels[panel].coords[4]

    ; Check if the panel is open
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, 0x441812, 0)) {
        Sleep 100
        if (debugMessages) {
            AddToLog(panel " is already open...")
        }
        Return true  ; Panel is already open
    }

    ; If not open, attempt to open it
    if Panels[panel].HasOwnProp("clickCoords") {
        if (debugMessages) {
            AddToLog("Opening " panel "...")
        }
        xClick := Panels[panel].clickCoords[1], yClick := Panels[panel].clickCoords[2]
        FixClick(xClick, yClick)
        Sleep 300
        Return true
    }

    Return false
}

ActivatePrayerIfInactive(prayer) {
    Prayers := Map()
    Prayers["Magic"] := { coords: [655, 429, 677, 455], clickCoords : [670, 440] }
    Prayers["Augory"] := { coords: [690, 470, 719, 493], clickCoords : [710, 480] }

    Prayers["Melee"] := { coords: [730, 429, 753, 454], clickCoords : [750, 440] }
    Prayers["Piety"] := { coords: [614, 470, 651, 492], clickCoords : [640, 480] }

    Prayers["Ranged"] := { coords: [695, 433, 713, 453], clickCoords : [710, 440] }
    Prayers["Rigour"] := { coords: [652, 469, 686, 497], clickCoords : [670, 480] }

    if !Prayers.Has(prayer) {
        AddToLog("Error: Couldn't find prayer with that name...")
        Return false  ; Invalid prayer name
    }

    x1 := Prayers[prayer].coords[1], y1 := Prayers[prayer].coords[2], x2 := Prayers[prayer].coords[3], y2 := Prayers[prayer].coords[4]

    ; Check if the prayer is active
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, 0xB7A36D, 0)) {
        Sleep 100
        AddToLog("Prayer is already active")
        Return true  ; Prayer is already active
    }

    ; If not open, attempt to open it
    if Prayers[prayer].HasOwnProp("clickCoords") {
        xClick := Prayers[prayer].clickCoords[1], yClick := Prayers[prayer].clickCoords[2]
        FixClick(xClick, yClick)
        Sleep 300
        Return true
    }
    Return false
}

MoveBackAndForth() {
    global SuccessfulX, SuccessfulY
    baseX := 400
    baseY := 335

    offsetX := 100  ; Distance to move right
    ; Move to the right and click
    FixClick(baseX + offsetX, baseY)
    Sleep(2000)  ; Wait for the movement to complete and ensure the click registers

    ; Move back to the left and click
    FixClick(baseX - offsetX + 25, baseY)
    Sleep(2000)  ; Wait for the movement to complete and ensure the click registers
}

CheckForRedOutline(coords) {
    if (PixelSearch(&verifyX, &verifyY, coords[1] - 25, coords[2] - 25, coords[1] + 25, coords[2] + 25, 0xFFFF0000, 2)) {
        return true
    }
}

CheckForMinionAndAttack() {
    MinionCoords := [[275, 190], [575, 190]]  ; Coordinates for the minions
    for index, coords in MinionCoords {
        MouseMove(coords[1], coords[2])
        Sleep(500)
        if (CheckForRedOutline(coords)) {
            AddToLog("The wyvern emerges from the shadows, eager for battle.")  
            FixClick(coords[1], coords[2])
            WaitForNoHealthBar()
        } else {
            AddToLog("The wyvern has vanished into the void... Awaiting its return.")
            Sleep (1000)
        }
    }

}

CheckForZorkathThenAttack() {
    BossCoords := [[430, 105]]  ; Coordinates for the boss
    for index, coords in BossCoords {
        MouseMove(coords[1], coords[2])
        Sleep(500)
        if (CheckForRedOutline(coords)) {
            AddToLog("The air grows heavy... Zorkath has returned.")  
            FixClick(coords[1], coords[2])
            WaitForNoHealthBar()
        } else {
            AddToLog("Zorkath has vanished... but such darkness never stays away for long.")
            Sleep (1000)
        }
    }
}

CheckForBossThenAttack(currentBoss) {
    BossCoords := [GetCoordsForBoss(currentBoss)]
    for index, coords in BossCoords {
        MouseMove(coords[1], coords[2])
        Sleep(500)
        if (CheckForRedOutline(coords)) {
            AddToLog("The air grows heavy..." currentBoss " has returned.")  
            FixClick(coords[1], coords[2])
            WaitForNoHealthBar()
        } else {
            AddToLog(currentBoss " has vanished... but such darkness never stays away for long.")
            Sleep (1000)
        }
    }
}

CheckForMinionsThenAttack(currentBoss) {
    MinionCoords := GetMinionCoordsForBoss(currentBoss)
    
    ; Only proceed if MinionCoords contains data
    if (MinionCoords.Length = 0) 
        return

    for index, coords in MinionCoords {
        MouseMove(coords[1], coords[2])
        Sleep(500)
        if (CheckForRedOutline(coords)) {
            FixClick(coords[1], coords[2])
            WaitForNoHealthBar()
        } else {
            Sleep(1000)
        }
    }
}

GetMinionCoordsForBoss(currentBoss) {
    switch currentBoss {
        case "Zorkath":
            return [[275, 190], [575, 190]]
        case "Blue Moon":
            return [[415, 415], [190, 210], [630, 210]]
        case "Eclipse Moon":
            return [[408, 452], [232, 295], [565, 296], [408, 167]]      
    }
    return []  ; Return an empty array if no minions exist for this boss
}

GetCoordsForBoss(currentBoss) {
    switch currentBoss {
        case "Blue Moon":
            return [420, 200]
        case "Eclipse Moon":
            return [416, 283]    
        case "Tekton":
            return [400, 265]
        case "Zorkath":
            return [430, 105]
        case "Electric Demon":
            return [360, 450]
        case "Polar Pup":
            return [270, 250]
    }
    return []  ; Return an empty array if no coords exist for this boss
}

TeleportToBoss(currentBoss) {
    AddToLog("Attempting to teleport to " currentBoss "...")
    bossCoords := ClickCoordsForBoss(currentBoss)
    FixClick(785, 190) ; Open Teleports
    Sleep (1000)
    FixClick(255, 150) ; Click Bosses
    Sleep (1000)

    bossList := ["Electric Demon", "Magma Cerberus", "Araxxor", "Zorkath", "Yama", "Azzandra", "Polar Pup"]
    if bossList.Has(currentBoss) {
        FixClick(220, 380)
    } else {
        FixClick(220, 210)
    }
    Sleep(1000)
    FixClick(bossCoords.x, bossCoords.y)
    Sleep(1000)
    FixClick(350, 290) ; Click Teleport
    Sleep(2500)
}

ClickCoordsForBoss(currentBoss) {
    switch currentBoss {
        case "Blood Moon" : return { x: 135, y: 205 }
        case "Blue Moon" : return { x: 135, y: 235 }
        case "Eclipse Moon" : return { x: 135, y: 265 }
        case "Tekton" : return { x: 135, y: 305 }
        case "Electric Demon" : return { x: 135, y: 205 }
        case "Magma Cerberus": return { x: 135, y: 235 }
        case "Araxxor": return { x: 135, y: 265 }
        case "Zorkath": return { x: 135, y: 305 }
        case "Yama" : return { x: 135, y: 335 }
        case "Azzandra" : return { x: 135, y: 365 }
        case "Polar Pup" : return { x: 135, y: 400 }
    }
}

HandleBossMovement(currentBoss) {
    AddToLog("Executing Movement for: " currentBoss)
    Sleep(2000)

    switch currentBoss {
        case "Eclipse Moon":
            MoveForMoonBosses()
        case "Electric Demon":
            MoveForElectricDemon()
        case "Polar Pup":
            MoveForPolarPup()
    }

}

MoveForPolarPup() {
    FixClick(710, 115) ; Click Teleport
    Sleep(2500)
}

MoveForMoonBosses() {
    FixClick(408, 286)
    Sleep(2500)
}

MoveForElectricDemon() {
    Loop 20 {
        Send "{DOWN Down}"
        Sleep 50
    }
    Send "{DOWN Up}"
    Sleep (50)
    ; Zoom in smoothly
    Loop 5 {
        Send "{WheelUp}"
        Sleep 50
    }
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/6DWgB9XMTV")
}