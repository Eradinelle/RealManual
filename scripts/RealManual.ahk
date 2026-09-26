; ==========================================================================================================================================================
; REALMANUAL SCRIPT LOOKUP
; ==========================================================================================================================================================
;
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
;   Directives / metadata:
;       AutoHotkey requirements, single-instance policy, keyboard hook
;       app name/version, config path, send mode, key delay
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 2: TRAY MENU SETUP
;   Tray actions:
;       Reload Config, Pause/Resume, Open Validation Log, Exit
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 3: CONFIG FILE HELPERS
;   Config rule maps:
;       numericConfigRules
;       booleanConfigRules
;
;   Functions:
;       ConfigRuleKey()
;       TryParseConfigInt()
;       TryParseConfigBool()
;       ReadBool()
;       ReadInt()
;       ReadText()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 4: CONFIG LOADING - GENERAL AND HOTKEYS
;   Variable groups:
;       General Configuration
;       General Controls
;       Transmission Controls
;       Clutch Controls
;       Shifter-Handbrake Controls
;       Stalling / Ignition Controls
;       Stopwatch Controls
;       Statistics Controls
;       Utility / Capture Controls
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 5: CONFIG LOADING - TRANSMISSION AND CLUTCH
;   Variable groups:
;       Transmission Configuration
;       Clutch Configuration
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 6: CONFIG LOADING - PEDALS, GAME KEYS, AND H-PATTERN
;   Variable groups:
;       Combined Pedal Configuration
;       NFSMW Game Keys
;       H-Pattern Shifter Mappings
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 7: CONFIG LOADING - SEQUENTIAL, HANDBRAKE, STALLING, AND REVERSE ASSIST
;   Variable groups:
;       Sequential Configuration
;       Handbrake Configuration
;       Stalling Configuration
;       Reverse Assist Configuration
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 8: CONFIG LOADING - TIMING, STOPWATCH, AND STATISTICS
;   Variable groups:
;       Timing Configuration
;       Internal Timing
;       Stopwatch Configuration
;       Statistics Configuration
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 9: RUNTIME STATE VARIABLES
;   State groups:
;       transmission / H-pattern state
;       sequential / paddle / keyboard state
;       clutch transaction state
;       handbrake state
;       reverse-assist state
;       stall / engine state
;       script / application state
;       video-settings menu automation state
;       NFSMW process state
;       stopwatch state
;       statistics counters / display state
;       shared overlay layout state
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 10: INPUT / OUTPUT MAPS AND BINDING SANITIZATION
;   Maps:
;       hShifterProtocol
;       gearKeys
;       reservedProtocolKeys
;       reservedProtocolVks
;       gearButtons
;
;   Functions:
;       GetReservedProtocolConflict()
;       SanitizeUserConfiguredKey()
;       SanitizeUserConfiguredBindings()
;       RefreshActiveSequentialBindings()
;
;   Initialization:
;       sanitize configured runtime bindings
;       precompute auxiliary-input configuration flags
;       precompute sequential / shifter-handbrake binding conflicts
;       resolve active sequential bindings
;       build sanitized H-pattern forward-gear map
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 11: LOW-LEVEL OUTPUT HELPERS & SAFETY
;   Functions:
;       SendKeyForDuration()
;       TapKey()
;       SaveNvidiaInstantReplay()
;       CaptureNvidiaScreenshot()
;       TrySetOutputKeyState()
;       TapThrottleBlip()
;       SendGearToMod()
;       ReleaseReverseAssistQuietly()
;       ReleaseHeldOutputsQuietly()
;       HandleScriptExit()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 12: LOW-LEVEL INPUT READERS
;   Generic readers:
;       TryGetInputState()
;       TryGetPhysicalKeyState()
;       SafeGetKeyState()
;
;   Transmission / control readers:
;       ReadClutchAxis()
;       ReadCombinedPedalAxis()
;       IsClutchPressed()
;       ReadSelectedGear()
;       IsBrakeAxisPastThreshold()
;       IsBrakePedalActive()
;       IsBrakePressedForSequentialReset()
;
;   Handbrake / shifter arbitration:
;       IsShifterHandbrakeActive()
;       IsAnalogHandbrakeActive()
;
;   Stall / restart readers:
;       ReadClutchReleasePercent()
;       ReadThrottlePercentForStall()
;       IsBrakePressedForReverseAssist()
;       IsFirstGearSelectedForStall()
;       IsPhysicalShifterNeutral()
;       IsClutchFullyPressedForRestart()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 13: NOTIFICATIONS, STATUS, VALIDATION, AND LOGGING
;   Status / display helpers:
;       BoolText()
;       ModeText()
;       ClearStatusToolTip()
;       ShowToolTipMessage()
;       ShowLiveModeStatus()
;       ShowStartupInfo()
;
;   Validation / logging:
;       DetectInputHardware()
;       AddValidationWarning()
;       BuildValidationText()
;       WriteStartupLogFile()
;       OpenValidationLog()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 14: STATISTICS & SHARED OVERLAY LAYOUT
;   Persistence / initialization:
;       ReadStatCount()
;       SaveStatCount()
;       InitializeStats()
;       ApplyStatisticsStartupOptions()
;       StartStatsSession()
;       FinalizeStatsSession()
;       SynchronizeStatsSession()
;
;   Event recording:
;       RecordShift()
;       RecordStall()
;       RecordRaceRestart()
;
;   Display / shared layout:
;       IsStatsDisplayActive()
;       GetOverlayX()
;       UpdateStatsDisplay()
;       ToggleStatsDisplay()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 15: STOPWATCH
;   Functions:
;       FormatStopwatchTime()
;       GetStopwatchElapsedMs()
;       UpdateStopwatchDisplay()
;       ToggleStopwatch()
;       LapStopwatch()
;       ClearStopwatch()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 16: TRANSIENT STATE CLEAR / DISARM HELPERS
;   Transmission state:
;       ClearEdgeInputState()
;       ClearClutchTransactionState()
;       ClearTransmissionInputState()
;       DisarmEdgeInputs()
;
;   Stall / brake-reset state:
;       ClearStallDetectionState()
;       ClearBrakeResetStallGraceState()
;       ClearSequentialBrakeHoldTimer()
;       ClearSequentialBrakeResetState()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 17: DYNAMIC HOTKEYS AND LIVE MODE TOGGLES
;   Dynamic registration:
;       GetDynamicHotkeyDefinitions()
;       TryRegisterHotkey()
;       RegisterDynamicHotkeys()
;       ShowHotkeyHelp()
;
;   Transmission / feature controls:
;       SetTransmissionMode()
;       ToggleTransmissionMode()
;       ToggleClutchRequired()
;       ToggleClutchNeutral()
;       ToggleMaxForwardGear()
;       ToggleSequentialShifterInvert()
;       ToggleShifterHandbrake()
;       ToggleStalling()
;       ToggleScriptPause()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 18: NFSMW MENU AUTOMATION
;   Menu output:
;       TapMenuKey()
;
;   Sequence construction:
;       AddMenuSequenceSteps()
;       BuildMaxVideoSettingsSequence()
;
;   Sequence lifecycle / scheduling:
;       StopMaxVideoSettingsSequence()
;       ProcessMaxVideoSettingsStep()
;
;   Hotkey entry point:
;       ApplyMaxVideoSettings()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 19: AUXILIARY INPUT / SYNC HANDLERS
;   Functions:
;       HandlePaddleSync()
;       HandleKeyboardShiftSync()
;       HandleHandbrake()
;       HandleReverseAssist()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 20: STALL / ENGINE OFF/ON SIMULATION LOGIC
;   Stall protection / detection:
;       ShouldSuppressStallForBrakeReset()
;       HandleStallDetection()
;
;   Engine-state transitions:
;       EnterEngineOffState()
;       StallEngine()
;       ShutOffEngine()
;       MaintainStalledState()
;       TryRestartEngine()
;       HandleIgnitionButton()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 21: H-PATTERN TRANSMISSION LOGIC
;   Function:
;       HandleHPatternTransmission()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 22: SEQUENTIAL TRANSMISSION LOGIC
;   Brake recovery:
;       HandleSequentialBrakeHoldReset()
;
;   Shift processing:
;       TrySequentialShift()
;       SendQueuedSequentialShifts()
;       HandleSequentialTransmission()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 23: RECOVERY AND MANUAL SYNC
;   Functions:
;       SyncGear()
;       ResetInputs()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 24: NFSMW PROCESS / FOCUS TRACKING
;   Functions:
;       IsNFSFocused()
;       InitializeNFSProcessTracking()
;       MonitorNFSProcess()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 25: MAIN LOOP
;   Functions:
;       SetMainLoopTimerInterval()
;       UpdateMainLoopSchedule()
;       MainLoop()
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 26: STARTUP
;   Initialization order:
;       register exit cleanup
;       initialize statistics
;       initialize NFSMW process tracking
;       ApplyStatisticsStartupOptions()
;       register configurable hotkeys
;       show startup / validation information
;       start NFSMW process monitor
;       start MainLoop
;
;-----------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 27: FIXED H-SHIFTER HOTKEYS
;   Fixed protocol bindings:
;       $0 -> reverse
;       $n -> neutral
;       $1-$6 -> forward gears
;
; ==========================================================================================================================================================


; ==========================================================================================================================================================
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
; ==========================================================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force ; prevent duplicate copies of this script
#UseHook true ; force keyboard hook for better game compatibility
appName := "RealManual"
appVersion := "1.2.0"
SendMode "Event" ; event-style key sending for older games
configFile := A_ScriptDir "\config.ini" ; config path needs to be beside this script
SetKeyDelay 0, 0 ; sends keys as quickly as possible


; ==========================================================================================================================================================
; SECTION 2: TRAY MENU SETUP
; ==========================================================================================================================================================

A_TrayMenu.Delete()
A_TrayMenu.Add("Reload Config", (*) => Reload())
A_TrayMenu.Default := "Reload Config"
A_TrayMenu.Add()
A_TrayMenu.Add("Pause RealManual", ToggleScriptPause)
A_TrayMenu.Add("Open Validation Log", OpenValidationLog)
A_TrayMenu.Add()
A_TrayMenu.Add("Exit RealManual", (*) => ExitApp())


; ==========================================================================================================================================================
; SECTION 3: CONFIG FILE HELPERS
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; CONFIGURATION SANITY RULES
; ==========================================================================================================================================================
;
; Numeric rules are operational guardrails
;
; Each entry:
;   "Section|Key" => [minimum, maximum]
;
; The same rules are used by:
;   ReadInt()             - runtime fallback protection
;   BuildValidationText() - startup sanity reporting
; ==========================================================================================================================================================

ConfigRuleKey(section, key) {
    return section "|" key
} ; end configrulekey


numericConfigRules := Map(
    ConfigRuleKey("General", "ToolTipDurationMs"),             [100, 30000],

    ConfigRuleKey("Transmission", "MaxForwardGear"),           [5, 6],

    ConfigRuleKey("Timing", "KeyHoldMs"),                      [1, 250],
    ConfigRuleKey("Timing", "ScanIntervalMs"),                 [1, 100],

    ConfigRuleKey("Clutch", "ClutchThreshold"),                [1, 99],
    ConfigRuleKey("Handbrake", "HandbrakeThreshold"),          [1, 99],

    ConfigRuleKey("Pedals", "CombinedPedalCenter"),            [1, 99],
    ConfigRuleKey("Pedals", "BrakeActiveThreshold"),           [1, 99],

    ConfigRuleKey("Sequential", "BrakeHoldResetMs"),           [100, 10000],
    ConfigRuleKey("Sequential", "BrakeResetThreshold"),        [1, 99],
    ConfigRuleKey("Sequential", "QueuedShiftDelayMs"),         [1, 1000],

    ConfigRuleKey("Stalling", "ClutchReleaseThreshold"),       [1, 99],
    ConfigRuleKey("Stalling", "ThrottleThreshold"),            [0, 100],
    ConfigRuleKey("Stalling", "RestartClutchThreshold"),       [0, 99],
    ConfigRuleKey("Stalling", "NeutralResendMs"),              [50, 1000],
    ConfigRuleKey("Stalling", "ThrottleBlipMs"),               [1, 2000],
    ConfigRuleKey("Stalling", "NoInputStallDelayMs"),          [0, 1500],
    ConfigRuleKey("Stalling", "BrakeResetStallGraceMs"),       [0, 1000],

    ConfigRuleKey("ReverseAssist", "EngageBrakeThreshold"),    [1, 99],

    ConfigRuleKey("Stopwatch", "StopwatchRefreshMs"),          [20, 1000],
    ConfigRuleKey("Stopwatch", "StopwatchMaxLines"),           [1, 50]
)

booleanConfigRules := Map(
    ConfigRuleKey("General", "WriteStartupLog"), true,
    ConfigRuleKey("General", "EnableToolTips"), true,

    ConfigRuleKey("Transmission", "StartInSequentialMode"), true,
    ConfigRuleKey("Sequential", "InvertSequentialShifter"), true,
    ConfigRuleKey("Clutch", "RequireClutch"), true,
    ConfigRuleKey("Clutch", "ClutchActsAsNeutral"), true,

    ConfigRuleKey("Handbrake", "EnableShifterHandbrake"), true,

    ConfigRuleKey("Sequential", "EnableBrakeHoldGearReset"), true,
    ConfigRuleKey("Pedals", "BrakeAxisIncreasesWhenPressed"), true,

    ConfigRuleKey("Stalling", "EnableStalling"), true,
    ConfigRuleKey("ReverseAssist", "EnableReverseAssist"), true,

    ConfigRuleKey("Statistics", "TrackShifts"), false,
    ConfigRuleKey("Statistics", "TrackStalls"), false,
    ConfigRuleKey("Statistics", "TrackRaceRestarts"), false,
    ConfigRuleKey("Statistics", "ClearAllTimeOnStartup"), false
)

