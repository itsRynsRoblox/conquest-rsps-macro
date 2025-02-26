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

StartSelectedMode() {
    global lastBankedTime

    lastBankedTime := A_TickCount ; Starts Timer

    mode := ModeDropdown.Text
    AddToLog("Starting " . mode)

    ; Dispatch to corresponding function based on mode
    if (mode = "Bosses") {
        StartKilling("Bosses")
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
    }
    else if (mode = "Monsters") {
        currentEntity := MonsterDropDown.Text
        AddToLog("Starting " . currentEntity)
    }
    RestartStage()
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
        RestoreHealthIfNeeded(currentFoodSlot)
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

StartMoonBossFight() {
    global PrayerPosition, FoodPosition
    currentPrayerSlot := PrayerPosition.Text
    currentFoodSlot := FoodPosition.Text
    while !(ok := CheckForHealthBarNoFindText()) {
        while !(ok := FindText(&X, &Y, 584, 31, 803, 208, 0, 0, BlueMoonMinimap)) { ;720-150000, 88-150000, 720+150000, 88+150000
            Sleep 2500
        }
        CheckForAFKDetection()
        RestoreHealthIfNeeded(currentFoodSlot)
        RestorePrayerIfNeeded(currentPrayerSlot)
        FightMoonBoss()
    }
}

FightMoonBoss() {
    ; Kill Minions and Boss
    MinionCoords := [[412, 392], [254, 240], [570, 242], [417, 233]]  ; Coordinates for the minions and boss
    for index, coords in MinionCoords {
        FixClick(coords[1], coords[2])
        WaitForNoHealthBar()
    }
}

    
RestartStage() {
    loop {
        while !CheckForHealthBarNoFindText() {
            Sleep(50)  ; Prevents excessive CPU usage while checking

            switch ModeDropdown.Text {
                case "Bosses":
                    if (BossDropDown.Text = "Blue Moon") {
                        StartMoonBossFight()
                    } else {
                        Fight()
                    }
                default:
                    Fight()
            }
        }
    }
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a mode before starting the macro!")
        return false
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
        if CheckForInactive() {
            AddToLog("🕒 Inactive wave timer detected, verifying wave completion...")
            Sleep(2000)
            
            if CheckForInactive() {
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