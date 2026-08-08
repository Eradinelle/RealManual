; =============================================================================
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
; =============================================================================
; SECTION 2: TRAY MENU SETUP
; =============================================================================
; SECTION 3: CONFIG FILE HELPERS
; =============================================================================
; SECTION 4: CONFIG LOADING - MODE AND FEATURES
; =============================================================================
; SECTION 5: CONFIG LOADING - NOTIFICATIONS AND TIMING
; =============================================================================
; SECTION 6: CONFIG LOADING - AXES, THRESHOLDS, AND OUTPUT KEYS
; =============================================================================
; SECTION 7: CONFIG LOADING - SHIFTER AND SEQUENTIAL SETTINGS
; =============================================================================
; SECTION 8: RUNTIME STATE VARIABLES
; =============================================================================
; SECTION 9: INPUT AND OUTPUT MAPS
; =============================================================================
; SECTION 10: LOW-LEVEL OUTPUT HELPERS & SAFETY
; =============================================================================
; SECTION 11: LOW-LEVEL INPUT READERS
; =============================================================================
; SECTION 12: NOTIFICATIONS, VALIDATION, AND LOGGING
; =============================================================================
; SECTION 13: DYNAMIC HOTKEYS AND LIVE MODE TOGGLES
; =============================================================================
; SECTION 14: AUXILIARY INPUT HANDLERS
; =============================================================================
; SECTION 15: STALL / ENGINE OFF/ON SIMULATION LOGIC
; =============================================================================
; SECTION 16: H-PATTERN TRANSMISSION LOGIC
; =============================================================================
; SECTION 17: SEQUENTIAL TRANSMISSION LOGIC
; =============================================================================
; SECTION 18: RECOVERY AND MANUAL SYNC
; =============================================================================
; SECTION 19: MAIN LOOP
; =============================================================================
; SECTION 20: STARTUP
; =============================================================================
; SECTION 21: HOTKEYS
; =============================================================================


; =============================================================================
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force ; prevent duplicate copies of this script
#UseHook true ; force keyboard hook for better game compatibility
appName := "RealManual"
appVersion := "1.0.0"
SendMode "Event" ; event-style key sending for older games
configFile := A_ScriptDir "\config.ini" ; config path needs to be beside this script
SetKeyDelay 0, 0 ; sends keys as quickly as possible


; =============================================================================
; SECTION 2: TRAY MENU SETUP
; =============================================================================

A_TrayMenu.Delete()
A_TrayMenu.Add("Reload Config", (*) => Reload())
A_TrayMenu.Default := "Reload Config"
A_TrayMenu.Add()
A_TrayMenu.Add("Pause RealManual", ToggleScriptPause)
A_TrayMenu.Add("Open Validation Log", OpenValidationLog)
A_TrayMenu.Add()
A_TrayMenu.Add("Exit RealManual", (*) => ExitApp())


; =============================================================================
; SECTION 3: CONFIG FILE HELPERS
; =============================================================================

; =============================================================================
; ReadBool(section, key, fallback)
; -----------------------------------------------------------------------------
; Reads a true/false option from config.ini.
; The fallback value is used when the setting is missing from config.ini.
; This keeps the script usable with deleted or forgotten config lines.
; =============================================================================
ReadBool(section, key, fallback) {
    global configFile
    return IniRead(configFile, section, key, fallback ? "1" : "0") = "1" ; returns true on 1
} ; end readbool


; =============================================================================
; ReadInt(section, key, fallback)
; -----------------------------------------------------------------------------
; Reads a numeric integer option from config.ini.
;
; Used for timing and threshold values such as:
;   KeyHoldMs
;   ScanIntervalMs
;   ClutchThreshold
;   HandbrakeThreshold
;
; AutoHotkey reads INI values as text, so this function converts the result into
; an integer before returning it.
; =============================================================================
ReadInt(section, key, fallback) {
    global configFile
    return Integer(IniRead(configFile, section, key, fallback))
} ; end readint


; =============================================================================
; ReadText(section, key, fallback)
; -----------------------------------------------------------------------------
; Reads a text option from config.ini.
;
; Used for key names, joystick button names, and joystick axis names such as:
;   1Joy13
;   1JoyY
;   Space
;   n
;
; The fallback value protects from broken or incomplete config files.
; =============================================================================
ReadText(section, key, fallback) {
    global configFile
    return IniRead(configFile, section, key, fallback)
} ; end readtext


; =============================================================================
; SECTION 4: CONFIG LOADING - MODE AND FEATURES
; =============================================================================

transmissionIsSequential := ReadBool("Mode", "TransmissionIsSequential", false)
invertSequentialAxis := ReadBool("Mode", "InvertSequentialAxis", false)
requireClutch := ReadBool("Mode", "RequireClutch", true)
clutchActsAsNeutral := ReadBool("Mode", "ClutchActsAsNeutral", true)
maxForwardGear := ReadInt("Mode", "MaxForwardGear", 6) ; highest forward gear supported by current car
enableHandbrake := ReadBool("Mode", "EnableHandbrake", true)
enableReverse := ReadBool("Mode", "EnableReverse", true) ; true = reverse slot enabled
enableSyncHotkeys := ReadBool("Mode", "EnableSyncHotkeys", true)
enableLiveHotkeys := ReadBool("LiveHotkeys", "EnableLiveHotkeys", true) ; true = allows hotkeys to change modes while script is running
enableStalling := ReadBool("Stalling", "EnableStalling", false) ; enables first-gear stall simulation
noInputStallDelayMs := ReadInt("Stalling", "NoInputStallDelayMs", 300) ; time first gear may remain clutch-out with insufficient throttle


resetButton := ReadText("Hotkeys", "ResetButton", "1Joy10")
pauseButton := ReadText("Hotkeys", "PauseButton", "")
reloadButton := ReadText("Hotkeys", "ReloadButton", "^F9")
helpButton := ReadText("Hotkeys", "HelpButton", "F7") ; displays current RealManual modes and hotkeys
toggleTransmissionButton := ReadText("Hotkeys", "ToggleTransmissionButton", "")
toggleSequentialInvertButton := ReadText("Hotkeys", "ToggleSequentialInvertButton", "+F11")
toggleClutchButton := ReadText("Hotkeys", "ToggleClutchButton", "")
toggleNeutralButton := ReadText("Hotkeys", "ToggleNeutralButton", "")
toggleFiveGearModeButton := ReadText("Hotkeys", "ToggleFiveGearModeButton", "^F11") ; configurable 5-speed/6-speed toggle hotkey
toggleShifterHandbrakeButton := ReadText("Hotkeys", "ToggleShifterHandbrakeButton", "F9")
toggleShifterHandbrakeInvertButton := ReadText("Hotkeys", "ToggleShifterHandbrakeInvertButton", "+F9")
IgnitionButton := ReadText("Hotkeys", "IgnitionButton", "1Joy24")
toggleStallingButton := ReadText("Hotkeys", "ToggleStallingButton", "+F10")
stopwatchButton := ReadText("Hotkeys", "StopwatchButton", "F6") ; starts, pauses, or resumes stopwatch
stopwatchLapButton := ReadText("Hotkeys", "StopwatchLapButton", "+F6") ; freezes current lap and starts the next
stopwatchClearButton := ReadText("Hotkeys", "StopwatchClearButton", "^F6") ; clears stopwatch and all visible tooltips


; =============================================================================
; SECTION 5: CONFIG LOADING - NOTIFICATIONS AND TIMING
; =============================================================================

enableToolTips := ReadBool("Notifications", "EnableToolTips", true)
toolTipDurationMs := ReadInt("Notifications", "ToolTipDurationMs", 2000) ; tooltip lifetime in milliseconds
showDetailedStartup := ReadBool("Startup", "ShowDetailedStartup", true)
writeStartupLog := ReadBool("Startup", "WriteStartupLog", true)
keyHoldMs := ReadInt("Timing", "KeyHoldMs", 18) ; milliseconds to hold output keys
scanIntervalMs := ReadInt("Timing", "ScanIntervalMs", 5) ; milliseconds between input scans
throttleBlipMs := ReadInt("Stalling", "ThrottleBlipMs", 120) ; duration of simulated throttle blips
stopwatchRefreshMs := ReadInt("Stopwatch", "RefreshMs", 50) ; milliseconds between stopwatch display updates
stopwatchMaxLines := ReadInt("Stopwatch", "MaxLines", 10) ; maximum stopwatch lines displayed at once


; =============================================================================
; SECTION 6: CONFIG LOADING - AXES, THRESHOLDS, AND OUTPUT KEYS
; =============================================================================

clutchAxis := ReadText("Axes", "ClutchAxis", "1JoyY")
brakeAxis := ReadText("Sequential", "BrakeAxis", "1JoyZ") ; brake axis used for sequential reset heuristic
handbrakeAxis := ReadText("Axes", "HandbrakeAxis", "2JoyR")

clutchThreshold := ReadInt("Thresholds", "ClutchThreshold", 40) ; clutch activates below this value
brakeThreshold := ReadInt("Sequential", "BrakeThreshold", 55) ; brake threshold used for sequential reset heuristic
handbrakeThreshold := ReadInt("Thresholds", "HandbrakeThreshold", 35) ; handbrake activates above this value

neutralKey := ReadText("OutputKeys", "NeutralKey", "n")
forwardKey := ReadText("OutputKeys", "ForwardKey", "Up") ; brief throttle tap used for stall jerk and restart rev
reverseKey := ReadText("OutputKeys", "ReverseKey", "s")
handbrakeKey := ReadText("OutputKeys", "HandbrakeKey", "Space")

shiftUpKey := ReadText("OutputKeys", "ShiftUpKey", "e")
shiftDownKey := ReadText("OutputKeys", "ShiftDownKey", "q")


; =============================================================================
; SECTION 7: CONFIG LOADING - SHIFTER AND SEQUENTIAL SETTINGS
; =============================================================================

gear1Button := ReadText("ShifterButtons", "Gear1Button", "1Joy13") ; physical first gear button, etc.
gear2Button := ReadText("ShifterButtons", "Gear2Button", "1Joy14")
gear3Button := ReadText("ShifterButtons", "Gear3Button", "1Joy15")
gear4Button := ReadText("ShifterButtons", "Gear4Button", "1Joy16")
gear5Button := ReadText("ShifterButtons", "Gear5Button", "1Joy17")
gear6Button := ReadText("ShifterButtons", "Gear6Button", "1Joy18")
reverseButton := ReadText("ShifterButtons", "ReverseButton", "1Joy19") ; physical reverse button

sequentialUpButtonNormal := ReadText("Sequential", "UpshiftButton", gear3Button) ; physical sequential upshift slot
sequentialDownButtonNormal := ReadText("Sequential", "DownshiftButton", gear4Button) ; physical sequential downshift slot

queuedShiftDelayMs := ReadInt("Sequential", "QueuedShiftDelayMs", 35) ; delay between queued sequential shifts on clutch release. Game cannot shift several times at once, must have delay between shifts.
enableBrakeHoldGearReset := ReadBool("Sequential", "EnableBrakeHoldGearReset", true) ; true = sequential mode assumes gear 1 after sustained braking
brakeHoldResetMs := ReadInt("Sequential", "BrakeHoldResetMs", 2000) ; milliseconds brake must be held before virtual gear resets to first
brakeAxisIncreasesWhenPressed := ReadBool("Sequential", "BrakeAxisIncreasesWhenPressed", true)
enablePaddleSync := ReadBool("Sequential", "EnablePaddleSync", true) ; true = paddle shifts update virtual gear state
paddleUpshiftButton := ReadText("Sequential", "PaddleUpshiftButton", "1Joy5") ; physical paddle upshift button
paddleDownshiftButton := ReadText("Sequential", "PaddleDownshiftButton", "1Joy6") ; physical paddle downshift button

enableShifterHandbrake := ReadBool("ShifterHandbrake", "EnableShifterHandbrake", false) ; true = use h-shifter slot as handbrake in sequential mode
invertShifterHandbrake := ReadBool("ShifterHandbrake", "InvertShifterHandbrake", false) ; true = use inverted shifter handbrake slot
shifterHandbrakeButtonNormal := ReadText("ShifterHandbrake", "NormalButton", gear4Button) ; normal shifter handbrake slot, default is fourth gear
shifterHandbrakeButtonInverted := ReadText("ShifterHandbrake", "InvertedButton", gear3Button) ; inverted shifter handbrake slot, default is third gear

