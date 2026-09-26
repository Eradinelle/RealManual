# RealManual

RealManual is an AutoHotkey v2 transmission and input bridge for **Need for Speed: Most Wanted (2005)**. It adds physical H-pattern and sequential shifting, clutch behavior, handbrakes, manual synchronization, reverse assistance, simulated stalling, statistics, a stopwatch, and several quality-of-life utilities that the original game does not provide natively.

RealManual reads controller state through the Windows joystick interface and works together with **MW2005-HShifter** to provide direct reverse, neutral, and forward-gear selection.

> **Current version:** 1.2.0
>
> **Game compatibility:** MW2005-HShifter currently targets **Need for Speed: Most Wanted 1.3 Black Edition**.
>
> **Primary tested hardware:** Logitech G29 wheel, pedals and H-pattern shifter using Logitech Gaming Software (LGS), plus a separate USB handbrake. Need for Speed: Most Wanted (2005) relies on DirectInput-compatible controller input. RealManual itself reads controller state through AutoHotkey's joystick interface, which depends on Windows correctly enumerating the device.

See [`CHANGELOG.md`](CHANGELOG.md) for the complete 1.2.0 change history.

---

## Requirements

- Windows 10 or Windows 11
- Need for Speed: Most Wanted (2005), version 1.3 Black Edition
- AutoHotkey v2
- An ASI loader capable of loading `.asi` plugins from the NFSMW game directory or `scripts` directory
- MW2005-HShifter, preferably the build included with the RealManual release
- A wheel, pedals, shifter, handbrake (optional), or other controller hardware that is visible through the Windows joystick interface

RealManual does not replace the game's normal steering, accelerator, brake, menu, camera, nitrous, speedbreaker, or other ordinary controls. Those still need to be configured inside NFSMW itself.

---

## Installation

1. Install **AutoHotkey v2** if it is not already installed.
   - https://www.autohotkey.com/

2. Make sure your NFSMW installation has a working ASI loader.
   - If other `.asi` mods already load correctly from your game directory or `scripts` directory, this requirement is already satisfied.

3. Download the latest RealManual release.

4. Copy the included `scripts` folder into the main Need for Speed: Most Wanted directory and allow it to merge with any existing `scripts` folder.

   The resulting layout should contain files similar to:

   ```text
   Need for Speed Most Wanted/
   └── scripts/
       ├── RealManual.ahk
       ├── RealManual_InputDetector.ahk
       ├── config.ini
       └── MW2005-HShifter.asi
   ```

   RealManual may also create:

   ```text
   startup_log.txt   # when WriteStartupLog=1
   stats.txt         # persistent session/all-time statistics
   ```

