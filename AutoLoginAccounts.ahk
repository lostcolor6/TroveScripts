; Define the window titles
ClientWindowTitle := "Glyph"
LoginWindowTitle := "Glyph Anmeldung" ;This is the german translation of "Glyph Login"
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
Gui, Add, Text, x20 y10 w300 h20 vStatusText, Status: Not Running
Gui, Add, Button, gStartScript x60 y40 w100 h30, Start Script
Gui, Add, Button, gStopScript x60 y70 w100 h30, Stop Script
Gui, Add, Button, gRearrangeWindows x60 y100 w150 h30, Rearrange Trove Windows
Gui, Show, w320 h130, AutoHotkey Script Running

; Variable to control the loop (starts as false initially)
ScriptRunning := false

; Function to start the script
StartScript:
    if (ScriptRunning)
    {
        MsgBox, Script is already running!
        return
    }
    
    ScriptRunning := true
    GuiControl,, StatusText, Status: Logging in to each instance

    ; Start the login process when "Start Script" is clicked
    Gosub, LoginLoop
return

; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    Gui, Destroy ; Close the GUI
    ExitApp ; Exit the script
return

; Login loop
LoginLoop:
    ; Start a new instance of the client for each account
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
        ; To send a literal #, use {#} inside ControlSend
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

; Hotkey to force quit (Ctrl + Q)
^q::ExitApp




/*


; Define the window title or part of the title of the target program
TargetWindowTitle := "Trove" ; Replace with the actual title of the program

; Define how frequently to send the 'E' key (in milliseconds)
Interval := 1000 ; 1000 milliseconds = 1 second

; Create a simple GUI window
Gui, Add, Text, x20 y10 w200 h20, - Hold space for autojump
Gui, Add, Text, x20 y50 w200 h20, - Status: Sending 'E' to %TargetWindowTitle%
Gui, Add, Text, x20 y70 w200 h20, - Ctrl + Alt + Q to force Exit
Gui, Add, Text, x20 y90 w200 h20 vMousePosText, Mouse Position: (0, 0) ; Placeholder for mouse position
Gui, Add, Button, gStopScript x60 y110 w100 h30, Stop Script
Gui, Show, w600 h300, AutoHotkey Script Running

; Variable to control the loop (starts as true)
ScriptRunning := true

; Loop to send 'E' key
Loop
{
    ; Exit the loop if the script is stopped
    if (!ScriptRunning)
        Break

    ; Check if the target window exists
    IfWinExist, %TargetWindowTitle%
    {
        ; Send 'E' to the window (even if it's in the background)
        ControlSend,, e, %TargetWindowTitle%
    }

    ; Wait for the specified interval before sending again
    Sleep, %Interval%
}

$Space::
    while GetKeyState("Space", "P")  ; Checks if the space key is pressed
    {
        Send {Space}  ; Sends the space key
        Sleep 115  ; Adjust the delay between presses (50ms is a reasonable value, tweak as needed)
    }
return



; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    Gui, Destroy ; Close the GUI
    ExitApp ; Exit the script
return

; Hotkey to force quit (Ctrl + Q)
^x::ExitApp
*/