stallClutchReleaseThreshold := ReadInt("Stalling", "ClutchReleaseThreshold", 60) ; stall check occurs when clutch reaches this released position
stallThrottleThreshold := ReadInt("Stalling", "ThrottleThreshold", 15) ; minimum throttle percentage required to prevent stalling
restartClutchThreshold := ReadInt("Stalling", "RestartClutchThreshold", 15) ; clutch must be this close to fully pressed to restart
combinedPedalCenter := ReadInt("Stalling", "CombinedPedalCenter", 50) ; resting value of combined gas/brake axis
stallNeutralResendMs := ReadInt("Stalling", "NeutralResendMs", 250) ; interval between forced neutral commands while stalled


; =============================================================================
; SECTION 8: RUNTIME STATE VARIABLES
; =============================================================================

virtualGear := 1 ; script-tracked gear for sequential mode
pendingGear := 1 ; selected h-pattern gear while clutch is pressed
pendingSequentialShiftCount := 0 ; stores net sequential shifts while clutch is held
sequentialShifterArmed := true ; true = sequential shifter can trigger shifts after returning to neutral
shifterHandbrakeArmed := true ; true = shifter handbrake can engage after shifter returns to neutral
lastUpshiftPressed := false ; previous sequential upshift state
lastDownshiftPressed := false ; previous sequential downshift state
lastPaddleUpshiftPressed := false ; previous paddle upshift state for edge detection
lastPaddleDownshiftPressed := false ; previous paddle downshift state for edge detection
lastSentGear := 1 ; last direct gear sent to h-shifter mod
lastClutchPressed := false ; previous clutch state
clutchNeutralSent := false ; prevents neutral spam while clutch is held
reverseHeld := false ; tracks reverse key hold state
handbrakeHeld := false ; tracks handbrake key hold state
brakeHoldStartTime := 0 ; stores when brake hold began for sequential reset heuristic
brakeHoldResetTriggered := false ; prevents repeated gear resets during one brake hold
engineStalled := false ; true while transmission output is locked by stall simulation
stallDetectionArmed := false ; becomes true after clutch is pressed while first gear is selected
lastStallNeutralSendTime := 0 ; controls periodic neutral keepalive while stalled
noInputStallStartTime := 0 ; stores when first gear entered a clutch-out, no-throttle condition
lastNFSFocused := false  ; tracks whether nfs was focused during the previous scan
scriptPaused := false ; tracks whether RealManual input handling is paused
stopwatchStarted := false ; true after stopwatch has been started
stopwatchRunning := false ; true while current stopwatch segment is counting
stopwatchStartTime := 0 ; A_TickCount when current running period began
stopwatchAccumulatedMs := 0 ; elapsed time preserved across pause/resume
stopwatchLaps := [] ; stores completed lap durations
stopwatchToolTipId := 2 ; keeps stopwatch separate from normal RealManual tooltip #1


; =============================================================================
; SECTION 9: INPUT AND OUTPUT MAPS
; =============================================================================

gearButtons := Map() ; creates physical gear button map
gearButtons[gear1Button] := 1 ; maps first gear button, etc.
gearButtons[gear2Button] := 2
gearButtons[gear3Button] := 3
gearButtons[gear4Button] := 4
gearButtons[gear5Button] := 5
gearButtons[gear6Button] := 6

gearKeys := Map() ; creates output gear key map
gearKeys[0] := neutralKey
gearKeys[1] := ReadText("OutputKeys", "Gear1Key", "1") ; output key for first gear, etc.
gearKeys[2] := ReadText("OutputKeys", "Gear2Key", "2")
gearKeys[3] := ReadText("OutputKeys", "Gear3Key", "3")
gearKeys[4] := ReadText("OutputKeys", "Gear4Key", "4")
gearKeys[5] := ReadText("OutputKeys", "Gear5Key", "5")
gearKeys[6] := ReadText("OutputKeys", "Gear6Key", "6")


; =============================================================================
; SECTION 10: LOW-LEVEL OUTPUT HELPERS & SAFETY
; =============================================================================

; =============================================================================
; TapKey(keyName)
; -----------------------------------------------------------------------------
; Sends one controlled key tap.
;
; The key is pressed, held for keyHoldMs milliseconds, then released.
; More reliable than an instant tap because older games and ASI plugins
; can miss synthetic key presses that are too short.
; =============================================================================
TapKey(keyName) {
    global keyHoldMs
    SendEvent "{" keyName " down}" ; presses output key
    Sleep keyHoldMs ; holds output key briefly
    SendEvent "{" keyName " up}" ; releases output key
} ; end tapkey

; =============================================================================
; TapThrottleBlip()
; -----------------------------------------------------------------------------
; Briefly holds the configured forward key for stall and engine-start effects.
;
; =============================================================================
TapThrottleBlip() {
    global forwardKey, throttleBlipMs

    SendEvent "{" forwardKey " down}"
    Sleep throttleBlipMs
    SendEvent "{" forwardKey " up}"
} ; end tapthrottleblip

; =============================================================================
; SendGearToMod(targetGear)
; -----------------------------------------------------------------------------
; Sends a direct gear command to MW2005-HShifter that can register direct gears
;
; Gear model:
;   0  = neutral
;   1-6 = forward gears
;   -1 = reverse state marker used internally in HandleReverse()
; =============================================================================
SendGearToMod(targetGear, force := false) {
    global gearKeys, lastSentGear

    if !force && targetGear = lastSentGear { ; skips duplicate gear only when force is disabled
        return ; prevents repeated key spam
    } ; end duplicate guard

    if !gearKeys.Has(targetGear) { ; checks whether target gear exists in output map
        return ; invalid gear target
    } ; end gear map guard

    TapKey(gearKeys[targetGear]) ; sends mapped gear key
    lastSentGear := targetGear ; stores last successfully requested gear
} ; end sendgeartomod

; =============================================================================
; ReleaseHeldOutputsQuietly()
; -----------------------------------------------------------------------------
; Releases any game output keys that RealManual may currently be holding.
;
; Prevents stuck brake/reverse or handbrake inputs while RealManual is not
; actively controlling the game.
; =============================================================================
ReleaseHeldOutputsQuietly() {
    global reverseHeld, reverseKey, handbrakeHeld, handbrakeKey

    if reverseHeld {
        SendEvent "{" reverseKey " up}"  ; releases reverse output key
        reverseHeld := false
    }

    if handbrakeHeld {
        SendEvent "{" handbrakeKey " up}"
        handbrakeHeld := false
    }
}


; =============================================================================
; SECTION 11: LOW-LEVEL INPUT READERS
; =============================================================================

; =============================================================================
; SafeGetKeyState()
; -----------------------------------------------------------------------------
; Safely reads a keyboard, joystick button, or joystick axis without allowing
; missing devices, invalid input names, or empty values to crash the script.
;
; Returns:
;   Actual input value when successful.
;   Fallback value when input is blank, invalid, unavailable, or unreadable.
; =============================================================================
SafeGetKeyState(inputName, fallback := false) {
    if Trim(inputName) = "" { ; checks for blank input names
        return fallback
    } ; end blank check

    try {
        value := GetKeyState(inputName) ; reads keyboard, joystick button, or joystick axis
        return value = "" ? fallback : value ; replaces empty input values with fallback
    } catch {
        return fallback
    } ; end try/catch
} ; end safegetkeystate

; =============================================================================
; IsClutchPressed()
; -----------------------------------------------------------------------------
; Reads the configured clutch axis and determines whether the clutch is pressed.
;
; For the tested Logitech setup, clutch value decreases when pressed.
;
; Clutch pressed if clutchAxisValue < clutchThreshold
; =============================================================================
IsClutchPressed() {
    global clutchAxis, clutchThreshold
    return SafeGetKeyState(clutchAxis, 100) < clutchThreshold ; missing clutch reads as released
} ; end isclutchpressed

; =============================================================================
; ReadSelectedGear()
; -----------------------------------------------------------------------------
; Reads the physical H-pattern shifter position.
;
; The function checks each configured gear button and returns:
;   1-6 when a gear button is active
;   0 when no gear button is active
;
; The 0 return value represents the shifter's physical neutral/middle position.
; =============================================================================
ReadSelectedGear() {
    global gearButtons

    for buttonName, gearNumber in gearButtons { ; loops through gear mappings
        if SafeGetKeyState(buttonName, false) { ; checks active gear button
            return gearNumber
        } ; end active check
    } ; end loop

    return 0 ; no button means neutral
} ; end readselectedgear

; =============================================================================
; GetSequentialUpshiftButton()
; -----------------------------------------------------------------------------
; Returns the physical input used for sequential upshift.
; =============================================================================
GetSequentialUpshiftButton() {
    global invertSequentialAxis, sequentialUpButtonNormal, sequentialDownButtonNormal
    return invertSequentialAxis ? sequentialDownButtonNormal : sequentialUpButtonNormal ; returns swapped or normal input
} ; end getsequentialupshiftbutton

; =============================================================================
; GetSequentialDownshiftButton()
; =============================================================================
GetSequentialDownshiftButton() {
    global invertSequentialAxis, sequentialUpButtonNormal, sequentialDownButtonNormal
    return invertSequentialAxis ? sequentialUpButtonNormal : sequentialDownButtonNormal
} ; end getsequentialdownshiftbutton

; =============================================================================
; IsBrakePressedForSequentialReset()
; -----------------------------------------------------------------------------
; Determines whether the brake pedal has crossed the configured threshold used
; by the sequential brake-hold reset heuristic.
; =============================================================================
IsBrakePressedForSequentialReset() {
    global brakeAxis, brakeThreshold, brakeAxisIncreasesWhenPressed

    brakeValue := SafeGetKeyState(brakeAxis, brakeAxisIncreasesWhenPressed ? 0 : 100) ; missing brake reads as released

    if brakeAxisIncreasesWhenPressed {
        return brakeValue > brakeThreshold ; brake is pressed when value rises above threshold
    } else {
        return brakeValue < brakeThreshold ; brake is pressed when value falls below threshold
        
    } ; end axis direction branch
} ; end isbrakepressedforsequentialreset

; =============================================================================
; GetShifterHandbrakeButton()
; -----------------------------------------------------------------------------
; Returns the configured shifter slot used as a digital handbrake.
;
; Default:
;   shifterHandbrakeButtonNormal, fourth gear
;
; Inverted:
;   shifterHandbrakeButtonInverted, third gear
;
; Returns:
;   shifter slot used as handbrake
;
; Shifter handbrake inversion is independent from sequential shift inversion.
; =============================================================================
GetShifterHandbrakeButton() { ; returns the 
    global invertShifterHandbrake
    global shifterHandbrakeButtonNormal, shifterHandbrakeButtonInverted

    if invertShifterHandbrake {
        return shifterHandbrakeButtonInverted
    } ; end inverted branch

    return shifterHandbrakeButtonNormal
} ; end getshifterhandbrakebutton

; =============================================================================
; IsShifterHandbrakeModeActive()
; -----------------------------------------------------------------------------
; Determines whether the shifter-handbrake feature is currently active.
;
; This feature is valid only in sequential mode because H-pattern mode needs the
; physical shifter slots for actual gears.
;
; Returns:
;   true  = sequential mode is active and shifter handbrake is enabled
;   false = shifter handbrake ignored
; =============================================================================
IsShifterHandbrakeModeActive() { ; checks whether shifter handbrake mode can run
    global enableShifterHandbrake, transmissionIsSequential ; feature and transmission mode

    return enableShifterHandbrake && transmissionIsSequential ; active only when enabled and sequential mode is active
} ; end isshifterhandbrakemodeactive

; =============================================================================
; IsShifterHandbrakeActive()
; -----------------------------------------------------------------------------
; Reads the configured shifter-handbrake slot.
;
; Neutral position:
;   no handbrake
;
; Configured slot:
;   handbrake held
;
; Returns:
;   true  = configured shifter handbrake slot is selected
;   false = shifter handbrake is inactive or released
; =============================================================================
IsShifterHandbrakeActive() {
    global shifterHandbrakeArmed

    if !IsShifterHandbrakeModeActive() {
        return false ; ignores shifter handbrake outside sequential mode or when disabled
    } ; end mode check

    handbrakeSlotPressed := SafeGetKeyState(GetShifterHandbrakeButton(), false) ; reads configured shifter handbrake
    sequentialSlotPressed := SafeGetKeyState(GetSequentialUpshiftButton(), false) || SafeGetKeyState(GetSequentialDownshiftButton(), false) ; checks whether shifter is still in any sequential slot

    if !sequentialSlotPressed { ; shifter is physically in neutral
        shifterHandbrakeArmed := true ; allows future shifter handbrake engagement
    } ; end neutral-arm branch

    if !shifterHandbrakeArmed { ; blocks stale shifter position after enabling shifter handbrake
        return false ; waits until shifter returns to neutral first
    } ; end arming gate

    return handbrakeSlotPressed ; returns handbrake only after neutral-arm condition is satisfied
} ; end isshifterhandbrakeactive

