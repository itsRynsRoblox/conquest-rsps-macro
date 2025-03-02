#Requires Autohotkey v2.0

#Include JSON.ahk

CheckForUpdates() {
    global repoOwner, repoName, autoUpdateEnabled  ; Explicitly declare global variables

    url := "https://api.github.com/repos/" repoOwner "/" repoName "/releases/latest"
    http := ComObject("MSXML2.XMLHTTP")
    http.Open("GET", url, false)
    http.Send()

    if (http.Status != 200) {
        AddToLog("Failed to check for updates.")
        return
    }

    response := http.responseText
    latestVersion := JSON.parse(response).Get("tag_name")

    if (latestVersion != currentVersion) {
        AddToLog("A new version is available! Current version: " currentVersion "`nLatest version: " latestVersion)
        if (autoUpdateEnabled) {
            DownloadAndUpdateRepo()
        }
    } else {
        AddToLog("You are using the latest version.")
    }
}


DownloadAndUpdateRepo() {
    global repoOwner, repoName
    zipUrl := "https://github.com/" repoOwner "/" repoName "/archive/refs/heads/main.zip"

    tempDir := A_Temp "\RepoUpdate"
    zipFilePath := tempDir "\repo.zip"

    ; Ensure temp directory exists
    if !DirExist(tempDir) {
        DirCreate(tempDir)
    }

    ; Download the latest repo ZIP
    if !Download(zipUrl, zipFilePath) {
        AddToLog("Failed to download the update.")
        return
    }

    ; Extract the ZIP
    ExtractZIP(zipFilePath, tempDir)

    ; Delete ZIP after extraction
    FileDelete(zipFilePath)

    extractedFolderPath := tempDir "\anime-adventures-multi-use"

    if !DirExist(extractedFolderPath) {
        MsgBox("Something went wrong while extracting")
        return
    }

    ; Copy new files from temp directory to script directory
    ErrorCount := CopyFilesAndFolders(extractedFolderPath . "\*", A_ScriptDir, "1")
    if ErrorCount != 0 {
        AddToLog(ErrorCount " files/folders could not be copied.")
        return
    }

    ; Clean up temp directory
    DirDelete(tempDir, true)

    AddToLog("Updated! Restarting script")
    RestartScript()
}

ExtractZIP(zipFilePath, targetDir) {
    RunWait("tar -xf " "" zipFilePath "" " -C " "" targetDir "" "", "", "Hide")
}

CopyFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite := false)
{
    ErrorCount := 0
    try
        FileCopy SourcePattern, DestinationFolder, DoOverwrite
    catch as Err
        ErrorCount := Err.Extra
    Loop Files, SourcePattern, "D"
    {
        try
            DirCopy A_LoopFilePath, DestinationFolder "\" A_LoopFileName, DoOverwrite
        catch
        {
            ErrorCount += 1
        }
    }
    return ErrorCount
}

RestartScript() {
    Run(A_ScriptFullPath)
    ExitApp
}