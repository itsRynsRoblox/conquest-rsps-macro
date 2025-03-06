#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

CheckForUpdates()

InitializeMacro() {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

StartSelectedMode() {
    global lastBankedTime

    lastBankedTime := A_TickCount ; Starts Timer

    mode := ModeDropdown.Text

    ; Dispatch to corresponding function based on mode
    if (mode = "Bosses") {
        FixCamera()
        StartKilling("Bosses")
    }
    else if (mode = "AFK") {
        StartAFK()
    }
    else if (mode = "Monsters") {
        StartKilling("Monsters")
    }
    else if (mode = "Minigames") {
        MinigameMode()
    }
    else if (mode = "Slayer") {
        StartSlayer()
    }
}

StartKilling(mode) {
    global BossDropDown, MonsterDropDown
    ; Select entity based on the mode
    if (mode = "Bosses") {
        currentEntity := BossDropDown.Text
        AddToLog("Starting " . currentEntity)
        TeleportToBoss(currentEntity)
        HandleBossMovement(currentEntity)
    }
    else if (mode = "Monsters") {
        currentEntity := MonsterDropDown.Text
        AddToLog("Starting " . currentEntity)
    }
    RestartStage()
}

StartAFK() {
    global PrayerPosition, FoodPosition
    currentPrayerSlot := PrayerPosition.Text
    currentFoodSlot := FoodPosition.Text
    Loop {
        Sleep(1000)
        CheckIfVenomed()
        RestorePrayerIfNeeded(currentPrayerSlot)
        RestoreHealthIfNeeded(currentFoodSlot)
        CheckIfAlreadyUnderAttack()
        CheckForMobThenAttack()
    }
}

MinigameMode() {
    global MinigameDropDown
    currentMinigame := MinigameDropDown.Text
    AddToLog("Starting " . currentMinigame . " minigame")
    HandleMinigame()
}


Fight() {
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition, FoodPosition
    global lastBankedTime
    currentPrayerSlot := PrayerPosition.Text
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    currentFoodSlot := FoodPosition.Text
    currentLoadout := LoadoutPosition.Text
    timeElapsed := A_TickCount - lastBankedTime
    while !(ok := CheckForHealthBarNoFindText()) {
        CheckForAFKDetection()
        CheckForDisconnect()
        CheckIfAlreadyUnderAttack()
        RestoreHealthIfNeeded(currentFoodSlot)
        RestorePrayerIfNeeded(currentPrayerSlot)
        if (AutoBankBox.Value) {
            if (timeElapsed >= BankTimer()) {
                AddToLog("Bank Timer Reached - Banking Items...")
                lastBankedTime := A_TickCount
                BankItems(currentLoadout)
                AddToLog("Waiting " BankDelay.Text " until banking again.")
                ReactivatePrayers(currentPrayer, currentBuffPrayer)
                Sleep(1500)
            }
        }
        if (ModeDropdown.Text = "Monsters") {
            if (FindandClickMobsWithVerify(GetColorsForMob(MonsterDropDown.Text))) {
                WaitForNoHealthBar()
            }
        }
        break
    }
}

FightBoss() {
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition, FoodPosition
    global lastBankedTime
    currentPrayerSlot := PrayerPosition.Text
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    currentFoodSlot := FoodPosition.Text
    currentLoadout := LoadoutPosition.Text
    timeElapsed := A_TickCount - lastBankedTime

    while !(ok := CheckForHealthBarNoFindText()) {
        CheckForAFKDetection()
        CheckForDisconnect()
        if (AutoBankBox.Value) {
            if (timeElapsed >= BankTimer()) {
                AddToLog("Bank Timer Reached - Banking Items...")
                lastBankedTime := A_TickCount
                ;BankItems(currentLoadout)
                AddToLog("Waiting " BankDelay.Text " until banking again.")
                ;ReactivatePrayers(currentPrayer, currentBuffPrayer)
                ;Sleep(1500)
            }
        }
        RestoreHealthIfNeeded(currentFoodSlot)
        RestorePrayerIfNeeded(currentPrayerSlot)
        CheckForMinionsThenAttack(BossDropDown.Text)
        CheckForBossThenAttack(BossDropDown.Text)
        break
    }

    if (BossDropDown.Text = "Zorkath") {
        ; Loop while health bar is present
        while (CheckForHealthBarNoFindText()) {
                LookForFireball()
                Sleep 100
        }
    }

    if (BossDropDown.Text = "Araxxor") {
        ; Loop while health bar is present
        while (CheckForHealthBarNoFindText()) {
                CheckIfVenomed()
                Sleep 100
        }
    }
}

    
RestartStage() {
    loop {
        while !CheckForHealthBarNoFindText() {
            Sleep(50)  ; Prevents excessive CPU usage while checking

            switch ModeDropdown.Text {
                case "Bosses":
                    if (BossDropDown.Text = "Eclipse Moon" or BossDropDown.Text = "Blood Moon" or BossDropDown.Text = "Blue Moon") {
                        Send("^h") ; Sends Control + B
                        Sleep(4000)
                        TeleportToBoss(BossDropDown.Text)
                        HandleBossMovement(BossDropDown.Text)
                    }
                    FightBoss()
                default:
                    Fight()
            }
        }
    }
}

ValidateMode() {
    global savedX, savedY
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a mode before starting the macro!")
        return false
    }
    if (ModeDropdown.Text = "AFK") {
        if (savedCoords[1] = "") {  ; Check if there are no coordinates saved
            AddToLog("Please set the search coordinates before starting the AFK mode!")
            return false
        }
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

BankTimer() {
    switch BankDelay.Text {
        case "1 minute":
            return 60000
        case "3 minutes":
            return 180000
        case "5 minutes":
            return 300000
        case "10 minutes":
            return 600000
        case "15 minutes":
            return 900000
        default:
            return 60000  ; Default to 1 minute if no match
    }
}


HandleMinigame() {
    global MinigameDropDown
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition
    currentLoadout := LoadoutPosition.Text
    currentPrayerSlot := PrayerPosition.Text
    currentPrayer := ProtectionPrayer.Text
    currentBuffPrayer := BuffPrayer.Text
    FixCamera()
    Loop {
        Sleep(1000)
        if SearchFor("Inactive Wave") {
            AddToLog("🕒 Inactive wave timer detected, verifying wave completion...")
            Sleep(2000)
            
            if SearchFor("Inactive Wave") {
                AddToLog("🌊 Wave timer still inactive, initiating next wave...")

                if (AutoBankBox.Value) {
                    PrepareForNextWave(currentLoadout, currentPrayer, currentBuffPrayer)
                }

                InitiateNextWave()
            } else {
                AddToLog("🔄 Transitioning between waves, wave not yet complete...")
                CheckForAFKDetection()
                CheckForDisconnect()
                RestorePrayerIfNeeded(currentPrayerSlot)
            }
        } else {
            CheckForAFKDetection()
            CheckForDisconnect()
            RestorePrayerIfNeeded(currentPrayerSlot)
        }
    }
}

PrepareForNextWave(currentLoadout, currentPrayer, currentBuffPrayer) {
    AddToLog("💰 Preparing for the next wave by banking items...")
    BankItems(currentLoadout)
    ReactivatePrayers(currentPrayer, currentBuffPrayer)
}

InitiateNextWave() {
    ; Sequence of clicks to start the next wave
    ClickSequence([
        [410, 300], ; Click Totem
        [295, 405], ; Click Prestige
        [485, 120], ; Close Interface Prestige
        [410, 300]  ; Click Totem again
    ])
    SendInput("{1}")
    Sleep(1500)
}

ClickSequence(coordsArray) {
    for index, coords in coordsArray {
        FixClick(coords[1], coords[2])
        Sleep(1500) ; Sleep between each click
    }
}