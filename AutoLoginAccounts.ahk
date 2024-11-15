; Define the window titles
ClientWindowTitle := "Glyph"
LoginWindowTitle := "Glyph Anmeldung" ; This is the German translation of "Glyph Login"
TargetWindowTitle := "Trove"

; Define account credentials (email and password for multiple accounts)
Emails := ["exampel1@gmail.com", "exampel2@gmail.com", "exampel3@gmail.com", "exampel4@gmail.com", "exampel5@gmail.com", "exampel6@gmail.com"]
Passwords := ["pw1", "pw2", "pw3", "pw4", "pw5", "pw6"]

; Define the coordinates for clicking
ClickCoords := [1000, 20, 1000, 150, 1000, 100]

; Define the wait times (in milliseconds)
WaitTime := 500
LongWaitTime := 2000

; Create a simple GUI window


Gui, Add, Text, x20 y20 w300 h20 vStatusText, Status: Not Running

Gui, Add, Button, gStartScript x20 y40 w100 h30, Start Script
Gui, Add, Button, gStopScript x120 y40 w100 h30, Stop Script


Gui, Add, Text, x20 y100 w200 h20, - Sending 'E' Key to %TargetWindowTitle% every %Interval% ms
Gui, Add, Button, gStartAntiAFK x20 y120 w100 h30, Start Anti-AFK
Gui, Add, Button, gStopAntiAFK x120 y120 w100 h30, Stop Anti-AFK

Gui, Add, Button, gRearrangeWindows x40 y200 w150 h30, Rearrange Trove Windows

Gui, Add, Text, x20 y260 w200 h20, - Hold space for autojump
Gui, Add, Text, x20 y280 w280 h20, - Ctrl +  Q to force Exit

Gui, Show, w420 h320, AutoHotkey Script Running

; Variable to control the loop (starts as true initially)
ScriptRunning := true

;AntiAFK settings
AntiAFKRunning := false
Interval := 10000 ; 10000 milliseconds = 10 seconds


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
        ControlSend,, %email%, %LoginWindowTitle% ; Send email to the email field
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
    }
return

; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    GuiControl,, StatusText, Status: Not Running
return

; Function to rearrange the Trove windows
RearrangeWindows:
    WinGet, id, list, %TargetWindowTitle%
    Loop, %id%
    {
        ; Calculate the position for each window
        this_id := id%A_Index%
        RowNum := Mod(A_Index - 1, 2) ; 2 rows
        ColNum := Floor((A_Index - 1) / 2) ; 3 columns
        X := ColNum * 800 ; window width: 800
        Y := RowNum * 500 ; window height: 500

        ; Move the window to the calculated position and resize it
        WinActivate, ahk_id %this_id%
        WinMove, ahk_id %this_id%, , X, Y, 800, 500
    }
return



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



$Space::
    while GetKeyState("Space", "P")  ; Checks if the space key is pressed
    {
        Send {Space}  ; Sends the space key
        Sleep 115  ; Adjust the delay between presses (50ms is a reasonable value, tweak as needed)
    }
return

; Hotkey to force quit (Ctrl + Q)
^q::ExitApp



