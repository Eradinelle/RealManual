# Changelog

# 

All notable changes to RealManual are documented in this file.

## [1.2.0] - 2026-09-25

### Highlights

- Added persistent session/all-time statistics for shifts, stalls, and race restarts, with session lifetime tied to the active `speed.exe` process.
- Added Reverse Assist, keyboard-shift synchronization, NVIDIA Instant Replay/screenshot hotkeys, and cancellable maximum-video-settings menu automation.
- Added NFSMW process-lifecycle tracking and safe synchronization when the game exits, restarts, crashes, or is replaced.
- Reworked H-pattern and sequential input handling around fail-closed reads, explicit re-arming, centralized state clearing, and shared per-scan input snapshots.
- Added fixed MW2005-HShifter protocol protection for `0`, `N`, and `1`-`6` across configurable hotkeys, mappings, axes, and game-output bindings.
- Reorganized `config.ini` into subsystem-oriented sections and aligned public setting names with runtime terminology.
- Added adaptive MainLoop scheduling: the default 5 ms focused poll remains responsive, unfocused polling slows to 100 ms, and the polling timer stops completely while RealManual is paused or menu automation is active.
- Expanded startup validation from basic presence/range checks into a centralized configuration, relationship, hotkey, reserved-key, and hardware-validation report.
- Added centralized output cleanup on script exit/reload to reduce the risk of logically held synthetic keys.

### Added

#### Configuration and validation infrastructure

- Added `ConfigRuleKey()` to provide a shared `Section|Key` identity for numeric/boolean rule maps and validation.
- Added `TryParseConfigInt()` for strict non-negative integer parsing.
- Added `TryParseConfigBool()` for strict `0` / `1` boolean parsing.
- Added centralized `numericConfigRules` and `booleanConfigRules`.
- Added `AddValidationWarning()` so detailed validation and the condensed warning summary use one reporting path.
- Added relationship validation for:
  - combined-pedal center vs normal brake vs hard-brake thresholds;
  - reverse-assist brake threshold placement;
  - clutch press / restart / clutch-release threshold ordering;
  - duplicate H-pattern, sequential, and paddle mappings.
- Added reporting for duplicate configurable hotkeys, malformed hotkeys, reserved MW2005-HShifter protocol conflicts, and unavailable hardware.
- Added the top-of-file script lookup covering all major sections and functions.

#### Binding and protocol safety

- Added `GetReservedProtocolConflict()` to protect MW2005-HShifter's fixed keyboard protocol:
  - `0` = reverse;
  - `N` = neutral;
  - `1`-`6` = forward gears.
- Added `SanitizeUserConfiguredKey()` and `SanitizeUserConfiguredBindings()` to disable unsafe runtime bindings before they reach input/output logic.
- Added support for detecting reserved-key conflicts through normal names, modifier-prefixed hotkeys, custom AHK combinations, and equivalent virtual-key representations.
- Added startup construction of a validated H-pattern gear map plus `hPatternMappingValid`.
- Added precomputed configuration flags for paddle synchronization, keyboard-shift synchronization, analog handbrake availability, and shifter-handbrake/sequential overlap.
- Added `RefreshActiveSequentialBindings()` so sequential inversion resolves the active up/down pair only at startup or when inversion changes.

#### Input/output safety

- Added `SendKeyForDuration()` as the common timed-key-output primitive.
- Added `TrySetOutputKeyState()` for protected held-key press/release operations.
- Added `TryGetInputState()` to distinguish a valid released/zero input from an unreadable input.
- Added `TryGetPhysicalKeyState()` to observe physical keyboard state without reacting to RealManual's own synthetic `SendEvent` output.
- Added `ReadClutchAxis()` and `ReadCombinedPedalAxis()` for explicit per-scan axis snapshots.
- Added `ReleaseReverseAssistQuietly()`.
- Added `HandleScriptExit()` and registered it with `OnExit()` so game outputs are released on exit/reload.
- Added `ClearStatusToolTip()` to prevent an older tooltip-clear timer from removing a newer status message.

#### Statistics

- Added persistent `stats.txt` storage.
- Added session counters for:
  - shifts;
  - stalls;
  - race restarts.
