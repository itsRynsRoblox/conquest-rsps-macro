#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
#Include Functions.ahk
#Include AutoUpdates.ahk

; Basic Application Info
global aaTitle := "Conquest Macro "
global version := "v1.5"
global gameID := "ahk_exe Java.exe"
;Coordinate and Positioning Variables
global targetWidth := 816
global targetHeight := 638
global offsetX := -5
global offsetY := 1
global WM_SIZING := 0x0214
global WM_SIZE := 0x0005
global centerX := 408
global centerY := 320
global mode := ""
global StartTime := A_TickCount
global currentTime := GetCurrentTime()
;Bank
global lastBankedTime := A_TickCount
;Custom Search Area
global waitingForClick := false
global savedX := 0, savedY := 0
global savedCoords := []  ; Initialize an empty array to hold the coordinates
;Auto Updating
global autoUpdateEnabled := true
global repoOwner := "itsRynsRoblox"
global repoName := "conquest-rsps-macro"
global currentVersion := "1.4"
;Gui creation
global uiBorders := []
global uiBackgrounds := []
global uiTheme := []
global UnitData := []
global aaMainUI := Gui("+AlwaysOnTop -Caption")
global lastlog := ""
global aaMainUIHwnd := aaMainUI.Hwnd
;Theme colors
uiTheme.Push("0xffffff")  ; Header color
uiTheme.Push("0c000a")  ; Background color
uiTheme.Push("0xffffff")    ; Border color
uiTheme.Push("0c000a")  ; Accent color
uiTheme.Push("0x3d3c36")   ; Trans color
uiTheme.Push("000000")    ; Textbox color
uiTheme.Push("00ffb3") ; HighLight
;Logs/Save settings
global settingsGuiOpen := false
global SettingsGUI := ""
global currentOutputFile := A_ScriptDir "\Logs\LogFile.txt"
global WebhookURLFile := "Settings\WebhookURL.txt"
global DiscordUserIDFile := "Settings\DiscordUSERID.txt"
global SendActivityLogsFile := "Settings\SendActivityLogs.txt"
;Custom Pictures
GithubImage := "Images\github-logo.png"
DiscordImage := "Images\another_discord.png"

if !DirExist(A_ScriptDir "\Logs") {
    DirCreate(A_ScriptDir "\Logs")
}
if !DirExist(A_ScriptDir "\Settings") {
    DirCreate(A_ScriptDir "\Settings")
}

setupOutputFile()

;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
aaMainUI.BackColor := uiTheme[2]
global Webhookdiverter := aaMainUI.Add("Edit", "x0 y0 w1 h1 +Hidden", "") ; diversion
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1364 h1 +Background" uiTheme[3]))  ;Top line
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1 h707 +Background" uiTheme[3]))   ;Left line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h630 +Background" uiTheme[3])) ;Right line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h707 +Background" uiTheme[3])) ;Second Right line
uiBackgrounds.Push(aaMainUI.Add("Text", "x3 y3 w1360 h27 +Background" uiTheme[2])) ;Title Top
uiBorders.Push(aaMainUI.Add("Text", "x0 y30 w1363 h1 +Background" uiTheme[3])) ;Title bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y100 w560 h1 +Background" uiTheme[3])) ;Mode bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y150 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y550 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(aaMainUI.Add("Text", "x802 y30 w1 h677 +Background" uiTheme[3])) ;Game Right
uiBorders.Push(aaMainUI.Add("Text", "x0 y707 w1364 h1 +Background" uiTheme[3], "")) ;Game second bottom

global gameHolder := aaMainUI.Add("Text", "x3 y33 w797 h597 +Background" uiTheme[5], "") ;Game window box
global exitButton := aaMainUI.Add("Picture", "x1330 y1 w32 h32 +BackgroundTrans", Exitbutton) ;Exit image
exitButton.OnEvent("Click", (*) => Destroy()) ;Exit button
global minimizeButton := aaMainUI.Add("Picture", "x1300 y3 w27 h27 +Background" uiTheme[2], Minimize) ;Minimize gui
minimizeButton.OnEvent("Click", (*) => minimizeUI()) ;Minimize gui
aaMainUI.SetFont("Bold s16 c" uiTheme[1], "Verdana") ;Font
global windowTitle := aaMainUI.Add("Text", "x10 y3 w1200 h29 +BackgroundTrans", aaTitle "" . "" version) ;Title

