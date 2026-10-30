#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; REALMANUAL - DEVICE IDENTITY PROBE (DIRECTINPUT + WINMM)
; -----------------------------------------------------------------------------
; Purpose: identify the controller attached to each AutoHotkey nJoy slot.
;
; Priority:
;   1. DirectInput product/instance name + DIPROP_JOYSTICKID slot mapping.
;   2. Slot-associated Windows joystick OEM registry information.
;   3. WinMM per-slot manufacturer/product codes and diagnostics.
;
; IMPORTANT: never associate a DirectInput device with an AHK slot merely
; because it happened to appear in the same enumeration order.
; =============================================================================

global probeWindow := Gui("+MinSize780x470", "RealManual - Device Identity Probe") ; scrolling report window
global probeText := "" ; current copyable diagnostic report
global probeEdit := "" ; report's read-only edit control

probeWindow.SetFont("s9", "Consolas") ; fixed-width font for aligned diagnostic fields
probeEdit := probeWindow.AddEdit("x12 y12 w916 h542 ReadOnly -Wrap +HScroll +VScroll", "") ; scrollable copyable report
probeWindow.SetFont("s9", "Segoe UI") ; system font for action buttons
refreshButton := probeWindow.AddButton("x12 y566 w110 h30", "Refresh") ; re-enumeration after reconnecting controllers
copyButton := probeWindow.AddButton("x132 y566 w135 h30", "Copy full report")
closeButton := probeWindow.AddButton("x818 y566 w110 h30", "Close")
refreshButton.OnEvent("Click", RefreshIdentityReport)
copyButton.OnEvent("Click", CopyIdentityReport)
closeButton.OnEvent("Click", (*) => ExitApp())
probeWindow.OnEvent("Close", (*) => ExitApp())
probeWindow.OnEvent("Size", ResizeIdentityWindow)
probeWindow.Show("w940 h610") ; diagnostic interface
RefreshIdentityReport() ; populate initial device identity report

RefreshIdentityReport(*) { ; independent snapshot of connected joystick devices
    global probeText, probeEdit
    
    try {
        probeText := BuildIdentityReport() ; query WinMM and DirectInput
    } catch Error as err { ; retain enough detail to diagnose a probe-level error
        probeText := "Probe failed: " err.Message "`r`nLine: " err.Line "`r`n" ; AutoHotkey error and line
    } ; end report-build protection
    probeEdit.Value := probeText
} ; end report refresh

CopyIdentityReport(*) {
    global probeText

    A_Clipboard := probeText
    MsgBox("The full device identity report was copied to the clipboard.", "RealManual Probe")
} ; end copy report

ResizeIdentityWindow(thisGui, minMax, width, height) { ; resize edit field and buttons with the probe window
    global probeEdit, refreshButton, copyButton, closeButton ; child GUI controls

    if minMax = -1 { ; ignore minimized state
        return
    } ; end minimized guard

    probeEdit.Move(12, 12, width - 24, height - 68) ; expand scrollable report
    refreshButton.Move(12, height - 44) ; move Refresh below the report
    copyButton.Move(132, height - 44) ; move Copy alongside Refresh
    closeButton.Move(width - 122, height - 44) ; keep Close right-aligned
} ; end window resize

