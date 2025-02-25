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

FarmBoss() {
    global BossDropDown
    currentBoss := BossDropDown.Text
    AddToLog("Starting " currentBoss)
    RestartStage()
}

FarmMonster() {
    global MonsterDropDown
    currentMonster := MonsterDropDown.Text
    AddToLog("Starting " currentMonster)
    RestartStage()
}

MinigameMode() {
    global RaidDropdown
    currentMinigame := RaidDropdown.Text
    AddToLog("Starting " currentMinigame " minigame")
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
        while !(ok := FindText(&X, &Y, 720-150000, 88-150000, 720+150000, 88+150000, 0, 0, BlueMoonMinimap)) {
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

StartSelectedMode() {
    global lastBankedTime

    lastBankedTime := A_TickCount ; Starts Timer

    if (ModeDropdown.Text = "Bosses") {
        FarmBoss()
    }
    if (ModeDropdown.Text = "Monsters") {
        FarmMonster()
    }
    if (ModeDropdown.Text = "Minigames") {
        MinigameMode()
    }
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