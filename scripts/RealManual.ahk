; ==========================================================================================================================================================
; REALMANUAL SCRIPT LOOKUP
; ==========================================================================================================================================================
;
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
;   Variables and directives:
;     Application: appName, appVersion, configFile
;     Directives: #Requires, #SingleInstance, #UseHook, SendMode, SetKeyDelay
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 2: TRAY MENU SETUP
;   Menu object and actions:
;     Tray object: A_TrayMenu
;     Actions: Reload, ToggleScriptPause, OpenValidationLog, ExitApp
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 3: CONFIG FILE HELPERS
;   Variables:
;     Rule maps: numericConfigRules, booleanConfigRules
;
;   Functions:
;       ConfigRuleKey()
;       TryParseConfigInt()
;       TryParseConfigBool()
;       ReadConfigValue()
;       ReadBool()
;       ReadInt()
;       ReadText()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 4: PROFILE SELECTION, RULE MIRRORING, AND INPUT RESOLUTION
;   Variables:
;     Startup profile: preferredStartupProfileName, activeProfileName, startupProfileSelectionReason
;     Enumeration: autoEnumerateDevices, joystickRoleSlots, profileResolutionWarnings
;     Bindings: resolvedInputBindings, gamepadInputDefinitions, gamepadActivationSettings
;
;   Functions:
;       ProfileSection()
;       RegisterProfileConfigRules()
;       ReadStrictProfileInt()
;       ReadStrictProfileBool()
;       InferGamepadInputKind()
;       StopProfileLoading()
;       EnumerateJoystickDevices()
;       ResolveConfiguredJoystickRoles()
;       ReadPreferredStartupProfile()
;       SelectStartupProfile()
;       InitializeJoystickSlots()
;       ResolveJoystickAlias()
;       ReadInputBinding()
;       LoadGamepadInputDefinitions()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 5: CONFIG LOADING - GENERAL AND HOTKEYS
;   Variables:
;     General: writeStartupLog, enableToolTips, toolTipDurationMs
;     Core hotkeys: helpButton, resetButton, pauseButton, reloadButton, profileToggleButton
;     Transmission toggles: toggleTransmissionModeButton, toggleSequentialShifterInvertButton, toggleMaxForwardGearButton
;     Clutch/engine toggles: toggleClutchRequiredButton, toggleClutchNeutralButton, toggleShifterHandbrakeButton, toggleStallingButton
;     Stopwatch: stopwatchButton, stopwatchLapButton, stopwatchClearButton
;     Stats: statsShiftsButton, statsStallsButton, statsRaceRestartsButton, raceRestartButton
;     Capture/ignition: saveInstantReplayButton, captureScreenshotButton, ignitionButton
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 6: CONFIG LOADING - TRANSMISSION AND CLUTCH
;   Variables:
;     Transmission: startInSequentialMode, transmissionIsSequential, maxForwardGear
;     Clutch options: requireClutch, clutchActsAsNeutral, clutchThreshold
;     Clutch input: clutchAxis, clutchAxisIncreasesWhenPressed
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 7: CONFIG LOADING - PEDALS, GAME KEYS, AND H-PATTERN
;   Variables:
;     Pedal layout: useCombinedPedals, combinedPedalAxis, throttleAxis, brakeAxis
;     Pedal polarity: throttleAxisIncreasesWhenPressed, brakeAxisIncreasesWhenPressed
;     Brake activity: brakeActivePercent
;     H-pattern inputs: gear1Button, gear2Button, gear3Button, gear4Button, gear5Button, gear6Button, reverseButton
;     Game output keys: forwardKey, reverseKey, handbrakeKey, shiftUpKey, shiftDownKey
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 8: CONFIG LOADING - SEQUENTIAL, HANDBRAKE, STALLING, AND REVERSE ASSIST
;   Variables:
;     Sequential inputs: invertSequentialShifter, sequentialUpshiftButton, sequentialDownshiftButton, paddleUpshiftButton, paddleDownshiftButton
;     Brake hold/queue: enableBrakeHoldGearReset, brakeHoldResetMs, brakeResetPercent, queuedShiftDelayMs
;     Handbrake routing: realManualControlsHandbrake, handbrakeAxis, handbrakeAxisIncreasesWhenPulled, handbrakeThreshold
;     Shifter handbrake: enableShifterHandbrake, shifterHandbrakeButton
;     Engine/reverse options: enableStalling, enableReverseAssist, engageBrakePercent
;     Stalling limits: clutchReleaseThreshold, throttleThreshold, restartClutchThreshold
;     Engine timing: neutralResendMs, throttleBlipMs, noInputStallDelayMs, brakeResetStallGraceMs
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 9: CONFIG LOADING - TIMING, STOPWATCH, AND STATISTICS
;   Variables:
;     Input timing: keyHoldMs, scanIntervalMs, mainLoopIdleIntervalMs
;     Stopwatch settings: stopwatchRefreshMs, stopwatchMaxLines
;     Statistics options: trackShifts, trackStalls, trackRaceRestarts, clearAllTimeOnStartup
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 10: RUNTIME STATE VARIABLES
;   Variables:
;     Gear/H-pattern: virtualGear, lastSentGear, lastHPatternSelectedGear, reverseCommandLatched
;     Sequential: pendingSequentialShiftCount, sequentialShifterArmed, paddleSyncArmed
;     Shift edges: lastUpshiftPressed, lastDownshiftPressed, lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
;     Keyboard shift: keyboardShiftSyncArmed, lastKeyboardUpshiftPressed, lastKeyboardDownshiftPressed
;     Clutch state: lastClutchPressed, clutchNeutralSent
;     Handbrake state: shifterHandbrakeArmed, handbrakeHeld
;     Brake hold: brakeHoldStartTime, brakeHoldResetTriggered, brakeResetStallGraceActive, brakeResetReleaseTime
;     Reverse assist: sequentialReverseAssistEligible, reverseAssistHeld
;     Engine state: engineStalled, stallDetectionArmed, stallSuppressedUntilShift, noInputStallStartTime, lastStallNeutralSendTime
;     Script/UI state: lastNFSFocused, scriptPaused, mainLoopTimerIntervalMs, dynamicHotkeyRegistrationResults
;     Game process: nfsProcessPid, nfsProcessSeen, nfsInstanceResetPending
;     Stopwatch state: stopwatchStarted, stopwatchRunning, stopwatchStartTime, stopwatchAccumulatedMs, stopwatchLaps, stopwatchToolTipId
;     Stats storage: statsFile, sessionProcessPid, sessionShiftCount, sessionStallCount, sessionRaceRestartCount
;     All-time stats: allTimeShiftCount, allTimeStallCount, allTimeRaceRestartCount, statsLastGear
;     Stats display: showShiftStats, showStallStats, showRaceRestartStats, statsToolTipId
;     Overlay layout: overlayActivationCounter, stopwatchOverlayOrder, statsOverlayOrder, overlayPrimaryX, overlaySecondaryX, overlayY
;     Gamepad edges: gamepadDigitalInputState, gamepadDigitalInputArmed
;     Profile switching: profileMutableOverrides, profileSwitchInProgress, profileRigHotkeys
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 11: INPUT / OUTPUT MAPS AND BINDING SANITIZATION
;   Variables:
;     Binding maps: hShifterProtocol, gearKeys, reservedProtocolKeys, reservedProtocolVks
;     Derived inputs: activeSequentialUpshiftButton, activeSequentialDownshiftButton, gearButtons
;     Derived flags: paddleSyncConfigured, keyboardShiftSyncConfigured, analogHandbrakeConfigured, shifterHandbrakeConflict, hPatternMappingValid
;
;   Functions:
;       GetReservedProtocolConflict()
;       SanitizeUserConfiguredKey()
;       SanitizeUserConfiguredBindings()
;       RefreshActiveSequentialBindings()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 12: LOW-LEVEL OUTPUT HELPERS & SAFETY
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
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 13: LOW-LEVEL INPUT READERS
;   Functions:
;       TryGetInputState()
;       TryGetPhysicalKeyState()
;       SafeGetKeyState()
;       NormalizeAxisActuation()
;       ReadGamepadActionPercent()
;       ReadGamepadDigitalAction()
;       ReadClutchAxis()
;       ReadProfilePedalSnapshot()
;       TryReadProfileClutch()
;       ReadHandbrakeAxis()
;       IsClutchPressed()
;       ReadSelectedGear()
;       IsBrakePercentAboveThreshold()
;       IsBrakePedalActive()
;       IsBrakePressedForSequentialReset()
;       IsShifterHandbrakeActive()
;       IsAnalogHandbrakeActive()
;       ReadClutchReleasePercent()
;       IsBrakePressedForReverseAssist()
;       IsFirstGearSelectedForStall()
;       IsPhysicalShifterNeutral()
;       IsClutchFullyPressedForRestart()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 14: NOTIFICATIONS, STATUS, VALIDATION, AND LOGGING
;   Functions:
;       BoolText()
;       ModeText()
;       ClearStatusToolTip()
;       ShowToolTipMessage()
;       ShowLiveModeStatus()
;       ShowStartupInfo()
;       DetectInputHardware()
;       AddValidationWarning()
;       BuildActiveProfileValidationText()
;       BuildValidationText()
;       WriteStartupLogFile()
;       OpenValidationLog()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 15: STATISTICS & SHARED OVERLAY LAYOUT
;   Functions:
;       ReadStatCount()
;       SaveStatCount()
;       InitializeStats()
;       ApplyStatisticsStartupOptions()
;       StartStatsSession()
;       FinalizeStatsSession()
;       SynchronizeStatsSession()
;       RecordShift()
;       RecordStall()
;       RecordRaceRestart()
;       IsStatsDisplayActive()
;       GetOverlayX()
;       UpdateStatsDisplay()
;       ToggleStatsDisplay()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 16: STOPWATCH
;   Functions:
;       FormatStopwatchTime()
;       GetStopwatchElapsedMs()
;       UpdateStopwatchDisplay()
;       ToggleStopwatch()
;       LapStopwatch()
;       ClearStopwatch()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 17: TRANSIENT STATE CLEAR / DISARM HELPERS
;   Functions:
;       ClearEdgeInputState()
;       ClearClutchTransactionState()
;       ClearTransmissionInputState()
;       DisarmEdgeInputs()
;       DisarmGamepadDigitalInputs()
;       ClearStallDetectionState()
;       ClearBrakeResetStallGraceState()
;       ClearSequentialBrakeHoldTimer()
;       ClearSequentialBrakeResetState()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 18: PROFILE SWITCHING, DYNAMIC HOTKEYS, AND LIVE MODE TOGGLES
;   Functions:
;       SwitchProfileBoolean()
;       SwitchProfileInteger()
;       SwitchResolveInput()
;       SwitchRequireAvailable()
;       BuildProfileSwitchCandidate()
;       CaptureProfileMutableOptions()
;       CommitProfileSwitch()
;       CaptureFullProfileSnapshot()
;       GetRigProfileHotkeys()
;       PrepareRigHotkeys()
;       SetRigHotkeysEnabled()
;       GetOutgoingProfileHardwareState()
;       ToggleControllerProfile()
;       TryActivateProfile()
;       GetDynamicHotkeyDefinitions()
;       TryRegisterHotkey()
;       RegisterDynamicHotkeys()
;       ShowHotkeyHelp()
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
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 19: AUXILIARY INPUT / SYNC HANDLERS
;   Functions:
;       HandlePaddleSync()
;       HandleKeyboardShiftSync()
;       HandleHandbrake()
;       HandleReverseAssist()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 20: STALL / ENGINE OFF/ON SIMULATION LOGIC
;   Functions:
;       ShouldSuppressStallForBrakeReset()
;       HandleStallDetection()
;       EnterEngineOffState()
;       StallEngine()
;       ShutOffEngine()
;       MaintainStalledState()
;       TryRestartEngine()
;       HandleIgnitionButton()
;       HandleGamepadIgnition()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 21: H-PATTERN TRANSMISSION LOGIC
;   Functions:
;       HandleHPatternTransmission()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 22: SEQUENTIAL TRANSMISSION LOGIC
;   Functions:
;       HandleSequentialBrakeHoldReset()
;       TrySequentialShift()
;       SendQueuedSequentialShifts()
;       HandleSequentialTransmission()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 23: RECOVERY AND MANUAL SYNC
;   Functions:
;       SyncGear()
;       ResetInputs()
;       RefreshProfileForNewGame()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 24: NFSMW PROCESS / FOCUS TRACKING
;   Functions:
;       IsNFSFocused()
;       InitializeNFSProcessTracking()
;       MonitorNFSProcess()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 25: MAIN LOOP
;   Functions:
;       SetMainLoopTimerInterval()
;       UpdateMainLoopSchedule()
;       MainLoop()
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 26: STARTUP
;   State and startup calls:
;     Startup hotkeys: dynamicHotkeyRegistrationResults, profileRigHotkeys
;     Startup calls: InitializeStats, InitializeNFSProcessTracking, ApplyStatisticsStartupOptions, RegisterDynamicHotkeys,
;         ShowStartupInfo, UpdateMainLoopSchedule
;     Monitoring: MonitorNFSProcess
;
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;
; SECTION 27: FIXED H-SHIFTER HOTKEYS
;   Hotkey bindings:
;     Game sync hotkeys: $0, $n, $1, $2, $3, $4, $5, $6
;     Hotkey context: #HotIf, IsNFSFocused()
;
; ==========================================================================================================================================================


; ==========================================================================================================================================================
; SECTION 1: SCRIPT DIRECTIVES AND APPLICATION METADATA
; ==========================================================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force ; prevent duplicate copies of this script
#UseHook true ; force keyboard hook for better game compatibility
appName := "RealManual"
appVersion := "1.3.0"
SendMode "Event" ; event-style key sending for older games
configFile := A_ScriptDir "\RealManual.ini" ; config path needs to be beside this script
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


    ConfigRuleKey("Sequential", "BrakeHoldResetMs"),           [100, 10000],
    ConfigRuleKey("Sequential", "QueuedShiftDelayMs"),         [1, 1000],

    ConfigRuleKey("Stalling", "ClutchReleaseThreshold"),       [1, 99],
    ConfigRuleKey("Stalling", "ThrottleThreshold"),            [0, 100],
    ConfigRuleKey("Stalling", "RestartClutchThreshold"),       [0, 99],
    ConfigRuleKey("Stalling", "NeutralResendMs"),              [50, 1000],
    ConfigRuleKey("Stalling", "ThrottleBlipMs"),               [1, 2000],
    ConfigRuleKey("Stalling", "NoInputStallDelayMs"),          [0, 1500],
    ConfigRuleKey("Stalling", "BrakeResetStallGraceMs"),       [0, 1000],


    ConfigRuleKey("Stopwatch", "StopwatchRefreshMs"),          [20, 1000],
    ConfigRuleKey("Stopwatch", "StopwatchMaxLines"),           [1, 50]
)