; =============================================================================
; IsAnalogHandbrakeActive()
; -----------------------------------------------------------------------------
; Reads the optional physical handbrake axis.
;
; Allows physical handbrake and shifter handbrake to coexist.
;
; Returns:
;   true  = analog handbrake is pulled past threshold
;   false = analog handbrake is released, blank, invalid, or disconnected
; =============================================================================
IsAnalogHandbrakeActive() {
    global handbrakeAxis, handbrakeThreshold ; analog handbrake settings

    if Trim(handbrakeAxis) = "" { ; checks whether user left handbrake axis blank
        return false ; no physical handbrake configured
    } ; end blank axis check

    return SafeGetKeyState(handbrakeAxis, 0) > handbrakeThreshold ; missing handbrake reads as released
} ; end isanaloghandbrakeactive

; =============================================================================
; ReadClutchReleasePercent()
; -----------------------------------------------------------------------------
; Returns the current clutch release position:
;   0   = fully pressed
;   100 = fully released
; =============================================================================
ReadClutchReleasePercent() {
    global clutchAxis

    clutchValue := SafeGetKeyState(clutchAxis, 100) ; missing clutch reads as fully released
    return Max(0, Min(100, clutchValue))
} ; end readclutchreleasepercent

; =============================================================================
; ReadThrottlePercentForStall()
; -----------------------------------------------------------------------------
; Estimates throttle percentage from the shared gas/brake axis.
;
; If brake increases the axis value:
;   brake moves above center
;   gas moves below center
;
; If brake decreases the axis value, those directions are reversed.
; =============================================================================
ReadThrottlePercentForStall() {
    global brakeAxis, brakeAxisIncreasesWhenPressed, combinedPedalCenter

    pedalValue := SafeGetKeyState(brakeAxis, combinedPedalCenter)

    if brakeAxisIncreasesWhenPressed {
        gasDistance := combinedPedalCenter - pedalValue
        gasRange := combinedPedalCenter
    } else {
        gasDistance := pedalValue - combinedPedalCenter
        gasRange := 100 - combinedPedalCenter
    } ; end combined axis direction branch

    if gasRange <= 0 {
        return 0
    } ; end invalid range guard

    throttlePercent := gasDistance / gasRange * 100
    return Max(0, Min(100, throttlePercent))
} ; end readthrottlepercentforstall

; =============================================================================
; IsFirstGearSelectedForStall()
; -----------------------------------------------------------------------------
; H-pattern uses the physical first-gear slot.
; Sequential mode uses RealManual's tracked virtual gear.
; =============================================================================
IsFirstGearSelectedForStall() {
    global transmissionIsSequential, virtualGear

    if transmissionIsSequential {
        return virtualGear = 1
    }

    return ReadSelectedGear() = 1
} ; end isfirstgearselectedforstall

; =============================================================================
; IsPhysicalShifterNeutral()
; -----------------------------------------------------------------------------
; Reverse must be checked separately because ReadSelectedGear() returns zero
; when the reverse slot is selected.
; =============================================================================
IsPhysicalShifterNeutral() {
    global reverseButton

    return ReadSelectedGear() = 0
        && !SafeGetKeyState(reverseButton, false)
} ; end isphysicalshifterneutral

; =============================================================================
; IsClutchFullyPressedForRestart()
; -----------------------------------------------------------------------------
IsClutchFullyPressedForRestart() {
    global restartClutchThreshold

    return ReadClutchReleasePercent() <= restartClutchThreshold
} ; end isclutchfullypressedforrestart

; =============================================================================
; IsNFSFocused()
; -----------------------------------------------------------------------------
; Determines whether Need for Speed is currently the active foreground window.
;
; Returns:
;   true  = speed.exe is focused and receiving input
;   false = another application currently has focus
;
; Used to prevent RealManual from reading inputs or sending game commands while
; interacting with another application.
; =============================================================================
IsNFSFocused() {
    return WinActive("ahk_exe speed.exe")
}


; =============================================================================
; SECTION 12: NOTIFICATIONS, VALIDATION, AND LOGGING
; =============================================================================

; =============================================================================
; ShowStartupInfo()
; -----------------------------------------------------------------------------
; Builds and displays the startup notification after config.ini has loaded.
;
; This function summarizes the active transmission mode and major feature flags:
;   H-pattern or sequential
;   clutch required
;   clutch-to-neutral
;   handbrake
;
; Full validation details are written to startup_log.txt.
; =============================================================================
ShowStartupInfo() { ; shows compact startup status after config loads
    global appName, appVersion, transmissionIsSequential, requireClutch, clutchActsAsNeutral, enableHandbrake, enableReverse, writeStartupLog ; startup display settings
    global handbrakeAxis, handbrakeThreshold ; handbrake config

    ; converts transmission modes to readable text
    modeText := transmissionIsSequential ? "Sequential" : "H-Pattern" ;
    clutchText := requireClutch ? "Enabled" : "Disabled"
    clutchNeutralText := clutchActsAsNeutral ? "Enabled" : "Disabled"

    physicalHandbrakeConfigured := enableHandbrake && IsValidPercent(handbrakeThreshold) && IsConfigured(handbrakeAxis) ; checks whether physical handbrake is configured
    handbrakeText := physicalHandbrakeConfigured ? "Enabled" : "Disabled" ; displays physical handbrake status

    title := appName " " appVersion " - Config Loaded" ; builds notification title

    compactMessage := "Mode: " modeText ; startup message
    compactMessage .= "`nClutch Required: " clutchText
    compactMessage .= "`nClutch -> Neutral: " clutchNeutralText
    compactMessage .= "`nHandbrake: " handbrakeText

    validationText := BuildValidationText() ; builds detailed validation report for log file

    if writeStartupLog { ; writes validation report to disk when enabled
        WriteStartupLogFile(title, compactMessage, validationText)
    } ; end startup log write

    TrayTip compactMessage, title, 1 ; shows compact windows notification only
} ; end showstartupinfo

; =============================================================================
; DetectInputHardware()
; -----------------------------------------------------------------------------
; Checks whether a configured input can currently be read from physical
; hardware.
; =============================================================================
DetectInputHardware(inputName) {
    return SafeGetKeyState(inputName, "__MISSING__") != "__MISSING__"
} ; end detectinputhardware

; =============================================================================
; BuildValidationText()
; -----------------------------------------------------------------------------
; Creates the startup validation report.
;
; Configuration Validation
; Hardware Detection
; =============================================================================
BuildValidationText() {
    global configFile, transmissionIsSequential, enableHandbrake, enableReverse ; config and mode settings
    global clutchAxis, handbrakeAxis, clutchThreshold, handbrakeThreshold, neutralKey ; axis and threshold settings
    global gear1Button, gear2Button, gear3Button, gear4Button, gear5Button, gear6Button, reverseButton, resetButton ; button mappings
    global sequentialUpButtonNormal, sequentialDownButtonNormal ; sequential mappings

    warningText := "" ; collects warnings for final summary
    warningCount := 0

    text := "" ; validation output text

    text .= "Configuration Validation:`n`n"

    if FileExist(configFile) { ; checks whether config exists
        text .= "[OK] Config file found`n"
    } else {
        text .= "[WARN] config.ini missing, using fallback values`n"
        warningText .= "config.ini missing, using fallback values`n"
        warningCount++
    } ; end config validation

    if IsValidPercent(clutchThreshold) {
        text .= "[OK] Clutch threshold valid`n"
    } else {
        text .= "[WARN] Clutch threshold should be 0-100`n"
        warningText .= "Clutch threshold should be 0-100`n"
        warningCount++
    } ; end clutch threshold validation

    if IsValidPercent(handbrakeThreshold) {
        text .= "[OK] Handbrake threshold valid`n"
    } else {
        text .= "[WARN] Handbrake threshold should be 0-100`n"
        warningText .= "Handbrake threshold should be 0-100`n"
        warningCount++
    } ; end handbrake threshold validation

    if IsConfigured(clutchAxis) {
        text .= "[OK] Clutch axis configured`n"
    } else {
        text .= "[WARN] Clutch axis missing`n"
        warningText .= "Clutch axis missing`n"
        warningCount++
    } ; end clutch axis validation

    if enableHandbrake { ; only validates handbrake config when handbrake support is enabled
        if IsConfigured(handbrakeAxis) {
            text .= "[OK] Handbrake axis configured`n"
        } else {
            text .= "[WARN] Handbrake axis missing`n"
            warningText .= "Handbrake axis missing`n"
            warningCount++
        }
    } ; end handbrake config validation branch

    ; gear mapping
    if IsConfigured(neutralKey) {
        text .= "[OK] Neutral key configured`n"
    } else {
        text .= "[WARN] Neutral key missing`n"
        warningText .= "Neutral key missing`n"
        warningCount++
    } ; end neutral key validation

    if IsConfigured(gear1Button) {
        text .= "[OK] Gear 1 button configured`n"
    } else {
        text .= "[WARN] Gear 1 button missing`n"
        warningText .= "Gear 1 button missing`n"
        warningCount++
    } ; end gear 1 validation

    if IsConfigured(gear2Button) {
        text .= "[OK] Gear 2 button configured`n"
    } else {
        text .= "[WARN] Gear 2 button missing`n"
        warningText .= "Gear 2 button missing`n"
        warningCount++
    } ; end gear 2 validation

    if IsConfigured(gear3Button) {
        text .= "[OK] Gear 3 button configured`n"
    } else {
        text .= "[WARN] Gear 3 button missing`n"
        warningText .= "Gear 3 button missing`n"
        warningCount++
    } ; end gear 3 validation

    if IsConfigured(gear4Button) {
        text .= "[OK] Gear 4 button configured`n"
    } else {
        text .= "[WARN] Gear 4 button missing`n"
        warningText .= "Gear 4 button missing`n"
        warningCount++
    } ; end gear 4 validation

    if IsConfigured(gear5Button) {
        text .= "[OK] Gear 5 button configured`n"
    } else {
        text .= "[WARN] Gear 5 button missing`n"
        warningText .= "Gear 5 button missing`n"
        warningCount++
    } ; end gear 5 validation

    if IsConfigured(gear6Button) {
        text .= "[OK] Gear 6 button configured`n"
    } else {
        text .= "[WARN] Gear 6 button missing`n"
        warningText .= "Gear 6 button missing`n"
        warningCount++
    } ; end gear 6 validation

    if transmissionIsSequential {
        if IsConfigured(sequentialUpButtonNormal) {
            text .= "[OK] Sequential upshift configured`n"
        } else {
            text .= "[WARN] Sequential upshift missing`n"
            warningText .= "Sequential upshift missing`n"
            warningCount++
        } ; end sequential upshift validation

        if IsConfigured(sequentialDownButtonNormal) {
            text .= "[OK] Sequential downshift configured`n"
        } else {
            text .= "[WARN] Sequential downshift missing`n"
            warningText .= "Sequential downshift missing`n"
            warningCount++
        } ; end sequential downshift validation
    } ; end sequential config validation branch

    if enableReverse {
        if IsConfigured(reverseButton) {
            text .= "[OK] Reverse button configured`n"
        } else {
            text .= "[WARN] Reverse button missing`n"
            warningText .= "Reverse button missing`n"
            warningCount++
        } ; end reverse validation
    } ; end reverse config validation branch

    if IsConfigured(resetButton) {
        text .= "[OK] Reset button configured`n"
    } else {
        text .= "[WARN] Reset button missing`n"
        warningText .= "Reset button missing`n"
        warningCount++
    } ; end reset validation

    text .= "`nHardware Detection:`n`n"

    if DetectInputHardware(clutchAxis) {
        text .= "[OK] Clutch axis detected`n"
    } else {
        text .= "[WARN] Clutch axis not detected: " clutchAxis "`n"
        warningText .= "Clutch axis not detected: " clutchAxis "`n"
        warningCount++
    } ; end clutch hardware detection

    if enableHandbrake && Trim(handbrakeAxis) != "" { ; detects handbrake hardware only when configured and enabled
        if DetectInputHardware(handbrakeAxis) {
            text .= "[OK] Handbrake axis detected`n"
        } else {
            text .= "[WARN] Handbrake axis not detected: " handbrakeAxis "`n"
            warningText .= "Handbrake axis not detected: " handbrakeAxis "`n"
            warningCount++
        } ; end handbrake hardware detection
    } ; end handbrake detection branch

    shifterDetected := false ; assumes shifter hardware is unavailable

    for buttonName in [gear1Button, gear2Button, gear3Button, gear4Button, gear5Button, gear6Button, reverseButton] { ; scans configured shifter buttons
        if DetectInputHardware(buttonName) {
            shifterDetected := true
            break ; stops scanning after first readable shifter input
        } ; end shifter input detected branch
    } ; end shifter detection loop

    if shifterDetected { ; checks whether any shifter input was detected
        text .= "[OK] Shifter detected`n"
    } else {
        text .= "[WARN] Shifter not detected`n"
        warningText .= "Shifter not detected`n"
        warningCount++
    } ; end shifter detection branch

    if transmissionIsSequential {
        seqUpDetected := DetectInputHardware(sequentialUpButtonNormal)
        seqDownDetected := DetectInputHardware(sequentialDownButtonNormal)

        if seqUpDetected {
            text .= "[OK] Sequential upshift detected`n"
        } else {
            text .= "[WARN] Sequential upshift not detected: " sequentialUpButtonNormal "`n"
            warningText .= "Sequential upshift not detected: " sequentialUpButtonNormal "`n"
            warningCount++
        } ; end sequential upshift hardware detection

        if seqDownDetected {
            text .= "[OK] Sequential downshift detected`n"
        } else {
            text .= "[WARN] Sequential downshift not detected: " sequentialDownButtonNormal "`n"
            warningText .= "Sequential downshift not detected: " sequentialDownButtonNormal "`n"
            warningCount++
        } ; end sequential downshift hardware detection
    } ; end sequential hardware detection branch

    if warningCount = 0 {
        text .= "`nReady."
    } else {
        text .= "`n[WARNING]`n"
        text .= warningText
    } ; end warning summary branch

    return text ; returns completed validation report
} ; end buildvalidationtext

