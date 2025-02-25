#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

InitializeMacro() {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

CheckForXp() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 322, 195, 505, 276, 0, 0, Spawn)) {
        return true
    }
    return false
}


UpgradeUnits() {
    if CheckForXp() {
        AddToLog("Stage ended during upgrades, proceeding to results")
        StartSelectedMode()
        return
    }
}

FarmBoss() {
    global BossDropDown
    
    ; Get current map and act
    currentBoss := BossDropDown.Text

    AddToLog("Starting " currentBoss)

    RestartStage()
}

FarmMonster() {
    global MonsterDropDown
    
    ; Get current map and act
    currentMonster := BossDropDown.Text

    AddToLog("Starting " currentMonster)

    RestartStage()
}

MinigameMode() {
    global RaidDropdown
    ; Get current map and act
    currentMinigame := RaidDropdown.Text
    AddToLog("Starting " currentMinigame)
    HandleMinigame()
}


Fight() {
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition
    global lastBankedTime
    currentPrayerSlot := PrayerPosition.Text
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    currentLoadout := LoadoutPosition.Text
    timeElapsed := A_TickCount - lastBankedTime
    while !(ok := CheckForHealthBarNoFindText()) {
        AFKDetection()
        CheckForDisconnect()
        RestorePrayerIfNeeded(currentPrayerSlot)
        Sleep(1500)

        if (timeElapsed >= BankTimer()) {
            AddToLog("Bank Timer Reached - Banking Items...")
            lastBankedTime := A_TickCount
            BankItems(currentLoadout)
            AddToLog("Waiting " BankDelay.Text " until banking again.")
            ReactivatePrayers(currentPrayer, currentBuffPrayer)
            Sleep(1500)
        }
        if (ModeDropdown.Text = "Bosses") {
            FindandClickMobs(GetColorsForMob(BossDropDown.Text))
            Sleep(1500)
        }
        if (ModeDropdown.Text = "Monsters") {
            FindandClickMobs(GetColorsForMob(MonsterDropDown.Text))
            Sleep(1500)
        }
        break
    }
}

Fight1() {
    global PrayerPosition
    currentPrayerSlot := PrayerPosition.Text
    while !(ok := CheckForHealthBar()) {
        while !(ok := FindText(&X, &Y, 720-150000, 88-150000, 720+150000, 88+150000, 0, 0, BlueMoonMinimap)) {
            Sleep 2500
        }
        AFKDetection()
        RestorePrayerIfNeeded(currentPrayerSlot)
        FightBlueMoon()
    }
}

FightBlueMoon() {
    ; Kill Minion #1
    FixClick(412, 392)
    WaitForNoHealthBar()

    ; Kill Minion #2
    FixClick(254, 240)
    WaitForNoHealthBar()

    ; Kill Minion #3
    FixClick(570, 242)
    WaitForNoHealthBar()

    ; Attack Boss
    FixClick(417, 233)
    WaitForNoHealthBar()
}

WaitForNoHealthBar() {
    Sleep 3500
    Loop {
        if !(ok := FindText(&X, &Y, 6, 66, 130, 89, 0, 0, HealthBarNew)) {
            Break  ; Exit loop when HP bar is gone
        }
        Sleep 1500  ; Check every 1.5 seconds
    }
}

AFKDetection() {
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

    
RestartStage() {
    loop {
        while !CheckForHealthBarNoFindText() {
            Sleep(50)  ; Prevents excessive CPU usage while checking

            switch ModeDropdown.Text {
                case "Bosses":
                    if (BossDropDown.Text = "Blue Moon") {
                        Fight1()
                    } else {
                        Fight()
                    }
                default:
                    Fight()
            }
        }
    }
}

CheckSpawn() {
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

StartSelectedMode() {
    global lastBankedTime

    lastBankedTime := A_TickCount ; Starts Timer

    if (ModeDropdown.Text = "Bosses") {
        FarmBoss()
    }
    if (ModeDropdown.Text = "Monsters") {
        FarmBoss()
    }
    if (ModeDropdown.Text = "Minigames") {
        MinigameMode()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary
    
    ; Generate 40 random points
    Loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)
        
        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x)**2 + (y - existingPoint.y)**2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }
        
        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({x: x, y: y})
    }
    
    ; Always add center point last (so it's used last)
    points.Push({x: centerX, y: centerY})
    
    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points row by row
    Loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)
        
        ; Generate each point in the current row
        Loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
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

BankTimer() {
    if BankDelay.Text = "1 minute" {
        return 60000
    } else if BankDelay.Text = "3 minutes" {
        return 180000
    } else if BankDelay.Text = "5 minutes" {
        return 300000
    } else if BankDelay.Text = "10 minutes" {
        return 600000
    } else if BankDelay.Text = "15 minutes" {
        return 900000
    } else {
        return 60000
    }
}

CheckForInactive() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 391, 31, 446, 54, 0, 0, InactiveWave)) {
        return true
    }
    return false
}


HandleMinigame() {
    global RaidDropdown
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition
    currentLoadout := LoadoutPosition.Text
    currentPrayerSlot := PrayerPosition.Text
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    Loop {
        Sleep(1000)
        ; Check for Inactive Wave Screen
        if CheckForInactive() {
            AddToLog("🕒 Inactive wave timer detected, verifying wave completion...")
            Sleep(2000)
            if CheckForInactive() {
                AddToLog("🌊 Wave timer still inactive, initiating next wave...")
                Sleep(500)
    
                if (AutoBankBox.Value) {
                    AddToLog("💰 Preparing for the next wave by banking items...")
                    BankItems(currentLoadout)
                    ReactivatePrayers(currentPrayer, currentBuffPrayer)
                }
    
                FixClick(420, 200) ; Click Totem
                Sleep(1500)

                FixClick(295, 405) ; Click Prestige
                Sleep(1500)

                FixClick(485, 120) ; Close Interface Prestige
                Sleep(1500)

                FixClick(420, 200) ; Click Totem
                Sleep(1500)

                SendInput("{1}")
                Sleep(1500)
            } else {
                AddToLog("🔄 Transitioning between waves, wave not yet complete...")
                AFKDetection()
                CheckForDisconnect()
                RestorePrayerIfNeeded(currentPrayerSlot)
            }
        } else {
            AFKDetection()
            CheckForDisconnect()
            RestorePrayerIfNeeded(currentPrayerSlot)
        }
    }
}