- Added AllTime counters for the same categories.
- Added `ReadStatCount()` and `SaveStatCount()`.
- Added `InitializeStats()`.
- Added `StartStatsSession()`, `FinalizeStatsSession()`, and `SynchronizeStatsSession()`.
- Added `ApplyStatisticsStartupOptions()` and retained only the distinct `ClearAllTimeOnStartup` maintenance option.
- Added `RecordShift()`, `RecordStall()`, and `RecordRaceRestart()`.
- Added `IsStatsDisplayActive()`, `UpdateStatsDisplay()`, and `ToggleStatsDisplay()`.
- Added `GetOverlayX()` to coordinate stopwatch/statistics panel placement.
- Session identity now follows one NFSMW `speed.exe` PID:
  - reloading RealManual during the same game process resumes the session;
  - closing/replacing `speed.exe` finalizes the session into AllTime;
  - the next `speed.exe` starts a fresh session.
- Session counters are persisted as they change for reload/crash recovery, while AllTime is updated when the NFSMW process session is finalized.
- Added `StatsShiftsButton`, `StatsStallsButton`, `StatsRaceRestartsButton`, and `RaceRestartButton`.

#### NFSMW process lifecycle and scheduling

- Added `InitializeNFSProcessTracking()`.
- Added `MonitorNFSProcess()` with detection for:
  - first observed NFSMW process;
  - process disappearance;
  - game return after an observed exit;
  - direct PID replacement between monitor scans.
- Added `SetMainLoopTimerInterval()` to avoid repeatedly resetting an unchanged timer interval.
- Added `UpdateMainLoopSchedule()` for focused, unfocused, paused, and menu-automation states.
- Added deferred internal reset for replacement NFSMW processes so no direct H-shifter command is sent during game startup before focus is established.
- Added new-game stall suppression until RealManual accepts a legitimate driver shift.

#### Reverse Assist

- Added `[ReverseAssist]` configuration.
- Added `IsBrakePressedForReverseAssist()`.
- Added `HandleReverseAssist()`.
- Added separate reverse-assist engagement thresholding.
- Added tracked held-output state and safe release behavior.
- Sequential reverse assist now cooperates with the brake-hold first-gear reset eligibility state.
- H-pattern reverse-assist behavior uses the currently known physical shifter state.
- Engaged clutch disables assist (used to solve the problem of weak reversing on a stiff brake pedal. This function sends the brake/reverse key while reversing, giving full power)

#### Keyboard and paddle synchronization

- Added `HandleKeyboardShiftSync()` to mirror physically pressed native NFSMW shift keys into `virtualGear` without detecting RealManual's own generated shift outputs.
- Paddle synchronization now works in both H-pattern and sequential RealManual modes when configured.
- Paddle/keyboard synchronization now fails closed on unreadable inputs and requires a proven released state before re-arming.
- Paddle and keyboard native shifts participate in shift statistics only after the tracked gear actually changes.

#### Menu and capture utilities

- Added `TapMenuKey()`.
- Added `AddMenuSequenceSteps()`.
- Added `BuildMaxVideoSettingsSequence()`.
- Added `ProcessMaxVideoSettingsStep()`.
- Added `StopMaxVideoSettingsSequence()`.
- Added `ApplyMaxVideoSettings()`.
- Maximum-video-settings automation is timer-driven, cancellable between inputs, focus-guarded, and temporarily suspends MainLoop input handling.
- Made this to solve a very specific and probably unique problem. My video settings do not save. Automated maxing them. ONLY WORKS FROM MAIN MENU, HOVERING OVER "CAREER MODE" AND IF YOUR SETTINGS ARE NOT ALREADY MAXED IN BOTH "BASIC" AND "ADVANCED"
- Added `SaveNvidiaInstantReplay()` for NVIDIA Overlay `Alt+F10`.
- Added `CaptureNvidiaScreenshot()` for NVIDIA Overlay `Alt+F1`.
- Added configurable hotkeys `MaxVideoSettingsButton`, `SaveInstantReplayButton`, and `CaptureScreenshotButton`.
- So that you can bind captures to the steering wheel

#### State-reset helpers