; =============================================================================
; WriteStartupLogFile(title, compactMessage, validationText)
; -----------------------------------------------------------------------------
; Writes startup_log.txt beside RealManual.ahk.
;
; Log includes:
;   timestamp
;   app/version title
;   active mode summary
;   validation report
;
; This file is for troubleshooting.
; =============================================================================
WriteStartupLogFile(title, compactMessage, validationText) {
    logFile := A_ScriptDir "\startup_log.txt" ; stores log beside executable

    log := ""
    log .= "==================================================`n"
    log .= "RealManual Startup Log`n"
    log .= "==================================================`n`n"
    log .= "Generated: " A_Now "`n`n" ; timestamp
    log .= title "`n`n"
    log .= compactMessage "`n`n" ; config summary
    log .= "Validation:`n`n"
    log .= validationText "`n`n"
    log .= "==================================================`n"
    log .= "End of Log`n"
    log .= "==================================================`n"

    FileDelete(logFile) ; removes previous log if it exists
    FileAppend(log, logFile, "UTF-8") ; writes new log file
} ; end writestartuplogfile

; =============================================================================
; OpenValidationLog(*)
; -----------------------------------------------------------------------------
; Opens startup_log.txt from the tray menu.
; =============================================================================
OpenValidationLog(*) {
    logFile := A_ScriptDir "\startup_log.txt"

    if FileExist(logFile) {
        Run(logFile) ; opens with associated editor
    } else { ;
        MsgBox("startup_log.txt was not found.")
    } ; end existence check
} ; end openvalidationlog

; =============================================================================
; BoolText(value)
; -----------------------------------------------------------------------------
; Converts a boolean value into user-readable text.
;
; true  -> Enabled
; false -> Disabled
;
; Used by startup messages and live mode status popups.
; =============================================================================
BoolText(value) {
    return value ? "Enabled" : "Disabled"
} ; end booltext

; =============================================================================
; ModeText()
; -----------------------------------------------------------------------------
; Converts the current transmission mode into user-readable text.
; =============================================================================
ModeText() { ; returns current transmission mode as text
    global transmissionIsSequential ; current transmission mode
    return transmissionIsSequential ? "Sequential" : "H-Pattern"
} ; end modetext

; =============================================================================
; ShowLiveModeStatus(changedSetting)
; -----------------------------------------------------------------------------
; Shows a short tooltip after a live hotkey changes a mode setting.
;
; Live hotkeys change the running script state only. They do not write back to
; config.ini. Reloading RealManual restores the saved config file values.
; =============================================================================
ShowLiveModeStatus(changedSetting) {
    global transmissionIsSequential, requireClutch, clutchActsAsNeutral, invertSequentialAxis, maxForwardGear ; live settings
    global enableShifterHandbrake, invertShifterHandbrake ; shifter handbrake settings
    global toggleTransmissionButton, toggleClutchButton, toggleNeutralButton, toggleSequentialInvertButton ; mode hotkeys
    global toggleFiveGearModeButton, toggleShifterHandbrakeButton, toggleShifterHandbrakeInvertButton ; feature hotkeys
    global enableStalling, toggleStallingButton ; stalling
    global helpButton

    message := changedSetting "`n"
    message .= "Transmission: " ModeText() " [" toggleTransmissionButton "]`n"
    message .= "Clutch Required: " BoolText(requireClutch) " [" toggleClutchButton "]`n"
    message .= "Clutch -> Neutral: " BoolText(clutchActsAsNeutral) " [" toggleNeutralButton "]`n"
    message .= "Sequential Invert: " BoolText(invertSequentialAxis) " [" toggleSequentialInvertButton "]`n"
    message .= "Max Gear: " maxForwardGear " [" toggleFiveGearModeButton "]`n"
    message .= "Shifter Handbrake: " BoolText(enableShifterHandbrake) " [" toggleShifterHandbrakeButton "]`n"
    message .= "Shifter HB Invert: " BoolText(invertShifterHandbrake) " [" toggleShifterHandbrakeInvertButton "]"
    message .= "`nStalling: " BoolText(enableStalling) " [" toggleStallingButton "]"
    message .= "`nHelp: [" helpButton "]"

    ShowToolTipMessage(message) ; displays optional tooltip message
} ; end showlivemodestatus

; =============================================================================
; ShowToolTipMessage(message)
; -----------------------------------------------------------------------------
; Displays an optional tooltip based on configuration.
;
; All RealManual tooltip messages should go through this function instead of
; calling ToolTip() directly. This allows disabling informational popups
; globally without changing script behavior.
; =============================================================================
ShowToolTipMessage(message) {
    
    global enableToolTips, toolTipDurationMs ; notification settings

    if !enableToolTips { ; checks whether tooltips are disabled
        return
    } ; end enabled check

    ToolTip message ; show tooltip
    SetTimer () => ToolTip(), -toolTipDurationMs ; clear tooltip after configured duration
} ; end showtooltipmessage

; =============================================================================
; IsValidPercent(value)
; -----------------------------------------------------------------------------
; Validates a joystick threshold value.
;
; Valid if 0 <= value <= 100
; =============================================================================
IsValidPercent(value) {
    return value >= 0 && value <= 100
} ; end isvalidpercent

; =============================================================================
; IsConfigured(value)
; -----------------------------------------------------------------------------
; Checks whether a config field contains usable text.
;
; This catches blank mappings such as:
;   Gear1Button=
;
; It does not prove the mapping is correct; it only proves the setting exists.
; =============================================================================
IsConfigured(value) {
    return Trim(value) != "" ; returns true when value contains text
} ; end isconfigured

; =============================================================================
; SECTION 13: STOPWATCH
; =============================================================================

; =============================================================================
; FormatStopwatchTime(totalMs)
; -----------------------------------------------------------------------------
; Converts an elapsed millisecond count into stopwatch-style text.
;
; Under one hour:
;   MM:SS.mmm
;
; One hour or longer:
;   HH:MM:SS.mmm
; =============================================================================
FormatStopwatchTime(totalMs) {
    totalMs := Max(0, Floor(totalMs))

    hours := Floor(totalMs / 3600000)
    remainingMs := Mod(totalMs, 3600000)

    minutes := Floor(remainingMs / 60000)
    remainingMs := Mod(remainingMs, 60000)

    seconds := Floor(remainingMs / 1000)
    milliseconds := Mod(remainingMs, 1000)

    if hours > 0 {
        return Format("{:02}:{:02}:{:02}.{:03}", hours, minutes, seconds, milliseconds)
    }

    return Format("{:02}:{:02}.{:03}", minutes, seconds, milliseconds)
} ; end formatstopwatchtime

; =============================================================================
; GetStopwatchElapsedMs()
; -----------------------------------------------------------------------------
; Returns the elapsed time of the current stopwatch segment.
;
; While running, elapsed time includes time since stopwatchStartTime.
; While paused, only the previously accumulated time is returned.
; =============================================================================
GetStopwatchElapsedMs() {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime, stopwatchAccumulatedMs

    if !stopwatchStarted {
        return 0
    }

    elapsedMs := stopwatchAccumulatedMs

    if stopwatchRunning {
        elapsedMs += A_TickCount - stopwatchStartTime
    }

    return elapsedMs
} ; end getstopwatchelapsedms

; =============================================================================
; UpdateStopwatchDisplay()
; -----------------------------------------------------------------------------
; Builds the persistent stopwatch tooltip.
;
; Completed laps remain frozen above the current timer.
; The current timer shows whether it is running or paused.
; =============================================================================
UpdateStopwatchDisplay() {
    global enableToolTips
    global stopwatchStarted, stopwatchRunning, stopwatchLaps
    global stopwatchToolTipId

    if !enableToolTips {
        ToolTip(,,, stopwatchToolTipId)
        return
    }

    if !stopwatchStarted {
        ToolTip(,,, stopwatchToolTipId)
        return
    }

    message := "Stopwatch"

    for lapNumber, lapTime in stopwatchLaps {
        message .= "`n" lapNumber ". " FormatStopwatchTime(lapTime)
    }

    currentNumber := stopwatchLaps.Length + 1
    currentTime := GetStopwatchElapsedMs()

    if stopwatchRunning {
        message .= "`n" currentNumber ". " FormatStopwatchTime(currentTime) "  [RUNNING]"
    } else {
        message .= "`n" currentNumber ". " FormatStopwatchTime(currentTime) "  [PAUSED]"
    }

    ToolTip(message, 20, 20, stopwatchToolTipId)
} ; end updatestopwatchdisplay

; =============================================================================
; ToggleStopwatch(*)
; -----------------------------------------------------------------------------
; Controls the current stopwatch segment.
;
; Not started:
;   starts the stopwatch
;
; Running:
;   pauses at the current elapsed time
;
; Paused:
;   resumes from the preserved elapsed time
; =============================================================================
ToggleStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchRefreshMs

    if !stopwatchStarted {
        stopwatchStarted := true
        stopwatchRunning := true
        stopwatchStartTime := A_TickCount
        stopwatchAccumulatedMs := 0

        UpdateStopwatchDisplay()
        SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))
        return
    } ; end initial start

    if stopwatchRunning {
        stopwatchAccumulatedMs += A_TickCount - stopwatchStartTime
        stopwatchRunning := false

        SetTimer(UpdateStopwatchDisplay, 0) ; timer no longer needs continuous updates while paused
        UpdateStopwatchDisplay() ; preserves paused value on screen
        return
    } ; end pause

    stopwatchRunning := true
    stopwatchStartTime := A_TickCount

    UpdateStopwatchDisplay()
    SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))
} ; end togglestopwatch

