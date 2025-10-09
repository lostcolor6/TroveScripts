; Define the window title to target
TargetWindowTitle := "Trove"

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

; Hotkey to quit the script (Ctrl + Q)
^q::Exit

