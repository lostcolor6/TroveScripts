; Define the window titles
ClientWindowTitle := "Glyph"
LoginWindowTitles := ["Glyph Login", "Glyph Anmeldung", "Connexion à Glyph", "Вход в систему Glyph", "Inicio de sesión de Glyph", "Login da Glyph", "Glyph 로그인", "登录 Glyph"]
TargetWindowTitle := "Trove"

; Define account credentials from txt file(email and password for multiple accounts)

; Path to the credentials file
filePath := "credentials.txt"

; Arrays to hold account data
AccountNumbers := []
Emails := []
Passwords := []
WindowStates := [] ; Track window states: "logged_in", "crashed", "logging_in", "offline"

; Read the credentials file
FileRead, fileContent, %filePath%

; Parse the file content
Loop, Parse, fileContent, `n, `r ; Split by lines
{
    ; Skip empty lines
    if (A_LoopField = "")
        continue
    
    ; Split each line into account number, email and password
    StringSplit, accountData, A_LoopField, `,
    
    ; Add account data to respective arrays
    AccountNumbers.Push(accountData1)
    Emails.Push(accountData2)
    Passwords.Push(accountData3)
    WindowStates.Push("offline")
}

; Check if arrays are populated
if (Emails.Length() = 0 || Passwords.Length() = 0) {
    MsgBox, Error: No valid credentials found in the file.
    ExitApp
}





; Define the coordinates for clicking
ClickCoords := [1000, 20, 1000, 150, 1000, 100]

; Define the wait times (in milliseconds)
WaitTime := 1000
LongWaitTime := 2000

; Create a simple GUI window


Gui, Add, Text, x20 y20 w300 h20 vStatusText, Status: Not Running

Gui, Add, Button, gStartScript x20 y40 w100 h30, Start Script
Gui, Add, Button, gStopScript x120 y40 w100 h30, Stop Script


Gui, Add, Text, x20 y100 w200 h20, - Sending 'E' Key to %TargetWindowTitle% every %Interval% ms
Gui, Add, Button, gStartAntiAFK x20 y120 w100 h30, Start Anti-AFK
Gui, Add, Button, gStopAntiAFK x120 y120 w100 h30, Stop Anti-AFK

Gui, Add, Button, gStartAutoJump x20 y160 w100 h30, Start AutoJump
Gui, Add, Button, gStopAutoJump x120 y160 w100 h30, Stop AutoJump

Gui, Add, Button, gRearrangeWindows x40 y200 w150 h30, Rearrange Trove Windows
Gui, Add, Button, gShowDesktopInfo x220 y200 w120 h30, Desktop Info

Gui, Add, Button, gStartCrashDetection x20 y240 w100 h30, Start Monitor
Gui, Add, Button, gStopCrashDetection x120 y240 w100 h30, Stop Monitor
Gui, Add, Button, gShowWindowStatus x220 y240 w120 h30, Window Status

; Gui, Add, Text, x20 y280 w200 h20, - Hold space for autojump
Gui, Add, Text, x20 y320 w280 h20, - Ctrl +  Q to force Exit

Gui, Show, w420 h360, AutoHotkey Script Running

; Variable to control the loop (starts as true initially)
ScriptRunning := true

;AntiAFK settings
AntiAFKRunning := false
Interval := 200000 ; 200000 milliseconds = 200 seconds

AutoJump := false

; Crash detection settings
CrashDetectionRunning := false
CrashCheckInterval := 30000 ; Check every 30 seconds

; Function to rename a Trove window
RenameWindow(windowId, accountNumber) {
    newTitle := "Trove - Account " . accountNumber
    WinSetTitle, ahk_id %windowId%, , %newTitle%
    return newTitle
}

; Function to find window by account number
FindWindowByAccount(accountNumber) {
    targetTitle := "Trove - Account " . accountNumber
    WinGet, windowId, ID, %targetTitle%
    if (windowId) {
        return windowId
    }
    return 0
}

; Function to detect crashed windows and re-login
DetectAndFixCrashes() {
    Loop, % AccountNumbers.MaxIndex()
    {
        accountNum := AccountNumbers[A_Index]
        currentState := WindowStates[A_Index]
        
        ; Only check windows that should be logged in
        if (currentState = "logged_in") {
            windowId := FindWindowByAccount(accountNum)
            
            if (!windowId) {
                ; Window crashed or closed
                WindowStates[A_Index] := "crashed"
                GuiControl,, StatusText, Status: Account %accountNum% crashed, restarting...
                
                ; Start re-login process for this account
                ReloginAccount(A_Index)
            }
        }
    }
}

; Function to re-login a specific account
ReloginAccount(accountIndex) {
    if (!ScriptRunning) {
        return
    }
    
    accountNum := AccountNumbers[accountIndex]
    email := Emails[accountIndex]
    password := Passwords[accountIndex]
    
    WindowStates[accountIndex] := "logging_in"
    
    ; Start a new instance of the client
    Run, "C:\Program Files (x86)\Glyph\GlyphClient.exe"
    Sleep, LongWaitTime
    
    ; Wait for the client window to appear
    WinWait, %ClientWindowTitle%,, 10
    if !WinExist() {
        WindowStates[accountIndex] := "crashed"
        return
    }
    
    ; Activate the client window
    WinActivate
    
    ; Click on the coordinates (same as original login process)
    Loop, 3 {
        MouseMove, ClickCoords[(A_Index*2)-1], ClickCoords[A_Index*2], 0
        Sleep, WaitTime
        Click
        Sleep, WaitTime
    }
    
    ; Wait for login window
    loginWindowFound := false
    Loop, % LoginWindowTitles.MaxIndex() {
        LoginWindowTitle := LoginWindowTitles[A_Index]
        WinWait, %LoginWindowTitle%,, 10
        if WinExist(LoginWindowTitle) {
            loginWindowFound := true
            break
        }
    }
    
    if (!loginWindowFound) {
        WindowStates[accountIndex] := "crashed"
        return
    }
    
    ; Activate the login window
    WinActivate
    
    ; Input credentials
    SetKeyDelay, 10, 10
    ; Escape the @ symbol in email
    emailEscaped := StrReplace(email, "@", "{@}")
    ControlSend,, %emailEscaped%, %LoginWindowTitle%
    Sleep, WaitTime
    ControlSend,, {Tab}, %LoginWindowTitle%
    Sleep, WaitTime
    
    SetKeyDelay, 20, 10
    ControlSend,, % StrReplace(password, "#", "{#}"), %LoginWindowTitle%
    Sleep, WaitTime
    ControlSend,, {Enter}, %LoginWindowTitle%
    Sleep, LongWaitTime
    
    ; Wait for login to complete
    WinWaitNotActive, %LoginWindowTitle%,, 30
    
    ; Activate Glyph client and start game
    WinActivate, %ClientWindowTitle%
    MouseMove, ClickCoords[5], ClickCoords[6], 0
    Sleep, WaitTime
    Click
    Sleep, WaitTime
    
    ; Wait a bit for Trove to start, then rename the window
    Sleep, 5000
    WinWait, %TargetWindowTitle%,, 30
    if WinExist() {
        WinGet, newWindowId, ID, %TargetWindowTitle%
        RenameWindow(newWindowId, accountNum)
        WindowStates[accountIndex] := "logged_in"
        GuiControl,, StatusText, Status: Account %accountNum% successfully restarted
    } else {
        WindowStates[accountIndex] := "crashed"
    }
}


;AUTO-OPEN

; Function to start the script
StartScript:
    if (ScriptRunning)
    {
        MsgBox, press Start Script to run!
        ScriptRunning := false 
        return
    }
    
    ScriptRunning := true
    GuiControl,, StatusText, Status: Logging in to each instance

    ; Start the login process when "Start Script" is clicked
    Loop, % Emails.MaxIndex()  ; Loop through all accounts
    {
        ; Start a new instance of the client
        Run, "C:\Program Files (x86)\Glyph\GlyphClient.exe" ; Replace with the actual path to your client executable
        Sleep, LongWaitTime ; Wait for the client to load

        ; Exit the loop if the script is stopped
        if (!ScriptRunning)
            Break

        ; Wait for the client window to appear
        WinWait, %ClientWindowTitle%,, 10 ; Wait up to 10 seconds for the window to appear
        if !WinExist()
        {
            MsgBox, Client window not found for account %A_Index%! Exiting script.
            ExitApp
        }

        ; Activate the client window
        WinActivate

        ; Click on the coordinates
        Loop, 3
        {
            MouseMove, ClickCoords[(A_Index*2)-1], ClickCoords[A_Index*2], 0
            Sleep, WaitTime
            Click
            Sleep, WaitTime
        }


        ;This might slow down the script since it runs and checks in each iteration of the loop
        ; Wait for the login window to appear
        loginWindowFound := false
        Loop, % LoginWindowTitles.MaxIndex()
        {
            LoginWindowTitle := LoginWindowTitles[A_Index]
            WinWait, %LoginWindowTitle%,, 10 ; Wait up to 10 seconds for the window to appear
            if WinExist(LoginWindowTitle)
            {
                loginWindowFound := true
                break
            }
        }

        if (!loginWindowFound)
        {
            MsgBox, Login window not found for account %A_Index%! Exiting script.
            ExitApp
        }
        ; Wait for the login window to appear
        WinWait, %LoginWindowTitle%,, 10 ; Wait up to 10 seconds for the window to appear
        if !WinExist()
        {
            MsgBox, Login window not found for account %A_Index%! Exiting script.
            ExitApp
        }




        ; Activate the login window
        WinActivate

        ; Input the email
        email := Emails[A_Index]
        SetKeyDelay, 10, 10 ; Set a delay of 10ms between key presses
        ; Escape the @ symbol in email
        emailEscaped := StrReplace(email, "@", "{@}")
        ControlSend,, %emailEscaped%, %LoginWindowTitle% ; Send email to the email field
        Sleep, WaitTime

        ; Move focus to password field
        ControlSend,, {Tab}, %LoginWindowTitle%
        Sleep, WaitTime

        ; Input the password
        password := Passwords[A_Index]
        SetKeyDelay, 20, 10 ; Set a delay of 10ms between key presses
        ControlSend,, % StrReplace(password, "#", "{#}"), %LoginWindowTitle%
        Sleep, WaitTime

        ; Press Enter to log in
        ControlSend,, {Enter}, %LoginWindowTitle%
        Sleep, LongWaitTime ; Wait for login to process

        ; Wait for the login window to close
        WinWaitNotActive, %LoginWindowTitle%,, 30 ; Wait up to 30 seconds for the window to close
        if WinExist()
        {
            MsgBox, Login window did not close for account %A_Index%! Exiting script.
            ExitApp
        }

        ; Activate the Glyph client window
        WinActivate, %ClientWindowTitle%

        ; Click on the final coordinate
        MouseMove, ClickCoords[5], ClickCoords[6], 0
        Sleep, WaitTime
        Click
        Sleep, WaitTime
        
        ; Wait for Trove to launch and rename the window
        accountNum := AccountNumbers[A_Index]
        WindowStates[A_Index] := "logging_in"
        
        ; Wait a bit longer for Trove to fully load
        Sleep, 8000
        
        ; Find and rename the newest Trove window
        WinWait, %TargetWindowTitle%,, 30
        if WinExist() {
            WinGet, windowId, ID, %TargetWindowTitle%
            RenameWindow(windowId, accountNum)
            WindowStates[A_Index] := "logged_in"
            GuiControl,, StatusText, Status: Account %accountNum% logged in successfully
        } else {
            WindowStates[A_Index] := "crashed"
            GuiControl,, StatusText, Status: Account %accountNum% failed to start
        }
    }
    
    ; Start crash detection after all accounts are logged in
    SetTimer, CrashDetectionTimer, %CrashCheckInterval%
    CrashDetectionRunning := true
    GuiControl,, StatusText, Status: All accounts logged in, monitoring for crashes
return

; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    GuiControl,, StatusText, Status: Not Running
return

; Function to rearrange the Trove windows dynamically
RearrangeWindows:
    ; Get primary monitor resolution
    SysGet, PrimaryMonitor, MonitorPrimary
    SysGet, MonitorWorkArea, MonitorWorkArea, %PrimaryMonitor%
    
    ; Calculate usable desktop area (excluding taskbar)
    DesktopWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
    DesktopHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
    
    ; Get list of all Trove windows (both original and renamed)
    WinGet, id, list, Trove
    WindowCount := id
    
    if (WindowCount = 0) {
        MsgBox, No Trove windows found!
        return
    }
    
    ; Calculate optimal grid layout
    GridLayout := CalculateOptimalGrid(WindowCount)
    Columns := GridLayout.Columns
    Rows := GridLayout.Rows
    
    ; Calculate window dimensions with small padding
    Padding := 5
    WindowWidth := Floor((DesktopWidth - (Padding * (Columns + 1))) / Columns)
    WindowHeight := Floor((DesktopHeight - (Padding * (Rows + 1))) / Rows)
    
    ; Arrange windows in grid
    Loop, %WindowCount%
    {
        this_id := id%A_Index%
        
        ; Calculate grid position (cycles through grid for >6 windows)
        GridIndex := Mod(A_Index - 1, 6)  ; Reset every 6 windows for overlay
        RowNum := Floor(GridIndex / 3)     ; 0 or 1 for 3x2 grid
        ColNum := Mod(GridIndex, 3)        ; 0, 1, or 2
        
        ; Calculate actual screen coordinates
        X := MonitorWorkAreaLeft + Padding + (ColNum * (WindowWidth + Padding))
        Y := MonitorWorkAreaTop + Padding + (RowNum * (WindowHeight + Padding))
        
        ; For overlapping windows (>6), add slight offset
        if (A_Index > 6) {
            OverlayOffset := ((A_Index - 1) / 6) * 20
            X += OverlayOffset
            Y += OverlayOffset
        }
        
        ; Move and resize the window
        WinActivate, ahk_id %this_id%
        WinMove, ahk_id %this_id%, , X, Y, WindowWidth, WindowHeight
        
        ; Brief pause to ensure window operations complete
        Sleep, 50
    }
    
    GuiControl,, StatusText, Status: Arranged %WindowCount% windows in %Columns%x%Rows% grid
return

; Function to calculate optimal grid layout based on window count
CalculateOptimalGrid(windowCount)
{
    ; Default to 3x2 grid for up to 6 windows
    if (windowCount <= 6) {
        if (windowCount <= 3) {
            return {Columns: windowCount, Rows: 1}
        } else {
            return {Columns: 3, Rows: 2}
        }
    }
    
    ; For more than 6 windows, still use 3x2 base grid (windows will overlay)
    ; This maintains the preferred 3x2 layout as requested
    return {Columns: 3, Rows: 2}
}

; Function to show desktop information
ShowDesktopInfo:
    ; Get primary monitor information
    SysGet, PrimaryMonitor, MonitorPrimary
    SysGet, MonitorWorkArea, MonitorWorkArea, %PrimaryMonitor%
    SysGet, Monitor, Monitor, %PrimaryMonitor%
    
    ; Calculate dimensions
    FullWidth := MonitorRight - MonitorLeft
    FullHeight := MonitorBottom - MonitorTop
    WorkWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
    WorkHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
    TaskbarHeight := FullHeight - WorkHeight
    
    ; Get current Trove window count
    WinGet, id, list, %TargetWindowTitle%
    WindowCount := id
    
    ; Show information dialog
    InfoText := "Desktop Information:`n`n"
    InfoText .= "Full Resolution: " . FullWidth . " x " . FullHeight . "`n"
    InfoText .= "Work Area: " . WorkWidth . " x " . WorkHeight . "`n"
    InfoText .= "Taskbar Height: " . TaskbarHeight . "px`n`n"
    InfoText .= "Current Trove Windows: " . WindowCount . "`n"
    
    if (WindowCount > 0) {
        GridLayout := CalculateOptimalGrid(WindowCount)
        Columns := GridLayout.Columns
        Rows := GridLayout.Rows
        
        WindowWidth := Floor((WorkWidth - (5 * (Columns + 1))) / Columns)
        WindowHeight := Floor((WorkHeight - (5 * (Rows + 1))) / Rows)
        
        InfoText .= "Grid Layout: " . Columns . " x " . Rows . "`n"
        InfoText .= "Window Size: " . WindowWidth . " x " . WindowHeight . "`n"
        
        if (WindowCount > 6) {
            InfoText .= "`nNote: " . (WindowCount - 6) . " windows will overlay"
        }
    }
    
    MsgBox, 0, Desktop Information, %InfoText%
return





;ANTI-AFK

; Function to start the Anti-AFK script
StartAntiAFK:
    if (AntiAFKRunning) {
        MsgBox, Anti-AFK is already running!
        return
    }
    
    AntiAFKRunning := true
    SetTimer, AntiAFK, %Interval%
    GuiControl,, StatusText, Status: Anti-AFK Running
return

; Function to stop the Anti-AFK script
StopAntiAFK:
    AntiAFKRunning := false
    SetTimer, AntiAFK, Off
    GuiControl,, StatusText, Status: Not Running
return

; Anti-AFK function
AntiAFK:
while AntiAFKRunning
    {
        ; Check if the target window exists
        WinGet, id, list, %TargetWindowTitle%
        Loop, %id%
        {
            this_id := id%A_Index%
            ; Send 'E' to the window (even if it's in the background)
            ControlSend,, e, ahk_id %this_id%
        }

        ; Wait for the specified interval before sending again
        Sleep, %Interval%
    }
return



;AUTO-JUMP

; Function to start the AutoJump script
StartAutoJump:
    if (AutoJump) {
        MsgBox, Autojump is already running!
        return
    }
    
    AutoJump := true
    
    GuiControl,, StatusText, Status: AutoJump running
return

; Function to stop the AutoJump
StopAutoJump:
    AutoJump := false
    
    GuiControl,, StatusText, Status: AutoJump stopped
return


$Space::
; AutoJump function
    if (AutoJump) {
        while GetKeyState("Space", "P")  ; Checks if the space key is pressed
    {
        Send {Space}  ; Sends the space key
        Sleep 115  ; Adjust the delay between presses (50ms is a reasonable value, tweak as needed)
    }
    }
    else {
        if(GetKeyState("Space", "P")) {
            Send {Space}  ; If AutoJump is not running, just send the space key
        }
    }
    
return







/*



;MIRROR-WALK

; Set hotkeys for W, A, S, D for both press and release
~w::StartBroadcast("w")
~a::StartBroadcast("a")
~s::StartBroadcast("s")
~d::StartBroadcast("d")

; Detect when the keys are released
~w up::StopBroadcast("w")
~a up::StopBroadcast("a")
~s up::StopBroadcast("s")
~d up::StopBroadcast("d")

; Function to start broadcasting key presses to all Trove windows
StartBroadcast(key)
{
    ; Get the list of all open Trove windows
    WinGet, id, list, %TargetWindowTitle%
    
    ; Get the ID of the currently active window (so we don't send keys twice to it)
    WinGetActiveTitle, activeWindowTitle

    Loop, %id%
    {
        this_id := id%A_Index%

        ; Check if the window is the currently active window
        WinGetTitle, title, ahk_id %this_id%
        if (title != activeWindowTitle)
        {
            ; Send the key down to the window (hold key)
            ControlSend,, {%key% down}, ahk_id %this_id%
        }
    }
}

; Function to stop broadcasting when the key is released
StopBroadcast(key)
{
    ; Get the list of all open Trove windows
    WinGet, id, list, %TargetWindowTitle%
    
    ; Get the ID of the currently active window (so we don't send keys twice to it)
    WinGetActiveTitle, activeWindowTitle

    Loop, %id%
    {
        this_id := id%A_Index%

        ; Check if the window is the currently active window
        WinGetTitle, title, ahk_id %this_id%
        if (title != activeWindowTitle)
        {
            ; Send the key up to the window (release key)
            ControlSend,, {%key% up}, ahk_id %this_id%
        }
    }
}


*/

; Crash Detection Controls
StartCrashDetection:
    if (CrashDetectionRunning) {
        MsgBox, Crash detection is already running!
        return
    }
    
    CrashDetectionRunning := true
    SetTimer, CrashDetectionTimer, %CrashCheckInterval%
    GuiControl,, StatusText, Status: Crash detection started
return

StopCrashDetection:
    CrashDetectionRunning := false
    SetTimer, CrashDetectionTimer, Off
    GuiControl,, StatusText, Status: Crash detection stopped
return

; Timer function for crash detection
CrashDetectionTimer:
    if (CrashDetectionRunning) {
        DetectAndFixCrashes()
    }
return

; Function to show current window status
ShowWindowStatus:
    StatusText := "Window Status Report:`n`n"
    
    Loop, % AccountNumbers.MaxIndex() {
        accountNum := AccountNumbers[A_Index]
        email := Emails[A_Index]
        state := WindowStates[A_Index]
        windowId := FindWindowByAccount(accountNum)
        
        StatusText .= "Account " . accountNum . " (" . email . "):`n"
        StatusText .= "  State: " . state . "`n"
        
        if (windowId) {
            StatusText .= "  Window: Found (ID: " . windowId . ")`n"
        } else {
            StatusText .= "  Window: Not found`n"
        }
        StatusText .= "`n"
    }
    
    ; Add crash detection status
    StatusText .= "Crash Detection: " 
    if (CrashDetectionRunning) {
        StatusText .= "Running (checks every " . (CrashCheckInterval/1000) . "s)"
    } else {
        StatusText .= "Stopped"
    }
    
    MsgBox, 0, Window Status, %StatusText%
return

; Hotkey to force quit (Ctrl + Q)
^q::ExitApp