- Added `ClearEdgeInputState()`.
- Added `ClearClutchTransactionState()`.
- Added `ClearTransmissionInputState()`.
- Added `DisarmEdgeInputs()`.
- Added `ClearStallDetectionState()`.
- Added `ClearSequentialBrakeHoldTimer()`.
- Existing brake-reset/stall clear logic is now composed from these helpers instead of duplicating state mutation across mode changes, resets, focus changes, stalls, and recovery paths.

#### Dynamic hotkey architecture

- Added `GetDynamicHotkeyDefinitions()`.
- Added `TryRegisterHotkey()`.
- Hotkey registration is now data-driven rather than a long sequence of individual `Hotkey()` calls.
- Registration results are retained for startup validation.
- Duplicate, reserved, and malformed hotkeys are rejected without aborting unrelated registrations.
- The AHK `HotIf` context is restored in a `finally` block after registration.

### Changed

#### Configuration schema

The configuration layout was reorganized around functional subsystems. The v1.2.0 script reads these sections:

- `[General]`
- `[Hotkeys]`
- `[Transmission]`
- `[Clutch]`
- `[Pedals]`
- `[GameKeys]`
- `[HPattern]`
- `[Sequential]`
- `[Handbrake]`
- `[Stalling]`
- `[ReverseAssist]`
- `[Timing]`
- `[Stopwatch]`
- `[Statistics]`

`NeutralKey` is no longer a normal user-configurable output binding; neutral belongs to the fixed MW2005-HShifter protocol. `ReverseKey` is now a normal NFSMW game-key binding used by Reverse Assist.

#### Config parsing

- `ReadBool()` now uses strict centralized `0`/`1` parsing.
- `ReadInt()` now requires a registered numeric rule and enforces that setting's configured minimum/maximum range.
- `ReadText()` remains the lightweight text-reader path.
- Ad-hoc `ReadRequiredText()`, `IsValidPercent()`, and `IsConfigured()` validation paths were removed in favor of the centralized configuration/validation system.

#### H-pattern transmission

- `ReadSelectedGear()` now evaluates the complete H-pattern state and fails closed:
  - returns unknown when the map is incomplete/invalid;
  - returns unknown when any required position is unreadable;
  - returns unknown when multiple positions appear active;
  - returns neutral only after all seven physical positions are successfully observed inactive.
- `HandleHPatternTransmission()` now receives a single physical shifter snapshot plus shared clutch/pedal snapshots from MainLoop.
- Added `lastHPatternSelectedGear` so stationary H-pattern positions do not repeatedly override legitimate native paddle changes.
- Direct gear state is committed only after the corresponding output succeeds.
- Clutch release makes the current physical H-pattern position authoritative.
- Reverse handling and reverse-exit recovery were rewritten to avoid stale clutch/gear transactions.
- H-pattern shifts now feed the statistics subsystem only for accepted driver gear changes.

#### Sequential transmission

- Sequential active bindings are cached by `RefreshActiveSequentialBindings()` rather than recomputed by getter functions every scan.
- Sequential input reads fail closed; an unreadable up/down input disarms the shifter until a valid neutral/released state is observed.
- Shifter-handbrake conflict handling is explicit and cached.
- `TrySequentialShift()` now:
  - receives the already-known clutch state;
  - validates direction and gear bounds;
  - returns success/failure;
  - changes authoritative tracked state only after successful immediate output;
  - calculates queued deltas from actual target movement;
  - records accepted shifts.
- Added `SendQueuedSequentialShifts()` to centralize release-time emission of queued sequential requests.
- `HandleSequentialTransmission()` now cleanly supports:
  - no-clutch immediate passthrough;
  - clutch-required queued passthrough;
  - clutch-to-neutral virtual-gear operation;
  - combinations where clutch requirement and clutch-neutral are independently enabled/disabled.
- Clutch-neutral gear restoration uses forced direct synchronization because native paddle/keyboard inputs may have changed the game's actual gear.
- Sequential re-arming and edge history are explicitly reset after mode changes, mapping inversion, unreadable input, and shifter-handbrake ownership changes.

#### Sequential brake reset