BuildIdentityReport() { ; combine legacy slot enumeration with actual Windows device identities
    slots := ReadWinMMSlots() ; enumerate the same 1-16 joystick slots AutoHotkey uses
    directInput := ReadDirectInputDevices(&diError) ; enumerate named game controllers independently
    report := "REALMANUAL - WINDOWS CONTROLLER IDENTITY DIAGNOSTIC`r`n" ; start plain-text diagnostic output
    report .= "===============================================================`r`n"
    report .= "AutoHotkey: " A_AhkVersion " (" (A_PtrSize * 8) "-bit)`r`n" ; record the runtime type
    report .= "Timestamp: " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "`r`n" ; timestamp current snapshot
    report .= "WinMM slots responding: " slots.Count "`r`n" ; count active legacy joystick slots
    report .= "DirectInput devices enumerated: " directInput.Length "`r`n" ; count attached DirectInput controllers
    if diError != "" {
        report .= "DirectInput note: " diError "`r`n" ; include failure reason
    } ; end DirectInput note
    report .= "`r`nMapping policy: DirectInput JOYSTICKID -> WinMM slot -> AHK nJoy.`r`n" ; state the mapping chain
    report .= "A DirectInput LIST ORDER is NEVER assumed to equal an AHK SLOT.`r`n" ; avoid accidental misidentification

    Loop 16 { ; print discovered slots in their actual 1Joy through 16Joy order
        slot := A_Index ; get the one-based AutoHotkey joystick slot

        if !slots.Has(slot) { ; missing or unreadable joystick slot
            continue
        } ; end unpopulated slot guard

        info := slots[slot] ; retrieve WinMM metadata for this slot
        matches := [] ; collect DirectInput identities explicitly mapped to the same slot
        
        for device in directInput { ; scan DirectInput results without relying on enumeration order
            if device.joyIdAvailable && device.joyId + 1 = slot { ; DIPROP_JOYSTICKID is zero based
                matches.Push(device) ; store the authoritative slot-linked device
            } ; end explicit joystick-ID match
        } ; end DirectInput correlation
        report .= "`r`n--- AHK SLOT " slot " (" slot "Joy...) ---`r`n" ; usable AutoHotkey prefix
        report .= "AHK JoyName: " DisplayIdentity(info.ahkName) "`r`n" ; original generic name
        report .= "WinMM product name: " DisplayIdentity(info.driverName) "`r`n" ; joystick API name
        report .= "WinMM maker/product: " info.legacyIds "`r`n" ; WinMM manufacturer/product codes
        report .= "WinMM axes/buttons: " info.axes " / " info.buttons "`r`n" ; basic input capability evidence
        report .= "WinMM registry key: " DisplayIdentity(info.regKey) "`r`n" ; registry lookup root
        report .= "OEM registry identifier: " DisplayIdentity(info.oemKey) "`r`n" ; OEM key when available
        report .= "OEM registry name: " DisplayIdentity(info.oemName) "`r`n" ; readable manufacturer name
        if matches.Length = 1 { ; one verified DirectInput identity for this legacy slot
            item := matches[1] ; load unique DirectInput match
            report .= "IDENTITY: DIRECTINPUT SLOT-MATCHED`r`n" ; strong linked result
            report .= "DirectInput product: " DisplayIdentity(item.productName) "`r`n"
            report .= "DirectInput instance: " DisplayIdentity(item.instanceName) "`r`n"
            report .= "DirectInput GUID: " item.instanceGuidText "`r`n"
            report .= "Product GUID: " item.productGuidText "`r`n"
            report .= "DirectInput VID/PID: " item.vidPidText "`r`n"
            report .= "Device interface path: " DisplayIdentity(item.path) "`r`n" ; stable-ish PnP path if supported
        } else if matches.Length > 1 { ; duplicate ID claims
            report .= "IDENTITY: AMBIGUOUS - " matches.Length " DirectInput devices claim slot " slot "`r`n" ; reject duplicate matches
            for item in matches { ; show candidates for troubleshooting
                report .= "  Candidate: " DisplayIdentity(item.productName) " | " item.instanceGuidText "`r`n" ; include unique GUID for each
            } ; end candidate listing
        } else if info.oemName != "" { ; DirectInput did not provide a slot-linked identity
            report .= "IDENTITY: OEM REGISTRY FALLBACK (VERIFY WITH DEVICE INPUT)`r`n"
            report .= "Likely name: " info.oemName "`r`n" ; supported OEM name without claiming unique identity
        } else { ; no identity source established a device name
            report .= "IDENTITY: UNRESOLVED - DO NOT AUTO-ASSIGN THIS SLOT`r`n"
        } ; end slot identity result
    } ; end slot report loop

    report .= "`r`n--- DIRECTINPUT DEVICES WITHOUT A VERIFIED AHK SLOT ---`r`n" ; separate devices with no proven slot mapping
    unresolvedCount := 0
    for item in directInput {
        mapped := false ; assume unmapped until a live WinMM slot agrees

        if item.joyIdAvailable && slots.Has(item.joyId + 1) { ; real corresponding slot exists
            mapped := true ; mapping can be represented in the main report
        } ; end active-slot match

        if !mapped { ; unresolved devices visible for diagnosis
            unresolvedCount++
            report .= "  " DisplayIdentity(item.productName) " | " item.instanceGuidText "`r`n"
            report .= "  JOYSTICKID: " item.joyIdText " | VID/PID: " item.vidPidText "`r`n"
            report .= "  Interface path: " DisplayIdentity(item.path) "`r`n"
        } ; end unresolved device
    } ; end unmatched devices

    if unresolvedCount = 0 {
        report .= "  None.`r`n" ; all reported DirectInput devices had an active matching slot
    } ; end empty unmatched listing

    report .= "`r`nIMPORTANT NOTES`r`n"
    report .= "- Product name is not a unique serial number; identical models can share it.`r`n" ; duplicates
    report .= "- HID/virtual devices may not support DIPROP_JOYSTICKID or path.`r`n" ; partial data
    report .= "- DirectInput GUID/path may change after replugging or driver updates.`r`n" ; persistence
    return report ; copyable text string
} ; end report builder