aaMainUI.Add("Text", "x805 y110 w558 h25 +Center +BackgroundTrans", "Activity Log") ;Process header
aaMainUI.SetFont("norm s11 c" uiTheme[1]) ;Font
global process1 := aaMainUI.Add("Text", "x810 y152 w538 h18 +BackgroundTrans c" uiTheme[7], "➤ Original Creator: Ryn") ;Processes
global process2 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") ;Processes 
global process3 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process4 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process5 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process6 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process7 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process8 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process9 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process10 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process11 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process12 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")
global process13 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process14 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process15 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process16 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process17 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process18 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "")  
WinSetTransColor(uiTheme[5], aaMainUI) ;Game window box

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
ShowSettingsGUI(*) {
    global settingsGuiOpen, SettingsGUI
    
    ; Check if settings window already exists
    if (SettingsGUI && WinExist("ahk_id " . SettingsGUI.Hwnd)) {
        WinActivate("ahk_id " . SettingsGUI.Hwnd)
        return
    }
    
    if (settingsGuiOpen) {
        return
    }
    
    settingsGuiOpen := true
    SettingsGUI := Gui("-MinimizeBox +Owner" aaMainUIHwnd)  
    SettingsGui.Title := "Settings"
    SettingsGUI.OnEvent("Close", OnSettingsGuiClose)
    SettingsGUI.BackColor := uiTheme[2]
    
    ; Window border
    SettingsGUI.Add("Text", "x0 y0 w1 h600 +Background" uiTheme[3])     ; Left
    SettingsGUI.Add("Text", "x599 y0 w1 h600 +Background" uiTheme[3])   ; Right
    SettingsGUI.Add("Text", "x0 y399 w600 h1 +Background" uiTheme[3])   ; Bottom
    
    ; Right side sections
    SettingsGUI.SetFont("s10", "Verdana")
    SettingsGUI.Add("GroupBox", "x310 y5 w280 h160 c" uiTheme[1], "Discord Webhook")  ; Box
    SettingsGUI.SetFont("s9", "Verdana")
    ; Show the settings window
    SettingsGUI.Show("w600 h400")
    Webhookdiverter.Focus()
}
aaMainUI.SetFont("s9")

placementSaveText := aaMainUI.Add("Text", "x210 y642 w80 h20 +Center", "Save Config")
placementSaveBtn := aaMainUI.Add("Button", "x211 y662 w80 h20", "Save")
placementSaveBtn.OnEvent("Click", SaveSettings)

searchAreaText := aaMainUI.Add("Text", "x310 y642 w80 h20 +Center", "Search Area")
searchAreaButton := aaMainUI.Add("Button", "x311 y662 w80 h20", "Set")
searchAreaButton.OnEvent("Click", (*) => StartClickCapture())

AutoPrayerText := aaMainUI.Add("Text", "x840 y560 w115 h20 +Center", "Auto Prayer")
global AutoPrayerBox := aaMainUI.Add("Checkbox", "x850 y580 cffffff Checked +Center", "Enabled")

ProtectionPrayerText := aaMainUI.Add("Text", "x970 y560 w115 h20 +Center", "Protection Prayer")
global ProtectionPrayer := aaMainUI.Add("DropDownList", "x980 y580 w100 Choose1 +Center", ["Magic", "Melee", "Ranged"])

BuffPrayerText := aaMainUI.Add("Text", "x1100 y560 w115 h20 +Center", "Buff Prayer")
global BuffPrayer := aaMainUI.Add("DropDownList", "x1110 y580 w100 Choose1 +Center", ["Augury", "Piety", "Rigour"])

