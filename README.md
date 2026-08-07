# RealManual

RealManual is an AutoHotkey v2 transmission and input bridge for **Need for Speed: Most Wanted (2005)**. It adds support for physical H-pattern and sequential shifters, clutch behavior, handbrakes, manual gear synchronization, and optional driving-simulation features that the original game does not provide natively.

RealManual is designed around the Windows joystick interface and works together with a modified build of **MW2005-HShifter** to provide direct forward-gear and neutral selection.

> **Game compatibility:** MW2005-HShifter currently targets **Need for Speed: Most Wanted 1.3 Black Edition**.
>
> **Primary tested hardware:** Logitech G29 wheel, pedals and H-pattern shifter using Logitech Gaming Software (LGS), plus a separate USB handbrake. Need for Speed: Most Wanted (2005) relies on DirectInput-compatible controller input. RealManual itself reads controller state through AutoHotkey's joystick interface, which depends on Windows correctly enumerating the device.

---

## Requirements

- Windows 10 or Windows 11
- Need for Speed: Most Wanted (2005), version 1.3 Black Edition
- AutoHotkey v2
- An ASI loader capable of loading `.asi` plugins from the NFSMW game directory or `scripts` directory
- The modified RealManual or original build of MW2005-HShifter
- A wheel, pedals, shifter, handbrake (optional), or other controller hardware that is visible through the Windows joystick interface

RealManual does not replace the game's normal steering, accelerator, brake, menu, or interaction controls. Those controls still need to be configured inside NFSMW itself.

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