- `HandleSequentialBrakeHoldReset()` now consumes shared clutch/pedal snapshots.
- Brake-reset first-gear synchronization now updates tracked gear/statistics baselines without creating a false driver-shift statistic.
- Added reverse-assist eligibility state for a brake-reset sequence that began outside neutral.
- Added post-reset stall-grace coordination.
- Queued sequential shifts are cleared when the reset establishes first gear.
- The sequential lever is disarmed after a forced reset until a safe neutral return is observed.
- Clutch-to-neutral state is preserved rather than forcing a forward gear while the clutch intentionally holds neutral.

#### Clutch handling

- `IsClutchPressed()` and `ReadClutchReleasePercent()` now operate on a previously sampled clutch value instead of re-reading hardware internally.
- Clutch-required and clutch-neutral live toggles now clear queued/clutch/stall transient state so an old transaction cannot survive a mode change.
- Clutch-to-neutral and clutch-required behavior are no longer coupled to unnecessary hardware reads when both features are disabled.

#### Pedal / brake handling

- Added shared `ReadCombinedPedalAxis()` snapshotting.
- `IsBrakeAxisPastThreshold()`, `IsBrakePedalActive()`, `IsBrakePressedForSequentialReset()`, `ReadThrottlePercentForStall()`, and brake-reset stall suppression now consume the shared per-scan pedal value rather than performing independent reads.
- Combined-pedal direction and center are centralized under `[Pedals]`.

#### Handbrake

- Simplified the shifter-handbrake model to one configured `ShifterHandbrakeButton`.
- Removed independent shifter-handbrake inversion.
- Analog handbrake and shifter-slot handbrake can coexist.
- Shifter handbrake remains sequential-only.
- Enabling it from H-pattern mode performs a synchronized transition to sequential mode.
- Disabling it forces the sequential lever to return to neutral before shifting resumes when the lever may still occupy the former handbrake slot.
- Unreadable shifter-handbrake input fails closed and must be observed released before re-arming.
- Held handbrake output now uses protected press/release logic.

#### Stall / engine simulation

- Stall detection now uses shared clutch/pedal/gear snapshots from MainLoop.
- Added centralized `ClearStallDetectionState()`.
- Added new-game stall suppression until the user performs an accepted shift.
- H-pattern unknown/reverse state is explicitly excluded from first-gear stall detection.
- Brake-reset stall protection uses the shared pedal snapshot.
- `StallEngine()` now records stall statistics.
- `EnterEngineOffState()` centralizes more state cleanup and releases Reverse Assist.
- `TryRestartEngine()` uses the explicit clutch snapshot helper and centralized state clears.
- Removed obsolete pending-gear state from engine-off/restart logic.
- Stall keepalive naming/configuration was aligned around `NeutralResendMs`.

#### Reverse and synchronization

- Fixed protocol hotkeys now include:
  - `$0::SyncGear(-1)` for reverse;
  - `$n::SyncGear(0)` for neutral;
  - `$1`-`$6` for forward gears.
- `SyncGear()` now supports the complete direct-gear protocol range `-1`, `0`, and `1`-`6`.
- Manual sync clears stale transmission transactions and disarms the sequential lever before accepting new movement.
- `ResetInputs()` now accepts `syncGame` and `showStatus` arguments.
- A new NFSMW process can receive an internal-only reset (`syncGame := false`) without sending a direct protocol command during game load.
- Manual reset still performs authoritative first-gear synchronization and output reevaluation.

#### Output helpers

- `TapKey()` now delegates to `SendKeyForDuration()`.
- `TapThrottleBlip()` also delegates to the same timed-output helper.
- `SendGearToMod()` now returns a success status, validates targets, suppresses unnecessary duplicate commands, supports forced synchronization, and updates `lastSentGear` only after successful output.
- `ReleaseHeldOutputsQuietly()` now uses protected state changes and releases Reverse Assist as well as handbrake output.

#### Notifications and startup logging

- `ShowToolTipMessage()` now uses a dedicated status tooltip ID and cancels an older pending clear timer before showing a new status.
- `ShowLiveModeStatus()` reflects the renamed controls and newly added statistics controls.
- `ShowStartupInfo()` relies on the expanded validation system rather than duplicating ad-hoc configuration tests.
- `DetectInputHardware()` uses a read-success API instead of treating fallback values as successful reads.
- `WriteStartupLogFile()` is protected against file I/O failure and returns success/failure.
- `OpenValidationLog()` now handles a missing or unopenable log gracefully.

#### Stopwatch / overlays

