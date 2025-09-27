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
emailCount := Emails.MaxIndex()
passwordCount := Passwords.MaxIndex()
if (emailCount = "" || passwordCount = "" || emailCount = 0 || passwordCount = 0) {
    MsgBox, Error: No valid credentials found in the file.
    ExitApp
}





; Define the coordinates for clicking
ClickCoords := [1000, 20, 1000, 150, 1000, 100]

; Define the wait times (in milliseconds)
WaitTime := 1000
LongWaitTime := 2000

; Create a modern GUI window with tabs
Gui, Add, Tab3, x10 y10 w780 h500 vMainTabs, Accounts|Settings|Tools

; === ACCOUNTS TAB ===
Gui, Tab, Accounts

; Status and main controls
Gui, Add, Text, x20 y50 w300 h20 vStatusText, Status: Not Running
Gui, Add, Button, gStartScript x20 y75 w100 h30, Start All
Gui, Add, Button, gStopScript x130 y75 w100 h30, Stop All

; Account table header
Gui, Add, Text, x20 y120 w40 h20 +Center +Border, #
Gui, Add, Text, x60 y120 w200 h20 +Center +Border, Email
Gui, Add, Text, x260 y120 w80 h20 +Center +Border, Status
Gui, Add, Text, x340 y120 w80 h20 +Center +Border, Action

; Create account rows dynamically
AccountRowY := 140
Loop, % Emails.MaxIndex() {
    accountNum := AccountNumbers[A_Index]
    email := Emails[A_Index]
    
    ; Account number
    Gui, Add, Text, x20 y%AccountRowY% w40 h25 +Center +Border vAccNum%A_Index%, %accountNum%
    
    ; Email
    Gui, Add, Text, x60 y%AccountRowY% w200 h25 +Center +Border vAccEmail%A_Index%, %email%
    
    ; Status
    Gui, Add, Text, x260 y%AccountRowY% w80 h25 +Center +Border vAccStatus%A_Index%, Offline
    
    ; Individual login button
    Gui, Add, Button, x340 y%AccountRowY% w80 h25 gLoginAccount%A_Index% vLoginBtn%A_Index%, Login
    
    AccountRowY += 25
}

; === SETTINGS TAB ===
Gui, Tab, Settings

; Anti-AFK Settings
Gui, Add, GroupBox, x20 y50 w350 h80, Anti-AFK Settings
Gui, Add, Checkbox, x30 y75 w150 h20 vAntiAFKCheck gToggleAntiAFK, Enable Anti-AFK
Gui, Add, Text, x30 y100 w200 h20, Send 'E' key every %Interval% ms

; AutoJump Settings  
Gui, Add, GroupBox, x20 y140 w350 h60, AutoJump Settings
Gui, Add, Checkbox, x30 y165 w150 h20 vAutoJumpCheck gToggleAutoJump, Enable AutoJump

; === TOOLS TAB ===
Gui, Tab, Tools

Gui, Add, Button, gRearrangeWindows x20 y50 w150 h40, Rearrange Windows
Gui, Add, Button, gShowDesktopInfo x180 y50 w120 h40, Desktop Info

; Instructions
Gui, Add, Text, x20 y120 w350 h40, Instructions:`n- Use checkboxes in Settings tab to enable/disable features`n- Individual login buttons are available in Accounts tab
Gui, Add, Text, x20 y180 w280 h20, Press Ctrl + Q to force exit

Gui, Tab ; End tab creation

Gui, Show, w800 h520, Trove Auto Login Manager

; Variable to control the loop (starts as false initially)
ScriptRunning := false

;AntiAFK settings
AntiAFKRunning := false
Interval := 200000 ; 200000 milliseconds = 200 seconds

AutoJump := false

; GUI checkbox variables (will be set by Gui, Submit, NoHide)
AntiAFKCheck := false
AutoJumpCheck := false

; Prevent any automatic execution
return

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

; Removed crash detection and auto re-login functions as requested


;AUTO-OPEN

; Individual account login functions (dynamically handle up to 10 accounts)
LoginAccount1:
    GuiControl,, StatusText, DEBUG: LoginAccount1 button clicked!
    LoginSingleAccount(1)