booleanConfigRules := Map(
    ConfigRuleKey("General", "WriteStartupLog"), true,
    ConfigRuleKey("General", "EnableToolTips"), true,

    ConfigRuleKey("Transmission", "StartInSequentialMode"), true,
    ConfigRuleKey("Sequential", "InvertSequentialShifter"), true,

    ConfigRuleKey("Clutch", "ClutchAxisIncreasesWhenPressed"), true,
    ConfigRuleKey("Clutch", "RequireClutch"), true,
    ConfigRuleKey("Clutch", "ClutchActsAsNeutral"), true,

    ConfigRuleKey("Handbrake", "EnableShifterHandbrake"), true,
    ConfigRuleKey("Handbrake", "HandbrakeAxisIncreasesWhenPulled"), true,

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
; ReadConfigValue(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads one RealManual.ini value and removes an optional inline comment.
;
; Inline comments must begin with whitespace followed by a semicolon:
;
;   Setting=Value ; comment
;
; A semicolon that is part of the value is preserved:
;
;   SomeKey=;
;   SomeKey=; ; semicolon key
;
; Leading and trailing whitespace is removed from the resulting value.
; ==========================================================================================================================================================
ReadConfigValue(section, key, fallback := "") {
    global configFile

    rawValue := IniRead(configFile, section, key, fallback)

    return Trim(RegExReplace(rawValue, "\s+;.*$"))
} ; end readconfigvalue

; ==========================================================================================================================================================
; ReadBool(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a boolean option from RealManual.ini.
;
; Missing, blank, malformed, or commented values safely return either the
; configured boolean or the supplied fallback.
; ==========================================================================================================================================================
ReadBool(section, key, fallback) {
    rawValue := ReadConfigValue(section, key)

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
; BuildValidationText() separately reports the original configured value.
; ==========================================================================================================================================================
ReadInt(section, key, fallback) {
    global numericConfigRules

    ruleKey := ConfigRuleKey(section, key)

    ; explicit sanity rule
    if !numericConfigRules.Has(ruleKey) {
        return fallback
    } ; end missing numeric rule guard

    rawValue := ReadConfigValue(section, key)

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
; Reads a text option from RealManual.ini.
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
    return ReadConfigValue(section, key, fallback)
} ; end readtext


; ==========================================================================================================================================================
; SECTION 4: PROFILE SELECTION, RULE MIRRORING, AND INPUT RESOLUTION
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; ProfileSection(category)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Builds the active profile-specific INI section path.
; Returns a section such as Profile.Gamepad.Clutch.
; ==========================================================================================================================================================
ProfileSection(category) {
    global activeProfileName
    return "Profile." activeProfileName "." category
} ; end profilesection

; ==========================================================================================================================================================
; RegisterProfileConfigRules()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Extends numeric and Boolean validation rules to the two profile namespaces.
; Preserves shared global configuration rules and adds profile-specific bounds.
; ==========================================================================================================================================================
RegisterProfileConfigRules() {
    global numericConfigRules, booleanConfigRules
    numericBase := numericConfigRules.Clone() ; avoids modifying the map being enumerated
    booleanBase := booleanConfigRules.Clone()
    categories := "|Transmission|Clutch|Pedals|Sequential|Handbrake|Stalling|ReverseAssist|"

    for ruleKey, limits in numericBase {
        parts := StrSplit(ruleKey, "|")
        if !InStr(categories, "|" parts[1] "|") {
            continue
        } ; end global section guard
        for profileName in ["SimRig", "Gamepad"] {
            numericConfigRules[ConfigRuleKey("Profile." profileName "." parts[1], parts[2])] := limits.Clone()
        } ; end profile iteration
    } ; end numeric iteration

    for ruleKey, marker in booleanBase {
        parts := StrSplit(ruleKey, "|")
        if !InStr(categories, "|" parts[1] "|") {
            continue
        } ; end global guard
        for profileName in ["SimRig", "Gamepad"] {
            booleanConfigRules[ConfigRuleKey("Profile." profileName "." parts[1], parts[2])] := marker
        } ; end profile loop
    } ; end boolean iteration

    for role in ["Gamepad", "Wheel", "Handbrake"] {
        numericConfigRules[ConfigRuleKey("JoystickDevices", role "Slot")] := [1, 16]
    } ; end slot registration

    for action in ["Clutch", "Throttle", "Brake", "Handbrake", "Upshift", "Downshift", "Ignition"] {
        numericConfigRules[ConfigRuleKey("Profile.Gamepad.AxisCalibration", action "Released")] := [0, 100] ; physical neutral
        numericConfigRules[ConfigRuleKey("Profile.Gamepad.AxisCalibration", action "Pressed")] := [0, 100] ; full physical actuation
    } ; end action loop

    for field in ["AnalogActivationPercent", "AnalogReleasePercent", "AnalogHandbrakeActivationPercent", "AnalogHandbrakeReleasePercent"] {
        numericConfigRules[ConfigRuleKey("Profile.Gamepad.Activation", field)] := [0, 100]
    } ; end shared activation rules

    for sectionAndKey in [["Pedals", "BrakeActivePercent"], ["Sequential", "BrakeResetPercent"], ["ReverseAssist", "EngageBrakePercent"]] {
        numericConfigRules[ConfigRuleKey("Profile.SimRig." sectionAndKey[1], sectionAndKey[2])] := [0, 100]
    } ; end SimRig normalized thresholds

    numericConfigRules[ConfigRuleKey("Profile.Gamepad.Sequential", "BrakeResetPercent")] := [0, 100]
    numericConfigRules[ConfigRuleKey("Profile.Gamepad.Stalling", "BrakeActivePercent")] := [0, 100]
    booleanConfigRules[ConfigRuleKey("JoystickDevices", "AutoEnumerateDevices")] := true
    booleanConfigRules[ConfigRuleKey("Profile.SimRig.Pedals", "UseCombinedPedals")] := true
    booleanConfigRules[ConfigRuleKey("Profile.SimRig.Pedals", "ThrottleAxisIncreasesWhenPressed")] := true ; polarity used only in separate mode

    for profileName in ["SimRig", "Gamepad"] {
        category := profileName = "SimRig" ? "Handbrake" : "Inputs"
        booleanConfigRules[ConfigRuleKey("Profile." profileName "." category, "RealManualControlsHandbrake")] := true
    } ; end handbrake routing registration
} ; end registerprofileconfigrules

; ==========================================================================================================================================================
; ReadStrictProfileInt(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads and validates an integer used by the active profile.
; Rejects invalid active settings.
; ==========================================================================================================================================================
ReadStrictProfileInt(section, key, fallback) {
    global numericConfigRules
    ruleKey := ConfigRuleKey(section, key)

    if !numericConfigRules.Has(ruleKey) {
        StopProfileLoading("No validation rule for [" section "] " key)
    } ; end rule guard

    rawValue := ReadText(section, key, fallback)
    if !TryParseConfigInt(rawValue, &number) {
        StopProfileLoading("[" section "] " key " must be an integer")
    } ; end parse guard

    limits := numericConfigRules[ruleKey]
    if number < limits[1] || number > limits[2] { ; ensure the configured value is safe
        StopProfileLoading("[" section "] " key " must be between " limits[1] " and " limits[2])
    } ; end bounds guard

    return number
} ; end readstrictprofileint

; ==========================================================================================================================================================
; ReadStrictProfileBool(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads and validates a strictly binary profile setting.
; Accepts only 0 or 1 for an explicitly configured option.
; ==========================================================================================================================================================
ReadStrictProfileBool(section, key, fallback) {
    rawValue := ReadText(section, key, fallback ? "1" : "0")

    if !TryParseConfigBool(rawValue, &result) {
        StopProfileLoading("[" section "] " key " must be 0 or 1")
    } ; end boolean validation

    return result
} ; end readstrictprofilebool

; ==========================================================================================================================================================
; InferGamepadInputKind(source)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Infers the physical input type from the resolved Gamepad binding.
; Returns Axis, Button, Key, POV or an empty string when unsupported.
; ==========================================================================================================================================================
InferGamepadInputKind(source) {
    if RegExMatch(source, "i)^(?:[1-9]|1[0-6])Joy(?:X|Y|Z|R|U|V)$") {
        return "Axis" ; calibrated 0-100 physical input
    } ; end axis guard

    if RegExMatch(source, "i)^(?:[1-9]|1[0-6])Joy(?:[1-9]|[12][0-9]|3[0-2])$") {
        return "Button"
    } ; end button guard

    if RegExMatch(source, "i)^(?:[1-9]|1[0-6])JoyPOV$") {
        return "POV"
    } ; end POV guard

    if source != "" && !InStr(source, ":") && !RegExMatch(source, "i)^\d+Joy") {
        return "Key" ; physical keyboard input
    } ; end key guard

    return ""
} ; end infergamepadinputkind

; ==========================================================================================================================================================
; StopProfileLoading(reason)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Stops initialization when required profile configuration is unsafe.
; ==========================================================================================================================================================
StopProfileLoading(reason) {
    MsgBox("RealManual profile configuration error:`n`n" reason)
    ExitApp()
} ; end stopprofileloading

; ==========================================================================================================================================================
; EnumerateJoystickDevices()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads responding legacy joystick slots and their WinMM hardware IDs.
; Returns live slot identities.
; ==========================================================================================================================================================
EnumerateJoystickDevices() {
    devices := []

    Loop 16 {
        slot := A_Index
        joyId := slot - 1
        name := ""

        try { ; name is only informational because generic driver names are not unique
            name := Trim(GetKeyState(slot "JoyName"))
        } catch { ; a missing driver must not terminate controller enumeration
            name := ""
        } ; end legacy-name read

        caps := Buffer(728, 0)

        try { ; prevents a Windows API error from silently assigning the wrong hardware
            status := DllCall("winmm\joyGetDevCapsW", "UPtr", joyId, "Ptr", caps.Ptr, "UInt", caps.Size, "UInt")
        } catch { ; an unsupported API must not become a valid identity
            status := -1
        } ; end capability read

        if status != 0 {
            if name != "" {
                devices.Push({slot: slot, name: name, hardwareId: ""})
            } ; end readable manual slot
            continue
        } ; end missing capabilities

        state := Buffer(52, 0)
        NumPut("UInt", 52, state, 0)
        NumPut("UInt", 0xFF, state, 4)

        try { ; stale capabilities can remain after a controller disconnects
            stateStatus := DllCall("winmm\joyGetPosEx", "UInt", joyId, "Ptr", state.Ptr, "UInt")
        } catch { ; failed input polling is not a connected device
            stateStatus := -1
        } ; end presence check

        if stateStatus != 0 { ; avoids matching devices with registry entries but no live input
            continue ; refuses stale hardware identities
        } ; end disconnected slot

        maker := NumGet(caps, 0, "UShort")
        product := NumGet(caps, 2, "UShort")
        hardwareId := (maker != 0 && product != 0) ? Format("VID_{:04X}&PID_{:04X}", maker, product) : ""
        devices.Push({slot: slot, name: name, hardwareId: hardwareId})
    } ; end legacy enumeration

    return devices
} ; end enumeratejoystickdevices

; ==========================================================================================================================================================
; ResolveConfiguredJoystickRoles(&warnings)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Resolves controller roles using automatic VID/PID or manual slots.
; Rejects missing or duplicate identities; supplies warnings for validation.
; ==========================================================================================================================================================
ResolveConfiguredJoystickRoles(&warnings) {
    global autoEnumerateDevices

    warnings := []
    candidates := Map() ; stages matched role-to-slot values before checking for shared-device conflicts
    devices := EnumerateJoystickDevices()

    for role in ["Gamepad", "Wheel", "Handbrake"] {
        roleKey := StrLower(role)

        if autoEnumerateDevices {
            expectedId := StrUpper(Trim(ReadText("JoystickDevices", role "HardwareId")))

            if expectedId = "" { ; disconnected and unconfigured inactive roles are optional
                continue ; the active role is checked explicitly after role resolution
            } ; end blank hardware identity

            if !RegExMatch(expectedId, "^VID_[0-9A-F]{4}&PID_[0-9A-F]{4}$") { ; permits only the verified whole-device identity syntax
                warnings.Push(role "HardwareId '" expectedId "' is invalid; expected VID_XXXX&PID_XXXX")
                continue
            } ; end hardware-id syntax validation

            matches := []

            for device in devices {
                if device.hardwareId = expectedId {
                    matches.Push(device.slot)
                } ; end hardware-id equality
            } ; end identity scan

            if matches.Length != 1 { ; two identical models cannot safely be distinguished using VID/PID alone
                warnings.Push(role "HardwareId '" expectedId "' matched " matches.Length " connected devices (exactly one required)")
                continue
            } ; end exact-unique match check

            candidates[roleKey] := matches[1]

        } else {
            rawSlot := ReadText("JoystickDevices", role "Slot") ; manual mode uses the declared slot, not the name

            if rawSlot = "" { ; an unconnected optional controller does not require a manual slot
                continue
            } ; end blank-slot guard

            if !TryParseConfigInt(rawSlot, &slot) || slot < 1 || slot > 16 {
                throw Error("[JoystickDevices] " role "Slot must be 1..16 or blank")
            } ; end manual-range check

            present := false

            for device in devices {
                if device.slot = slot {
                    present := true
                    break
                } ; end presence check
            } ; end slot presence scan

            if !present { ; a disconnected manual slot cannot control an action
                warnings.Push(role "Slot " slot " is not currently readable")
                continue
            } ; end missing manual slot

            candidates[roleKey] := slot
        } ; end backend selection
    } ; end configured roles

    roles := Map()

    for role, slot in candidates { ; checks every staged match before accepting it
        collision := ""
        for otherRole, otherSlot in candidates {
            if otherRole != role && otherSlot = slot { ; two logical devices must not silently become one physical controller
                collision := otherRole
                break
            } ; end duplicate slot test
        } ; end claim arbitration

        if collision != "" { ; conflicting roles cannot safely share a joystick
            warnings.Push(role " and " collision " both claim joystick " slot)
            continue
        } ; end collision guard

        roles[role] := slot
    } ; end arbitration loop

    return roles
} ; end resolveconfiguredjoystickroles

; ==========================================================================================================================================================
; ReadPreferredStartupProfile()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the configured Gamepad/SimRig preference.
; 0 = Gamepad and 1 = SimRig; named values are also accepted.
; ==========================================================================================================================================================
ReadPreferredStartupProfile() {
    configuredValue := Trim(ReadText("Profiles", "ActiveProfile", ""))

    if configuredValue = "0" || configuredValue = "Gamepad" {
        return "Gamepad"
    } ; end gamepad preference

    if configuredValue = "1" || configuredValue = "SimRig" {
        return "SimRig"
    } ; end simrig preference

    StopProfileLoading("[Profiles] ActiveProfile must be 0 (Gamepad) or 1 (SimRig)")
} ; end readpreferredstartupprofile

; ==========================================================================================================================================================
; SelectStartupProfile(preferredProfile, roles, warnings, &selectionReason)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Chooses the effective startup profile from connected primary controllers.
; A sole controller wins in auto mode; a two-controller tie uses the preference.
; ==========================================================================================================================================================
SelectStartupProfile(preferredProfile, roles, warnings, &selectionReason) {
    global autoEnumerateDevices ; only automatic mode may override the ini preference

    selectionReason := "configured preference"

    if !autoEnumerateDevices {
        return preferredProfile
    } ; end manual mode

    for _, warning in warnings {
        if RegExMatch(warning, "i)^(?:Gamepad|Wheel)HardwareId .* is invalid") {
            StopProfileLoading("Automatic startup has an invalid primary hardware identity:`n- " warning)
        } ; end invalid identifier guard

        if RegExMatch(warning, "i)^(?:Gamepad|Wheel)HardwareId .* matched ([0-9]+) connected devices", &ambiguous) {
            if ambiguous[1] > 1 { ; more than one matching primary controller is not a uniquely identifiable role
                StopProfileLoading("Automatic startup found an ambiguous primary controller:`n- " warning)
            } ; end duplicate controller guard
        } ; end ambiguous identity check
    } ; end identity warning check

    hasGamepad := roles.Has("gamepad")
    hasWheel := roles.Has("wheel")

    if hasGamepad && hasWheel {
        selectionReason := "both primary controllers connected; using configured preference"
        return preferredProfile
    } ; end both connected

    if hasGamepad {
        selectionReason := "only Gamepad detected; selected automatically"
        return "Gamepad"
    } ; end gamepad-only selection

    if hasWheel {
        selectionReason := "only SimRig detected; selected automatically"
        return "SimRig"
    } ; end wheel-only selection

    detail := "" ; collects failures from missing, ambiguous, or malformed configured primary identities
    for _, warning in warnings {
        detail .= "`n- " warning
    } ; end warning collection

    StopProfileLoading("Automatic profile selection requires a uniquely identified Gamepad or Wheel; neither was resolved." detail)
} ; end selectstartupprofile

; ==========================================================================================================================================================
; InitializeJoystickSlots()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Initializes role-to-slot mappings before resolving physical bindings.
; Ensures only validated connected roles can supply joystick input.
; ==========================================================================================================================================================
InitializeJoystickSlots() {
    global joystickRoleSlots, profileResolutionWarnings

    try {
        joystickRoleSlots := ResolveConfiguredJoystickRoles(&profileResolutionWarnings)
    } catch as err {
        StopProfileLoading(err.Message)
    } ; end startup resolution guard
} ; end initializejoystickslots

; ==========================================================================================================================================================
; ResolveJoystickAlias(binding, label)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Resolves Wheel:/Gamepad:/Handbrake: joystick role aliases.
; Returns a native nJoy binding for the currently matched device slot.
; ==========================================================================================================================================================
ResolveJoystickAlias(binding, label) {
    global joystickRoleSlots, profileResolutionWarnings

    binding := Trim(binding)
    if binding = "" {
        return ""
    } ; end blank guard

    if !InStr(binding, ":Joy") {
        if InStr(binding, ":") {
            profileResolutionWarnings.Push(label " has unsupported binding '" binding "'")
            return "" ; does not pass malformed strings into GetKeyState
        } ; end unknown-alias check

        return binding ; allow legacy
    } ; end legacy binding branch

    pattern := "i)^(Gamepad|Wheel|Handbrake):Joy([1-9]|[12][0-9]|3[0-2]|X|Y|Z|R|U|V|POV)$"
    if !RegExMatch(binding, pattern, &matched) {
        profileResolutionWarnings.Push(label " has invalid joystick alias '" binding "'")
        return ""
    } ; end malformed alias guard

    role := StrLower(matched[1])
    if !joystickRoleSlots.Has(role) {
        profileResolutionWarnings.Push(label " requires missing role '" role "'")
        return ""
    } ; end unresolved-role guard

    return joystickRoleSlots[role] "Joy" matched[2]
} ; end resolvejoystickalias

; ==========================================================================================================================================================
; ReadInputBinding(section, key, fallback := "")
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Loads one physical input binding through the role resolver.
; Keeps unverified role aliases out of input and hotkey readers.
; ==========================================================================================================================================================
ReadInputBinding(section, key, fallback := "") {
    global resolvedInputBindings

    rawBinding := ReadText(section, key, fallback)
    effectiveBinding := ResolveJoystickAlias(rawBinding, "[" section "] " key)
    resolvedInputBindings[ConfigRuleKey(section, key)] := effectiveBinding

    return effectiveBinding
} ; end readinputbinding

; ==========================================================================================================================================================
; LoadGamepadInputDefinitions()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Builds calibrated Gamepad action mappings and shared hysteresis settings.
; Infers source types and validates analog endpoint and POV configurations.
; ==========================================================================================================================================================
LoadGamepadInputDefinitions() {
    global gamepadInputDefinitions, gamepadActivationSettings, realManualControlsHandbrake
    section := "Profile.Gamepad.Inputs"

    realManualControlsHandbrake := ReadStrictProfileBool(section, "RealManualControlsHandbrake", false)
    gamepadInputDefinitions := Map()
    gamepadActivationSettings := Map()

    for action in ["Clutch", "Throttle", "Brake", "Handbrake", "Upshift", "Downshift", "Ignition"] {
        source := ReadInputBinding(section, action "Source")

        if source = "" && action = "Handbrake" && !realManualControlsHandbrake {
            gamepadInputDefinitions[action] := {source: "", kind: "Native", released: 0, pressed: 100, povDirection: -1}
            continue
        } ; end native handbrake exception

        if source = "" && action = "Ignition" {
            gamepadInputDefinitions[action] := {source: "", kind: "Disabled", released: 0, pressed: 100, povDirection: -1}
            continue ; end optional ignition mapping
        } ; end optional ignition guard

        if source = "" {
            StopProfileLoading("Gamepad " action "Source is missing or unresolved")
        } ; end missing source guard

        kind := InferGamepadInputKind(source)

        if kind = "" { ; rejects malformed or unsupported physical mappings
            StopProfileLoading("Gamepad " action "Source is not a supported input: " source)
        } ; end source type check

        released := action = "Brake" ? 50 : 0
        pressed := 100

        if kind = "Axis" { ; calibration applies only to continuous analog sources
            released := ReadStrictProfileInt("Profile.Gamepad.AxisCalibration", action "Released", released)
            pressed := ReadStrictProfileInt("Profile.Gamepad.AxisCalibration", action "Pressed", pressed)
            if released = pressed {
                StopProfileLoading("Gamepad " action "Released and Pressed cannot be equal")
            } ; end distinct endpoint guard
        } ; end axis calibration

        direction := -1

        if kind = "POV" { ; POV directions must be explicit and aligned to 45-degree steps
            rawDirection := ReadText(section, action "POVDirection")
            if !TryParseConfigInt(rawDirection, &direction) || direction > 31500 || Mod(direction, 4500) != 0 { ; rejects missing/invalid values
                StopProfileLoading("Gamepad " action "POVDirection must be 0,4500,...,31500")
            } ; end POV direction check
        } ; end POV branch

        gamepadInputDefinitions[action] := {source: source, kind: kind, released: released, pressed: pressed, povDirection: direction}
    } ; end action loop

    if gamepadInputDefinitions["Upshift"].source = gamepadInputDefinitions["Downshift"].source { ; a single source cannot represent both shift directions
        StopProfileLoading("Gamepad UpshiftSource and DownshiftSource must differ")
    } ; end shift conflict guard

    activationSection := "Profile.Gamepad.Activation"
    analogOn := ReadStrictProfileInt(activationSection, "AnalogActivationPercent", 60)
    analogOff := ReadStrictProfileInt(activationSection, "AnalogReleasePercent", 40)
    brakeOn := ReadStrictProfileInt(activationSection, "AnalogHandbrakeActivationPercent", 20)
    brakeOff := ReadStrictProfileInt(activationSection, "AnalogHandbrakeReleasePercent", 15)

    if analogOn <= analogOff || brakeOn <= brakeOff {
        StopProfileLoading("Analog activation percentages must exceed their release percentages")
    } ; end hysteresis guard

    for action in ["Upshift", "Downshift", "Ignition"] {
        gamepadActivationSettings[action] := {on: analogOn, off: analogOff}
    } ; end digital action loop

    gamepadActivationSettings["Handbrake"] := {on: brakeOn, off: brakeOff}
} ; end loadgamepadinputdefinitions

; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Startup ordering: rules -> profile selection -> device resolution -> inputs -> Sections 5-9.
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterProfileConfigRules() ; adds mirrored and new numeric rules before any profile ReadInt calls
preferredStartupProfileName := ReadPreferredStartupProfile() ; validates the ini preference before checking hardware
activeProfileName := preferredStartupProfileName
autoEnumerateDevices := ReadStrictProfileBool("JoystickDevices", "AutoEnumerateDevices", false)
resolvedInputBindings := Map()
InitializeJoystickSlots()
activeProfileName := SelectStartupProfile(preferredStartupProfileName, joystickRoleSlots, profileResolutionWarnings, &startupProfileSelectionReason)
requiredRole := activeProfileName = "Gamepad" ? "gamepad" : "wheel"

if !joystickRoleSlots.Has(requiredRole) {
    if autoEnumerateDevices && ReadText("JoystickDevices", activeProfileName "HardwareId") = "" {
        StopProfileLoading("[JoystickDevices] " activeProfileName "HardwareId must contain VID_XXXX&PID_XXXX from the identity detector")
    } ; end missing hardware-ID guard

    detail := ""
    for _, warning in profileResolutionWarnings {
        detail .= "`n- " warning
    } ; end warnings

    StopProfileLoading("The active " activeProfileName " profile requires " (autoEnumerateDevices ? "one uniquely matching hardware ID" : "a valid joystick slot") detail)
} ; end essential-device guard

if activeProfileName = "SimRig" && joystickRoleSlots.Has("handbrake") {
    if joystickRoleSlots["handbrake"] = joystickRoleSlots["wheel"] {
        StopProfileLoading("WheelSlot and HandbrakeSlot cannot refer to the same joystick")
    } ; end role overlap guard
} ; end optional handbrake slot arbitration

if activeProfileName = "Gamepad" {
    LoadGamepadInputDefinitions()
} else {
    gamepadInputDefinitions := Map()
    gamepadActivationSettings := Map()
} ; end startup action definitions

; ==========================================================================================================================================================
; SECTION 5: CONFIG LOADING - GENERAL AND HOTKEYS
; ==========================================================================================================================================================
writeStartupLog := ReadBool("General", "WriteStartupLog", true)
enableToolTips := ReadBool("General", "EnableToolTips", true)
toolTipDurationMs := ReadInt("General", "ToolTipDurationMs", 2000)

helpButton := ReadInputBinding("Hotkeys", "HelpButton")
resetButton := ReadInputBinding("Hotkeys", "ResetButton")
pauseButton := ReadInputBinding("Hotkeys", "PauseButton")
reloadButton := ReadInputBinding("Hotkeys", "ReloadButton")
profileToggleButton := ReadText("Profiles", "ToggleProfileButton", "^F12")

toggleTransmissionModeButton := ReadInputBinding("Hotkeys", "ToggleTransmissionModeButton")
toggleSequentialShifterInvertButton := ReadInputBinding("Hotkeys", "ToggleSequentialShifterInvertButton")
toggleMaxForwardGearButton := ReadInputBinding("Hotkeys", "ToggleMaxForwardGearButton")
toggleClutchRequiredButton := ReadInputBinding("Hotkeys", "ToggleClutchRequiredButton")
toggleClutchNeutralButton := ReadInputBinding("Hotkeys", "ToggleClutchNeutralButton")
toggleShifterHandbrakeButton := ReadInputBinding("Hotkeys", "ToggleShifterHandbrakeButton")
toggleStallingButton := ReadInputBinding("Hotkeys", "ToggleStallingButton")

stopwatchButton := ReadInputBinding("Hotkeys", "StopwatchButton")
stopwatchLapButton := ReadInputBinding("Hotkeys", "StopwatchLapButton")
stopwatchClearButton := ReadInputBinding("Hotkeys", "StopwatchClearButton")
statsShiftsButton := ReadInputBinding("Hotkeys", "StatsShiftsButton")
statsStallsButton := ReadInputBinding("Hotkeys", "StatsStallsButton")
statsRaceRestartsButton := ReadInputBinding("Hotkeys", "StatsRaceRestartsButton")
raceRestartButton := ReadInputBinding("Hotkeys", "RaceRestartButton")
saveInstantReplayButton := ReadInputBinding("Hotkeys", "SaveInstantReplayButton")
captureScreenshotButton := ReadInputBinding("Hotkeys", "CaptureScreenshotButton")

ignitionButton := ""
if activeProfileName = "SimRig" {
    ignitionButton := ReadInputBinding(ProfileSection("Hotkeys"), "IgnitionButton")
} else {
    toggleTransmissionModeButton := ""
    toggleSequentialShifterInvertButton := ""
    toggleShifterHandbrakeButton := ""
} ; end profile-specific hotkey availability


; ==========================================================================================================================================================
; SECTION 6: CONFIG LOADING - TRANSMISSION AND CLUTCH
; ==========================================================================================================================================================

if activeProfileName = "SimRig" {
    startInSequentialMode := ReadBool(ProfileSection("Transmission"), "StartInSequentialMode", false)
    maxForwardGear := ReadInt(ProfileSection("Transmission"), "MaxForwardGear", 6)
    requireClutch := ReadBool(ProfileSection("Clutch"), "RequireClutch", true)
    clutchActsAsNeutral := ReadBool(ProfileSection("Clutch"), "ClutchActsAsNeutral", true)
    clutchAxis := ReadInputBinding(ProfileSection("Clutch"), "ClutchAxis")
    clutchAxisIncreasesWhenPressed := ReadBool(ProfileSection("Clutch"), "ClutchAxisIncreasesWhenPressed", false)
    clutchThreshold := ReadInt(ProfileSection("Clutch"), "ClutchThreshold", 40)
} else { ; Gamepad only supports sequential transmission
    startInSequentialMode := true
    maxForwardGear := ReadInt(ProfileSection("Transmission"), "MaxForwardGear", 6)
    requireClutch := ReadBool(ProfileSection("Clutch"), "RequireClutch", true)
    clutchActsAsNeutral := ReadBool(ProfileSection("Clutch"), "ClutchActsAsNeutral", true)
    clutchThreshold := ReadInt(ProfileSection("Clutch"), "ClutchThreshold", 40)
    clutchAxis := gamepadInputDefinitions["Clutch"].source
    clutchAxisIncreasesWhenPressed := true
} ; end transmission / clutch profile branch
transmissionIsSequential := startInSequentialMode


; ==========================================================================================================================================================
; SECTION 7: CONFIG LOADING - PEDALS, GAME KEYS, AND H-PATTERN
; ==========================================================================================================================================================

if activeProfileName = "SimRig" {
    useCombinedPedals := ReadStrictProfileBool(ProfileSection("Pedals"), "UseCombinedPedals", true)
    combinedPedalAxis := ""
    throttleAxis := ""
    brakeAxis := ""
    brakeAxisIncreasesWhenPressed := ReadStrictProfileBool(ProfileSection("Pedals"), "BrakeAxisIncreasesWhenPressed", true)
    throttleAxisIncreasesWhenPressed := false ; ignored for combined pedals
    if useCombinedPedals {
        combinedPedalAxis := ReadInputBinding(ProfileSection("Pedals"), "CombinedPedalAxis")
        if combinedPedalAxis = "" {
            StopProfileLoading("SimRig combined pedal axis is missing")
        } ; end combined-axis guard
    } else { ; independent rig pedals must be explicitly mapped and normalized
        throttleAxis := ReadInputBinding(ProfileSection("Pedals"), "ThrottleAxis")
        brakeAxis := ReadInputBinding(ProfileSection("Pedals"), "BrakeAxis")
        throttleAxisIncreasesWhenPressed := ReadStrictProfileBool(ProfileSection("Pedals"), "ThrottleAxisIncreasesWhenPressed", false)
        if throttleAxis = "" || brakeAxis = "" || throttleAxis = brakeAxis {
            StopProfileLoading("SimRig separate pedals require distinct ThrottleAxis and BrakeAxis")
        } ; end separate mode input check
    } ; end physical pedal selection
    brakeActivePercent := ReadStrictProfileInt(ProfileSection("Pedals"), "BrakeActivePercent", 10)
    gear1Button := ReadInputBinding(ProfileSection("HPattern"), "Gear1Button")
    gear2Button := ReadInputBinding(ProfileSection("HPattern"), "Gear2Button")
    gear3Button := ReadInputBinding(ProfileSection("HPattern"), "Gear3Button")
    gear4Button := ReadInputBinding(ProfileSection("HPattern"), "Gear4Button")
    gear5Button := ReadInputBinding(ProfileSection("HPattern"), "Gear5Button")
    gear6Button := ReadInputBinding(ProfileSection("HPattern"), "Gear6Button")
    reverseButton := ReadInputBinding(ProfileSection("HPattern"), "ReverseButton")
} else { ; Gamepad uses its own configurable physical input map
    useCombinedPedals := false ; logical controller pedals are independent
    combinedPedalAxis := "" ; avoids reading any G29 pedal binding
    throttleAxis := "" ; controller axes are read through the typed Gamepad definitions
    brakeAxis := "" ; controller brake source is read through its action mapping
    throttleAxisIncreasesWhenPressed := true ; not consulted for Gamepad actions
    brakeAxisIncreasesWhenPressed := true ; not consulted for Gamepad actions
    brakeActivePercent := ReadStrictProfileInt(ProfileSection("Stalling"), "BrakeActivePercent", 10) ; same normalized brake unit
    gear1Button := "" ; no controller H-pattern gear positions
    gear2Button := ""
    gear3Button := ""
    gear4Button := ""
    gear5Button := ""
    gear6Button := ""
    reverseButton := ""
} ; end profile pedal and H-pattern selection

forwardKey := ReadText("GameKeys", "ForwardKey")
reverseKey := ReadText("GameKeys", "ReverseKey")
handbrakeKey := ReadText("GameKeys", "HandbrakeKey")
shiftUpKey := ReadText("GameKeys", "ShiftUpKey")
shiftDownKey := ReadText("GameKeys", "ShiftDownKey")


; ==========================================================================================================================================================
; SECTION 8: CONFIG LOADING - SEQUENTIAL, HANDBRAKE, STALLING, AND REVERSE ASSIST
; ==========================================================================================================================================================

if activeProfileName = "SimRig" {
    invertSequentialShifter := ReadBool(ProfileSection("Sequential"), "InvertSequentialShifter", false)
    sequentialUpshiftButton := ReadInputBinding(ProfileSection("Sequential"), "SequentialUpshiftButton")
    sequentialDownshiftButton := ReadInputBinding(ProfileSection("Sequential"), "SequentialDownshiftButton")
    paddleUpshiftButton := ReadInputBinding(ProfileSection("Sequential"), "PaddleUpshiftButton")
    paddleDownshiftButton := ReadInputBinding(ProfileSection("Sequential"), "PaddleDownshiftButton")
    enableBrakeHoldGearReset := ReadBool(ProfileSection("Sequential"), "EnableBrakeHoldGearReset", true)
    brakeHoldResetMs := ReadInt(ProfileSection("Sequential"), "BrakeHoldResetMs", 2000)
    brakeResetPercent := ReadStrictProfileInt(ProfileSection("Sequential"), "BrakeResetPercent", 40)
    queuedShiftDelayMs := ReadInt(ProfileSection("Sequential"), "QueuedShiftDelayMs", 35)
    realManualControlsHandbrake := ReadStrictProfileBool(ProfileSection("Handbrake"), "RealManualControlsHandbrake", true)
    handbrakeAxis := realManualControlsHandbrake ? ReadInputBinding(ProfileSection("Handbrake"), "HandbrakeAxis") : ""
    handbrakeAxisIncreasesWhenPulled := ReadBool(ProfileSection("Handbrake"), "HandbrakeAxisIncreasesWhenPulled", true)
    handbrakeThreshold := ReadInt(ProfileSection("Handbrake"), "HandbrakeThreshold", 20)
    enableShifterHandbrake := ReadBool(ProfileSection("Handbrake"), "EnableShifterHandbrake", false)
    shifterHandbrakeButton := ReadInputBinding(ProfileSection("Handbrake"), "ShifterHandbrakeButton")
    enableStalling := ReadBool(ProfileSection("Stalling"), "EnableStalling", false)
    enableReverseAssist := ReadBool(ProfileSection("ReverseAssist"), "EnableReverseAssist", false)
    engageBrakePercent := ReadStrictProfileInt(ProfileSection("ReverseAssist"), "EngageBrakePercent", 20)
} else { ; Gamepad shares the sequential state machine
    invertSequentialShifter := false
    sequentialUpshiftButton := gamepadInputDefinitions["Upshift"].source
    sequentialDownshiftButton := gamepadInputDefinitions["Downshift"].source
    paddleUpshiftButton := ""
    paddleDownshiftButton := ""
    enableBrakeHoldGearReset := ReadBool(ProfileSection("Sequential"), "EnableBrakeHoldGearReset", false)
    brakeHoldResetMs := ReadInt(ProfileSection("Sequential"), "BrakeHoldResetMs", 2000)
    brakeResetPercent := ReadStrictProfileInt(ProfileSection("Sequential"), "BrakeResetPercent", 40)
    queuedShiftDelayMs := ReadInt(ProfileSection("Sequential"), "QueuedShiftDelayMs", 35)
    handbrakeAxis := ""
    handbrakeAxisIncreasesWhenPulled := true ; unused in Gamepad
    handbrakeThreshold := 20 ; unused in Gamepad
    enableShifterHandbrake := false ; no H-shifter in Gamepad profile
    shifterHandbrakeButton := "" ; no physical H-shifter handbrake slot
    enableStalling := ReadStrictProfileBool(ProfileSection("Stalling"), "EnableStalling", false)

    if enableStalling && gamepadInputDefinitions["Ignition"].source = "" {
        StopProfileLoading("Gamepad stalling requires a valid IgnitionSource")
    } ; end controller ignition requirement

    enableReverseAssist := false ; reverse assist is unavailable in Gamepad profile
    engageBrakePercent := 20 ; unused rig-only reverse-assist setting
} ; end profile-specific sequential and engine options

clutchReleaseThreshold := ReadInt(ProfileSection("Stalling"), "ClutchReleaseThreshold", 60)
throttleThreshold := ReadInt(ProfileSection("Stalling"), "ThrottleThreshold", 15)
restartClutchThreshold := ReadInt(ProfileSection("Stalling"), "RestartClutchThreshold", 15)
neutralResendMs := ReadInt(ProfileSection("Stalling"), "NeutralResendMs", 50)
throttleBlipMs := ReadInt(ProfileSection("Stalling"), "ThrottleBlipMs", 500)
noInputStallDelayMs := ReadInt(ProfileSection("Stalling"), "NoInputStallDelayMs", 700)
brakeResetStallGraceMs := ReadInt(ProfileSection("Stalling"), "BrakeResetStallGraceMs", 100)


; ==========================================================================================================================================================
; SECTION 9: CONFIG LOADING - TIMING, STOPWATCH, AND STATISTICS
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
; SECTION 10: RUNTIME STATE VARIABLES
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

gamepadDigitalInputState := Map() ; maintains each logical Gamepad action's last digital pressed state
gamepadDigitalInputArmed := Map() ; initially require a released sample before accepting a new digital action
profileMutableOverrides := Map() ; remember live option toggles separately for each profile
profileSwitchInProgress := false ; reject nested profile activation requests
profileRigHotkeys := Map() ; remember installed rig-only dynamic hotkeys

; ==========================================================================================================================================================
; SECTION 11: INPUT / OUTPUT MAPS AND BINDING SANITIZATION
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
    global reservedProtocolKeys, reservedProtocolVks

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
    global clutchAxis, combinedPedalAxis, throttleAxis, brakeAxis, handbrakeAxis
    global forwardKey, reverseKey, handbrakeKey, shiftUpKey, shiftDownKey
    global gear1Button, gear2Button, gear3Button, gear4Button
    global gear5Button, gear6Button, reverseButton
    global sequentialUpshiftButton, sequentialDownshiftButton
    global paddleUpshiftButton, paddleDownshiftButton
    global shifterHandbrakeButton

    ; axes/general physical inputs
    clutchAxis := SanitizeUserConfiguredKey(clutchAxis)
    combinedPedalAxis := SanitizeUserConfiguredKey(combinedPedalAxis)
    throttleAxis := SanitizeUserConfiguredKey(throttleAxis)
    brakeAxis := SanitizeUserConfiguredKey(brakeAxis)
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

if activeProfileName = "Gamepad" { ; checks keyboard action inputs against the fixed MW2005-HShifter protocol
    for action, definition in gamepadInputDefinitions { ; inspects every configured Gamepad action
        if definition.kind = "Key" && GetReservedProtocolConflict(definition.source) != "" { ; rejects keyboard keys reserved for direct gear injection
            StopProfileLoading("Gamepad " action "Source uses a reserved H-shifter protocol key: " definition.source) ; prevents a gear command from being mistaken for an action
        } ; end reserved key guard
    } ; end action scan
} ; end Gamepad protocol validation
SanitizeUserConfiguredBindings() ; retain existing output and physical binding sanitation

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
    (activeProfileName = "SimRig" && realManualControlsHandbrake && handbrakeAxis != "")
    || (activeProfileName = "Gamepad" && realManualControlsHandbrake)

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
    global invertSequentialShifter, sequentialUpshiftButton, sequentialDownshiftButton

    global activeSequentialUpshiftButton, activeSequentialDownshiftButton

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
; SECTION 12: LOW-LEVEL OUTPUT HELPERS & SAFETY
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
SaveNvidiaInstantReplay(*) {
    SendEvent "!{F10}"
} ; end savenvidiainstantreplay


; ==========================================================================================================================================================
; CaptureNvidiaScreenshot(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Sends NVIDIA Overlay's fixed Alt+F1 screenshot shortcut.
;
; RealManual's configurable hotkey determines which physical controller button invokes this function. The NVIDIA output shortcut itself remains Alt+F1.
; ==========================================================================================================================================================
CaptureNvidiaScreenshot(*) {
    SendEvent "!{F1}"
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
    global forwardKey, throttleBlipMs

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
    global gearKeys, lastSentGear

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
    global reverseAssistHeld, reverseKey

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
    global handbrakeHeld, handbrakeKey

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
    global gearKeys, handbrakeKey, forwardKey, reverseKey
    global shiftUpKey, shiftDownKey

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
; SECTION 13: LOW-LEVEL INPUT READERS
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
; NormalizeAxisActuation(rawValue, releasedValue, pressedValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts a configured axis with either polarity and any distinct 0..100
; endpoints into 0..100 percent ACTUATION (not clutch release).
; ==========================================================================================================================================================
NormalizeAxisActuation(rawValue, releasedValue, pressedValue) {
    span := pressedValue - releasedValue

    if span = 0 {
        return 0 ; maintains a safe numeric result if an invalid definition slips through
    } ; end calibration guard

    actuation := (rawValue - releasedValue) / span * 100
    return Max(0, Min(100, actuation))
} ; end normalizeaxisactuation

; ==========================================================================================================================================================
; ReadGamepadActionPercent(action, &actuationPercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a Gamepad logical action without assuming which physical control owns it.
; Axis: calibrated continuous 0..100 percent; Button/Key/POV: digital 0 or 100.
; Returns false when a source is missing/unreadable.
; ==========================================================================================================================================================
ReadGamepadActionPercent(action, &actuationPercent) {
    global gamepadInputDefinitions

    actuationPercent := 0
    if !gamepadInputDefinitions.Has(action) {
        return false
    } ; end missing-action guard

    definition := gamepadInputDefinitions[action]
    if definition.source = "" { ; rejects an input whose alias could not be resolved
        return false
    } ; end missing-source guard

    if definition.kind = "Key" { ; keyboard keys use physical state to avoid reading synthetic RealManual output
        if !TryGetPhysicalKeyState(definition.source, &keyDown) { ; physical keyboard state
            return false ; physical key is unreadable
        } ; end physical-key read guard

        actuationPercent := keyDown ? 100 : 0
        return true
    } ; end physical-key branch

    if !TryGetInputState(definition.source, &rawValue) {
        return false
    } ; end controller-read guard

    if definition.kind = "Axis" {
        if Type(rawValue) != "Float" && Type(rawValue) != "Integer" {
            return false ; rejects unexpected driver data before arithmetic
        } ; end numeric-type guard

        actuationPercent := NormalizeAxisActuation(rawValue, definition.released, definition.pressed)
        return true
    } ; end analog branch

    if definition.kind = "Button" {
        actuationPercent := rawValue ? 100 : 0
        return true
    } ; end button branch

    if definition.kind = "POV" {
        actuationPercent := rawValue = definition.povDirection ? 100 : 0 ; activates only the requested configured direction
        return true
    } ; end POV branch

    return false
} ; end readgamepadactionpercent

; ==========================================================================================================================================================
; ReadGamepadDigitalAction(action, &isPressed)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts normalized inputs into a logical button using configurable
; hysteresis. Requires a released reading before initially arming or rearming.
; The focused MainLoop polls shifting and ignition; handbrake polls when routed
; through RealManual. Digital sources use immediate binary pressed/released.
; ==========================================================================================================================================================
ReadGamepadDigitalAction(action, &isPressed) {
    global gamepadActivationSettings, gamepadDigitalInputState, gamepadDigitalInputArmed
    global gamepadInputDefinitions

    isPressed := false

    if !gamepadActivationSettings.Has(action) { ; only digital actions are sampled through this state machine
        return false ; prevent an undefined threshold from activating an output
    } ; end missing-threshold guard

    if !ReadGamepadActionPercent(action, &percent) {
        gamepadDigitalInputState[action] := false ; discards any stale pressed state after input loss
        gamepadDigitalInputArmed[action] := false
        return false
    } ; end unavailable-input guard

    thresholds := gamepadActivationSettings[action]
    definition := gamepadInputDefinitions[action]
    ; Analog controls use configurable hysteresis; buttons/keys/POV use exact on/off states.
    onLevel := definition.kind = "Axis" ? thresholds.on : 100
    offLevel := definition.kind = "Axis" ? thresholds.off : 0

    ; A previously held control cannot trigger when the profile starts or hardware reconnects.
    if !gamepadDigitalInputArmed.Get(action, false) {
        if percent <= offLevel {
            gamepadDigitalInputArmed[action] := true
        } ; end release detection

        gamepadDigitalInputState[action] := false
        return true
    } ; end rearm guard

    wasPressed := gamepadDigitalInputState.Get(action, false)
    isPressed := wasPressed ? percent > offLevel : percent >= onLevel
    gamepadDigitalInputState[action] := isPressed

    return true
} ; end readgamepaddigitalaction

; ==========================================================================================================================================================
; ReadClutchAxis()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads and normalizes the configured clutch axis.
;
; Returns:
;   0   = fully pressed
;   100 = fully released
;
; ClutchAxisIncreasesWhenPressed allows either physical axis direction to use
; the same internal clutch convention.
;
; An unavailable clutch axis safely reports fully released.
; ==========================================================================================================================================================
ReadClutchAxis() {
    global clutchAxis, clutchAxisIncreasesWhenPressed

    fallback := clutchAxisIncreasesWhenPressed ? 0 : 100
    clutchValue := SafeGetKeyState(clutchAxis, fallback)

    if clutchAxisIncreasesWhenPressed {
        clutchValue := 100 - clutchValue
    } ; end axis normalization

    return Max(0, Min(100, clutchValue))
} ; end readclutchaxis

; ==========================================================================================================================================================
; ReadProfilePedalSnapshot(&brakePercent, &throttlePercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns independent 0..100 brake and throttle actuation percentages for either profile.
; In combined mode, the centered physical axis is split into opposing half-ranges.
; Returns false when either required input is unreadable rather than inventing a release.
; ==========================================================================================================================================================
ReadProfilePedalSnapshot(&brakePercent, &throttlePercent) {
    global activeProfileName, useCombinedPedals, combinedPedalAxis, brakeAxisIncreasesWhenPressed
    global throttleAxisIncreasesWhenPressed, throttleAxis, brakeAxis

    brakePercent := 0
    throttlePercent := 0
    if activeProfileName = "Gamepad" {
        if !ReadGamepadActionPercent("Brake", &brakePercent) {
            return false
        } ; end brake read

        if !ReadGamepadActionPercent("Throttle", &throttlePercent) {
            return false
        } ; end throttle read

        return true
    } ; end gamepad branch

    if useCombinedPedals {
        ; Combined pedals share a centered axis, with the brake and throttle occupying opposite halves.
        if !TryGetInputState(combinedPedalAxis, &position) {
            return false
        } ; end combined read

        if (Type(position) != "Float" && Type(position) != "Integer") {
            return false
        } ; end numeric guard

        brakeEnd := brakeAxisIncreasesWhenPressed ? 100 : 0
        throttleEnd := brakeAxisIncreasesWhenPressed ? 0 : 100
        brakePercent := NormalizeAxisActuation(position, 50, brakeEnd)
        throttlePercent := NormalizeAxisActuation(position, 50, throttleEnd)

        return true
    } ; end combined mode

    if !TryGetInputState(throttleAxis, &rawThrottle) || !TryGetInputState(brakeAxis, &rawBrake) {
        return false
    } ; end separate input check

    if (Type(rawThrottle) != "Float" && Type(rawThrottle) != "Integer") || (Type(rawBrake) != "Float" && Type(rawBrake) != "Integer") {
        return false
    } ; end numeric guard

    ; Separate pedals use their own full-range axes, and either axis polarity is supported.
    throttleEnd := throttleAxisIncreasesWhenPressed ? 100 : 0
    brakeEnd := brakeAxisIncreasesWhenPressed ? 100 : 0
    throttlePercent := NormalizeAxisActuation(rawThrottle, 100 - throttleEnd, throttleEnd)
    brakePercent := NormalizeAxisActuation(rawBrake, 100 - brakeEnd, brakeEnd)

    return true
} ; end readprofilepedalsnapshot

; ==========================================================================================================================================================
; TryReadProfileClutch(&clutchReleasePercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads the active profile clutch in normalized RELEASE percentage.
; Returns false when the hardware state cannot be trusted.
; ==========================================================================================================================================================
TryReadProfileClutch(&clutchReleasePercent) {
    global activeProfileName, clutchAxis, clutchAxisIncreasesWhenPressed

    clutchReleasePercent := 100

    if activeProfileName = "Gamepad" {
        if !ReadGamepadActionPercent("Clutch", &actuation) {
            return false
        } ; end input failure guard

        clutchReleasePercent := 100 - actuation
        return true
    } ; end gamepad branch

    if !TryGetInputState(clutchAxis, &rawClutch) {
        return false
    } ; end G29 clutch read

    clutchReleasePercent := clutchAxisIncreasesWhenPressed ? 100 - rawClutch : rawClutch
    clutchReleasePercent := Max(0, Min(100, clutchReleasePercent))

    return true ; the physical clutch is readable
} ; end tryreadprofileclutch

; ==========================================================================================================================================================
; ReadHandbrakeAxis()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads and normalizes the configured analog handbrake axis.
;
; Returns:
;   0   = fully released
;   100 = fully pulled
;
; HandbrakeAxisIncreasesWhenPulled allows either physical axis direction to use
; the same internal handbrake convention.
;
; An unavailable handbrake axis safely reports fully released.
; ==========================================================================================================================================================
ReadHandbrakeAxis() {
    global handbrakeAxis, handbrakeAxisIncreasesWhenPulled

    fallback := handbrakeAxisIncreasesWhenPulled ? 0 : 100
    handbrakeValue := SafeGetKeyState(handbrakeAxis, fallback)

    if !handbrakeAxisIncreasesWhenPulled {
        handbrakeValue := 100 - handbrakeValue
    } ; end axis normalization

    return Max(0, Min(100, handbrakeValue))
} ; end readhandbrakeaxis

; ==========================================================================================================================================================
; IsClutchPressed(clutchValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether a previously normalized clutch-axis value represents a
; pressed clutch.
;
; Normalized clutch convention:
;   0   = fully pressed
;   100 = fully released
;
; Clutch pressed if clutchValue < clutchThreshold.
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
    global gearButtons, reverseButton, hPatternMappingValid

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
; IsBrakePercentAboveThreshold(brakePercent, thresholdPercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Compares normalized brake actuation against a percentage threshold.
;
; The strict greater-than comparison preserves threshold-edge behavior.
; ==========================================================================================================================================================
IsBrakePercentAboveThreshold(brakePercent, thresholdPercent) {
    return brakePercent > thresholdPercent
} ; end isbrakepercentabovethreshold

; ==========================================================================================================================================================
; IsBrakePedalActive(brakePercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether normalized braking exceeds the active threshold.
; Uses the active profile brake activation percentage.
; ==========================================================================================================================================================
IsBrakePedalActive(brakePercent) {
    global brakeActivePercent
    return IsBrakePercentAboveThreshold(brakePercent, brakeActivePercent)
} ; end isbrakepedalactive

; ==========================================================================================================================================================
; IsBrakePressedForSequentialReset(brakePercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Checks whether braking qualifies for sequential first-gear recovery.
; Uses the active profile normalized brake-reset percentage.
; ==========================================================================================================================================================
IsBrakePressedForSequentialReset(brakePercent) {
    global brakeResetPercent
    return IsBrakePercentAboveThreshold(brakePercent, brakeResetPercent)
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
    global enableShifterHandbrake, transmissionIsSequential, shifterHandbrakeArmed, shifterHandbrakeButton

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
; Determines whether the normalized analog handbrake position is past the
; configured activation threshold.
;
; Allows physical handbrake and shifter handbrake to coexist.
;
; Returns:
;   true  = analog handbrake is pulled past threshold
;   false = analog handbrake is released, invalid, or disconnected
; ==========================================================================================================================================================
IsAnalogHandbrakeActive() {
    global handbrakeThreshold, activeProfileName, realManualControlsHandbrake

    if !realManualControlsHandbrake {
        return false
    } ; end native route guard

    if activeProfileName = "Gamepad" {
        if !ReadGamepadDigitalAction("Handbrake", &pressed) {
            return false
        } ; end controller read guard

        return pressed
    } ; end controller branch

    return ReadHandbrakeAxis() > handbrakeThreshold
} ; end isanaloghandbrakeactive

; ==========================================================================================================================================================
; ReadClutchReleasePercent(clutchValue)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the release percentage from a previously normalized clutch-axis value:
;   0   = fully pressed
;   100 = fully released
; ==========================================================================================================================================================
ReadClutchReleasePercent(clutchValue) {
    return Max(0, Min(100, clutchValue))
} ; end readclutchreleasepercent

; ==========================================================================================================================================================
; IsBrakePressedForReverseAssist(brakePercent)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Determines whether normalized braking exceeds the reverse-assist engagement threshold.
; ==========================================================================================================================================================
IsBrakePressedForReverseAssist(brakePercent) {
    global engageBrakePercent

    return IsBrakePercentAboveThreshold(brakePercent, engageBrakePercent)
} ; end isbrakepressedforreverseassist

; ==========================================================================================================================================================
; IsFirstGearSelectedForStall(brakePercent, selectedGear := -2)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns true when RealManual currently believes the game is in first gear.
;
; virtualGear is the authoritative tracked game gear.
;
; In H-pattern mode, an unknown or reverse physical shifter state prevents
; first-gear stall detection for that scan.
; ==========================================================================================================================================================
IsFirstGearSelectedForStall(brakePercent, selectedGear := -2) {
    global transmissionIsSequential, virtualGear, lastSentGear

    ; reverse is never treated as first gear.
    if lastSentGear = -1 && IsBrakePedalActive(brakePercent) {
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
; SECTION 14: NOTIFICATIONS, STATUS, VALIDATION, AND LOGGING
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
    global enableToolTips, toolTipDurationMs

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
; Live hotkeys change the running script state only. They do not write back to RealManual.ini. Reloading RealManual restores the saved config file values.
; ==========================================================================================================================================================
ShowLiveModeStatus(changedSetting) {
    global activeProfileName, profileToggleButton\
    global requireClutch, clutchActsAsNeutral, invertSequentialShifter, maxForwardGear
    global enableShifterHandbrake
    global toggleTransmissionModeButton, toggleClutchRequiredButton, toggleClutchNeutralButton
    global toggleSequentialShifterInvertButton
    global toggleMaxForwardGearButton, toggleShifterHandbrakeButton
    global statsShiftsButton, statsStallsButton, statsRaceRestartsButton, raceRestartButton
    global enableStalling, toggleStallingButton
    global stopwatchButton, stopwatchLapButton, stopwatchClearButton
    global helpButton

    message := changedSetting
    message .= "`nProfile: " activeProfileName " [" profileToggleButton "]"
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

    ShowToolTipMessage(message)
} ; end showlivemodestatus

; ==========================================================================================================================================================
; ShowStartupInfo()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Displays a compact startup summary after RealManual.ini has loaded.
;
; Reports runtime behavior settings that meaningfully change RealManual's transmission model.
; Detailed configuration and hardware status are written separately to the validation log.
; ==========================================================================================================================================================
ShowStartupInfo() {
    global appName, appVersion, activeProfileName, transmissionIsSequential
    global requireClutch, clutchActsAsNeutral, enableStalling, writeStartupLog

    modeText := transmissionIsSequential ? "Sequential" : "H-Pattern"
    clutchText := requireClutch ? "Enabled" : "Disabled"
    clutchNeutralText := clutchActsAsNeutral ? "Enabled" : "Disabled"
    stallingText := enableStalling ? "Enabled" : "Disabled"

    title := appName " " appVersion " - Config Loaded"

    compactMessage := "Profile: " activeProfileName
    compactMessage .= "`nMode: " modeText
    compactMessage .= "`nClutch Required: " clutchText
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
    text .= "[WARN] " detail "`n"

    if summary = "" {
        summary := detail
    } ; end default-summary branch

    warningText .= summary "`n"
    warningCount++
} ; end addvalidationwarning

; ==========================================================================================================================================================
; BuildActiveProfileValidationText()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reports the effective active profile, resolved controller roles, and feature state.
; This is diagnostic context; BuildValidationText() performs actual validation.
; ==========================================================================================================================================================
BuildActiveProfileValidationText() {
    global activeProfileName, preferredStartupProfileName, startupProfileSelectionReason
    global autoEnumerateDevices, joystickRoleSlots, profileResolutionWarnings
    global gamepadInputDefinitions, useCombinedPedals
    global brakeActivePercent, brakeResetPercent
    global realManualControlsHandbrake, enableStalling, enableBrakeHoldGearReset

    report := "RealManual Profile Configuration:`n`n"
    report .= "Active profile: " activeProfileName "`n"
    report .= "Configured preference: " preferredStartupProfileName "`n"
    report .= "Startup selection: " startupProfileSelectionReason "`n"
    report .= "Device resolution: " (autoEnumerateDevices ? "automatic hardware-ID match" : "manual joystick slots") "`n"

    ; Resolved controller roles and discovery diagnostics
    for role, slot in joystickRoleSlots {
        report .= role " => joystick " slot "`n"
    } ; end role listing

    for _, warning in profileResolutionWarnings {
        report .= "Device warning: " warning "`n"
    } ; end discovery diagnostics

    ; Active feature state
    report .= "Brake active above: " brakeActivePercent "%`n"
    report .= "Brake reset above: " brakeResetPercent "%`n"
    report .= "Handbrake output: " (realManualControlsHandbrake ? "RealManual" : "NFSMW native") "`n"
    report .= "Brake hold reset: " (enableBrakeHoldGearReset ? "enabled" : "disabled") "`n"
    report .= "Stalling: " (enableStalling ? "enabled" : "disabled") "`n"

    if activeProfileName = "SimRig" {
        report .= "Pedals: " (useCombinedPedals ? "combined" : "separate") "`n"
    } else {
        for action, definition in gamepadInputDefinitions {
            sourceText := definition.source != "" ? definition.source : (definition.kind = "Native" ? "NFSMW native" : "disabled")
            report .= action " => " sourceText " (" definition.kind ")`n"
        } ; end Gamepad input listing
    } ; end active profile branch

    return report
} ; end buildactiveprofilevalidationtext

; ==========================================================================================================================================================
; BuildValidationText()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Builds the active-profile startup report using the dual-profile INI.
;
; Configuration Validation:
;   checks required settings, integer/boolean syntax, and registered ranges.
;
; Configuration Relationships:
;   checks relevant brake/clutch ordering and duplicate transmission mappings.
;
; Hotkey and Protocol Validation:
;   reports registration failures and fixed H-shifter key conflicts.
;
; Hardware Detection:
;   tests only the active profile's configured and resolved physical inputs.
;
; Inactive-profile settings and intentionally optional controls do not produce
; missing-input warnings. Unsafe required profile settings are also rejected
; during profile loading, before this diagnostic report is generated.
; ==========================================================================================================================================================
BuildValidationText() {
    global configFile, activeProfileName, autoEnumerateDevices
    global numericConfigRules, booleanConfigRules, dynamicHotkeyRegistrationResults
    global joystickRoleSlots, resolvedInputBindings, gamepadInputDefinitions
    global useCombinedPedals, realManualControlsHandbrake, enableShifterHandbrake
    global enableStalling, enableBrakeHoldGearReset, enableReverseAssist
    global requireClutch, clutchActsAsNeutral
    global brakeActivePercent, brakeResetPercent, engageBrakePercent
    global clutchThreshold, restartClutchThreshold, clutchReleaseThreshold

    text := BuildActiveProfileValidationText() "`nConfiguration Validation:`n`n"
    warningText := ""
    warningCount := 0
    missingSentinel := "__REALMANUAL_MISSING_CONFIG_VALUE__"
    validatedInts := Map()
    configuredValues := Map()
    configChecks := []

    ; Configuration file
    configExists := FileExist(configFile) != ""
    if configExists {
        text .= "[OK] Config file found: " configFile "`n"
    } else {
        AddValidationWarning(&text, &warningText, &warningCount, "Configuration file missing: " configFile)
    } ; end file validation

    ; Shared configuration sections
    for group in [
        ["Profiles", ["ActiveProfile"], true],
        ["Profiles", ["ToggleProfileButton"], false],
        ["JoystickDevices", ["AutoEnumerateDevices"], true],
        ["General", ["WriteStartupLog", "EnableToolTips", "ToolTipDurationMs"], true],
        ["Hotkeys", ["HelpButton", "ResetButton", "PauseButton", "ReloadButton", "ToggleTransmissionModeButton", "ToggleSequentialShifterInvertButton",
                    "ToggleMaxForwardGearButton", "ToggleClutchRequiredButton", "ToggleClutchNeutralButton", "ToggleShifterHandbrakeButton", "ToggleStallingButton",
                    "StopwatchButton", "StopwatchLapButton", "StopwatchClearButton", "StatsShiftsButton", "StatsStallsButton", "StatsRaceRestartsButton",
                    "RaceRestartButton", "SaveInstantReplayButton", "CaptureScreenshotButton"], false],
        ["GameKeys", ["ForwardKey", "ReverseKey", "HandbrakeKey", "ShiftUpKey", "ShiftDownKey"], true],
        ["Timing", ["KeyHoldMs", "ScanIntervalMs"], true],
        ["Stopwatch", ["StopwatchRefreshMs", "StopwatchMaxLines"], true],
        ["Statistics", ["TrackShifts", "TrackStalls", "TrackRaceRestarts", "ClearAllTimeOnStartup"], true]
    ] {
        for key in group[2] {
            configChecks.Push([group[1], key, group[3]])
        } ; end shared group settings
    } ; end shared configuration groups

    ; The active controller's hardware identity or manual slot is mandatory
    primaryRole := activeProfileName = "SimRig" ? "Wheel" : "Gamepad"
    for role in ["Wheel", "Gamepad", "Handbrake"] {
        field := role (autoEnumerateDevices ? "HardwareId" : "Slot")
        configChecks.Push(["JoystickDevices", field, role = primaryRole])
    } ; end device configuration

    ; Profile-specific configuration, excluding inputs that are intentionally unused
    profilePrefix := "Profile." activeProfileName "."
    if activeProfileName = "SimRig" {
        for group in [
            ["Hotkeys", ["IgnitionButton"], enableStalling],
            ["Transmission", ["StartInSequentialMode", "MaxForwardGear"], true],
            ["Clutch", ["RequireClutch", "ClutchActsAsNeutral", "ClutchAxisIncreasesWhenPressed", "ClutchThreshold"], true],
            ["Clutch", ["ClutchAxis"], requireClutch || clutchActsAsNeutral],
            ["Pedals", ["UseCombinedPedals", "BrakeAxisIncreasesWhenPressed", "BrakeActivePercent"], true],
            ["HPattern", ["Gear1Button", "Gear2Button", "Gear3Button", "Gear4Button", "Gear5Button", "Gear6Button", "ReverseButton"], true],
            ["Sequential", ["InvertSequentialShifter", "SequentialUpshiftButton", "SequentialDownshiftButton", "EnableBrakeHoldGearReset", "BrakeHoldResetMs",
                            "BrakeResetPercent", "QueuedShiftDelayMs"], true],
            ["Sequential", ["PaddleUpshiftButton", "PaddleDownshiftButton"], false],
            ["Handbrake", ["RealManualControlsHandbrake", "EnableShifterHandbrake"], true],
            ["Handbrake", ["ShifterHandbrakeButton"], enableShifterHandbrake],
            ["ReverseAssist", ["EnableReverseAssist"], true]
        ] {
            for key in group[2] {
                configChecks.Push([profilePrefix group[1], key, group[3]])
            } ; end SimRig section entries
        } ; end SimRig sections

        if useCombinedPedals {
            configChecks.Push([profilePrefix "Pedals", "CombinedPedalAxis", true])
        } else {
            for key in ["ThrottleAxis", "BrakeAxis", "ThrottleAxisIncreasesWhenPressed"] {
                configChecks.Push([profilePrefix "Pedals", key, true])
            } ; end separate pedal entries
        } ; end pedal layout

        if realManualControlsHandbrake {
            for key in ["HandbrakeAxis", "HandbrakeAxisIncreasesWhenPulled", "HandbrakeThreshold"] {
                configChecks.Push([profilePrefix "Handbrake", key, false])
            } ; end optional analog handbrake entries
        } ; end RealManual handbrake routing

        if enableReverseAssist {
            configChecks.Push([profilePrefix "ReverseAssist", "EngageBrakePercent", true])
        } ; end reverse-assist settings
    } else {
        for group in [
            ["Transmission", ["MaxForwardGear"], true],
            ["Clutch", ["RequireClutch", "ClutchActsAsNeutral", "ClutchThreshold"], true],
            ["Inputs", ["RealManualControlsHandbrake", "ClutchSource", "ThrottleSource", "BrakeSource", "UpshiftSource", "DownshiftSource"], true],
            ["Inputs", ["IgnitionSource"], enableStalling],
            ["Inputs", ["HandbrakeSource"], realManualControlsHandbrake],
            ["Activation", ["AnalogActivationPercent", "AnalogReleasePercent", "AnalogHandbrakeActivationPercent", "AnalogHandbrakeReleasePercent"], true],
            ["Sequential", ["EnableBrakeHoldGearReset", "BrakeHoldResetMs", "BrakeResetPercent", "QueuedShiftDelayMs"], true],
            ["Stalling", ["BrakeActivePercent"], true]
        ] {
            for key in group[2] {
                configChecks.Push([profilePrefix group[1], key, group[3]])
            } ; end Gamepad section entries
        } ; end Gamepad sections

        ; Axis calibration is meaningful only for an active analog input.
        for action, definition in gamepadInputDefinitions {
            if definition.kind != "Axis" {
                continue
            } ; end non-axis guard

            for suffix in ["Released", "Pressed"] {
                configChecks.Push([profilePrefix "AxisCalibration", action suffix, false])
            } ; end calibration endpoints
        } ; end analog action calibration

        ; POV direction is required only when that action is mapped to a POV.
        for action, definition in gamepadInputDefinitions {
            if definition.kind = "POV" {
                configChecks.Push([profilePrefix "Inputs", action "POVDirection", true])
            } ; end POV action
        } ; end POV direction settings
    } ; end profile-specific configuration

    ; Engine-related settings belong only to the currently selected profile.
    stallingSection := profilePrefix "Stalling"
    configChecks.Push([stallingSection, "EnableStalling", true])

    if enableStalling {
        for key in ["ClutchReleaseThreshold", "ThrottleThreshold", "RestartClutchThreshold", "NeutralResendMs", "ThrottleBlipMs", "NoInputStallDelayMs", "BrakeResetStallGraceMs"] {
            configChecks.Push([stallingSection, key, true])
        } ; end stalling settings
    } ; end engine simulation

    ; Required values, valid syntax and registered numeric bounds
    if configExists {
        for check in configChecks {
            section := check[1]
            key := check[2]
            required := check[3]
            rawValue := ReadConfigValue(section, key, missingSentinel)

            if rawValue = missingSentinel || rawValue = "" {
                if required {
                    AddValidationWarning(&text, &warningText, &warningCount, "[" section "] " key " missing")
                } ; end required setting
                continue
            } ; end blank/missing setting

            ruleKey := ConfigRuleKey(section, key)
            configuredValues[ruleKey] := rawValue

            if numericConfigRules.Has(ruleKey) {
                limits := numericConfigRules[ruleKey]
                if !TryParseConfigInt(rawValue, &number) {
                    AddValidationWarning(&text, &warningText, &warningCount, "[" section "] " key " invalid integer: '" rawValue "'")
                } else if number < limits[1] || number > limits[2] {
                    AddValidationWarning(&text, &warningText, &warningCount, "[" section "] " key " = " number " outside valid range " limits[1] "-" limits[2])
                } else {
                    validatedInts[ruleKey] := number
                    text .= "[OK] [" section "] " key " = " number "`n"
                } ; end numeric validation
            } else if booleanConfigRules.Has(ruleKey) {
                if !TryParseConfigBool(rawValue, &value) {
                    AddValidationWarning(&text, &warningText, &warningCount, "[" section "] " key " must be 0 or 1; got '" rawValue "'")
                } else {
                    text .= "[OK] [" section "] " key " = " rawValue "`n"
                } ; end boolean validation
            } else {
                text .= "[OK] [" section "] " key " configured`n"
            } ; end setting type
        } ; end configuration check loop
    } ; end config presence

    ; Hardware identifier syntax and resolved primary controller
    text .= "`nController Resolution:`n`n"
    if autoEnumerateDevices {
        for role in ["Wheel", "Gamepad", "Handbrake"] {
            field := role "HardwareId"
            key := ConfigRuleKey("JoystickDevices", field)
            if !configuredValues.Has(key) {
                continue
            } ; end absent optional identity
            id := StrUpper(configuredValues[key])
            if !RegExMatch(id, "^VID_[0-9A-F]{4}&PID_[0-9A-F]{4}$") {
                AddValidationWarning(&text, &warningText, &warningCount, "[JoystickDevices] " field " must be VID_XXXX&PID_XXXX")
            } else {
                text .= "[OK] " field " = " id "`n"
            } ; end hardware identity syntax
        } ; end configured role identities
    } ; end automatic resolver

    if joystickRoleSlots.Has(StrLower(primaryRole)) {
        text .= "[OK] Active " primaryRole " resolved to joystick " joystickRoleSlots[StrLower(primaryRole)] "`n"
    } else {
        AddValidationWarning(&text, &warningText, &warningCount, "Active " primaryRole " could not be resolved")
    } ; end active primary hardware

    ; Configuration relationship checks
    text .= "`nConfiguration Relationships:`n`n"
    if enableStalling && (requireClutch || clutchActsAsNeutral) {
        if restartClutchThreshold <= clutchThreshold {
            text .= "[OK] Restart clutch threshold is within the pressed range`n"
        } else {
            AddValidationWarning(&text, &warningText, &warningCount, "RestartClutchThreshold should not exceed ClutchThreshold")
        } ; end restart threshold
        if clutchReleaseThreshold > clutchThreshold {
            text .= "[OK] Stall clutch-release threshold exceeds pressed threshold`n"
        } else {
            AddValidationWarning(&text, &warningText, &warningCount, "ClutchReleaseThreshold should exceed ClutchThreshold")
        } ; end clutch-release threshold
    } ; end active clutch/engine relationship checks

    if enableBrakeHoldGearReset {
        if brakeResetPercent > brakeActivePercent {
            text .= "[OK] Hard-brake reset threshold exceeds normal brake activation`n"
        } else {
            AddValidationWarning(&text, &warningText, &warningCount, "BrakeResetPercent should exceed BrakeActivePercent")
        } ; end brake reset thresholds
    } ; end brake-hold feature

    if activeProfileName = "SimRig" {
        if enableReverseAssist {
            if engageBrakePercent > brakeActivePercent {
                text .= "[OK] Reverse-assist engagement threshold exceeds normal brake activation`n"
            } else {
                AddValidationWarning(&text, &warningText, &warningCount, "EngageBrakePercent should exceed BrakeActivePercent")
            } ; end reverse-assist thresholds
        } ; end reverse-assist relationship

        if !useCombinedPedals {
            throttleKey := ConfigRuleKey(profilePrefix "Pedals", "ThrottleAxis")
            brakeKey := ConfigRuleKey(profilePrefix "Pedals", "BrakeAxis")
            if resolvedInputBindings.Has(throttleKey) && resolvedInputBindings.Has(brakeKey) {
                if resolvedInputBindings[throttleKey] = resolvedInputBindings[brakeKey] {
                    AddValidationWarning(&text, &warningText, &warningCount, "ThrottleAxis and BrakeAxis resolve to the same input")
                } else {
                    text .= "[OK] Separate throttle and brake axes are distinct`n"
                } ; end separate pedal relationship
            } ; end resolved pedal sources
        } ; end separate-pedals mode

        ; Uniqueness is checked within each mapping group
        mappingGroups := [
            ["H-pattern gear/reverse", "HPattern", ["Gear1Button", "Gear2Button", "Gear3Button", "Gear4Button", "Gear5Button", "Gear6Button", "ReverseButton"]],
            ["Sequential shifter", "Sequential", ["SequentialUpshiftButton", "SequentialDownshiftButton"]],
            ["Paddle synchronization", "Sequential", ["PaddleUpshiftButton", "PaddleDownshiftButton"]]
        ]

        for group in mappingGroups {
            seen := Map()
            for key in group[3] {
                inputKey := ConfigRuleKey(profilePrefix group[2], key)
                if !resolvedInputBindings.Has(inputKey) || resolvedInputBindings[inputKey] = "" {
                    continue
                } ; end inactive/missing input

                binding := resolvedInputBindings[inputKey]
                normalized := StrLower(binding)

                if seen.Has(normalized) {
                    AddValidationWarning(&text, &warningText, &warningCount, group[1] ": " seen[normalized] " and " key " share input [" binding "]")
                } else {
                    seen[normalized] := key
                } ; end duplicate mapping
            } ; end group input loop
        } ; end mapping groups
    } else {
        onKey := ConfigRuleKey(profilePrefix "Activation", "AnalogActivationPercent")
        offKey := ConfigRuleKey(profilePrefix "Activation", "AnalogReleasePercent")
        handOnKey := ConfigRuleKey(profilePrefix "Activation", "AnalogHandbrakeActivationPercent")
        handOffKey := ConfigRuleKey(profilePrefix "Activation", "AnalogHandbrakeReleasePercent")

        for pair in [[onKey, offKey], [handOnKey, handOffKey]] {
            if validatedInts.Has(pair[1]) && validatedInts.Has(pair[2]) {
                if validatedInts[pair[1]] <= validatedInts[pair[2]] {
                    AddValidationWarning(&text, &warningText, &warningCount, "Analog activation threshold must exceed its release threshold")
                } else {
                    text .= "[OK] Analog activation/release hysteresis is valid`n"
                } ; end hysteresis relationship
            } ; end validated threshold pair
        } ; end Gamepad hysteresis pairs
    } ; end profile relationships

    ; Hotkey registration and fixed MW2005-HShifter protocol conflicts
    text .= "`nHotkey Validation:`n`n"
    for result in dynamicHotkeyRegistrationResults {
        switch result.status {
            case "registered":
                text .= "[OK] " result.label " [" result.hotkey "] registered`n"
            case "reserved":
                AddValidationWarning(&text, &warningText, &warningCount, "[Hotkeys] " result.setting " [" result.hotkey "] conflicts with " result.detail "; hotkey not registered")
            case "duplicate":
                AddValidationWarning(&text, &warningText, &warningCount, "Hotkey [" result.hotkey "] assigned to both " result.detail " and " result.label)
            case "failed":
                detail := "[Hotkeys] " result.setting " could not register [" result.hotkey "]"
                if result.detail != "" {
                    detail .= ": " result.detail
                } ; end registration failure reason
                AddValidationWarning(&text, &warningText, &warningCount, detail)
        } ; end hotkey registration status
    } ; end registered hotkeys

    ; Uses only active profile bindings, including resolved role aliases
    text .= "`nProtocol Binding Validation:`n`n"
    for check in configChecks {
        section := check[1]
        key := check[2]

        if section = "Hotkeys" || section = "JoystickDevices" || !RegExMatch(key, "i)(?:Source|Axis|Button|Key)$") {
            continue
        } ; end non-binding entry

        ruleKey := ConfigRuleKey(section, key)

        if activeProfileName = "Gamepad" && !realManualControlsHandbrake && ruleKey = ConfigRuleKey("Profile.Gamepad.Inputs", "HandbrakeSource") {
            continue
        } ; end NFSMW-native handbrake

        if !configuredValues.Has(ruleKey) {
            continue
        } ; end unconfigured binding

        binding := resolvedInputBindings.Has(ruleKey) ? resolvedInputBindings[ruleKey] : configuredValues[ruleKey]

        if binding = "" {
            continue
        } ; end disabled binding

        reservedPurpose := GetReservedProtocolConflict(binding)

        if reservedPurpose != "" {
            AddValidationWarning(&text, &warningText, &warningCount, "[" section "] " key " [" binding "] conflicts with " reservedPurpose "; runtime binding disabled")
        } ; end reserved protocol collision
    } ; end active binding checks

    ; Test resolved, active physical inputs through AutoHotkey's joystick reader.
    text .= "`nHardware Detection:`n`n"
    for ruleKey, inputName in resolvedInputBindings {
        if activeProfileName = "Gamepad" && !realManualControlsHandbrake && ruleKey = ConfigRuleKey("Profile.Gamepad.Inputs", "HandbrakeSource") {
            continue
        } ; end NFSMW-native handbrake

        if inputName = "" || GetReservedProtocolConflict(inputName) != "" {
            continue
        } ; end unused/unsafe binding

        if DetectInputHardware(inputName) {
            text .= "[OK] " ruleKey " detected: " inputName "`n"
        } else {
            AddValidationWarning(&text, &warningText, &warningCount, ruleKey " not detected: " inputName)
        } ; end hardware detection
    } ; end active resolved bindings

    if warningCount = 0 {
        text .= "`nReady."
    } else {
        text .= "`n[WARNING] " warningCount " warning(s):`n" warningText
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
; SECTION 15: STATISTICS & SHARED OVERLAY LAYOUT
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
    global sessionShiftCount, sessionStallCount, sessionRaceRestartCount
    global allTimeShiftCount, allTimeStallCount, allTimeRaceRestartCount

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
    global configFile, clearAllTimeOnStartup
    global allTimeShiftCount, allTimeStallCount, allTimeRaceRestartCount

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
    global sessionShiftCount, sessionStallCount, sessionRaceRestartCount
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
    global sessionProcessPid, sessionShiftCount, sessionStallCount, sessionRaceRestartCount
    global allTimeShiftCount, allTimeStallCount, allTimeRaceRestartCount

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
; ==========================================================================================================================================================
RecordShift(targetGear) {
    global trackShifts, statsLastGear, sessionShiftCount, stallSuppressedUntilShift

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
    global trackStalls, sessionStallCount

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
    global trackRaceRestarts, sessionRaceRestartCount

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
; Returns:
;   true  = at least one statistics line is selected for display
;   false = no statistics lines are selected
; ==========================================================================================================================================================
IsStatsDisplayActive() {
    global showShiftStats, showStallStats, showRaceRestartStats

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
    global stopwatchStarted, statsOverlayOrder, stopwatchOverlayOrder, overlayPrimaryX
    global overlaySecondaryX

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
;   1. the statistic is enabled for tracking in RealManual.ini
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
    global enableToolTips, trackShifts, trackStalls, trackRaceRestarts
    global showShiftStats, showStallStats, showRaceRestartStats, sessionShiftCount
    global sessionStallCount, sessionRaceRestartCount, statsToolTipId, overlayY

    if !enableToolTips
        || !IsStatsDisplayActive() {
        ; Clears only the statistics tooltip.
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

    ; Shows statistics overlay
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
; enabled in RealManual.ini.
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
    global trackShifts, trackStalls, trackRaceRestarts, showShiftStats
    global showStallStats, showRaceRestartStats, overlayActivationCounter, statsOverlayOrder
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
        statsOverlayOrder := overlayActivationCounter
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
; SECTION 16: STOPWATCH
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
    global stopwatchStarted, stopwatchRunning, stopwatchStartTime, stopwatchAccumulatedMs

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
    global enableToolTips, stopwatchStarted, stopwatchRunning, stopwatchLaps
    global stopwatchToolTipId, overlayY

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
    global stopwatchStarted, stopwatchRunning, stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchRefreshMs, overlayActivationCounter, stopwatchOverlayOrder

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
        stopwatchAccumulatedMs += A_TickCount - stopwatchStartTime
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
    global stopwatchStarted, stopwatchRunning, stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchRefreshMs, stopwatchLaps, stopwatchMaxLines

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
    global stopwatchStarted, stopwatchRunning, stopwatchStartTime, stopwatchAccumulatedMs
    global stopwatchLaps, stopwatchToolTipId, stopwatchOverlayOrder

    ; Stops stopwatch refresh timer
    SetTimer(UpdateStopwatchDisplay, 0)

    ; Resets stopwatch state
    stopwatchStarted := false
    stopwatchRunning := false
    stopwatchStartTime := 0
    stopwatchAccumulatedMs := 0
    stopwatchLaps := []

    ; Removes From Shared Overlay Layout
    stopwatchOverlayOrder := 0

    ; Clears Stopwatch Tooltip
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
; SECTION 17: TRANSIENT STATE CLEAR / DISARM HELPERS
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
    global lastUpshiftPressed, lastDownshiftPressed, lastPaddleUpshiftPressed, lastPaddleDownshiftPressed
    global paddleSyncArmed, reverseCommandLatched, lastKeyboardUpshiftPressed, lastKeyboardDownshiftPressed
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
    global lastClutchPressed, clutchNeutralSent

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
    DisarmGamepadDigitalInputs()
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
    DisarmGamepadDigitalInputs()
} ; end disarmedgeinputs

; ==========================================================================================================================================================
; DisarmGamepadDigitalInputs()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears action edges after focus loss or other input interruption.
; Prevents a held analog source from generating an unintended new action.
; ==========================================================================================================================================================
DisarmGamepadDigitalInputs() {
    global gamepadDigitalInputState, gamepadDigitalInputArmed

    gamepadDigitalInputState.Clear()
    gamepadDigitalInputArmed.Clear()
} ; end disarmgamepaddigitalinputs

; ==========================================================================================================================================================
; ClearStallDetectionState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears transient state belonging to an in-progress stall-detection cycle.
; ==========================================================================================================================================================
ClearStallDetectionState() {
    global stallDetectionArmed, noInputStallStartTime

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
    global brakeResetStallGraceActive, brakeResetReleaseTime

    brakeResetStallGraceActive := false
    brakeResetReleaseTime := 0
} ; end clearbrakeresetstallgracestate

; ==========================================================================================================================================================
; ClearSequentialBrakeHoldTimer()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Clears the in-progress sequential brake-hold timer when continuous input
; observation is interrupted, such as by focus loss or script pause.
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
    global brakeHoldStartTime, brakeHoldResetTriggered, sequentialReverseAssistEligible

    brakeHoldStartTime := 0
    brakeHoldResetTriggered := false
    sequentialReverseAssistEligible := false

    ClearBrakeResetStallGraceState()
} ; end clearsequentialbrakeresetstate


; ==========================================================================================================================================================
; SECTION 18: PROFILE SWITCHING, DYNAMIC HOTKEYS, AND LIVE MODE TOGGLES
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; SwitchProfileBoolean(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a target profile Boolean for a potential controller switch.
; Validates the value before any active global is modified.
; ==========================================================================================================================================================
SwitchProfileBoolean(section, key, fallback) {
    raw := ReadConfigValue(section, key, fallback ? "1" : "0")

    if !TryParseConfigBool(raw, &value) {
        throw Error("[" section "] " key " must be 0 or 1")
    } ; end boolean check

    return value
} ; end switchprofileboolean

; ==========================================================================================================================================================
; SwitchProfileInteger(section, key, fallback)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Reads a target profile integer using registered range constraints.
; Keeps candidate evaluation separate from active configuration.
; ==========================================================================================================================================================
SwitchProfileInteger(section, key, fallback) {
    global numericConfigRules

    ruleKey := ConfigRuleKey(section, key)

    if !numericConfigRules.Has(ruleKey) {
        throw Error("missing numeric validation rule: [" section "] " key)
    } ; end registered bounds guard

    raw := ReadConfigValue(section, key, fallback "")

    if !TryParseConfigInt(raw, &value) {
        throw Error("[" section "] " key " must be an integer")
    } ; end syntax check

    bounds := numericConfigRules[ruleKey]

    if value < bounds[1] || value > bounds[2] {
        throw Error("[" section "] " key " must be " bounds[1] ".." bounds[2])
    } ; end range check

    return value
} ; end switchprofileinteger

; ==========================================================================================================================================================
; SwitchResolveInput(section, key, roles, optional := false)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Resolves one candidate input against newly enumerated roles.
; Does not modify the current role map before a successful switch.
; ==========================================================================================================================================================
SwitchResolveInput(section, key, roles, optional := false) {
    binding := ReadText(section, key)

    if binding = "" {
        if optional {
            return ""
        } ; end optional guard

        throw Error("[" section "] " key " is missing") ; block invalid target profile
    } ; end absent binding guard

    if RegExMatch(binding, "i)^(Gamepad|Wheel|Handbrake):Joy([1-9]|[12][0-9]|3[0-2]|X|Y|Z|R|U|V|POV)$", &match) {
        role := StrLower(match[1])

        if !roles.Has(role) {
            throw Error("[" section "] " key " requires a connected " match[1])
        } ; end missing role

        return roles[role] "Joy" match[2] ; produces an AHK-readable physical binding
    } ; end role alias resolution

    if InStr(binding, ":") || RegExMatch(binding, "i)^\d+Joy") && !RegExMatch(binding, "i)^(?:[1-9]|1[0-6])Joy(?:X|Y|Z|R|U|V|POV|[1-9]|[12][0-9]|3[0-2])$") {
        throw Error("[" section "] " key " has unsupported binding: " binding)
    } ; end malformed binding guard

    return binding
} ; end switchresolveinput

; ==========================================================================================================================================================
; SwitchRequireAvailable(binding, label)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Verifies a candidate physical input is currently readable.
; Refuses profile activation when a required device is unavailable.
; ==========================================================================================================================================================
SwitchRequireAvailable(binding, label) {
    if !TryGetInputState(binding, &value) {
        throw Error(label " could not be read: " binding)
    } ; end inaccessible input check

    return value
} ; end switchrequireavailable

; ==========================================================================================================================================================
; BuildProfileSwitchCandidate(target)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Prepares and validates the complete target profile configuration.
; Keeps the running profile unchanged until commit succeeds.
; ==========================================================================================================================================================
BuildProfileSwitchCandidate(target) {
    global profileMutableOverrides, virtualGear, autoEnumerateDevices

    s := Map()
    s["activeProfileName"] := target
    roles := ResolveConfiguredJoystickRoles(&deviceWarnings)
    wanted := target = "Gamepad" ? "gamepad" : "wheel"

    if !roles.Has(wanted) {
        if autoEnumerateDevices && ReadText("JoystickDevices", target "HardwareId") = "" {
            throw Error("[JoystickDevices] " target "HardwareId must contain VID_XXXX&PID_XXXX from the identity detector")
        } ; end missing target ID

        detail := ""

        for _, warning in deviceWarnings {
            detail .= "`n- " warning
        } ; end warnings

        throw Error(target " requires " (autoEnumerateDevices ? "one uniquely matching hardware ID" : "a connected " wanted " slot") detail)
    } ; end missing device guard

    if target = "SimRig" && roles.Has("handbrake") && roles["handbrake"] = roles["wheel"] {
        throw Error("WheelSlot and HandbrakeSlot cannot be the same device")
    } ; end role collision

    s["joystickRoleSlots"] := roles
    ts := "Profile." target ".Transmission"
    cs := "Profile." target ".Clutch"
    ps := "Profile." target ".Pedals"
    hs := "Profile." target ".Handbrake"
    ss := "Profile." target ".Sequential"
    es := "Profile." target ".Stalling"
    s["maxForwardGear"] := SwitchProfileInteger(ts, "MaxForwardGear", 6)

    if virtualGear > s["maxForwardGear"] {
        throw Error("shift down to gear " s["maxForwardGear"] " or lower before switching")
    } ; end gearbox incompatibility

    s["requireClutch"] := SwitchProfileBoolean(cs, "RequireClutch", true)
    s["clutchActsAsNeutral"] := SwitchProfileBoolean(cs, "ClutchActsAsNeutral", true)
    s["clutchThreshold"] := SwitchProfileInteger(cs, "ClutchThreshold", 40)
    s["throttleAxis"] := ""
    s["brakeAxis"] := ""
    s["combinedPedalAxis"] := ""
    s["handbrakeAxis"] := ""
    s["gearButtons"] := Map()
    s["gamepadInputDefinitions"] := Map()
    s["gamepadActivationSettings"] := Map()
    s["ignitionButton"] := ""
    s["paddleSyncConfigured"] := false
    s["analogHandbrakeConfigured"] := false
    s["shifterHandbrakeConflict"] := false
    s["hPatternMappingValid"] := false
    s["engageBrakePercent"] := 20
    s["handbrakeThreshold"] := 20
    s["handbrakeAxisIncreasesWhenPulled"] := true
    s["throttleAxisIncreasesWhenPressed"] := true
    s["brakeAxisIncreasesWhenPressed"] := true
    s["useCombinedPedals"] := false
    s["invertSequentialShifter"] := false
    s["enableShifterHandbrake"] := false
    s["shifterHandbrakeButton"] := ""
    s["enableReverseAssist"] := false
    s["toggleTransmissionModeButton"] := ""
    s["toggleSequentialShifterInvertButton"] := ""
    s["toggleShifterHandbrakeButton"] := ""
    s["realManualControlsHandbrake"] := false

    if target = "SimRig" {
        s["transmissionIsSequential"] := SwitchProfileBoolean(ts, "StartInSequentialMode", false)
        s["clutchAxisIncreasesWhenPressed"] := SwitchProfileBoolean(cs, "ClutchAxisIncreasesWhenPressed", false)
        s["clutchAxis"] := SwitchResolveInput(cs, "ClutchAxis", roles)
        SwitchRequireAvailable(s["clutchAxis"], "SimRig clutch")
        s["useCombinedPedals"] := SwitchProfileBoolean(ps, "UseCombinedPedals", true)
        s["brakeAxisIncreasesWhenPressed"] := SwitchProfileBoolean(ps, "BrakeAxisIncreasesWhenPressed", true)

        if s["useCombinedPedals"] {
            s["combinedPedalAxis"] := SwitchResolveInput(ps, "CombinedPedalAxis", roles)
            SwitchRequireAvailable(s["combinedPedalAxis"], "Combined pedals")
            s["throttleAxisIncreasesWhenPressed"] := !s["brakeAxisIncreasesWhenPressed"]
        } else {
            s["throttleAxis"] := SwitchResolveInput(ps, "ThrottleAxis", roles)
            s["brakeAxis"] := SwitchResolveInput(ps, "BrakeAxis", roles)

            if s["throttleAxis"] = s["brakeAxis"] {
                throw Error("SimRig separate throttle and brake axes must differ")
            } ; end pedal uniqueness

            s["throttleAxisIncreasesWhenPressed"] := SwitchProfileBoolean(ps, "ThrottleAxisIncreasesWhenPressed", false)
            SwitchRequireAvailable(s["throttleAxis"], "Separate throttle")
            SwitchRequireAvailable(s["brakeAxis"], "Separate brake")
        } ; end pedal selection

        s["brakeActivePercent"] := SwitchProfileInteger(ps, "BrakeActivePercent", 10)

        for index in [1, 2, 3, 4, 5, 6] {
            source := SwitchResolveInput("Profile.SimRig.HPattern", "Gear" index "Button", roles)
            s["gear" index "Button"] := source

            if s["gearButtons"].Has(source) {
                throw Error("SimRig H-pattern gear " index " duplicates another gear button")
            } ; end duplicate gear guard

            s["gearButtons"][source] := index
        } ; end forward gear loop

        s["reverseButton"] := SwitchResolveInput("Profile.SimRig.HPattern", "ReverseButton", roles)

        if s["gearButtons"].Has(s["reverseButton"]) {
            throw Error("SimRig reverse binding duplicates a forward-gear binding")
        } ; end reverse collision

        s["hPatternMappingValid"] := true
        s["invertSequentialShifter"] := SwitchProfileBoolean(ss, "InvertSequentialShifter", false)
        s["sequentialUpshiftButton"] := SwitchResolveInput(ss, "SequentialUpshiftButton", roles)
        s["sequentialDownshiftButton"] := SwitchResolveInput(ss, "SequentialDownshiftButton", roles)
        s["paddleUpshiftButton"] := SwitchResolveInput(ss, "PaddleUpshiftButton", roles, true)
        s["paddleDownshiftButton"] := SwitchResolveInput(ss, "PaddleDownshiftButton", roles, true)
        s["paddleSyncConfigured"] := s["paddleUpshiftButton"] != "" && s["paddleDownshiftButton"] != ""
        s["realManualControlsHandbrake"] := SwitchProfileBoolean(hs, "RealManualControlsHandbrake", true)

        if s["realManualControlsHandbrake"] {
            s["handbrakeAxis"] := SwitchResolveInput(hs, "HandbrakeAxis", roles, true)

            if s["handbrakeAxis"] != "" {
                SwitchRequireAvailable(s["handbrakeAxis"], "External handbrake")
            } ; end optional lever
        } ; end script routing branch

        s["handbrakeAxisIncreasesWhenPulled"] := SwitchProfileBoolean(hs, "HandbrakeAxisIncreasesWhenPulled", true)
        s["handbrakeThreshold"] := SwitchProfileInteger(hs, "HandbrakeThreshold", 20)
        s["enableShifterHandbrake"] := SwitchProfileBoolean(hs, "EnableShifterHandbrake", false)
        s["shifterHandbrakeButton"] := SwitchResolveInput(hs, "ShifterHandbrakeButton", roles, true)
        s["analogHandbrakeConfigured"] := s["realManualControlsHandbrake"] && s["handbrakeAxis"] != ""
        s["enableReverseAssist"] := SwitchProfileBoolean("Profile.SimRig.ReverseAssist", "EnableReverseAssist", false)
        s["engageBrakePercent"] := SwitchProfileInteger("Profile.SimRig.ReverseAssist", "EngageBrakePercent", 20)
        s["ignitionButton"] := SwitchResolveInput("Profile.SimRig.Hotkeys", "IgnitionButton", roles, true)
        s["toggleTransmissionModeButton"] := ReadText("Hotkeys", "ToggleTransmissionModeButton")
        s["toggleSequentialShifterInvertButton"] := ReadText("Hotkeys", "ToggleSequentialShifterInvertButton")
        s["toggleShifterHandbrakeButton"] := ReadText("Hotkeys", "ToggleShifterHandbrakeButton")
    } else {
        s["transmissionIsSequential"] := true
        s["clutchAxisIncreasesWhenPressed"] := true
        inputs := "Profile.Gamepad.Inputs"
        calibrations := "Profile.Gamepad.AxisCalibration"
        activation := "Profile.Gamepad.Activation"
        s["realManualControlsHandbrake"] := SwitchProfileBoolean(inputs, "RealManualControlsHandbrake", false)

        for action in ["Clutch", "Throttle", "Brake", "Handbrake", "Upshift", "Downshift", "Ignition"] {
            optional := (action = "Ignition") || (action = "Handbrake" && !s["realManualControlsHandbrake"])
            source := SwitchResolveInput(inputs, action "Source", roles, optional)

            if source = "" {
                kind := action = "Handbrake" ? "Native" : "Disabled"
                s["gamepadInputDefinitions"][action] := {source: "", kind: kind, released: 0, pressed: 100, povDirection: -1}
                continue
            } ; end optional source

            kind := InferGamepadInputKind(source)

            if kind = "" {
                throw Error("Gamepad " action "Source is unsupported: " source)
            } ; end kind check

            released := action = "Brake" ? 50 : 0
            pressed := 100

            if kind = "Axis" { ; only analog inputs require calibration endpoints
                released := SwitchProfileInteger(calibrations, action "Released", released)
                pressed := SwitchProfileInteger(calibrations, action "Pressed", pressed)

                if released = pressed {
                    throw Error("Gamepad " action " calibration endpoints must differ")
                } ; end endpoint check
            } ; end analog mapping

            pov := -1

            if kind = "POV" {
                raw := ReadText(inputs, action "POVDirection")

                if !TryParseConfigInt(raw, &pov) || pov > 31500 || Mod(pov, 4500) != 0 {
                    throw Error("Gamepad " action "POVDirection must be 0,4500,...,31500")
                } ; end directional validation
            } ; end POV angle

            if kind != "Key" {
                SwitchRequireAvailable(source, "Gamepad " action)
            } ; end physical source check

            if kind = "Key" {
                if GetReservedProtocolConflict(source) != "" {
                    throw Error("Gamepad " action " keyboard mapping uses a reserved H-shifter protocol key")
                } ; end protected gear keys

                if !TryGetPhysicalKeyState(source, &physicalKeyPressed) {
                    throw Error("Gamepad " action " keyboard input cannot be read: " source)
                } ; end physical key availability
            } ; end keyboard validation

            s["gamepadInputDefinitions"][action] := {source: source, kind: kind, released: released, pressed: pressed, povDirection: pov}
        } ; end action loop

        if s["gamepadInputDefinitions"]["Upshift"].source = s["gamepadInputDefinitions"]["Downshift"].source {
            throw Error("Gamepad upshift and downshift inputs must be different")
        } ; end shift conflict

        onPct := SwitchProfileInteger(activation, "AnalogActivationPercent", 60)
        offPct := SwitchProfileInteger(activation, "AnalogReleasePercent", 40)
        brakeOn := SwitchProfileInteger(activation, "AnalogHandbrakeActivationPercent", 20)
        brakeOff := SwitchProfileInteger(activation, "AnalogHandbrakeReleasePercent", 15)

        if onPct <= offPct || brakeOn <= brakeOff {
            throw Error("Gamepad analog activation percentages must exceed release percentages")
        } ; end gap validation

        for action in ["Upshift", "Downshift", "Ignition"] {
            s["gamepadActivationSettings"][action] := {on: onPct, off: offPct}
        } ; end threshold loop

        s["gamepadActivationSettings"]["Handbrake"] := {on: brakeOn, off: brakeOff}
        s["clutchAxis"] := s["gamepadInputDefinitions"]["Clutch"].source
        s["sequentialUpshiftButton"] := s["gamepadInputDefinitions"]["Upshift"].source
        s["sequentialDownshiftButton"] := s["gamepadInputDefinitions"]["Downshift"].source
        s["paddleUpshiftButton"] := ""
        s["paddleDownshiftButton"] := ""
        s["brakeActivePercent"] := SwitchProfileInteger(es, "BrakeActivePercent", 10)
        s["analogHandbrakeConfigured"] := s["realManualControlsHandbrake"]

        for index in [1, 2, 3, 4, 5, 6] {
            s["gear" index "Button"] := ""
        } ; end no H-pattern loop

        s["reverseButton"] := ""
    } ; end profile configuration branch

    s["enableBrakeHoldGearReset"] := SwitchProfileBoolean(ss, "EnableBrakeHoldGearReset", target = "SimRig")
    s["brakeHoldResetMs"] := SwitchProfileInteger(ss, "BrakeHoldResetMs", 2000)
    s["brakeResetPercent"] := SwitchProfileInteger(ss, "BrakeResetPercent", 40)
    s["queuedShiftDelayMs"] := SwitchProfileInteger(ss, "QueuedShiftDelayMs", 35)
    s["enableStalling"] := SwitchProfileBoolean(es, "EnableStalling", false)

    s["clutchReleaseThreshold"] := SwitchProfileInteger(es, "ClutchReleaseThreshold", 60)
    s["throttleThreshold"] := SwitchProfileInteger(es, "ThrottleThreshold", 15)
    s["restartClutchThreshold"] := SwitchProfileInteger(es, "RestartClutchThreshold", 15)
    s["neutralResendMs"] := SwitchProfileInteger(es, "NeutralResendMs", 50)
    s["throttleBlipMs"] := SwitchProfileInteger(es, "ThrottleBlipMs", 500)
    s["noInputStallDelayMs"] := SwitchProfileInteger(es, "NoInputStallDelayMs", 700)
    s["brakeResetStallGraceMs"] := SwitchProfileInteger(es, "BrakeResetStallGraceMs", 100)

    if target = "SimRig" {
        if s["sequentialUpshiftButton"] = s["sequentialDownshiftButton"] {
            throw Error("SimRig sequential upshift and downshift inputs must differ")
        } ; end sequential duplicate

        s["shifterHandbrakeConflict"] := s["shifterHandbrakeButton"] != ""
            && (s["shifterHandbrakeButton"] = s["sequentialUpshiftButton"] || s["shifterHandbrakeButton"] = s["sequentialDownshiftButton"])
    } ; end SimRig conflict calculation

    s["paddleSyncConfigured"] := s["paddleUpshiftButton"] != "" && s["paddleDownshiftButton"] != ""

    if target = "SimRig" {
        s["toggleTransmissionModeButton"] := ReadText("Hotkeys", "ToggleTransmissionModeButton")
        s["toggleSequentialShifterInvertButton"] := ReadText("Hotkeys", "ToggleSequentialShifterInvertButton")
        s["toggleShifterHandbrakeButton"] := ReadText("Hotkeys", "ToggleShifterHandbrakeButton")
    } ; end rig hotkeys

    if profileMutableOverrides.Has(target) {
        for key, value in profileMutableOverrides[target] {
            s[key] := value
        } ; end saved option loop
    } ; end override restore

    if virtualGear > s["maxForwardGear"] {
        throw Error("target gearbox limit is below current gear " virtualGear)
    } ; end live limit guard

    if target = "Gamepad" && s["enableStalling"] && s["gamepadInputDefinitions"]["Ignition"].source = "" {
        throw Error("Gamepad stalling requires a usable IgnitionSource")
    } ; end saved stalling validation

    if target = "SimRig" && !s["transmissionIsSequential"] {
        for buttonName, gearIndex in s["gearButtons"] {
            if SwitchRequireAvailable(buttonName, "H-pattern gear " gearIndex) {
                throw Error("place the physical H-shifter in neutral before switching to H-pattern")
            } ; end active gear
        } ; end physical gear scan

        if SwitchRequireAvailable(s["reverseButton"], "H-pattern reverse") {
            throw Error("place the physical H-shifter in neutral before switching to H-pattern")
        } ; end reverse release
    } ; end H-pattern neutral gate

    return s
} ; end buildprofileswitchcandidate

; ==========================================================================================================================================================
; CaptureProfileMutableOptions()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Saves a profile's current in-memory feature toggles.
; Allows each profile to restore its own temporary options.
; ==========================================================================================================================================================
CaptureProfileMutableOptions() {
    global activeProfileName, profileMutableOverrides, requireClutch, clutchActsAsNeutral
    global maxForwardGear, transmissionIsSequential, invertSequentialShifter, enableShifterHandbrake
    global enableStalling

    profileMutableOverrides[activeProfileName] := Map(
        "requireClutch", requireClutch, "clutchActsAsNeutral", clutchActsAsNeutral,
        "maxForwardGear", maxForwardGear, "transmissionIsSequential", transmissionIsSequential,
        "invertSequentialShifter", invertSequentialShifter, "enableShifterHandbrake", enableShifterHandbrake,
        "enableStalling", enableStalling)
} ; end captureprofilemutableoptions

; ==========================================================================================================================================================
; CommitProfileSwitch(s)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Applies a validated profile candidate as one guarded transition.
; Preserves persistent counters and avoids resetting the tracked gear.
; ==========================================================================================================================================================
CommitProfileSwitch(s) {
    global maxForwardGear, requireClutch, clutchActsAsNeutral, clutchThreshold
    global clutchAxis, clutchAxisIncreasesWhenPressed, useCombinedPedals, combinedPedalAxis
    global throttleAxis, brakeAxis, throttleAxisIncreasesWhenPressed, brakeAxisIncreasesWhenPressed
    global brakeActivePercent, gear1Button, gear2Button, gear3Button
    global gear4Button, gear5Button, gear6Button, reverseButton
    global invertSequentialShifter, sequentialUpshiftButton, sequentialDownshiftButton, paddleUpshiftButton
    global paddleDownshiftButton, enableBrakeHoldGearReset, brakeHoldResetMs, brakeResetPercent
    global queuedShiftDelayMs, realManualControlsHandbrake, handbrakeAxis, handbrakeAxisIncreasesWhenPulled
    global handbrakeThreshold, enableShifterHandbrake, shifterHandbrakeButton, enableStalling
    global enableReverseAssist, engageBrakePercent, clutchReleaseThreshold, throttleThreshold
    global restartClutchThreshold, neutralResendMs, throttleBlipMs, noInputStallDelayMs
    global brakeResetStallGraceMs, ignitionButton, toggleTransmissionModeButton
    global toggleSequentialShifterInvertButton, toggleShifterHandbrakeButton, activeProfileName
    global transmissionIsSequential, joystickRoleSlots, gamepadInputDefinitions, gamepadActivationSettings
    global paddleSyncConfigured, analogHandbrakeConfigured, shifterHandbrakeConflict, hPatternMappingValid
    global gearButtons
    maxForwardGear := s["maxForwardGear"]
    requireClutch := s["requireClutch"]
    clutchActsAsNeutral := s["clutchActsAsNeutral"]
    clutchThreshold := s["clutchThreshold"]
    clutchAxis := s["clutchAxis"]
    clutchAxisIncreasesWhenPressed := s["clutchAxisIncreasesWhenPressed"]
    useCombinedPedals := s["useCombinedPedals"]
    combinedPedalAxis := s["combinedPedalAxis"]
    throttleAxis := s["throttleAxis"]
    brakeAxis := s["brakeAxis"]
    throttleAxisIncreasesWhenPressed := s["throttleAxisIncreasesWhenPressed"]
    brakeAxisIncreasesWhenPressed := s["brakeAxisIncreasesWhenPressed"]
    brakeActivePercent := s["brakeActivePercent"]
    gear1Button := s["gear1Button"]
    gear2Button := s["gear2Button"]
    gear3Button := s["gear3Button"]
    gear4Button := s["gear4Button"]
    gear5Button := s["gear5Button"]
    gear6Button := s["gear6Button"]
    reverseButton := s["reverseButton"]
    invertSequentialShifter := s["invertSequentialShifter"]
    sequentialUpshiftButton := s["sequentialUpshiftButton"]
    sequentialDownshiftButton := s["sequentialDownshiftButton"]
    paddleUpshiftButton := s["paddleUpshiftButton"]
    paddleDownshiftButton := s["paddleDownshiftButton"]
    enableBrakeHoldGearReset := s["enableBrakeHoldGearReset"]
    brakeHoldResetMs := s["brakeHoldResetMs"]
    brakeResetPercent := s["brakeResetPercent"]
    queuedShiftDelayMs := s["queuedShiftDelayMs"]
    realManualControlsHandbrake := s["realManualControlsHandbrake"]
    handbrakeAxis := s["handbrakeAxis"]
    handbrakeAxisIncreasesWhenPulled := s["handbrakeAxisIncreasesWhenPulled"]
    handbrakeThreshold := s["handbrakeThreshold"]
    enableShifterHandbrake := s["enableShifterHandbrake"]
    shifterHandbrakeButton := s["shifterHandbrakeButton"]
    enableStalling := s["enableStalling"]
    enableReverseAssist := s["enableReverseAssist"]
    engageBrakePercent := s["engageBrakePercent"]
    clutchReleaseThreshold := s["clutchReleaseThreshold"]
    throttleThreshold := s["throttleThreshold"]
    restartClutchThreshold := s["restartClutchThreshold"]
    neutralResendMs := s["neutralResendMs"]
    throttleBlipMs := s["throttleBlipMs"]
    noInputStallDelayMs := s["noInputStallDelayMs"]
    brakeResetStallGraceMs := s["brakeResetStallGraceMs"]
    ignitionButton := s["ignitionButton"]
    toggleTransmissionModeButton := s["toggleTransmissionModeButton"]
    toggleSequentialShifterInvertButton := s["toggleSequentialShifterInvertButton"]
    toggleShifterHandbrakeButton := s["toggleShifterHandbrakeButton"]
    activeProfileName := s["activeProfileName"]
    transmissionIsSequential := s["transmissionIsSequential"]
    joystickRoleSlots := s["joystickRoleSlots"]
    gamepadInputDefinitions := s["gamepadInputDefinitions"]
    gamepadActivationSettings := s["gamepadActivationSettings"]
    paddleSyncConfigured := s["paddleSyncConfigured"]
    analogHandbrakeConfigured := s["analogHandbrakeConfigured"]
    shifterHandbrakeConflict := s["shifterHandbrakeConflict"]
    hPatternMappingValid := s["hPatternMappingValid"]
    gearButtons := s["gearButtons"]
    RefreshActiveSequentialBindings()
} ; end commitprofileswitch

; ==========================================================================================================================================================
; CaptureFullProfileSnapshot()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Captures the current profile settings for transactional rollback.
; Provides recovery if hotkey activation or commit fails.
; ==========================================================================================================================================================
CaptureFullProfileSnapshot() {
    global maxForwardGear, requireClutch, clutchActsAsNeutral, clutchThreshold
    global clutchAxis, clutchAxisIncreasesWhenPressed, useCombinedPedals, combinedPedalAxis
    global throttleAxis, brakeAxis, throttleAxisIncreasesWhenPressed, brakeAxisIncreasesWhenPressed
    global brakeActivePercent, gear1Button, gear2Button, gear3Button
    global gear4Button, gear5Button, gear6Button, reverseButton
    global invertSequentialShifter, sequentialUpshiftButton, sequentialDownshiftButton, paddleUpshiftButton
    global paddleDownshiftButton, enableBrakeHoldGearReset, brakeHoldResetMs, brakeResetPercent
    global queuedShiftDelayMs, realManualControlsHandbrake, handbrakeAxis, handbrakeAxisIncreasesWhenPulled
    global handbrakeThreshold, enableShifterHandbrake, shifterHandbrakeButton, enableStalling
    global enableReverseAssist, engageBrakePercent, clutchReleaseThreshold, throttleThreshold
    global restartClutchThreshold, neutralResendMs, throttleBlipMs, noInputStallDelayMs
    global brakeResetStallGraceMs, ignitionButton, toggleTransmissionModeButton
    global toggleSequentialShifterInvertButton, toggleShifterHandbrakeButton, activeProfileName
    global transmissionIsSequential, joystickRoleSlots, gamepadInputDefinitions, gamepadActivationSettings
    global paddleSyncConfigured, analogHandbrakeConfigured, shifterHandbrakeConflict, hPatternMappingValid
    global gearButtons
    snapshot := Map()
    snapshot["maxForwardGear"] := maxForwardGear
    snapshot["requireClutch"] := requireClutch
    snapshot["clutchActsAsNeutral"] := clutchActsAsNeutral
    snapshot["clutchThreshold"] := clutchThreshold
    snapshot["clutchAxis"] := clutchAxis
    snapshot["clutchAxisIncreasesWhenPressed"] := clutchAxisIncreasesWhenPressed
    snapshot["useCombinedPedals"] := useCombinedPedals
    snapshot["combinedPedalAxis"] := combinedPedalAxis
    snapshot["throttleAxis"] := throttleAxis
    snapshot["brakeAxis"] := brakeAxis
    snapshot["throttleAxisIncreasesWhenPressed"] := throttleAxisIncreasesWhenPressed
    snapshot["brakeAxisIncreasesWhenPressed"] := brakeAxisIncreasesWhenPressed
    snapshot["brakeActivePercent"] := brakeActivePercent
    snapshot["gear1Button"] := gear1Button
    snapshot["gear2Button"] := gear2Button
    snapshot["gear3Button"] := gear3Button
    snapshot["gear4Button"] := gear4Button
    snapshot["gear5Button"] := gear5Button
    snapshot["gear6Button"] := gear6Button
    snapshot["reverseButton"] := reverseButton
    snapshot["invertSequentialShifter"] := invertSequentialShifter
    snapshot["sequentialUpshiftButton"] := sequentialUpshiftButton
    snapshot["sequentialDownshiftButton"] := sequentialDownshiftButton
    snapshot["paddleUpshiftButton"] := paddleUpshiftButton
    snapshot["paddleDownshiftButton"] := paddleDownshiftButton
    snapshot["enableBrakeHoldGearReset"] := enableBrakeHoldGearReset
    snapshot["brakeHoldResetMs"] := brakeHoldResetMs
    snapshot["brakeResetPercent"] := brakeResetPercent
    snapshot["queuedShiftDelayMs"] := queuedShiftDelayMs
    snapshot["realManualControlsHandbrake"] := realManualControlsHandbrake
    snapshot["handbrakeAxis"] := handbrakeAxis
    snapshot["handbrakeAxisIncreasesWhenPulled"] := handbrakeAxisIncreasesWhenPulled
    snapshot["handbrakeThreshold"] := handbrakeThreshold
    snapshot["enableShifterHandbrake"] := enableShifterHandbrake
    snapshot["shifterHandbrakeButton"] := shifterHandbrakeButton
    snapshot["enableStalling"] := enableStalling
    snapshot["enableReverseAssist"] := enableReverseAssist
    snapshot["engageBrakePercent"] := engageBrakePercent
    snapshot["clutchReleaseThreshold"] := clutchReleaseThreshold
    snapshot["throttleThreshold"] := throttleThreshold
    snapshot["restartClutchThreshold"] := restartClutchThreshold
    snapshot["neutralResendMs"] := neutralResendMs
    snapshot["throttleBlipMs"] := throttleBlipMs
    snapshot["noInputStallDelayMs"] := noInputStallDelayMs
    snapshot["brakeResetStallGraceMs"] := brakeResetStallGraceMs
    snapshot["ignitionButton"] := ignitionButton
    snapshot["toggleTransmissionModeButton"] := toggleTransmissionModeButton
    snapshot["toggleSequentialShifterInvertButton"] := toggleSequentialShifterInvertButton
    snapshot["toggleShifterHandbrakeButton"] := toggleShifterHandbrakeButton
    snapshot["activeProfileName"] := activeProfileName
    snapshot["transmissionIsSequential"] := transmissionIsSequential
    snapshot["joystickRoleSlots"] := joystickRoleSlots
    snapshot["gamepadInputDefinitions"] := gamepadInputDefinitions
    snapshot["gamepadActivationSettings"] := gamepadActivationSettings
    snapshot["paddleSyncConfigured"] := paddleSyncConfigured
    snapshot["analogHandbrakeConfigured"] := analogHandbrakeConfigured
    snapshot["shifterHandbrakeConflict"] := shifterHandbrakeConflict
    snapshot["hPatternMappingValid"] := hPatternMappingValid
    snapshot["gearButtons"] := gearButtons
    return snapshot
} ; end capturefullprofilesnapshot

; ==========================================================================================================================================================
; GetRigProfileHotkeys(s)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Lists the hotkeys that belong exclusively to the SimRig profile.
; ==========================================================================================================================================================
GetRigProfileHotkeys(s) {
    return [
        {name: s["toggleTransmissionModeButton"], callback: (*) => ToggleTransmissionMode()},
        {name: s["toggleSequentialShifterInvertButton"], callback: (*) => ToggleSequentialShifterInvert()},
        {name: s["toggleShifterHandbrakeButton"], callback: ToggleShifterHandbrake},
        {name: s["ignitionButton"], callback: HandleIgnitionButton}
    ] ; end rig-only list
} ; end getrigprofilehotkeys

; ==========================================================================================================================================================
; PrepareRigHotkeys(s)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Registers the incoming SimRig hotkeys in their disabled state.
; Avoids partial activation if a conflicting hotkey cannot be registered.
; ==========================================================================================================================================================
PrepareRigHotkeys(s) {
    global profileRigHotkeys

    if s["activeProfileName"] != "SimRig" {
        return
    } ; end Gamepad guard

    protected := Map()

    for definition in GetDynamicHotkeyDefinitions() {
        if definition.setting = "ToggleTransmissionModeButton"
            || definition.setting = "ToggleSequentialShifterInvertButton"
            || definition.setting = "ToggleShifterHandbrakeButton"
            || definition.setting = "IgnitionButton" {
            continue
        } ; end rig-only skip

        if definition.hotkey != "" {
            protected[StrLower(definition.hotkey)] := true
        } ; end registered global binding
    } ; end shared hotkey scan

    HotIfWinActive("ahk_exe speed.exe")

    try {
        for hot in GetRigProfileHotkeys(s) {
            if hot.name = "" {
                continue
            } ; end optional binding

            binding := StrLower(hot.name)

            if protected.Has(binding) || GetReservedProtocolConflict(hot.name) != "" {
                throw Error("Rig-only shortcut conflicts with another control: " hot.name)
            } ; end shortcut conflict

            protected[binding] := true

            if !profileRigHotkeys.Has(binding) {
                Hotkey(hot.name, hot.callback, "Off")
                profileRigHotkeys[binding] := hot.name
            } ; end new registration
        } ; end rig-only hotkey list
    } finally {
        HotIfWinActive()
    } ; end hotkey preflight
} ; end preparerighotkeys

; ==========================================================================================================================================================
; SetRigHotkeysEnabled(enabled)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Enables or disables the prepared SimRig-only hotkey bindings.
; Called after the target profile has been selected.
; ==========================================================================================================================================================
SetRigHotkeysEnabled(enabled) {
    global profileRigHotkeys

    HotIfWinActive("ahk_exe speed.exe")

    try {
        for _, keyName in profileRigHotkeys {
            Hotkey(keyName, enabled ? "On" : "Off")
        } ; end hotkey iteration
    } finally {
        HotIfWinActive()
    } ; end protected toggles
} ; end setrighotkeysenabled

; ==========================================================================================================================================================
; GetOutgoingProfileHardwareState()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Confirms whether the currently active profile's primary device still occupies
; its resolved AutoHotkey slot. Used only for a live profile handoff.
;
; Returns:
;   "present"      = the same unique hardware identity still occupies its slot
;   "disconnected" = no responding joystick has the outgoing profile's VID/PID
;   "relocated"    = the outgoing hardware moved to a different joystick slot
;   "unverified"   = manual enumeration, invalid ID, or ambiguous live identity
; ==========================================================================================================================================================
GetOutgoingProfileHardwareState() {
    global activeProfileName, autoEnumerateDevices, joystickRoleSlots

    if !autoEnumerateDevices {
        return "unverified"
    } ; end automatic-mode requirement

    role := activeProfileName = "Gamepad" ? "Gamepad" : "Wheel"
    roleKey := StrLower(role)
    expectedId := StrUpper(Trim(ReadText("JoystickDevices", role "HardwareId")))

    if !RegExMatch(expectedId, "^VID_[0-9A-F]{4}&PID_[0-9A-F]{4}$") {
        return "unverified"
    } ; end identity format guard

    matches := []

    try {
        for device in EnumerateJoystickDevices() {
            if device.hardwareId = expectedId {
                matches.Push(device.slot)
            } ; end identity match
        } ; end connected-device scan
    } catch {
        return "unverified"
    } ; end protected enumeration

    if matches.Length = 0 {
        return "disconnected"
    } ; end absent-controller condition

    if matches.Length != 1 {
        return "unverified"
    } ; end uniqueness requirement

    if !joystickRoleSlots.Has(roleKey) || matches[1] != joystickRoleSlots[roleKey] {
        return "relocated"
    } ; end moved-slot check

    return "present"
} ; end getoutgoingprofilehardwarestate

; ==========================================================================================================================================================
; ToggleControllerProfile(*)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Handles the configured manual profile-switch shortcut.
; Delegates candidate verification and state preservation to TryActivateProfile.
; ==========================================================================================================================================================
ToggleControllerProfile(*) {
    global activeProfileName

    target := activeProfileName = "Gamepad" ? "SimRig" : "Gamepad"

    TryActivateProfile(target)
} ; end togglecontrollerprofile

; ==========================================================================================================================================================
; TryActivateProfile(target, freshGameSession := false, refreshSameProfile := false)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Activate a target profile during switching or game relaunch.
; Validates inputs, guards clutch transactions and rolls back on failure.
; ==========================================================================================================================================================
TryActivateProfile(target, freshGameSession := false, refreshSameProfile := false) {
    global activeProfileName, profileSwitchInProgress, virtualGear, engineStalled
    global clutchNeutralSent, lastClutchPressed, scriptPaused, pendingSequentialShiftCount
    global handbrakeHeld, reverseAssistHeld, requireClutch, clutchActsAsNeutral
    global transmissionIsSequential
    global lastHPatternSelectedGear, nfsInstanceResetPending
    if profileSwitchInProgress || (target = activeProfileName && !refreshSameProfile) {
        return false
    } ; end duplicate request

    gameRunning := !!ProcessExist("speed.exe")

    if !gameRunning {
        MonitorNFSProcess()
    } ; end offline process reconciliation

    if gameRunning && nfsInstanceResetPending && !freshGameSession {
        ShowToolTipMessage("profile switch blocked: wait for game instance synchronization")
        return false
    } ; end process reset guard

    if scriptPaused {
        ShowToolTipMessage("profile switch blocked: resume RealManual before switching")
        return false
    } ; end non-driving mode guard

    if gameRunning && !freshGameSession && (clutchNeutralSent || lastClutchPressed) {
        ShowToolTipMessage("profile switch blocked: release clutch first")
        return false
    } ; end clutch transaction gate

    if gameRunning && !freshGameSession && (requireClutch || clutchActsAsNeutral) {
        outgoingHardwareState := GetOutgoingProfileHardwareState()

        if outgoingHardwareState = "relocated" {
            ShowToolTipMessage("profile switch blocked: old controller moved slots; exit game and reload")
            return false
        } ; end stale-slot guard

        if outgoingHardwareState != "disconnected" {
            if !TryReadProfileClutch(&releasePercent) {
                ShowToolTipMessage("profile switch blocked: clutch unreadable; exit NFSMW to switch safely")
                return false
            } ; end trusted clutch read

            if IsClutchPressed(releasePercent) {
                ShowToolTipMessage("profile switch blocked: release the current clutch")
                return false
            } ; end physical clutch gate
        } ; end disconnect-aware clutch gate
    } ; end clutch feature guard

    if gameRunning && !freshGameSession && pendingSequentialShiftCount != 0 {
        ShowToolTipMessage("profile switch blocked: finish pending clutch-required shifts")
        return false
    } ; end queued shift gate

    profileSwitchInProgress := true
    oldSnapshot := ""
    oldHPatternPosition := lastHPatternSelectedGear
    oldProfile := activeProfileName
    committing := false

    try {
        if refreshSameProfile {
            CaptureProfileMutableOptions()
        } ; end same-profile option capture

        candidate := BuildProfileSwitchCandidate(target) ; validates all target hardware and settings before activation

        if engineStalled && !candidate["enableStalling"] {
            throw Error("target profile must have stalling enabled while the engine is off")
        } ; end engine-off safety policy

        if target = "SimRig" {
            PrepareRigHotkeys(candidate)
        } ; end new hotkeys preflight

        oldSnapshot := CaptureFullProfileSnapshot()
        CaptureProfileMutableOptions()
        Critical "On" ; prevents MainLoop/timers from observing half-applied profile settings
        committing := true
        ReleaseHeldOutputsQuietly()

        if handbrakeHeld || reverseAssistHeld {
            throw Error("unable to release a synthetic game input")
        } ; end output release check

        DisarmEdgeInputs()
        ClearTransmissionInputState()
        ClearStallDetectionState()
        ClearSequentialBrakeResetState()

        pendingSequentialShiftCount := 0

        SetRigHotkeysEnabled(false)
        CommitProfileSwitch(candidate)

        if target = "SimRig" && !transmissionIsSequential {
            lastHPatternSelectedGear := 0
        } ; end rig H-pattern transition history

        if target = "SimRig" {
            SetRigHotkeysEnabled(true)
        } ; end rig-only enabling

        committing := false
        Critical "Off"

        if engineStalled {
            MaintainStalledState()
        } ; end engine-off output

        ShowToolTipMessage("profile switched: " target " | gear " virtualGear " | engine " (engineStalled ? "off" : "on"))

        return true
    } catch as err {
        if committing && IsObject(oldSnapshot) {
            try {
                SetRigHotkeysEnabled(false)
                CommitProfileSwitch(oldSnapshot)

                lastHPatternSelectedGear := oldHPatternPosition

                SetRigHotkeysEnabled(oldProfile = "SimRig")

                if engineStalled {
                    MaintainStalledState()
                } ; end stalled rollback output

            } catch as restoreError {
                scriptPaused := true
                ReleaseHeldOutputsQuietly()
                ShowToolTipMessage("profile rollback failed: RealManual paused; reload safely")
            } ; end rollback recovery
        } ; end partial commit guard

        ShowToolTipMessage("profile switch refused: " err.Message)

        return false
    } finally {
        Critical "Off"
        profileSwitchInProgress := false
    } ; end profile switching transaction
} ; end tryactivateprofile

; ==========================================================================================================================================================
; GetDynamicHotkeyDefinitions()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Returns the complete set of configurable RealManual hotkeys.
;
; Each definition contains:
;   setting  = RealManual.ini key name
;   label    = human-readable name used by validation
;   hotkey   = configured AutoHotkey hotkey string
;   callback = function object executed when the hotkey fires
;
; Registration and validation both use this same definition list so the two
; systems cannot silently drift apart.
; ==========================================================================================================================================================
GetDynamicHotkeyDefinitions() {
    global helpButton, resetButton, pauseButton, reloadButton
    global profileToggleButton, toggleTransmissionModeButton, toggleSequentialShifterInvertButton
    global toggleClutchRequiredButton, toggleClutchNeutralButton, toggleMaxForwardGearButton
    global toggleShifterHandbrakeButton, ignitionButton, toggleStallingButton, stopwatchButton
    global stopwatchLapButton, stopwatchClearButton, statsShiftsButton, statsStallsButton
    global statsRaceRestartsButton, raceRestartButton, saveInstantReplayButton, captureScreenshotButton

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
            setting: "ToggleProfileButton",
            label: "Switch Controller Profile",
            hotkey: profileToggleButton,
            callback: ToggleControllerProfile
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
; Registers normal hotkeys for speed.exe focus and the profile toggle additionally while speed.exe has no window.
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

    ; Registers the profile toggle on the desktop so controllers can be switched before relaunching NFSMW.
    for result in registrationResults {
        if result.setting != "ToggleProfileButton" || result.status != "registered" {
            continue
        } ; end shared toggle validation

        HotIfWinNotExist("ahk_exe speed.exe")

        try {
            Hotkey(result.hotkey, ToggleControllerProfile, "On") ; allows an offline profile handoff on the desktop
        } catch as err {
            result.detail := "offline registration failed: " err.Message
        } finally {
            HotIfWinActive()
        } ; end offline toggle registration

        break
    } ; end profile toggle registration

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
    global activeProfileName

    if activeProfileName = "Gamepad" && !useSequential {
        return
    } ; end profile transmission guard

    global transmissionIsSequential, pendingSequentialShiftCount, sequentialShifterArmed
    global enableShifterHandbrake, shifterHandbrakeArmed, lastHPatternSelectedGear

    if transmissionIsSequential = useSequential {
        return
    } ; end unchanged-mode guard

    transmissionIsSequential := useSequential

    ; Clears mode-specific transient state
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
    global activeProfileName

    if activeProfileName = "Gamepad" {
        return
    } ; end unsupported-mode guard

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
    global requireClutch, pendingSequentialShiftCount

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
    global clutchActsAsNeutral, pendingSequentialShiftCount

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
; 6th gear is invalid in cars with 5 gears, produces neutral. This function keeps 5th gear when 6th is selected in 5 gear mode.
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
    global maxForwardGear, virtualGear, pendingSequentialShiftCount, clutchActsAsNeutral
    global engineStalled, statsLastGear

    previousMaxGear := maxForwardGear
    previousVirtualGear := virtualGear

    maxForwardGear := maxForwardGear = 5 ? 6 : 5

    if maxForwardGear > previousMaxGear {
        ShowLiveModeStatus("Changed: Gearbox Limit")
        return
    } ; end expanded gearbox branch

    ; Clamps Internal Gear State
    virtualGear := Min(virtualGear, maxForwardGear)

    ; A queued sequential shift transaction was created under the previous gearbox limit and may now target a gear that no longer exists.
    pendingSequentialShiftCount := 0

    ; virtualGear is the best-known current game gear in both transmission modes, including temporary H-pattern/paddle disagreement.
    correctionRequired := previousVirtualGear > maxForwardGear

    if correctionRequired {
        ; Gearbox-limit correction is a system state change, not a shift.
        statsLastGear := virtualGear
    }

    ; Synchronizes game gear
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
    global activeProfileName

    if activeProfileName = "Gamepad" {
        return
    } ; end Gamepad guard

    global invertSequentialShifter, lastUpshiftPressed, lastDownshiftPressed, sequentialShifterArmed

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
    global activeProfileName

    if activeProfileName = "Gamepad" {
        return
    } ; end Gamepad guard

    global enableShifterHandbrake, transmissionIsSequential, shifterHandbrakeArmed, sequentialShifterArmed

    if !enableShifterHandbrake {
        if !transmissionIsSequential {
            SetTransmissionMode(true)
        } ; end sequential-mode requirement

        enableShifterHandbrake := true

        ; Prevents an already-selected handbrake slot from activating immediately when the feature is enabled.
        shifterHandbrakeArmed := false

    ; Disables shifter handbrake
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
    global activeProfileName, gamepadInputDefinitions, enableStalling, engineStalled
    global lastStallNeutralSendTime

    if activeProfileName = "Gamepad" && !enableStalling && gamepadInputDefinitions["Ignition"].source = "" {
        ShowToolTipMessage("stalling unavailable: set IgnitionSource")
        return
    } ; end optional ignition availability guard

    enableStalling := !enableStalling ; toggles the shared simulated engine behavior
    ClearStallDetectionState()

    if activeProfileName = "Gamepad" {
        DisarmGamepadDigitalInputs()
    } ; end controller input rearm

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

    scriptPaused := !scriptPaused

    if scriptPaused {

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
; This is so you can set up/down shifts in the game settings for SimRig mode that bypasses RealManual's configurations.
; ==========================================================================================================================================================
HandlePaddleSync() {
    global virtualGear, maxForwardGear, paddleUpshiftButton, paddleDownshiftButton
    global lastPaddleUpshiftPressed, lastPaddleDownshiftPressed, paddleSyncArmed

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
    global virtualGear, maxForwardGear, shiftUpKey, shiftDownKey

    global keyboardShiftSyncArmed, lastKeyboardUpshiftPressed, lastKeyboardDownshiftPressed

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
    global engineStalled, handbrakeKey, handbrakeHeld

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
; HandleReverseAssist(clutchPressed, brakePercent, selectedGear := -2)
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Adds a digital NFSMW reverse-key hold on top of RealManual's normal reverse
; behavior.
;
; Reverse assist uses separate engagement and release conditions:
;
;   assist inactive:
;       brake must exceed EngageBrakePercent before engagement
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
HandleReverseAssist(clutchPressed, brakePercent, selectedGear := -2) {
    global enableReverseAssist, transmissionIsSequential, reverseKey, reverseAssistHeld
    global reverseCommandLatched, brakeHoldResetTriggered, sequentialReverseAssistEligible, virtualGear

    if !enableReverseAssist || clutchPressed {
        ReleaseReverseAssistQuietly()
        return
    } ; end feature / clutch gate

    if reverseAssistHeld {
        brakeConditionMet :=
            IsBrakePedalActive(brakePercent)
    } else {
        brakeConditionMet := IsBrakePressedForReverseAssist(brakePercent)
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
ShouldSuppressStallForBrakeReset(brakePercent) {
    global transmissionIsSequential, enableBrakeHoldGearReset, brakeResetStallGraceActive
    global brakeResetReleaseTime, brakeResetStallGraceMs

    if !brakeResetStallGraceActive {
        return false
    } ; end inactive guard

    if !transmissionIsSequential || !enableBrakeHoldGearReset {
        ClearBrakeResetStallGraceState()
        return false
    } ; end feature-state guard

    if IsBrakePedalActive(brakePercent) {
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
; HandleStallDetection(clutchPressed, clutchValue, brakePercent, throttlePercent, selectedGear := -2)
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
HandleStallDetection(clutchPressed, clutchValue, brakePercent, throttlePercent, selectedGear := -2) {
    global enableStalling, engineStalled, stallDetectionArmed, requireClutch
    global clutchActsAsNeutral, clutchReleaseThreshold, throttleThreshold, noInputStallDelayMs
    global noInputStallStartTime, stallSuppressedUntilShift

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

    if ShouldSuppressStallForBrakeReset(brakePercent) {
        ClearStallDetectionState()
        return
    } ; end sequential brake-reset stall protection

    if !IsFirstGearSelectedForStall(brakePercent, selectedGear) {
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
    global engineStalled, virtualGear, pendingSequentialShiftCount, sequentialShifterArmed
    global lastStallNeutralSendTime, statsLastGear

    if engineStalled {
        return
    } ; end duplicate engine-off guard

    engineStalled := true
    ClearStallDetectionState()
    ReleaseReverseAssistQuietly()

    if playStallJerk {
        TapThrottleBlip() ; brief jerk only when the engine stalls
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
; Manually enters the same engine-off state, but without producing the simulated forward jerk.
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
    global engineStalled, neutralResendMs, lastStallNeutralSendTime

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
;   engine currently stalled/off
;   SimRig: physical H-shifter in neutral
;   Gamepad: tracked logical gear is neutral and throttle is not pressed
;   clutch nearly fully pressed (if RequireClutch = true)
; ==========================================================================================================================================================
TryRestartEngine(*) {
    global enableStalling, engineStalled, requireClutch, activeProfileName
    global virtualGear, pendingSequentialShiftCount, lastStallNeutralSendTime, sequentialShifterArmed
    global statsLastGear, throttleThreshold

    if !enableStalling || !engineStalled {
        return
    } ; end restart-state guard

    if activeProfileName = "Gamepad" {
        if virtualGear != 0 {
            ShowToolTipMessage("restart blocked: transmission not neutral")
            return
        } ; end logical-neutral check

        if !ReadProfilePedalSnapshot(&restartBrakePercent, &restartThrottlePercent) {
            ShowToolTipMessage("restart blocked: pedal input unavailable")
            return
        } ; end valid pedal sample

        if restartThrottlePercent > throttleThreshold {
            ShowToolTipMessage("restart blocked: release throttle")
            return
        } ; end throttle guard
    } else {
        if !IsPhysicalShifterNeutral() {
            ShowToolTipMessage("restart blocked: shifter not neutral")
            return
        } ; end physical-neutral guard
    } ; end profile-neutral selection

    if requireClutch {
        if activeProfileName = "Gamepad" {
            if !TryReadProfileClutch(&restartClutchRelease) {
                ShowToolTipMessage("restart blocked: clutch input unavailable")
                return
            } ; end controller clutch read
        } else {
            restartClutchRelease := ReadClutchAxis()
        } ; end clutch reader selection

        if !IsClutchFullyPressedForRestart(restartClutchRelease) {
            ShowToolTipMessage("restart blocked: press clutch fully")
            return
        } ; end restart clutch requirement
    } ; end optional clutch gate

    if !SendGearToMod(0, true) {
        ShowToolTipMessage("restart failed: cannot send neutral")
        return
    } ; end neutral-output guard

    TapThrottleBlip()
    ClearStallDetectionState()

    engineStalled := false
    virtualGear := 0 ; leaves the restarted transmission in neutral
    statsLastGear := 0
    lastStallNeutralSendTime := 0
    pendingSequentialShiftCount := 0

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()

    sequentialShifterArmed := activeProfileName = "SimRig"

    HandleHandbrake()
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
; HandleGamepadIgnition()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Polls a Gamepad ignition input while NFSMW is focused.
; ==========================================================================================================================================================
HandleGamepadIgnition() {
    global activeProfileName, enableStalling, gamepadDigitalInputState

    if activeProfileName != "Gamepad" || !enableStalling {
        return
    } ; end profile/feature guard

    wasPressed := gamepadDigitalInputState.Get("Ignition", false)
    if !ReadGamepadDigitalAction("Ignition", &isPressed) {
        return
    } ; end input-validity gate

    if isPressed && !wasPressed {
        HandleIgnitionButton() ; shuts down or attempts a restart using the established engine model
    } ; end ignition edge
} ; end handlegamepadignition


; ==========================================================================================================================================================
; SECTION 21: H-PATTERN TRANSMISSION LOGIC
; ==========================================================================================================================================================

; ==========================================================================================================================================================
; HandleHPatternTransmission(clutchPressed, brakePercent, selectedGear)
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
HandleHPatternTransmission(clutchPressed, brakePercent, selectedGear) {
    global requireClutch, clutchActsAsNeutral, lastClutchPressed, clutchNeutralSent
    global virtualGear, maxForwardGear, reverseCommandLatched, lastHPatternSelectedGear
    global lastSentGear, statsLastGear

    if selectedGear = -2 {
        return
    } ; end unknown shifter-state guard

    if selectedGear = -1 {
        lastHPatternSelectedGear := -1

        ; Reverse abandons any incomplete forward-gear clutch transaction.
        ClearClutchTransactionState()

        if IsBrakePedalActive(brakePercent) {
            if !reverseCommandLatched {
                if SendGearToMod(-1, true) {
                    RecordShift(-1)

                    reverseCommandLatched := true
                } ; end successful reverse command
            } ; end reverse command latch
        } else {
            ; After a successful direct reverse command, NFSMW returns to first when the brake is released even while the physical shifter remains in reverse.
            ; Reconciles the tracked game state without counting that automatic return as a driver shift.
            if lastSentGear = -1 {
                virtualGear := 1
                statsLastGear := 1
            }
            reverseCommandLatched := false
        }

        return
    } ; end reverse gear

    reverseCommandLatched := false

    ; Normalizes Forward Gear Limit
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
            ; Records it as a shift only if it differs from the last driver-selected gear known by the statistics subsystem.
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
HandleSequentialBrakeHoldReset(clutchPressed, brakePercent) {
    global transmissionIsSequential, enableBrakeHoldGearReset, brakeHoldResetMs, brakeHoldStartTime
    global brakeHoldResetTriggered, virtualGear, brakeResetStallGraceActive, brakeResetReleaseTime
    global statsLastGear, pendingSequentialShiftCount, sequentialShifterArmed, clutchActsAsNeutral
    global sequentialReverseAssistEligible

    if !transmissionIsSequential || !enableBrakeHoldGearReset {
        ClearSequentialBrakeResetState()
        return
    } ; end feature gate

    if IsBrakePressedForSequentialReset(brakePercent) {
        if brakeHoldStartTime = 0 {
            brakeHoldStartTime := A_TickCount
        } ; end start-time branch

        ; Measure how long the hard-brake condition has been continuously active.
        heldMs := A_TickCount - brakeHoldStartTime

        if heldMs >= brakeHoldResetMs && !brakeHoldResetTriggered {
            ; Sends the gear command before committing the tracked target unless clutch-neutral requires a deferred engagement.
            ; While the clutch is pressed, the existing transmission handler applies the selected first gear on release.
            if !(clutchActsAsNeutral && clutchPressed) {
                if !SendGearToMod(1, true) {
                    ClearSequentialBrakeHoldTimer() ; requires a new uninterrupted brake hold to retry
                    ShowToolTipMessage("sequential gear reset failed: gear output")
                    return
                } ; end authoritative first-gear output check
            } ; end clutch-neutral defer branch

            sequentialReverseAssistEligible := virtualGear != 0
            virtualGear := 1
            statsLastGear := 1
            pendingSequentialShiftCount := 0
            sequentialShifterArmed := false
            brakeHoldResetTriggered := true
            brakeResetStallGraceActive := true
            brakeResetReleaseTime := 0

            ShowToolTipMessage("sequential gear reset to 1 after brake hold")
        }
    } else {
        ; Hard-braking condition is no longer present, so an unfinished hold timer must restart if hard braking begins again.
        brakeHoldStartTime := 0

        if !IsBrakePedalActive(brakePercent) {
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
;   sends the normal game shift immediately
;   commits virtualGear only after successful output
;
; RequireClutch=1, ClutchActsAsNeutral=0:
;   accepts shifts only while clutch is pressed
;   accumulates net movement for clutch release
;
; RequireClutch=0, ClutchActsAsNeutral=1:
;   clutch released -> sends immediate game shift, then commit target
;   clutch pressed  -> updates only the deferred direct-gear target
;
; RequireClutch=1, ClutchActsAsNeutral=1:
;   accepts shifts only while clutch is pressed
;   updates the deferred direct-gear target while the game remains neutral
; ==========================================================================================================================================================
TrySequentialShift(direction, clutchPressed) {
    global requireClutch, clutchActsAsNeutral, virtualGear, maxForwardGear
    global shiftUpKey, shiftDownKey, pendingSequentialShiftCount

    ; Resolves requested direction
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

    ; Clutch-Required passthrough model
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
    global clutchActsAsNeutral, virtualGear, lastUpshiftPressed, lastDownshiftPressed
    global lastClutchPressed, clutchNeutralSent, sequentialShifterArmed, requireClutch
    global pendingSequentialShiftCount, activeSequentialUpshiftButton, activeSequentialDownshiftButton
    global enableShifterHandbrake, shifterHandbrakeConflict, activeProfileName

    ; Clutch -> Neutral
    if clutchActsAsNeutral && clutchPressed && !clutchNeutralSent {
        if SendGearToMod(0, true) {
            clutchNeutralSent := true
        } ; end successful neutral command
    } ; end clutch-neutral branch

    ; Reads sequential shifter inputs
    sequentialInputsReadable := true
    upshiftPressed := false
    downshiftPressed := false

    if enableShifterHandbrake && shifterHandbrakeConflict { ; suppresses the sequential pair when the active handbrake slot owns either shift input
        sequentialShifterArmed := true

    } else { ; reads both sequential directions normally when the handbrake overlaps neither configured shift slot
        if activeProfileName = "Gamepad" {
            upshiftReadable := ReadGamepadDigitalAction("Upshift", &upshiftPressed)
            downshiftReadable := ReadGamepadDigitalAction("Downshift", &downshiftPressed)
        } else {
            upshiftReadable := TryGetInputState(activeSequentialUpshiftButton, &upshiftPressed)
            downshiftReadable := TryGetInputState(activeSequentialDownshiftButton, &downshiftPressed)
        } ; end active-profile sequential input adapter

        if !upshiftReadable || !downshiftReadable {
            sequentialInputsReadable := false
            sequentialShifterArmed := false
            lastUpshiftPressed := false
            lastDownshiftPressed := false
            upshiftPressed := false
            downshiftPressed := false
        } ; end unreadable sequential-input guard
    } ; end sequential-shifter availability branch

    if upshiftPressed && downshiftPressed {
        sequentialShifterArmed := false
    } ; end conflicting shift guard

    ; Sequential shifter re-arm
    if sequentialInputsReadable && !upshiftPressed && !downshiftPressed {
        sequentialShifterArmed := true
        lastUpshiftPressed := false
        lastDownshiftPressed := false
    } ; end neutral-arm branch

    ; Shifter arming gate
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

    ; Sequential shift edges
    if upshiftPressed && !lastUpshiftPressed { ; accepts only the rising edge of the physical upshift input
        TrySequentialShift("up", clutchPressed)
    } ; end upshift branch

    if downshiftPressed && !lastDownshiftPressed {
        TrySequentialShift("down", clutchPressed)
    } ; end downshift branch

    ; Clutch release
    if lastClutchPressed && !clutchPressed {
        if clutchActsAsNeutral {
            SendGearToMod(virtualGear, true) ; forces the tracked virtual gear back into MW2005-HShifter

        } else if requireClutch && pendingSequentialShiftCount != 0 {
            SendQueuedSequentialShifts(pendingSequentialShiftCount)
            pendingSequentialShiftCount := 0
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
    global virtualGear, maxForwardGear, pendingSequentialShiftCount, sequentialShifterArmed
    global engineStalled, statsLastGear

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
    global virtualGear, pendingSequentialShiftCount, sequentialShifterArmed, shifterHandbrakeArmed
    global engineStalled, lastStallNeutralSendTime, lastHPatternSelectedGear, lastSentGear
    global handbrakeHeld, statsLastGear, stallSuppressedUntilShift, reverseAssistHeld

    ; Clears gear/shift transactions
    virtualGear := 1
    statsLastGear := 1

    pendingSequentialShiftCount := 0
    lastHPatternSelectedGear := -2

    ClearTransmissionInputState()
    ClearSequentialBrakeResetState()

    ; Requires a return to neutral before an already-selected sequential or shifter-handbrake slot can be interpreted as a fresh input
    sequentialShifterArmed := false
    shifterHandbrakeArmed := false

    ; Clears Engine-Off/Stall state
    engineStalled := false
    lastStallNeutralSendTime := 0

    ClearStallDetectionState()

    stallSuppressedUntilShift := !syncGame

    ; Synchronizes game/output state
    if syncGame {
        ReleaseReverseAssistQuietly()

        ; Force bypasses the lastSentGear cache because ResetInputs() is deliberately establishing first gear as the authoritative state
        SendGearToMod(1, true)

        ; Re-evaluates all valid handbrake sources
        ; A physically pulled analog handbrake should remain active
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
; RefreshProfileForNewGame()
; ----------------------------------------------------------------------------------------------------------------------------------------------------------
; Selects the uniquely connected primary controller for each new speed.exe PID.
; Both connected = configured startup preference. Manual enumeration = unchanged.
; Also rebuilds active bindings if the same controller moved joystick slots.
; ==========================================================================================================================================================
RefreshProfileForNewGame() {
    global autoEnumerateDevices, preferredStartupProfileName, activeProfileName, joystickRoleSlots
    global profileSwitchInProgress, scriptPaused

    if !autoEnumerateDevices || profileSwitchInProgress || scriptPaused {
        return
    } ; end refresh eligibility

    try {
        roles := ResolveConfiguredJoystickRoles(&warnings) ; reads responding controllers at their CURRENT numbered slots
        for _, warning in warnings {
            if RegExMatch(warning, "i)^(?:Gamepad|Wheel)HardwareId .* is invalid") {
                ShowToolTipMessage("auto profile refresh refused: invalid primary hardware ID")
                return
            } ; end invalid identity

            if RegExMatch(warning, "i)^(?:Gamepad|Wheel)HardwareId .* matched ([0-9]+) connected devices", &matches) && matches[1] > 1 {
                ShowToolTipMessage("auto profile refresh refused: ambiguous primary hardware ID")
                return
            } ; end duplicate match
        } ; end identity validation

        hasGamepad := roles.Has("gamepad")
        hasWheel := roles.Has("wheel")

        if !hasGamepad && !hasWheel {
            ShowToolTipMessage("auto profile refresh skipped: no primary controller detected")
            return
        } ; end absent drivers

        target := hasGamepad && hasWheel ? preferredStartupProfileName : (hasGamepad ? "Gamepad" : "SimRig")
        role := target = "Gamepad" ? "gamepad" : "wheel"
        needsRebind := target = activeProfileName && (!joystickRoleSlots.Has(role) || joystickRoleSlots[role] != roles[role])

        if target = "SimRig" && target = activeProfileName {
            previousHandbrake := joystickRoleSlots.Has("handbrake") ? joystickRoleSlots["handbrake"] : 0
            currentHandbrake := roles.Has("handbrake") ? roles["handbrake"] : 0
            needsRebind := needsRebind || previousHandbrake != currentHandbrake
        } ; end handbrake movement check

        if target != activeProfileName || needsRebind {
            if !TryActivateProfile(target, true, needsRebind) {
                ShowToolTipMessage("auto profile refresh failed; verify target controller and bindings")
            } ; end safe transaction result
        } ; end desired profile differs
    } catch as err {
        ShowToolTipMessage("auto profile refresh error: " err.Message)
    } ; end protected re-enumeration
} ; end refreshprofilefornewgame


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
; If the game is not running yet, RealManual waits for the first instance to appear.
; ==========================================================================================================================================================
InitializeNFSProcessTracking() {
    global nfsProcessPid, nfsProcessSeen

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
; Exit cleanup resets internal inputs immediately without sending a gear command.
; A newly observed process also receives a silent focused first-gear synchronization.
; ==========================================================================================================================================================
MonitorNFSProcess() {
    global nfsProcessPid, nfsProcessSeen, nfsInstanceResetPending

    currentPid := ProcessExist("speed.exe")

    ; No game process running
    if !currentPid {
        if nfsProcessPid != 0 { ; a previously running game has now closed or crashed
            SynchronizeStatsSession(0)
            ReleaseHeldOutputsQuietly()
            ResetInputs(false, false)
            nfsInstanceResetPending := false
        } ; end ended-process cleanup

        nfsProcessPid := 0 ; no speed.exe is currently running
        return
    } ; end no-process branch

    ; First game instance
    if !nfsProcessSeen { ; RealManual started before NFSMW and has now observed its first process
        SynchronizeStatsSession(currentPid)
        nfsProcessPid := currentPid
        nfsProcessSeen := true
        nfsInstanceResetPending := true
        ResetInputs(false, false)
        RefreshProfileForNewGame()
        return
    } ; end first-instance branch

    ; Game returned after previous instance disappeared
    if nfsProcessPid = 0 {
        SynchronizeStatsSession(currentPid)
        nfsProcessPid := currentPid
        nfsInstanceResetPending := true
        ResetInputs(false, false)
        RefreshProfileForNewGame()
        return
    } ; end replacement-after-exit branch

    ; PID changed without observing an empty interval
    if currentPid != nfsProcessPid { ; a new process replaced the old one between monitor samples
        SynchronizeStatsSession(currentPid)
        ReleaseHeldOutputsQuietly()
        ResetInputs(false, false)
        nfsProcessPid := currentPid
        nfsInstanceResetPending := true
        RefreshProfileForNewGame()
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
;   paused                   = MainLoop stopped
;   NFSMW focused            = normal fast scan interval
;   NFSMW unfocused          = slower idle polling interval
; ==========================================================================================================================================================
UpdateMainLoopSchedule() {
    global scriptPaused, scanIntervalMs, mainLoopIdleIntervalMs

    if scriptPaused {
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
;   RealManual paused:
;       timer is stopped
;
; Order of operations:
;   1. guards paused/profile-switching states
;   2. handles focus transitions and releases held outputs
;   3. synchronizes new NFSMW processes
;   4. maintains simulated engine-off state
;   5. handles paddle/keyboard sync and handbrake routing
;   6. samples the H-pattern position when applicable
;   7. samples pedals only when required
;   8. processes the active transmission mode
;   9. processes reverse assist and simulated stalling
;
; H-pattern transmission handling evaluates reverse before neutral/forward processing so the physical reverse slot cannot fall through as another state.
; ==========================================================================================================================================================
MainLoop() {
    global profileSwitchInProgress, scriptPaused, lastNFSFocused, nfsInstanceResetPending
    global activeProfileName, transmissionIsSequential
    global requireClutch, clutchActsAsNeutral, enableStalling, stallSuppressedUntilShift
    global enableReverseAssist, reverseAssistHeld, enableBrakeHoldGearReset, brakeResetStallGraceActive
    global paddleSyncConfigured, keyboardShiftSyncConfigured
    global analogHandbrakeConfigured, enableShifterHandbrake, handbrakeHeld
    global lastSentGear, scanIntervalMs, mainLoopIdleIntervalMs

    if profileSwitchInProgress {
        return
    } ; end switching gate

    if scriptPaused {
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

    if activeProfileName = "Gamepad" && enableStalling {
        HandleGamepadIgnition()
    } ; end focused Gamepad ignition polling

    if MaintainStalledState() {
        return
    } ; end engine-off gate

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
        if !TryReadProfileClutch(&clutchValue) {
            DisarmEdgeInputs()
            ClearStallDetectionState()
            return
        } ; end invalid-clutch gate
        clutchPressed := IsClutchPressed(clutchValue)
    } else {
        clutchValue := 100
        clutchPressed := false
    } ; end clutch snapshot

    stallLogicActive := enableStalling && (requireClutch || clutchActsAsNeutral)

    stallNeedsPedalSample :=
        stallLogicActive
        && !stallSuppressedUntilShift
        && (
            brakeResetStallGraceActive
            || lastSentGear = -1
            || !clutchPressed
        ) ; retain the existing stall-input scheduling conditions

    needsPedalSample :=
        (!transmissionIsSequential && selectedGear = -1)
        || (transmissionIsSequential && enableBrakeHoldGearReset)
        || (enableReverseAssist && !clutchPressed)
        || stallNeedsPedalSample ; select only modes that use brake or throttle telemetry

    brakePercent := 0
    throttlePercent := 0

    if needsPedalSample {
        if !ReadProfilePedalSnapshot(&brakePercent, &throttlePercent) {
            ClearSequentialBrakeHoldTimer()
            ClearStallDetectionState()
            ReleaseReverseAssistQuietly()
            return
        } ; end unavailable pedal guard
    } ; end pedal snapshot

    if transmissionIsSequential {
        if enableBrakeHoldGearReset {
            HandleSequentialBrakeHoldReset(clutchPressed, brakePercent)
        } ; end sequential brake-reset routing

        HandleSequentialTransmission(clutchPressed)

        if enableReverseAssist || reverseAssistHeld {
            HandleReverseAssist(clutchPressed, brakePercent)
        } ; end reverse-assist routing

        if stallLogicActive {
            HandleStallDetection(clutchPressed, clutchValue, brakePercent, throttlePercent)
        } ; end stall-detection routing
    } else {
        HandleHPatternTransmission(clutchPressed, brakePercent, selectedGear)

        if enableReverseAssist || reverseAssistHeld {
            HandleReverseAssist(clutchPressed, brakePercent, selectedGear)
        } ; end reverse-assist routing

        if stallLogicActive {
            HandleStallDetection(clutchPressed, clutchValue, brakePercent, throttlePercent, selectedGear)
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
if activeProfileName = "SimRig" {
    for result in dynamicHotkeyRegistrationResults {
        if result.status != "registered" {
            continue
        } ; end registration status

        if result.setting = "ToggleTransmissionModeButton"
            || result.setting = "ToggleSequentialShifterInvertButton"
            || result.setting = "ToggleShifterHandbrakeButton"
            || result.setting = "IgnitionButton" {
            profileRigHotkeys[StrLower(result.hotkey)] := result.hotkey
        } ; end rig registration selection
    } ; end result scan
} ; end active SimRig hotkey ledger
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