; =============================================================================
; LapStopwatch(*)
; -----------------------------------------------------------------------------
; Freezes the current stopwatch segment and starts a new segment from zero.
;
; Completed laps remain visible above the active timer.
; The total number of displayed lines is limited by Stopwatch.MaxLines.
; =============================================================================
LapStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchLaps, stopwatchMaxLines, stopwatchRefreshMs

    if !stopwatchStarted {
        return
    } ; end not-started guard

    maxLines := Max(1, stopwatchMaxLines)

    ; One line must remain available for the currently active timer.
    if stopwatchLaps.Length >= maxLines - 1 {
        ShowToolTipMessage("stopwatch lap limit reached")
        return
    } ; end lap limit

    currentTime := GetStopwatchElapsedMs()

    stopwatchLaps.Push(currentTime) ; freezes completed lap

    ; Every new lap begins immediately from zero.
    stopwatchAccumulatedMs := 0
    stopwatchStartTime := A_TickCount
    stopwatchRunning := true

    UpdateStopwatchDisplay()
    SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))
} ; end lapstopwatch

; =============================================================================
; ClearStopwatch(*)
; -----------------------------------------------------------------------------
; Completely resets stopwatch state and removes the stopwatch display.
; =============================================================================
ClearStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchLaps, stopwatchToolTipId

    SetTimer(UpdateStopwatchDisplay, 0)

    stopwatchStarted := false
    stopwatchRunning := false
    stopwatchStartTime := 0
    stopwatchAccumulatedMs := 0
    stopwatchLaps := []

    ToolTip(,,, stopwatchToolTipId) ; clears only the stopwatch tooltip
} ; end clearstopwatch


; =============================================================================
; SECTION 14: DYNAMIC HOTKEYS AND LIVE MODE TOGGLES
; =============================================================================

; =============================================================================
; RegisterDynamicHotkeys()
; -----------------------------------------------------------------------------
; Registers configurable hotkeys loaded from config.ini.
;
; These hotkeys are scoped to speed.exe only, they will not trigger while 
; outside of the game.
;
; Blank config fields are skipped safely.
; =============================================================================
RegisterDynamicHotkeys() {
    global helpButton, resetButton, pauseButton, reloadButton ; utility hotkeys
    global toggleTransmissionButton, toggleSequentialInvertButton, toggleFiveGearModeButton ; transmission hotkeys
    global toggleClutchButton, toggleNeutralButton ; clutch hotkeys
    global toggleShifterHandbrakeButton, toggleShifterHandbrakeInvertButton ; shifter handbrake hotkeys
    global IgnitionButton, toggleStallingButton ; stalling
    global stopwatchButton, stopwatchLapButton, stopwatchClearButton ; stopwatch hotkeys

    HotIfWinActive("ahk_exe speed.exe") ; nfs focused

    if Trim(helpButton) != "" {
        Hotkey(helpButton, ShowHotkeyHelp, "On")
    } ; end help

    if Trim(resetButton) != "" { ; registers reset hotkey if configured
        Hotkey(resetButton, (*) => ResetInputs(), "On") ; binds configured key to reset function
    } ; end reset

    if Trim(pauseButton) != "" {
        Hotkey(pauseButton, (*) => ToggleScriptPause(), "On")
    } ; end pause

    if Trim(reloadButton) != "" {
        Hotkey(reloadButton, (*) => Reload(), "On")
    } ; end reload

    if Trim(toggleTransmissionButton) != "" {
        Hotkey(toggleTransmissionButton, (*) => ToggleTransmissionMode(), "On")
    } ; end transmission

    if Trim(toggleSequentialInvertButton) != "" {
        Hotkey(toggleSequentialInvertButton, (*) => ToggleSequentialInvert(), "On")
    } ; end sequential invert

    if Trim(toggleClutchButton) != "" {
        Hotkey(toggleClutchButton, (*) => ToggleClutchRequired(), "On")
    } ; end clutch

    if Trim(toggleNeutralButton) != "" {
        Hotkey(toggleNeutralButton, (*) => ToggleClutchNeutral(), "On")
    } ; end neutral

    if Trim(toggleShifterHandbrakeButton) != "" {
        Hotkey(toggleShifterHandbrakeButton, (*) => ToggleShifterHandbrake(), "On")
    } ; end shifter handbrake

    if Trim(toggleShifterHandbrakeInvertButton) != "" {
        Hotkey(toggleShifterHandbrakeInvertButton, (*) => ToggleShifterHandbrakeInvert(), "On")
    } ; end shifter handbrake invert

    if Trim(toggleFiveGearModeButton) != "" {
        Hotkey(toggleFiveGearModeButton, (*) => ToggleFiveGearMode(), "On")
    } ; end 5-speed

    if Trim(IgnitionButton) != "" {
        Hotkey(IgnitionButton, HandleIgnitionButton, "On")
    } ; end ignition hotkey

    if Trim(toggleStallingButton) != "" {
        Hotkey(toggleStallingButton, ToggleStalling, "On")
    } ; end stalling toggle

    if Trim(stopwatchButton) != "" {
        Hotkey(stopwatchButton, ToggleStopwatch, "On")
    } ; end stopwatch start/pause/resume

    if Trim(stopwatchLapButton) != "" {
        Hotkey(stopwatchLapButton, LapStopwatch, "On")
    } ; end stopwatch lap

    if Trim(stopwatchClearButton) != "" {
        Hotkey(stopwatchClearButton, ClearStopwatch, "On")
    } ; end stopwatch clear

    HotIfWinActive() ; clears dynamic hotkey context so later hotkeys are not accidentally scoped
} ; end registerdynamichotkeys

; =============================================================================
; ShowHotkeyHelp(*)
; -----------------------------------------------------------------------------
; Displays the same live-mode status window used after mode changes without
; changing any RealManual setting.
; =============================================================================
ShowHotkeyHelp(*) {
    ShowLiveModeStatus("RealManual Hotkeys")
} ; end showhotkeyhelp

; =============================================================================
; ToggleTransmissionMode()
; -----------------------------------------------------------------------------
; Switches RealManual between H-pattern mode and sequential mode.
;
; When switching into sequential mode, the function reads the current physical
; H-pattern shifter position and converts it into RealManual's sequential
; virtualGear estimate.
;
; The function also clears edge-detection states so the script does not interpret
; an already-held shifter position as a fresh input after switching modes.
; =============================================================================
ToggleTransmissionMode() {
    global enableLiveHotkeys, transmissionIsSequential, virtualGear ; live mode state and sequential gear estimate
    global lastUpshiftPressed, lastDownshiftPressed, lastClutchPressed, clutchNeutralSent, sequentialShifterArmed ; edge states
    global enableShifterHandbrake, shifterHandbrakeArmed, handbrakeHeld, handbrakeKey ; shifter handbrake state

    if !enableLiveHotkeys { ; blocks live toggle if disabled
        return
    } ; end enabled check

    transmissionIsSequential := !transmissionIsSequential ; flips transmission mode

    if transmissionIsSequential { ; mode changed to sequential
        selectedGear := ReadSelectedGear() ; reads current h-pattern shifter position

        if selectedGear > 0 { ; checks whether a physical gear is selected
            virtualGear := selectedGear ; initializes sequential estimate from selected h-pattern gear
        } else { ; physical shifter is neutral
            virtualGear := 0 ; initializes sequential estimate as neutral
        } ; end selected gear conversion

        sequentialShifterArmed := false ; requires shifter to return to neutral before first sequential shift
    } else { ; mode was changed into h-pattern
        sequentialShifterArmed := true ; re-arms sequential shifter state for the next sequential session
        enableShifterHandbrake := false ; disables shifter handbrake because h-pattern needs the shifter for gears
        shifterHandbrakeArmed := true ; resets shifter handbrake arming state

        if handbrakeHeld { ; releases handbrake if it was held by shifter handbrake
            SendEvent "{" handbrakeKey " up}"
            handbrakeHeld := false ; clears handbrake held state
        } ; end handbrake release
    } ; end sequential initialization

    lastUpshiftPressed := false ; clears sequential upshift edge state
    lastDownshiftPressed := false ; clears sequential downshift edge state
    lastClutchPressed := false ; clears clutch transition state
    clutchNeutralSent := false ; clears clutch-neutral state

    ShowLiveModeStatus("Changed: Transmission Mode") ; shows updated mode status
} ; end toggletransmissionmode

; =============================================================================
; ToggleClutchRequired()
; -----------------------------------------------------------------------------
; Enables or disables the clutch gate.
;
; Enabled:
;   gear changes require clutch input
;
; Disabled:
;   they do not
;
; The function clears clutch transition state to prevent a stale clutch press from
; triggering an unintended gear engagement after toggling.
; =============================================================================
ToggleClutchRequired() {
    global enableLiveHotkeys, requireClutch, lastClutchPressed, clutchNeutralSent ; clutch mode state

    if !enableLiveHotkeys {
        return
    } ; end enabled check

    requireClutch := !requireClutch ; flips clutch requirement
    lastClutchPressed := false ; clears clutch transition state
    clutchNeutralSent := false ; clears clutch-neutral state
    ShowLiveModeStatus("Changed: Clutch Required")
} ; end toggleclutchrequired

; =============================================================================
; ToggleClutchNeutral()
; -----------------------------------------------------------------------------
; Enables or disables clutch-to-neutral behavior.
;
; Enabled:
;   clutch press sends neutral
;   clutch release re-engages the selected or tracked gear
;
; Disabled:
;   clutch can still be required, but it does not force neutral.
; =============================================================================
ToggleClutchNeutral() {
    global enableLiveHotkeys, clutchActsAsNeutral, lastClutchPressed, clutchNeutralSent ; clutch-neutral state

    if !enableLiveHotkeys {
        return
    } ; end enabled check

    clutchActsAsNeutral := !clutchActsAsNeutral ; flip clutch-neutral behavior
    lastClutchPressed := false
    clutchNeutralSent := false
    ShowLiveModeStatus("Changed: Clutch -> Neutral")
} ; end toggleclutchneutral

; =============================================================================
; ToggleFiveGearMode()
; -----------------------------------------------------------------------------
; Toggles the current car gearbox limit between 5-speed and 6-speed mode.
;
; Affects sequential virtualGear clamping and direct gear re-engagement when
; clutch-to-neutral is enabled.
; =============================================================================
ToggleFiveGearMode(*) {
    global maxForwardGear, virtualGear ; gearbox limit and tracked gear

    maxForwardGear := maxForwardGear = 5 ? 6 : 5 ; toggles maximum forward gear

    if virtualGear > maxForwardGear { ; checks whether tracked gear exceeds new gearbox limit
        virtualGear := maxForwardGear ; clamps tracked gear to current gearbox limit
    } ; end virtual gear clamp

    ShowLiveModeStatus("Changed: Gearbox Limit")
} ; end togglefivegearmode

; =============================================================================
; ToggleSequentialInvert()
; -----------------------------------------------------------------------------
; Swaps the sequential upshift/downshift slots.
;
; Convenience setting to change mapping without quitting the game
; =============================================================================
ToggleSequentialInvert() {
    global enableLiveHotkeys, invertSequentialAxis, lastUpshiftPressed, lastDownshiftPressed ; sequential inversion state

    if !enableLiveHotkeys {
        return
    } ; end enabled check

    invertSequentialAxis := !invertSequentialAxis
    lastUpshiftPressed := false ; clears upshift edge state
    lastDownshiftPressed := false ; clears downshift edge state
    ShowLiveModeStatus("Changed: Sequential Invert")
} ; end togglesequentialinvert

; =============================================================================
; ToggleShifterHandbrake()
; -----------------------------------------------------------------------------
; Toggles shifter-handbrake mode.
;
; If enabled while RealManual is not already in sequential mode, this
; automatically switches RealManual to sequential mode because shifter handbrake
; is only valid there.
; =============================================================================
ToggleShifterHandbrake(*) {
    global enableShifterHandbrake, transmissionIsSequential ; feature and transmission mode
    global shifterHandbrakeArmed, handbrakeHeld, handbrakeKey ; arming and handbrake output state
    global lastUpshiftPressed, lastDownshiftPressed, clutchNeutralSent, lastClutchPressed ; sequential state

    enableShifterHandbrake := !enableShifterHandbrake

    if enableShifterHandbrake {
        if !transmissionIsSequential {
            transmissionIsSequential := true
        } ; end sequential force check

        shifterHandbrakeArmed := false ; require shifter to return to neutral before handbrake can engage
        lastUpshiftPressed := false ; clears sequential upshift edge state
        lastDownshiftPressed := false ; clears sequential downshift edge state
        clutchNeutralSent := false ; clears clutch-neutral state
        lastClutchPressed := false ; clears clutch transition state
    } else { ; shifter handbrake was disabled
        shifterHandbrakeArmed := true ; reset arming state

        if handbrakeHeld { ; releases handbrake if currently held by shifter handbrake
            SendEvent "{" handbrakeKey " up}"
            handbrakeHeld := false
        } ; end handbrake release
    } ; end feature toggle branch

    ShowLiveModeStatus("Changed: Shifter Handbrake")
} ; end toggleshifterhandbrake

