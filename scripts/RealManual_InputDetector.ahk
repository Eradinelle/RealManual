#Requires AutoHotkey v2.0
#SingleInstance Force

scanIntervalMs := 75
maxDevices := 8
maxButtons := 32
axisNames := ["X", "Y", "Z", "R", "U", "V", "POV"]

SetTimer(UpdateInputDisplay, scanIntervalMs)

UpdateInputDisplay() {
    global maxDevices, maxButtons, axisNames

    output := ""
    output .= "RealManual Input Detector`n"
    output .= "Press F9 to reload. Press Esc to exit.`n`n"

    Loop maxDevices {
        deviceNumber := A_Index
        deviceText := BuildDeviceText(deviceNumber)

        if deviceText != "" {
            output .= deviceText "`n"
        }
    }

    if output = "RealManual Input Detector`nPress F9 to reload. Press Esc to exit.`n`n" {
        output .= "No joystick devices detected by AutoHotkey.`n"
    }

    ToolTip output
} ; end updateinputdisplay

BuildDeviceText(deviceNumber) {
    global maxButtons, axisNames

    devicePrefix := deviceNumber "Joy"
    hasReadableInput := false
    text := "Device " deviceNumber "`n"

    for axisName in axisNames {
        inputName := devicePrefix axisName
        value := SafeGetKeyState(inputName)

        if value != "__INVALID__" {
            hasReadableInput := true
            text .= "  " inputName " = " value "`n"
        }
    } ; end axis loop

    pressedButtons := ""

    Loop maxButtons {
        buttonNumber := A_Index
        inputName := devicePrefix buttonNumber
        value := SafeGetKeyState(inputName)

        if value != "__INVALID__" {
            hasReadableInput := true

            if value {
                pressedButtons .= inputName " "
            }
        }
    } ; end button loop

    if pressedButtons != "" {
        text .= "  Pressed Buttons = " pressedButtons "`n"
    } else {
        text .= "  Pressed Buttons = none`n"
    } ; end button display branch

    if hasReadableInput {
        return text
    } ; end device detected check

    return "" ; hides devices that do not respond
} ; end builddevicetext

SafeGetKeyState(inputName) {
    try {
        return GetKeyState(inputName)
    } catch {
        return "__INVALID__"
    } ; end try/catch
} ; end safegetkeystate

Esc::ExitApp
F9::Reload