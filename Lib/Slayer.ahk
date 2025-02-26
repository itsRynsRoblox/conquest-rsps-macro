#Requires AutoHotkey v2.0

StartSlayer() {
    FixCamera() ; Fixes Camera Angle
    Sleep(1000)
    OpenPlayerPanel()
    currentTask := DetectSlayerTask()
    if (CheckForNoSlayerTask()) {
        TeleportToSlayerMaster()
        GetTask()
    }
    TeleportToSlayerTask(currentTask)
    if (currentTask != "no task found") {
        HandleMovement(currentTask)
    }
    StartSlayerCombat(currentTask)
}

GetTask() {
    AddToLog("Attemping to get a slayer task...")
    FixClick(400, 275, "Right") ; Right Click Slayer Master
    Sleep(1000)
    FixClick(390, 315)
    Sleep(1000)
    SendInput(GetKeyForTask()) ; Choose Slayer Task
    Sleep(1000)
    FixClick(660, 580)  ; Close Player Panel to force text update
    Sleep(1000)
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
    CloseChat()
    FixClick(650, 50) ; Face North Minimap
    Sleep(1000)
    MouseMove(600, 50)
    Sleep(1000) ;225 283
    ; Move Camera Upwards
    Loop 20 {
        Send "{UP Down}"
        Sleep 50
    }
    ; Zoom in smoothly
    Loop 30 {
        Send "{WheelUp}"
        Sleep 50
    }
    ; Zoom back out smoothly
    Loop 10 {
        Send "{WheelDown}"
        Sleep 50
    }
}

TeleportToSlayerMaster() {
    AddToLog("Attemping to teleport to the slayer master...")
    OpenPlayerPanel()
    FixClick(645, 495) ; Teleport To Slayer Master
    Sleep (1000)
    SendInput("{1}")
    Sleep(2500)
}

TeleportToSlayerTask(currentTask) {
    AddToLog("Attempting to teleport to " currentTask "...")
    taskCoords := ClickCoordsForSlayerTask(currentTask)
    FixClick(785, 190) ; Open Teleports
    Sleep (1000)
    FixClick(155, 150) ; Click Monsters
    Sleep (1000)
    FixClick(135, 205) ; Click so can scroll down list
    Sleep (1000)
    if (SlayerDropDown.Text = "Hard") {
        if (currentTask = "Galvek" or currentTask = "Tormented Demon") {
            FixClick(225, 300)
            Sleep (1000)
        } else {
            FixClick(225, 283)
            Sleep (1000)
        }
    }
    if (SlayerDropDown.Text = "Elite") {
        Loop 10 {
            SendInput("{WheelDown}") ; Scroll To Elite Monsters
            Sleep(150)
        }
    }
    FixClick(taskCoords.x, taskCoords.y)
    Sleep(1000)
    FixClick(350, 290) ; Click Teleport
    Sleep(2500)
}

CheckForNoSlayerTask() {
    ; Check for completed slayer task
    OpenPlayerPanel()
    if (ok := FindText(&X, &Y, 661, 427, 742, 456, 0, 0, NoSlayerTask)) {
        Sleep(500)
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
        case "Sarachnis" : return { x: 135, y: 375 }
        case "Galvek" : return { x: 135, y: 370 }
        case "Tormented Demon" : return { x: 135, y: 400 }
        case "Shadow Corp": return { x: 135, y: 205 }
        case "Abyssal Kurasks": return { x: 135, y: 235 }
        case "Night Beasts": return { x: 135, y: 265 }
    }
}

DetectSlayerTask() {
    slayerTasks := Map(
        "Magma Beast", MagmaBeast,
        "Tormented Demon", TormentedDemon,
        "Shadow Corp", ShadowCorp
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

OpenPlayerPanel() {
    if !CheckIfPlayerPanelOpen() {
        ; If player panel is not found, open it
        Sleep(500)
        FixClick(660, 580)  ; Click to open Player Panel
        Sleep(1500)
    }
}

CheckIfPlayerPanelOpen() {
    searchArea := [642, 563, 673, 595]
    ; Extract the search area boundaries
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, 0x441812, 0)) {
        Sleep (100)
        return true
    }
    return false
}

HandleMovement(TaskName) {
    AddToLog("Executing Movement for: " TaskName)
    
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
    Fixclick(767, 170, "Left")
    Sleep (7000)
    Fixclick(790, 95, "Left")
    Sleep (7000)
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
    Fixclick(750, 75 "Left")
    Sleep (5500)
}

MoveForTormentedDemons() {
    Fixclick(790, 115 "Left")
    Sleep (5500)
}

StartSlayerCombat(TaskName) {
    loop {
        while !CheckForHealthBarNoFindText() {
            Sleep(50)  ; Prevents excessive CPU usage while checking
            KillSlayerMonsters(TaskName)
        }
    }
}

KillSlayerMonsters(TaskName) {
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
        if (CheckForNoSlayerTask()) {
            return StartSlayer()
        }
        RestoreHealthIfNeeded(currentFoodSlot)
        RestorePrayerIfNeeded(currentPrayerSlot)
        Sleep(1500)

        if (timeElapsed >= BankTimer()) {
            AddToLog("Bank Timer Reached - Banking Items...")
            lastBankedTime := A_TickCount
            BankItems(currentLoadout)
            AddToLog("Waiting " BankDelay.Text " until banking again.")
            Sleep(1500)
        }
        FindAndClickMobsWithVerify(GetColorsForMob(TaskName))
        Sleep(1500)
        break
    }
}