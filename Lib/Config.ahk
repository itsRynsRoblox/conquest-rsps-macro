#Include %A_ScriptDir%\Lib\GUI.ahk
global settingsFile := "" 


setupFilePath() {
    global settingsFile
    
    if !DirExist(A_ScriptDir "\Settings") {
        DirCreate(A_ScriptDir "\Settings")
    }

    settingsFile := A_ScriptDir "\Settings\Configuration.txt"
    return settingsFile
}

readInSettings() {
    global mode
    global AutoBankBox
    global BankDelay
    global FoodPosition
    global PrayerPosition
    global ProtectionPrayer
    global BuffPrayer
    global AutoPrayerBox
    global LoadoutPosition

    try {
        settingsFile := setupFilePath()
        if !FileExist(settingsFile) {
            return
        }

        content := FileRead(settingsFile)
        lines := StrSplit(content, "`n")
        
        for line in lines {
            if line = "" {
                continue
            }
            
            parts := StrSplit(line, "=")
            switch parts[1] {
                case "Mode": mode := parts[2]
                case "Banking": AutoBankBox.Value := parts[2]
                case "Delay": BankDelay.Value := parts[2] ; Set the dropdown value
                case "Slot": PrayerPosition.Value := parts[2] ; Set the dropdown value
                case "FoodSlot": FoodPosition.Value := parts[2] ; Set the dropdown value
                case "LoadoutSlot": LoadoutPosition.Value := parts[2] ; Set the dropdown value
                case "Prayer": ProtectionPrayer.Value := parts[2]
                case "Buff": BuffPrayer.Value := parts[2]
                case "Praying": AutoPrayerBox.Value := parts[2]
            }
        }
        AddToLog("Configuration settings loaded successfully")
    } 
}


SaveSettings(*) {
    global mode
    global AutoBankBox
    global BankDelay
    global FoodPosition
    global PrayerPosition
    global ProtectionPrayer
    global BuffPrayer
    global AutoPrayerBox
    global LoadoutPosition

    try {
        settingsFile := A_ScriptDir "\Settings\Configuration.txt"
        if FileExist(settingsFile) {
            FileDelete(settingsFile)
        }

        ; Save mode and map selection
        content := "Mode=" mode "`n"
        if (mode = "Bosses") {
            content .= "Boss=" BossDropDown.Text
        } else if (mode = "Monsters") {
            content .= "Monster=" MonsterDropDown.Text
        } else if (mode = "Minigames") {
            content .= "Game=" MinigameDropDown.Text
        }

        content .= "`n`n[AutoBanking]"
        content .= "`nBanking=" AutoBankBox.Value "`n"

        content .= "`n`n[AutoPrayer]"
        content .= "`nPraying=" AutoPrayerBox.Value "`n"

        content .= "`n`n[BankDelay]"
        content .= "`nDelay=" BankDelay.Value "`n"

        content .= "`n`n[FoodPosition]"
        content .= "`nFoodSlot=" FoodPosition.Value "`n"

        content .= "`n`n[LoadoutSlot]"
        content .= "`nLoadoutSlot=" LoadoutPosition.Value "`n"

        content .= "`n`n[PrayerPosition]"
        content .= "`nSlot=" PrayerPosition.Value "`n"

        content .= "`n`n[ProtectionPrayer]"
        content .= "`nPrayer=" ProtectionPrayer.Value "`n"

        content .= "`n`n[BuffPrayer]"
        content .= "`nBuff=" BuffPrayer.Value "`n"

        FileAppend(content, settingsFile)
        AddToLog("Configuration settings saved successfully")
    }
}