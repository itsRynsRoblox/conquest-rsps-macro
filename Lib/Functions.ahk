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
    TogglePause()
}
F5:: {
    FixCamera()
}
F6:: {

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
        FixClick(foundX + 1, foundY, "Left")
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

FindAndClickMobsWithVerify(targetColors, searchArea := [0, 28, 589, 469], verifyColor := 0xFFFF0000, retries := 5, retryDelay := 200) {
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]
    verifyArea := [-25, -25, 25, 25]  ; Offset for verification

    loop retries {
        for color in targetColors {
            if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 0)) {
                MouseMove(foundX, foundY)

                ; Verify the target is indeed a mob by checking for verifyColor around it
                if (PixelSearch(&verifyX, &verifyY, foundX + verifyArea[1], foundY + verifyArea[2], foundX + verifyArea[3], foundY + verifyArea[4], verifyColor, 2)) {
                    FixClick(foundX, foundY, "Left")
                    AddToLog("✅ Mob found and verified! Clicked at: X" foundX " Y" foundY)
                    return true
                } else {
                    if (debugMessages) {
                        AddToLog("⚠ Color match found, but verification color not detected. Skipping click.")
                    }
                }
            }
        }

        ; Retry delay before trying again
        Sleep(retryDelay)
    }

    ; Failure Handling - Define what happens if no mob is found
    if (debugMessages) {
        AddToLog("❌ Failed to find and verify a mob after " retries " attempts.")
    }
    RotateCamera()
    return false
}

RotateCamera() {
    SendInput ("{Left up}")
    Sleep 200
    SendInput ("{Left down}")
    Sleep 750
    SendInput ("{Left up}")
    KeyWait "Left" ; Wait for key to be fully processed
}

FindAndClickMobsWithVerifyRightClick(targetColors, searchArea := [0, 28, 589, 469], verifyColor := 0xFFFF0000, healthBarColor := 0x6BC300) {
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Predefine the verification search area around the found target
    verifyArea := [-25, -25, 25, 25]  ; Adjustable offset for verification

    for color in targetColors {
        ; Perform a faster search for the target color
        if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, 0)) {
            MouseMove(foundX, foundY)
            
            ; Perform the verification search for the verifyColor around the found target area
            if (PixelSearch(&verifyX, &verifyY, foundX + verifyArea[1], foundY + verifyArea[2], foundX + verifyArea[3], foundY + verifyArea[4], verifyColor, 2)) {

                ; Check if there is a health bar above the found NPC
                healthBarX := foundX
                healthBarY := foundY - 20  ; Adjust this value based on your game's UI
                
                if (PixelSearch(&barX, &barY, healthBarX - 15, healthBarY - 5, healthBarX + 15, healthBarY + 5, healthBarColor, 5)) {
                    if (debugMessages) {
                        AddToLog("⚠ Mob found, but a health bar detected. Skipping click.")
                    }
                    continue  ; Skip this mob since it has a health bar
                }

                ; If no health bar is found, proceed with attacking
                FixClick(foundX, foundY, "Right")  ; Open interaction menu
                AddToLog("✅ Mob found, verified, and has NO health bar! Right-clicked at: X" foundX " Y" foundY)

                Sleep(100)  ; Small delay to allow menu to open
                FixClick(foundX, foundY + 30, "Left")  ; Select attack option
                
                return true
            } else {
                if (debugMessages) {
                    AddToLog("⚠ Color match found, but verification color not detected. Skipping click.")
                }
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
    searchArea := [7, 67, 128, 89] ;0x4B4539/0x1F722B
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
        "Sarachnis", [0x7C2823, 0x7C2823], ;0x812925/0x531A18
        "Galvek", [0x55120E, 0x55120E],
        "Tormented Demon", [0x985450, 0x8D5805],
        "Snow Imps", [0x1F54A6, 0x000000],
        "Shadow Corp", [0x6D7570, 0x6D7570], ;0x79827D/0x838D88/0x535A57
        "Abyssal Kurask", [0x3D5B1D, 0x2E4316],
        "Fury Drake", [0x171414, 0xB30F06], ; Body / Red Glow
        "Night Beast", [0x1A1A26, 0x3D7175], ;Back / Glow Under
        "Shadow Nihil", [0x21182D, 0x21182D], ;0x21182D / 0x402E56
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
            FixClick(clickCoords.x, clickCoords.y) ; Click on prayer potion
        }
    }
}