- Stopwatch behavior remains compatible but now shares screen layout with the statistics panel.
- `UpdateStopwatchDisplay()` dynamically uses the shared overlay position.
- `ToggleStopwatch()` records activation order so the first-visible panel stays in the primary position.
- `ClearStopwatch()` releases its overlay order and immediately repositions statistics if required.
- Stopwatch refresh stops while paused and resumes only when necessary.

#### MainLoop

- Added explicit focus-transition handling.
- Added adaptive timer scheduling.
- Added new-process synchronization.
- Added feature-aware routing.
- Added one H-pattern state snapshot per applicable scan.
- Added clutch sampling only when clutch-dependent features require it.
- Added combined-pedal sampling only when reverse, sequential brake reset, Reverse Assist, or stall logic requires it.
- Reuses shared input snapshots across the transmission, reverse-assist, and stall subsystems.
- Stops handling input while RealManual is paused or menu automation owns the game.
- Keeps native paddle and keyboard synchronization independent from RealManual's direct shifter mode.
- Releases held outputs and disarms edge-sensitive inputs on focus loss.

With the default timing values, unfocused MainLoop scheduling changes from approximately `200 callbacks/s` at 5 ms to approximately `10 callbacks/s` at 100 ms. Paused/menu-automation states stop MainLoop polling entirely.

### Function-level changes

#### New functions in 1.2.0

**Configuration / validation**
- `ConfigRuleKey()` — canonical configuration rule identity.
- `TryParseConfigInt()` — strict integer parser.
- `TryParseConfigBool()` — strict boolean parser.
- `AddValidationWarning()` — shared validation-warning reporter.

**Binding / protocol safety**
- `GetReservedProtocolConflict()` — detects MW2005-HShifter protocol conflicts.
- `SanitizeUserConfiguredKey()` — sanitizes one configured runtime binding.
- `SanitizeUserConfiguredBindings()` — sanitizes all non-hotkey runtime bindings.
- `RefreshActiveSequentialBindings()` — caches inversion-aware sequential bindings.

**Output / cleanup**
- `SendKeyForDuration()` — common timed key press/release helper.
- `TrySetOutputKeyState()` — protected held-output state helper.
- `ReleaseReverseAssistQuietly()` — safe reverse-assist release.
- `HandleScriptExit()` — best-effort output cleanup on exit/reload.
- `SaveNvidiaInstantReplay()` — NVIDIA Instant Replay shortcut output.
- `CaptureNvidiaScreenshot()` — NVIDIA screenshot shortcut output.

**Input**
- `TryGetInputState()` — input read with explicit success/failure.
- `TryGetPhysicalKeyState()` — physical-only keyboard input read.
- `ReadClutchAxis()` — clutch snapshot helper.
- `ReadCombinedPedalAxis()` — shared pedal snapshot helper.
- `IsBrakePressedForReverseAssist()` — reverse-assist brake threshold helper.

**Statistics / overlay**
- `ReadStatCount()`
- `SaveStatCount()`
- `InitializeStats()`
- `ApplyStatisticsStartupOptions()`
- `StartStatsSession()`
- `FinalizeStatsSession()`
- `SynchronizeStatsSession()`
- `RecordShift()`
- `RecordStall()`
- `RecordRaceRestart()`
- `IsStatsDisplayActive()`
- `GetOverlayX()`
- `UpdateStatsDisplay()`
- `ToggleStatsDisplay()`

**Transient-state management**
- `ClearEdgeInputState()`
- `ClearClutchTransactionState()`
- `ClearTransmissionInputState()`
- `DisarmEdgeInputs()`
- `ClearStallDetectionState()`
- `ClearSequentialBrakeHoldTimer()`

**Hotkey architecture / mode control**
- `GetDynamicHotkeyDefinitions()`
- `TryRegisterHotkey()`
- `SetTransmissionMode()`
- `ToggleMaxForwardGear()` — replacement for `ToggleFiveGearMode()`.
- `ToggleSequentialShifterInvert()` — replacement for `ToggleSequentialInvert()`.

**Menu automation**
- `TapMenuKey()`
- `AddMenuSequenceSteps()`
- `BuildMaxVideoSettingsSequence()`
- `StopMaxVideoSettingsSequence()`
- `ProcessMaxVideoSettingsStep()`
- `ApplyMaxVideoSettings()`

