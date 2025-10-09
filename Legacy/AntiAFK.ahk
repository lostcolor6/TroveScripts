; Define the window title or part of the title of the target program
TargetWindowTitle := "Trove"

; Define how frequently to send the 'E' key (in milliseconds)
Interval := 10000 ; 10000 milliseconds = 10 second

; Create a simple GUI window
Gui, Add, Text, x20 y10 w300 h20, Status: Not Running
Gui, Add, Button, gStartScript x60 y40 w100 h30, Start Script
Gui, Add, Button, gStopScript x60 y70 w100 h30, Stop Script
Gui, Show, w320 h130, AutoHotkey Script Running

; Variable to control the loop (starts as false)
ScriptRunning := false

; Function to start the script
StartScript:
    ScriptRunning := true
    GuiControl, Text, Status:, Status: Running
    Gosub, AntiAFKLoop
return

; Function to handle stopping the script
StopScript:
    ScriptRunning := false ; Stop the loop
    Gui, Destroy ; Close the GUI
    ExitApp ; Exit the script
return

; Anti-AFK loop
AntiAFKLoop:
    while ScriptRunning
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



; Hotkey to force quit (Ctrl + Q)
^x::ExitApp