; =============================================================================
; ToggleShifterHandbrakeInvert()
; -----------------------------------------------------------------------------
; Toggles which shifter slot acts as the handbrake.
;
; Independent from sequential shift inversion.
; =============================================================================
ToggleShifterHandbrakeInvert(*) {
    global invertShifterHandbrake ; handbrake inversion state

    invertShifterHandbrake := !invertShifterHandbrake

    ShowLiveModeStatus("Changed: Shifter Handbrake Invert")
} ; end toggleshifterhandbrakeinvert

; =============================================================================
; ToggleStalling()
; -----------------------------------------------------------------------------
; Disabling the feature while stalled acts as an emergency unlock. 
; Does not perform the ignition animation.
; -----------------------------------------------------------------------------
ToggleStalling(*) {
    global enableLiveHotkeys, enableStalling
    global engineStalled, stallDetectionArmed
    global lastStallNeutralSendTime, noInputStallStartTime

    if !enableLiveHotkeys {
        return
    } ; end live toggle gate

    enableStalling := !enableStalling
    stallDetectionArmed := false
    noInputStallStartTime := 0

    if !enableStalling && engineStalled {
        engineStalled := false
        lastStallNeutralSendTime := 0
        HandleHandbrake() ; removes forced stall handbrake
    } ; end stalled disable branch

    ShowLiveModeStatus("Changed: Stalling")
} ; end togglestalling

; =============================================================================
; ToggleScriptPause(*)
; -----------------------------------------------------------------------------
; Pauses or resumes RealManual input handling.
;
; When paused:
;   MainLoop returns immediately
;   held reverse/handbrake keys are released for safety
;   tray menu text changes to Resume
;
; Does not suspend the AutoHotkey process; only disables RealManual's
; controller-to-keyboard logic.
; =============================================================================
ToggleScriptPause(*) {
    global scriptPaused, reverseHeld, reverseKey, handbrakeHeld, handbrakeKey ; pause and held-key state

    scriptPaused := !scriptPaused

    if scriptPaused {
        if reverseHeld { ; releases reverse if currently held
            SendEvent "{" reverseKey " up}"
            reverseHeld := false
        } ; end reverse release

        if handbrakeHeld { ; releases handbrake if currently held
            SendEvent "{" handbrakeKey " up}"
            handbrakeHeld := false
        } ; end handbrake release

        A_TrayMenu.Rename("Pause RealManual", "Resume RealManual")
        ShowToolTipMessage("RealManual paused")
    } else { ; script resumed
        A_TrayMenu.Rename("Resume RealManual", "Pause RealManual")
        ShowToolTipMessage("RealManual running")
    } ; end pause state branch
} ; end togglescriptpause


; =============================================================================
; SECTION 15: AUXILIARY INPUT HANDLERS
; =============================================================================

; =============================================================================
; HandleHandbrake()
; -----------------------------------------------------------------------------
; Converts an analog USB handbrake axis into a digital game handbrake key.
;
; Axis model:
;   released = low value
;   pulled   = high value
;
; Holds handbrakeKey if handbrakeAxisValue > handbrakeThreshold
; =============================================================================
HandleHandbrake() {
    global enableHandbrake, engineStalled
    global handbrakeKey, handbrakeHeld

    handbrakeRequested := engineStalled ; a stalled engine always requests the handbrake

    if enableHandbrake {
        handbrakeRequested := handbrakeRequested
            || IsAnalogHandbrakeActive()
            || IsShifterHandbrakeActive()
    } ; end normal handbrake source branch

    if handbrakeRequested {
        if !handbrakeHeld {
            SendEvent "{" handbrakeKey " down}"
            handbrakeHeld := true
        } ; end press guard
    } else {
        if handbrakeHeld {
            SendEvent "{" handbrakeKey " up}"
            handbrakeHeld := false
        } ; end release guard
    } ; end requested state branch
} ; end handlehandbrake

; =============================================================================
; HandleReverse()
; -----------------------------------------------------------------------------
; Handles the physical reverse gear slot for H-pattern mode only.
;
;   Reverse gear + brake pedal past threshold = hold brake/reverse key
;
; For full sim purposes. You can always just brake to reverse. Gas/Brake shared
; pedal axis, so can't use Gas to reverse. 
; =============================================================================
HandleReverse() {
    global enableReverse, reverseButton, reverseKey, reverseHeld, lastSentGear ; reverse state
    global transmissionIsSequential ; transmission mode

    if transmissionIsSequential { ; sequential mode does not use physical reverse slot
        return false
    } ; end sequential bypass

    if !enableReverse {
        if reverseHeld {
            SendEvent "{" reverseKey " up}"
            reverseHeld := false
        } ; end release guard

        return false ; reverse inactive
    } ; end feature toggle check

    if SafeGetKeyState(reverseButton, false) { ; checks whether physical reverse slot is selected
        lastSentGear := -1 ; marks reverse slot state without sending neutral

        if IsBrakePressedForSequentialReset() { ; only activates brake/reverse key when brake pedal is pressed
            if !reverseHeld {
                SendEvent "{" reverseKey " down}"
                reverseHeld := true
            } ; end press guard
        } else { ; reverse slot selected but brake pedal not pressed
            if reverseHeld {
                SendEvent "{" reverseKey " up}"
                reverseHeld := false
            } ; end release guard
        } ; end brake gate branch

        return true ; blocks h-pattern logic so reverse slot does not get treated as neutral
    } ; end reverse slot branch

    if reverseHeld { ; releases when leaving reverse slot
        SendEvent "{" reverseKey " up}"
        reverseHeld := false
    } ; end release guard

    return false ; reverse inactive
} ; end handlereverse

; =============================================================================
; SECTION 16: STALL / ENIGNE OFF/ON SIMULATION LOGIC
; =============================================================================

; =============================================================================
; EnterEngineOffState(playStallJerk, statusMessage)
; -----------------------------------------------------------------------------
; Places RealManual into its simulated engine-off state.
;
; Both an automatic stall and a manual ignition shutoff use the same state:
;   transmission output locked
;   neutral forced
;   handbrake forced
;   tracked gear state reset to neutral
;
; playStallJerk:
;   true  = briefly taps throttle before neutral to simulate a stall jerk
;   false = shuts the engine off cleanly
; =============================================================================
EnterEngineOffState(playStallJerk, statusMessage) {
    global engineStalled, stallDetectionArmed
    global virtualGear, pendingGear, pendingSequentialShiftCount
    global lastClutchPressed, clutchNeutralSent
    global lastUpshiftPressed, lastDownshiftPressed
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global sequentialShifterArmed
    global brakeHoldStartTime, brakeHoldResetTriggered
    global lastStallNeutralSendTime, noInputStallStartTime

    if engineStalled {
        return
    } ; end duplicate engine-off guard

    engineStalled := true
    stallDetectionArmed := false
    noInputStallStartTime := 0

    if playStallJerk {
        TapThrottleBlip() ; brief jerk only when the engine actually stalls
    } ; end stall jerk

    SendGearToMod(0, true) ; forces neutral

    virtualGear := 0
    pendingGear := 0
    pendingSequentialShiftCount := 0

    lastClutchPressed := false
    clutchNeutralSent := false
    lastUpshiftPressed := false
    lastDownshiftPressed := false
    lastPaddleUpshiftPressed := false
    lastPaddleDownshiftPressed := false

    sequentialShifterArmed := false
    brakeHoldStartTime := 0
    brakeHoldResetTriggered := false

    lastStallNeutralSendTime := A_TickCount

    HandleHandbrake()
    ShowToolTipMessage(statusMessage)
} ; end enterengineoffstate

; =============================================================================
; StallEngine()
; -----------------------------------------------------------------------------
; Enters the engine-off state after a simulated first-gear stall.
; =============================================================================
StallEngine() {
    EnterEngineOffState(true, "stalled")
} ; end stallengine

; =============================================================================
; ShutOffEngine()
; -----------------------------------------------------------------------------
; Manually enters the same engine-off state as a stall, but without producing
; the simulated forward jerk.
; =============================================================================
ShutOffEngine() {
    EnterEngineOffState(false, "engine shut off")
} ; end shutoffengine

; =============================================================================
; HandleStallDetection(clutchPressed)
; -----------------------------------------------------------------------------
; Detects two first-gear stall conditions:
;
;   1. clutch-release stall:
;      clutch is released past the configured point without sufficient throttle
;
;   2. sustained no-input stall:
;      first gear remains selected with the clutch released and insufficient
;      throttle, even when no clutch-release cycle armed the original check
;
; Stall behavior depends on the active clutch configuration:
;
; RequireClutch = false, ClutchActsAsNeutral = false
;   - clutch input is ignored completely
;   - first gear stalls only after sustained insufficient throttle
;
; RequireClutch = true, ClutchActsAsNeutral = false
;   - pressing the clutch prevents the first-gear stall
;   - once the clutch is sufficiently released, sustained insufficient throttle
;     can stall the engine
;   - clutch required to restart the engine
;
; RequireClutch = false, ClutchActsAsNeutral = true
;   - releasing the clutch past the configured point without enough throttle
;     causes an immediate stall
;   - sustained first-gear insufficient-throttle stalling also remains active
;   - clutch not required to restart the engine
;
; RequireClutch = true, ClutchActsAsNeutral = true
;   - full clutch simulation behavior
;   - clutch press prevents stalling
;   - improper clutch release can stall the engine
;   - sustained first-gear insufficient-throttle stalling remains active
;   - clutch required to restart the engine
; =============================================================================
HandleStallDetection(clutchPressed) {
    global enableStalling, engineStalled, stallDetectionArmed
    global requireClutch, clutchActsAsNeutral
    global stallClutchReleaseThreshold, stallThrottleThreshold
    global noInputStallDelayMs, noInputStallStartTime

    if !enableStalling {
        stallDetectionArmed := false
        noInputStallStartTime := 0
        return
    } ; end feature gate

    if engineStalled {
        stallDetectionArmed := false
        noInputStallStartTime := 0
        return
    } ; end stalled guard

    if !IsFirstGearSelectedForStall() {
        stallDetectionArmed := false
        noInputStallStartTime := 0
        return
    } ; end first-gear gate

    ; Any enabled clutch feature means the clutch can prevent the normal
    ; first-gear insufficient-throttle stall while it is pressed.
    clutchParticipatesInStallLogic := requireClutch || clutchActsAsNeutral

    ; Only clutch-to-neutral enables the immediate clutch-release stall.
    clutchReleaseStallEnabled := clutchActsAsNeutral

    if clutchParticipatesInStallLogic {
        if clutchPressed {
            ; Only arm an immediate clutch-release stall when clutch-to-neutral
            ; behavior is enabled.
            stallDetectionArmed := clutchReleaseStallEnabled

            ; A pressed clutch disconnects the transmission, so the normal
            ; first-gear no-throttle stall timer cannot continue.
            noInputStallStartTime := 0
            return
        } ; end clutch-held branch

        clutchReleasePercent := ReadClutchReleasePercent()

        if clutchReleasePercent < stallClutchReleaseThreshold {
            ; Clutch is still sufficiently depressed to prevent the engine from
            ; being treated as fully coupled to first gear.
            noInputStallStartTime := 0
            return
        } ; end clutch release threshold guard
    } else {
        ; Neither clutch feature is enabled, so the clutch axis has no effect on
        ; stall simulation.
        stallDetectionArmed := false
    } ; end clutch participation branch

    throttlePercent := ReadThrottlePercentForStall()

    if clutchReleaseStallEnabled && stallDetectionArmed {
        stallDetectionArmed := false
        noInputStallStartTime := 0

        if throttlePercent < stallThrottleThreshold {
            StallEngine()
        } ; end insufficient throttle branch

        return
    } ; end clutch-release evaluation

    ; Sufficient throttle cancels the sustained first-gear stall timer.
    if throttlePercent >= stallThrottleThreshold {
        noInputStallStartTime := 0
        return
    } ; end throttle guard

    ; First gear is selected, the clutch is no longer protecting the engine,
    ; and throttle is insufficient. Start or continue the sustained stall timer.
    if noInputStallStartTime = 0 {
        noInputStallStartTime := A_TickCount
    } ; end timer start

    requiredDelayMs := Max(0, noInputStallDelayMs)

    if A_TickCount - noInputStallStartTime >= requiredDelayMs {
        noInputStallStartTime := 0
        StallEngine()
    } ; end sustained no-input stall
} ; end handlestalldetection