PrayerText := aaMainUI.Add("Text", "x1230 y560 w115 h20 +Center", "Potion Slot")
global PrayerPosition := aaMainUI.Add("DropDownList", "x1240 y580 w100 Choose1 +Center", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28"])

BankSettingsText := aaMainUI.Add("Text", "x840 y610 w115 h20 +Center", "Auto Bank")
global AutoBankBox := aaMainUI.Add("Checkbox", "x850 y630 cffffff Checked", "Enabled")

BankDelayText := aaMainUI.Add("Text", "x970 y610 w115 h20 +Center", "Timer")
global BankDelay := aaMainUI.Add("DropDownList", "x980 y630 w100 Choose1 +Center", ["1 minute", "3 minutes", "5 minutes", "10 minutes", "15 minutes"])

LoadoutPositionText := aaMainUI.Add("Text", "x1100 y610 w115 h20 +Center", "Loadout Slot")
global LoadoutPosition := aaMainUI.Add("DropDownList", "x1110 y630 w100 Choose1 +Center", ["1", "2", "3"])

AutoFoodText := aaMainUI.Add("Text", "x840 y660 w115 h20 +Center", "Auto Food")
global AutoFoodBox := aaMainUI.Add("Checkbox", "x850 y680 cffffff +Center", "Enabled")

FoodPositionText := aaMainUI.Add("Text", "x970 y660 w115 h20 +Center", "Food Slot")
global FoodPosition := aaMainUI.Add("DropDownList", "x980 y680 w100 Choose1 +Center", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28"])

Hotkeytext := aaMainUI.Add("Text", "x807 y35 w200 h30", "F1: Position Window")
Hotkeytext2 := aaMainUI.Add("Text", "x807 y50 w200 h30", "F2: Start Macro")
Hotkeytext3 := aaMainUI.Add("Text", "x807 y65 w200 h30", "F3: Stop Macro")
GithubButton := aaMainUI.Add("Picture", "x30 y640 w40 h40 +BackgroundTrans cffffff", GithubImage)
DiscordButton := aaMainUI.Add("Picture", "x112 y645 w60 h34 +BackgroundTrans cffffff", DiscordImage)

GithubButton.OnEvent("Click", (*) => OpenGithub())
DiscordButton.OnEvent("Click", (*) => OpenDiscord())
;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT
global modeSelectionGroup := aaMainUI.Add("GroupBox", "x808 y38 w500 h45 Background" uiTheme[2], "Mode Select")
aaMainUI.SetFont("Bold s10 c" uiTheme[6])
global ModeDropdown := aaMainUI.Add("DropDownList", "x818 y53 w140 h180 Choose0 +Center", ["AFK", "Bosses", "Monsters", "Minigames", "Slayer"])
global BossDropDown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Blood Moon", "Blue Moon", "Eclipse Moon", "Electric Demon", "Magma Cerberus", "Araxxor", "Tekton", "Zorkath", "Yama", "Polar Pup"])
global SlayerDropDown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Hard", "Elite"])
global MonsterDropDown := aaMainUI.Add("DropDownlist", "x968 y53 w150 h180 Choose0 +Center", ["Arcane Nagua", "Electric Wyrm", "Elysian Nagua", "Magma Beast", "Sarachnis", "Spectral Nagua", "Snow Imps","Tormented Demon", "Vanguards"])
global MinigameDropDown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Doomcore"])
global ConfirmButton := aaMainUI.Add("Button", "x1218 y53 w80 h25", "Confirm")

BossDropDown.Visible := false
MonsterDropDown.Visible := false
MinigameDropDown.Visible := false
SlayerDropDown.Visible := false
Hotkeytext.Visible := false
Hotkeytext2.Visible := false
Hotkeytext3.Visible := false
ModeDropdown.OnEvent("Change", OnModeChange)
ConfirmButton.OnEvent("Click", OnConfirmClick)
;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI
;------UNIT CONFIGURATION------UNIT CONFIGURATION------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/

aaMainUI.SetFont("s8 c" uiTheme[6])

; Mode selection dropdown

readInSettings()
aaMainUI.Show("w1366 h710")
WinMove(0, 0,,, "ahk_id " aaMainUIHwnd)
forceWindowSize()  ; Initial force size and position
SetTimer(checkWindowSize, 600000)  ; Check every 10 minutes
;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION
;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS

;Process text
AddToLog(current) { 
    global process1, process2, process3, process4, process5, process6, process7,process8, process9, process10, process11, process12, process13, process14, process14, process15, process16, process17, process18, currentOutputFile, lastlog

    ; Remove arrow from all lines first
    process18.Value := StrReplace(process17.Value, "➤ ", "")
    process17.Value := StrReplace(process16.Value, "➤ ", "")
    process16.Value := StrReplace(process15.Value, "➤ ", "")
    process15.Value := StrReplace(process14.Value, "➤ ", "")
    process14.Value := StrReplace(process13.Value, "➤ ", "")
    process13.Value := StrReplace(process12.Value, "➤ ", "")
    process12.Value := StrReplace(process11.Value, "➤ ", "")
    process11.Value := StrReplace(process10.Value, "➤ ", "")
    process10.Value := StrReplace(process9.Value, "➤ ", "")
    process9.Value := StrReplace(process8.Value, "➤ ", "")
    process8.Value := StrReplace(process7.Value, "➤ ", "")
    process7.Value := StrReplace(process6.Value, "➤ ", "")
    process6.Value := StrReplace(process5.Value, "➤ ", "")
    process5.Value := StrReplace(process4.Value, "➤ ", "")
    process4.Value := StrReplace(process3.Value, "➤ ", "")
    process3.Value := StrReplace(process2.Value, "➤ ", "")
    process2.Value := StrReplace(process1.Value, "➤ ", "")
    
    ; Add arrow only to newest process
    process1.Value := "➤ " . current
    
    elapsedTime := getElapsedTime()
    Sleep(50)
    FileAppend(current . " " . elapsedTime . "`n", currentOutputFile)

    ; Add webhook logging
    lastlog := current
    if FileExist("Settings\SendActivityLogs.txt") {
        SendActivityLogsStatus := FileRead("Settings\SendActivityLogs.txt", "UTF-8")
    }
}

;Timer
getElapsedTime() {
    global StartTime
    ElapsedTime := A_TickCount - StartTime
    Minutes := Mod(ElapsedTime // 60000, 60)  
    Seconds := Mod(ElapsedTime // 1000, 60)
    return Format("{:02}:{:02}", Minutes, Seconds)
}

sizeDown() {
    global gameID
    
    if !WinExist(gameID)
        return

    WinGetPos(&X, &Y, &OutWidth, &OutHeight, gameID)
    
    ; Exit fullscreen if needed
    if (OutWidth >= A_ScreenWidth && OutHeight >= A_ScreenHeight) {
        Send "{F11}"
        Sleep(100)
    }

    ; Force the window size and retry if needed
    Loop 3 {
        WinMove(X, Y, targetWidth, targetHeight, gameID)
        Sleep(100)
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, gameID)
        if (OutWidth == targetWidth && OutHeight == targetHeight)
            break
    }
}

moveWindow() {
    global aaMainUIHwnd, offsetX, offsetY, gameID
    
    if !WinExist(gameID) {
        AddToLog("Waiting for window...")
        return
    }

    ; First ensure correct size
    sizeDown()
    
    ; Then move relative to main UI
    WinGetPos(&x, &y, &w, &h, aaMainUIHwnd)
    WinMove(x + offsetX, y + offsetY,,, gameID)
    WinActivate(gameID)
}

forceWindowSize() {
    global gameID
    
    if !WinExist(gameID) {
        checkCount := 0
        While !WinExist(gameID) {
            Sleep(5000)
            if(checkCount >= 5) {
                AddToLog("Attempting to locate the window")
            } 
            checkCount += 1
            if (checkCount > 12) { ; Give up after 1 minute
                AddToLog("Could not find window")
                return
            }
        }
        AddToLog("Found the window")
    }

    WinActivate(gameID)
    sizeDown()
    moveWindow()
}
; Function to periodically check window size
checkWindowSize() {
    global gameID
    if WinExist(gameID) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, gameID)
        if (OutWidth != targetWidth || OutHeight != targetHeight) {
            sizeDown()
            moveWindow()
        }
    }
}

OnSettingsGuiClose(*) {
    global settingsGuiOpen, SettingsGUI
    settingsGuiOpen := false
    if SettingsGUI {
        SettingsGUI.Destroy()
        SettingsGUI := ""  ; Clear the GUI reference
    }
}

checkSizeTimer() {
    if (WinExist("ahk_exe Java.exe")) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, "ahk_exe Java.exe")
        if (OutWidth != 816 || OutHeight != 638) {
            AddToLog("Fixing window size")
            moveWindow()
        }
    }
}

StartClickCapture() {
    global waitingForClick
    waitingForClick := true
    ToolTip "Click anywhere to save coordinates..."
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 sec
}

~LShift::
{
    global waitingForClick, savedCoords  ; Use a list to store multiple coordinates
    if waitingForClick {
        MouseGetPos &x, &y
        waitingForClick := false
        savedCoords.push([x, y])  ; Add the new coordinate pair to the list
        ToolTip "Coordinates saved: " x ", " y
        SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 sec
    }
}
