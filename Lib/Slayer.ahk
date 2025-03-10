#Requires AutoHotkey v2.0

StartSlayer(newTask := true) {
    global LoadoutPosition
    currentLoadout := LoadoutPosition.Text

    if (newTask) {
        FixCamera()  ; Adjusts camera for better visibility
        AddToLog("💰 Preparing for the task by banking items...")
        BankItems(currentLoadout)
    }

    CheckAndOpenPanelIfNeeded("PlayerPanel")

    if (CheckForNoSlayerTask()) {
        FixCamera()  ; Adjusts camera for better visibility
        TeleportToSlayerMaster()
        WaitFor("Brimstone Chest")
        GetTask()
    }

    Sleep(2000)

    if (CheckForNoSlayerTask()) {
        AddToLog("⚠ No Slayer task detected. Restarting...")
        return StartSlayer()
    }
    
    currentTask := DetectSlayerTask()

    TeleportToSlayerTask(currentTask)
    HandleMovement(currentTask)
    ActivatePrayerForTask(currentTask)
    StartSlayerCombat(currentTask)
}

GetTask() {
    AddToLog("Attempting to get a " SlayerDropDown.Text " task...")
    FixClick(405, 305, "Right") ; Right Click Slayer Master
    Sleep(1000)
    FixClick(390, 345)
    Sleep(1000)

    taskKey := GetKeyForTask()
    Loop 3 {  ; Retry up to 3 times if needed
        SendInput(taskKey) ; Choose Slayer Task
        Sleep(500)
        if (DetectSlayerTask() != "no task found") {
            AddToLog("✅ Slayer task received successfully.")
            return
        }
        AddToLog("⚠ Failed to retrieve Slayer task. Retrying...")
    }

    AddToLog("❌ Failed to get a Slayer task after multiple attempts.")
}

GetKeyForTask() {
    switch SlayerDropDown.Text {
        case "Easy" : return 1
        case "Medium" : return 2
        case "Hard" : return 3
        case "Elite" : return 4
    }
}

FixCamera() {
    ; Face North Minimap
    FixClick(650, 50)
    Sleep(1000)
    MouseMove(600, 50)
    Sleep(1000) ; Move camera upwards

    ; Move Camera Upwards
    MoveCameraUp(20, 50)

    ; Zoom in smoothly
    ZoomIn(30, 50)

    ; Check if we need to zoom out
    ZoomOutBasedOnMode()
}

; Move camera upwards function
MoveCameraUp(repeats, delay) {
    Loop(repeats) {
        Send("{UP Down}")
        Sleep(delay)
    }
    Send("{UP Up}")
    Sleep(50)
}

; Zoom in function
ZoomIn(repeats, delay) {
    Loop(repeats) {
        Send("{WheelUp}")
        Sleep(delay)
    }
}

; Zoom out based on the mode
ZoomOutBasedOnMode() {
    ; Default zoom out (smooth)
    zoomOutRepeats := 10
    zoomDelay := 50

    if (ModeDropdown.Text = "Bosses") {
        if (BossDropDown.Text = "Eclipse Moon" or BossDropDown.Text = "Blood Moon" or BossDropDown.Text = "Blue Moon") {
            zoomOutRepeats := 30 ; Zoom out to max
        }
        if (BossDropDown.Text = "Araxxor") {
            zoomOutRepeats := 30 ; Zoom out to max
        }
    }

    ; Perform the zoom out
    Loop(zoomOutRepeats) {
        Send("{WheelDown}")
        Sleep(zoomDelay)
    }
}

TeleportToSlayerMaster() {
    AddToLog("Attemping to teleport to the slayer master...")
    CheckAndOpenPanelIfNeeded("PlayerPanel")
    Sleep(200)
    FixClick(645, 495) ; Teleport To Slayer Master
    Sleep (1000)
    SendInput("{1}")
}

TeleportToSlayerTask(currentTask) {
    AddToLog("Attempting to teleport to " currentTask "...")
    if !SearchFor("Compass") {
        FixClick(650, 50)
        Sleep(500)
    }
    taskCoords := ClickCoordsForSlayerTask(currentTask)
    FixClick(785, 190) ; Open Teleports
    WaitForInterface("Teleport")
    FixClick(155, 150) ; Click Monsters
    Sleep (1000)
    if (ModeDropDown.Text = "Slayer") {
        if (SlayerDropDown.Text = "Hard") {
            if (currentTask = "Galvek" or currentTask = "Tormented Demon") {
                FixClick(225, 300)
            } else {
                FixClick(225, 283)
            }
            Sleep(1000)
        }
        else if (SlayerDropDown.Text = "Elite") {
            FixClick(225, 385)
            Sleep(1000)
        }
    }
    if (currentTask = "no task found") {
        AddToLog("⚠ No Slayer task detected. Restarting...")
        return StartSlayer()  ; Restart if no task is detected
    }
    FixClick(taskCoords.x, taskCoords.y)
    Sleep(1000)
    FixClick(350, 290) ; Click Teleport
    Sleep(2500)
}