; =============================================================================
; MaintainStalledState()
; -----------------------------------------------------------------------------
; Holds the handbrake and periodically reasserts neutral while stalled.
;
; Periodic neutral prevents the game from leaving neutral after its built-in
; brake-to-reverse and automatic first-gear behavior.
;
; Returns:
;   true  = engine is stalled/off and normal transmission handling must stop
;   false = engine is running
; =============================================================================
MaintainStalledState() {
    global engineStalled
    global stallNeutralResendMs, lastStallNeutralSendTime

    if !engineStalled {
        return false
    } ; end stalled-state check

    HandleHandbrake() ; preserves forced handbrake while stalled

    resendInterval := Max(50, stallNeutralResendMs)

    if A_TickCount - lastStallNeutralSendTime >= resendInterval {
        SendGearToMod(0, true) ; force is required because lastSentGear is already zero
        lastStallNeutralSendTime := A_TickCount
    } ; end neutral keepalive branch

    return true
} ; end maintainstalledstate

; =============================================================================
; TryRestartEngine()
; -----------------------------------------------------------------------------
; Restart requires:
;   engine currently stalled
;   physical shifter in neutral
;   clutch nearly fully pressed (if RequireClutch = true)
; =============================================================================
TryRestartEngine(*) {
    global enableStalling, engineStalled, requireClutch
    global virtualGear, pendingGear, pendingSequentialShiftCount
    global stallDetectionArmed, lastStallNeutralSendTime, noInputStallStartTime
    global lastClutchPressed, clutchNeutralSent
    global lastUpshiftPressed, lastDownshiftPressed
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global sequentialShifterArmed
    global brakeHoldStartTime, brakeHoldResetTriggered

    if !enableStalling || !engineStalled {
        return
    } ; end restart-state guard

    if !IsPhysicalShifterNeutral() {
        ShowToolTipMessage("restart blocked: shifter not neutral")
        return
    } ; end neutral requirement

    if requireClutch && !IsClutchFullyPressedForRestart() {
        ShowToolTipMessage("restart blocked: press clutch fully")
        return
    } ; end optional clutch requirement

    SendGearToMod(0, true) ; ensures the game is in neutral before restart
    TapThrottleBlip() ; simulated engine-start rev

    engineStalled := false
    stallDetectionArmed := false
    lastStallNeutralSendTime := 0
    noInputStallStartTime := 0

    virtualGear := 0
    pendingGear := 0
    pendingSequentialShiftCount := 0

    lastClutchPressed := false
    clutchNeutralSent := false
    lastUpshiftPressed := false
    lastDownshiftPressed := false
    lastPaddleUpshiftPressed := false
    lastPaddleDownshiftPressed := false

    sequentialShifterArmed := true ; physical neutral was explicitly verified
    brakeHoldStartTime := 0
    brakeHoldResetTriggered := false

    HandleHandbrake() ; removes the forced engine-off handbrake request
    ShowToolTipMessage("engine started")
} ; end tryrestartengine

; =============================================================================
; HandleIgnitionButton(*)
; -----------------------------------------------------------------------------
; Acts as a simulated ignition switch.
; =============================================================================
HandleIgnitionButton(*) {
    global enableStalling, engineStalled

    if !enableStalling {
        return
    } ; end feature gate

    if engineStalled {
        TryRestartEngine()
    } else {
        ShutOffEngine()
    } ; end ignition state branch
} ; end handleignitionbutton

; =============================================================================
; SECTION 17: H-PATTERN TRANSMISSION LOGIC
; =============================================================================

; =============================================================================
; HandleHPatternTransmission(clutchPressed)
; -----------------------------------------------------------------------------
; Handles full H-pattern behavior.
;
; Main modes:
;   no clutch required:
;       selected physical gear is sent immediately
;
;   clutch required:
;       selected gear is stored while clutch is held
;       stored gear is sent when clutch is released
;
;   clutch-to-neutral:
;       clutch press sends neutral once
;       clutch release sends the selected pending gear
;
; Virtual gear tracking:
;   H-pattern mode also updates virtualGear so switching from H-pattern to
;   sequential mode starts from the best-known current gear instead of an
;   outdated sequential estimate.
;
; Neutral behavior:
;   If no gear button is active, selectedGear = 0, which sends neutral.
; =============================================================================
HandleHPatternTransmission(clutchPressed) { ; processes h-pattern mode
    global requireClutch, clutchActsAsNeutral, pendingGear, lastClutchPressed, clutchNeutralSent, virtualGear, maxForwardGear ; h-pattern state and shared gear estimate

    selectedGear := ReadSelectedGear() ; reads physical shifter position
    selectedGear := selectedGear > maxForwardGear ? maxForwardGear : selectedGear ; clamps selected gear to current car gearbox limit

    if clutchActsAsNeutral { ; clutch-neutral behavior can run with or without clutch-required mode
        if clutchPressed {
            if selectedGear > 0 { ; only updates pending gear when a real gear is selected
                pendingGear := selectedGear ; remembers selected gear without letting neutral overwrite it
            } ; end pending gear update

            if !clutchNeutralSent { ; sends neutral once per clutch press
                SendGearToMod(0)
                virtualGear := 0 ; tracks neutral while clutch is held
                clutchNeutralSent := true
            } ; end neutral send branch

            lastClutchPressed := true
            return ; waits for clutch release
        } ; end clutch held branch

        if lastClutchPressed { ; clutch release event
            pendingGear := pendingGear > maxForwardGear ? maxForwardGear : pendingGear ; clamps pending gear to current car gearbox limit
            SendGearToMod(pendingGear, true) ; forces gear re-engagement on clutch release
            virtualGear := pendingGear ; tracks re-engaged gear for future sequential mode
            lastClutchPressed := false ; clears clutch event
            clutchNeutralSent := false ; allows future neutral
            return ; end clutch-neutral release
        } ; end clutch release branch
    } ; end clutch-neutral branch

    if !requireClutch { ; no clutch-required mode
        SendGearToMod(selectedGear) ; sends clamped gear immediately
        virtualGear := selectedGear ; tracks current h-pattern gear for future sequential mode
        return ; end h-pattern handling
    } ; end no clutch branch

    if clutchPressed { ; clutch held without clutch-neutral behavior
        if selectedGear > 0 {
            pendingGear := selectedGear
        } ; end pending gear update

        lastClutchPressed := true
        return ; waits for release
    } ; end clutch held branch

    if lastClutchPressed { ; clutch release event
        pendingGear := pendingGear > maxForwardGear ? maxForwardGear : pendingGear ; clamps pending gear to current car gearbox limit
        SendGearToMod(pendingGear, true) ; force gear re-engagement on clutch release
        virtualGear := pendingGear ; tracks newly engaged h-pattern gear
        lastClutchPressed := false ; clears clutch event
        clutchNeutralSent := false ; clears neutral state defensively
        return ; end release handling
    } ; end release branch

    if selectedGear = 0 { ; passive physical neutral
        SendGearToMod(0)
        virtualGear := 0
    } else { ; idle state while a physical gear remains selected
        virtualGear := selectedGear ; keeps the virtual gear synchronized without sending another shift
    } ; end passive tracking branch
} ; end handlehpatterntransmission


; =============================================================================
; SECTION 18: SEQUENTIAL TRANSMISSION LOGIC
; =============================================================================

; =============================================================================
; HandleSequentialBrakeHoldReset()
; -----------------------------------------------------------------------------
; Implements a recovery heuristic for sequential mode.
;
; Timer Logic:
;   brake pressed -> store brakeHoldStartTime -> measure elapsed time -> elapsed >= brakeHoldResetMs -> trigger reset once
;
; Reset Actions:
;   virtualGear := 1
;   SendGearToMod(1)
;
; Both the script state and game state are updated together to prevent desync.
;
; One-Shot Protection:
;   brakeHoldResetTriggered prevents repeated resets while the brake remains
;   held. The reset becomes available again only after the brake is released.
;
; This heuristic only runs when:
;   transmissionIsSequential = true
;   EnableBrakeHoldGearReset = true
;
; H-pattern mode never uses this logic because H-pattern mode always knows the
; selected gear position directly from the physical shifter.
; =============================================================================
HandleSequentialBrakeHoldReset() {
    global transmissionIsSequential, enableBrakeHoldGearReset, brakeHoldResetMs ; feature settings
    global brakeHoldStartTime, brakeHoldResetTriggered, virtualGear ; timer and gear state

    if !transmissionIsSequential || !enableBrakeHoldGearReset { ; only runs this heuristic in sequential mode when enabled
        brakeHoldStartTime := 0 ; clears timer when feature is inactive
        brakeHoldResetTriggered := false ; clears one-shot trigger when feature is inactive
        return ; skip reset logic
    } ; end feature gate

    if IsBrakePressedForSequentialReset() {
        if brakeHoldStartTime = 0 { ; checks whether this is the first scan of the brake hold
            brakeHoldStartTime := A_TickCount ; stores start time in milliseconds
        } ; end start-time branch

        heldMs := A_TickCount - brakeHoldStartTime ; calculates how long brake has been held

        if heldMs >= brakeHoldResetMs && !brakeHoldResetTriggered { ; checks whether hold duration passed threshold once
            virtualGear := 1 
            SendGearToMod(1)
            brakeHoldResetTriggered := true ; prevents repeated resets during same brake hold
            ShowToolTipMessage("sequential gear reset to 1 after brake hold")
        } ; end reset trigger branch
    } else { ; brake is not held past threshold
        brakeHoldStartTime := 0 ; clears brake hold timer
        brakeHoldResetTriggered := false ; allows reset on next brake hold
    } ; end brake state branch
} ; end handlesequentialbrakeholdreset

; =============================================================================
; TrySequentialShift(direction)
; -----------------------------------------------------------------------------
; Handles one sequential upshift/downshift request.
;
; There are three sequential behavior modes:
;
; 1. no clutch required + no clutch-neutral:
;      shift immediately by sending the game's up/down key
;
; 2. clutch required + no clutch-neutral:
;      do not shift immediately
;      store a net pending shift count
;      send the final net shift amount on clutch release
;
; 3. clutch-neutral enabled:
;      update virtualGear while clutch is held
;      clutch release sends direct gear key for virtualGear
;
; =============================================================================
TrySequentialShift(direction) { ; handles sequential shift input
    global requireClutch, clutchActsAsNeutral, virtualGear, shiftUpKey, shiftDownKey, pendingSequentialShiftCount, maxForwardGear ; sequential settings and state

    if clutchActsAsNeutral { ; clutch-neutral mode uses virtual gear for re-engagement
        if requireClutch && !IsClutchPressed() { ; blocks tracking if clutch is required but not pressed
            return ; ignores invalid shift completely
        } ; end clutch-required gate

        if direction = "up" { ; upshift request
            virtualGear := Min(virtualGear + 1, maxForwardGear) ; increases one gear but never above the current car's highest forward gear
        } else { ; downshift request
            virtualGear := Max(virtualGear - 1, 0) ; decreases one gear but never below neutral (0)
        } ; end virtual gear update branch

        if !requireClutch && !IsClutchPressed() { ; no clutch required and clutch is not pressed
            if direction = "up" { ; upshift request
                TapKey(shiftUpKey) ; sends game's normal upshift key immediately
            } else { ; downshift request
                TapKey(shiftDownKey) ; sends game's normal downshift key immediately
            } ; end passthrough branch
        } ; end no-clutch passthrough branch

        return ; clutch-neutral mode handled
    } ; end clutch-neutral branch

    if requireClutch && !IsClutchPressed() { ; blocks shift if clutch is required but not pressed
        return ; ignores invalid shift attempt
    } ; end clutch gate

    if requireClutch { ; clutch-gated passthrough mode
        if direction = "up" { ; pending upshift
            pendingSequentialShiftCount += 1 ; adds one pending upshift
            virtualGear := Min(virtualGear + 1, maxForwardGear) ; tracks estimated gear after valid shift request
        } else { ; pending downshift
            pendingSequentialShiftCount -= 1 ; adds one pending downshift
            virtualGear := Max(virtualGear - 1, 0) ; tracks estimated gear or neutral after valid shift request
        } ; end pending direction branch

        pendingSequentialShiftCount := Max(-6, Min(6, pendingSequentialShiftCount)) ; limits queued net shifts to the full neutral-through-6th gearbox range
        return ; does not send shift until clutch release
    } ; end clutch-gated passthrough branch

    if direction = "up" { ; no-clutch passthrough upshift
        virtualGear := Min(virtualGear + 1, maxForwardGear) ; tracks estimated gear
        TapKey(shiftUpKey)
    } else { ; no-clutch passthrough downshift
        virtualGear := Max(virtualGear - 1, 0) ; tracks estimated gear or neutral
        TapKey(shiftDownKey)
    } ; end no-clutch passthrough branch
} ; end trysequentialshift