RestoreHealthIfNeeded(FoodPosition) {
    foundX := foundY := 0
    if (AutoFoodBox.Value) {
        if (PixelSearch(&foundX, &foundY, 621, 78, 643, 99, 0xFFFF00, 3) ; First color check
            || PixelSearch(&foundX, &foundY, 621, 78, 643, 99, 0xFCA607, 3)) { ; Second color check
            clickCoords := ClickCoordsForFood(FoodPosition)
            AddToLog("Detected low health, restoring...")
            CheckAndOpenPanelIfNeeded("Inventory")
            FixClick(clickCoords.x, clickCoords.y) ; Click on prayer potion
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
    WaitForInterface("Bank")
    FixClick(525, 150) ; Click Preset
    Sleep(500)
    LoadPreset(LoadoutPosition) ; Click Selected Preset
    FixClick(130, 400) ; Load Preset
    Sleep(500)
    FixClick(537, 120) ; Close Preset
    Sleep(2000)
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

    ; Click the prayers
    ActivatePrayerIfInactive(ProtectionPrayer)
    ActivatePrayerIfInactive(BuffPrayer)
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

CheckForSpawn() {
    ; Check for spawn booths
    if (ok := FindText(&X, &Y, 186, 177, 231, 230, 0, 0, InformationBooth)) {
        return true
    }
    return false
}

CheckIfAlreadyUnderAttack() {
    ; Check for under attack text
    if (ok := FindText(&X, &Y, 9, 573, 493, 590, 0, 0, UnderAttack)) {
        AddToLog("Already under attack, clicking under player...")
        FixClick(410, 335)
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

WaitForNoHealthBar(timeoutAppear := 5000, timeoutDisappear := 10000, maxFails := 3) {
    static failCount := 0  ; Tracks failed detections across multiple calls
    startTime := A_TickCount  ; Get current time

    ; **Wait for the health bar to appear** (max wait: timeoutAppear ms)
    Loop {
        if (CheckForHealthBarNoFindText()) {
            AddToLog("✅ Health bar found, waiting for combat end...")
            failCount := 0  ; Reset fail count because combat started properly
            Break  ; Found the HP bar, now wait for it to disappear
        }
        if ((A_TickCount - startTime) > timeoutAppear) {
            failCount++  ; Increase fail count if no health bar is found

            if !(ModeDropdown.Text = "Bosses") {
                AddToLog("❌ Health bar not found after attacking. Fail count: " failCount "/" maxFails)
                if (failCount >= maxFails) {
                    AddToLog("⚠ Reached max failed attempts. Executing teleport/fail action.")
    
                    ; **Only teleport if maxFails is reached**
                    if (ModeDropdown.Text = "Slayer") {
                        return StartSlayer(false)
                    }
                    if (ModeDropdown.Text = "Monsters") {
                        return TeleportToSlayerTask(MonsterDropDown.Text)
                    }
    
                    return false  ; Prevent further teleport attempts if mode is unknown
                }
            }

            return false  ; Just return false without teleporting if under maxFails
        }
        Sleep 100  ; Fast checks for better responsiveness
    }

    ; **Wait for the health bar to disappear**
    startTime := A_TickCount  ; Reset timer
    Loop {
        if !(CheckForHealthBarNoFindText()) {
            AddToLog("✅ Health bar gone, combat likely ended.")
            return true  ; HP bar is gone, return success
        }
        if ((A_TickCount - startTime) > timeoutDisappear) {
            AddToLog("⚠ Health bar stayed too long, possible combat issue.")
            return false
        }
        Sleep 100  ; Faster response when combat ends
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

CheckForMobThenAttack() {
    static lastMobDetectionTime := 0  ; Static variable to store the last successful detection time
    currentTime := A_TickCount  ; Get current time in milliseconds

    ; Skip the 12-minute check if no mob has been detected yet (lastMobDetectionTime = 0)
    if (lastMobDetectionTime != 0 && (currentTime - lastMobDetectionTime) > 720000) {
        AddToLog("❌ More than 12 minutes since last mob detection. Triggering backup method...")
        StartSelectedMode()  ; Backup method if time exceeds 12 minutes
        return  ; Exit early if backup method is triggered
    }

    ; Check for mobs at each saved coordinate
    global savedCoords  ; Reference the saved coordinates array
    mobFound := false  ; Flag to track if a mob is found at any coordinate

    for index, coords in savedCoords {
        MouseMove(coords[1], coords[2])  ; Move the mouse to the current coordinates

        if (CheckForRedOutline(coords)) {
            FixClick(coords[1], coords[2])  ; Click on the mob at the saved coordinates
            WaitForNoHealthBar()  ; Wait until the health bar is gone (mob is dead or combat is over)

            ; Update the last detection time upon successful mob detection
            lastMobDetectionTime := currentTime
            mobFound := true  ; Set flag to true since a mob was found and clicked
            break  ; Exit loop after successful mob detection
        } else {
            if (debugMessages) {
                AddToLog("Mob was not found at coords " coords[1] ", " coords[2] " ... could be dead or missing...")
            }
        }
    }

    ; If no mob was found at any of the saved coordinates
    if (!mobFound) {
        if (debugMessages) {
            AddToLog("❌ Could not find mob at any of the saved coordinates.")
        }
    }
}




CheckForBossThenAttack(currentBoss) {
    static lastBossDetectionTime := 0  ; Static variable to store the last successful detection time
    currentTime := A_TickCount  ; Get current time in milliseconds

    ; Skip the 12-minute check if no mob has been detected yet (lastMobDetectionTime = 0)
    if (lastBossDetectionTime != 0 && (currentTime - lastBossDetectionTime) > 720000) {
        AddToLog("❌ More than 12 minutes since last mob detection. Triggering backup method...")
        StartSelectedMode()  ; Backup method if time exceeds 12 minutes
        return  ; Exit early if backup method is triggered
    }

    BossCoords := [GetCoordsForBoss(currentBoss)]
    for index, coords in BossCoords {
        MouseMove(coords[1], coords[2])
        if (CheckForRedOutline(coords)) {
            if (currentBoss != "AFK") {
                AddToLog("The air grows heavy... " currentBoss " has returned...") 
            } 
            FixClick(coords[1], coords[2])
            WaitForNoHealthBar()
            
            ; Update the last detection time upon successful boss detection
            lastBossDetectionTime := currentTime
        } else {
            if (debugMessages) {
                AddToLog(currentBoss " was not found, could be dead...")
            }
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
        case "Araxxor":
            return [[176, 350], [668, 350]]
        case "Zorkath":
            return [[275, 190], [575, 190]]
        case "Blood Moon":
            return [[408, 452], [232, 295], [565, 296], [408, 167]]
        case "Blue Moon":
            return [[408, 452], [232, 295], [565, 296], [408, 167]]
        case "Eclipse Moon":
            return [[408, 452], [232, 295], [565, 296], [408, 167]]      
    }
    return []  ; Return an empty array if no minions exist for this boss
}

GetCoordsForBoss(currentBoss) {
    global savedX, savedY
    switch currentBoss {
        case "AFK":
            return [savedX, savedY]
        case "Araxxor":
            return [455, 219]
        case "Blood Moon":
            return [416, 283]
        case "Blue Moon":
            return [416, 283]
        case "Eclipse Moon":
            return [416, 283]
        case "Magma Cerberus":
            return [343, 308]     
        case "Tekton":
            return [400, 265]
        case "Zorkath":
            return [430, 105]
        case "Electric Demon":
            return [360, 450]
        case "Yama":
            return [423, 214]    
        case "Polar Pup":
            return [270, 250]
    }
    return []  ; Return an empty array if no coords exist for this boss
}

TeleportToBoss(currentBoss) {
    AddToLog("Attempting to teleport to " currentBoss "...")
    bossCoords := ClickCoordsForBoss(currentBoss)
    FixClick(785, 190) ; Open Teleports
    WaitForInterface("Teleport")
    FixClick(255, 150) ; Click Bosses
    Sleep (1000)

    bossList := ["Electric Demon", "Magma Cerberus", "Araxxor", "Zorkath", "Yama", "Azzandra", "Polar Pup"]

    found := false
    for boss in bossList {
        if (boss = currentBoss) {
            found := true
            Break
        }
    }
    
    if (found) {
        FixClick(220, 380)
    } else {
        FixClick(220, 210)
    }
    Sleep(1000)
    FixClick(bossCoords.x, bossCoords.y)
    Sleep(1000)
    FixClick(350, 290) ; Click Teleport
    Sleep(3500)
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
        case "Blood Moon":
            MoveForMoonBosses()
        case "Blue Moon":
            MoveForMoonBosses()
        case "Eclipse Moon":
            MoveForMoonBosses()
        case "Electric Demon":
            MoveForElectricDemon()
        case "Tekton":
            MoveForTekton()
        case "Zorkath":
            MoveForZorkath()
        case "Magma Cerberus":
            MoveForMagmaCerberus() 
        case "Polar Pup":
            MoveForPolarPup()
    }

}

MoveForPolarPup() {
    FixClick(710, 115)
    Sleep(2500)
}

MoveForTekton() {
    FixClick(400, 225) ;Click Lava Crater
    Sleep(2500)
    FixClick(420, 225) ;Click Boss Room #1
    Sleep(4000)
    FixClick(728, 95) ;Click Near Tekton
    Sleep(1500)
}

MoveForElectricDemon() {
    FixClick(422, 220) ;Click Boss Teleporter
    Sleep(2500)
    FixClick(420, 225) ;Click Boss Room #1
    Sleep(2000)
    FixClick(729, 66) ;Click Near Tekton
    Sleep(5000)
}

MoveForMoonBosses() {
    FixClick(408, 286)
    Sleep(2500)
}

MoveForMagmaCerberus() {
    FixClickWithSleep(334, 268, 2000)
    FixClickWithSleep(420, 225, 2500) ;Click Boss Room #1
    FixClickWithSleep(727, 54, 5000)
}

MoveForZorkath() {
    FixClickWithSleep(407, 189, 2500) ;Click Portal
    FixClickWithSleep(420, 225, 2000) ;Click Boss Room #1
}

MoveForYama() {
    FixClickWithSleep(393, 196, 2000)
    FixClickWithSleep(420, 225, 2000) ;Click Boss Room #1
}

MoveForAzzandra() {
    FixClickWithSleep(398, 125, 2500)
    FixClickWithSleep(420, 225, 2000) ;Click Boss Room #1
}

WaitForPixel(Name, timeoutAppear := 5000) {
    startTime := A_TickCount  ; Get current time

    ; **Wait for the interface to appear**
    Loop {
        if (SearchForPixel(Name)) { 
            if (debugMessages) {
                AddToLog("✅ " Name " detected, proceeding...")
            }
            return true  ; Interface found, exit loop
        }
        if ((A_TickCount - startTime) > timeoutAppear) {
            if (debugMessages) {
                AddToLog("⚠ " Name " was not found in time.")
            }
            return false  ; Exit if timeout reached (interface never opened)
        }
        Sleep 100  ; Fast checks for better responsiveness
    }
}

WaitForInterface(interfaceName, timeoutAppear := 5000) {
    startTime := A_TickCount  ; Get current time

    ; **Wait for the interface to appear**
    Loop {
        if (CheckForInterface(interfaceName)) { 
            if (debugMessages) {
                AddToLog("✅ " interfaceName " detected, proceeding...")
            }
            return true  ; Interface found, exit loop
        }
        if ((A_TickCount - startTime) > timeoutAppear) {
            if (debugMessages) {
                AddToLog("⚠ " interfaceName " was not found in time.")
            }
            return false  ; Exit if timeout reached (interface never opened)
        }
        Sleep 100  ; Fast checks for better responsiveness
    }
}

WaitFor(Name, timeoutAppear := 5000) {
    startTime := A_TickCount  ; Get current time

    ; **Wait for the interface to appear**
    Loop {
        if (SearchFor(Name)) { 
            if (debugMessages) {
                AddToLog("✅ " Name " detected, proceeding...")
            }
            return true  ; Interface found, exit loop
        }
        if ((A_TickCount - startTime) > timeoutAppear) {
            if (debugMessages) {
                AddToLog("⚠ " Name " was not found in time.")
            }
            return false  ; Exit if timeout reached (interface never opened)
        }
        Sleep 100  ; Fast checks for better responsiveness
    }
}

TeleportHome() {
    Send("^h") ; Teleports Home
    WaitFor("Information Booth")
    return StartSlayer()
}

SearchForPixel(Name) {
    Pixels := Map()
    Pixels["Venom"] := { coords: [621, 78, 643, 99], color: 0x254B22 }

    Pixels["Prayer"] := { coords: [186, 177, 231, 230], color: 0x441812 }

    Pixels["Magic"] := { coords: [655, 429, 677, 455], color: 0xB7A36D }
    Pixels["Augory"] := { coords: [690, 470, 719, 493], color: 0xB7A36D }

    Pixels["Melee"] := { coords: [730, 429, 753, 454], color: 0xB7A36D }
    Pixels["Piety"] := { coords: [614, 470, 651, 492], color: 0xB7A36D }

    Pixels["Ranged"] := { coords: [695, 433, 713, 453], color: 0xB7A36D }
    Pixels["Rigour"] := { coords: [652, 469, 686, 497], color: 0xB7A36D }
    
    ; Check if the Pixel exists in the map
    if !Pixels.Has(Name) {
        AddToLog("Error: Couldn't find " Name "...")
        Return false  ; Invalid Pixel name
    }

    coords := Pixels[Name].coords
    color := Pixels[Name].color
    x1 := coords[1], y1 := coords[2], x2 := coords[3], y2 := coords[4]

    ; Perform the Pixel search
    if (PixelSearch(&X, &Y, x1, y1, x2, y2, color)) {
        if (debugMessages) {
            AddToLog("Found " Name)
        }
        Return true  ; Pixel found
    }

    Return false  ; Pixel not found
}

SearchFor(Name) {
    FindTexts := Map()
    FindTexts["Information Booth"] := { coords: [186, 177, 231, 230], searchText: InformationBooth }
    FindTexts["Brimstone Chest"] := { coords: [322, 293, 366, 328], searchText: BrimstoneChest }
    FindTexts["Compass"] := { coords: [620, 27, 669, 66], searchText: Compass }
    FindTexts["Inactive Wave"] := { coords: [391, 31, 446, 54], searchText: InactiveWave }

    ; Check if the InterfaceName exists in the map
    if !FindTexts.Has(Name) {
        AddToLog("Error: Couldn't find " Name "...")
        Return false  ; Invalid interface name
    }

    coords := FindTexts[Name].coords
    searchText := FindTexts[Name].searchText
    x1 := coords[1], y1 := coords[2], x2 := coords[3], y2 := coords[4]

    ; Perform the Find Text search
    if (FindText(&X, &Y, x1, y1, x2, y2, 0, 0, searchText)) {
        Return true  ; Interface found
    }

    Return false  ; Interface not found
}

CheckForInterface(InterfaceName) {
    ; Define the mapping of interface names to their respective search areas and search texts
    Interfaces := Map()
    Interfaces["Bank"] := { coords: [219, 107, 375, 131], searchText: Bank }
    Interfaces["Teleport"] := { coords: [229, 106, 370, 132], searchText: TeleportInterface }
    Interfaces["Slayer"] := { coords: [612, 363, 703, 389], searchText: DonatorRank }

    ; Check if the InterfaceName exists in the map
    if !Interfaces.Has(InterfaceName) {
        AddToLog("Error: Couldn't find " InterfaceName "...")
        Return false  ; Invalid interface name
    }

    coords := Interfaces[InterfaceName].coords
    searchText := Interfaces[InterfaceName].searchText
    x1 := coords[1], y1 := coords[2], x2 := coords[3], y2 := coords[4]

    ; Perform the Find Text search
    if (FindText(&X, &Y, x1, y1, x2, y2, 0, 0, searchText)) {
        Return true  ; Interface found
    }

    Return false  ; Interface not found
}

CheckIfVenomed() {
    if (SearchForPixel("Venom")) {
        AddToLog("You are affected by venom, curing...")
        UseAntiVenom()
    }
}

UseAntiVenom() {
    FindAndClickColor(0x3F5047, [608, 294, 799, 553])
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/6DWgB9XMTV")
}