GetNewInstance(TaskName) {
    minTries := 1  ; Minimum number of times to type ::newroom
    maxTries := SlayerDropDown.Text = "Elite" ? 2 : 3  ; Maximum number of times
    attempts := Random(minTries, maxTries)  ; Generate a random number between min and max

    if (TaskName = "Pyrelord") {
        attempts := 1
    }

    if (TaskName = "Fury Drake") {
        attempts := 2
    }

    if (TaskName = "Abyssal Kurask") {
        attempts := 2
    }

    if (TaskName = "Night Beast") {
        attempts := 2
    }

    Loop attempts {
        Send("{Backspace 3}")  ; Backspace 3 times
        Send("::newroom{Enter}")
        Sleep(4500)
    }
}

CheckForNoSlayerTask() {
    ; Check for completed slayer task
    CheckAndOpenPanelIfNeeded("PlayerPanel")
    WaitForInterface("Slayer")
    if (ok := FindText(&X, &Y, 661, 427, 742, 456, 0, 0, NoSlayerTask)) {
        return true
    }
    return false
}

ClickCoordsForSlayerTask(SlayerTask) {
    switch SlayerTask {
        case "Arcane Nagua" : return { x: 135, y: 205 }
        case "Spectral Nagua" : return { x: 135, y: 235 }
        case "Elysian Nagua" : return { x: 135, y: 265 }
        case "Vanguards" : return { x: 135, y: 305 }
        case "Electric Wyrm" : return { x: 135, y: 335 }
        case "Magma Beast" : return { x: 135, y: 365 }
        case "Sarachnis" : return { x: 135, y: 400 }
        case "Galvek" : return { x: 135, y: 370 }
        case "Tormented Demon" : return { x: 135, y: 400 }
        case "Shadow Corp": return { x: 135, y: 205 }
        case "Abyssal Kurask": return { x: 135, y: 235 }
        case "Night Beast": return { x: 135, y: 265 }
        case "Fury Drake" : return { x: 135, y: 305 }
        case "Shadow Nihil" : return { x: 135, y: 335 }
        case "Pyrelord" : return { x: 135, y: 365 }
    }
}

DetectSlayerTask() {
    slayerTasks := Map(
        "Arcane Nagua", ArcaneNagua,
        "Spectral Nagua", SpectralNagua,
        "Elysian Nagua", ElysianNagua,
        "Vanguards", Vanguards,
        "Electric Wyrm", ElectricWyrm,
        "Magma Beast", MagmaBeast,
        "Sarachnis", Sarachnis,
        "Galvek", Galvek,
        "Tormented Demon", TormentedDemon,
        "Shadow Corp", ShadowCorp,
        "Abyssal Kurask", AbyssalKurask,
        "Fury Drake", FuryDrake,
        "Night Beast", NightBeast,
        "Shadow Nihil", ShadowNihil,
        "Pyrelord", Pyrelord
    )
    for taskName, pattern in slayerTasks {
        if (ok := FindText(&X, &Y, 612, 426, 799, 457, 0, 0, pattern)) {
            AddToLog("Detected task: " taskName)
            return taskName
        }
    } else {
        return "no task found"
    }
    
}

HandleMovement(TaskName) {
    AddToLog("Executing Movement for: " TaskName)
    Sleep(2000)
    GetNewInstance(TaskName)
    switch TaskName {
        case "Arcane Nagua":
            MoveForArcaneNagua()
        case "Elysian Nagua":
            MoveForElysianNagua()
        case "Spectral Nagua":
            MoveForSpectralNagua()     
        case "Vanguards":
            MoveForVanguards()
        case "Magma Beast":
            MoveForMagmaBeast()
        case "Sarachnis":
            MoveForSarachnis()
        case "Galvek":
            MoveForGalvek()
        case "Tormented Demon":
            MoveForTormentedDemons()
        case "Shadow Corp":
            MoveForShadowCorps()
        case "Night Beast":
            MoveForNightBeast()
        case "Abyssal Kurask":
            MoveForAbyssalKurask()
        case "Fury Drake":
            MoveForFuryDrake()
        case "Shadow Nihil":
            MoveForShadowNihil()
        case "Pyrelord":
            MoveForPyrelord()     
    }
}

MoveForShadowCorps() {
    Fixclick(775, 115, "Left")
    Sleep (4000)
    Fixclick(788, 85, "Left")
    Sleep (7000)
}