**Auxiliary input / transmission**
- `HandleKeyboardShiftSync()`
- `HandleReverseAssist()`
- `SendQueuedSequentialShifts()`

**Process / scheduler**
- `InitializeNFSProcessTracking()`
- `MonitorNFSProcess()`
- `SetMainLoopTimerInterval()`
- `UpdateMainLoopSchedule()`

#### Existing functions with material changes

**Configuration / validation**
- `ReadBool()` — now uses strict centralized boolean parsing.
- `ReadInt()` — now enforces registered per-setting ranges.
- `BuildValidationText()` — expanded into configuration, relationship, hotkey, reserved-binding, and hardware validation.
- `DetectInputHardware()` — now distinguishes read failure from a valid released/zero value.
- `ShowStartupInfo()` — simplified around authoritative centralized validation.
- `WriteStartupLogFile()` — protected file replacement/write with success result.
- `OpenValidationLog()` — missing/open-failure handling added.
- `ShowLiveModeStatus()` — renamed controls, removed shifter-handbrake inversion, added statistics information.
- `ShowToolTipMessage()` — dedicated tooltip ID and stale-clear-timer cancellation.

**Output / input helpers**
- `TapKey()` — delegates to `SendKeyForDuration()`.
- `TapThrottleBlip()` — delegates to `SendKeyForDuration()`.
- `SendGearToMod()` — target validation, return status, duplicate suppression, forced sync, success-only cache updates.
- `ReleaseHeldOutputsQuietly()` — protected release plus Reverse Assist cleanup.
- `SafeGetKeyState()` — now wraps `TryGetInputState()`.
- `IsClutchPressed()` — consumes a pre-read clutch value.
- `ReadClutchReleasePercent()` — consumes a pre-read clutch value.
- `ReadThrottlePercentForStall()` — consumes a pre-read pedal value.
- `IsBrakeAxisPastThreshold()` — consumes a pre-read pedal value.
- `IsBrakePedalActive()` — uses shared pedal snapshot.
- `IsBrakePressedForSequentialReset()` — uses shared pedal snapshot.
- `IsClutchFullyPressedForRestart()` — consumes a pre-read clutch value.
- `ReadSelectedGear()` — complete fail-closed H-pattern validation.
- `IsAnalogHandbrakeActive()` — simplified around sanitized/precomputed configuration.
- `IsShifterHandbrakeActive()` — single-slot model, fail-closed read and re-arm.
- `IsFirstGearSelectedForStall()` — shared pedal/selected-gear context and safer reverse/unknown handling.

**Statistics-adjacent / overlays**
- `UpdateStopwatchDisplay()` — participates in shared overlay positioning.
- `ToggleStopwatch()` — manages activation ordering and coordinated overlay refresh.
- `ClearStopwatch()` — clears shared overlay order and repositions remaining stats.
- `LapStopwatch()` retains equivalent timing behavior but operates within the new shared overlay subsystem.

**Transient / mode state**
- `ClearSequentialBrakeResetState()` — now also clears Reverse Assist eligibility and composes brake-reset stall-grace cleanup.
- `ToggleTransmissionMode()` — delegates state transition to `SetTransmissionMode()`.
- `ToggleClutchRequired()` — clears queued/clutch/stall transaction state.
- `ToggleClutchNeutral()` — clears queued/clutch/stall transaction state.
- `ToggleShifterHandbrake()` — one-slot model and centralized sequential-mode transition/re-arming.
- `ToggleStalling()` — centralized stall-state clearing and safe stalled-state exit.
- `ToggleScriptPause()` — cancels menu automation, releases outputs, disarms edge inputs, clears timers, and stops/resumes MainLoop scheduling.