return
LoginAccount2:
    GuiControl,, StatusText, DEBUG: LoginAccount2 button clicked!
    LoginSingleAccount(2)
return
LoginAccount3:
    GuiControl,, StatusText, DEBUG: LoginAccount3 button clicked!
    LoginSingleAccount(3)
return
LoginAccount4:
    GuiControl,, StatusText, DEBUG: LoginAccount4 button clicked!
    LoginSingleAccount(4)
return
LoginAccount5:
    GuiControl,, StatusText, DEBUG: LoginAccount5 button clicked!
    LoginSingleAccount(5)
return
LoginAccount6:
    GuiControl,, StatusText, DEBUG: LoginAccount6 button clicked!
    LoginSingleAccount(6)
return
LoginAccount7:
    GuiControl,, StatusText, DEBUG: LoginAccount7 button clicked!
    LoginSingleAccount(7)
return
LoginAccount8:
    GuiControl,, StatusText, DEBUG: LoginAccount8 button clicked!
    LoginSingleAccount(8)
return
LoginAccount9:
    GuiControl,, StatusText, DEBUG: LoginAccount9 button clicked!
    LoginSingleAccount(9)
return
LoginAccount10:
    GuiControl,, StatusText, DEBUG: LoginAccount10 button clicked!
    LoginSingleAccount(10)
return