5. Configure `config.ini` for your hardware and preferences. See [Configuration](#configuration).

6. Run `RealManual.ahk`.

   Starting RealManual before NFSMW is still the simplest workflow, but 1.2.0 can also attach to an already-running `speed.exe` process.

7. Start Need for Speed: Most Wanted normally if it is not already running.

RealManual only processes gameplay inputs while `speed.exe` is the active foreground application. When NFSMW is unfocused, RealManual reduces its polling rate; while RealManual is paused or its menu automation is active, the normal gameplay polling timer is stopped.

### MW2005-HShifter

RealManual uses a modified build of MW2005-HShifter maintained here:

https://github.com/Eradinelle/MW2005-HShifter

The RealManual release should be used with the version of `MW2005-HShifter.asi` included in that release. The original mod can also provide the direct-gear protocol, but the RealManual-maintained build is the version this project is developed and tested against.

---

## Configuration

RealManual reads its settings from `config.ini`, which must remain in the same directory as `RealManual.ahk`.

Boolean settings use:

```text
0 = disabled / false
1 = enabled / true
```

Hotkeys can use normal AutoHotkey v2 modifiers:

```text
^ = Ctrl
+ = Shift
! = Alt
# = Win
```

Leave a configurable hotkey value blank to disable that hotkey.

### 1. Verify the hardware in Windows first

Before editing RealManual mappings:

1. Press `Win + R`.
2. Enter: `joy.cpl`
3. Select the wheel/controller and open **Properties**.
4. Confirm that the wheel, pedals, shifter buttons, paddles, and other required controls produce visible input.

If the device is missing from `joy.cpl`, or the Properties/Test page is blank or does not react, fix the Windows driver/enumeration problem before configuring RealManual. See [Troubleshooting](#troubleshooting).

### 2. Run the RealManual Input Detector

Run:

```text
RealManual_InputDetector.ahk
```

The detector scans the Windows joystick slots and displays each detected device, its axes, and currently pressed buttons.

Typical names look like:

```text
1JoyX
1JoyY
1JoyZ
1JoyR
1Joy13
1Joy19
2JoyR
```

The number before `Joy` is the Windows/AutoHotkey joystick number. The suffix identifies an axis or button.

Move or press **one control at a time** and watch which value changes.

For example:

```text
Clutch pedal     -> 1JoyY
First gear       -> 1Joy13
Second gear      -> 1Joy14
Reverse gate     -> 1Joy19
USB handbrake    -> 2JoyR
```

The detector supports joystick slots 1-16 and scans buttons 1-32. `F9` reloads the detector and `Esc` closes it.

### 3. Understand the configuration sections

RealManual 1.2.0 uses the following sections:

| Section | Purpose |
| --- | --- |
| `[General]` | Startup log and tooltip behavior |
| `[Hotkeys]` | Runtime controls, stopwatch/statistics controls, menu/capture utilities |
| `[Transmission]` | Startup transmission mode and 5/6-speed limit |
| `[Clutch]` | Clutch behavior, axis and threshold |
| `[Pedals]` | Shared gas/brake axis and brake-direction thresholds |
| `[GameKeys]` | Keyboard actions configured inside NFSMW |
| `[HPattern]` | Physical 1-6 and reverse shifter positions |
| `[Sequential]` | Sequential lever, paddles, brake reset and queued-shift timing |
| `[Handbrake]` | Analog handbrake and optional sequential shifter-slot handbrake |
| `[Stalling]` | Simulated engine stall/restart behavior |
| `[ReverseAssist]` | Optional digital reverse-key assistance |
| `[Timing]` | Normal key hold and focused polling interval |
| `[Stopwatch]` | Stopwatch refresh and line limit |
| `[Statistics]` | Persistent shift/stall/race-restart tracking |

### 4. Configure the important hardware mappings

Use the identifiers reported by the Input Detector.

| Config setting | Section | Purpose |
| --- | --- | --- |
| `ClutchAxis` | `[Clutch]` | Physical clutch pedal axis |
| `CombinedPedalAxis` | `[Pedals]` | Shared gas/brake axis used by brake reset, Reverse Assist, and stall logic |
| `HandbrakeAxis` | `[Handbrake]` | Optional analog USB handbrake axis |
| `Gear1Button` through `Gear6Button` | `[HPattern]` | Physical H-pattern forward gears |
| `ReverseButton` | `[HPattern]` | Physical reverse gate |
| `SequentialUpshiftButton` | `[Sequential]` | Sequential upshift shifter position |
| `SequentialDownshiftButton` | `[Sequential]` | Sequential downshift shifter position |
| `PaddleUpshiftButton` | `[Sequential]` | Native paddle upshift used for tracked-gear synchronization |
| `PaddleDownshiftButton` | `[Sequential]` | Native paddle downshift used for tracked-gear synchronization |
| `ShifterHandbrakeButton` | `[Handbrake]` | Optional H-shifter slot used as handbrake in sequential mode |
| `ForwardKey` | `[GameKeys]` | NFSMW accelerate/forward keyboard binding |
| `ReverseKey` | `[GameKeys]` | NFSMW brake/reverse keyboard binding used by Reverse Assist |
| `HandbrakeKey` | `[GameKeys]` | NFSMW handbrake keyboard binding |
| `ShiftUpKey` | `[GameKeys]` | NFSMW sequential upshift key and physical-key synchronization source |
| `ShiftDownKey` | `[GameKeys]` | NFSMW sequential downshift key and physical-key synchronization source |

### 5. Reserved MW2005-HShifter protocol keys

RealManual and MW2005-HShifter reserve these physical keyboard keys:

```text
0   = reverse
N   = neutral
1-6 = forward gears
```

These are fixed protocol bindings.

RealManual 1.2.0 checks configured bindings at startup. Conflicting bindings are blocked/disabled and reported in `startup_log.txt`.

The fixed protocol keys can also be used for RealManual's manual direct-gear synchronization:

```text
0   -> reverse
N   -> neutral
1-6 -> corresponding forward gear
```

### Expected pedal direction

RealManual's default/tested logic expects:

| Input | Released/resting | Activated |
| --- | ---: | ---: |
| Clutch | high, near 100 | low, near 0 |
| Analog handbrake | low | high |
| Combined gas/brake axis | near center | gas moves one direction, brake moves the opposite direction |

The direction of the **brake** side of the combined axis is configurable through `BrakeAxisIncreasesWhenPressed`.

### Tested axis configuration

The primary tested setup is a Logitech G29 using Logitech Gaming Software (LGS), with **combined gas/brake pedals enabled**, plus a separate USB handbrake.

- **Gas**
  - Axis: `1JoyZ`
  - Resting value: around `50`
  - Pressing the gas makes the value **decrease toward 0**

- **Brake**
  - Axis: `1JoyZ`
  - Resting value: around `50`
  - Pressing the brake makes the value **increase toward 100**

- **Clutch**
  - Axis: `1JoyY`
  - Released value: around `100`
  - Pressing the clutch makes the value **decrease toward 0**

- **USB handbrake**
  - Axis: `2JoyR`
  - Released value: around `0`
  - Pulling the handbrake makes the value **increase toward 100**

In this configuration, gas and brake share the same centered axis.

Relevant 1.2.0 settings:

```ini
[Clutch]
ClutchAxis=1JoyY
ClutchThreshold=40

[Pedals]
CombinedPedalAxis=1JoyZ
CombinedPedalCenter=50
BrakeAxisIncreasesWhenPressed=1
BrakeActiveThreshold=55

[Handbrake]
HandbrakeAxis=2JoyR
HandbrakeThreshold=20
```

The harder sequential brake-reset threshold is configured separately:

```ini
[Sequential]
BrakeResetThreshold=70
```

Reverse Assist also has a separate **engagement** threshold:

```ini
[ReverseAssist]
EngageBrakeThreshold=60
```

Once Reverse Assist is already active, normal brake release uses `[Pedals] BrakeActiveThreshold`.

If you cannot detect your hardware with older software, see [Using newer or incompatible hardware through middleware](#using-newer-or-incompatible-hardware-through-middleware).

### Configure the game itself

RealManual is a transmission/input bridge.

Inside NFSMW, bind the controls that the game can read directly, including:

- steering
- accelerator
- brake/reverse
- normal menu/navigation controls
- camera/nitrous/speedbreaker and other gameplay buttons you use

Also make sure the keyboard output keys under `[GameKeys]` match the corresponding keyboard controls inside NFSMW.

The default 1.2.0 values are:

```ini
[GameKeys]
ForwardKey=w
ReverseKey=s
HandbrakeKey=Space
ShiftUpKey=e
ShiftDownKey=q
```

`ShiftUpKey` and `ShiftDownKey` are also monitored as **physical keyboard inputs** so RealManual can keep its tracked gear synchronized when you shift with the game's native keyboard controls. RealManual ignores its own synthetic shift outputs for this synchronization path.

The direct reverse/neutral/forward protocol uses the fixed `0`, `N`, and `1`-`6` keys described above.

### Default hotkeys

The included 1.2.0 config uses:

| Default | Action |
| --- | --- |
| `F1` | Show RealManual hotkey/status help |
| `F2` | Reset/synchronize transmission state |
| `F3` | Pause/resume RealManual |
| `Ctrl+F3` | Reload RealManual/config |
| `F4` | Toggle H-pattern / sequential mode |
| `Shift+F4` | Invert sequential shifter direction |
| `Ctrl+F4` | Toggle 5-speed / 6-speed limit |
| `F5` | Toggle clutch requirement |
| `Shift+F5` | Toggle clutch-to-neutral |
| `F6` | Toggle shifter-slot handbrake |
| `F7` | Toggle simulated stalling |
| `1Joy24` | Ignition / engine restart |
| `F8` | Stopwatch start/pause/resume |
| `Shift+F8` | Stopwatch lap |
| `Ctrl+F8` | Clear stopwatch |
| `F9` | Toggle shift statistics display |
| `Shift+F9` | Toggle stall statistics display |
| `Ctrl+F9` | Toggle race-restart statistics display |
| `F10` | Record one race restart |
| `F11` | Run/cancel maximum-video-settings automation |
| blank by default | Save NVIDIA Instant Replay |
| blank by default | Capture NVIDIA screenshot |

Live feature toggles change the current running state only. They don't write the new value back to `config.ini`; reloading RealManual restores the saved configuration.

### Shifter handbrake

`EnableShifterHandbrake` allows one H-pattern shifter position to act as a handbrake while RealManual is in sequential mode.

The default config recommends second gear:

```ini
[Handbrake]
EnableShifterHandbrake=0
ShifterHandbrakeButton=1Joy14
```

The default sequential lever uses third/fourth gear positions, so second gear avoids overlap.

If the shifter-handbrake slot overlaps either configured sequential shift position, RealManual gives the handbrake ownership of the conflicting shifter arrangement while that feature is enabled. For normal sequential-shifter use, choose a non-overlapping slot.

### Sequential brake-hold reset

Sequential mode can reset its tracked gear to first after sustained hard braking:

```ini
[Sequential]
EnableBrakeHoldGearReset=1
BrakeHoldResetMs=2000
BrakeResetThreshold=70
```

This is a recovery heuristic for cases where the game's actual sequential gear may no longer match RealManual's tracked gear.

The reset:

- establishes first gear as the new tracked target;
- clears stale queued sequential shifts;
- requires the sequential lever to return to neutral before creating another shift;
- preserves clutch-to-neutral if the clutch is intentionally holding the game in neutral;
- coordinates with Reverse Assist and stall-protection timing.

### Reverse Assist

Reverse Assist is intended to improve reversing when the physical brake pedal is too stiff or difficult to hold far enough for strong reverse acceleration.

When enabled, RealManual can hold the configured NFSMW `ReverseKey` digitally while the car is in an eligible reverse state.

```ini
[ReverseAssist]
EnableReverseAssist=1
EngageBrakeThreshold=60
```

Behavior:

- the brake must first cross `EngageBrakeThreshold` to engage the assist;
- once active, it stays active until the pedal falls below the normal `[Pedals] BrakeActiveThreshold`;
- pressing the clutch immediately disables the assist;
- in H-pattern mode, the physical shifter must be in reverse and the direct reverse command must have succeeded;
- in sequential mode, Reverse Assist cooperates with the sequential brake-hold reset state.

This feature still uses the shared combined gas/brake axis.

### Stalling / engine simulation

The optional stall system simulates an engine-off state using gear, clutch, and pedal state.

```ini
[Stalling]
EnableStalling=1
ClutchReleaseThreshold=60
ThrottleThreshold=15
RestartClutchThreshold=15
NeutralResendMs=50
ThrottleBlipMs=500
NoInputStallDelayMs=700
BrakeResetStallGraceMs=100
```

When enabled, RealManual can stall in FIRST gear when:

- the clutch is released too far without sufficient throttle; or
- first gear remains coupled at low/no throttle long enough.

While the simulated engine is off:

- RealManual repeatedly maintains neutral;
- the handbrake is forced on;
- ordinary transmission behavior is blocked until restart.

Restart behavior:

- the physical H-pattern shifter must be in neutral (I know you can start a car in any gear, but this is good practice);
- if `RequireClutch=1`, the clutch must also be pressed deeply enough to satisfy `RestartClutchThreshold`;
- RealManual sends a simulated throttle blip and resumes from neutral.

The stall model is still a simulation; it does not read actual NFSMW RPM, vehicle speed, engine torque, or clutch torque from game memory.

### Statistics

Version 1.2.0 adds persistent statistics for:

- shifts;
- simulated stalls;
- manually recorded race restarts.

Enable categories independently:

```ini
[Statistics]
TrackShifts=1
TrackStalls=1
TrackRaceRestarts=1
ClearAllTimeOnStartup=0
```

RealManual stores statistics in:

```text
stats.txt
```

#### Session definition

A **Session** is the lifetime of one NFSMW `speed.exe` process.

- Starting/reloading RealManual while the same NFSMW process is still running resumes the same session.
- When that `speed.exe` process ends or is replaced, RealManual transfers the completed Session counters into AllTime.
- The next NFSMW process begins a fresh Session.
- Session counters are persisted while the game is running so a RealManual reload does not discard the current session.

The on-screen statistics panel shows **Session** values. Persistent AllTime values remain in `stats.txt`.

Race restarts are not inferred automatically; use `RaceRestartButton` to record one.

`ClearAllTimeOnStartup=1` is a one-shot maintenance option. RealManual clears the AllTime counters and resets that config value back to `0`.

### Stopwatch and shared overlays

RealManual includes a persistent in-game stopwatch with:

- start;
- pause/resume;
- laps;
- clear/reset;
- configurable refresh interval;
- configurable maximum displayed lines.

```ini
[Stopwatch]
StopwatchRefreshMs=50
StopwatchMaxLines=10
```

The stopwatch and statistics panel use separate tooltip IDs and can be displayed at the same time. The overlay that was activated first keeps the primary position; the second is placed beside it.

### Maximum video settings automation

`MaxVideoSettingsButton` runs a cancellable keyboard macro that navigates NFSMW's menus and applies the author's maximum-video-settings sequence.

This is intentionally a very specific utility.

It is designed to be started:

- from the **main menu**;
- with the menu selection positioned on **Career Mode** (just having entered the game);
- with the video settings **not already maxed in both Basic and Advanced**.

Press the hotkey again while the sequence is running to cancel it.

The macro is focus-guarded and pauses RealManual's normal gameplay polling while it owns the menu input sequence.

If your starting selection or existing settings state differs, do not assume the sequence will land on the intended options.

It is meant to max LEVEL OF DETAIL in BASIC and:
   FULL SCREEN ANTI-ALIASING
   TEXTURE FILTERING
   WORLD LEVEL OF DETAIL
   ROAD REFLECTION DETAIL
   SHADOW DETAIL
   CAR GEOMETRY DETAIL
   CAR REFLECTION DETAIL
   CAR REFLECTION UPDATED RATE
   and TURN ON VSYC
   in ADVANCED

If BASIC or ADVANCED settings don't prompt you to save on ESC, sequence will fail.

### NVIDIA capture hotkeys

Two optional hotkeys can map controller/wheel buttons to NVIDIA Overlay capture shortcuts:

```ini
SaveInstantReplayButton=
CaptureScreenshotButton=
```

When configured:

- `SaveInstantReplayButton` sends NVIDIA Overlay's `Alt+F10`;
- `CaptureScreenshotButton` sends NVIDIA Overlay's `Alt+F1`.

They are blank by default.

These utilities assume those NVIDIA Overlay shortcuts are still configured to their standard values.

### Startup validation and log

RealManual 1.2.0 performs a broader startup validation pass covering:

- missing config values;
- invalid boolean syntax;
- invalid integer syntax;
- numeric ranges;
- clutch/brake threshold relationships;
- duplicate H-pattern/sequential/paddle mappings;
- duplicate dynamic hotkeys;
- malformed hotkeys;
- conflicts with the fixed MW2005-HShifter protocol;
- configured hardware availability.

If `WriteStartupLog=1`, the report is written to:

```text
startup_log.txt
```

Use the tray-menu **Open Validation Log** command when diagnosing a configuration problem.

### Device numbers can change

Windows may assign a different joystick number after:

- changing USB ports;
- reinstalling a driver;
- adding/removing another controller;
- repairing joystick registry entries.

If an input suddenly stops working after a hardware change, run the Input Detector again and verify that `1Joy...`, `2Joy...`, etc. still match `config.ini`.

---

## Features

### Transmission

- Physical H-pattern support for gears 1-6, reverse, and neutral
- Configurable 5-speed / 6-speed gearbox limit
- Sequential mode using configurable H-shifter positions
- Runtime switching between H-pattern and sequential modes
- Configurable sequential shifter inversion
- Optional clutch requirement
- Optional clutch-to-neutral behavior
- Queued sequential shifts while the clutch is held
- Direct-gear and virtual-gear synchronization
- Manual reverse/neutral/1-6 synchronization hotkeys
- Native paddle-shift synchronization
- Native physical keyboard shift synchronization
- Sequential brake-hold first-gear recovery/reset
- Fail-closed H-pattern and sequential reads with explicit neutral/released re-arming

### Handbrake and reverse

- Optional analog USB handbrake
- Optional H-shifter-slot handbrake in sequential mode
- Combined handbrake arbitration between analog, shifter-slot, and simulated engine-off requests
- Optional Reverse Assist for stronger digital reverse-key output
- Separate reverse-assist engagement and normal brake-release thresholds

### Engine simulation

- First-gear clutch/throttle stall detection
- First-gear sustained low-throttle stall detection
- Forced neutral and handbrake while the simulated engine is off
- Manual ignition shutoff/restart
- Physical-neutral restart requirement
- Optional clutch restart requirement
- Stall/restart throttle-blip effects
- Brake-reset stall-grace coordination
- New-game stall suppression until the first accepted driver shift

### Statistics and timing

- Persistent per-NFSMW-process Session statistics
- Persistent AllTime statistics
- Shift tracking
- Stall tracking
- Manual race-restart tracking
- Independent statistics display toggles
- Persistent stopwatch with pause/resume, laps, and clear
- Shared statistics/stopwatch overlay layout

### Safety, validation, and recovery

- Fixed protocol-key reservation for `0`, `N`, and `1`-`6`
- Startup sanitization of unsafe configured bindings
- Duplicate/malformed hotkey protection
- Configuration relationship validation
- Startup hardware detection
- Fail-closed unreadable controller handling
- Automatic release of held output keys on focus loss
- Best-effort output cleanup on RealManual exit/reload
- NFSMW process restart/crash/replacement detection
- Internal-only synchronization for a newly launched game process
- Centralized transient-state clearing across resets and mode changes
- Config reload from tray/hotkey

### Utilities and performance

- RealManual Input Detector
- Maximum-video-settings menu automation
- Optional NVIDIA Instant Replay hotkey
- Optional NVIDIA screenshot hotkey
- Focus-aware MainLoop scheduling
- Default 5 ms focused polling
- 100 ms unfocused polling
- Gameplay polling stopped while paused/menu automation is active

---

## Troubleshooting

### Start with `joy.cpl`

RealManual can only use controller inputs that Windows exposes through its joystick interface.

Press `Win + R`, enter `joy.cpl`, select the device, and open **Properties**.

The required axes and buttons should react there before you troubleshoot RealManual itself.

Use this order:

```text
Hardware / vendor driver
        ↓
joy.cpl
        ↓
RealManual_InputDetector.ahk
        ↓
config.ini
        ↓
RealManual.ahk
        ↓
MW2005-HShifter.asi / NFSMW
```

If one layer does not work, fix that layer before moving down the chain.

### Controller driver software

Use the manufacturer's official Windows driver/control software whenever possible. The important requirement is not the program name itself; the device must ultimately be exposed to Windows in a form that works through `joy.cpl` and the RealManual Input Detector.

Common examples include:

- **Logitech:** Logitech Gaming Software (LGS) for older supported hardware; Logitech G HUB for newer hardware
- **Thrustmaster:** Thrustmaster Force Feedback driver/Control Panel for supported legacy FFB bases, or My Thrustmaster Panel for newer supported products
- **Fanatec:** Fanatec App, or the legacy Fanatec Driver/Control Panel where appropriate
- **MOZA:** MOZA Pit House

RealManual's primary tested Logitech configuration uses **Logitech Gaming Software (LGS)**. Compatibility with other driver suites should be verified with `joy.cpl` and the Input Detector rather than assumed.

Some Fanatec bases provide a **Compatibility PC mode** intended specifically for older games; on supported bases this can make the device identify as an older Fanatec model that legacy titles recognize.

### `joy.cpl` works, but RealManual Input Detector does not

Check the following:

1. Close any old copy of RealManual or another input script that may be polling/remapping the same device.
2. Run `RealManual_InputDetector.ahk`.
3. Verify the device number and axis/button identifiers again.
4. Try a stable motherboard USB port rather than a hub for initial diagnosis.
5. Disconnect unrelated controllers temporarily and test with only the wheel/shifter connected.
6. Reboot after driver or USB enumeration changes.
7. If the device works under another Windows user account but not your main account, see [Repairing Windows joystick registry/enumeration data](#repairing-windows-joystick-registryenumeration-data).

### Input Detector works, but RealManual does not

Check:

- `config.ini` is beside `RealManual.ahk`
- the mapped names exactly match the Input Detector (`1Joy13`, `2JoyR`, etc.)
- the correct feature is enabled in `config.ini`
- NFSMW is running as `speed.exe` and is the active foreground window
- RealManual is not paused from its tray menu/hotkey
- if NFSMW is running as Administrator, run RealManual at the same privilege level
- check `startup_log.txt` through **Open Validation Log** in the RealManual tray menu

### Startup log reports a reserved protocol conflict

The physical keyboard keys `0`, `N`, and `1`-`6` belong to MW2005-HShifter's fixed direct-gear protocol.

If `startup_log.txt` reports a conflict:

1. Find the named config entry.
2. Change that binding to a non-reserved key/button/axis.
3. Reload RealManual.
4. Confirm the warning is gone.

RealManual intentionally disables conflicting runtime bindings rather than allowing them to interfere with direct gear commands.

### RealManual reacts, but direct gears do not work

This usually points to the ASI/direct-protocol side rather than controller detection.

Check:

- `MW2005-HShifter.asi` is in the NFSMW root or `scripts` directory used by your ASI loader
- your ASI loader is working
- you do not have two different copies/versions of MW2005-HShifter installed at the same time
- the game is the supported 1.3 Black Edition build
- `0`, `N`, and `1`-`6` are not being intercepted/rebound by another script or utility
- `startup_log.txt` does not report a reserved-key conflict

### Sequential shifts stop after an input/device problem

RealManual 1.2.0 intentionally fails closed when it cannot read both configured sequential directions safely.

After the input becomes readable again, return the sequential lever to its neutral/released position before attempting the next shift.

The same re-arm principle applies after several mode changes, handbrake ownership changes, resets, and other synchronization events.

### Shifter handbrake works, but the sequential lever does not

Check whether `ShifterHandbrakeButton` overlaps `SequentialUpshiftButton` or `SequentialDownshiftButton`.

Use a non-overlapping shifter position if you want the sequential H-shifter pair and shifter handbrake available together. The included config recommends second gear for the handbrake and third/fourth for sequential shifting.

### Reverse Assist does not engage

Check:

- `EnableReverseAssist=1`
- `[GameKeys] ReverseKey` matches NFSMW's brake/reverse keyboard control
- `CombinedPedalAxis` is correct
- `BrakeAxisIncreasesWhenPressed` matches the physical axis direction
- `EngageBrakeThreshold` is on the brake side of `CombinedPedalCenter`
- the clutch is not currently pressed
- in H-pattern mode, the shifter is actually in reverse
- check `startup_log.txt` for pedal-axis/threshold warnings

### Statistics do not update

Check:

- the relevant `TrackShifts`, `TrackStalls`, or `TrackRaceRestarts` option is enabled
- the corresponding statistics display toggle is enabled if you expect to see it on-screen
- race restarts are recorded manually with `RaceRestartButton`
- `stats.txt` is writable beside `RealManual.ahk`

Remember that the on-screen panel displays **Session** values. AllTime values are stored in `stats.txt` and are updated when the owning NFSMW process session is finalized.

### Maximum video settings automation navigates incorrectly

The automation assumes a specific starting state.

Before using it:

- be on the NFSMW **main menu**
- have **Career Mode** selected
- use the expected 1.3 Black Edition menu layout
- do not assume it will work correctly if Basic and Advanced video settings are already in a different/maxed state

Press the hotkey again to cancel an active sequence.

### Using newer or incompatible hardware through middleware

If newer hardware does not expose a DirectInput-compatible device that NFSMW can use, middleware such as vJoy/UCR or Joystick Gremlin can create a virtual DirectInput device for the game. RealManual can then be configured against either the physical or virtual joystick device, depending on which one Windows/AutoHotkey exposes reliably.

This path is intended as a compatibility fallback and has **not been validated on every wheel or controller model**.

A useful goal is to create a virtual Windows joystick that RealManual can see even when the physical hardware is exposed through a newer or incompatible input path.

#### Option A: UCR + vJoy

**Universal Control Remapper (UCR)** can read both XInput and DirectInput controllers and can output a virtual DirectInput controller through **vJoy**.

Projects:

- UCR: https://github.com/Snoothy/UCR
- vJoy maintained Windows fork: https://github.com/jshafer817/vJoy

Recommended procedure:

1. Install the manufacturer's normal driver/software first and confirm the physical hardware works in its own control panel.
2. Install a Windows 10/11-compatible vJoy build.
3. Open **Configure vJoy** and create one virtual joystick.
4. Enable enough axes and buttons for the controls you need.
   - Keep RealManual-specific buttons within buttons 1-32 because the Input Detector scans the first 32 joystick buttons.
5. Install/start UCR.
6. Select the physical controller as the input source.
7. Select the vJoy device as the output device.
8. Create mappings for the needed controls:
   - clutch axis -> vJoy axis
   - shifter buttons -> vJoy buttons
   - reverse -> vJoy button
   - paddles -> vJoy buttons
   - handbrake -> vJoy axis/button as appropriate
   - steering/gas/brake as well if NFSMW cannot use the physical device directly
9. Activate the UCR profile.
10. Open `joy.cpl` and test the **vJoy Device**. Moving the physical controls should now move the virtual device.
11. Run `RealManual_InputDetector.ahk`.
12. Configure RealManual using the vJoy identifiers reported by the detector rather than the original physical device identifiers.

If the physical device is XInput-only but UCR can read it, this route can convert the inputs RealManual needs into a vJoy/DirectInput joystick output.

#### Option B: Joystick Gremlin + vJoy

Joystick Gremlin is another strong option when the physical device is already exposed as a DirectInput joystick.

Projects:

- Joystick Gremlin: https://whitemagic.github.io/JoystickGremlin/
- vJoy: https://github.com/jshafer817/vJoy

Typical procedure:

1. Install/configure vJoy.
2. Open Joystick Gremlin.
3. Select the physical wheel/pedals/shifter.
4. Map the needed physical axes and buttons to the vJoy device.
5. Activate the Gremlin profile.
6. Test the vJoy device in `joy.cpl`.
7. Run the RealManual Input Detector and use the vJoy mappings in `config.ini`.

Joystick Gremlin also provides a **Merge Axis** action. This can be useful when modern pedals expose accelerator and brake as separate axes but RealManual's pedal-dependent features need a combined gas/brake axis. The `Bidirectional` merge operation is intended for pedal-style inputs.

After creating the merged vJoy axis, verify its actual rest/gas/brake values with the Input Detector and configure:

```ini
[Pedals]
CombinedPedalAxis=
CombinedPedalCenter=
BrakeAxisIncreasesWhenPressed=
BrakeActiveThreshold=
```

Then configure the feature-specific harder thresholds as needed:

```ini
[Sequential]
BrakeResetThreshold=

[ReverseAssist]
EngageBrakeThreshold=
```

#### Optional: HidHide

If both the physical controller and virtual vJoy device are visible to a game, some games may receive duplicate/conflicting input. **HidHide** can hide the original physical device from applications while allowing the remapping software to continue reading it.

Project:

https://github.com/nefarius/HidHide

Use HidHide only when duplicate physical/virtual input is actually a problem.

General setup:

1. Install HidHide and reboot if requested.
2. Add the remapping application (for example UCR or Joystick Gremlin) to HidHide's allowed applications list.
3. Select the original physical controller as the device to hide.
4. Do **not** hide the vJoy output device.
5. Enable device hiding.
6. Verify that the remapper still sees the physical device and `joy.cpl` still sees the vJoy device.

If NFSMW needs direct access to the physical wheel for force feedback, hiding it may interfere with that path. RealManual itself does not emulate or manage force feedback, so test carefully before hiding a wheel base from the game.

### Repairing Windows joystick registry/enumeration data

> **Advanced troubleshooting. Back up the affected registry keys before deleting anything. Do not delete unrelated HID/controller keys.**

A controller can be correctly installed at the USB/HID level while its per-user Windows joystick state is stale or corrupt. Symptoms can include:

- the device appears in `joy.cpl` but its Test page is blank
- AutoHotkey/RealManual sees no input even though the game or vendor software does
- the device works in one Windows user profile but not another
- joystick numbers change or disappear
- stale controller names remain after driver changes

Windows stores some of this data per user under `HKEY_CURRENT_USER`, so two Windows accounts on the same PC can behave differently.

#### Find the device VID/PID

Open **Device Manager**:

1. Find the wheel/controller under **Human Interface Devices**, **Sound, video and game controllers**, or the vendor-specific category.
2. Open **Properties**.
3. Open the **Details** tab.
4. Select **Hardware Ids**.
5. Note the value containing:

   ```text
   VID_XXXX&PID_YYYY
   ```

For example, the Logitech G29 uses:

```text
VID_046D&PID_C24F
```

#### Back up the per-user joystick keys

For a G29, PowerShell/Command Prompt examples are:

```bat
reg export "HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\VID_046D&PID_C24F" "%USERPROFILE%\Desktop\G29-OEM-backup.reg"
reg export "HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_046D&PID_C24F" "%USERPROFILE%\Desktop\G29-DirectInput-backup.reg"
```

For another device, replace the VID/PID with the hardware ID reported by Device Manager.

If a key does not exist, `reg export` will report that it could not find it; do not create a replacement manually unless you know exactly what data belongs there.

#### Reset the affected per-user device entries

Close NFSMW, RealManual, the Input Detector, and other controller tools. Disconnect the controller if practical.

Delete **only the matching VID/PID key** under these locations:

```text
HKEY_CURRENT_USER\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\VID_XXXX&PID_YYYY
```

and:

```text
HKEY_CURRENT_USER\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_XXXX&PID_YYYY
```

For the G29 example:

```bat
reg delete "HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\VID_046D&PID_C24F" /f
reg delete "HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\DirectInput\VID_046D&PID_C24F" /f
```

Then:

1. reboot Windows or sign out/restart the affected driver environment
2. start the manufacturer's driver/control software if it normally runs with the device
3. reconnect the controller
4. allow Windows to enumerate it again
5. test it in `joy.cpl`
6. run the RealManual Input Detector again
7. update `config.ini` if the joystick number changed

The purpose of this reset is to remove stale per-user joystick/OEM/DirectInput state so Windows and the vendor driver can regenerate it during enumeration.

#### Check `CurrentJoystickSettings`

Legacy joystick enumeration also uses a mapping under:

```text
HKEY_CURRENT_USER\System\CurrentControlSet\Control\MediaResources\Joystick\DINPUT.DLL\CurrentJoystickSettings
```

Typical values include names such as:

```text
Joystick1OEMName
Joystick2OEMName
Joystick1Configuration
Joystick2Configuration
```

The `Joystick#OEMName` values identify which VID/PID occupies a legacy joystick slot.

If this key contains stale mappings, or is missing/corrupt on one Windows user profile while the same hardware works on another profile, the problem may be per-user enumeration rather than the physical wheel or USB driver.

Before changing it, export the key:

```bat
reg export "HKCU\System\CurrentControlSet\Control\MediaResources\Joystick\DINPUT.DLL\CurrentJoystickSettings" "%USERPROFILE%\Desktop\CurrentJoystickSettings-backup.reg"
```

For a targeted cleanup, remove stale `Joystick#OEMName` and matching `Joystick#Configuration` values that clearly reference a controller which is no longer present, then reconnect/re-enumerate the hardware.

Deleting the entire `CurrentJoystickSettings` key should be treated as a last resort after a backup; allow Windows/vendor software to rebuild it.

#### Driver re-enumeration if registry reset is not enough

If the correct entries do not regenerate:

1. Disconnect the controller.
2. Open **Device Manager**.
3. Enable **View -> Show hidden devices**.
4. Find only the entries belonging to the affected wheel/controller.
5. Uninstall the affected device entries.
6. Reboot.
7. Reinstall or repair the manufacturer's official driver package.
8. Reconnect the hardware to a stable USB port.
9. Test `joy.cpl` before reopening RealManual.

Avoid removing unrelated generic HID devices; keyboards, mice, other controllers, and internal devices also appear under the HID categories.

### Device works in one Windows account but not another

This strongly suggests a per-user configuration/enumeration problem because much of the legacy joystick state used here is stored under `HKEY_CURRENT_USER`.

Test `joy.cpl` in both accounts. If one account has a working Test page and the other is blank, focus troubleshooting on the affected account's joystick/DirectInput registry state.

### Controller ordering / enumeration problems

If multiple controllers are attached and RealManual identifies the wrong device number:

1. Close the game and RealManual.
2. Disconnect all optional controllers.
3. Connect the main wheel first.
4. Confirm it in `joy.cpl`.
5. Connect the shifter/handbrake/secondary devices one at a time.
6. Run `RealManual_InputDetector.ahk`.
7. Update all `1Joy...`, `2Joy...`, etc. values in `config.ini`.

Keep devices on the same USB ports after configuration when possible.

---

## Known Limitations

- RealManual currently targets NFSMW 2005 and relies on MW2005-HShifter for direct gear selection.
- The bundled H-shifter mod currently targets the 1.3 Black Edition executable.
- RealManual does not provide force feedback.
- The stall system is a simulation based on pedal and gear state; it does not currently read actual engine RPM, vehicle speed, clutch torque, or other drivetrain values from game memory.
- Pedal-dependent features such as stall-throttle detection, sequential brake reset, and Reverse Assist currently expect a usable combined gas/brake axis.
- Race-restart statistics are manually recorded; RealManual does not currently detect race restarts from game memory.
- The maximum-video-settings automation is a positional menu macro and depends on the documented menu starting state/layout.
- NVIDIA capture utilities send fixed `Alt+F10` and `Alt+F1` shortcuts; custom NVIDIA Overlay shortcut assignments are not detected automatically.
- Middleware configurations such as UCR/vJoy, Joystick Gremlin/vJoy, and HidHide are compatibility options and are not guaranteed to work with every wheel/base/driver combination.
- Windows joystick numbering can change after hardware/driver enumeration changes.

---

## Credits and Third-Party Software

RealManual uses a modified build of **MW2005-HShifter**, originally created by **x0reaxeax**.

RealManual-maintained fork:

https://github.com/Eradinelle/MW2005-HShifter

MW2005-HShifter incorporates **MinHook** and Hacker Disassembler Engine components.

See:

```text
THIRD_PARTY_NOTICES.md
licenses/MW2005-HShifter-LICENSE.txt
licenses/MinHook-LICENSE.txt
```

for attribution and license details.

---

## License

RealManual is distributed under the MIT License.

See `LICENSE.txt` for the complete license terms.

RealManual is an unofficial community project and is not affiliated with, authorized by, or endorsed by Electronic Arts.