**Auxiliary / transmission logic**
- `HandlePaddleSync()` — both transmission modes, fail-closed re-arm, shift statistics.
- `HandleHandbrake()` — analog/shifter/stall arbitration with protected output state.
- `HandleHPatternTransmission()` — shared snapshots, physical-change tracking, safe reverse handling, output-success checks, paddle coexistence, statistics.
- `HandleSequentialBrakeHoldReset()` — shared snapshots, reverse-assist eligibility, statistics baseline, queue clearing, lever disarm, clutch-neutral preservation.
- `TrySequentialShift()` — direction/limit validation, output-success gating, correct queued deltas, statistics.
- `HandleSequentialTransmission()` — cached mappings, fail-closed reads/re-arm, conflict suppression, queued-shift helper, complete clutch-mode handling.
- `ShouldSuppressStallForBrakeReset()` — shared pedal snapshot.
- `HandleStallDetection()` — shared snapshots, centralized clear logic, new-process suppression, safer first-gear gating.
- `EnterEngineOffState()` — centralized state cleanup, Reverse Assist release, statistics baseline synchronization.
- `StallEngine()` — records stall statistic before entering engine-off state.
- `MaintainStalledState()` — aligned `NeutralResendMs` terminology.
- `TryRestartEngine()` — explicit clutch snapshot, centralized state clearing, statistics baseline.
- `SyncGear()` — full reverse/neutral/forward direct protocol support and synchronized transient-state reset.
- `ResetInputs()` — parameterized game sync/status behavior and safe new-process internal reset.
- `MainLoop()` — adaptive scheduling, process sync, focus transitions, feature-aware input sampling, shared snapshots, and new subsystem routing.

## [1.1.1] - 2026-08-08

### Highlights

- Added the first persistent in-game stopwatch system, including pause/resume, lap tracking, and reset controls.
- Added a Help hotkey for quickly displaying the current live-mode controls.
- Expanded the stall/restart model so configurations without a clutch pedal behave correctly.
- Decoupled stall/restart behavior from assumptions that `RequireClutch` and `ClutchActsAsNeutral` are always enabled together.

### Added

#### Stopwatch

- Added a persistent in-game stopwatch.
- Added a configurable stopwatch start/pause/resume hotkey.
- Added stopwatch lap support with up to 10 visible timer entries.
- Added a configurable stopwatch clear/reset hotkey.

#### Live-control help

- Added a Help hotkey for displaying the current live-mode controls.

### Changed

#### Stall / clutch behavior

- Expanded stalling behavior for configurations without a clutch pedal.
- Stall detection now respects `RequireClutch` and `ClutchActsAsNeutral` independently.
- Engine restart now requires the clutch only when `RequireClutch` is enabled.

---

## [1.0.0] - 2026-08-06

### Highlights

- Initial public RealManual release.
- Added H-pattern and sequential transmission support built around MW2005-HShifter direct gear selection.
- Added optional clutch, handbrake, stall simulation, synchronization/recovery, configuration validation, and hardware-detection systems.

### Added

#### Transmission

- Physical H-pattern transmission support for gears 1-6, reverse, and neutral.
- Configurable 5-speed / 6-speed gearbox limit.
- Sequential transmission mode using configurable shifter positions.
- Runtime switching between H-pattern and sequential transmission modes.
- Configurable sequential shifter inversion.
- Queued sequential shifts while the clutch is held.
- Virtual gear tracking for sequential mode.
- H-pattern-to-sequential gear-state synchronization.
- Native paddle-shift synchronization.
- Manual gear synchronization/recovery hotkeys.
- Sequential brake-hold gear reset/recovery.

#### Clutch and handbrake

- Optional clutch requirement for gear changes.
- Optional clutch-to-neutral behavior.
- Optional analog USB handbrake support.
- Optional shifter-slot handbrake for sequential mode.
- Independent shifter-handbrake inversion.

#### Stall / engine simulation

- Added first-gear stall simulation:
  - stall detection when the clutch is released without sufficient throttle;
  - stall detection when first gear is left engaged without clutch or throttle input;
  - forced neutral and handbrake while the simulated engine is off;
  - ignition hotkey for manual engine shutoff and restart;
  - restart requiring physical neutral and clutch position;
  - stall/restart throttle-blip effects.

#### Runtime controls and diagnostics

- Runtime feature toggles through configurable hotkeys.
- Optional status tooltips.
- Config reload from the tray menu.
- Automatic release of held output keys when the game loses focus.
- Startup configuration validation.
- Startup hardware detection.
- Troubleshooting log generation.
- Separate RealManual Input Detector utility.
- INI-based controller mappings, thresholds, timing, output keys, and feature switches.