; Function to login a single account
LoginSingleAccount(accountIndex) {
    global AccountNumbers, Emails, Passwords, WindowStates
    global ClientWindowTitle, LoginWindowTitles, TargetWindowTitle
    global ClickCoords, WaitTime, LongWaitTime
    
    ; Debug: Function called
    GuiControl,, StatusText, DEBUG: LoginSingleAccount called for index %accountIndex%
    Sleep, 1000  ; Give time to see the message
    
    maxAccounts := Emails.MaxIndex()
    GuiControl,, StatusText, DEBUG: Checking arrays - maxAccounts: %maxAccounts%
    Sleep, 1000
    
    if (maxAccounts = "" || accountIndex > maxAccounts) {
        GuiControl,, StatusText, DEBUG: Invalid account index %accountIndex% (max: %maxAccounts%)
        return
    }
    
    accountNum := AccountNumbers[accountIndex]
    email := Emails[accountIndex] 
    password := Passwords[accountIndex]
    
    ; Debug: Account info
    GuiControl,, StatusText, DEBUG: Account %accountNum% - %email%
    Sleep, 1000
    
    GuiControl,, AccStatus%accountIndex%, Logging in...
    GuiControl,, StatusText, DEBUG: Starting Glyph client for Account %accountNum%
    Sleep, 1000
    
    ; Start a new instance of the client
    Run, "C:\Program Files (x86)\Glyph\GlyphClient.exe"
    Sleep, LongWaitTime
    
    ; Debug: Waiting for client window
    GuiControl,, StatusText, DEBUG: Waiting for Glyph client window...
    Sleep, 1000
    
    ; Wait for the client window to appear
    WinWait, %ClientWindowTitle%,, 10
    if !WinExist() {
        GuiControl,, AccStatus%accountIndex%, Failed
        GuiControl,, StatusText, DEBUG: ERROR - Glyph client window not found for Account %accountNum%
        return
    }
    
    ; Debug: Client window found
    GuiControl,, StatusText, DEBUG: Glyph client found, activating...
    Sleep, 1000
    
    ; Activate the client window
    WinActivate
    
    ; Debug: Clicking coordinates
    GuiControl,, StatusText, DEBUG: Clicking coordinates in Glyph client...
    Sleep, 1000
    
    ; Click on the coordinates
    Loop, 3 {
        coordX := ClickCoords[(A_Index*2)-1]
        coordY := ClickCoords[A_Index*2]
        GuiControl,, StatusText, DEBUG: Clicking %coordX%,%coordY% (click %A_Index%/3)
        MouseMove, coordX, coordY, 0
        Sleep, WaitTime
        Click
        Sleep, WaitTime
    }
    
    ; Debug: Waiting for login window
    GuiControl,, StatusText, DEBUG: Searching for login window...
    
    ; Wait for login window with reduced timeout (20 seconds max)
    loginWindowFound := false
    Loop, % LoginWindowTitles.MaxIndex() {
        LoginWindowTitle := LoginWindowTitles[A_Index]
        GuiControl,, StatusText, DEBUG: Looking for window: %LoginWindowTitle%
        WinWait, %LoginWindowTitle%,, 2 ; Reduced wait time to 2 seconds per attempt
        if WinExist(LoginWindowTitle) {
            loginWindowFound := true
            GuiControl,, StatusText, DEBUG: Found login window: %LoginWindowTitle%
            break
        }
    }
    
    if (!loginWindowFound) {
        GuiControl,, AccStatus%accountIndex%, Failed
        GuiControl,, StatusText, DEBUG: ERROR - No login window found for Account %accountNum%
        return
    }
    
    ; Debug: Activating login window
    GuiControl,, StatusText, DEBUG: Activating login window and entering credentials...
    
    ; Activate the login window and input credentials quickly
    WinActivate
    Sleep, 500 ; Reduced wait time
    
    ; Debug: Sending email
    GuiControl,, StatusText, DEBUG: Sending email: %email%
    
    ; Input email
    SetKeyDelay, 10, 10
    Send, %email%
    Sleep, 500 ; Reduced wait time
    
    ; Debug: Moving to password field
    GuiControl,, StatusText, DEBUG: Moving to password field...
    
    ; Move to password field
    ControlSend,, {Tab}, %LoginWindowTitle%
    Sleep, 500 ; Reduced wait time
    
    ; Debug: Sending password
    GuiControl,, StatusText, DEBUG: Sending password...
    
    ; Input password
    SetKeyDelay, 20, 10
    ControlSend,, % StrReplace(password, "#", "{#}"), %LoginWindowTitle%
    Sleep, 500 ; Reduced wait time
    
    ; Debug: Pressing Enter
    GuiControl,, StatusText, DEBUG: Pressing Enter to login...
    
    ; Press Enter to log in
    ControlSend,, {Enter}, %LoginWindowTitle%
    Sleep, 1000 ; Reduced wait time
    
    ; Debug: Waiting for login completion
    GuiControl,, StatusText, DEBUG: Waiting for login window to close...
    
    ; Wait for login to complete (max 20 seconds)
    WinWaitNotActive, %LoginWindowTitle%,, 20
    
    ; Debug: Starting game
    GuiControl,, StatusText, DEBUG: Login window closed, starting game...
    
    ; Activate Glyph client and start game
    WinActivate, %ClientWindowTitle%
    MouseMove, ClickCoords[5], ClickCoords[6], 0
    Sleep, WaitTime
    Click
    Sleep, WaitTime
    
    ; Debug: Waiting for Trove
    GuiControl,, StatusText, DEBUG: Waiting for Trove to launch...
    
    ; Wait for Trove to launch
    Sleep, 5000
    WinWait, %TargetWindowTitle%,, 20 ; Reduced to 20 seconds max
    if WinExist() {
        WinGet, windowId, ID, %TargetWindowTitle%
        RenameWindow(windowId, accountNum)
        WindowStates[accountIndex] := "logged_in"
        GuiControl,, AccStatus%accountIndex%, Online
        GuiControl,, StatusText, DEBUG: SUCCESS - Account %accountNum% logged in and Trove started
    } else {
        WindowStates[accountIndex] := "crashed"
        GuiControl,, AccStatus%accountIndex%, Failed
        GuiControl,, StatusText, DEBUG: ERROR - Trove failed to start for Account %accountNum%
    }
}