ReadWinMMSlots() {
    slots := Map()
    Loop 16 { ; AutoHotkey supports numbered Joy1 through Joy16 devices
        slot := A_Index
        joyId := slot - 1 ; WinMM joystick identifiers are zero based
        caps := Buffer(728, 0) ; allocate exact JOYCAPSW (wide char) structure size
        status := DllCall("winmm\joyGetDevCapsW", "UPtr", joyId, "Ptr", caps.Ptr, "UInt", caps.Size, "UInt") ; read driver capabilities

        if status != 0 { ; zero means joy capabilities returned successfully
            continue ; skip invalid or unsupported slots
        } ; end failed capability read

        state := Buffer(52, 0) ; allocate JOYINFOEX for a connected-device probe
        NumPut("UInt", 52, state, 0) ; WinMM state structure size
        NumPut("UInt", 0xFF, state, 4) ; all available axes, buttons and POV
        stateStatus := DllCall("winmm\joyGetPosEx", "UInt", joyId, "Ptr", state.Ptr, "UInt") ; slot responds?

        if stateStatus != 0 { ; installed but disconnected devices can have stale caps
            continue
        } ; end active device guard

        name := "" ; default AHK JoyName to unknown
        try { ; controller names can be missing for some drivers
            name := Trim(GetKeyState(slot "JoyName"))
        } catch { ; WinMM diagnostics if AHK cannot provide a name
            name := "" ; unavailable name
        } ; end AHK name read

        maker := NumGet(caps, 0, "UShort") ; WinMM manufacturer identifier
        product := NumGet(caps, 2, "UShort") ; WinMM product identifier
        driverName := StrGet(caps.Ptr + 4, "UTF-16") ; Unicode WinMM product string
        regKey := StrGet(caps.Ptr + 144, "UTF-16") ; WinMM registry subkey
        regIdentity := ReadSlotOEMIdentity(slot, regKey, maker, product) ; slot-associated OEM identity
        slots[slot] := {slot: slot, ahkName: name, driverName: driverName,
            legacyIds: Format("MID=0x{:04X}, PID=0x{:04X}", maker, product),
            axes: NumGet(caps, 136, "UInt"), buttons: NumGet(caps, 92, "UInt"),
            regKey: regKey, oemKey: regIdentity.key, oemName: regIdentity.name} ; WinMM metadata for this slot
    } ; end active slots loop
    return slots ; return WinMM/AHK slot associations
} ; end legacy enumeration