5. Configure `config.ini` for your hardware. See [Configuration](#configuration).

6. Run `RealManual.ahk` **before starting the game**.

7. Start Need for Speed: Most Wanted normally.

RealManual only processes gameplay inputs while `speed.exe` is the active foreground application.

### MW2005-HShifter

RealManual uses a modified build of MW2005-HShifter maintained here:

https://github.com/Eradinelle/MW2005-HShifter

The RealManual release should be used with the version of `MW2005-HShifter.asi` included in that release. The original mod works too, but I found my changes to improve stability for RealManual.

---

## Configuration

RealManual reads its settings from `config.ini`, which must remain in the same directory as `RealManual.ahk`.

### 1. Verify the hardware in Windows first

Before editing RealManual mappings:

1. Press `Win + R`.
2. Enter: joy.cpl
3. Select the wheel/controller and open **Properties**.
4. Confirm that the wheel, pedals, shifter buttons, paddles, and other required controls produce visible input.

If the device is missing from `joy.cpl`, or the Properties/Test page is blank or does not react, fix the Windows driver/enumeration problem before configuring RealManual. See [Troubleshooting](#troubleshooting).

### 2. Run the RealManual Input Detector

Run: RealManual_InputDetector.ahk

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

### 3. Update `config.ini`

Use the identifiers reported by the Input Detector.

The most important hardware mappings are:

| Config setting | Purpose |
| --- | --- |
| `ClutchAxis` | Clutch pedal axis |
| `HandbrakeAxis` | Optional analog USB handbrake axis |
| `Gear1Button` through `Gear6Button` | Physical H-pattern forward gears |
| `ReverseButton` | Physical reverse gate |
| `UpshiftButton` | Sequential upshift shifter position |
| `DownshiftButton` | Sequential downshift shifter position |
| `BrakeAxis` | Brake/combined pedal axis used by reverse and sequential reset logic |
| `PaddleUpshiftButton` | Native paddle upshift button used for virtual-gear synchronization |
| `PaddleDownshiftButton` | Native paddle downshift button used for virtual-gear synchronization |
| Hotkey entries | Keyboard or joystick buttons used for live controls, reset, ignition, pause, etc. |

### Expected pedal direction

RealManual's default logic expects the following normalized behavior:

| Input | Released/resting | Activated |
| --- | ---: | ---: |
| Clutch | high, near 100 | low, near 0 |
| Analog handbrake | low | high |
| Combined gas/brake axis | near center | gas moves one direction, brake moves the opposite direction |

### Tested Axis Configuration

The primary tested setup is a Logitech G29 using Logitech Gaming Software (LGS),
with **combined gas/brake pedals enabled**, plus a separate USB handbrake.

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

Relevant settings:
   [Axes]
   ClutchAxis=1JoyY
   HandbrakeAxis=2JoyR

   [Sequential]
   BrakeAxis=1JoyZ
   BrakeAxisIncreasesWhenPressed=1

   [Stalling]
   CombinedPedalCenter=50

If you cannot detect your hardware with older software, see [Using newer or incompatible hardware through middleware](#using-newer-or-incompatible-hardware-through-middleware).

### Configure the game itself

RealManual is a transmission/input bridge, not a complete wheel-input replacement.

Inside NFSMW, bind the controls that the game can read directly, including:

- steering
- accelerator
- brake/reverse
- normal menu/navigation controls
- camera/nitrous/speedbreaker and other gameplay buttons you use

Also make sure the keyboard output keys configured in `config.ini` still match the corresponding game actions. In particular, the configured forward, reverse/brake, handbrake, sequential upshift, and sequential downshift keys must perform those actions in NFSMW.

The direct gear and neutral output keys are consumed by MW2005-HShifter.

### Device numbers can change

Windows may assign a different joystick number after:

- changing USB ports
- reinstalling a driver
- adding/removing another controller
- repairing joystick registry entries

If an input suddenly stops working after a hardware change, run the Input Detector again and verify that `1Joy...`, `2Joy...`, etc. still match `config.ini`.

---

## Features

- Physical H-pattern transmission support for gears 1-6, reverse and neutral
- Configurable 5-speed / 6-speed gearbox limit
- Sequential transmission mode using configurable shifter positions
- Runtime switching between H-pattern and sequential transmission modes
- Configurable sequential shifter inversion
- Optional clutch requirement for gear changes
- Optional clutch-to-neutral behavior
- Queued sequential shifts while the clutch is held
- Virtual gear tracking for sequential mode
- H-pattern-to-sequential gear-state synchronization
- Native paddle-shift synchronization
- Manual gear synchronization/recovery hotkeys
- Sequential brake-hold gear reset/recovery
- Optional analog USB handbrake support
- Optional shifter-slot handbrake for sequential mode
- Independent shifter-handbrake inversion
- First-gear stall simulation:
   - Stall detection when the clutch is released without sufficient throttle
   - Stall detection when first gear is left engaged without clutch or throttle input
   - Forced neutral and handbrake while the simulated engine is off
   - Ignition hotkey for manual engine shutoff and restart
   - Restart requires using physical neutral and clutch position
   - Stall/restart throttle-blip effects
- Runtime feature toggles through configurable hotkeys
- Optional status tooltips
- Config reload from the tray menu
- Automatic release of held output keys when the game loses focus
- Startup configuration validation
- Startup hardware detection
- Troubleshooting log generation
- Separate RealManual Input Detector utility
- INI-based controller mappings, thresholds, timing, output keys, and feature switches

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

### RealManual reacts, but direct gears do not work

This usually points to the ASI side rather than controller detection.

Check:

- `MW2005-HShifter.asi` is in the NFSMW root or `scripts` directory used by your ASI loader
- your ASI loader is working
- you do not have two different copies/versions of MW2005-HShifter installed at the same time
- the game is the supported 1.3 Black Edition build
- the RealManual output-key mappings have not been changed to values the H-shifter mod does not expect

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

Joystick Gremlin also provides a **Merge Axis** action. This can be useful when modern pedals expose accelerator and brake as separate axes but RealManual's optional stall simulation needs a combined gas/brake axis. The `Bidirectional` merge operation is intended for pedal-style inputs. After creating the merged vJoy axis, verify its actual rest/gas/brake values with the Input Detector and configure `CombinedPedalCenter`, `BrakeThreshold`, and `BrakeAxisIncreasesWhenPressed` accordingly.

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

Test `joy.cpl` in both accounts. If one account has a working Test page and the other is blank, focus troubleshooting on the affected account's joystick/DirectInput registry state

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
- The stall system is a simulation based on pedal and gear state; it does not currently read actual engine RPM, vehicle speed, or clutch torque from game memory.
- Stall-throttle detection currently assumes a usable combined gas/brake axis.
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