MoveForNightBeast() {
    Fixclick(742, 180, "Left")
    Sleep (10000)
    ;Fixclick(767, 170, "Left")
    ;Sleep (7000)
    ;Fixclick(790, 95, "Left")
    ;Sleep (7000)
}

MoveForArcaneNagua() {
    Fixclick(745, 45, "Left")
    Sleep (5000)
}

MoveForElysianNagua() {
    Fixclick(660, 85, "Left")
    Sleep (5000)
}

MoveForVanguards() {
    Fixclick(680, 60, "Left")
    Sleep (5000)
    Fixclick(680, 60, "Left")
    Sleep (5000)
    Fixclick(670, 140, "Left")
    Sleep (5000)
}


MoveForSpectralNagua() {
    Fixclick(665, 100, "Left")
    Sleep (5000)
    Fixclick(670, 100, "Left")
    Sleep (5000)
}

MoveForMagmaBeast() {
    Fixclick(800, 115, "Left")
    Sleep (5500)
    Fixclick(770, 80, "Left")
    Sleep (5500)
}

MoveForSarachnis() {
    Fixclick(700, 170, "Left")
    Sleep (5500)
}

MoveForGalvek() {
    Fixclick(750, 75, "Left")
    Sleep (5500)
}

MoveForTormentedDemons() {
    Fixclick(790, 115, "Left")
    Sleep (5500)
}

MoveForAbyssalKurask() {

}

MoveForFuryDrake() {
    Fixclick(680, 60, "Left")
    Sleep (5500)
}

MoveForShadowNihil() {
    Fixclick(750, 100, "Left")
    Sleep (5500)
}

MoveForPyrelord() {
    ; Randomly choose between two sets of coordinates
    if (Random(0, 1)) {  ; 50/50 chance
        ; Slightly randomize the click position around (674, 107) by a small range
        randomX := Random(674 - 3, 674 + 3)
        randomY := Random(107 - 3, 107 + 3)
        Fixclick(randomX, randomY, "Left")
    } else {
        ; Slightly randomize the click position around (775, 110) by a small range
        randomX := Random(775 - 3, 775 + 3)
        randomY := Random(110 - 3, 110 + 3)
        Fixclick(randomX, randomY, "Left")
    }

    ; A subtle random sleep time (e.g., between 5300ms and 5700ms)
    randomSleep := Random(5300, 5700)
    Sleep(randomSleep)  ; Wait after the click
}


StartSlayerCombat(TaskName) {
    loop {
        if !CheckForHealthBarNoFindText() {  
            KillSlayerMonsters(TaskName)
        }
        Sleep(50)  ; Prevents excessive CPU usage
    }
}

ActivatePrayerForTask(TaskName) {
    global BuffPrayer
    neededPrayer := GetProtectionPrayerType(TaskName)
    currentBuffPrayer := BuffPrayer.Text
    if (neededPrayer != "Unknown") {
        ReactivatePrayers(neededPrayer, currentBuffPrayer)
    }
}

GetProtectionPrayerType(TaskName) {
    switch TaskName {
        case "Arcane Nagua":
            return "Melee"
        case "Elysian Nagua":
            return "Melee"
        case "Spectral Nagua":
            return "Melee"
        case "Vanguards":
            return "Magic"
        case "Electric Wyrm":
            return "Magic"    
        case "Sarachnis":
            return "Melee"  
        case "Magma Beast":
            return "Melee"
        case "Galvek":
            return "Melee"
        case "Tormented Demon":
            return "Melee"
        case "Shadow Corp":
            return "Magic"    
        case "Night Beast":
            return "Ranged"
        case "Fury Drake":
            return "Magic"  
        case "Abyssal Kurask":
            return "Melee"
        case "Shadow Nihil":
            return "Magic"
        case "Pyrelord":
            return "Melee"    
    
        default:
            return "Unknown"
    }
}

KillSlayerMonsters(TaskName) {
    global PrayerPosition, ProtectionPrayer, BuffPrayer, LoadoutPosition, FoodPosition, lastBankedTime

    currentPrayerSlot := PrayerPosition.Text
    currentFoodSlot := FoodPosition.Text

    mobColors := GetColorsForMob(TaskName)

    while !CheckForHealthBarNoFindText() {  ; Loop while health bar is not found
        CheckForAFKDetection()
        CheckForDisconnect()
        
        if CheckForNoSlayerTask() {
            AddToLog("Slayer task finished, restarting...")
            return TeleportHome()
        }

        if CheckForSpawn() {
            AddToLog("Found in spawn, restarting...")
            return StartSlayer()
        }

        RestoreHealthIfNeeded(currentFoodSlot)
        RestorePrayerIfNeeded(currentPrayerSlot)
        CheckIfAlreadyUnderAttack()

        if FindAndClickMobsWithVerify(mobColors) {
            WaitForNoHealthBar()
        }
    }
}