ReadSlotOEMIdentity(slot, regKey, maker, product) {
    result := { key: "", name: "" }

    if regKey != "" && !InStr(regKey, "\") { ; restrict the driver-supplied name to one registry subkey
        currentKey := "HKCU\System\CurrentControlSet\Control\MediaResources\Joystick\" regKey "\CurrentJoystickSettings" ; WinMM per-slot settings
        try { ; this value is optional and may not exist for virtual devices
            result.key := Trim(RegRead(currentKey, "Joystick" slot "OEMName")) ; slot-specific OEM reference
        } catch { ; absence is normal on some installations
            result.key := "" ; reference unassigned
        } ; end slot registry lookup
    } ; end registry-name guard

    if result.key = "" && (maker != 0 || product != 0) { ; MID/PID only as a fallback
        result.key := Format("VID_{:04X}&PID_{:04X}", maker, product) ; product in OEM registry
    } ; end code-derived OEM key

    if result.key != "" && !InStr(result.key, "\") { ; block paths or malformed values from being interpreted as registry roots
        locations := ["HKCU\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\", "HKLM\SYSTEM\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM\"] ; user and system OEM names
        for root in locations { ; search only known Windows OEM controller-key locations
            try { ; registry keys may be absent or inaccessible without elevation
                found := Trim(RegRead(root result.key, "OEMName")) ; descriptive product name

                if found != "" { ; first nonempty OEM description
                    result.name := found ; source-linked OEM identity
                    break ; successful lookup
                } ; end successful name lookup

            } catch {
                continue ; inspect the next legitimate registry location
            } ; end registry name attempt
        } ; end OEM registry search
    } ; end key lookup guard
    return result ; return both the reference and readable name
} ; end OEM name resolution

ReadDirectInputDevices(&statusMessage) { ; enumerate attached DirectInput devices and query their WinMM joystick IDs
    statusMessage := ""
    entries := [] ; Windows DirectInput enumeration results
    iid := Buffer(16, 0) ; IID_IDirectInput8W GUID structure
    parseResult := DllCall("ole32\CLSIDFromString", "WStr", "{BF798031-483A-4DA2-AA99-5D64ED369700}", "Ptr", iid.Ptr, "Int") ; DirectInput8W IID

    if parseResult != 0 { ; malformed IID
        statusMessage := "Could not initialize the DirectInput interface IID."
        return entries ; legacy fallback
    } ; end IID guard

    hInstance := DllCall("kernel32\GetModuleHandleW", "Ptr", 0, "Ptr") ; current process module
    di := 0 ; output DirectInput COM interface pointer
    initResult := DllCall("dinput8\DirectInput8Create", "Ptr", hInstance, "UInt", 0x0800, "Ptr", iid.Ptr, "Ptr*", &di, "Ptr", 0, "Int") ; DirectInput8W COM interface

    if initResult < 0 || di = 0 { ; Windows may not support DirectInput or initialization may fail
        statusMessage := "DirectInput8Create failed: " Format("0x{:08X}", initResult & 0xFFFFFFFF) ; HRESULT
        return entries
    } ; end creation guard

    callback := 0 ; callback pointer for guaranteed cleanup
    try { ; ensure both callback and COM interface are released
        rawDevices := [] ; copied device descriptions from enumeration callback
        callback := CallbackCreate(CaptureDInputDevice.Bind(rawDevices), , 2) ; callback with DIDEVICEINSTANCE pointer and context
        enumResult := DllCall(VTableFunction(di, 4), "Ptr", di, "UInt", 4, "Ptr", callback, "Ptr", 0, "UInt", 1, "Int") ; enumerate attached game controllers only

        if enumResult < 0 {
            statusMessage := "EnumDevices failed: " Format("0x{:08X}", enumResult & 0xFFFFFFFF) ; HRESULT
            return entries ; gathered WinMM metadata
        } ; end enumeration guard

        for item in rawDevices { ; resolve properties for each attached DirectInput instance
            device := 0 ; reset output device pointer
            hr := DllCall(VTableFunction(di, 3), "Ptr", di, "Ptr", item.instanceGuidBuffer.Ptr, "Ptr*", &device, "Ptr", 0, "Int") ; create this DirectInput device interface

            if hr < 0 || device = 0 { ; skip device objects DirectInput cannot open
                item.joyIdAvailable := false
                item.joyIdText := "unavailable (CreateDevice failed)"
                item.vidPidText := "unavailable"
                item.path := "" ; no device interface path was read
                entries.Push(item) ; descriptive device names visible
                continue
            } ; end interface creation guard

            try { ; ensure temporary device interface is always freed
                idResult := ReadDInputDWORDProperty(device, 15, &idValue) ; DIPROP_JOYSTICKID (WinMM index)
                item.joyIdAvailable := (idResult = 0 && idValue >= 0 && idValue <= 15) ; known valid indices
                item.joyId := item.joyIdAvailable ? idValue : -1 ; zero-based joystick ID only if valid

                if item.joyIdAvailable {
                    item.joyIdText := idValue " (AHK " (idValue + 1) "Joy)" ; translate to one-based input prefix
                } else { ; unsupported or out-of-range joystick identifier
                    item.joyIdText := "unsupported / invalid (" Format("0x{:08X}", idResult & 0xFFFFFFFF) ")" ; HRESULT
                } ; end joystick-ID display

                pidResult := ReadDInputDWORDProperty(device, 24, &vidPid) ; DIPROP_VIDPID if available

                if pidResult = 0 && vidPid != 0 { ; use only an available nonzero VID/PID property
                    item.vidPidText := Format("VID_{:04X}&PID_{:04X}", vidPid & 0xFFFF, (vidPid >> 16) & 0xFFFF) ; decode GUID property DWORD
                } else { ; some virtual drivers don't support VID/PID
                    item.vidPidText := "unavailable"
                } ; end VID/PID result

                item.path := ReadDInputInterfacePath(device) ; PnP interface path
            } finally { ; release DirectInput device after reading its properties
                ObjRelease(device) ; release one COM reference
            } ; end per-device cleanup
            entries.Push(item) ; append complete product and mapped slot identity
        } ; end DirectInput instance loop
    } catch Error as err {
        statusMessage := "DirectInput query error: " err.Message " (line " err.Line ")"
    } finally { ; release the callback and root COM object even when enumeration fails

        if callback != 0 { ; callback allocation succeeded
            CallbackFree(callback) ; free executable AutoHotkey callback memory
        } ; end callback cleanup

        ObjRelease(di) ; release IDirectInput8W interface
    } ; end protected DirectInput session
    return entries ; return all devices with available identity information
} ; end DirectInput discovery

CaptureDInputDevice(entries, infoPtr, contextPtr) { ; copy one enumerated DIDEVICEINSTANCEW from a native callback
    try { ; errors must not cross the C-to-AutoHotkey callback boundary
        instanceGUID := Buffer(16, 0) ; allocate self-owned copy of the instance GUID
        productGUID := Buffer(16, 0) ; allocate self-owned copy of the product GUID

        Loop 4 { ; GUIDs contain exactly four DWORDs
            offset := (A_Index - 1) * 4 ; calculate current GUID DWORD offset
            NumPut("UInt", NumGet(infoPtr + 4 + offset, "UInt"), instanceGUID, offset) ; copy instance GUID DWORD
            NumPut("UInt", NumGet(infoPtr + 20 + offset, "UInt"), productGUID, offset) ; copy product GUID DWORD
        } ; end GUID copy

        instanceName := StrGet(infoPtr + 40, "UTF-16") ; read Windows DirectInput instance name
        productName := StrGet(infoPtr + 560, "UTF-16") ; read Windows DirectInput product name
        entries.Push({instanceGuidBuffer: instanceGUID, productGuidBuffer: productGUID,
            instanceGuidText: FormatGUID(instanceGUID), productGuidText: FormatGUID(productGUID),
            instanceName: instanceName, productName: productName,
            joyIdAvailable: false, joyId: -1, joyIdText: "not queried",
            vidPidText: "not queried", path: ""}) ; store copied DirectInput identities, initialized to unmapped
    } catch { ; name or GUID is unavailable
        return 0
    } ; end native callback protection
    return 1 ; DIENUM_CONTINUE: continue listing attached controllers
} ; end callback

ReadDInputDWORDProperty(device, propertyNumber, &value) { ; query a DirectInput property with a DWORD result
    value := -1 ; initialize an invalid output to prevent stale reads
    data := Buffer(20, 0) ; reserve a DIPROPDWORD: 16-byte header and DWORD data
    NumPut("UInt", 20, data, 0) ; set DIPROPHEADER.dwSize to the complete buffer size
    NumPut("UInt", 16, data, 4) ; set DIPROPHEADER.dwHeaderSize
    NumPut("UInt", 0, data, 8) ; set dwObj = 0 for device-wide property
    NumPut("UInt", 0, data, 12) ; select DIPH_DEVICE for a whole-device property
    result := DllCall(VTableFunction(device, 5), "Ptr", device, "Ptr", propertyNumber, "Ptr", data.Ptr, "Int") ; read DirectInput property by ID

    if result = 0 { ; device supports the requested property
        value := NumGet(data, 16, "UInt") ; 32-bit property value
    } ; end successful query

    return result ; HRESULT for diagnostic decisions
} ; end DWORD property query

ReadDInputInterfacePath(device) { ; optional device-interface path for stronger identification
    pathData := Buffer(552, 0) ; DIPROPGUIDANDPATH = header16 + GUID16 + WCHAR[MAX_PATH]520
    NumPut("UInt", pathData.Size, pathData, 0) ; full structure size
    NumPut("UInt", 16, pathData, 4) ; DIPROPHEADER size
    NumPut("UInt", 0, pathData, 8) ; zero object index
    NumPut("UInt", 0, pathData, 12) ; DIPH_DEVICE
    hr := DllCall(VTableFunction(device, 5), "Ptr", device, "Ptr", 12, "Ptr", pathData.Ptr, "Int") ; read DIPROP_GUIDANDPATH for the HID interface path
    return (hr = 0) ? StrGet(pathData.Ptr + 32, "UTF-16") : "" ; return supported path
} ; end interface path reader

FormatGUID(guid) { ; stringify a copied Windows GUID
    output := Buffer(80, 0) ; enough UTF-16 storage for a braced GUID
    count := DllCall("ole32\StringFromGUID2", "Ptr", guid.Ptr, "Ptr", output.Ptr, "Int", 40, "Int") ; format the Windows GUID
    return count > 0 ? StrGet(output.Ptr, "UTF-16") : "unavailable" ; corrupt identifiers
} ; end GUID formatting

VTableFunction(interfacePtr, methodIndex) { ; locate an explicitly documented COM method by index
    vtable := NumGet(interfacePtr, "Ptr") ; load the COM object's method table
    return NumGet(vtable + methodIndex * A_PtrSize, "Ptr") ; native method pointer
} ; end COM function pointer lookup

DisplayIdentity(value) { ; missing optional identity fields
    return Trim(value) != "" ? value : "(not available)"
} ; end missing-field formatting