; Function to start the script
StartScript:
    if (ScriptRunning)
    {
        MsgBox, All accounts login already in progress!
        return
    }
    
    ScriptRunning := true
    GuiControl,, StatusText, Status: Logging in to all accounts

    ; Start the login process when "Start Script" is clicked
    Loop, % Emails.MaxIndex()  ; Loop through all accounts
    {
        ; Update GUI status
        GuiControl,, AccStatus%A_Index%, Logging in...
        
        ; Start a new instance of the client
        Run, "C:\Program Files (x86)\Glyph\GlyphClient.exe"
        Sleep, LongWaitTime

        ; Exit the loop if the script is stopped
        if (!ScriptRunning)
            Break

        ; Wait for the client window to appear (reduced timeout)
        WinWait, %ClientWindowTitle%,, 10
        if !WinExist()
        {
            GuiControl,, AccStatus%A_Index%, Failed
            GuiControl,, StatusText, Status: Client failed for Account %A_Index%
            continue
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

        ; Wait for the login window to appear (reduced total wait time to max 20 seconds)
        loginWindowFound := false
        Loop, % LoginWindowTitles.MaxIndex()
        {
            LoginWindowTitle := LoginWindowTitles[A_Index]
            WinWait, %LoginWindowTitle%,, 3 ; 3 seconds per window title
            if WinExist(LoginWindowTitle)
            {
                loginWindowFound := true
                break
            }
        }

        if (!loginWindowFound)
        {
            GuiControl,, AccStatus%A_Index%, Failed
            GuiControl,, StatusText, Status: Login window not found for Account %A_Index%
            continue
        }

        ; Activate the login window and input credentials quickly
        WinActivate
        Sleep, 500 ; Reduced delay

        ; Input the email
        email := Emails[A_Index]
        SetKeyDelay, 10, 10
        Send, %email%
        Sleep, 500 ; Reduced delay

        ; Move focus to password field
        ControlSend,, {Tab}, %LoginWindowTitle%
        Sleep, 500 ; Reduced delay

        ; Input the password
        password := Passwords[A_Index]
        SetKeyDelay, 20, 10
        ControlSend,, % StrReplace(password, "#", "{#}"), %LoginWindowTitle%
        Sleep, 500 ; Reduced delay

        ; Press Enter to log in
        ControlSend,, {Enter}, %LoginWindowTitle%
        Sleep, 1000 ; Reduced delay

        ; Wait for the login window to close (max 20 seconds)
        WinWaitNotActive, %LoginWindowTitle%,, 20
        
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
        
        ; Wait for Trove to fully load (reduced time)
        Sleep, 5000
        
        ; Find and rename the newest Trove window
        WinWait, %TargetWindowTitle%,, 20 ; Reduced to 20 seconds max
        if WinExist() {
            WinGet, windowId, ID, %TargetWindowTitle%
            RenameWindow(windowId, accountNum)
            WindowStates[A_Index] := "logged_in"
            GuiControl,, AccStatus%A_Index%, Online
            GuiControl,, StatusText, Status: Account %accountNum% logged in successfully
        } else {
            WindowStates[A_Index] := "crashed"
            GuiControl,, AccStatus%A_Index%, Failed
            GuiControl,, StatusText, Status: Account %accountNum% failed to start
        }
    }
    
    GuiControl,, StatusText, Status: All accounts processed
return

; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    GuiControl,, StatusText, Status: Script stopped
    
    ; Reset all account statuses to offline
    Loop, % Emails.MaxIndex() {
        GuiControl,, AccStatus%A_Index%, Offline
        WindowStates[A_Index] := "offline"
    }
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

; Function to toggle Anti-AFK based on checkbox
ToggleAntiAFK:
    Gui, Submit, NoHide
    if (AntiAFKCheck) {
        if (!AntiAFKRunning) {
            AntiAFKRunning := true
            SetTimer, AntiAFK, %Interval%
            GuiControl,, StatusText, Status: Anti-AFK Started
        }
    } else {
        if (AntiAFKRunning) {
            AntiAFKRunning := false
            SetTimer, AntiAFK, Off
            GuiControl,, StatusText, Status: Anti-AFK Stopped
        }
    }
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

; Function to toggle AutoJump based on checkbox
ToggleAutoJump:
    Gui, Submit, NoHide
    if (AutoJumpCheck) {
        if (!AutoJump) {
            AutoJump := true
            GuiControl,, StatusText, Status: AutoJump Started
        }
    } else {
        if (AutoJump) {
            AutoJump := false
            GuiControl,, StatusText, Status: AutoJump Stopped
        }
    }
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





; Removed crash detection and window status functionality as requested

; Hotkey to force quit (Ctrl + Q)
^q::ExitApp