; =============================================================================
; HandleSequentialTransmission(clutchPressed)
; -----------------------------------------------------------------------------
; Handles sequential transmission mode.
;
; Sequential mode has two different internal models:
;
; passthrough model:
;   used when clutchActsAsNeutral = false
;   sends normal game upshift/downshift keys
;
; virtual-gear model:
;   used when clutchActsAsNeutral = true
;   tracks virtualGear and re-engages direct gear on clutch release
;
; With clutch required and clutch-neutral disabled:
;   shift requests are accumulated as pendingSequentialShiftCount
;   the net result is sent when the clutch is released
;
; =============================================================================
HandleSequentialTransmission(clutchPressed) {
    global clutchActsAsNeutral, virtualGear, lastUpshiftPressed, lastDownshiftPressed, lastClutchPressed, clutchNeutralSent, sequentialShifterArmed ; sequential state
    global requireClutch, shiftUpKey, shiftDownKey, pendingSequentialShiftCount, queuedShiftDelayMs ; clutch-gated passthrough settings

    if clutchActsAsNeutral && clutchPressed && !clutchNeutralSent { ; sends neutral once on clutch press
        SendGearToMod(0)
        clutchNeutralSent := true
    } ; end clutch neutral branch

    if IsShifterHandbrakeModeActive() { ; disables shifter-slot sequential shifting while shifter is used as handbrake
        upshiftPressed := false ; prevents shifter slot from sending upshift
        downshiftPressed := false ; prevents shifter slot from sending downshift
        sequentialShifterArmed := true
    } else { ; normal sequential shifter mode
        upshiftPressed := SafeGetKeyState(GetSequentialUpshiftButton(), false) ; reads sequential upshift input
        downshiftPressed := SafeGetKeyState(GetSequentialDownshiftButton(), false) ; reads sequential downshift input
    } ; end shifter handbrake branch

    if !upshiftPressed && !downshiftPressed { ; if sequential lever is physically back in neutral
        sequentialShifterArmed := true ; arm sequential shifting only after neutral is detected
        lastUpshiftPressed := false ; clear upshift edge state so the next upshift can register
        lastDownshiftPressed := false ; clear downshift edge state so the next downshift can register
    } ; end neutral-arm branch

    if !sequentialShifterArmed { ; blocks stale shifter position after switching into sequential mode
        if lastClutchPressed && !clutchPressed { ; still handle clutch release while waiting for neutral
            if clutchActsAsNeutral { ; clutch-neutral mode
                SendGearToMod(virtualGear, true) ; re-engages tracked gear on clutch release
            } ; end clutch-neutral release branch

            clutchNeutralSent := false ; resets neutral flag even while shifter is not armed
        } ; end clutch release while unarmed

        lastClutchPressed := clutchPressed ; still tracks clutch state while waiting for neutral
        return ; waits until shifter returns to neutral before allowing sequential shifts
    } ; end arming gate

    if upshiftPressed && !lastUpshiftPressed { ; upshift edge
        TrySequentialShift("up")
    } ; end upshift branch

    if downshiftPressed && !lastDownshiftPressed { ; downshift edge
        TrySequentialShift("down")
    } ; end downshift branch

    if lastClutchPressed && !clutchPressed { ; clutch release edge
        if clutchActsAsNeutral {
            SendGearToMod(virtualGear) ; re-engages tracked direct gear
        } else if requireClutch && pendingSequentialShiftCount != 0 { ; clutch-gated passthrough mode
            if pendingSequentialShiftCount > 0 { ; net result is upshifts
                Loop pendingSequentialShiftCount { ; sends one upshift per pending step
                    TapKey(shiftUpKey)
                    Sleep queuedShiftDelayMs ; waits so the game can detect the next queued shift
                } ; end upshift loop
            } else { ; net result is downshifts
                Loop Abs(pendingSequentialShiftCount) { ; sends one downshift per pending step
                    TapKey(shiftDownKey)
                    Sleep queuedShiftDelayMs
                } ; end downshift loop
            } ; end pending shift direction branch

            pendingSequentialShiftCount := 0 ; clears pending shifts after sending
        } ; end clutch release behavior branch

        clutchNeutralSent := false
    } ; end release branch

    if upshiftPressed || downshiftPressed { ; if sequential lever is currently in an upshift or downshift slot
        lastUpshiftPressed := upshiftPressed ; stores upshift state for edge detection
        lastDownshiftPressed := downshiftPressed
    } ; end active sequential state branch

    lastClutchPressed := clutchPressed ; stores clutch state
} ; end handlesequentialtransmission

; =============================================================================
; HandlePaddleSync()
; -----------------------------------------------------------------------------
; Updates RealManual's sequential virtual gear when the game's native paddle
; shifters are used.
;
;   This function does not send any shift key.
;   The game already receives the paddle input directly.
;
; Its only job is to keep virtualGear aligned with shifts caused outside of
; RealManual's normal sequential shifter logic.
;
; =============================================================================
HandlePaddleSync() {
    global transmissionIsSequential, enablePaddleSync, virtualGear, maxForwardGear ; sequential mode and tracked gear
    global paddleUpshiftButton, paddleDownshiftButton ; paddle button mappings
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed ; previous paddle states

    if !transmissionIsSequential || !enablePaddleSync { ; only runs paddle sync in sequential mode when enabled
        lastPaddleUpshiftPressed := false ; clears stale upshift edge state
        lastPaddleDownshiftPressed := false
        return ; skip paddle sync
    } ; end mode gate

    paddleUpshiftPressed := SafeGetKeyState(paddleUpshiftButton, false) ; reads paddle upshift button
    paddleDownshiftPressed := SafeGetKeyState(paddleDownshiftButton, false)

    if paddleUpshiftPressed && !lastPaddleUpshiftPressed { ; detects new paddle upshift press
        virtualGear := Min(virtualGear + 1, maxForwardGear) ; updates virtual gear upward without sending a key
    } ; end paddle upshift branch

    if paddleDownshiftPressed && !lastPaddleDownshiftPressed {
        virtualGear := Max(virtualGear - 1, 0)
    } ; end paddle downshift branch

    lastPaddleUpshiftPressed := paddleUpshiftPressed ; stores upshift state for next scan
    lastPaddleDownshiftPressed := paddleDownshiftPressed
} ; end handlepaddlesync


; =============================================================================
; SECTION 19: RECOVERY AND MANUAL SYNC
; =============================================================================

; =============================================================================
; SyncGear(gearNumber)
; -----------------------------------------------------------------------------
; Manually synchronizes RealManual's internal gear state with a known gear.
;
; This is mainly for sequential mode, where the game may start an event in an
; unknown gear while RealManual assumes first gear.
;
; Number keys 1-6 and N call this function.
;
; =============================================================================
SyncGear(gearNumber) {
    global enableSyncHotkeys, virtualGear, pendingGear, lastClutchPressed, clutchNeutralSent, maxForwardGear ; sync state
    global engineStalled

    if engineStalled {
        return ; manual sync cannot bypass the ignition requirement
    }

    if gearNumber > maxForwardGear { ; prevents syncing above current car gearbox limit
        gearNumber := maxForwardGear ; clamps requested gear to current maximum
    } ; end max gear clamp

    if !enableSyncHotkeys { ; checks sync toggle
        return ; ignores sync
    } ; end toggle check

    virtualGear := gearNumber ; updates sequential gear
    pendingGear := gearNumber ; updates h-pattern pending gear
    lastClutchPressed := false ; clears clutch state
    clutchNeutralSent := false ; clears neutral state
    SendGearToMod(gearNumber, true) ; sends selected gear
    ShowToolTipMessage("synced gear " gearNumber)
} ; end syncgear


; =============================================================================
; ResetInputs()
; -----------------------------------------------------------------------------
; Resets RealManual after race restart or unusual game state changes.
;
;   resets virtual and pending gear to 1
;   clears clutch and sequential edge states
;   releases reverse if stuck
;   releases handbrake if stuck
;
; This is a recovery function.
; =============================================================================
ResetInputs() {
    global virtualGear, pendingGear, lastSentGear, lastClutchPressed, clutchNeutralSent, lastUpshiftPressed, lastDownshiftPressed, pendingSequentialShiftCount, reverseHeld, reverseKey, handbrakeHeld, handbrakeKey, lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global engineStalled, stallDetectionArmed
    global lastStallNeutralSendTime, noInputStallStartTime

    virtualGear := 1
    pendingGear := 1
    lastSentGear := 1
    lastClutchPressed := false
    clutchNeutralSent := false
    lastUpshiftPressed := false
    lastDownshiftPressed := false
    lastPaddleUpshiftPressed := false
    lastPaddleDownshiftPressed := false
    pendingSequentialShiftCount := 0
    engineStalled := false
    stallDetectionArmed := false
    lastStallNeutralSendTime := 0
    noInputStallStartTime := 0

    if reverseHeld { ; releases reverse if stuck
        SendEvent "{" reverseKey " up}"
        reverseHeld := false
    } ; end reverse release

    if handbrakeHeld { ; releases handbrake if stuck
        SendEvent "{" handbrakeKey " up}"
        handbrakeHeld := false
    } ; end handbrake release

    ShowToolTipMessage("transmission bridge reset to gear 1")
} ; end resetinputs


; =============================================================================
; SECTION 20: MAIN LOOP
; =============================================================================

; =============================================================================
; MainLoop()
; -----------------------------------------------------------------------------
; Central routing loop for RealManual.
;
; Runs every scanIntervalMs milliseconds.
;
; Order of operations:
;   1. exit early if manually paused
;   2. release held outputs once if NFS loses focus
;   3. exit early if NFS is not focused
;   4. process stall
;   5. process handbrake
;   6. process sequential brake-hold reset heuristic
;   7. process H-pattern reverse override
;   8. read clutch state once
;   9. route to H-pattern or sequential transmission logic
;
; Reverse is handled before forward gears because reverse should override normal
; shifting while the reverse slot is physically active.
; =============================================================================
MainLoop() {  ; routes input to selected transmission mode
    global transmissionIsSequential, scriptPaused, lastNFSFocused  ; mode, pause state, and focus state

    if scriptPaused {  ; skips all input handling while manually paused
        return  ; does nothing until resumed
    }

    if !IsNFSFocused() {  ; checks whether nfs is not currently focused
        if lastNFSFocused {
            ReleaseHeldOutputsQuietly()  ; releases any held game output keys once
        }

        lastNFSFocused := false
        return  ; prevents realmanual from reading or sending gameplay inputs
    }

    lastNFSFocused := true

    if MaintainStalledState() {
        return ; engine is stalled, so all normal transmission handling stays locked
    }

    HandlePaddleSync()

    HandleHandbrake()

    HandleSequentialBrakeHoldReset()

    if HandleReverse() {
        return
    }

    clutchPressed := IsClutchPressed()

    if transmissionIsSequential {
        HandleSequentialTransmission(clutchPressed)
    } else {
        HandleHPatternTransmission(clutchPressed)
    }

    HandleStallDetection(clutchPressed) ; runs after first gear has been engaged on clutch release
}


; =============================================================================
; SECTION 21: STARTUP
; =============================================================================

ShowStartupInfo() ; shows startup confirmation after config loads
RegisterDynamicHotkeys() ; registers configurable hotkeys from config.ini
SetTimer(MainLoop, scanIntervalMs) ; starts main scan loop


; =============================================================================
; SECTION 22: HOTKEYS
; =============================================================================

#HotIf IsNFSFocused()  ; makes the following hotkeys active only while nfs is focused
$1::SyncGear(1)  ; syncs first gear only while nfs is focused
$2::SyncGear(2)
$3::SyncGear(3)
$4::SyncGear(4)
$5::SyncGear(5)
$6::SyncGear(6)
#HotIf  ; end focus-specific hotkey section