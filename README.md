# RealManual

**RealManual** is an AutoHotkey v2 transmission and controller-input bridge for **Need for Speed: Most Wanted (2005)**. Together with [MW2005-HShifter](https://github.com/Eradinelle/MW2005-HShifter), it adds direct H-pattern gear selection, sequential shifting, clutch simulation, an optional engine-stall/restart model, handbrake handling, gear synchronization, statistics, a stopwatch, and configurable utilities.

**Version:** 1.3.0  
**Target game:** NFSMW 2005 v1.3 Black Edition, using a compatible MW2005-HShifter ASI build.  
**Supported RealManual profiles:** **SimRig** (H-pattern or sequential) and **Gamepad** (sequential only).

RealManual reads controllers through the Windows joystick interface. It **does not replace NFSMW's ordinary driving controls**: steering, acceleration, braking, NOS, Speedbreaker, pause and native paddle shifting must still reach the game through its own control bindings. RealManual handles the supplemental transmission and simulation logic.

The two configurations actually tested during development are:

- **SimRig:** Logitech G29 + H-shifter + clutch + USB Arduino Leonardo handbrake, with **separate throttle and brake pedals**, Logitech Gaming Software (LGS), **Joystick Gremlin R16 + vJoy 2.1.9.1**, and HidHide. The combined-pedal G29 configuration remains available.
- **Gamepad:** DualShock 4 through **DS4Windows virtual DualShock 4 output**, with HidHide preventing duplicate physical-controller input; analog L2 clutch, R2 throttle, right-stick-down brake, R1/L1 shifts, and right-stick-up ignition.

For changes since 1.2.0, see [CHANGELOG.md](CHANGELOG.md).

---

## Requirements

### RealManual itself

- Windows 10 or 11 and [AutoHotkey v2](https://www.autohotkey.com/).
- **Need for Speed: Most Wanted (2005), v1.3 Black Edition**, with a functioning ASI loader.
- [MW2005-HShifter](https://github.com/Eradinelle/MW2005-HShifter), preferably the matching `.asi` included with the RealManual release.
- A controller exposed to the Windows joystick APIs and verified with `joy.cpl` / the RealManual Input Detector.

### Optional software by hardware path

| Setup | Software | Reason |
| --- | --- | --- |
| G29, **combined pedals** | Logitech Gaming Software (LGS) | Original single centered throttle/brake axis; no virtual joystick required if NFSMW recognizes the wheel. |
| G29, **independent pedals** | **LGS**, [vJoy](https://github.com/jshafer817/vJoy), [Joystick Gremlin](https://whitemagic.github.io/JoystickGremlin/), [HidHide](https://github.com/nefarius/HidHide) | Preserve three independent physical pedals; present a game-compatible virtual joystick while RealManual reads the physical G29. |
| DualShock 4 | **DS4Windows**, its matching virtual-controller backend, **HidHide** | Create a single virtual DualShock 4 with independent analog inputs and hide duplicate physical input. |

**Software distinction:** vJoy and HidHide install drivers that function without their configuration windows. **Joystick Gremlin must remain running with its profile active** to feed vJoy; **DS4Windows must remain running** when it is supplying the gamepad's virtual controller. RealManual must remain running for its own functions.

---

## Installation

1. Install AutoHotkey v2.
2. Install an ASI loader and verify that `.asi` mods load in NFSMW.
3. Download the RealManual release and place the provided files in your NFSMW installation. A typical layout is:

   ```text
   Need for Speed Most Wanted/
   └── scripts/
       ├── RealManual.ahk
       ├── RealManual.ini
       ├── RealManual_InputDetector.ahk
       ├── RealManual_DeviceIdentity_Probe.ahk
       └── MW2005-HShifter.asi
   ```

   The RealManual.ahk can live and be launched from anywhere, as long as its config is in its directory. H-Shifter.asi has to be in the NFSMW scripts folder.
4. Keep `RealManual.ini` **beside `RealManual.ahk`**. Choose a controller setup below, then edit its mappings.
5. Start RealManual before or after NFSMW; it monitors the `speed.exe` process and applies its input handling while the game has focus.

If enabled, `startup_log.txt` and `stats.txt` are written alongside RealManual. `RealManual_InputDetector.ahk` and `RealManual_DeviceIdentity_Probe.ahk` are standalone, read-only diagnostic utilities.

### MW2005-HShifter direct-gear protocol

The H-shifter ASI uses fixed keyboard commands:

| Key | Direct gear |
| --- | --- |
| `0` | Reverse |
| `N` | Neutral |
| `1`–`6` | Forward gears 1–6 |

RealManual reserves these keys and checks configurable bindings for conflicts. Its fixed synchronization keys also let you manually re-establish the tracked gear. Do not bind gameplay functions to these reserved keys.

---

## Controller profiles and device detection

RealManual v1.3.0 separates shared settings from the two supported profiles:

- `[General]`, `[Hotkeys]`, `[GameKeys]`, `[Timing]`, `[Stopwatch]`, `[Statistics]`: common behavior and keyboard output.
- `[Profiles]`, `[JoystickDevices]`: profile preference, manual switching and controller discovery.
- `[Profile.SimRig.*]`: G29-style clutch, H-pattern/sequential, pedals, handbrake, stalling and Reverse Assist.
- `[Profile.Gamepad.*]`: sequential Gamepad actions, calibration, hysteresis (for axis-to-button mappings and vice-versa) and stalling.

### Automatic profile selection

```ini
[Profiles]
ActiveProfile=1          ; 0 = Gamepad, 1 = SimRig
ToggleProfileButton=^F12

[JoystickDevices]
AutoEnumerateDevices=1  ; 1 = exact hardware IDs, 0 = manual slots
GamepadHardwareId=VID_054C&PID_05C4
WheelHardwareId=VID_046D&PID_C24F
HandbrakeHardwareId=VID_2341&PID_8036
```

The IDs above are **verified for MY setup**, not universal defaults. `GamepadHardwareId` refers to the tested **virtual** DualShock 4. The physical second-generation DS4 can instead report `VID_054C&PID_09CC`; do not confuse it with the intended virtual input. Use the **VID** obtained from `RealManual_DeviceIdentity_Probe.ahk`.

When `AutoEnumerateDevices=1`, RealManual checks responding Windows joystick slots **1–16**, matches the configured VID/PID to a live device, and resolves logical bindings such as `Wheel:JoyY` to the correct current slot. It requires an **unambiguous** match; two identical devices with the same VID/PID cannot be uniquely distinguished by this method. Generic `JoyName` strings are not used as hardware identity because different controllers may share the name `Microsoft PC-joystick driver`.

Automatic selection follows the connected **primary controllers** (Wheel and Gamepad), not the optional handbrake:

| Connected primary controllers | Active RealManual profile |
| --- | --- |
| Only wheel | SimRig, regardless of preference |
| Only Gamepad | Gamepad, regardless of preference |
| Both | Use `ActiveProfile` as the preference |
| Neither | Refuse startup |

**On every new `speed.exe` process**, RealManual resets the session's transmission/input state and refreshes the active controller/profile. `Ctrl+F12` requests a manual switch **of RealManual's input profile only**, subject to target-device availability and clutch/queued-shift safety checks. Within a running game, this preserves tracked gear and simulated engine state. A new game PID instead triggers fresh-session reset.

**NFSMW seems to only be able to detect 1 external controller per launch (Wireless controller through DS4Windows/G29/vJoy) and it seems to favor the G29 first and vJoy last (if you HidHide the handbrake, letting RealManual send the handbrake key. Otherwise it will detect the handbrake before vJoy). Switching profiles with the Gamepad and SimRig both connected will not change what NFSMW currently sees. You will still need to relaunch the game and disconnect the SimRig before launching if switching to a Gamepad. Autoenumeration handles the active connected device automatically. NFSMW also seems to only save 1 external device controls at a time. Changing devices will require you to remap controls within NFSMW. Do not map Up/Down shifts for the Gamepad in NFSMW. Those are handled by RealManual.**

For fixed manual assignments, set `AutoEnumerateDevices=0` and fill `GamepadSlot`, `WheelSlot` and `HandbrakeSlot` with their current 1–16 joystick numbers. In automatic mode those slot fields are ignored. **Those numbers may change on disconnect/reconnect/PC restart. Verify with `RealManual_InputDetector.ahk`**

### Identify controller hardware IDs with the bundled probe

Use **`scripts/RealManual_DeviceIdentity_Probe.ahk`** when first setting up automatic enumeration, changing drivers or virtual-controller software, or investigating a controller mismatch. Unlike the ordinary Input Detector, this read-only AutoHotkey v2 diagnostic reports device identity **and its verified current AHK joystick slot**.

1. Connect or start the controllers you want RealManual to identify (for example, the physical G29, Arduino handbrake and a DS4Windows **virtual** DualShock 4). If HidHide is enabled, run the probe with an allowlisted AutoHotkey executable so it can see the hidden physical devices.
2. Run `RealManual_DeviceIdentity_Probe.ahk`, then click **Refresh** after changing connections. It enumerates the responding `1Joy`–`16Joy` slots and uses DirectInput's joystick-ID association to correlate device names to slots rather than trusting enumeration list order.
3. In each **`--- AHK SLOT N ---`** block, look for **`IDENTITY: DIRECTINPUT SLOT-MATCHED`** and read the **`DirectInput VID/PID`** and **`OEM registry identifier`** fields. These should agree in the verified setups; use the `VID_XXXX&PID_YYYY` value, **not** the generic `AHK JoyName` (`Microsoft PC-joystick driver` may appear for every device). If an identity is unresolved or ambiguous, investigate before assigning a role.
4. Copy those IDs into `[JoystickDevices]` in **`scripts/RealManual.ini`**: physical wheel → `WheelHardwareId`, physical USB handbrake → `HandbrakeHardwareId`, intended **virtual DS4** → `GamepadHardwareId`. Save and reload RealManual; check its startup report/log for the resolved roles.
5. To inspect a binding *within* one controller (axis direction, shifter button number), use `RealManual_InputDetector.ahk` separately. Device IDs and joystick slot numbers serve different purposes.

Example excerpts from the **tested** hardware (other revisions/devices can differ):

```text
AHK SLOT 1 — Logitech G29 Driving Force Racing Wheel USB
  DirectInput VID/PID: VID_046D&PID_C24F    -> WheelHardwareId
AHK SLOT 3 — Arduino Leonardo USB handbrake
  DirectInput VID/PID: VID_2341&PID_8036    -> HandbrakeHardwareId
AHK SLOT 4 — virtual Wireless Controller (DS4-compatible)
  DirectInput VID/PID: VID_054C&PID_05C4    -> GamepadHardwareId
```

The **slot numbers are illustrative and can change**. In automatic mode RealManual uses the hardware IDs, not the example numbers.

### Important: RealManual profile selection is not NFSMW controller selection

| Situation | RealManual behavior | What NFSMW does / recommended action |
| --- | --- | --- |
| `AutoEnumerateDevices=1`, only Gamepad primary connected | Selects Gamepad, ignoring `ActiveProfile` | Launch/relaunch with the intended Gamepad controller as the only game-visible driving device. |
| `AutoEnumerateDevices=1`, only wheel primary connected | Selects SimRig, ignoring `ActiveProfile` | Launch/relaunch with the intended wheel or SimRig vJoy output as the only game-visible driving device. |
| `AutoEnumerateDevices=1`, **both** primary controllers connected | Uses configured `ActiveProfile` | **Does not compel NFSMW to use that device**; on my setup NFSMW is likely to keep the SimRig/wheel-side controller. Isolate the desired game-visible device and relaunch. |
| `AutoEnumerateDevices=0` | Uses the configured profile and manual slot bindings | `Ctrl+F12` can switch RealManual profiles if both role assignments are available; **NFSMW still needs the appropriate device selected at launch**. |

**Recommended everyday workflow with auto enumeration (tested practical approach):**

1. **Exit NFSMW completely** before changing between SimRig and Gamepad. Switching RealManual while the game remains open does not replace NFSMW's chosen controller.
2. Stop/disconnect or hide the *unwanted game-visible driving device*, and make the new controller available. For Gamepad, enable the intended DS4Windows virtual DS4 and prevent the SimRig wheel/**vJoy** device from competing; disconnecting the physical wheel alone may **not** remove vJoy, since vJoy is a separate installed virtual device. For SimRig, activate Joystick Gremlin/vJoy and avoid competing DS4Windows virtual outputs. Check ordinary, non-allowlisted `joy.cpl` if uncertain.
3. **Relaunch NFSMW.** RealManual detects the new `speed.exe` PID, resets its game-session state, and in auto mode selects the sole detected primary controller (or your `ActiveProfile` preference if both still appear to RealManual). Confirm NFSMW's native bindings and rebind/save them if necessary.

In this tested one-game-controller-at-a-time workflow, **Ctrl+F12 is generally unnecessary with `AutoEnumerateDevices=1`**, because process relaunch refreshes the profile automatically. The manual switch hotkey is most useful when using `AutoEnumerateDevices=0` or on hardware/game installations that demonstrably support both native devices at once. RealManual may legitimately see hidden physical devices through HidHide's allowlist even though the game sees only the chosen virtual controller.

### Hardware verification

1. Open `Win + R` → `joy.cpl` → **Properties → Test** to establish that Windows receives input.
2. Run `RealManual_InputDetector.ahk`; move one axis/button at a time to find its AutoHotkey binding (`1JoyY`, `3JoyR`, etc.).
3. Run the bundled **`RealManual_DeviceIdentity_Probe.ahk`** to identify each controller's exact VID/PID for automatic enumeration as described above. Windows joystick numbers can change after a reconnect or driver change.
4. If HidHide is enabled, an allowlisted AutoHotkey process can see hidden devices even if normal `joy.cpl` only lists the game-visible virtual controller. This is expected.

---

## Setup A — SimRig with Logitech G29

The SimRig profile supports H-pattern and sequential transmissions, a physical clutch, paddle tracking, a separate USB handbrake, optional Reverse Assist and simulated stalling. The setup below describes both combined pedals and the newly **tested independent-pedal setup**.

### A1. Original combined-pedal configuration

This path remains useful if NFSMW recognizes the G29 directly and separate-pedal support isn't needed.

In LGS, enable **Combined Pedals** for the profile NFSMW will use. The tested G29 then exposes a shared throttle/brake axis near **50 at rest**, decreasing toward 0 on throttle and increasing toward 100 on brake. The clutch remains independent and decreases from 100 released toward 0 pressed **this is how it worked on my setup, verify for yours**.

```ini
[Profile.SimRig.Pedals]
UseCombinedPedals=1
CombinedPedalAxis=Wheel:JoyZ
BrakeAxisIncreasesWhenPressed=1
ThrottleAxis=
BrakeAxis=
ThrottleAxisIncreasesWhenPressed=0
BrakeActivePercent=10
```

With `UseCombinedPedals=1`, separate throttle/brake fields are unused.

### A2. Independent pedals — tested with LGS + Joystick Gremlin + vJoy

This was verified in NFSMW with **simultaneous independent acceleration and braking**, without automatic menu scrolling or phantom throttle. The exact physical and virtual axes matter:

| Physical G29 (for RealManual) | LGS / Gremlin input | Range: released → pressed | Virtual vJoy output (for NFSMW) |
| --- | --- | --- | --- |
| Steering `Wheel:JoyX` | Gremlin `X Axis` (Axis 1) | Center → left/right | vJoy **X Axis**, full centered range |
| Throttle `Wheel:JoyZ` | Gremlin `Y Axis` (Axis 2) | 100 → 0 | vJoy **Y Axis**, **50 → 0** |
| Brake `Wheel:JoyR` | Gremlin `Z Rotation` (Axis 6) | 100 → 0 | vJoy **Z Axis**, **50 → 100** |
| Clutch `Wheel:JoyY` | Gremlin `Slider` (Axis 7) | 100 → 0 | **Not mapped**; RealManual reads the physical clutch |

**Why centered half-axes?** NFSMW interpreted the tested UCR/virtual-DS4 throttle trigger as fully pressed at rest, even though the Windows axis moved correctly. Using vJoy axes with a centered resting position and limited half-axis travel solved the issue on this system. It is **not** evidence that every NFSMW installation or controller requires centered pedals: the tested DS4Windows gamepad's R2 trigger worked with a normal 0–100 range.

#### 1. Configure the physical pedals in Logitech Gaming Software

1. Open LGS and select the profile to use with NFSMW. Disable **Combined Pedals**.
2. Make that profile **Persistent**, or ensure the NFSMW-specific profile uses the same setting. LGS previously switched back to combined inputs when a different profile became active.
3. In `joy.cpl` / the Input Detector, confirm all three pedals are independent and return to **100 when released, 0 when pressed**.
4. Keep this physical configuration unchanged. RealManual reads the G29 directly and needs the original axis directions, not the virtual vJoy directions.

#### 2. Install and configure vJoy

The tested version is **vJoy 2.1.9.1** from the [jshafer817 vJoy releases](https://github.com/jshafer817/vJoy/releases). During installation, retaining the Feeder, Configuration, Monitoring and Device Listing utilities is useful for testing.

Open **Configure vJoy** and set up **Device 1**:

| Option | Tested configuration |
| --- | --- |
| Enabled axes | **X, Y, Z** only |
| Rx, Ry, Rz, Slider, Dial/Slider2 | Disabled |
| Buttons | 32 |
| POV hats | 1 continuous (optional if using a D-pad) |
| Force-feedback effects | Disabled on the *virtual* device |
| Enable vJoy | On |

Apply and verify **vJoy Device** appears in `joy.cpl`. The configuration utility may be closed afterward; the vJoy driver remains active. Disabling vJoy's virtual force-feedback effects does not change the physical G29 driver settings; however, the game no longer sends its normal wheel force feedback through the hidden physical G29. Test LGS's independent centering-spring option if you want steering recentering without in-game FFB; it is **not guaranteed** to work the same on every system.

#### 3. Create a Joystick Gremlin profile

The tested version is **Joystick Gremlin R16**; R14.3 was unstable on this system. Create and save a profile, for example `NFSMW G29 Independent Pedals.xml`. For the tested portable installation, placing the XML **beside the `Joystick.Gremlin.R16` application folder** (in its parent directory) resolved a profile-loading issue.

In **Tools → Input Viewer**, expand the G29 and enable **Axes – Current**. For this hardware, the controls were:

- **X Axis / Axis 1:** wheel steering.
- **Y Axis / Axis 2:** throttle.
- **Z Rotation / Axis 6:** brake.
- **Slider / Axis 7:** clutch (do not map it to vJoy).

For each pedal, select its **physical** G29 axis, create **one action sequence**, add **Response Curve** first and **Map to vJoy** second. Set the curve type to **Piecewise Linear**, leave **Symmetric** off, and keep the default deadzone during initial validation.

**Throttle: G29 Y Axis → vJoy Device 1 / Y Axis, Absolute**

| Curve input X | Curve output Y |
| ---: | ---: |
| `-1.00` | `-1.00` |
| `+1.00` | `0.00` |

**Brake: G29 Z Rotation → vJoy Device 1 / Z Axis, Absolute**

| Curve input X | Curve output Y |
| ---: | ---: |
| `-1.00` | `+1.00` |
| `+1.00` | `0.00` |

The pedals are physically **+1 released** and **−1 fully pressed**. Gremlin expresses neutral vJoy output as `0` (equivalent to 50 on AutoHotkey's 0–100 axis scale). Thus throttle output is `0 → -1` as the pedal is pressed; brake output is `0 → +1`.

**Steering: G29 X Axis → vJoy Device 1 / X Axis, Absolute**, with no response curve initially.

Save with `Ctrl+S`, **activate** the Gremlin profile using its joystick toolbar icon, then inspect **Input Viewer → vJoy Device 1 → Axes – Current**:

| Pedal position | vJoy Y (throttle) | vJoy Z (brake) |
| --- | ---: | ---: |
| Neither pressed | 0 (center) | 0 (center) |
| Throttle fully pressed | −100% | 0 |
| Brake fully pressed | 0 | +100% |
| Both fully pressed | −100% | +100% |

If the physical pedal mapping reports different names or directions on your G29, verify inputs before copying these curves. **Gremlin must stay active while playing**, unlike vJoy's configuration utility.

#### 4. Map the controls NFSMW uses directly

Add a **Map to vJoy** action to the matching physical G29 button in Gremlin. Use Input Viewer → **Buttons & Hats** to identify the button number. Map buttons as ordinary press/release events: both **Press** and **Release** enabled, **Invert activation** off.

The tested wheel's right and left paddles are `Wheel:Joy5` and `Wheel:Joy6`; they can be passed through to vJoy Buttons 5 and 6 (or any two distinct vJoy buttons configured in NFSMW). **RealManual monitors the physical paddle presses for gear synchronization; it does not generate a second native paddle shift.** Also map any desired NOS, Speedbreaker, Pause/Options, and camera buttons to unused vJoy buttons. NFSMW can assign the Primary and Secondary slots to different buttons, avoiding overlapping virtual-button ownership for duplicate physical actions.

**Do not route the G29 clutch, H-shifter gear positions or ignition through vJoy.** RealManual reads these directly from the allowlisted physical wheel. Configure ignition under `[Profile.SimRig.Hotkeys]`, not as virtual input.

In NFSMW → **Options → Controls**, select **vJoy Device** and bind:

| Game action | Tested virtual mapping |
| --- | --- |
| Accelerate | **Y Axis** |
| Brake / Reverse | **Z Axis** |
| Steer Left / Right | **X Axis** |
| Shift Up / Down | Corresponding vJoy paddle buttons |
| NOS, Speedbreaker, Options | Your selected vJoy button assignments |
| Handbrake | Leave unbound if RealManual is configured to send the handbrake keyboard key |

Test steering, throttle, brake and button presses inside the game. NFSMW may need bindings re-entered after changing controllers; save using the game's normal exit flow.

#### 5. Configure HidHide to avoid device-selection conflicts

HidHide was necessary on the tested system because NFSMW sometimes chose the **Arduino handbrake** instead of the virtual driving controller; merely hiding the G29 was insufficient. The working arrangement keeps the physical devices accessible to allowlisted readers while hiding them from NFSMW:

- **Devices tab:** hide the **physical G29** (`VID_046D&PID_C24F`) and **Arduino Leonardo** (`VID_2341&PID_8036`); leave **vJoy Device** visible. Turn on **Enable device hiding**.
- **Applications tab:** allowlist the **actual executable** running RealManual (such as `AutoHotkey64.exe`, or a compiled RealManual executable), **Joystick Gremlin's executable**, and relevant LGS software where necessary. **Do not allowlist `speed.exe`.** Keep **Inverse application cloak** off for this arrangement.
- Confirm normal `joy.cpl` shows **vJoy Device** as the driving controller. RealManual/Input Detector may still see the physical wheel and Arduino because the interpreter is allowlisted; that is **expected**, not duplicate mapping.

With this arrangement, **NFSMW detects vJoy while both physical G29 and handbrake stay connected**, and RealManual still detects the Arduino handbrake correctly.

#### 6. Configure RealManual for independent physical pedals

The virtual vJoy axis names **must not** be copied into RealManual. RealManual uses **physical G29** axes for clutch/stalling/brake logic:

```ini
[Profiles]
ActiveProfile=1

[JoystickDevices]
AutoEnumerateDevices=1
WheelHardwareId=VID_046D&PID_C24F
HandbrakeHardwareId=VID_2341&PID_8036

[Profile.SimRig.Clutch]
RequireClutch=1
ClutchActsAsNeutral=1
ClutchAxis=Wheel:JoyY
ClutchAxisIncreasesWhenPressed=0
ClutchThreshold=40

[Profile.SimRig.Pedals]
UseCombinedPedals=0
CombinedPedalAxis=
BrakeAxisIncreasesWhenPressed=0
ThrottleAxis=Wheel:JoyZ
BrakeAxis=Wheel:JoyR
ThrottleAxisIncreasesWhenPressed=0
BrakeActivePercent=10

[Profile.SimRig.Handbrake]
RealManualControlsHandbrake=1
HandbrakeAxis=Handbrake:JoyR
HandbrakeAxisIncreasesWhenPulled=1
HandbrakeThreshold=20
```

All three pedals decrease from 100 released toward 0 when pressed. The external handbrake's R axis is a *different device* from the G29 brake's R axis, so `Wheel:JoyR` and `Handbrake:JoyR` do not conflict.

**Tested startup sequence:** LGS with separate pedals enabled → Joystick Gremlin running/profile active → RealManual running → NFSMW. Once HidHide is configured, the physical handbrake can remain connected. Start or reload RealManual with the desired primary controller attached. `speed.exe` launch/relaunch refreshes the active RealManual profile, but NFSMW independently selects and binds the game-visible controller.

---

## Setup B — DualShock 4 Gamepad

The Gamepad profile is **sequential only**. It uses the same clutch-required, clutch-to-neutral, stalling/ignition, brake-hold reset, stopwatch and statistics systems where applicable.. It does **not** enable SimRig-only Reverse Assist, H-pattern toggling or shifter-slot handbrake.

### B1. Create a game-compatible virtual controller

1. Install **DS4Windows** and its matching virtual-controller backend as instructed by the distribution you are using. The tested setup used a virtual **DualShock 4**, not an Xbox 360 controller. DS4Windows backends differ among builds, so follow the matching release's driver instructions.
2. Connect the DualShock 4 and set its DS4Windows **output controller type to DualShock 4**. A virtual Xbox 360 output combined L2/R2 on one legacy axis in testing, causing throttle interference when the clutch was pressed; virtual DS4 provided independent analog triggers.
3. Use modest deadzones as a starting point (tested: about **0.08 for sticks** and **0.03 for triggers**) and adjust if necessary.
4. In HidHide, hide the **physical** DS4 from NFSMW, allowlist `DS4Windows.exe`, and leave the **virtual** DS4 visible. Avoid relying on the legacy DS4Windows “Hide DS4” option when HidHide owns device filtering. Keep only one virtual controller output active to avoid VID/PID ambiguity.
5. In `joy.cpl` and the Input Detector, verify independent triggers and stick axes, then bind steering/throttle/brake/NOS/handbrake directly inside NFSMW.

The working Gamepad layout was:

| Control | Source | Destination |
| --- | --- | --- |
| Steering | Left stick X | NFSMW native steering |
| Throttle | R2, `Gamepad:JoyU` | NFSMW native throttle; RealManual stall telemetry |
| Brake | Right stick **down**, `Gamepad:JoyR` (50 → 100) | NFSMW native brake; RealManual brake telemetry |
| Clutch | L2, `Gamepad:JoyV` (0 → 100) | RealManual |
| Upshift / downshift | R1 `Gamepad:Joy6` / L1 `Gamepad:Joy5` | RealManual sequential actions |
| Ignition | Right stick **up**, `Gamepad:JoyR` (50 → 0) | RealManual analog-to-digital action |
| Handbrake | Square `Gamepad:Joy1` | NFSMW native binding by default; can be changed to RealManual for analog bindings with configurable thresholds |

The right-stick **up/down** uses the same physical axis for different actions: brake down, ignition up, resting center. RealManual uses distinct calibration endpoints, and the Gamepad's driving assignments must be coordinated with this layout. Alternate physical controllers may expose different axes/buttons.

### B2. Configure the Gamepad inputs

```ini
[Profiles]
ActiveProfile=0

[JoystickDevices]
AutoEnumerateDevices=1
GamepadHardwareId=VID_054C&PID_05C4

[Profile.Gamepad.Transmission]
MaxForwardGear=6

[Profile.Gamepad.Clutch]
RequireClutch=1
ClutchActsAsNeutral=1
ClutchThreshold=40

[Profile.Gamepad.Inputs]
ClutchSource=Gamepad:JoyV
ThrottleSource=Gamepad:JoyU
BrakeSource=Gamepad:JoyR
HandbrakeSource=Gamepad:Joy1
RealManualControlsHandbrake=0
UpshiftSource=Gamepad:Joy6
DownshiftSource=Gamepad:Joy5
IgnitionSource=Gamepad:JoyR

[Profile.Gamepad.AxisCalibration]
ClutchReleased=0
ClutchPressed=100
ThrottleReleased=0
ThrottlePressed=100
BrakeReleased=50
BrakePressed=100
HandbrakeReleased=0
HandbrakePressed=100
UpshiftReleased=0
UpshiftPressed=100
DownshiftReleased=0
DownshiftPressed=100
IgnitionReleased=50
IgnitionPressed=0

[Profile.Gamepad.Activation]
AnalogActivationPercent=60
AnalogReleasePercent=40
AnalogHandbrakeActivationPercent=20
AnalogHandbrakeReleasePercent=15
```

Input types are **inferred** from the configured source: axis, button, keyboard key or POV. Analog axis endpoints describe *physical actuation*, and RealManual converts the clutch to its own **clutch-release percentage** (0 = fully depressed, 100 = released). When an analog axis drives a digital action such as ignition or sequential shift, `AnalogActivationPercent` and `AnalogReleasePercent` provide hysteresis to avoid repeated triggers near a threshold. For analog script-controlled handbrakes, use the dedicated activation/release pair. Digital buttons don't need these analog hysteresis settings. For a POV source, add the corresponding `<Action>POVDirection` setting (0/4500/.../31500) in `[Profile.Gamepad.Inputs]`.

**Native handbrake:** `RealManualControlsHandbrake=0` lets NFSMW read the controller's handbrake binding. Setting it to `1` makes RealManual read `HandbrakeSource` and send the configured `[GameKeys] HandbrakeKey` instead. In both profiles, the engine-off simulation can force a handbrake command when needed.

**Gamepad shift outputs:** Unlike physical paddles on the SimRig (which RealManual only monitors), Gamepad R1/L1 are RealManual's *sequential shift commands*. Do not simultaneously bind those same controller buttons to NFSMW's native up/downshift controls or you could duplicate the shift.

### B3. Launch and change controllers

Run DS4Windows with the virtual DS4 active, and make sure HidHide exposes the intended virtual Gamepad to NFSMW without a competing SimRig controller. Start RealManual and launch NFSMW. With automatic enumeration, RealManual selects Gamepad when it is the only detected primary device. **If both Wheel and Gamepad remain visible to RealManual, `ActiveProfile=0` is needed to prefer Gamepad—but this does not override NFSMW's own device choice.**

When changing from SimRig to Gamepad, close NFSMW, stop or isolate the wheel-side virtual controller (vJoy can remain enumerated even when Gremlin is stopped), activate the virtual DS4, then relaunch the game and verify/rebind its native controls. Switching `Ctrl+F12` during an existing NFSMW session cannot change its native driving device. See [RealManual profile selection is not NFSMW controller selection](#important-realmanual-profile-selection-is-not-nfsmw-controller-selection) for the full tested workflow.

---

## Configuration reference and runtime features

### Shared keyboard outputs and hotkeys

The `[GameKeys]` keyboard bindings must match NFSMW's keyboard controls

```ini
[GameKeys]
ForwardKey=w
ReverseKey=s
HandbrakeKey=Space
ShiftUpKey=e
ShiftDownKey=q
```

`ForwardKey` can also be used for timed engine throttle blips. `ReverseKey` belongs to SimRig Reverse Assist.

AHK hotkey modifiers use `^` = Ctrl, `+` = Shift, `!` = Alt and `#` = Win. Optional capture hotkeys may be left blank.

| Default | Function | Availability |
| --- | --- | --- |
| `F1` | Show live-mode help | Both |
| `F2` | Reset/synchronize input and gear state | Both |
| `F3` / `Ctrl+F3` | Pause/resume / reload configuration | Both |
| `Ctrl+F12` | Manually switch controller profile | Both, subject to safety/availability |
| `F4` | H-pattern ↔ sequential | SimRig only |
| `Shift+F4` | Invert sequential lever positions | SimRig only |
| `Ctrl+F4` | Toggle maximum 5/6 forward gears | Both |
| `F5` / `Shift+F5` | Clutch required / clutch-to-neutral | Both |
| `F6` | Shifter-slot handbrake | SimRig only |
| `F7` | Stalling/engine simulation | Both |
| Configured SimRig wheel button (tested `Wheel:Joy24`) | Ignition shutoff/restart | SimRig |
| Configured Gamepad `IgnitionSource` | Ignition shutoff/restart | Gamepad |
| `F8` / `Shift+F8` / `Ctrl+F8` | Stopwatch / lap / clear | Both |
| `F9` / `Shift+F9` / `Ctrl+F9` | Shift/stall/race-restart statistics | Both |
| `F10` | Record race restart | Both |
| Optional bindings | NVIDIA Instant Replay / screenshot | Both |
| `0`, `N`, `1`–`6` | Fixed direct-gear synchronization | Both, game-focused |

**Removed in 1.3.0:** the old F11 **MaxVideoSettings** automation. It targeted a specific older graphics-fix/menu arrangement and proved unreliable; neither the hotkey nor any macro setting is part of current RealManual. Configure graphics in-game or through your installed graphics mods instead.

### Clutch, shifting and gear tracking

`RequireClutch` controls whether shifting requires a clutch, while `ClutchActsAsNeutral` controls whether pressing the clutch temporarily selects neutral. They are **independent options**, including on Gamepad. SimRig can use H-pattern or sequential; Gamepad is always sequential. Clutch-required sequential shifting may queue shifts until release; clutch-neutral restores the intended virtual gear when the clutch releases.

For the SimRig, RealManual observes native paddle and physical keyboard shift inputs to update tracked gear, but does **not** generate an extra shift on native paddle presses. For the Gamepad, the configured up/down actions drive the sequential logic. The H-shifter ASI handles RealManual's direct-gear commands.

### Brake-hold reset and independent threshold units

Both profiles can use `EnableBrakeHoldGearReset=1`. After a sustained hard-brake hold (`BrakeHoldResetMs`), the sequential transmission can re-establish tracked first gear. `BrakeResetPercent` is normalized **brake actuation from 0 to 100**. `BrakeActivePercent`, reverse-assist `EngageBrakePercent`, throttle `ThrottleThreshold`, and handbrake percentages likewise use normalized actuation where applicable.

### Stalling, ignition and reverse assistance

RealManual's optional engine simulation may stall at low throttle when first gear is coupled. When simulated engine-off, it sends/maintains neutral and forces handbrake output, then requires an eligible ignition/restart input. It is a **simulation** based on gear, clutch and pedal state, not actual NFSMW RPM, vehicle speed or drivetrain physics. SimRig restart requires a neutral physical shifter state; Gamepad has no H-shifter gate and uses its sequential neutral logic. Clutch-restart requirements follow the active profile's configuration.

SimRig-only `EnableReverseAssist` optionally sends the configured digital reverse key during eligible reverse braking **for faster max speed reversing (useful against cops)**, using `EngageBrakePercent` for engagement and `BrakeActivePercent` for release. RealManual controls the external handbrake when `RealManualControlsHandbrake=1`; `0` leaves its normal actuation to NFSMW's native binding. If HidHide hides the handbrake from NFSMW, select **RealManual routing**, not native routing.

### Statistics and stopwatch

`stats.txt` stores **Session** and **AllTime** shift/stall/race-restart counts. A Session follows one `speed.exe` PID, persists across RealManual reloads while that game process remains alive, and finalizes when the game exits/is replaced. Race restarts are entered manually through `F10`; they are not inferred from game memory. The in-game stopwatch supports start/pause, laps and clear, and can coexist with statistics overlays.

---

## Troubleshooting

### NFSMW crashes and will not relaunch

This is unrelated to RealManual. If NFSMW crashes and subsequent launch attempts fail until Windows is restarted, try **`Win + Ctrl + Shift + B`** to reset the graphics driver, then launch the game again.

### NFSMW scrolls menus or accelerates at rest

- With separate G29 pedals, physical values are **100 released → 0 pressed**; NFSMW may treat those released endpoints as held navigation or accelerator input.
- Verify LGS didn't reactivate a different/combined-pedal profile. In the tested setup, setting the **Separate** LGS profile as persistent resolved the driver-side mode switch.
- Verify vJoy is the **only game-visible driving controller**; HidHide should hide the physical G29 and Arduino while allowing Gremlin/RealManual to read them.
- In Gremlin Input Viewer, vJoy throttle must rest at **center (0 signed)** and travel toward −100%; brake must rest centered and travel toward +100%. Don't copy their vJoy axis names into RealManual's physical-pedal settings.

### NFSMW selects the USB handbrake instead of vJoy

Hide `Arduino Leonardo` in HidHide **Devices** while keeping RealManual's exact executable in **Applications**. Leave vJoy visible and restart NFSMW. This was the confirmed fix that allowed the handbrake to remain connected permanently during NFSMW launch.

### HidHide hides devices from Windows tools

A normal, non-allowlisted `joy.cpl` may show only vJoy. The allowlisted AutoHotkey Input Detector may show the **physical G29 and handbrake plus vJoy simultaneously**. This is correct: the two applications have different visibility permissions. Verify you allowlisted the actual AHK interpreter (`AutoHotkey64.exe` in the tested environment), or the compiled executable if applicable. Keep **Inverse application cloak off** unless you intentionally reconfigure all HidHide rules.

### Gamepad trigger/brake conflict or two Wireless Controllers

Check DS4Windows output is **virtual DS4**, not Xbox 360, and ensure the physical controller is hidden via HidHide while DS4Windows is allowlisted. The physical DS4 v2 can report `VID_054C&PID_09CC`; the virtual controller used for RealManual's Gamepad hardware match reports `VID_054C&PID_05C4`. Only one intended game-visible virtual controller should be active. Avoid running UCR, Gremlin/vJoy, and DS4Windows outputs simultaneously unless you have deliberately configured distinct roles.

### RealManual starts with the wrong profile or a missing-controller error

- Check `[Profiles] ActiveProfile` (`0` Gamepad; `1` SimRig) and `[JoystickDevices] AutoEnumerateDevices`.
- Run `RealManual_DeviceIdentity_Probe.ahk` and confirm the **DirectInput VID/PID** is matched to the expected `WheelHardwareId`, `GamepadHardwareId` or `HandbrakeHardwareId`. The device's generic `JoyName` is not sufficient.
- With only one primary controller present, **automatic** mode deliberately overrides the configured preference. With both detected, the preference wins for **RealManual only**; NFSMW's selected controller may differ.
- Hardware IDs must match the **actual** intended physical or virtual device. Distinguish physical DS4 (`09CC` in the tested revision) from the virtual DS4 (`05C4` in the tested setup); duplicate matching IDs are rejected.
- In **manual** mode, slots may change after reconnecting devices; read them afresh using the Input Detector. The probe can also identify which numbered slot belongs to a device.
- On failed live Ctrl+F12 switching, release the old clutch, clear pending shifts, or switch with NFSMW closed. A missing target controller is intentionally not selected. Even if switching succeeds, relaunch NFSMW when changing its native controller.

### `joy.cpl` works but RealManual doesn't

Check `RealManual.ini` is alongside the script, `speed.exe` has focus, RealManual isn't paused, the actual AutoHotkey executable is allowed through HidHide, and `startup_log.txt` contains no hardware-ID/config validation error. If the game runs elevated, use compatible permissions for the script. Confirm `Wheel:JoyR` belongs to the G29 brake and `Handbrake:JoyR` belongs to the separate lever.

### Direct gears or sequential shifts fail

Check the MW2005-HShifter ASI is loaded exactly once and the fixed `0`, `N`, `1`–`6` protocol is unmodified. Check reserved-key diagnostics in `startup_log.txt`. After a disconnected/unreadable sequential input, return its control to neutral/released so the edge-trigger logic can re-arm. Native paddle controls must be mapped in NFSMW or the active virtual-controller profile; RealManual monitors them but does not forward them for the SimRig.

### Older or newer controllers and other driver suites

The **confirmed** virtual DirectInput workaround here is **G29 + LGS + Joystick Gremlin R16 + vJoy 2.1.9.1 + HidHide**. The same idea—vendor driver for physical input, a curve/mapping layer for game-visible vJoy, and HidHide for duplicate-device prevention *may* work with G HUB, Thrustmaster, Fanatec, MOZA, or other DirectInput-accessible gear. You must rediscover each device's physical axes, polarity and VID/PID, build matching curves, and test game compatibility. No blanket guarantee is made for these devices or their force-feedback behavior.

### Logitech Gaming Software no longer detects the G29 (confirmed fix)

On the tested **G29 with LGS 9.04.49**, Windows still recognized the wheel (`VID_046D&PID_C24F`), `joy.cpl` and Joystick Gremlin received its inputs, and LGS showed G29 firmware information in Settings—but the wheel was missing from LGS's main device selector, so its operating range could not be adjusted. Restarting Windows, reconnecting the wheel, disabling HidHide and resetting LGS's `settings.json` did not resolve it. **Reinstalling the two wheel driver INF files bundled with LGS restored detection on this system.**

1. Fully close **LGS** (`LCore.exe`), NFSMW, RealManual and Joystick Gremlin.
2. Disconnect the **G29 USB cable**.
3. Open the LGS driver directory (adjust the path if LGS is installed elsewhere):

   ```text
   C:\Program Files\Logitech Gaming Software\Drivers\LGJoyHid\
   ```

4. Right-click **`LGJoyHid.inf`** → **Show more options → Install** (on Windows 11).
5. Open the **`WinUSB`** subfolder and right-click **`LGJoyWinUsb.inf`** → **Install**.
6. Reconnect the G29, allow its calibration rotation to finish, then launch LGS. Confirm that the G29 appears in the device selector and that its **wheel operating-range** controls are available again.

This repairs the existing driver registration without first uninstalling the wheel or LGS. Both INF files were installed in the successful test; it wasn't established which individual installation resolved the issue. This is a **confirmed fix for the tested configuration**, not a guarantee for every Logitech installation.

### Windows joystick registry/enumeration issues (advanced)

If a controller appears in `joy.cpl` but its Test tab is blank, or only one Windows user account can read it, investigate Windows' per-user joystick/OEM/DirectInput registry records. **Back up relevant keys first**, target only the affected VID/PID, and prefer reinstalling/re-enumerating the vendor driver before deleting unrelated HID records. The legacy settings may reside under `HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM`, `...\DirectInput`, and `HKCU\System\CurrentControlSet\Control\MediaResources\Joystick\DINPUT.DLL\CurrentJoystickSettings`. Never broadly delete HID/controller keys.

---

## Known limitations

- RealManual relies on the MW2005-HShifter direct-gear protocol for the supported NFSMW executable; it does not provide force feedback.
- **NFSMW may select only one external driving controller per launch**, often favoring the SimRig/wheel-side input when multiple primary controllers are present on the tested installation. RealManual's `ActiveProfile`, automatic VID/PID discovery and `Ctrl+F12` do **not** change the game's selected controller. Exit NFSMW, isolate the desired native input, relaunch, and check/rebind native controls; binding persistence across controller changes is unreliable.
- In automatic mode, `Ctrl+F12` is not needed for the normal close/change-controller/relaunch workflow because RealManual reselects at a new `speed.exe` PID. Manual mode retains a meaningful profile-switch shortcut, but never bypasses NFSMW's own native device limitation.
- Simulated stalling/restart does not read real engine RPM, speed or clutch torque.
- Gamepad is sequential-only; H-pattern, shifter-slot handbrake and Reverse Assist are SimRig-only.
- VID/PID-based role matching cannot uniquely distinguish **two identical models**; no silent fallback to a different device is used.
- Native virtual-controller output depends on DS4Windows or Joystick Gremlin actively running. RealManual itself does not create vJoy/virtual DS4 devices.
- Physical wheel FFB is not passed through vJoy. LGS centering may provide a separate spring effect, but this does not reproduce the game's native wheel forces.
- Third-party device remapping and registration behaviors can vary with installed driver versions, game mods and Windows joystick ordering.
- Race-restart statistics are recorded manually. NVIDIA capture hotkeys use the normal overlay shortcuts and depend on the user's overlay configuration.

---

## Credits, third-party software and license

- **MW2005-HShifter:** originally by **x0reaxeax**; [RealManual-maintained fork](https://github.com/Eradinelle/MW2005-HShifter). The H-shifter build incorporates MinHook and Hacker Disassembler Engine components; consult the repository's `THIRD_PARTY_NOTICES.md` and license files.
- [AutoHotkey](https://www.autohotkey.com/) — scripting runtime.
- [Joystick Gremlin](https://whitemagic.github.io/JoystickGremlin/) and [vJoy](https://github.com/jshafer817/vJoy) — optional virtual joystick mapping for the tested independent G29 pedals.
- [HidHide](https://github.com/nefarius/HidHide) — optional HID visibility filter for physical/virtual devices.
- **Logitech Gaming Software** and **DS4Windows** — hardware-specific setup tools used in testing. DS4Windows virtual-controller dependencies vary by version.

These external applications/drivers are separately maintained and licensed; RealManual does **not** bundle or replace them.

RealManual is distributed under the **MIT License**; see [LICENSE](LICENSE) for the current repository license and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for dependency attribution. RealManual is an unofficial community project and is not affiliated with, authorized by, or endorsed by Electronic Arts.