; ==========================================================================================================================================================
; TryParseConfigInt(rawValue, &parsedValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Validates integer syntax
; ==========================================================================================================================================================
TryParseConfigInt(rawValue, &parsedValue) {
    parsedValue := 0
    rawValue := Trim(rawValue)

    if !RegExMatch(rawValue, "^[0-9]+$") {
        return false
    } ; end syntax guard

    try {
        parsedValue := Integer(rawValue)
        return true
    } catch {
        return false
    } ; end conversion guard
} ; end tryparseconfigint

; ==========================================================================================================================================================
; TryParseConfigBool(rawValue, &parsedValue)
; ==========================================================================================================================================================
TryParseConfigBool(rawValue, &parsedValue) {
    rawValue := Trim(rawValue)
    parsedValue := false

    if rawValue = "1" {
        parsedValue := true
        return true
    }

    if rawValue = "0" {
        parsedValue := false
        return true
    }

    return false
} ; end tryparseconfigbool

; ==========================================================================================================================================================
; ReadBool(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a boolean option from config.ini.
;
; Missing, blank, or malformed values return the supplied fallback.
; ==========================================================================================================================================================
ReadBool(section, key, fallback) {
    global configFile

    rawValue := IniRead(configFile, section, key, "")

    if TryParseConfigBool(rawValue, &parsedValue) {
        return parsedValue
    }

    return fallback
} ; end readbool


; ==========================================================================================================================================================
; ReadInt(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a numeric config value and applies its registered sanity range.
;
; Invalid syntax, missing values, or out-of-range values return fallback.
;
; BuildValidationText() separately reports the original invalid config value
; ==========================================================================================================================================================
ReadInt(section, key, fallback) {
    global configFile, numericConfigRules

    ruleKey := ConfigRuleKey(section, key)

    ; explicit sanity rule
    if !numericConfigRules.Has(ruleKey) {
        return fallback
    } ; end missing numeric rule guard

    rawValue := IniRead(configFile, section, key, "")

    if !TryParseConfigInt(rawValue, &parsedValue) {
        return fallback
    } ; end integer syntax guard

    range := numericConfigRules[ruleKey]
    minimum := range[1]
    maximum := range[2]

    if parsedValue < minimum || parsedValue > maximum {
        return fallback
    } ; end numeric range guard

    return parsedValue
} ; end readint


; ==========================================================================================================================================================
; ReadText(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a text option from config.ini.
;
; Used for key names, joystick button names, and joystick axis names such as:
;   1Joy13
;   1JoyY
;   Space
;   F4
;
; Missing settings return the supplied fallback.
;
; When no fallback is supplied, a missing setting also returns an empty string.
; ==========================================================================================================================================================
ReadText(section, key, fallback := "") {
    global configFile

    return IniRead(configFile, section, key, fallback)
} ; end readtext


; ==========================================================================================================================================================
; SECTION 4: CONFIG LOADING - GENERAL AND HOTKEYS
; ==========================================================================================================================================================

; General Configuration
writeStartupLog := ReadBool("General", "WriteStartupLog", true)
enableToolTips := ReadBool("General", "EnableToolTips", true)
toolTipDurationMs := ReadInt("General", "ToolTipDurationMs", 2000)

; General Controls
helpButton := ReadText("Hotkeys", "HelpButton")
resetButton := ReadText("Hotkeys", "ResetButton")
pauseButton := ReadText("Hotkeys", "PauseButton")
reloadButton := ReadText("Hotkeys", "ReloadButton")

; Transmission Controls
toggleTransmissionModeButton := ReadText("Hotkeys", "ToggleTransmissionModeButton")
toggleSequentialShifterInvertButton := ReadText("Hotkeys", "ToggleSequentialShifterInvertButton")
toggleMaxForwardGearButton := ReadText("Hotkeys", "ToggleMaxForwardGearButton")

; Clutch Controls
toggleClutchRequiredButton := ReadText("Hotkeys", "ToggleClutchRequiredButton")
toggleClutchNeutralButton := ReadText("Hotkeys", "ToggleClutchNeutralButton")

; Shifter-Handbrake Controls
toggleShifterHandbrakeButton := ReadText("Hotkeys", "ToggleShifterHandbrakeButton")

; Stalling / Ignition Controls
toggleStallingButton := ReadText("Hotkeys", "ToggleStallingButton")
ignitionButton := ReadText("Hotkeys", "IgnitionButton")

; Stopwatch Controls
stopwatchButton := ReadText("Hotkeys", "StopwatchButton")
stopwatchLapButton := ReadText("Hotkeys", "StopwatchLapButton")
stopwatchClearButton := ReadText("Hotkeys", "StopwatchClearButton")

; Statistics Controls
statsShiftsButton := ReadText("Hotkeys", "StatsShiftsButton")
statsStallsButton := ReadText("Hotkeys", "StatsStallsButton")
statsRaceRestartsButton := ReadText("Hotkeys", "StatsRaceRestartsButton")
raceRestartButton := ReadText("Hotkeys", "RaceRestartButton")

; Utility / Capture Controls
maxVideoSettingsButton := ReadText("Hotkeys", "MaxVideoSettingsButton")
saveInstantReplayButton := ReadText("Hotkeys", "SaveInstantReplayButton")
captureScreenshotButton := ReadText("Hotkeys", "CaptureScreenshotButton")


; ==========================================================================================================================================================
; SECTION 5: CONFIG LOADING - TRANSMISSION AND CLUTCH
; ==========================================================================================================================================================

; Transmission Configuration
startInSequentialMode := ReadBool("Transmission", "StartInSequentialMode", false)
transmissionIsSequential := startInSequentialMode
maxForwardGear := ReadInt("Transmission", "MaxForwardGear", 6)

; Clutch Configuration
requireClutch := ReadBool("Clutch", "RequireClutch", true)
clutchActsAsNeutral := ReadBool("Clutch", "ClutchActsAsNeutral", true)
clutchAxis := ReadText("Clutch", "ClutchAxis")
clutchThreshold := ReadInt("Clutch", "ClutchThreshold", 40)


; ==========================================================================================================================================================
; SECTION 6: CONFIG LOADING - PEDALS, GAME KEYS, AND H-PATTERN
; ==========================================================================================================================================================

; Combined Pedal Configuration
combinedPedalAxis := ReadText("Pedals", "CombinedPedalAxis")
combinedPedalCenter := ReadInt("Pedals", "CombinedPedalCenter", 50)
brakeAxisIncreasesWhenPressed := ReadBool("Pedals", "BrakeAxisIncreasesWhenPressed", true)
brakeActiveThreshold := ReadInt("Pedals", "BrakeActiveThreshold", 55)

; NFSMW Game Keys
forwardKey := ReadText("GameKeys", "ForwardKey")
reverseKey := ReadText("GameKeys", "ReverseKey")
handbrakeKey := ReadText("GameKeys", "HandbrakeKey")
shiftUpKey := ReadText("GameKeys", "ShiftUpKey")
shiftDownKey := ReadText("GameKeys", "ShiftDownKey")

; H-Pattern Shifter Mappings
gear1Button := ReadText("HPattern", "Gear1Button")
gear2Button := ReadText("HPattern", "Gear2Button")
gear3Button := ReadText("HPattern", "Gear3Button")
gear4Button := ReadText("HPattern", "Gear4Button")
gear5Button := ReadText("HPattern", "Gear5Button")
gear6Button := ReadText("HPattern", "Gear6Button")
reverseButton := ReadText("HPattern", "ReverseButton")


; ==========================================================================================================================================================
; SECTION 7: CONFIG LOADING - SEQUENTIAL, HANDBRAKE, STALLING, AND REVERSE ASSIST
; ==========================================================================================================================================================

; Sequential Configuration
invertSequentialShifter := ReadBool("Sequential", "InvertSequentialShifter", false)
sequentialUpshiftButton := ReadText("Sequential", "SequentialUpshiftButton")
sequentialDownshiftButton := ReadText("Sequential", "SequentialDownshiftButton")
paddleUpshiftButton := ReadText("Sequential", "PaddleUpshiftButton")
paddleDownshiftButton := ReadText("Sequential", "PaddleDownshiftButton")
enableBrakeHoldGearReset := ReadBool("Sequential", "EnableBrakeHoldGearReset", true)
brakeHoldResetMs := ReadInt("Sequential", "BrakeHoldResetMs", 2000)
brakeResetThreshold := ReadInt("Sequential", "BrakeResetThreshold", 70)
queuedShiftDelayMs := ReadInt("Sequential", "QueuedShiftDelayMs", 35)

; Handbrake Configuration
handbrakeAxis := ReadText("Handbrake", "HandbrakeAxis")
handbrakeThreshold := ReadInt("Handbrake", "HandbrakeThreshold", 20)
enableShifterHandbrake := ReadBool("Handbrake", "EnableShifterHandbrake", false)
shifterHandbrakeButton := ReadText("Handbrake", "ShifterHandbrakeButton")

; Stalling Configuration
enableStalling := ReadBool("Stalling", "EnableStalling", false)
clutchReleaseThreshold := ReadInt("Stalling", "ClutchReleaseThreshold", 60)
throttleThreshold := ReadInt("Stalling", "ThrottleThreshold", 15)
restartClutchThreshold := ReadInt("Stalling", "RestartClutchThreshold", 15)
neutralResendMs := ReadInt("Stalling", "NeutralResendMs", 50)
throttleBlipMs := ReadInt("Stalling", "ThrottleBlipMs", 500)
noInputStallDelayMs := ReadInt("Stalling", "NoInputStallDelayMs", 700)
brakeResetStallGraceMs := ReadInt("Stalling", "BrakeResetStallGraceMs", 100)

; Reverse Assist Configuration
enableReverseAssist := ReadBool("ReverseAssist", "EnableReverseAssist", false)
engageBrakeThreshold := ReadInt("ReverseAssist", "EngageBrakeThreshold", 60)


; ==========================================================================================================================================================
; SECTION 8: CONFIG LOADING - TIMING, STOPWATCH, AND STATISTICS
; ==========================================================================================================================================================

; Timing Configuration
keyHoldMs := ReadInt("Timing", "KeyHoldMs", 18)
scanIntervalMs := ReadInt("Timing", "ScanIntervalMs", 5)

; Internal Timing
mainLoopIdleIntervalMs := 100 ; slower MainLoop polling while NFSMW is unfocused

; Stopwatch Configuration
stopwatchRefreshMs := ReadInt("Stopwatch", "StopwatchRefreshMs", 50)
stopwatchMaxLines := ReadInt("Stopwatch", "StopwatchMaxLines", 10)

; Statistics Configuration
trackShifts := ReadBool("Statistics", "TrackShifts", false)
trackStalls := ReadBool("Statistics", "TrackStalls", false)
trackRaceRestarts := ReadBool("Statistics", "TrackRaceRestarts", false)
clearAllTimeOnStartup := ReadBool("Statistics", "ClearAllTimeOnStartup", false)


; ==========================================================================================================================================================
; SECTION 9: RUNTIME STATE VARIABLES
; ==========================================================================================================================================================

; Transmission
virtualGear := 1 ; best-known current game gear across transmission modes
lastSentGear := 1 ; last successfully sent direct H-Shifter gear; NFSMW starts in 1st

; H-Pattern
lastHPatternSelectedGear := -2 ; last known physical H-pattern position; -2 = unknown
reverseCommandLatched := false ; prevents repeated direct reverse commands during one brake engagement

; Sequential / Paddle / Keyboard
pendingSequentialShiftCount := 0 ; net sequential shifts queued while clutch is held
sequentialShifterArmed := false ; true after sequential lever returns to a valid neutral position
paddleSyncArmed := false ; true after paddle inputs return to a valid released state
lastUpshiftPressed := false
lastDownshiftPressed := false
lastPaddleUpshiftPressed := false
lastPaddleDownshiftPressed := false
keyboardShiftSyncArmed := false
lastKeyboardUpshiftPressed := false
lastKeyboardDownshiftPressed := false

; Clutch Transaction
lastClutchPressed := false ; previous clutch state used for clutch-edge detection
clutchNeutralSent := false ; true after clutch-to-neutral has sent neutral for current clutch hold

; Handbrake
shifterHandbrakeArmed := false ; true after shifter-handbrake input returns to its resting state
handbrakeHeld := false

; Sequential Brake Reset / Reverse Assist Eligibility
brakeHoldStartTime := 0 ; A_TickCount when the current hard-brake hold began
brakeHoldResetTriggered := false ; prevents repeated first-gear resets during one brake hold
brakeResetStallGraceActive := false ; true while post-reset stall protection is active
brakeResetReleaseTime := 0 ; A_TickCount when brake release began the stall-grace period
sequentialReverseAssistEligible := false ; true when current brake-reset sequence began outside neutral

; Reverse Assist
reverseAssistHeld := false ; true while RealManual is holding the digital reverse key

; Stall / Engine
engineStalled := false
stallDetectionArmed := false ; true when a clutch-release stall check is armed
stallSuppressedUntilShift := false ; true after silent new-game reset until next accepted driver shift
noInputStallStartTime := 0 ; A_TickCount when sustained first-gear low-throttle condition began
lastStallNeutralSendTime := 0 ; A_TickCount of the last stalled-state neutral keepalive

; Script / Application
lastNFSFocused := false ; true if NFSMW was focused during the previous MainLoop scan
scriptPaused := false
mainLoopTimerIntervalMs := 0 ; currently scheduled MainLoop timer interval; 0 = stopped
dynamicHotkeyRegistrationResults := [] ; startup results for configurable hotkey registration

; Video Settings Menu Automation
videoSettingsSequenceActive := false
videoSettingsSequence := [] ; ordered menu-navigation steps for the active macro
videoSettingsSequenceIndex := 0 ; next menu-navigation step waiting to execute

; NFSMW Process Tracking
nfsProcessPid := 0 ; PID of the currently known speed.exe instance
nfsProcessSeen := false ; true after at least one NFSMW process has been observed
nfsInstanceResetPending := false ; true when a replacement game instance needs internal synchronization

; Stopwatch
stopwatchStarted := false
stopwatchRunning := false
stopwatchStartTime := 0
stopwatchAccumulatedMs := 0
stopwatchLaps := []
stopwatchToolTipId := 2 ; for the overlay

; Statistics Counters
statsFile := A_ScriptDir "\stats.txt" ; persistent statistics file beside RealManual
sessionProcessPid := 0 ; NFSMW PID that owns the current statistics session
sessionShiftCount := 0
sessionStallCount := 0
sessionRaceRestartCount := 0
allTimeShiftCount := 0
allTimeStallCount := 0
allTimeRaceRestartCount := 0
statsLastGear := 1

; Statistics Display
showShiftStats := false
showStallStats := false
showRaceRestartStats := false
statsToolTipId := 3

; Shared Overlay Layout
overlayActivationCounter := 0 ; monotonically increasing overlay activation sequence
stopwatchOverlayOrder := 0 ; activation order of stopwatch overlay; 0 = inactive
statsOverlayOrder := 0
overlayPrimaryX := 20 ; horizontal position used by the first active overlay
overlaySecondaryX := 260 ; horizontal position used by the second active overlay
overlayY := 20 ; shared vertical position for stopwatch and statistics overlays

; ==========================================================================================================================================================
; SECTION 10: INPUT / OUTPUT MAPS AND BINDING SANITIZATION
; ==========================================================================================================================================================

hShifterProtocol := [
    [-1, "0", "H-Shifter Reverse Sync"],
    [ 0, "n", "H-Shifter Neutral Sync"],
    [ 1, "1", "H-Shifter Gear 1 Sync"],
    [ 2, "2", "H-Shifter Gear 2 Sync"],
    [ 3, "3", "H-Shifter Gear 3 Sync"],
    [ 4, "4", "H-Shifter Gear 4 Sync"],
    [ 5, "5", "H-Shifter Gear 5 Sync"],
    [ 6, "6", "H-Shifter Gear 6 Sync"]
]

gearKeys := Map()
reservedProtocolKeys := Map()
reservedProtocolVks := Map()

for protocolEntry in hShifterProtocol {
    logicalGear := protocolEntry[1]
    protocolKey := protocolEntry[2]
    protocolPurpose := protocolEntry[3]

    gearKeys[logicalGear] := protocolKey

    ; normal textual lookup
    reservedProtocolKeys[StrLower(protocolKey)] := protocolPurpose

    ; physical keyboard lookup
    try {
        protocolVk := GetKeyVK(protocolKey)

        if protocolVk {
            reservedProtocolVks[protocolVk] := protocolPurpose
        }
    }
}

; ==========================================================================================================================================================
; GetReservedProtocolConflict(binding)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Checks any USER-CONFIGURED binding against MW2005-HShifter's fixed keyboard protocol.
;
; The H-Shifter protocol owns these physical keyboard keys exclusively:
;
;   0   = reverse
;   N   = neutral
;   1-6 = forward gears
;
; The check applies to:
;   - RealManual hotkeys
;   - NFSMW output bindings
;   - physical shifter mappings
;   - sequential shifter mappings
;   - paddle mappings
;   - shifter-handbrake mappings
;   - configured axes/input names
;
; Modifier-prefixed hotkeys are reduced to their underlying key.
; Custom AHK combinations are checked component-by-component.
;
; Both normal key names and alternate VK/SC representations are checked.
;
; Returns:
;   protocol description = a reserved H-Shifter physical key was found
;   ""                   = no reserved-key conflict
; ==========================================================================================================================================================
GetReservedProtocolConflict(binding) {
    global reservedProtocolKeys
    global reservedProtocolVks

    binding := Trim(binding)

    if binding = "" {
        return ""
    } ; end blank-binding guard

    bindingParts := StrSplit(binding, "&")

    for bindingPart in bindingParts {
        normalizedKey := Trim(bindingPart)
        normalizedKey := RegExReplace(normalizedKey, "i)\s+up$")
        ; removes AHK hotkey prefixes:
        ;   +  Shift
        ;   ^  Ctrl
        ;   !  Alt
        ;   #  Win
        ;   <  left modifier
        ;   >  right modifier
        ;   *  wildcard
        ;   ~  pass-through
        ;   $  keyboard hook
        normalizedKey := RegExReplace(normalizedKey, "^[~*$<>!^+#]+")
        normalizedKey := Trim(normalizedKey)
        normalizedLower := StrLower(normalizedKey)

        ; direct name match
        if reservedProtocolKeys.Has(normalizedLower) {
            return reservedProtocolKeys[normalizedLower]
        } ; end direct protocol-name match

        ; physical virtual-key match catches alternate names that resolve to the same keyboard key
        try {
            bindingVk := GetKeyVK(normalizedKey)

            if bindingVk && reservedProtocolVks.Has(bindingVk) {
                return reservedProtocolVks[bindingVk]
            }
        }
    } ; end binding-component loop

    return ""
} ; end getreservedprotocolconflict

; ==========================================================================================================================================================
; SanitizeUserConfiguredKey(binding)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Applies the shared H-Shifter reserved-key policy to a user-configured binding.
;
; Returns:
;   original binding = no H-Shifter conflict
;   ""               = binding conflicts with the fixed H-Shifter protocol
;
; This is intended for user-configured runtime bindings other than dynamic hotkeys. 
; Dynamic hotkeys use the same conflict checker inside TryRegisterHotkey() because they also need to record a registration result.
; ==========================================================================================================================================================
SanitizeUserConfiguredKey(binding) {

    if GetReservedProtocolConflict(binding) != "" {
        return ""
    } ; end reserved binding

    return Trim(binding)
} ; end sanitizeuserconfiguredkey

; ==========================================================================================================================================================
; SanitizeUserConfiguredBindings()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Applies the fixed H-Shifter reservation policy to every user-configured
; runtime binding other than dynamic hotkeys.
;
; Dynamic hotkeys are handled separately by TryRegisterHotkey() because their
; conflict must be recorded as a registration result.
;
; A reserved user binding becomes blank at runtime so no later input/output path
; can accidentally use an H-Shifter protocol key.
; ==========================================================================================================================================================
SanitizeUserConfiguredBindings() {
    global clutchAxis
    global combinedPedalAxis
    global handbrakeAxis

    global forwardKey
    global reverseKey
    global handbrakeKey
    global shiftUpKey
    global shiftDownKey

    global gear1Button
    global gear2Button
    global gear3Button
    global gear4Button
    global gear5Button
    global gear6Button
    global reverseButton

    global sequentialUpshiftButton
    global sequentialDownshiftButton

    global paddleUpshiftButton
    global paddleDownshiftButton

    global shifterHandbrakeButton

    ; axes/general physical inputs
    clutchAxis := SanitizeUserConfiguredKey(clutchAxis)
    combinedPedalAxis := SanitizeUserConfiguredKey(combinedPedalAxis)
    handbrakeAxis := SanitizeUserConfiguredKey(handbrakeAxis)

    ; NFSMW output bindings
    forwardKey := SanitizeUserConfiguredKey(forwardKey)
    reverseKey := SanitizeUserConfiguredKey(reverseKey)
    handbrakeKey := SanitizeUserConfiguredKey(handbrakeKey)
    shiftUpKey := SanitizeUserConfiguredKey(shiftUpKey)
    shiftDownKey := SanitizeUserConfiguredKey(shiftDownKey)

    ; H-pattern physical mappings
    gear1Button := SanitizeUserConfiguredKey(gear1Button)
    gear2Button := SanitizeUserConfiguredKey(gear2Button)
    gear3Button := SanitizeUserConfiguredKey(gear3Button)
    gear4Button := SanitizeUserConfiguredKey(gear4Button)
    gear5Button := SanitizeUserConfiguredKey(gear5Button)
    gear6Button := SanitizeUserConfiguredKey(gear6Button)
    reverseButton := SanitizeUserConfiguredKey(reverseButton)

    ; sequential physical mappings
    sequentialUpshiftButton := SanitizeUserConfiguredKey(sequentialUpshiftButton)
    sequentialDownshiftButton := SanitizeUserConfiguredKey(sequentialDownshiftButton)

    ; paddle synchronization inputs
    paddleUpshiftButton := SanitizeUserConfiguredKey(paddleUpshiftButton)
    paddleDownshiftButton := SanitizeUserConfiguredKey(paddleDownshiftButton)

    ; shifter-handbrake input
    shifterHandbrakeButton := SanitizeUserConfiguredKey(shifterHandbrakeButton)
} ; end sanitizeuserconfiguredbindings

SanitizeUserConfiguredBindings()

; ==========================================================================================================================================================
; Precompute Auxiliary Input Configuration
; ==========================================================================================================================================================

paddleSyncConfigured :=
    paddleUpshiftButton != ""
    && paddleDownshiftButton != ""

keyboardShiftSyncConfigured :=
    shiftUpKey != ""
    && shiftDownKey != ""

analogHandbrakeConfigured :=
    handbrakeAxis != ""

; ==========================================================================================================================================================
; Precompute Sequential / Shifter-Handbrake Binding Conflict
; ==========================================================================================================================================================

shifterHandbrakeConflict :=
    shifterHandbrakeButton != ""
    && (
        (
            sequentialUpshiftButton != ""
            && shifterHandbrakeButton = sequentialUpshiftButton
        )
        || (
            sequentialDownshiftButton != ""
            && shifterHandbrakeButton = sequentialDownshiftButton
        )
    )

; ==========================================================================================================================================================
; RefreshActiveSequentialBindings()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Resolves the active sequential upshift/downshift bindings from the configured
; physical shifter mappings and current sequential inversion state.
;
; Called at startup and whenever sequential inversion changes.
; ==========================================================================================================================================================
RefreshActiveSequentialBindings() {
    global invertSequentialShifter
    global sequentialUpshiftButton
    global sequentialDownshiftButton

    global activeSequentialUpshiftButton
    global activeSequentialDownshiftButton

    if invertSequentialShifter {
        activeSequentialUpshiftButton := sequentialDownshiftButton
        activeSequentialDownshiftButton := sequentialUpshiftButton
    } else {
        activeSequentialUpshiftButton := sequentialUpshiftButton
        activeSequentialDownshiftButton := sequentialDownshiftButton
    } ; end sequential mapping resolution
} ; end refreshactivesequentialbindings

RefreshActiveSequentialBindings()

; build sanitized H-pattern forward-gear map
gearButtons := Map()

for mapping in [
    [gear1Button, 1],
    [gear2Button, 2],
    [gear3Button, 3],
    [gear4Button, 4],
    [gear5Button, 5],
    [gear6Button, 6]
] {
    buttonName := mapping[1]
    gearNumber := mapping[2]

    if buttonName = "" {
        continue
    } ; end blank mapping guard

    if gearButtons.Has(buttonName) {
        continue
    } ; end duplicate mapping guard

    gearButtons[buttonName] := gearNumber
} ; end physical gear map construction

hPatternMappingValid :=
    gearButtons.Count = 6
    && reverseButton != ""
    && !gearButtons.Has(reverseButton)

; ==========================================================================================================================================================
; SECTION 11: LOW-LEVEL OUTPUT HELPERS & SAFETY
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; SendKeyForDuration(keyName, holdMs)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Presses one configured output key, holds it for the requested duration, then releases it.
;
; Centralizes timed key output used by normal key taps and longer simulated throttle blips.
; ==========================================================================================================================================================
SendKeyForDuration(keyName, holdMs) {
    if keyName = "" {
        return false
    } ; end blank output guard

    try {
        SendEvent "{" keyName " down}"
        Sleep holdMs
        SendEvent "{" keyName " up}"
        return true
    } catch {
        ; release
        try {
            SendEvent "{" keyName " up}"
        }

        return false
    } ; end protected timed output
} ; end sendkeyforduration

; ==========================================================================================================================================================
; TapKey(keyName)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends one controlled key tap.
;
; The key is pressed, held for keyHoldMs milliseconds, then released.
; More reliable than an instant tap because older games and ASI plugins can miss synthetic key presses that are too short.
; ==========================================================================================================================================================
TapKey(keyName) {
    global keyHoldMs

    return SendKeyForDuration(keyName, keyHoldMs)
} ; end tapkey

; ==========================================================================================================================================================
; SaveNvidiaInstantReplay(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends NVIDIA Overlay's fixed Alt+F10 shortcut for saving the current Instant Replay buffer.
;
; RealManual's configurable hotkey determines which physical controller button invokes this function. The NVIDIA output shortcut itself remains Alt+F10.
; ==========================================================================================================================================================
SaveNvidiaInstantReplay(*) { ; handles the configurable realmanual instant-replay hotkey
    SendEvent "!{F10}" ; sends alt+f10 to the nvidia overlay
} ; end savenvidiainstantreplay


; ==========================================================================================================================================================
; CaptureNvidiaScreenshot(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends NVIDIA Overlay's fixed Alt+F1 screenshot shortcut.
;
; RealManual's configurable hotkey determines which physical controller button invokes this function. The NVIDIA output shortcut itself remains Alt+F1.
; ==========================================================================================================================================================
CaptureNvidiaScreenshot(*) { ; handles the configurable realmanual screenshot hotkey
    SendEvent "!{F1}" ; sends alt+f1 to the nvidia overlay
} ; end capturenvidiascreenshot

; ==========================================================================================================================================================
; TrySetOutputKeyState(keyName, pressed)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Presses or releases one configured output key.
;
; Used for outputs that must remain held across multiple input scans rather than being sent as a short TapKey() command.
; ==========================================================================================================================================================
TrySetOutputKeyState(keyName, pressed) {
    if keyName = "" {
        return false
    } ; end blank output guard

    try {
        if pressed {
            SendEvent "{" keyName " down}"
        } else {
            SendEvent "{" keyName " up}"
        }

        return true
    } catch {
        if pressed {
            try {
                SendEvent "{" keyName " up}"
            }
        }

        return false
    } ; end protected output-state change
} ; end trysetoutputkeystate

; ==========================================================================================================================================================
; TapThrottleBlip()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Briefly holds the configured forward key for stall and engine-start effects.
; ==========================================================================================================================================================
TapThrottleBlip() {
    global forwardKey
    global throttleBlipMs

    return SendKeyForDuration(forwardKey, throttleBlipMs)
} ; end tapthrottleblip

; ==========================================================================================================================================================
; SendGearToMod(targetGear, force := false)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends a direct gear command to MW2005-HShifter.
;
; Gear model:
;   -1  = reverse
;    0  = neutral
;   1-6 = forward gears
;
; force = false:
;   suppresses a duplicate command when targetGear matches lastSentGear
;
; force = true:
;   bypasses the cache when the game may have changed gear independently or when RealManual is deliberately establishing an authoritative gear state.
;
; Returns:
;   true  = requested gear was already established or was sent successfully
;   false = target gear was invalid or the output command failed
; ==========================================================================================================================================================
SendGearToMod(targetGear, force := false) {
    global gearKeys
    global lastSentGear

    ; duplicate command suppression
    if !force && targetGear = lastSentGear {
        ; requested state is already the best-known direct gear state
        return true
    } ; end duplicate guard

    ; target validation
    if !gearKeys.Has(targetGear) {
        return false
    } ; end invalid gear guard

    ; fixed H-Shifter protocol command
    if !TapKey(gearKeys[targetGear]) {
        return false
    } ; end failed output guard

    ; only commits the cache after the output actually succeeds.
    lastSentGear := targetGear

    return true
} ; end sendgeartomod

; ==========================================================================================================================================================
; ReleaseReverseAssistQuietly()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Releases the digital reverse-assist output if RealManual currently holds it.
; ==========================================================================================================================================================
ReleaseReverseAssistQuietly() {
    global reverseAssistHeld
    global reverseKey

    if reverseAssistHeld {
        if TrySetOutputKeyState(
            reverseKey,
            false
        ) {
            reverseAssistHeld := false
        }
    } ; end reverse-assist release
} ; end releasereverseassistquietly

; ==========================================================================================================================================================
; ReleaseHeldOutputsQuietly()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Releases any game output keys that RealManual may currently be holding.
;
; Prevents stuck handbrake inputs while RealManual is not actively controlling the game.
; ==========================================================================================================================================================
ReleaseHeldOutputsQuietly() {
    global handbrakeHeld
    global handbrakeKey

    if handbrakeHeld {
        if TrySetOutputKeyState(handbrakeKey, false) {
            handbrakeHeld := false
        }
    } ; end handbrake release

    ReleaseReverseAssistQuietly()
} ; end releaseheldoutputsquietly

; ==========================================================================================================================================================
; HandleScriptExit(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Performs best-effort output cleanup when RealManual exits or reloads.
;
; Explicitly releases every gameplay output key that RealManual may hold so a key cannot remain logically pressed if the script exits during an output
; operation.
; ==========================================================================================================================================================
HandleScriptExit(*) {
    global gearKeys
    global handbrakeKey
    global forwardKey
    global reverseKey
    global shiftUpKey
    global shiftDownKey

    TrySetOutputKeyState(handbrakeKey, false)
    TrySetOutputKeyState(forwardKey, false)
    TrySetOutputKeyState(reverseKey, false)
    TrySetOutputKeyState(shiftUpKey, false)
    TrySetOutputKeyState(shiftDownKey, false)

    for _, gearKey in gearKeys {
        TrySetOutputKeyState(
            gearKey,
            false
        )
    }
} ; end handlescriptexit


; ==========================================================================================================================================================
; SECTION 12: LOW-LEVEL INPUT READERS
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; TryGetInputState(inputName, &value)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Attempts to read a configured keyboard, joystick button, or joystick axis.
;
; Unlike SafeGetKeyState(), this preserves the distinction between:
;   - a valid input that is currently released / zero
;   - an input that could not be read
;
; Returns:
;   true  = input was read successfully
;   false = input was blank, invalid, unavailable, or unreadable
; ==========================================================================================================================================================
TryGetInputState(inputName, &value) {
    value := ""

    if inputName = "" {
        return false
    } ; end blank input guard

    try {
        readValue := GetKeyState(inputName)

        if readValue = "" {
            return false
        } ; end empty result guard

        value := readValue
        return true
    } catch {
        return false
    } ; end protected read
} ; end trygetinputstate

; ==========================================================================================================================================================
; TryGetPhysicalKeyState(keyName, &pressed)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads only the physical state of a keyboard key.
;
; Unlike TryGetInputState(), synthetic SendEvent output does not count as a physical press. 
; This allows RealManual to monitor the same NFSMW shift keys it uses for output without detecting its own generated shift commands.
;
; Returns:
;   true  = physical key state was read successfully
;   false = key was blank, invalid, or unreadable
; ==========================================================================================================================================================
TryGetPhysicalKeyState(keyName, &pressed) {
    pressed := false

    if keyName = "" {
        return false
    } ; end blank key guard

    try {
        pressed := GetKeyState(
            keyName,
            "P"
        )

        return true
    } catch {
        return false
    } ; end protected physical read
} ; end trygetphysicalkeystate

; ==========================================================================================================================================================
; SafeGetKeyState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Safely reads a keyboard, joystick button, or joystick axis without allowing missing devices, invalid input names, or empty values to crash the script.
;
; Returns:
;   Actual input value when successful.
;   Fallback value when input is blank, invalid, unavailable, or unreadable.
; ==========================================================================================================================================================
SafeGetKeyState(inputName, fallback := false) {
    if TryGetInputState(inputName, &value) {
        return value
    }

    return fallback
} ; end safegetkeystate

; ==========================================================================================================================================================
; ReadClutchAxis()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the current raw clutch-axis position.
;
; For the tested Logitech setup:
;   0   = fully pressed
;   100 = fully released
;
; An unavailable clutch axis safely reports fully released.
; ==========================================================================================================================================================
ReadClutchAxis() {
    global clutchAxis

    return SafeGetKeyState(clutchAxis, 100)
} ; end readclutchaxis

; ==========================================================================================================================================================
; ReadCombinedPedalAxis()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the current raw shared gas/brake-axis position.
;
; combinedPedalCenter represents the released/resting position between the gas and brake sides of the shared axis.
;
; An unavailable combined pedal axis safely reports the resting center.
; ==========================================================================================================================================================
ReadCombinedPedalAxis() {
    global combinedPedalAxis
    global combinedPedalCenter

    return SafeGetKeyState(
        combinedPedalAxis,
        combinedPedalCenter
    )
} ; end readcombinedpedalaxis

; ==========================================================================================================================================================
; IsClutchPressed(clutchValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether a previously read clutch-axis value represents a pressed clutch.
;
; For the tested Logitech setup, clutch value decreases when pressed.
;
; Clutch pressed if clutchValue < clutchThreshold
; ==========================================================================================================================================================
IsClutchPressed(clutchValue) {
    global clutchThreshold

    return clutchValue < clutchThreshold
} ; end isclutchpressed

; ==========================================================================================================================================================
; ReadSelectedGear()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the complete physical H-pattern shifter state.
;
; Returns:
;   -2 = shifter state cannot be determined safely
;   -1 = reverse
;    0 = neutral
;   1-6 = selected forward gear
;
; Unknown is returned when:
;   - fewer than six unique forward mappings are available
;   - reverse is missing or duplicates a forward mapping
;   - any required shifter input cannot be read
;   - more than one physical gear position appears active at the same time
;
; Neutral is returned only when all seven physical gear positions can be read successfully and none is selected.
; ==========================================================================================================================================================
ReadSelectedGear() {
    global gearButtons
    global reverseButton
    global hPatternMappingValid

    if !hPatternMappingValid {
        return -2
    } ; end mapping-validity guard

    selectedGear := 0
    activePositionCount := 0

    for buttonName, gearNumber in gearButtons {
        if !TryGetInputState(buttonName, &buttonPressed) {
            return -2
        } ; end unreadable forward input

        if buttonPressed {
            selectedGear := gearNumber
            activePositionCount++
        } ; end active forward position
    } ; end forward gear scan

    if !TryGetInputState(reverseButton, &reversePressed) {
        return -2
    } ; end unreadable reverse input

    if reversePressed {
        selectedGear := -1
        activePositionCount++
    } ; end reverse position

    if activePositionCount > 1 {
        return -2
    } ; end ambiguous physical state

    return selectedGear
} ; end readselectedgear

; ==========================================================================================================================================================
; IsBrakeAxisPastThreshold(pedalValue, threshold)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Tests a previously read combined gas/brake-axis value against a brake-side threshold.
;
; Higher-level helpers define what each threshold means.
; ==========================================================================================================================================================
IsBrakeAxisPastThreshold(pedalValue, threshold) {
    global brakeAxisIncreasesWhenPressed

    if brakeAxisIncreasesWhenPressed {
        return pedalValue > threshold
    } else {
        return pedalValue < threshold
    } ; end axis direction branch
} ; end isbrakeaxispastthreshold

; ==========================================================================================================================================================
; IsBrakePedalActive(pedalValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether a previously read combined pedal value represents meaningful brake input.
; ==========================================================================================================================================================
IsBrakePedalActive(pedalValue) {
    global brakeActiveThreshold

    return IsBrakeAxisPastThreshold(pedalValue, brakeActiveThreshold)
} ; end isbrakepedalactive

; ==========================================================================================================================================================
; IsBrakePressedForSequentialReset(pedalValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether a previously read combined pedal value represents braking hard enough to count toward the sequential brake-hold gear-reset heuristic.
; ==========================================================================================================================================================
IsBrakePressedForSequentialReset(pedalValue) {
    global brakeResetThreshold

    return IsBrakeAxisPastThreshold(pedalValue, brakeResetThreshold)
} ; end isbrakepressedforsequentialreset

; ==========================================================================================================================================================
; IsShifterHandbrakeActive()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the currently active shifter-handbrake slot.
;
; The handbrake source is independent from sequential-shifter arbitration.
; HandleSequentialTransmission() separately uses the cached active shifter-handbrake conflict state to decide whether the sequential pair must
; be suppressed.
;
; After being disarmed, the handbrake must observe its OWN configured slot successfully released before it can engage again.
;
; Returns:
;   true  = active shifter-handbrake slot is selected while armed
;   false = source is inactive, disarmed, released, or unreadable
; ==========================================================================================================================================================
IsShifterHandbrakeActive() {
    global enableShifterHandbrake
    global transmissionIsSequential

    global shifterHandbrakeArmed
    global shifterHandbrakeButton

    if !enableShifterHandbrake || !transmissionIsSequential {
        return false
    } ; end inactive-mode guard

    if !TryGetInputState(
        shifterHandbrakeButton,
        &handbrakeSlotPressed
    ) {
        shifterHandbrakeArmed := false
        return false
    } ; end unreadable-input guard

    if !shifterHandbrakeArmed {
        if !handbrakeSlotPressed {
            shifterHandbrakeArmed := true
        } ; end released-state check

        return false
    } ; end re-arm gate

    return handbrakeSlotPressed
} ; end isshifterhandbrakeactive

; ==========================================================================================================================================================
; IsAnalogHandbrakeActive()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the optional physical handbrake axis.
;
; Allows physical handbrake and shifter handbrake to coexist.
;
; Returns:
;   true  = analog handbrake is pulled past threshold
;   false = analog handbrake is released, blank, invalid, or disconnected
; ==========================================================================================================================================================
IsAnalogHandbrakeActive() {
    global handbrakeAxis
    global handbrakeThreshold

    return SafeGetKeyState(handbrakeAxis, 0) > handbrakeThreshold
} ; end isanaloghandbrakeactive

; ==========================================================================================================================================================
; ReadClutchReleasePercent(clutchValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the clutch release position from a previously read raw clutch value:
;   0   = fully pressed
;   100 = fully released
; ==========================================================================================================================================================
ReadClutchReleasePercent(clutchValue) {
    return Max(0, Min(100, clutchValue))
} ; end readclutchreleasepercent

; ==========================================================================================================================================================
; ReadThrottlePercentForStall(pedalValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Estimates throttle percentage from a previously read shared gas/brake-axis value.
;
; If brake increases the axis value:
;   brake moves above center
;   gas moves below center
;
; If brake decreases the axis value, those directions are reversed.
; ==========================================================================================================================================================
ReadThrottlePercentForStall(pedalValue) {
    global brakeAxisIncreasesWhenPressed
    global combinedPedalCenter

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


; ==========================================================================================================================================================
; IsBrakePressedForReverseAssist(pedalValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether a previously read combined pedal value has passed the raw brake-axis threshold required to engage reverse assist.
; ==========================================================================================================================================================
IsBrakePressedForReverseAssist(pedalValue) {
    global engageBrakeThreshold

    return IsBrakeAxisPastThreshold(pedalValue, engageBrakeThreshold)
} ; end isbrakepressedforreverseassist

; ==========================================================================================================================================================
; IsFirstGearSelectedForStall(combinedPedalValue, selectedGear := -2)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns true when RealManual currently believes the game is in first gear.
;
; virtualGear is the authoritative tracked game gear.
;
; In H-pattern mode, an unknown or reverse physical shifter state prevents
; first-gear stall detection for that scan.
; ==========================================================================================================================================================
IsFirstGearSelectedForStall(combinedPedalValue, selectedGear := -2) {
    global transmissionIsSequential
    global virtualGear
    global lastSentGear

    ; reverse is never treated as first gear.
    if lastSentGear = -1 && IsBrakePedalActive(combinedPedalValue) {
        return false
    }

    ; H-pattern unknown (-2) and reverse (-1) are not safe first-gear states.
    if !transmissionIsSequential && selectedGear < 0 {
        return false
    }

    return virtualGear = 1
} ; end isfirstgearselectedforstall

; ==========================================================================================================================================================
; IsPhysicalShifterNeutral()
; ==========================================================================================================================================================
IsPhysicalShifterNeutral() {
    return ReadSelectedGear() = 0
} ; end isphysicalshifterneutral

; ==========================================================================================================================================================
; IsClutchFullyPressedForRestart()
; ==========================================================================================================================================================
IsClutchFullyPressedForRestart(clutchValue) {
    global restartClutchThreshold

    return ReadClutchReleasePercent(clutchValue) <= restartClutchThreshold
} ; end isclutchfullypressedforrestart


; ==========================================================================================================================================================
; SECTION 13: NOTIFICATIONS, STATUS, VALIDATION, AND LOGGING
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; BoolText(value)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts a boolean value into user-readable text.
;
; true  -> Enabled
; false -> Disabled
;
; Used by live mode status messages.
; ==========================================================================================================================================================
BoolText(value) {
    return value ? "Enabled" : "Disabled"
} ; end booltext

; ==========================================================================================================================================================
; ModeText()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts the current transmission mode into user-readable text.
; ==========================================================================================================================================================
ModeText() {
    global transmissionIsSequential

    return transmissionIsSequential ? "Sequential" : "H-Pattern"
} ; end modetext

; ==========================================================================================================================================================
; ClearStatusToolTip()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears RealManual's normal status tooltip without affecting the persistent stopwatch tooltip, which uses a separate tooltip ID.
; ==========================================================================================================================================================
ClearStatusToolTip() {
    ToolTip(,,, 1)
} ; end clearstatustooltip

; ==========================================================================================================================================================
; ShowToolTipMessage(message)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Displays an optional tooltip based on configuration.
;
; All RealManual tooltip messages should go through this function instead of calling ToolTip() directly. 
; This allows disabling informational popups globally without changing script behavior.
; ==========================================================================================================================================================
ShowToolTipMessage(message) {
    global enableToolTips
    global toolTipDurationMs

    if !enableToolTips {
        return
    } ; end enabled check

    ; cancels any older pending clear so a previous message cannot erase the newly displayed status prematurely.
    SetTimer(ClearStatusToolTip, 0)
    ToolTip(message,,, 1)
    SetTimer(ClearStatusToolTip, -toolTipDurationMs)
} ; end showtooltipmessage

; ==========================================================================================================================================================
; ShowLiveModeStatus(changedSetting)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Shows a short tooltip after a live hotkey changes a mode setting.
;
; Live hotkeys change the running script state only. They do not write back to config.ini. Reloading RealManual restores the saved config file values.
; ==========================================================================================================================================================
ShowLiveModeStatus(changedSetting) {
    global requireClutch, clutchActsAsNeutral
    global invertSequentialShifter, maxForwardGear
    global enableShifterHandbrake ; shifter handbrake
    global toggleTransmissionModeButton
    global toggleClutchRequiredButton, toggleClutchNeutralButton
    global toggleSequentialShifterInvertButton
    global toggleMaxForwardGearButton, toggleShifterHandbrakeButton ; feature
    global statsShiftsButton, statsStallsButton, statsRaceRestartsButton, raceRestartButton ; stats
    global enableStalling, toggleStallingButton ; stalling
    global stopwatchButton, stopwatchLapButton, stopwatchClearButton ; stopwatch
    global helpButton

    message := changedSetting
    message .= "`nTransmission: " ModeText() " [" toggleTransmissionModeButton "]"
    message .= "`nClutch Required: " BoolText(requireClutch) " [" toggleClutchRequiredButton "]"
    message .= "`nClutch -> Neutral: " BoolText(clutchActsAsNeutral) " [" toggleClutchNeutralButton "]"
    message .= "`nSequential Shifter Invert: " BoolText(invertSequentialShifter) " [" toggleSequentialShifterInvertButton "]"
    message .= "`nMax Gear: " maxForwardGear " [" toggleMaxForwardGearButton "]"
    message .= "`nShifter Handbrake: " BoolText(enableShifterHandbrake) " [" toggleShifterHandbrakeButton "]"
    message .= "`nStalling: " BoolText(enableStalling) " [" toggleStallingButton "]"
    message .= "`nStopwatch Start/Pause: [" stopwatchButton "]"
    message .= "`nStopwatch Lap: [" stopwatchLapButton "]"
    message .= "`nStopwatch Clear: [" stopwatchClearButton "]"
    message .= "`nStats - Shifts: [" statsShiftsButton "]"
    message .= "`nStats - Stalls: [" statsStallsButton "]"
    message .= "`nStats - Race Restarts: [" statsRaceRestartsButton "]"
    message .= "`nRecord Race Restart: [" raceRestartButton "]"
    message .= "`nHelp: [" helpButton "]"

    ShowToolTipMessage(message) ; displays optional tooltip message
} ; end showlivemodestatus

; ==========================================================================================================================================================
; ShowStartupInfo()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Displays a compact startup summary after config.ini has loaded.
;
; Reports runtime behavior settings that meaningfully change RealManual's transmission model. 
; Detailed configuration and hardware status are written separately to the validation log.
; ==========================================================================================================================================================
ShowStartupInfo() {
    global appName, appVersion
    global transmissionIsSequential, requireClutch, clutchActsAsNeutral, enableStalling
    global writeStartupLog

    modeText := transmissionIsSequential ? "Sequential" : "H-Pattern"
    clutchText := requireClutch ? "Enabled" : "Disabled"
    clutchNeutralText := clutchActsAsNeutral ? "Enabled" : "Disabled"
    stallingText := enableStalling ? "Enabled" : "Disabled"

    title := appName " " appVersion " - Config Loaded"

    compactMessage := "Mode: " modeText
    compactMessage .= "`nClutch Required: " clutchText
    compactMessage .= "`nClutch -> Neutral: " clutchNeutralText
    compactMessage .= "`nStalling: " stallingText

    validationText := BuildValidationText()

    if writeStartupLog {
        WriteStartupLogFile(title, compactMessage, validationText)
    } ; end startup log write

    TrayTip compactMessage, title, 1
} ; end showstartupinfo

; ==========================================================================================================================================================
; DetectInputHardware()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Checks whether a configured input can currently be read from physical
; hardware.
; ==========================================================================================================================================================
DetectInputHardware(inputName) {
    return TryGetInputState(inputName, &value)
} ; end detectinputhardware

; ==========================================================================================================================================================
; AddValidationWarning(&text, &warningText, &warningCount, detail, summary := "")
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Adds one warning to the detailed validation report and final warning summary.
;
; summary:
;   blank    = reuse detail in the final warning summary
;   nonblank = use the supplied shorter summary instead
; ==========================================================================================================================================================
AddValidationWarning(&text, &warningText, &warningCount, detail, summary := "") {
    text .= "[WARN] " detail "`n" ; adds the detailed warning to its current validation section

    if summary = "" { ; uses the detailed text as the summary when no alternate wording was supplied
        summary := detail ; avoids forcing callers to provide the same warning twice
    } ; end default-summary branch

    warningText .= summary "`n" ; adds the warning to the final condensed warning section
    warningCount++
} ; end addvalidationwarning

; ==========================================================================================================================================================
; BuildValidationText()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Creates the startup configuration, relationship, hotkey, and hardware report.
;
; Configuration Validation:
;   checks required settings for missing or blank values
;   validates boolean syntax
;   validates numeric syntax and configured sanity ranges
;
; Configuration Relationships:
;   checks whether individually valid settings make sense together, such as
;   clutch and brake threshold ordering.
;
; Hotkey Validation:
;   detects duplicate configurable hotkeys
;   detects conflicts with fixed MW2005-HShifter protocol keys
;
; Hardware Detection:
;   tests configured physical joystick axes/buttons to determine whether Windows
;   currently exposes them to AutoHotkey.
;
; Fixed MW2005-HShifter protocol keys:
;   0   = reverse
;   N   = neutral
;   1-6 = forward gears
;
; These protocol keys are hardcoded by RealManual and are not configurable.
; ==========================================================================================================================================================
BuildValidationText() {
    global configFile
    global dynamicHotkeyRegistrationResults
    global numericConfigRules, booleanConfigRules

    configExists := FileExist(configFile)
    missingSentinel := "__REALMANUAL_MISSING_CONFIG_VALUE__"

    configuredValues := Map()
    validatedInts := Map()
    validatedBools := Map()

    warningText := ""
    warningCount := 0
    text := ""

    text .= "Configuration Validation:`n`n"

    ; Config file
    if configExists {
        text .= "[OK] Config file found`n"
    } else {
        AddValidationWarning(
            &text,
            &warningText,
            &warningCount,
            "config.ini missing"
        )
    } ; end config file validation

    configChecks := [
        ; General
        ["General", "WriteStartupLog"],
        ["General", "EnableToolTips"],
        ["General", "ToolTipDurationMs"],

        ; General hotkeys
        ["Hotkeys", "HelpButton"],
        ["Hotkeys", "ResetButton"],
        ["Hotkeys", "PauseButton"],
        ["Hotkeys", "ReloadButton"],

        ; Transmission hotkeys
        ["Hotkeys", "ToggleTransmissionModeButton"],
        ["Hotkeys", "ToggleSequentialShifterInvertButton"],
        ["Hotkeys", "ToggleMaxForwardGearButton"],

        ; Clutch hotkeys
        ["Hotkeys", "ToggleClutchRequiredButton"],
        ["Hotkeys", "ToggleClutchNeutralButton"],

        ; Shifter handbrake hotkeys
        ["Hotkeys", "ToggleShifterHandbrakeButton"],

        ; Stall simulation hotkey
        ["Hotkeys", "ToggleStallingButton"],

        ; Stopwatch hotkeys
        ["Hotkeys", "StopwatchButton"],
        ["Hotkeys", "StopwatchLapButton"],
        ["Hotkeys", "StopwatchClearButton"],

        ; Ignition hotkey
        ["Hotkeys", "IgnitionButton"],

        ; Stats hotkeys
        ["Hotkeys", "StatsShiftsButton"],
        ["Hotkeys", "StatsStallsButton"],
        ["Hotkeys", "StatsRaceRestartsButton"],
        ["Hotkeys", "RaceRestartButton"],

        ; Transmission
        ["Transmission", "StartInSequentialMode"],
        ["Transmission", "MaxForwardGear"],

        ; General timing
        ["Timing", "KeyHoldMs"],
        ["Timing", "ScanIntervalMs"],

        ; Clutch
        ["Clutch", "RequireClutch"],
        ["Clutch", "ClutchActsAsNeutral"],
        ["Clutch", "ClutchAxis"],
        ["Clutch", "ClutchThreshold"],

        ; NFSMW game-key bindings
        ["GameKeys", "ForwardKey"],
        ["GameKeys", "ReverseKey"],
        ["GameKeys", "HandbrakeKey"],
        ["GameKeys", "ShiftUpKey"],
        ["GameKeys", "ShiftDownKey"],

        ; H-pattern shifter
        ["HPattern", "Gear1Button"],
        ["HPattern", "Gear2Button"],
        ["HPattern", "Gear3Button"],
        ["HPattern", "Gear4Button"],
        ["HPattern", "Gear5Button"],
        ["HPattern", "Gear6Button"],
        ["HPattern", "ReverseButton"],

        ; Handbrake
        ["Handbrake", "HandbrakeAxis"],
        ["Handbrake", "HandbrakeThreshold"],
        ["Handbrake", "EnableShifterHandbrake"],
        ["Handbrake", "ShifterHandbrakeButton"],

        ; Sequential transmission
        ["Sequential", "InvertSequentialShifter"],
        ["Sequential", "SequentialUpshiftButton"],
        ["Sequential", "SequentialDownshiftButton"],
        ["Sequential", "EnableBrakeHoldGearReset"],
        ["Sequential", "BrakeHoldResetMs"],
        ["Sequential", "BrakeResetThreshold"],
        ["Sequential", "PaddleUpshiftButton"],
        ["Sequential", "PaddleDownshiftButton"],
        ["Sequential", "QueuedShiftDelayMs"],

        ; Combined pedals
        ["Pedals", "CombinedPedalAxis"],
        ["Pedals", "CombinedPedalCenter"],
        ["Pedals", "BrakeAxisIncreasesWhenPressed"],
        ["Pedals", "BrakeActiveThreshold"],

        ; Stall / engine simulation
        ["Stalling", "EnableStalling"],
        ["Stalling", "ClutchReleaseThreshold"],
        ["Stalling", "ThrottleThreshold"],
        ["Stalling", "RestartClutchThreshold"],
        ["Stalling", "NeutralResendMs"],
        ["Stalling", "ThrottleBlipMs"],
        ["Stalling", "NoInputStallDelayMs"],
        ["Stalling", "BrakeResetStallGraceMs"],

        ; Reverse assist
        ["ReverseAssist", "EnableReverseAssist"],
        ["ReverseAssist", "EngageBrakeThreshold"],

        ; Stopwatch
        ["Stopwatch", "StopwatchRefreshMs"],
        ["Stopwatch", "StopwatchMaxLines"],

        ; Statistics
        ["Statistics", "TrackShifts"],
        ["Statistics", "TrackStalls"],
        ["Statistics", "TrackRaceRestarts"],
        ["Statistics", "ClearAllTimeOnStartup"]
    ]

    if configExists {
        for check in configChecks {
            section := check[1]
            key := check[2]

            ruleKey := ConfigRuleKey(section, key)
            rawValue := IniRead(configFile, section, key, missingSentinel)

            ; Missing / Blank
            if rawValue = missingSentinel || Trim(rawValue) = "" {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    "[" section "] " key " missing"
                )

                continue
            } ; end missing value guard

            ; Preserve the configured value so later validation stages do not need to read config.ini again.
            configuredValues[ruleKey] := Trim(rawValue)

            ; Numeric Settings
            if numericConfigRules.Has(ruleKey) {
                range := numericConfigRules[ruleKey]
                minimum := range[1]
                maximum := range[2]

                if !TryParseConfigInt(rawValue, &parsedValue) {
                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        "[" section "] " key
                            . " invalid integer: '" rawValue "'"
                    )

                    continue
                } ; end integer syntax validation

                if parsedValue < minimum || parsedValue > maximum {
                    detail :=
                        "[" section "] " key
                        . " = " parsedValue
                        . " outside valid range "
                        . minimum "-" maximum

                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        detail
                    )

                    continue
                } ; end integer range validation

                validatedInts[ruleKey] := parsedValue

                text .= "[OK] [" section "] " key
                    . " = " parsedValue
                    . " (valid range " minimum "-" maximum ")`n"

                continue
            } ; end numeric setting validation

            ; Boolean Settings
            if booleanConfigRules.Has(ruleKey) {
                if !TryParseConfigBool(rawValue, &parsedBool) {
                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        "[" section "] " key
                            . " must be 0 or 1; got '" rawValue "'"
                    )

                    continue
                } ; end boolean validation

                validatedBools[ruleKey] := parsedBool

                text .= "[OK] [" section "] " key
                    . " = " Trim(rawValue) "`n"

                continue
            } ; end boolean setting validation

            ; Text / Mapping Settings
            text .= "[OK] [" section "] " key " configured`n"

        } ; end config check loop
    } ; end config-presence branch

    ; Configuration Relationship Validation
    text .= "`nConfiguration Relationships:`n`n"

    ; Combined Pedal / Brake Threshold Relationships
    pedalCenterKey := ConfigRuleKey("Pedals", "CombinedPedalCenter")
    activeBrakeKey := ConfigRuleKey("Pedals", "BrakeActiveThreshold")
    hardBrakeKey := ConfigRuleKey("Sequential", "BrakeResetThreshold")
    engageBrakeThresholdKey := ConfigRuleKey("ReverseAssist", "EngageBrakeThreshold")
    brakeDirectionKey := ConfigRuleKey("Pedals", "BrakeAxisIncreasesWhenPressed")

    if validatedInts.Has(pedalCenterKey) && validatedBools.Has(brakeDirectionKey) {
        pedalCenter := validatedInts[pedalCenterKey]
        brakeIncreases := validatedBools[brakeDirectionKey]

        ; Normal Brake Threshold Ordering
        if validatedInts.Has(activeBrakeKey) && validatedInts.Has(hardBrakeKey) {
            activeBrakeThreshold := validatedInts[activeBrakeKey]
            hardBrakeThreshold := validatedInts[hardBrakeKey]

            if brakeIncreases {
                brakeThresholdOrderValid :=
                    pedalCenter < activeBrakeThreshold
                    && activeBrakeThreshold < hardBrakeThreshold
            } else {
                brakeThresholdOrderValid :=
                    pedalCenter > activeBrakeThreshold
                    && activeBrakeThreshold > hardBrakeThreshold
            } ; end brake-axis direction branch

            if brakeThresholdOrderValid {
                text .= "[OK] Combined pedal center and brake thresholds ordered correctly`n"
            } else {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    "CombinedPedalCenter, BrakeActiveThreshold, and "
                        . "BrakeResetThreshold are not ordered correctly for the configured "
                        . "brake-axis direction",
                    "CombinedPedalCenter / BrakeActiveThreshold / "
                        . "BrakeResetThreshold ordering invalid"
                )
            } ; end normal brake relationship result
        } ; end normal brake-threshold validation

        ; Reverse Assist Brake Threshold
        if validatedInts.Has(engageBrakeThresholdKey) {
            engageBrakeThreshold := validatedInts[engageBrakeThresholdKey]

            if brakeIncreases {
                engageBrakeThresholdValid := engageBrakeThreshold > pedalCenter
            } else {
                engageBrakeThresholdValid := engageBrakeThreshold < pedalCenter
            }

            if engageBrakeThresholdValid {
                text .= "[OK] Reverse-assist engagement threshold is on the brake side of the combined axis`n"
            } else {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    "ReverseAssist.EngageBrakeThreshold must be on the brake side of CombinedPedalCenter",
                    "ReverseAssist.EngageBrakeThreshold is not on the brake side of CombinedPedalCenter"
                )
            } ; end reverse-assist relationship result
        } ; end reverse-assist threshold validation

    } ; end combined-pedal brake relationship validation

    ; Clutch threshold relationships
    clutchThresholdKey := ConfigRuleKey("Clutch", "ClutchThreshold")

    restartThresholdKey := ConfigRuleKey("Stalling", "RestartClutchThreshold")

    clutchReleaseKey := ConfigRuleKey("Stalling", "ClutchReleaseThreshold")

    if validatedInts.Has(clutchThresholdKey) {
        clutchPressThreshold := validatedInts[clutchThresholdKey]

        ; Restart clutch threshold
        if validatedInts.Has(restartThresholdKey) {
            restartThreshold := validatedInts[restartThresholdKey]

            if restartThreshold <= clutchPressThreshold {
                text .= "[OK] Restart clutch threshold is within clutch-pressed range`n"
            } else {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    "RestartClutchThreshold should not exceed ClutchThreshold",
                    "RestartClutchThreshold exceeds ClutchThreshold"
                )
            } ; end restart clutch relationship
        }

        ; Stall clutch-release threshold
        if validatedInts.Has(clutchReleaseKey) {
            clutchReleaseThreshold := validatedInts[clutchReleaseKey]

            if clutchReleaseThreshold > clutchPressThreshold {
                text .= "[OK] Clutch release threshold is above clutch-pressed threshold`n"
            } else {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    "ClutchReleaseThreshold should be greater than ClutchThreshold",
                    "ClutchReleaseThreshold must exceed ClutchThreshold"
                )
            } ; end clutch-release relationship
        }
    } ; end clutch threshold relationships

    ; Physical mapping relationships
    mappingGroups := [
        [
            "H-pattern gear/reverse",
            [
                ["Gear 1", ConfigRuleKey("HPattern", "Gear1Button")],
                ["Gear 2", ConfigRuleKey("HPattern", "Gear2Button")],
                ["Gear 3", ConfigRuleKey("HPattern", "Gear3Button")],
                ["Gear 4", ConfigRuleKey("HPattern", "Gear4Button")],
                ["Gear 5", ConfigRuleKey("HPattern", "Gear5Button")],
                ["Gear 6", ConfigRuleKey("HPattern", "Gear6Button")],
                ["Reverse", ConfigRuleKey("HPattern", "ReverseButton")]
            ]
        ],
        [
            "Sequential shifter",
            [
                ["Upshift", ConfigRuleKey("Sequential", "SequentialUpshiftButton")],
                ["Downshift", ConfigRuleKey("Sequential", "SequentialDownshiftButton")]
            ]
        ],
        [
            "Paddle synchronization",
            [
                ["Paddle upshift", ConfigRuleKey("Sequential", "PaddleUpshiftButton")],
                ["Paddle downshift", ConfigRuleKey("Sequential", "PaddleDownshiftButton")]
            ]
        ]
    ]

    if configExists {
        for group in mappingGroups {
            groupName := group[1]
            mappings := group[2]

            seenInputs := Map()
            duplicateFound := false
            configuredCount := 0

            for mapping in mappings {
                label := mapping[1]
                mappingKey := mapping[2]

                if !configuredValues.Has(mappingKey) {
                    continue
                } ; end missing mapping guard

                inputName := configuredValues[mappingKey]
                configuredCount++

                normalizedInput := StrLower(inputName)

                if seenInputs.Has(normalizedInput) {
                    previousLabel := seenInputs[normalizedInput]

                    detail :=
                        groupName ": "
                        . previousLabel " and " label
                        . " share input [" inputName "]"

                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        detail
                    )

                    duplicateFound := true
                } else {
                    seenInputs[normalizedInput] := label
                } ; end duplicate check
            } ; end mapping loop

            if configuredCount = mappings.Length && !duplicateFound {
                text .= "[OK] " groupName
                    . " mappings are distinct`n"
            }
        } ; end mapping group loop
    } ; end physical mapping relationship validation

    ; Hotkey Validation
    text .= "`nHotkey Validation:`n`n"

    if configExists {
        for result in dynamicHotkeyRegistrationResults {

            switch result.status {
                ; Registered
                case "registered":
                    text .= "[OK] "
                        . result.label
                        . " hotkey ["
                        . result.hotkey
                        . "] registered`n"

                ; Reserved MW2005-HShifter Key
                case "reserved":
                    detail :=
                        "[Hotkeys] "
                        . result.setting
                        . " ["
                        . result.hotkey
                        . "] conflicts with "
                        . result.detail
                        . "; hotkey not registered"

                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        detail
                    )

                ; Duplicate
                case "duplicate":
                    detail :=
                        "Hotkey ["
                        . result.hotkey
                        . "] assigned to both "
                        . result.detail
                        . " and "
                        . result.label

                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        detail
                    )

                ; Registration Failure
                case "failed":
                    detail :=
                        "[Hotkeys] "
                        . result.setting
                        . " could not register ["
                        . result.hotkey
                        . "]"

                    if result.detail != "" {
                        detail .= ": " result.detail
                    }

                    AddValidationWarning(
                        &text,
                        &warningText,
                        &warningCount,
                        detail
                    )
            }

        } ; end registration-result loop
    } ; end hotkey validation

    ; Reserved MW2005-HShifter Binding Conflicts
    manualBindingChecks := [
        ; Axes / physical inputs
        ["Clutch", "ClutchAxis"],
        ["Pedals", "CombinedPedalAxis"],
        ["Handbrake", "HandbrakeAxis"],

        ; NFSMW game keys
        ["GameKeys", "ForwardKey"],
        ["GameKeys", "ReverseKey"],
        ["GameKeys", "HandbrakeKey"],
        ["GameKeys", "ShiftUpKey"],
        ["GameKeys", "ShiftDownKey"],

        ; H-pattern shifter
        ["HPattern", "Gear1Button"],
        ["HPattern", "Gear2Button"],
        ["HPattern", "Gear3Button"],
        ["HPattern", "Gear4Button"],
        ["HPattern", "Gear5Button"],
        ["HPattern", "Gear6Button"],
        ["HPattern", "ReverseButton"],

        ; Sequential shifter
        ["Sequential", "SequentialUpshiftButton"],
        ["Sequential", "SequentialDownshiftButton"],

        ; Paddle synchronization
        ["Sequential", "PaddleUpshiftButton"],
        ["Sequential", "PaddleDownshiftButton"],

        ; Shifter handbrake
        ["Handbrake", "ShifterHandbrakeButton"]
    ]

    if configExists {
        for bindingCheck in manualBindingChecks {

            sectionName := bindingCheck[1]
            settingName := bindingCheck[2]

            settingKey := ConfigRuleKey(sectionName, settingName)

            ; Missing and blank values were already handled by the normal configuration-validation pass.
            if !configuredValues.Has(settingKey) {
                continue
            } ; end missing binding

            configuredBinding := configuredValues[settingKey]
            reservedPurpose := GetReservedProtocolConflict(configuredBinding)

            if reservedPurpose = "" {
                continue
            } ; end valid user binding

            detail :=
                "["
                . sectionName
                . "] "
                . settingName
                . " ["
                . configuredBinding
                . "] conflicts with "
                . reservedPurpose
                . "; runtime binding disabled"

            AddValidationWarning(
                &text,
                &warningText,
                &warningCount,
                detail
            )
        } ; end manual binding validation
    } ; end reserved binding validation

    ; Hardware Detection
    text .= "`nHardware Detection:`n`n"

    if configExists {
        ; These axes are not part of the grouped button mappings, so they are added directly.
        hardwareChecks := [
            ["Clutch axis", ConfigRuleKey("Clutch", "ClutchAxis")],
            ["Handbrake axis", ConfigRuleKey("Handbrake", "HandbrakeAxis")],
            ["Combined pedal axis", ConfigRuleKey("Pedals", "CombinedPedalAxis")],
            ["Shifter handbrake", ConfigRuleKey("Handbrake", "ShifterHandbrakeButton")]
        ]

        ; Reuse the physical button mappings already defined for relationship validation instead of defining the same mappings again.
        for group in mappingGroups {
            groupName := group[1]
            mappings := group[2]

            for mapping in mappings {
                mappingLabel := mapping[1]
                mappingKey := mapping[2]

                hardwareChecks.Push([
                    groupName " - " mappingLabel,
                    mappingKey
                ])
            } ; end mapping loop
        } ; end mapping group loop

        ; Test every configured physical input against Windows / AutoHotkey.
        for hardwareCheck in hardwareChecks {
            label := hardwareCheck[1]
            inputKey := hardwareCheck[2]

            if !configuredValues.Has(inputKey) {
                continue
            } ; end missing mapping guard

            inputName := configuredValues[inputKey]

            ; Reserved H-Shifter bindings were already reported above and have been disabled at runtime.
            if GetReservedProtocolConflict(inputName) != "" {
                continue
            }

            if DetectInputHardware(inputName) {
                text .= "[OK] " label " detected: " inputName "`n"
            } else {
                AddValidationWarning(
                    &text,
                    &warningText,
                    &warningCount,
                    label " not detected: " inputName
                )
            } ; end hardware detection result
        } ; end hardware detection loop

    } ; end hardware detection config branch

    ; Summary
    if warningCount = 0 {
        text .= "`nReady."
    } else {
        text .= "`n[WARNING]`n"
        text .= warningText
    } ; end warning summary

    return text
} ; end buildvalidationtext

; ==========================================================================================================================================================
; WriteStartupLogFile(title, compactMessage, validationText)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Writes startup_log.txt beside RealManual.ahk.
;
; Log includes:
;   timestamp
;   app/version title
;   active mode summary
;   validation report
;
; This file is for troubleshooting.
; ==========================================================================================================================================================
WriteStartupLogFile(title, compactMessage, validationText) {
    logFile := A_ScriptDir "\startup_log.txt"

    log := ""
    log .= "==================================================`n"
    log .= "RealManual Startup Log`n"
    log .= "==================================================`n`n"
    log .= "Generated: " A_Now "`n`n"
    log .= title "`n`n"
    log .= compactMessage "`n`n"
    log .= "Validation:`n`n"
    log .= validationText "`n`n"
    log .= "==================================================`n"
    log .= "End of Log`n"
    log .= "==================================================`n"

    try {
        if FileExist(logFile) {
            FileDelete(logFile)
        }

        FileAppend(log, logFile, "UTF-8")
        return true
    } catch {
        return false
    }
} ; end writestartuplogfile

; ==========================================================================================================================================================
; OpenValidationLog(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Opens startup_log.txt from the tray menu.
; ==========================================================================================================================================================
OpenValidationLog(*) {
    logFile := A_ScriptDir "\startup_log.txt"

    if !FileExist(logFile) {
        MsgBox("startup_log.txt was not found.")
        return
    }

    try {
        Run(logFile)
    } catch {
        MsgBox("startup_log.txt could not be opened.")
    }
} ; end openvalidationlog


; ==========================================================================================================================================================
; SECTION 14: STATISTICS & SHARED OVERLAY LAYOUT
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; ReadStatCount(section, key)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads one non-negative count from stats.txt.
; Missing or malformed values safely become zero.
; ==========================================================================================================================================================
ReadStatCount(section, key) {
    global statsFile

    try {
        rawValue := IniRead(
            statsFile,
            section,
            key,
            "0"
        )

        if TryParseConfigInt(rawValue, &parsedValue) {
            return parsedValue
        }
    }

    return 0
} ; end readstatcount

; ==========================================================================================================================================================
; SaveStatCount(section, key, value)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Persists one statistics value to stats.txt.
;
; Callers use this only when that specific counter has actually changed.
; This avoids rewriting all session/all-time statistics after every event.
;
; Examples:
;   SaveStatCount("Session", "Shifts", sessionShiftCount)
;
; Returns:
;   true  = value written successfully
;   false = stats.txt could not be updated
; ==========================================================================================================================================================
SaveStatCount(section, key, value) {
    global statsFile

    try {
        IniWrite(
            value,
            statsFile,
            section,
            key
        )

        return true
    } catch {
        return false
    }
} ; end savestatcount

; ==========================================================================================================================================================
; InitializeStats()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Loads the persistent statistics state from stats.txt.
;
; Session statistics belong to one NFSMW speed.exe process and remain persisted so reloading RealManual during the same game process does not lose them.
;
; The NFSMW process tracker later decides whether the stored session should be:
;   resumed
;   finalized into AllTime
;   replaced by a new session
;
; A Session block with ProcessPid=0 is considered inactive and must contain zero counters.
; ==========================================================================================================================================================
InitializeStats() {
    global sessionProcessPid

    global sessionShiftCount
    global sessionStallCount
    global sessionRaceRestartCount

    global allTimeShiftCount
    global allTimeStallCount
    global allTimeRaceRestartCount

    sessionProcessPid := ReadStatCount("Session", "ProcessPid")

    sessionShiftCount := ReadStatCount("Session", "Shifts")
    sessionStallCount := ReadStatCount("Session", "Stalls")
    sessionRaceRestartCount := ReadStatCount("Session", "RaceRestarts")

    allTimeShiftCount := ReadStatCount("AllTime", "Shifts")
    allTimeStallCount := ReadStatCount("AllTime", "Stalls")
    allTimeRaceRestartCount := ReadStatCount("AllTime", "RaceRestarts")

    if sessionProcessPid = 0
        && (
            sessionShiftCount != 0
            || sessionStallCount != 0
            || sessionRaceRestartCount != 0
        ) {

        sessionShiftCount := 0
        sessionStallCount := 0
        sessionRaceRestartCount := 0

        SaveStatCount("Session", "Shifts", 0)
        SaveStatCount("Session", "Stalls", 0)
        SaveStatCount("Session", "RaceRestarts", 0)
    } ; end inactive-session normalization
} ; end initializestats

; ==========================================================================================================================================================
; ApplyStatisticsStartupOptions()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Applies one-shot statistics maintenance options after NFSMW session ownership has been synchronized.
; ==========================================================================================================================================================
ApplyStatisticsStartupOptions() {
    global configFile
    global clearAllTimeOnStartup

    global allTimeShiftCount
    global allTimeStallCount
    global allTimeRaceRestartCount

    if !clearAllTimeOnStartup {
        return
    } ; end no-clear guard

    allTimeShiftCount := 0
    allTimeStallCount := 0
    allTimeRaceRestartCount := 0

    SaveStatCount("AllTime", "Shifts", 0)
    SaveStatCount("AllTime", "Stalls", 0)
    SaveStatCount("AllTime", "RaceRestarts", 0)

    try {
        IniWrite("0", configFile, "Statistics", "ClearAllTimeOnStartup")
    }
} ; end applystatisticsstartupoptions

; ==========================================================================================================================================================
; StartStatsSession(processPid)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Begins a new statistics session owned by one NFSMW process.
;
; Every new game process starts with zero Session counters. AllTime remains untouched until this session is finalized.
; ==========================================================================================================================================================
StartStatsSession(processPid) {
    global sessionProcessPid

    global sessionShiftCount
    global sessionStallCount
    global sessionRaceRestartCount

    global statsLastGear

    if processPid <= 0 {
        return false
    } ; end invalid PID guard

    sessionProcessPid := processPid

    sessionShiftCount := 0
    sessionStallCount := 0
    sessionRaceRestartCount := 0

    statsLastGear := 1

    SaveStatCount("Session", "ProcessPid", sessionProcessPid)
    SaveStatCount("Session", "Shifts", 0)
    SaveStatCount("Session", "Stalls", 0)
    SaveStatCount("Session", "RaceRestarts", 0)

    UpdateStatsDisplay()

    return true
} ; end startstatssession

; ==========================================================================================================================================================
; FinalizeStatsSession()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Completes the active NFSMW statistics session.
;
; Session counters are added to their corresponding AllTime counters once, then the Session block is reset to its inactive state.
; ==========================================================================================================================================================
FinalizeStatsSession() {
    global sessionProcessPid

    global sessionShiftCount
    global sessionStallCount
    global sessionRaceRestartCount

    global allTimeShiftCount
    global allTimeStallCount
    global allTimeRaceRestartCount

    if sessionProcessPid = 0 {
        return false
    } ; end inactive-session guard

    if sessionShiftCount != 0 {
        allTimeShiftCount += sessionShiftCount
        SaveStatCount("AllTime", "Shifts", allTimeShiftCount)
    } ; end shift transfer

    if sessionStallCount != 0 {
        allTimeStallCount += sessionStallCount
        SaveStatCount("AllTime", "Stalls", allTimeStallCount)
    } ; end stall transfer

    if sessionRaceRestartCount != 0 {
        allTimeRaceRestartCount += sessionRaceRestartCount
        SaveStatCount("AllTime", "RaceRestarts", allTimeRaceRestartCount)
    } ; end race-restart transfer

    sessionProcessPid := 0

    sessionShiftCount := 0
    sessionStallCount := 0
    sessionRaceRestartCount := 0

    SaveStatCount("Session", "ProcessPid", 0)
    SaveStatCount("Session", "Shifts", 0)
    SaveStatCount("Session", "Stalls", 0)
    SaveStatCount("Session", "RaceRestarts", 0)

    UpdateStatsDisplay()

    return true
} ; end finalizestatssession

; ==========================================================================================================================================================
; SynchronizeStatsSession(processPid)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Synchronizes persistent Session ownership with the currently observed NFSMW
; process.
;
; Same PID:
;   resume the existing session
;
; Different PID:
;   finalize the stored session, then start a new one
;
; No running process:
;   finalize any stored active session
; ==========================================================================================================================================================
SynchronizeStatsSession(processPid) {
    global sessionProcessPid

    if processPid = sessionProcessPid {
        return
    } ; end already-synchronized guard

    if sessionProcessPid != 0 {
        FinalizeStatsSession()
    } ; end previous-session finalization

    if processPid {
        StartStatsSession(processPid)
    } ; end new-session start
} ; end synchronizestatssession

; ==========================================================================================================================================================
; RecordShift(targetGear)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Records one accepted driver-requested gear change.
;
; targetGear:
;   -1 = reverse
;    0 = neutral
;   1-6 = forward gears
;
; statsLastGear tracks the last gear recognized by the statistics subsystem.
; Repeating the same gear does not create another shift.
;
; statsLastGear is maintained even when shift tracking is disabled so enabling
; or otherwise synchronizing transmission state cannot leave the statistics
; gear baseline stale.
;
; System/recovery operations should update statsLastGear directly rather than
; calling RecordShift(), because those operations are synchronization events,
; not driver shifts.
; ==========================================================================================================================================================
RecordShift(targetGear) {
    global trackShifts
    global statsLastGear
    global sessionShiftCount
    global stallSuppressedUntilShift

    ; New-game stall suppression
    ; Reaching RecordShift() means RealManual accepted a legitimate driver shift.
    stallSuppressedUntilShift := false

    if targetGear = statsLastGear {
        return
    } ; end unchanged gear guard

    statsLastGear := targetGear

    if !trackShifts {
        return
    } ; end tracking feature guard

    sessionShiftCount++

    SaveStatCount(
        "Session",
        "Shifts",
        sessionShiftCount
    )

    UpdateStatsDisplay()
} ; end recordshift

; ==========================================================================================================================================================
; RecordStall()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Records one simulated engine stall when stall statistics are enabled.
;
; Only the Session stall counter is persisted here.
; AllTime is updated when the NFSMW process session is finalized.
; ==========================================================================================================================================================
RecordStall() {
    global trackStalls
    global sessionStallCount

    if !trackStalls {
        return
    } ; end tracking feature guard

    sessionStallCount++

    SaveStatCount(
        "Session",
        "Stalls",
        sessionStallCount
    )

    UpdateStatsDisplay()
} ; end recordstall

; ==========================================================================================================================================================
; RecordRaceRestart(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Manually records one race restart when race-restart statistics are enabled.
;
; Only the Session race-restart counter is persisted here.
; AllTime is updated when the NFSMW process session is finalized.
; ==========================================================================================================================================================
RecordRaceRestart(*) {
    global trackRaceRestarts
    global sessionRaceRestartCount

    if !trackRaceRestarts {
        return
    } ; end tracking feature guard

    sessionRaceRestartCount++

    SaveStatCount(
        "Session",
        "RaceRestarts",
        sessionRaceRestartCount
    )

    UpdateStatsDisplay()
} ; end recordracerestart

; ==========================================================================================================================================================
; IsStatsDisplayActive()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns whether the statistics overlay currently has at least one selected
; statistic to display.
;
; This describes display selection only.
;
; It does NOT determine whether statistics are being tracked. Tracking is
; controlled separately by the TrackShifts, TrackStalls, and TrackRaceRestarts
; configuration settings.
;
; Returns:
;   true  = at least one statistics line is selected for display
;   false = no statistics lines are selected
; ==========================================================================================================================================================
IsStatsDisplayActive() {
    global showShiftStats
    global showStallStats
    global showRaceRestartStats

    return showShiftStats
        || showStallStats
        || showRaceRestartStats
} ; end isstatsdisplayactive

; ==========================================================================================================================================================
; GetOverlayX(overlayName)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the horizontal position for either the statistics or stopwatch
; tooltip.
;
; Overlay placement policy:
;
;   only stats active:
;       stats uses overlayPrimaryX
;
;   only stopwatch active:
;       stopwatch uses overlayPrimaryX
;
;   both active:
;       whichever overlay was activated first keeps overlayPrimaryX
;       whichever overlay was activated second uses overlaySecondaryX
;
; overlayActivationCounter provides a monotonically increasing activation
; sequence. The smaller nonzero order value belongs to the older overlay.
;
; overlayName:
;   "stats"
;   "stopwatch"
; ==========================================================================================================================================================
GetOverlayX(overlayName) {
    global stopwatchStarted
    global statsOverlayOrder, stopwatchOverlayOrder
    global overlayPrimaryX, overlaySecondaryX

    statsActive := IsStatsDisplayActive()
    stopwatchActive := stopwatchStarted

    ; One overlay active
    if !statsActive || !stopwatchActive {
        return overlayPrimaryX
    } ; end single-overlay branch

    ; Both overlays active
    if overlayName = "stats" {
        ; Stats appeared first, so they retain the primary position.
        if statsOverlayOrder < stopwatchOverlayOrder {
            return overlayPrimaryX
        }
        ; Stopwatch appeared first, so stats move to the secondary position.
        return overlaySecondaryX
    } ; end stats positioning

    if overlayName = "stopwatch" {
        ; Stopwatch appeared first, so it retains the primary position.
        if stopwatchOverlayOrder < statsOverlayOrder {
            return overlayPrimaryX
        }
        ; Stats appeared first, so stopwatch moves to the secondary position.
        return overlaySecondaryX
    } ; end stopwatch positioning


    ; Unknown overlay names safely fall back to the primary position.
    return overlayPrimaryX
} ; end getoverlayx

; ==========================================================================================================================================================
; UpdateStatsDisplay()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Rebuilds the optional session-statistics tooltip.
;
; Only statistics that satisfy BOTH conditions are shown:
;
;   1. the statistic is enabled for tracking in config.ini
;   2. the user has toggled that statistic on for display
;
; The tooltip contains SESSION values only.
; Persistent all-time values remain stored in stats.txt.
;
; Statistics use tooltip ID 3 so the panel can coexist with the stopwatch,
; which uses tooltip ID 2.
;
; If no statistics are selected, or statistics/tooltips are disabled, tooltip
; ID 3 is cleared.
; ==========================================================================================================================================================
UpdateStatsDisplay() {
    global enableToolTips
    global trackShifts, trackStalls, trackRaceRestarts
    global showShiftStats, showStallStats, showRaceRestartStats
    global sessionShiftCount, sessionStallCount, sessionRaceRestartCount
    global statsToolTipId
    global overlayY

    if !enableToolTips
        || !IsStatsDisplayActive() {
        ; Clear only the statistics tooltip.
        ToolTip(
            ,
            ,
            ,
            statsToolTipId
        )

        return
    } ; end display availability guard

    message := "Session Stats"

    if trackShifts && showShiftStats {
        message .=
            "`nShifts: "
            . sessionShiftCount
    } ; end shift line

    if trackStalls && showStallStats {
        message .=
            "`nStalls: "
            . sessionStallCount
    } ; end stall line

    if trackRaceRestarts && showRaceRestartStats {
        message .=
            "`nRace Restarts: "
            . sessionRaceRestartCount
    } ; end race-restart line

    ; Show statistics overlay
    ToolTip(
        message,
        GetOverlayX("stats"),
        overlayY,
        statsToolTipId
    )
} ; end updatestatsdisplay

; ==========================================================================================================================================================
; ToggleStatsDisplay(statName)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Toggles one statistic line in the session-statistics overlay.
;
; Supported statName values:
;
;   "shifts"
;   "stalls"
;   "restarts"
;
; A statistic can be displayed only when its corresponding tracking option is
; enabled in config.ini.
;
; Overlay activation ordering:
;
;   When the FIRST statistics line becomes visible:
;       the statistics panel receives a new activation order.
;
;   When additional statistics are added to an already-visible panel:
;       the existing order is preserved.
;
;   When the LAST visible statistics line is removed:
;       statsOverlayOrder returns to zero.
;
; This preserves the behavior where whichever overlay appeared first
; remains on the left side.
; ==========================================================================================================================================================
ToggleStatsDisplay(statName) {
    global trackShifts, trackStalls, trackRaceRestarts
    global showShiftStats, showStallStats, showRaceRestartStats
    global overlayActivationCounter
    global statsOverlayOrder
    global stopwatchStarted

    wasActive := IsStatsDisplayActive()

    ; Toggle requested statistic
    switch statName {
        case "shifts":
            if !trackShifts {
                return
            }

            showShiftStats := !showShiftStats

        case "stalls":

            if !trackStalls {
                return
            }

            showStallStats := !showStallStats

        case "restarts":

            if !trackRaceRestarts {
                return
            }

            showRaceRestartStats := !showRaceRestartStats

        default:
            return
    } ; end statistic selection

    isActive := IsStatsDisplayActive()

    ; Statistics overlay became visible
    if !wasActive && isActive {
        overlayActivationCounter++

        statsOverlayOrder :=
            overlayActivationCounter
    } ; end stats activation

    ; Statistics overlay became hidden
    if wasActive && !isActive {
        statsOverlayOrder := 0
    } ; end stats deactivation

    UpdateStatsDisplay()

    if stopwatchStarted {
        UpdateStopwatchDisplay()
    } ; end stopwatch layout refresh
} ; end togglestatsdisplay


; ==========================================================================================================================================================
; SECTION 15: STOPWATCH
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; FormatStopwatchTime(totalMs)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts an elapsed millisecond count into stopwatch-style text.
;
; Under one hour:
;   MM:SS.mmm
;
; One hour or longer:
;   HH:MM:SS.mmm
; ==========================================================================================================================================================
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

; ==========================================================================================================================================================
; GetStopwatchElapsedMs()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the elapsed time of the current stopwatch segment.
;
; While running, elapsed time includes time since stopwatchStartTime.
; While paused, only the previously accumulated time is returned.
; ==========================================================================================================================================================
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

; ==========================================================================================================================================================
; UpdateStopwatchDisplay()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Builds the persistent stopwatch tooltip.
;
; Completed laps remain frozen above the current timer.
; The current timer shows whether it is running or paused.
;
; Stopwatch position is coordinated with the statistics overlay:
;
;   first overlay activated  -> primary position
;   second overlay activated -> secondary position
; ==========================================================================================================================================================
UpdateStopwatchDisplay() {
    global enableToolTips
    global stopwatchStarted
    global stopwatchRunning
    global stopwatchLaps
    global stopwatchToolTipId
    global overlayY

    if !enableToolTips {
        ToolTip(
            ,
            ,
            ,
            stopwatchToolTipId
        )

        return
    } ; end tooltip feature guard

    if !stopwatchStarted {
        ToolTip(
            ,
            ,
            ,
            stopwatchToolTipId
        )

        return
    } ; end stopwatch-state guard

    message := "Stopwatch"

    for lapNumber, lapTime in stopwatchLaps {
        message .=
            "`n"
            . lapNumber
            . ". "
            . FormatStopwatchTime(lapTime)
    } ; end completed-lap loop

    currentNumber := stopwatchLaps.Length + 1
    currentTime := GetStopwatchElapsedMs()

    if stopwatchRunning {
        message .=
            "`n"
            . currentNumber
            . ". "
            . FormatStopwatchTime(currentTime)
            . "  [RUNNING]"

    } else {
        message .=
            "`n"
            . currentNumber
            . ". "
            . FormatStopwatchTime(currentTime)
            . "  [PAUSED]"
    } ; end current stopwatch state

    ToolTip(
        message,
        GetOverlayX("stopwatch"),
        overlayY,
        stopwatchToolTipId
    )
} ; end updatestopwatchdisplay

; ==========================================================================================================================================================
; ToggleStopwatch(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Controls the current stopwatch segment.
;
; Not started:
;   starts the stopwatch
;   assigns the stopwatch its overlay activation order
;
; Running:
;   pauses at the current elapsed time
;
; Paused:
;   resumes from the preserved elapsed time
;
; Pausing/resuming doesn't change overlay order because the stopwatch remains
; visible throughout both states.
; ==========================================================================================================================================================
ToggleStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime
    global stopwatchAccumulatedMs, stopwatchRefreshMs
    global overlayActivationCounter, stopwatchOverlayOrder

    ; Initial start
    if !stopwatchStarted {
        stopwatchStarted := true
        stopwatchRunning := true

        stopwatchStartTime := A_TickCount
        stopwatchAccumulatedMs := 0

        overlayActivationCounter++
        stopwatchOverlayOrder := overlayActivationCounter

        UpdateStopwatchDisplay()

        if IsStatsDisplayActive() {
            UpdateStatsDisplay()
        }

        SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))

        return
    } ; end initial start

    ; Pause
    if stopwatchRunning {
        stopwatchAccumulatedMs +=
            A_TickCount - stopwatchStartTime

        stopwatchRunning := false

        ; paused stopwatch no longer requires continuous refreshes.
        SetTimer(UpdateStopwatchDisplay, 0)

        UpdateStopwatchDisplay()

        return
    } ; end pause

    ; Resume
    stopwatchRunning := true
    stopwatchStartTime := A_TickCount

    UpdateStopwatchDisplay()

    SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))
} ; end togglestopwatch

; ==========================================================================================================================================================
; LapStopwatch(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Freezes the current stopwatch segment and starts a new segment from zero.
;
; Completed laps remain visible above the active timer.
; The total number of displayed lines is limited by Stopwatch.StopwatchMaxLines.
; ==========================================================================================================================================================
LapStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime
    global stopwatchAccumulatedMs, stopwatchRefreshMs
    global stopwatchLaps, stopwatchMaxLines, 

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

    ; Every new lap begins from zero.
    stopwatchAccumulatedMs := 0
    stopwatchStartTime := A_TickCount
    stopwatchRunning := true

    UpdateStopwatchDisplay()
    SetTimer(UpdateStopwatchDisplay, Max(20, stopwatchRefreshMs))
} ; end lapstopwatch

; ==========================================================================================================================================================
; ClearStopwatch(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Completely resets stopwatch state and removes the stopwatch display.
;
; Clearing also removes the stopwatch from shared overlay ordering.
;
; If the statistics panel is still active, it is immediately refreshed so it
; can reclaim the primary upper-left position.
; ==========================================================================================================================================================
ClearStopwatch(*) {
    global stopwatchStarted, stopwatchRunning
    global stopwatchStartTime
    global stopwatchAccumulatedMs
    global stopwatchLaps
    global stopwatchToolTipId
    global stopwatchOverlayOrder

    ; Stop stopwatch refresh timer
    SetTimer(UpdateStopwatchDisplay, 0)

    ; Reset stopwatch state
    stopwatchStarted := false
    stopwatchRunning := false

    stopwatchStartTime := 0
    stopwatchAccumulatedMs := 0

    stopwatchLaps := []

    ; Remove From Shared Overlay Layout
    stopwatchOverlayOrder := 0

    ; Clear Stopwatch Tooltip
    ToolTip(
        ,
        ,
        ,
        stopwatchToolTipId
    )

    ; Reposition Remaining Statistics Overlay
    if IsStatsDisplayActive() {
        UpdateStatsDisplay()
    }
} ; end clearstopwatch


; ==========================================================================================================================================================
; SECTION 16: TRANSIENT STATE CLEAR / DISARM HELPERS
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; ClearEdgeInputState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears cached state for edge-triggered transmission inputs.
;
; Used whenever RealManual must forget previously observed button edges so an
; old press cannot survive a mode change, reset, engine-state transition, or
; other synchronization event.
;
; Paddle and keyboard synchronization are disarmed here along with their edge
; history. sequentialShifterArmed and shifterHandbrakeArmed are deliberately
; left to the calling context.
; ==========================================================================================================================================================
ClearEdgeInputState() {
    global lastUpshiftPressed, lastDownshiftPressed
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global paddleSyncArmed
    global reverseCommandLatched
    global lastKeyboardUpshiftPressed, lastKeyboardDownshiftPressed
    global keyboardShiftSyncArmed

    lastUpshiftPressed := false
    lastDownshiftPressed := false

    lastPaddleUpshiftPressed := false
    lastPaddleDownshiftPressed := false
    paddleSyncArmed := false

    lastKeyboardUpshiftPressed := false
    lastKeyboardDownshiftPressed := false
    keyboardShiftSyncArmed := false

    reverseCommandLatched := false
} ; end clearedgeinputstate

; ==========================================================================================================================================================
; ClearClutchTransactionState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears transient state belonging to the current clutch transaction.
;
; Used when a mode change, synchronization event, reverse transition, or
; completed H-pattern engagement invalidates the previous clutch cycle.
; ==========================================================================================================================================================
ClearClutchTransactionState() {
    global lastClutchPressed
    global clutchNeutralSent

    lastClutchPressed := false
    clutchNeutralSent := false
} ; end clearclutchtransactionstate

; ==========================================================================================================================================================
; ClearTransmissionInputState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears edge-triggered input history and any active clutch transaction.
;
; Used when RealManual deliberately establishes a new synchronized
; transmission state.
; ==========================================================================================================================================================
ClearTransmissionInputState() {
    ClearEdgeInputState()
    ClearClutchTransactionState()
} ; end cleartransmissioninputstate

; ==========================================================================================================================================================
; DisarmEdgeInputs()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Invalidates edge-triggered controller state after RealManual temporarily
; stops observing input, such as pause or focus loss.
; ==========================================================================================================================================================
DisarmEdgeInputs() {
    global sequentialShifterArmed, shifterHandbrakeArmed

    ClearEdgeInputState()

    sequentialShifterArmed := false
    shifterHandbrakeArmed := false
} ; end disarmedgeinputs

; ==========================================================================================================================================================
; ClearStallDetectionState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears transient state belonging to an in-progress stall-detection cycle.
; ==========================================================================================================================================================
ClearStallDetectionState() {
    global stallDetectionArmed
    global noInputStallStartTime

    stallDetectionArmed := false
    noInputStallStartTime := 0
} ; end clearstalldetectionstate

; ==========================================================================================================================================================
; ClearBrakeResetStallGraceState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears the stall-protection state created by a completed sequential
; brake-hold gear reset.
; ==========================================================================================================================================================
ClearBrakeResetStallGraceState() {
    global brakeResetStallGraceActive
    global brakeResetReleaseTime

    brakeResetStallGraceActive := false
    brakeResetReleaseTime := 0
} ; end clearbrakeresetstallgracestate

; ==========================================================================================================================================================
; ClearSequentialBrakeHoldTimer()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears the in-progress sequential brake-hold timer when continuous input
; observation is interrupted, such as by focus loss, pause, or menu automation.
; ==========================================================================================================================================================
ClearSequentialBrakeHoldTimer() {
    global brakeHoldStartTime

    brakeHoldStartTime := 0
} ; end clearsequentialbrakeholdtimer

; ==========================================================================================================================================================
; ClearSequentialBrakeResetState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Completely resets all transient state belonging to the sequential brake-hold
; gear-reset subsystem.
;
; Used when the subsystem's context becomes invalid, such as a transmission
; mode change, engine state change, or manual recovery reset.
; ==========================================================================================================================================================
ClearSequentialBrakeResetState() {
    global brakeHoldStartTime
    global brakeHoldResetTriggered
    global sequentialReverseAssistEligible

    brakeHoldStartTime := 0
    brakeHoldResetTriggered := false
    sequentialReverseAssistEligible := false

    ClearBrakeResetStallGraceState()
} ; end clearsequentialbrakeresetstate


; ==========================================================================================================================================================
; SECTION 17: DYNAMIC HOTKEYS AND LIVE MODE TOGGLES
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; GetDynamicHotkeyDefinitions()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the complete set of configurable RealManual hotkeys.
;
; Each definition contains:
;   setting  = config.ini key name
;   label    = human-readable name used by validation
;   hotkey   = configured AutoHotkey hotkey string
;   callback = function object executed when the hotkey fires
;
; Registration and validation both use this same definition list so the two
; systems cannot silently drift apart.
; ==========================================================================================================================================================
GetDynamicHotkeyDefinitions() {
    global helpButton, resetButton, pauseButton, reloadButton
    global toggleTransmissionModeButton, toggleSequentialShifterInvertButton
    global toggleClutchRequiredButton, toggleClutchNeutralButton
    global toggleMaxForwardGearButton
    global toggleShifterHandbrakeButton
    global ignitionButton, toggleStallingButton
    global stopwatchButton, stopwatchLapButton, stopwatchClearButton
    global statsShiftsButton, statsStallsButton
    global statsRaceRestartsButton, raceRestartButton
    global maxVideoSettingsButton
    global saveInstantReplayButton, captureScreenshotButton

    return [
        {
            setting: "HelpButton",
            label: "Help",
            hotkey: helpButton,
            callback: ShowHotkeyHelp
        },
        {
            setting: "ResetButton",
            label: "Reset",
            hotkey: resetButton,
            callback: (*) => ResetInputs()
        },
        {
            setting: "PauseButton",
            label: "Pause",
            hotkey: pauseButton,
            callback: (*) => ToggleScriptPause()
        },
        {
            setting: "ReloadButton",
            label: "Reload",
            hotkey: reloadButton,
            callback: (*) => Reload()
        },
        {
            setting: "ToggleTransmissionModeButton",
            label: "Transmission Mode Toggle",
            hotkey: toggleTransmissionModeButton,
            callback: (*) => ToggleTransmissionMode()
        },
        {
            setting: "ToggleSequentialShifterInvertButton",
            label: "Sequential Shifter Invert",
            hotkey: toggleSequentialShifterInvertButton,
            callback: (*) => ToggleSequentialShifterInvert()
        },
        {
            setting: "ToggleClutchRequiredButton",
            label: "Clutch Required Toggle",
            hotkey: toggleClutchRequiredButton,
            callback: (*) => ToggleClutchRequired()
        },
        {
            setting: "ToggleClutchNeutralButton",
            label: "Clutch Neutral Toggle",
            hotkey: toggleClutchNeutralButton,
            callback: (*) => ToggleClutchNeutral()
        },
        {
            setting: "ToggleShifterHandbrakeButton",
            label: "Shifter Handbrake Toggle",
            hotkey: toggleShifterHandbrakeButton,
            callback: (*) => ToggleShifterHandbrake()
        },
        {
            setting: "ToggleMaxForwardGearButton",
            label: "Maximum Forward Gear Toggle",
            hotkey: toggleMaxForwardGearButton,
            callback: (*) => ToggleMaxForwardGear()
        },
        {
            setting: "IgnitionButton",
            label: "Ignition",
            hotkey: ignitionButton,
            callback: HandleIgnitionButton
        },
        {
            setting: "ToggleStallingButton",
            label: "Stalling Toggle",
            hotkey: toggleStallingButton,
            callback: ToggleStalling
        },
        {
            setting: "StopwatchButton",
            label: "Stopwatch Start/Pause",
            hotkey: stopwatchButton,
            callback: ToggleStopwatch
        },
        {
            setting: "StopwatchLapButton",
            label: "Stopwatch Lap",
            hotkey: stopwatchLapButton,
            callback: LapStopwatch
        },
        {
            setting: "StopwatchClearButton",
            label: "Stopwatch Clear",
            hotkey: stopwatchClearButton,
            callback: ClearStopwatch
        },
        {
            setting: "StatsShiftsButton",
            label: "Stats Display - Shifts",
            hotkey: statsShiftsButton,
            callback: (*) => ToggleStatsDisplay("shifts")
        },
        {
            setting: "StatsStallsButton",
            label: "Stats Display - Stalls",
            hotkey: statsStallsButton,
            callback: (*) => ToggleStatsDisplay("stalls")
        },
        {
            setting: "StatsRaceRestartsButton",
            label: "Stats Display - Race Restarts",
            hotkey: statsRaceRestartsButton,
            callback: (*) => ToggleStatsDisplay("restarts")
        },
        {
            setting: "RaceRestartButton",
            label: "Record Race Restart",
            hotkey: raceRestartButton,
            callback: RecordRaceRestart
        },
        {
            setting: "MaxVideoSettingsButton",
            label: "Max Video Settings",
            hotkey: maxVideoSettingsButton,
            callback: ApplyMaxVideoSettings
        },
        {
            setting: "SaveInstantReplayButton",
            label: "Save NVIDIA Instant Replay",
            hotkey: saveInstantReplayButton,
            callback: SaveNvidiaInstantReplay
        },
        {
            setting: "CaptureScreenshotButton",
            label: "Capture NVIDIA Screenshot",
            hotkey: captureScreenshotButton,
            callback: CaptureNvidiaScreenshot
        }
    ]
} ; end getdynamichotkeydefinitions

; ==========================================================================================================================================================
; TryRegisterHotkey(definition, registeredHotkeys, registrationResults)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Attempts to register one configurable hotkey safely.
;
; Registration policy:
;   blank      -> skipped silently
;   reserved   -> blocked
;   duplicate  -> blocked; first successful assignment wins
;   malformed  -> exception caught and reported
;   valid      -> registered
;
; Results are recorded for BuildValidationText().
; ==========================================================================================================================================================
TryRegisterHotkey(definition, registeredHotkeys, registrationResults) {

    hotkeyName := Trim(definition.hotkey)

    if hotkeyName = "" {
        return true
    } ; end blank hotkey guard

    normalizedHotkey := StrLower(hotkeyName)
    reservedPurpose := GetReservedProtocolConflict(hotkeyName)

    if reservedPurpose != "" {
        registrationResults.Push({
            setting: definition.setting,
            label: definition.label,
            hotkey: hotkeyName,
            status: "reserved",
            detail: reservedPurpose
        })

        return false
    } ; end reserved protocol guard

    if registeredHotkeys.Has(normalizedHotkey) {
        registrationResults.Push({
            setting: definition.setting,
            label: definition.label,
            hotkey: hotkeyName,
            status: "duplicate",
            detail: registeredHotkeys[normalizedHotkey]
        })

        return false
    } ; end duplicate guard

    try {
        Hotkey(hotkeyName, definition.callback, "On")

        registeredHotkeys[normalizedHotkey] := definition.label

        registrationResults.Push({
            setting: definition.setting,
            label: definition.label,
            hotkey: hotkeyName,
            status: "registered",
            detail: ""
        })

        return true

    } catch as err {
        errorText := StrReplace(
            StrReplace(err.Message, "`r", " "),
            "`n",
            " "
        )

        registrationResults.Push({
            setting: definition.setting,
            label: definition.label,
            hotkey: hotkeyName,
            status: "failed",
            detail: errorText
        })

        return false
    } ; end protected registration
} ; end tryregisterhotkey

; ==========================================================================================================================================================
; RegisterDynamicHotkeys()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Attempts to register all configured RealManual hotkeys for speed.exe.
;
; Returns an array describing the registration result of every nonblank
; configured hotkey. BuildValidationText() consumes that result directly.
; ==========================================================================================================================================================
RegisterDynamicHotkeys() {
    definitions := GetDynamicHotkeyDefinitions()

    registeredHotkeys := Map()
    registrationResults := []

    HotIfWinActive("ahk_exe speed.exe")

    try {
        for definition in definitions {
            TryRegisterHotkey(definition, registeredHotkeys, registrationResults)
        }
    } finally {
        HotIfWinActive()
    }

    return registrationResults
} ; end registerdynamichotkeys

; ==========================================================================================================================================================
; ShowHotkeyHelp(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Displays the same live-mode status window used after mode changes.
; ==========================================================================================================================================================
ShowHotkeyHelp(*) {
    ShowLiveModeStatus("RealManual Hotkeys")
} ; end showhotkeyhelp

; ==========================================================================================================================================================
; SetTransmissionMode(useSequential)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Applies an H-pattern/sequential transmission-mode change and resets transient
; state shared by all code paths that can change transmission mode.
;
; Entering sequential:
;   preserves the best-known game gear and requires the sequential lever to
;   return to neutral before use.
;
; Entering H-pattern:
;   resets physical H-pattern position history, disables the sequential-only
;   shifter handbrake, and re-evaluates the remaining handbrake sources.
; ==========================================================================================================================================================
SetTransmissionMode(useSequential) {
    global transmissionIsSequential
    global pendingSequentialShiftCount
    global sequentialShifterArmed
    global enableShifterHandbrake, shifterHandbrakeArmed
    global lastHPatternSelectedGear

    if transmissionIsSequential = useSequential {
        return
    } ; end unchanged-mode guard

    transmissionIsSequential := useSequential

    ; Clear mode-specific transient state
    pendingSequentialShiftCount := 0

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()
    ClearStallDetectionState()

    if transmissionIsSequential {
        ; An already-selected sequential slot must not count as a new shift.
        sequentialShifterArmed := false
    } else {
        lastHPatternSelectedGear := -2
        sequentialShifterArmed := true

        ; Shifter handbrake cannot coexist with H-pattern gear selection.
        enableShifterHandbrake := false
        shifterHandbrakeArmed := true

        HandleHandbrake()
    } ; end target-mode initialization

} ; end settransmissionmode

; ==========================================================================================================================================================
; ToggleTransmissionMode()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Switches RealManual between H-pattern and sequential transmission modes.
;
; The actual mode transition and transient-state synchronization are handled by
; SetTransmissionMode() so every transmission-mode change follows the same path.
; ==========================================================================================================================================================
ToggleTransmissionMode() {
    global transmissionIsSequential

    SetTransmissionMode(!transmissionIsSequential)

    ShowLiveModeStatus("Changed: Transmission Mode")
} ; end toggletransmissionmode

; ==========================================================================================================================================================
; ToggleClutchRequired()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Enables or disables the clutch gate.
;
; The function clears clutch transition state to prevent a stale clutch press from
; triggering an unintended gear engagement after toggling.
; ==========================================================================================================================================================
ToggleClutchRequired() {
    global requireClutch
    global pendingSequentialShiftCount

    requireClutch := !requireClutch ; flips clutch requirement
    pendingSequentialShiftCount := 0

    ClearClutchTransactionState()
    ClearStallDetectionState()

    ShowLiveModeStatus("Changed: Clutch Required")
} ; end toggleclutchrequired

; ==========================================================================================================================================================
; ToggleClutchNeutral()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Enables or disables clutch-to-neutral behavior.
;
; Enabled:
;   clutch press sends neutral
;   clutch release re-engages the selected or tracked gear
;
; Disabled:
;   clutch can still be required, but it does not force neutral.
; ==========================================================================================================================================================
ToggleClutchNeutral() {
    global clutchActsAsNeutral
    global pendingSequentialShiftCount

    clutchActsAsNeutral := !clutchActsAsNeutral
    pendingSequentialShiftCount := 0

    ClearClutchTransactionState()
    ClearStallDetectionState()

    ShowLiveModeStatus("Changed: Clutch -> Neutral")
} ; end toggleclutchneutral

; ==========================================================================================================================================================
; ToggleMaxForwardGear(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Toggles the maximum selectable forward gear between five and six.
; 6th gear is invalid in cars with 5 gears, produces neutral this function keeps 5th gear when 6th is selected in 5 gear mode.
;
; Expanding to six gears only raises the allowed limit.
;
; Reducing to five gears:
;   clamps the tracked game gear to fifth
;   cancels queued sequential shifts created under the old gearbox limit
;   forces the game from sixth to fifth when necessary
;
; If clutch-to-neutral is active and the clutch is currently pressed, the game
; remains in neutral and the clamped gear is re-engaged normally on release.
; ==========================================================================================================================================================
ToggleMaxForwardGear(*) {
    global maxForwardGear
    global virtualGear
    global pendingSequentialShiftCount
    global clutchActsAsNeutral
    global engineStalled
    global statsLastGear

    previousMaxGear := maxForwardGear
    previousVirtualGear := virtualGear

    maxForwardGear := maxForwardGear = 5 ? 6 : 5

    if maxForwardGear > previousMaxGear {
        ShowLiveModeStatus("Changed: Gearbox Limit")
        return
    } ; end expanded gearbox branch

    ; Clamp Internal Gear State
    virtualGear := Min(virtualGear, maxForwardGear)

    ; A queued sequential shift transaction was created under the previous gearbox limit and may now target a gear that no longer exists.
    pendingSequentialShiftCount := 0

    ; virtualGear is the best-known current game gear in both transmission modes, including temporary H-pattern/paddle disagreement.
    correctionRequired := previousVirtualGear > maxForwardGear

    if correctionRequired {
        ; Gearbox-limit correction is a system state change, not a shift.
        statsLastGear := virtualGear
    }

    ; Synchronize game gear
    if correctionRequired && !engineStalled {
        ; Clutch-to-neutral deliberately keeps the game in neutral while the clutch is pressed. 
        ; The already-clamped virtual gear will be re-engaged normally when the clutch is released.
        if !(clutchActsAsNeutral && IsClutchPressed(ReadClutchAxis())) {
            SendGearToMod(maxForwardGear, true)
        } ; end clutch-neutral preservation
    } ; end game correction branch

    ShowLiveModeStatus("Changed: Gearbox Limit")
} ; end togglemaxforwardgear

; ==========================================================================================================================================================
; ToggleSequentialShifterInvert()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reverses the physical sequential-shifter upshift/downshift directions.
;
; After changing the mapping, the sequential shifter is disarmed until it returns to neutral. 
; This prevents an already-selected slot from being interpreted as a new shift under the inverted mapping.
; ==========================================================================================================================================================
ToggleSequentialShifterInvert() {
    global invertSequentialShifter
    global lastUpshiftPressed, lastDownshiftPressed
    global sequentialShifterArmed

    invertSequentialShifter := !invertSequentialShifter

    RefreshActiveSequentialBindings()

    lastUpshiftPressed := false
    lastDownshiftPressed := false

    sequentialShifterArmed := false

    ShowLiveModeStatus("Changed: Sequential Shifter Invert")
} ; end togglesequentialshifterinvert

; ==========================================================================================================================================================
; ToggleShifterHandbrake()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Toggles use of a configured H-shifter slot as the handbrake.
;
; Shifter-handbrake mode is valid only in sequential transmission mode.
; Enabling it from H-pattern mode performs a normal synchronized
; transmission-mode transition before activating the feature.
;
; The shifter must return to neutral after enabling before the handbrake slot
; becomes armed.
; ==========================================================================================================================================================
ToggleShifterHandbrake(*) {
    global enableShifterHandbrake
    global transmissionIsSequential
    global shifterHandbrakeArmed
    global sequentialShifterArmed

    if !enableShifterHandbrake {
        if !transmissionIsSequential {
            SetTransmissionMode(true)
        } ; end sequential-mode requirement

        enableShifterHandbrake := true

        ; Prevents an already-selected handbrake slot from activating immediately when the feature is enabled.
        shifterHandbrakeArmed := false

    ; Disable shifter handbrake
    } else {
        enableShifterHandbrake := false
        shifterHandbrakeArmed := true

        ; The lever may still physically occupy the slot that was just being used as the handbrake. 
        ; Require neutral before sequential shifting becomes active again.
        sequentialShifterArmed := false

        HandleHandbrake()
    } ; end feature-state branch

    ShowLiveModeStatus("Changed: Shifter Handbrake")
} ; end toggleshifterhandbrake

; ==========================================================================================================================================================
; ToggleStalling()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Disabling the feature while stalled acts as an emergency unlock. 
; Does not perform the ignition animation.
; ==========================================================================================================================================================
ToggleStalling(*) {
    global enableStalling
    global engineStalled
    global lastStallNeutralSendTime

    enableStalling := !enableStalling
    ClearStallDetectionState()

    if !enableStalling && engineStalled {
        engineStalled := false
        lastStallNeutralSendTime := 0
        HandleHandbrake() ; removes forced stall handbrake
    } ; end stalled disable branch

    ShowLiveModeStatus("Changed: Stalling")
} ; end togglestalling

; ==========================================================================================================================================================
; ToggleScriptPause(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Pauses or resumes RealManual input handling.
;
; When paused:
;   any active video-settings sequence is cancelled
;   held gameplay outputs are released
;   edge-triggered inputs are disarmed
;   stall and sequential brake-hold timing state is cleared
;   the MainLoop timer is stopped
;   the tray menu changes to Resume RealManual
;
; The AutoHotkey process itself remains active so tray controls and registered
; hotkeys can continue operating.
; ==========================================================================================================================================================
ToggleScriptPause(*) {
    global scriptPaused
    global videoSettingsSequenceActive

    scriptPaused := !scriptPaused

    if scriptPaused {

        if videoSettingsSequenceActive {
            StopMaxVideoSettingsSequence()
        } ; end active menu-sequence cancellation

        ReleaseHeldOutputsQuietly()
        DisarmEdgeInputs()
        ClearStallDetectionState()
        ClearSequentialBrakeHoldTimer()

        A_TrayMenu.Rename("Pause RealManual", "Resume RealManual")
        ShowToolTipMessage("RealManual paused")
    } else {
        A_TrayMenu.Rename("Resume RealManual", "Pause RealManual")
        ShowToolTipMessage("RealManual running")
    } ; end pause state branch

    UpdateMainLoopSchedule()
} ; end togglescriptpause


; ==========================================================================================================================================================
; SECTION 18: NFSMW MENU AUTOMATION
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; TapMenuKey(keyName)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends one controlled key press specifically for NFSMW menu navigation.
;
; The hold is long enough to span NFSMW's input polling reliably, but short
; enough to avoid triggering normal menu key-repeat behavior.
;
; Returns:
;   true  = key press completed successfully
;   false = key could not be sent
; ==========================================================================================================================================================
TapMenuKey(keyName) {
    menuKeyHoldMs := 10

    if Trim(keyName) = "" {
        return false
    } ; end blank-key guard

    try {
        SendEvent "{" keyName " down}"
        Sleep menuKeyHoldMs
        SendEvent "{" keyName " up}"

        return true
    } catch {
        ; Best-effort release if the press began before an output failure.
        try {
            SendEvent "{" keyName " up}"
        }

        return false
    } ; end protected menu-key send
} ; end tapmenukey

; ==========================================================================================================================================================
; AddMenuSequenceSteps(sequence, keyName, repeatCount, delayAfterMs)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Appends one or more individual menu-navigation steps to a sequence.
;
; Each key press becomes its own independently scheduled step so the sequence can be cancelled between any two inputs.
; ==========================================================================================================================================================
AddMenuSequenceSteps(sequence, keyName, repeatCount, delayAfterMs) {
    Loop repeatCount {
        sequence.Push({
            key: keyName,
            delayAfterMs: delayAfterMs
        })
    }
} ; end addmenusequencesteps

; ==========================================================================================================================================================
; BuildMaxVideoSettingsSequence()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Builds the complete NFSMW main-menu -> maximum-video-settings -> main-menu
; navigation sequence.
;
; Ordinary directional inputs use a short separation delay.
; Enter / screen-change operations receive a longer transition delay so the
; next input cannot arrive while NFSMW is still opening another menu.
; ==========================================================================================================================================================
BuildMaxVideoSettingsSequence() {
    sequence := []

    menuStepDelayMs := 40
    menuTransitionDelayMs := 1200

    ; Main Menu -> Video Settings
    AddMenuSequenceSteps(sequence, "Right", 7, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 4, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Left", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "2", 1, menuTransitionDelayMs)

    ; Maximum Video Settings
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 3, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 2, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 3, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 3, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 2, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Down", 3, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Right", 3, menuStepDelayMs)

    ; Apply / Confirm / Return to Main Menu
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Left", 1, menuStepDelayMs)
    AddMenuSequenceSteps(sequence, "Enter", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Esc", 1, menuTransitionDelayMs)
    AddMenuSequenceSteps(sequence, "Left", 7, menuStepDelayMs)

    return sequence
} ; end buildmaxvideosettingssequence

; ==========================================================================================================================================================
; StopMaxVideoSettingsSequence()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Stops the currently running maximum-video-settings sequence.
;
; Cancels any scheduled future step, clears transient sequence state, and re-evaluates MainLoop scheduling according to the current pause/focus state.
; ==========================================================================================================================================================
StopMaxVideoSettingsSequence() {
    global videoSettingsSequenceActive
    global videoSettingsSequence
    global videoSettingsSequenceIndex

    SetTimer(ProcessMaxVideoSettingsStep, 0)

    videoSettingsSequenceActive := false
    videoSettingsSequence := []
    videoSettingsSequenceIndex := 0

    UpdateMainLoopSchedule()
} ; end stopmaxvideosettingssequence

; ==========================================================================================================================================================
; ProcessMaxVideoSettingsStep()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Executes one scheduled step of the maximum-video-settings menu sequence.
;
; Only one key press is performed per invocation. The next invocation is scheduled as a one-shot timer after the current step's configured delay.
;
; This keeps the macro interruptible between every input and allows the same configured hotkey to cancel the sequence immediately.
; ==========================================================================================================================================================
ProcessMaxVideoSettingsStep() {
    global videoSettingsSequenceActive
    global videoSettingsSequence
    global videoSettingsSequenceIndex

    if !videoSettingsSequenceActive {
        return
    } ; end active-state guard

    if !IsNFSFocused() {
        StopMaxVideoSettingsSequence()
        return
    } ; end game-focus guard

    if videoSettingsSequenceIndex < 1
        || videoSettingsSequenceIndex > videoSettingsSequence.Length {

        StopMaxVideoSettingsSequence()
        return
    } ; end sequence bounds guard

    currentStep := videoSettingsSequence[videoSettingsSequenceIndex]

    if !TapMenuKey(currentStep.key) {
        StopMaxVideoSettingsSequence()
        return
    } ; end failed menu-input guard

    if !videoSettingsSequenceActive {
        return
    } ; end cancellation guard

    videoSettingsSequenceIndex++

    if videoSettingsSequenceIndex > videoSettingsSequence.Length {
        StopMaxVideoSettingsSequence()
        return
    } ; end completion branch

    SetTimer(ProcessMaxVideoSettingsStep, -currentStep.delayAfterMs)
} ; end processmaxvideosettingsstep

; ==========================================================================================================================================================
; ApplyMaxVideoSettings(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Starts or cancels NFSMW's maximum-video-settings menu sequence.
; ==========================================================================================================================================================
ApplyMaxVideoSettings(*) {
    global videoSettingsSequenceActive
    global videoSettingsSequence
    global videoSettingsSequenceIndex

    if videoSettingsSequenceActive {
        StopMaxVideoSettingsSequence()
        return
    } ; end cancellation branch

    if !IsNFSFocused() {
        return
    } ; end game-focus guard

    ReleaseHeldOutputsQuietly()

    videoSettingsSequence := BuildMaxVideoSettingsSequence()

    videoSettingsSequenceIndex := 1
    videoSettingsSequenceActive := true

    DisarmEdgeInputs()
    ClearStallDetectionState()
    ClearSequentialBrakeHoldTimer()

    UpdateMainLoopSchedule()

    SetTimer(ProcessMaxVideoSettingsStep, -200)
} ; end applymaxvideosettings


; ==========================================================================================================================================================
; SECTION 19: AUXILIARY INPUT / SYNC HANDLERS
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; HandlePaddleSync()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; This function does not send any shift key.
; The game already receives the paddle input directly.
;
; Updates RealManual's best-known game gear when the game's native paddle
; shifters are used.
;
; Paddle synchronization is active in both H-pattern and sequential modes.
; The game receives the paddle input directly; RealManual only mirrors the
; resulting gear change into virtualGear.
; ==========================================================================================================================================================
HandlePaddleSync() {
    global virtualGear
    global maxForwardGear
    global paddleUpshiftButton, paddleDownshiftButton
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global paddleSyncArmed

    upshiftReadable := TryGetInputState(paddleUpshiftButton, &paddleUpshiftPressed)
    downshiftReadable := TryGetInputState(paddleDownshiftButton, &paddleDownshiftPressed)

    if !upshiftReadable || !downshiftReadable {
        paddleSyncArmed := false
        lastPaddleUpshiftPressed := false
        lastPaddleDownshiftPressed := false
        return
    } ; end unreadable paddle guard

    if !paddleSyncArmed {
        if !paddleUpshiftPressed && !paddleDownshiftPressed {
            paddleSyncArmed := true
            lastPaddleUpshiftPressed := false
            lastPaddleDownshiftPressed := false
        }

        return
    } ; end paddle re-arm gate

    if paddleUpshiftPressed && !lastPaddleUpshiftPressed {
        previousGear := virtualGear
        virtualGear := Min(virtualGear + 1, maxForwardGear)

        if virtualGear != previousGear {
            RecordShift(virtualGear)
        }
    } ; end paddle upshift edge

    if paddleDownshiftPressed && !lastPaddleDownshiftPressed {
        previousGear := virtualGear
        virtualGear := Max(virtualGear - 1, 0)

        if virtualGear != previousGear {
            RecordShift(virtualGear)
        }
    } ; end paddle downshift edge

    lastPaddleUpshiftPressed := paddleUpshiftPressed
    lastPaddleDownshiftPressed := paddleDownshiftPressed
} ; end handlepaddlesync

; ==========================================================================================================================================================
; HandleKeyboardShiftSync()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Mirrors physical use of NFSMW's configured keyboard upshift/downshift keys into RealManual's tracked virtualGear.
;
; This function doesn't send any shift command. The physical keyboard input is already received directly by NFSMW.
;
; Physical-state reads are required so RealManual does not mistake its own synthetic shiftUpKey / shiftDownKey output for driver keyboard input.
; ==========================================================================================================================================================
HandleKeyboardShiftSync() {
    global virtualGear
    global maxForwardGear
    global shiftUpKey, shiftDownKey

    global keyboardShiftSyncArmed
    global lastKeyboardUpshiftPressed, lastKeyboardDownshiftPressed

    upshiftReadable := TryGetPhysicalKeyState(shiftUpKey, &keyboardUpshiftPressed)

    downshiftReadable := TryGetPhysicalKeyState(shiftDownKey, &keyboardDownshiftPressed)

    if !upshiftReadable || !downshiftReadable {
        keyboardShiftSyncArmed := false
        lastKeyboardUpshiftPressed := false
        lastKeyboardDownshiftPressed := false

        return
    } ; end unreadable keyboard-shift guard

    if !keyboardShiftSyncArmed {
        if !keyboardUpshiftPressed && !keyboardDownshiftPressed {
            keyboardShiftSyncArmed := true
            lastKeyboardUpshiftPressed := false
            lastKeyboardDownshiftPressed := false
        }

        return
    } ; end keyboard-shift re-arm gate

    if keyboardUpshiftPressed && !lastKeyboardUpshiftPressed {
        previousGear := virtualGear
        virtualGear := Min(virtualGear + 1, maxForwardGear)

        if virtualGear != previousGear {
            RecordShift(virtualGear)
        }
    } ; end physical keyboard upshift

    if keyboardDownshiftPressed && !lastKeyboardDownshiftPressed {
        previousGear := virtualGear
        virtualGear := Max(virtualGear - 1, 0)

        if virtualGear != previousGear {
            RecordShift(virtualGear)
        }
    } ; end physical keyboard downshift

    lastKeyboardUpshiftPressed := keyboardUpshiftPressed
    lastKeyboardDownshiftPressed := keyboardDownshiftPressed
} ; end handlekeyboardshiftsync

; ==========================================================================================================================================================
; HandleHandbrake()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Combines all active handbrake sources into the game's digital handbrake key.
;
; Handbrake sources:
;   analog handbrake axis
;   optional shifter handbrake
;   forced handbrake while the simulated engine is stalled/off
;
; An unconfigured or unavailable analog handbrake safely reports inactive.
; ==========================================================================================================================================================
HandleHandbrake() {
    global engineStalled
    global handbrakeKey, handbrakeHeld

    handbrakeRequested := engineStalled
        || IsAnalogHandbrakeActive()
        || IsShifterHandbrakeActive()

    if handbrakeRequested {
        if !handbrakeHeld {
            if TrySetOutputKeyState(handbrakeKey, true) {
                handbrakeHeld := true
            }
        } ; end press guard
    } else {
        if handbrakeHeld {
            if TrySetOutputKeyState(handbrakeKey, false) {
                handbrakeHeld := false
            }
        } ; end release guard
    } ; end requested-state branch
} ; end handlehandbrake

; ==========================================================================================================================================================
; HandleReverseAssist(clutchPressed, combinedPedalValue, selectedGear := -2)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Adds a digital NFSMW reverse-key hold on top of RealManual's normal reverse
; behavior.
;
; Reverse assist uses separate engagement and release conditions:
;
;   assist inactive:
;       brake must pass ReverseAssist.EngageBrakeThreshold before engagement
;
;   assist active:
;       remains active while the brake pedal is still considered engaged
;       releases only when IsBrakePedalActive() reports brake release
;
; Clutch behavior:
;   pressing the clutch always disables reverse assist
;   NFSMW then handles brake/reverse from the analog pedal normally
;
; H-pattern mode:
;   requires physical reverse selection
;   requires a successful direct MW2005-HShifter reverse command
;
; Sequential mode:
;   requires the sequential brake-hold reset to have triggered
;   requires that reset sequence to have begun outside neutral
;   requires the tracked gear to remain non-neutral
; ==========================================================================================================================================================
HandleReverseAssist(clutchPressed, combinedPedalValue, selectedGear := -2) {
    global enableReverseAssist
    global transmissionIsSequential
    global reverseKey
    global reverseAssistHeld
    global reverseCommandLatched
    global brakeHoldResetTriggered
    global sequentialReverseAssistEligible
    global virtualGear

    if !enableReverseAssist || clutchPressed {
        ReleaseReverseAssistQuietly()
        return
    } ; end feature / clutch gate

    if reverseAssistHeld {
        brakeConditionMet :=
            IsBrakePedalActive(combinedPedalValue)
    } else {
        brakeConditionMet := IsBrakePressedForReverseAssist(combinedPedalValue)
    } ; end brake engagement / release state

    reverseAssistRequested := false
    if brakeConditionMet {
        ; Sequential Mode
        if transmissionIsSequential {
            reverseAssistRequested :=
                brakeHoldResetTriggered
                && sequentialReverseAssistEligible
                && virtualGear != 0

        ; H-Pattern Mode
        } else {
            reverseAssistRequested := selectedGear = -1 && reverseCommandLatched
        }
    } ; end assist eligibility

    if reverseAssistRequested {
        if !reverseAssistHeld {
            if TrySetOutputKeyState(reverseKey, true) {
                reverseAssistHeld := true
            }
        } ; end press guard

    } else {

        ReleaseReverseAssistQuietly()
    } ; end requested-state branch

} ; end handlereverseassist


; ==========================================================================================================================================================
; SECTION 20: STALL / ENGINE OFF/ON SIMULATION LOGIC
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; ShouldSuppressStallForBrakeReset()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Protects sequential-mode reversing from first-gear stall detection after the
; brake-hold gear-reset heuristic has forced virtual gear 1.
;
; Protection has two phases:
;
;   1. Brake still held:
;      suppress stalling indefinitely while reverse/brake input remains active.
;
;   2. Brake released:
;      start BrakeResetStallGraceMs and continue suppressing stalling until the configured grace period expires.
;
; Returns true while stall detection should be skipped.
; ==========================================================================================================================================================
ShouldSuppressStallForBrakeReset(combinedPedalValue) {
    global transmissionIsSequential
    global enableBrakeHoldGearReset
    global brakeResetStallGraceActive
    global brakeResetReleaseTime
    global brakeResetStallGraceMs

    if !brakeResetStallGraceActive {
        return false
    } ; end inactive guard

    if !transmissionIsSequential || !enableBrakeHoldGearReset {
        ClearBrakeResetStallGraceState()
        return false
    } ; end feature-state guard

    if IsBrakePedalActive(combinedPedalValue) {
        brakeResetReleaseTime := 0
        return true
    } ; end brake-held protection

    if brakeResetReleaseTime = 0 {
        brakeResetReleaseTime := A_TickCount
        return true
    } ; end release detection

    graceMs := Max(0, brakeResetStallGraceMs)

    if A_TickCount - brakeResetReleaseTime < graceMs {
        return true
    } ; end post-release grace period

    brakeResetStallGraceActive := false
    brakeResetReleaseTime := 0

    return false
} ; end shouldsuppressstallforbrakereset

; ==========================================================================================================================================================
; HandleStallDetection(clutchPressed, clutchValue, combinedPedalValue, selectedGear := -2)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
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
; RequireClutch=0, ClutchActsAsNeutral=0
;    → NO STALLING
;
; RequireClutch=1, ClutchActsAsNeutral=0
;    → clutch protects while pressed
;    → sustained no-throttle stall after sufficient release
;    → no immediate clutch-release stall
;
; RequireClutch=0, ClutchActsAsNeutral=1
;    → clutch protects while pressed
;    → immediate bad-release stall
;    → sustained no-throttle stall
;
; RequireClutch=1, ClutchActsAsNeutral=1
;    → same full stall behavior
;    → clutch also required for restart
; ==========================================================================================================================================================
HandleStallDetection(clutchPressed, clutchValue, combinedPedalValue, selectedGear := -2) {
    global enableStalling, engineStalled, stallDetectionArmed
    global requireClutch, clutchActsAsNeutral
    global clutchReleaseThreshold, throttleThreshold
    global noInputStallDelayMs, noInputStallStartTime
    global stallSuppressedUntilShift

    if !enableStalling {
        ClearStallDetectionState()
        return
    } ; end feature gate

    if engineStalled {
        ClearStallDetectionState()
        return
    } ; end stalled guard

    if stallSuppressedUntilShift {
        ClearStallDetectionState()
        return
    } ; end new-game stall suppression

    if ShouldSuppressStallForBrakeReset(combinedPedalValue) {
        ClearStallDetectionState()
        return
    } ; end sequential brake-reset stall protection

    if !IsFirstGearSelectedForStall(combinedPedalValue, selectedGear) {
        ClearStallDetectionState()
        return
    } ; end first-gear gate

    ; Stall simulation only applies when at least one clutch-related feature participates in the transmission model.
    clutchParticipatesInStallLogic := requireClutch || clutchActsAsNeutral

    if !clutchParticipatesInStallLogic {
        ClearStallDetectionState()
        return
    } ; end clutch participation gate


    ; Only clutch-to-neutral enables the immediate clutch-release stall.
    clutchReleaseStallEnabled := clutchActsAsNeutral

    ; Clutch Protection
    if clutchParticipatesInStallLogic {
        if clutchPressed {
            stallDetectionArmed := clutchReleaseStallEnabled
            ; A pressed clutch disconnects the transmission, so the sustained first-gear no-throttle timer cannot continue.
            noInputStallStartTime := 0

            return
        } ; end clutch-held branch

        clutchReleasePercent := ReadClutchReleasePercent(clutchValue)

        if clutchReleasePercent < clutchReleaseThreshold {
            ; The clutch is still sufficiently depressed to prevent the engine from being treated as fully coupled to first gear.
            noInputStallStartTime := 0

            return
        } ; end clutch release threshold guard
    }

    throttlePercent := ReadThrottlePercentForStall(combinedPedalValue)

    if clutchReleaseStallEnabled && stallDetectionArmed {
        ClearStallDetectionState()

        if throttlePercent < throttleThreshold {
            StallEngine()
        } ; end insufficient throttle branch

        return
    } ; end clutch-release evaluation

    ; Sufficient throttle cancels the sustained first-gear stall timer.
    if throttlePercent >= throttleThreshold {
        noInputStallStartTime := 0
        return
    } ; end throttle guard

    ; First gear is selected, the clutch is no longer protecting the engine, and throttle is insufficient. Start or continue the sustained stall timer.
    if noInputStallStartTime = 0 {
        noInputStallStartTime := A_TickCount
    } ; end timer start

    requiredDelayMs := Max(0, noInputStallDelayMs)

    if A_TickCount - noInputStallStartTime >= requiredDelayMs {
        noInputStallStartTime := 0
        StallEngine()
    } ; end sustained no-input stall
} ; end handlestalldetection

; ==========================================================================================================================================================
; EnterEngineOffState(playStallJerk, statusMessage)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
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
; ==========================================================================================================================================================
EnterEngineOffState(playStallJerk, statusMessage) {
    global engineStalled
    global virtualGear
    global pendingSequentialShiftCount
    global sequentialShifterArmed
    global lastStallNeutralSendTime
    global statsLastGear

    if engineStalled {
        return
    } ; end duplicate engine-off guard

    engineStalled := true
    ClearStallDetectionState()
    ReleaseReverseAssistQuietly()

    if playStallJerk {
        TapThrottleBlip() ; brief jerk only when the engine actually stalls
    } ; end stall jerk

    SendGearToMod(0, true) ; forces neutral

    virtualGear := 0
    statsLastGear := 0
    pendingSequentialShiftCount := 0

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()

    sequentialShifterArmed := false
    lastStallNeutralSendTime := A_TickCount

    HandleHandbrake()
    ShowToolTipMessage(statusMessage)
} ; end enterengineoffstate

; ==========================================================================================================================================================
; StallEngine()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Enters the engine-off state after a simulated first-gear stall and records one stall for that engine-state transition.
; ==========================================================================================================================================================
StallEngine() {
    global engineStalled

    if engineStalled {
        return
    } ; end duplicate stall guard

    EnterEngineOffState(true, "stalled")
    RecordStall()
} ; end stallengine

; ==========================================================================================================================================================
; ShutOffEngine()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Manually enters the same engine-off state as a stall, but without producing the simulated forward jerk.
; ==========================================================================================================================================================
ShutOffEngine() {
    EnterEngineOffState(false, "engine shut off")
} ; end shutoffengine

; ==========================================================================================================================================================
; MaintainStalledState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Holds the handbrake and periodically reasserts neutral while stalled.
;
; Periodic neutral prevents the game from leaving neutral after its built-in brake-to-reverse and automatic first-gear behavior.
;
; Returns:
;   true  = engine is stalled/off and normal transmission handling must stop
;   false = engine is running
; ==========================================================================================================================================================
MaintainStalledState() {
    global engineStalled
    global neutralResendMs
    global lastStallNeutralSendTime

    if !engineStalled {
        return false
    } ; end stalled-state check

    HandleHandbrake() ; preserves forced handbrake while stalled
    resendInterval := Max(50, neutralResendMs)

    if A_TickCount - lastStallNeutralSendTime >= resendInterval {
        SendGearToMod(0, true) ; force is required because lastSentGear is already zero
        lastStallNeutralSendTime := A_TickCount
    } ; end neutral keepalive branch

    return true
} ; end maintainstalledstate

; ==========================================================================================================================================================
; TryRestartEngine()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Restart requires:
;   engine currently stalled
;   physical shifter in neutral
;   clutch nearly fully pressed (if RequireClutch = true)
; ==========================================================================================================================================================
TryRestartEngine(*) {
    global enableStalling, engineStalled, requireClutch
    global virtualGear, pendingSequentialShiftCount
    global lastStallNeutralSendTime
    global sequentialShifterArmed
    global statsLastGear

    if !enableStalling || !engineStalled {
        return
    } ; end restart-state guard

    if !IsPhysicalShifterNeutral() {
        ShowToolTipMessage("restart blocked: shifter not neutral")
        return
    } ; end neutral requirement

    if requireClutch && !IsClutchFullyPressedForRestart(ReadClutchAxis()) {
        ShowToolTipMessage("restart blocked: press clutch fully")
        return
    } ; end optional clutch requirement

    SendGearToMod(0, true) ; ensures the game is in neutral before restart
    TapThrottleBlip() ; simulated engine-start rev
    ClearStallDetectionState()

    engineStalled := false
    virtualGear := 0
    statsLastGear := 0
    lastStallNeutralSendTime := 0
    pendingSequentialShiftCount := 0

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()

    sequentialShifterArmed := true

    HandleHandbrake() ; removes the forced engine-off handbrake request
    ShowToolTipMessage("engine started")
} ; end tryrestartengine

; ==========================================================================================================================================================
; HandleIgnitionButton(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Acts as a simulated ignition switch.
; ==========================================================================================================================================================
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


; ==========================================================================================================================================================
; SECTION 21: H-PATTERN TRANSMISSION LOGIC
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; HandleHPatternTransmission(clutchPressed, combinedPedalValue, selectedGear)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Handles all physical H-pattern transmission behavior, including reverse.
;
; selectedGear is sampled once by MainLoop and passed into this function so transmission handling and stall detection use the same physical snapshot.
;
; Forward gears:
;   no clutch required:
;       a physical shifter-position change applies that gear immediately
;
;   clutch required:
;       forward shifter movement alone does not engage the new gear clutch release forces the CURRENT physical shifter position
;
; Clutch participation:
;   if either RequireClutch or ClutchActsAsNeutral is enabled, clutch release always makes the current physical H-shifter position authoritative.
;
; Clutch-to-neutral:
;   clutch press sends neutral once
;   clutch release forces the current physical H-shifter position
;
; Neutral:
;   moving the physical shifter into neutral always sends neutral immediately, regardless of clutch requirement
;
; Reverse:
;   physical reverse gate + active brake pedal sends MW2005-HShifter command 0 once for that brake engagement.
;
; Paddle synchronization:
;   native paddle shifts may temporarily make virtualGear differ from the physical H-shifter position. 
;   A stationary physical shifter does not overwrite that paddle-synchronized state.
;
; Unknown shifter state:
;   selectedGear = -2 means the physical state could not be determined safely.
;   No gear command or physical-position history update occurs in that case.
; ==========================================================================================================================================================
HandleHPatternTransmission(clutchPressed, combinedPedalValue, selectedGear) {
    global requireClutch, clutchActsAsNeutral
    global lastClutchPressed, clutchNeutralSent
    global virtualGear
    global maxForwardGear
    global reverseCommandLatched
    global lastHPatternSelectedGear
    global lastSentGear
    global statsLastGear

    if selectedGear = -2 {
        return
    } ; end unknown shifter-state guard

    if selectedGear = -1 {
        lastHPatternSelectedGear := -1

        ; Reverse abandons any incomplete forward-gear clutch transaction.
        ClearClutchTransactionState()

        if IsBrakePedalActive(combinedPedalValue) {
            if !reverseCommandLatched {
                if SendGearToMod(-1, true) {
                    RecordShift(-1)
    
                    reverseCommandLatched := true
                } ; end successful reverse command
            } ; end reverse command latch
        } else {
            ; After a successful direct reverse command, NFSMW returns to first when the brake is released even while the physical shifter remains in reverse.
            ; Reconcile the tracked game state without counting that automatic return as a driver shift.
            if lastSentGear = -1 {
                virtualGear := 1
                statsLastGear := 1
            }
            reverseCommandLatched := false
        }

        return
    } ; end reverse gear

    reverseCommandLatched := false

    ; Normalize Forward Gear Limit
    selectedGear := selectedGear > maxForwardGear ? maxForwardGear : selectedGear

    ; Physical H-Pattern Movement Detection
    previousHPatternSelectedGear := lastHPatternSelectedGear
    physicalSelectionChanged := selectedGear != previousHPatternSelectedGear
    lastHPatternSelectedGear := selectedGear

    ; Clutch State Model
    clutchParticipates :=
        requireClutch || clutchActsAsNeutral

    clutchReleaseEdge :=
        clutchParticipates
        && lastClutchPressed
        && !clutchPressed

    ; Physical Neutral
    ; Neutral is always allowed without requiring the clutch.
    if selectedGear = 0 {
        ; Clutch -> Neutral
        if clutchActsAsNeutral && clutchPressed {
            if !clutchNeutralSent {
                ; Force because native paddle input may have changed the game's actual gear without changing lastSentGear.
                if SendGearToMod(0, true) {
                    virtualGear := 0
                    clutchNeutralSent := true
                } ; end successful neutral command
            } ; end neutral send branch

            lastClutchPressed := true
            return
        } ; end clutch-neutral held branch

        ; Clutch Release While Physical Shifter Is Neutral
        if clutchReleaseEdge {
            if SendGearToMod(0, true) {
                virtualGear := 0
                ClearClutchTransactionState()
            } ; end successful neutral command
            return
        } ; end neutral clutch-release branch

        ; Physical Movement Into Neutral
        if physicalSelectionChanged {
            if SendGearToMod(0, true) {
                virtualGear := 0
            } else {
                ; The neutral command did not succeed
                lastHPatternSelectedGear := previousHPatternSelectedGear
            }
        } ; end physical neutral transition

        ; A clutch-required configuration still needs to remember that the clutch is currently held, even though neutral itself is immediate.
        if clutchParticipates {
            lastClutchPressed := clutchPressed
        }

        return
    } ; end physical neutral branch

    ; Clutch -> Neutral While Forward Gear Is Selected
    if clutchActsAsNeutral && clutchPressed {
        if !clutchNeutralSent {
            ; Force neutral because native paddle shifting can make the actual game gear differ from lastSentGear.
            if SendGearToMod(0, true) {
                virtualGear := 0
                clutchNeutralSent := true
            } ; end successful neutral command

        } ; end neutral send branch

        lastClutchPressed := true
        return
    } ; end clutch-neutral held branch

    ; Clutch Required, Forward Gear Selected
    if requireClutch && clutchPressed {
        lastClutchPressed := true
        return
    } ; end clutch-required held branch

    ; Clutch Release
    ; If either clutch feature participates, clutch release always makes the CURRENT physical H-shifter position authoritative.
    ; Clutch release always uses the current physical selector position.
    if clutchReleaseEdge {
        if SendGearToMod(selectedGear,true) {
            ; Only a successfully applied direct gear becomes authoritative.
            virtualGear := selectedGear
    
            ; Clutch release has now made the CURRENT physical H-pattern gear authoritative. 
            ; Record it as a shift only if it differs from the last driver-selected gear known by the statistics subsystem.
            RecordShift(selectedGear)
    
            ClearClutchTransactionState()
        } ; end successful clutch-release engagement
        return
    } ; end clutch-release branch

    ; Without RequireClutch, moving the physical H-shifter applies the newly selected gear immediately.
    if !requireClutch {
        if physicalSelectionChanged {
            if SendGearToMod(selectedGear, true) {
                virtualGear := selectedGear

                RecordShift(selectedGear)
            } else {
                ; Restore the previous physical-history state so the same physical selection can be retried on the next scan.
                lastHPatternSelectedGear := previousHPatternSelectedGear
            } ; end direct gear result
        } ; end physical forward transition

        return
    } ; end no-clutch-required branch

} ; end handlehpatterntransmission


; ==========================================================================================================================================================
; SECTION 22: SEQUENTIAL TRANSMISSION LOGIC
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; HandleSequentialBrakeHoldReset()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Implements a recovery heuristic for sequential mode.
;
; Timer Logic:
;   brake pressed -> store brakeHoldStartTime -> measure elapsed time
;   -> elapsed >= brakeHoldResetMs -> trigger reset once
;
; Reset Actions:
;   virtualGear := 1
;   SendGearToMod(1, true)
;
; Both the script state and game state are updated together to prevent desync.
;
; Stall Protection:
;   Once the reset fires, stall detection is suppressed while the brake remains
;   held. After the brake is released, a short grace period begins before
;   normal first-gear stall detection is allowed again.
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
; ==========================================================================================================================================================
HandleSequentialBrakeHoldReset(clutchPressed, combinedPedalValue) {
    global transmissionIsSequential
    global enableBrakeHoldGearReset
    global brakeHoldResetMs
    global brakeHoldStartTime
    global brakeHoldResetTriggered
    global virtualGear
    global brakeResetStallGraceActive
    global brakeResetReleaseTime
    global statsLastGear
    global pendingSequentialShiftCount
    global sequentialShifterArmed
    global clutchActsAsNeutral
    global sequentialReverseAssistEligible

    if !transmissionIsSequential || !enableBrakeHoldGearReset {
        ClearSequentialBrakeResetState()
        return
    } ; end feature gate

    if IsBrakePressedForSequentialReset(combinedPedalValue) {
        if brakeHoldStartTime = 0 {
            brakeHoldStartTime := A_TickCount
        } ; end start-time branch

        ; Measure how long the hard-brake condition has been continuously active.
        heldMs := A_TickCount - brakeHoldStartTime

        if heldMs >= brakeHoldResetMs && !brakeHoldResetTriggered {
            sequentialReverseAssistEligible := virtualGear != 0

            ; Establish first gear as the new authoritative target.
            virtualGear := 1
            statsLastGear := 1

            pendingSequentialShiftCount := 0
            sequentialShifterArmed := false

            ; Preserve clutch-to-neutral if the clutch is currently holding the game in neutral. 
            ; First gear will be re-engaged normally on clutch release.
            if !(clutchActsAsNeutral && clutchPressed) {
                SendGearToMod(1, true)
            }

            brakeHoldResetTriggered := true
            brakeResetStallGraceActive := true
            brakeResetReleaseTime := 0

            ShowToolTipMessage("sequential gear reset to 1 after brake hold")
        }
    } else {
        ; Hard-braking condition is no longer present, so an unfinished hold timer must restart if hard braking begins again.
        brakeHoldStartTime := 0

        if !IsBrakePedalActive(combinedPedalValue) {
            ; The brake has actually been released, so the one-shot reset may be armed again for the next brake-hold sequence.
            brakeHoldResetTriggered := false
            sequentialReverseAssistEligible := false

            if brakeResetStallGraceActive && brakeResetReleaseTime = 0 {
                brakeResetReleaseTime := A_TickCount
            } ; end grace release timestamp
        } ; end full-release rearm
    } ; end brake state branch
} ; end handlesequentialbrakeholdreset

; ==========================================================================================================================================================
; TrySequentialShift(direction, clutchPressed)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Handles one accepted sequential shift request.
;
; Immediate-output modes commit virtualGear and statistics ONLY after the
; required game output succeeds.
;
; Deferred clutch modes may update virtualGear immediately because the accepted
; lever movement itself establishes the new tracked target gear; the game
; command is intentionally deferred until clutch release.
;
; Sequential behavior by clutch configuration:
;
; RequireClutch=0, ClutchActsAsNeutral=0:
;   send the normal game shift immediately
;   commit virtualGear only after successful output
;
; RequireClutch=1, ClutchActsAsNeutral=0:
;   accept shifts only while clutch is pressed
;   accumulate net movement for clutch release
;
; RequireClutch=0, ClutchActsAsNeutral=1:
;   clutch released -> send immediate game shift, then commit target
;   clutch pressed  -> update only the deferred direct-gear target
;
; RequireClutch=1, ClutchActsAsNeutral=1:
;   accept shifts only while clutch is pressed
;   update the deferred direct-gear target while the game remains neutral
; ==========================================================================================================================================================
TrySequentialShift(direction, clutchPressed) {
    global requireClutch, clutchActsAsNeutral
    global virtualGear, maxForwardGear
    global shiftUpKey, shiftDownKey
    global pendingSequentialShiftCount

    ; Resolve Requested Direction
    previousGear := virtualGear

    if direction = "up" {
        targetGear := Min(previousGear + 1, maxForwardGear)
        shiftKey := shiftUpKey
    } else if direction = "down" {
        targetGear := Max(previousGear - 1, 0)
        shiftKey := shiftDownKey
    } else {
        return false
    } ; end direction resolution

    if targetGear = previousGear {
        ; Example:
        ;   6 -> up
        ;   N -> down
        ; No real gear change exists, so no output or statistic is generated.
        return false
    } ; end unchanged target guard

    ; Clutch -> Neutral Model
    if clutchActsAsNeutral {

        ; When the clutch is mandatory, an unclutched shift attempt is ignored.
        if requireClutch && !clutchPressed {
            return false
        } ; end clutch-required gate

        if !clutchPressed {
            if !TapKey(shiftKey) {
                return false
            } ; end failed immediate output
        } ; end immediate passthrough

        virtualGear := targetGear

        RecordShift(virtualGear)

        return true
    } ; end clutch-neutral model

    ; Clutch-Required Passthrough Model
    if requireClutch {
        if !clutchPressed {
            return false
        } ; end clutch gate

        if shiftKey = "" {
            return false
        } ; end unavailable queued-output guard

        virtualGear := targetGear

        pendingSequentialShiftCount += targetGear - previousGear
        pendingSequentialShiftCount := Max(-maxForwardGear, Min(maxForwardGear, pendingSequentialShiftCount))

        RecordShift(virtualGear)

        return true
    } ; end clutch-required passthrough model

    if !TapKey(shiftKey) {
        return false
    } ; end failed immediate output

    virtualGear := targetGear

    RecordShift(virtualGear)

    return true
} ; end trysequentialshift

; ==========================================================================================================================================================
; SendQueuedSequentialShifts(shiftCount)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends the net sequential shift requests accumulated while the clutch was held.
;
; Positive count:
;   sends queued upshifts
;
; Negative count:
;   sends queued downshifts
;
; Zero:
;   sends nothing
;
; queuedShiftDelayMs is applied only BETWEEN queued shifts. No delay is needed
; after the final shift because there is no following command to separate.
; ==========================================================================================================================================================
SendQueuedSequentialShifts(shiftCount) {
    global shiftUpKey, shiftDownKey, queuedShiftDelayMs

    if shiftCount = 0 {
        return
    } ; end empty queue guard

    shiftKey := shiftCount > 0 ? shiftUpKey : shiftDownKey

    shiftTotal := Abs(shiftCount)

    Loop shiftTotal {
        TapKey(shiftKey)

        if A_Index < shiftTotal {
            Sleep queuedShiftDelayMs
        }
    } ; end queued shift loop
} ; end sendqueuedsequentialshifts

; ==========================================================================================================================================================
; HandleSequentialTransmission(clutchPressed)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
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

; Shifter-handbrake arbitration:
;   if its configured slot overlaps neither sequential shift binding, both
;   sequential directions remain fully usable
;
;   if its configured slot overlaps either sequential shift binding, the entire
;   sequential H-shifter pair is intentionally suppressed
;
; Sequential shifter inputs fail closed:
;   if either shift input cannot be read, the shifter is disarmed and must
;   return to a successfully observed neutral position before shifting resumes.
;
; ==========================================================================================================================================================
HandleSequentialTransmission(clutchPressed) {
    global clutchActsAsNeutral
    global virtualGear
    global lastUpshiftPressed, lastDownshiftPressed
    global lastClutchPressed, clutchNeutralSent
    global sequentialShifterArmed
    global requireClutch
    global pendingSequentialShiftCount
    global activeSequentialUpshiftButton
    global activeSequentialDownshiftButton
    global enableShifterHandbrake
    global shifterHandbrakeConflict

    ; Clutch -> Neutral
    if clutchActsAsNeutral && clutchPressed && !clutchNeutralSent {
        if SendGearToMod(0, true) {
            clutchNeutralSent := true
        } ; end successful neutral command
    } ; end clutch-neutral branch

    ; Read Sequential Shifter Inputs
    sequentialInputsReadable := true
    upshiftPressed := false
    downshiftPressed := false

    if enableShifterHandbrake && shifterHandbrakeConflict { ; suppresses the sequential pair when the active handbrake slot owns either shift input
        sequentialShifterArmed := true

    } else { ; reads both sequential directions normally when the handbrake overlaps neither configured shift slot
        upshiftReadable := TryGetInputState(activeSequentialUpshiftButton, &upshiftPressed)
        downshiftReadable := TryGetInputState(activeSequentialDownshiftButton, &downshiftPressed)

        if !upshiftReadable || !downshiftReadable { ; fails closed when either half of the required sequential pair cannot be determined safely
            sequentialInputsReadable := false ; prevents an unreadable scan from satisfying the neutral re-arm condition
            sequentialShifterArmed := false ; requires a future successfully observed neutral position before another sequential shift
            lastUpshiftPressed := false ; clears stale upshift edge history because the physical state is no longer trustworthy
            lastDownshiftPressed := false
            upshiftPressed := false ; forces the local unreadable upshift state inactive for this scan
            downshiftPressed := false
        } ; end unreadable sequential-input guard
    } ; end sequential-shifter availability branch

    ; Sequential Shifter Re-Arm
    if sequentialInputsReadable && !upshiftPressed && !downshiftPressed { ; accepts only a trustworthy scan where neither sequential direction is active
        sequentialShifterArmed := true ; marks the sequential lever ready to accept the next physical movement
        lastUpshiftPressed := false ; clears old upshift history so the next press creates exactly one new edge
        lastDownshiftPressed := false
    } ; end neutral-arm branch

    ; Shifter Arming Gate
    if !sequentialShifterArmed { ; blocks physical shift processing until a safe neutral-return state has been established
        if lastClutchPressed && !clutchPressed { ; still recognizes clutch release while the sequential lever itself remains disarmed

            if clutchActsAsNeutral { ; handles clutch release in the direct virtual-gear model
                SendGearToMod(virtualGear, true) ; re-engages the currently tracked forward gear after clutch-neutral disengages

            } else if requireClutch && pendingSequentialShiftCount != 0 { ; completes an already-queued passthrough shift transaction on clutch release
                SendQueuedSequentialShifts(pendingSequentialShiftCount) ; emits the accumulated net upshift/downshift requests in order
                pendingSequentialShiftCount := 0 ; clears the transaction after its queued commands have been emitted
            } ; end clutch-release behavior branch

            clutchNeutralSent := false ; prepares clutch-neutral state for the next independent clutch press
        } ; end clutch release while unarmed

        lastClutchPressed := clutchPressed ; preserves current clutch state so the next scan can detect a release edge correctly
        return ; stops here because the physical sequential lever is not currently allowed to create new shift requests
    } ; end arming gate

    ; Sequential Shift Edges
    if upshiftPressed && !lastUpshiftPressed { ; accepts only the rising edge of the physical upshift input
        TrySequentialShift("up", clutchPressed) ; routes one upshift request through the active clutch/sequential transmission model
    } ; end upshift branch

    if downshiftPressed && !lastDownshiftPressed { ; accepts only the rising edge of the physical downshift input
        TrySequentialShift("down", clutchPressed) ; routes one downshift request through the active clutch/sequential transmission model
    } ; end downshift branch

    ; Clutch Release
    if lastClutchPressed && !clutchPressed { ; detects the transition from clutch pressed to clutch released
        if clutchActsAsNeutral { ; restores direct gear engagement after temporary clutch-neutral operation
            SendGearToMod(virtualGear, true) ; forces the tracked virtual gear back into MW2005-HShifter

        } else if requireClutch && pendingSequentialShiftCount != 0 { ; completes queued passthrough shifts only when clutch gating is enabled
            SendQueuedSequentialShifts(pendingSequentialShiftCount) ; sends the net shift requests accumulated during the clutch hold
            pendingSequentialShiftCount := 0 ; clears the completed queued-shift transaction
        } ; end clutch-release behavior branch

        clutchNeutralSent := false ; allows the next clutch press to send a fresh neutral command when required
    } ; end release branch

    if upshiftPressed || downshiftPressed { ; stores physical state only while one of the sequential directions is actively selected
        lastUpshiftPressed := upshiftPressed ; remembers whether upshift is currently held for next-scan edge detection
        lastDownshiftPressed := downshiftPressed
    } ; end active sequential-state branch

    lastClutchPressed := clutchPressed ; preserves the current clutch state for release-edge detection on the next scan
} ; end handlesequentialtransmission


; ==========================================================================================================================================================
; SECTION 23: RECOVERY AND MANUAL SYNC
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; SyncGear(gearNumber)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Manually synchronizes RealManual with a fixed MW2005-HShifter gear command.
;
; Gear model:
;   -1  = reverse
;    0  = neutral
;   1-6 = forward gears
;
; Neutral and forward commands update RealManual's tracked gear directly.
;
; Reverse is sent directly to MW2005-HShifter, while virtualGear
; remains at first because NFSMW returns to first when brake-held reverse ends.
;
; Any manual synchronization clears transient shift/clutch state so an older
; queued operation cannot immediately undo the requested synchronization.
; ==========================================================================================================================================================
SyncGear(gearNumber) {
    global virtualGear, maxForwardGear
    global pendingSequentialShiftCount
    global sequentialShifterArmed
    global engineStalled
    global statsLastGear

    if engineStalled {
        return ; manual gear commands cannot bypass the engine-off state
    } ; end engine-off guard

    if gearNumber < -1 || gearNumber > 6 {
        return ; accepts only the fixed H-Shifter gear-command range
    } ; end gear range guard

    pendingSequentialShiftCount := 0

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()
    ClearStallDetectionState()

    ; A currently held sequential lever position must return to neutral before it can modify the newly synchronized gear.
    sequentialShifterArmed := false

    ; Reverse
    if gearNumber = -1 {
        ; Reverse itself is not stored in the sequential virtual-gear model.
        ; First gear is the best-known forward state after NFSMW leaves reverse.
        virtualGear := 1
        statsLastGear := -1
        SendGearToMod(-1, true)
        ShowToolTipMessage("synced gear reverse")
        return
    } ; end reverse synchronization

    ; Neutral / Forward
    if gearNumber > maxForwardGear {
        gearNumber := maxForwardGear
    } ; end gearbox-limit clamp

    virtualGear := gearNumber
    statsLastGear := gearNumber
    SendGearToMod(gearNumber, true)

    if gearNumber = 0 {
        ShowToolTipMessage("synced gear neutral")
    } else {
        ShowToolTipMessage("synced gear " gearNumber)
    } ; end status message

} ; end syncgear

; ==========================================================================================================================================================
; ResetInputs(syncGame := true, showStatus := true)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Restores RealManual to a clean first-gear running state after a race restart,
; unusual transmission/input desynchronization, or a newly launched NFSMW
; process.
;
; Reset actions:
;   establishes first gear as RealManual's known transmission state
;   clears pending clutch and sequential shift transactions
;   clears sequential/paddle edge-detection state
;   re-arms reverse and brake-reset recovery state
;   requires sequential/shifter-handbrake inputs to return to neutral
;   clears the simulated engine-off state
;
; syncGame = true:
;   actively sends first gear to MW2005-HShifter and re-evaluates handbrake output
;
; syncGame = false:
;   changes internal RealManual state only
;   sends no keyboard output to NFSMW/MW2005-HShifter
;   intended for a newly launched game instance that already starts in first gear
;
; showStatus = true:
;   displays the normal reset confirmation tooltip
;
; showStatus = false:
;   performs the reset silently
;
; Stopwatch, statistics counters, and current runtime mode settings are
; intentionally unaffected.
; ==========================================================================================================================================================
ResetInputs(syncGame := true, showStatus := true) {
    global virtualGear
    global pendingSequentialShiftCount
    global sequentialShifterArmed, shifterHandbrakeArmed
    global engineStalled
    global lastStallNeutralSendTime
    global lastHPatternSelectedGear
    global lastSentGear
    global handbrakeHeld
    global statsLastGear
    global stallSuppressedUntilShift
    global reverseAssistHeld

    ; Clear Gear / Shift Transactions
    virtualGear := 1
    statsLastGear := 1

    pendingSequentialShiftCount := 0
    lastHPatternSelectedGear := -2

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()

    ; Require a return to neutral before an already-selected sequential or shifter-handbrake slot can be interpreted as a fresh input.
    sequentialShifterArmed := false
    shifterHandbrakeArmed := false

    ; Clear Engine-Off / Stall State
    engineStalled := false
    lastStallNeutralSendTime := 0

    ClearStallDetectionState()

    stallSuppressedUntilShift := !syncGame

    ; Synchronize Game / Output State
    if syncGame {
        ReleaseReverseAssistQuietly()

        ; Force bypasses the lastSentGear cache because ResetInputs() is deliberately establishing first gear as the authoritative state.
        SendGearToMod(1, true)

        ; Re-evaluate all valid handbrake sources rather than blindly releasing the output. 
        ; A physically pulled analog handbrake should remain active.
        HandleHandbrake()

    } else {

        ; A newly launched NFSMW instance starts in first gear
        lastSentGear := 1

        handbrakeHeld := false
        reverseAssistHeld := false
    } ; end synchronization mode

    if showStatus {
        ShowToolTipMessage("transmission bridge reset to gear 1")
    } ; end status notification

} ; end resetinputs

; ==========================================================================================================================================================
; SECTION 24: NFSMW PROCESS / FOCUS TRACKING
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; IsNFSFocused()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether Need for Speed is currently the active foreground window.
;
; Returns:
;   true  = speed.exe is focused and receiving input
;   false = another application currently has focus
;
; Used to prevent RealManual from reading inputs or sending game commands while
; interacting with another application.
; ==========================================================================================================================================================
IsNFSFocused() {
    return WinActive("ahk_exe speed.exe")
} ; end isnfsfocused

; ==========================================================================================================================================================
; InitializeNFSProcessTracking()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Establishes the NFSMW process that exists when RealManual starts.
;
; An already-running game is treated as the initial known instance rather than as a restart. 
; If the game is not running yet, RealManual simply waits for the first instance to appear.
; ==========================================================================================================================================================
InitializeNFSProcessTracking() {
    global nfsProcessPid
    global nfsProcessSeen

    currentPid := ProcessExist("speed.exe")

    SynchronizeStatsSession(currentPid)

    if currentPid {
        nfsProcessPid := currentPid
        nfsProcessSeen := true
    } else {
        nfsProcessPid := 0
        nfsProcessSeen := false
    } ; end initial process state
} ; end initializenfsprocesstracking

; ==========================================================================================================================================================
; MonitorNFSProcess()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Detects when the current NFSMW process is replaced by a new speed.exe instance.
;
; The first game instance observed after RealManual starts is accepted normally.
; A later instance is treated as a game restart/crash recovery and schedules a transmission-state reset.
;
; The reset itself is deferred to MainLoop() so no H-Shifter command is sent until the replacement game instance is actually focused.
; ==========================================================================================================================================================
MonitorNFSProcess() {
    global nfsProcessPid
    global nfsProcessSeen
    global nfsInstanceResetPending

    currentPid := ProcessExist("speed.exe")

    ; No Game Process Running
    if !currentPid {
        if nfsProcessPid != 0 {
            SynchronizeStatsSession(0)
        } ; end ended-process statistics finalization

        nfsProcessPid := 0

        return
    } ; end no-process branch

    ; First Game Instance
    if !nfsProcessSeen {
        SynchronizeStatsSession(currentPid)

        nfsProcessPid := currentPid
        nfsProcessSeen := true

        return
    } ; end first-instance branch

    ; Game returned after previous instance disappeared
    if nfsProcessPid = 0 {
        SynchronizeStatsSession(currentPid)

        nfsProcessPid := currentPid
        nfsInstanceResetPending := true

        return
    } ; end replacement-after-exit branch

    ; PID changed without observing an empty interval
    if currentPid != nfsProcessPid {
        SynchronizeStatsSession(currentPid)

        nfsProcessPid := currentPid
        nfsInstanceResetPending := true
    } ; end direct replacement branch

} ; end monitornfsprocess


; ==========================================================================================================================================================
; SECTION 25: MAIN LOOP
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; SetMainLoopTimerInterval(intervalMs)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Changes MainLoop's timer interval only when the requested interval differs
; from the interval already scheduled.
;
; intervalMs:
;   > 0 = run MainLoop repeatedly at that interval
;     0 = stop MainLoop
;
; Avoids repeatedly resetting the same AutoHotkey timer from inside the hot
; polling path.
; ==========================================================================================================================================================
SetMainLoopTimerInterval(intervalMs) {
    global mainLoopTimerIntervalMs

    intervalMs := Max(0, intervalMs)

    if intervalMs = mainLoopTimerIntervalMs {
        return
    } ; end unchanged interval guard

    SetTimer(MainLoop, intervalMs)

    mainLoopTimerIntervalMs := intervalMs
} ; end setmainlooptimerinterval

; ==========================================================================================================================================================
; UpdateMainLoopSchedule()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Chooses the appropriate MainLoop timer state from RealManual's current runtime
; context.
;
; Scheduling policy:
;   paused / menu automation = MainLoop stopped
;   NFSMW focused            = normal fast scan interval
;   NFSMW unfocused          = slower idle polling interval
; ==========================================================================================================================================================
UpdateMainLoopSchedule() {
    global scriptPaused
    global videoSettingsSequenceActive
    global scanIntervalMs
    global mainLoopIdleIntervalMs

    if scriptPaused || videoSettingsSequenceActive {
        SetMainLoopTimerInterval(0)
        return
    } ; end suspended-state scheduling

    targetInterval := IsNFSFocused() ? scanIntervalMs : mainLoopIdleIntervalMs

    SetMainLoopTimerInterval(
        targetInterval
    )
} ; end updatemainloopschedule

; ==========================================================================================================================================================
; MainLoop()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Central routing loop for RealManual.
;
; Scheduling:
;   NFSMW focused:
;       runs at scanIntervalMs for responsive input handling
;
;   NFSMW unfocused:
;       runs at mainLoopIdleIntervalMs only to detect refocus
;
;   RealManual paused or menu automation active:
;       timer is stopped
;
; Order of operations:
;   1. pause / menu-automation guard
;   2. focus-transition cleanup and focus guard
;   3. new-process synchronization
;   4. stalled-engine maintenance
;   5. configured paddle / keyboard synchronization and handbrake handling
;   6. H-pattern position snapshot when applicable
;   7. feature-aware pedal snapshot
;   8. active transmission-mode processing
;   9. enabled reverse-assist / stall processing
;
; H-pattern transmission handling evaluates reverse before neutral/forward processing so the physical reverse slot cannot fall through as another state.
; ==========================================================================================================================================================
MainLoop() {
    global transmissionIsSequential
    global scriptPaused
    global lastNFSFocused
    global nfsInstanceResetPending
    global videoSettingsSequenceActive
    global requireClutch
    global clutchActsAsNeutral
    global enableReverseAssist
    global reverseAssistHeld
    global enableBrakeHoldGearReset
    global enableStalling
    global combinedPedalCenter
    global stallSuppressedUntilShift
    global brakeResetStallGraceActive
    global lastSentGear
    global scanIntervalMs
    global mainLoopIdleIntervalMs
    global paddleSyncConfigured
    global keyboardShiftSyncConfigured
    global analogHandbrakeConfigured
    global enableShifterHandbrake
    global handbrakeHeld

    if scriptPaused || videoSettingsSequenceActive {
        return
    }

    nfsFocused := IsNFSFocused()

    if nfsFocused != lastNFSFocused {

        if nfsFocused {
            MonitorNFSProcess()
            SetMainLoopTimerInterval(scanIntervalMs)
        } else {
            ReleaseHeldOutputsQuietly()
            DisarmEdgeInputs()
            ClearStallDetectionState()
            ClearSequentialBrakeHoldTimer()

            SetMainLoopTimerInterval(mainLoopIdleIntervalMs)
        } ; end focus-state branch

        lastNFSFocused := nfsFocused
    } ; end focus transition

    if !nfsFocused {
        return
    }

    ; new NFSMW instance synchronization
    if nfsInstanceResetPending {
        nfsInstanceResetPending := false
        ResetInputs(false, false) ; internal reset

        return
    } ; end new-instance reset

    if MaintainStalledState() {
        return
    }

    if paddleSyncConfigured {
        HandlePaddleSync()
    } ; end paddle-sync routing

    if keyboardShiftSyncConfigured {
        HandleKeyboardShiftSync()
    } ; end keyboard-shift-sync routing

    if analogHandbrakeConfigured || enableShifterHandbrake || handbrakeHeld {
        HandleHandbrake()
    } ; end handbrake routing

    ; physical H-pattern snapshot
    selectedGear := -2

    if !transmissionIsSequential {
        selectedGear := ReadSelectedGear()
    } ; end H-pattern snapshot

    ; pedal input snapshot
    needsClutchSample := requireClutch || clutchActsAsNeutral || enableReverseAssist

    if needsClutchSample {
        clutchValue := ReadClutchAxis()
        clutchPressed := IsClutchPressed(clutchValue)
    } else {
        clutchValue := 100
        clutchPressed := false
    } ; end clutch snapshot

    stallLogicActive := enableStalling && (requireClutch || clutchActsAsNeutral)

    stallNeedsCombinedPedalSample :=
        stallLogicActive
        && !stallSuppressedUntilShift
        && (
            brakeResetStallGraceActive
            || lastSentGear = -1
            || !clutchPressed
        )

    needsCombinedPedalSample :=
        (!transmissionIsSequential && selectedGear = -1)
        || (transmissionIsSequential && enableBrakeHoldGearReset)
        || (enableReverseAssist && !clutchPressed)
        || stallNeedsCombinedPedalSample

    if needsCombinedPedalSample {
        combinedPedalValue := ReadCombinedPedalAxis()
    } else {
        combinedPedalValue := combinedPedalCenter
    } ; end combined pedal snapshot

    if transmissionIsSequential {
        if enableBrakeHoldGearReset {
            HandleSequentialBrakeHoldReset(clutchPressed, combinedPedalValue)
        } ; end sequential brake-reset routing

        HandleSequentialTransmission(clutchPressed)

        if enableReverseAssist || reverseAssistHeld {
            HandleReverseAssist(clutchPressed, combinedPedalValue)
        } ; end reverse-assist routing

        if stallLogicActive {
            HandleStallDetection(clutchPressed, clutchValue, combinedPedalValue)
        } ; end stall-detection routing
    } else {
        HandleHPatternTransmission(clutchPressed, combinedPedalValue, selectedGear)

        if enableReverseAssist || reverseAssistHeld {
            HandleReverseAssist(clutchPressed, combinedPedalValue, selectedGear)
        } ; end reverse-assist routing

        if stallLogicActive {
            HandleStallDetection(clutchPressed, clutchValue, combinedPedalValue, selectedGear)
        } ; end stall-detection routing
    }
} ; end mainloop


; ==========================================================================================================================================================
; SECTION 26: STARTUP
; ==========================================================================================================================================================

OnExit(HandleScriptExit)

InitializeStats()
InitializeNFSProcessTracking()
ApplyStatisticsStartupOptions()

dynamicHotkeyRegistrationResults := RegisterDynamicHotkeys()
ShowStartupInfo()
SetTimer(MonitorNFSProcess, 1000)
UpdateMainLoopSchedule()


; ==========================================================================================================================================================
; SECTION 27: FIXED H-SHIFTER HOTKEYS
; ==========================================================================================================================================================

#HotIf IsNFSFocused()
$0::SyncGear(-1)
$n::SyncGear(0)
$1::SyncGear(1)
$2::SyncGear(2)
$3::SyncGear(3)
$4::SyncGear(4)
$5::SyncGear(5)
$6::SyncGear(6)
#HotIf
