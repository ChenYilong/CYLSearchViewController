---
name: cyl-harmonyos-setup
description: "Prepare DevEco Studio and the HarmonyOS emulator for harmonyos/: IDE installation, SDK paths, emulator prerequisites (virtualization, Huawei ID, region set to China in country.region.xml), creating the Mate 70 Pro API 21 emulator."
---

# HarmonyOS IDE and emulator setup

Use this skill before the first HarmonyOS build or run on a machine, and whenever the Device Manager offers no local
emulator. Versions: HarmonyOS NEXT 6.0.1 (API 21), DevEco Studio 6.0.1 (`AGENTS.md`, "HarmonyOS: API and example
1:1 with iOS"). Full rule: `AGENTS.md`, "HarmonyOS: IDE preparation and emulator prerequisites".

## 1. IDE preparation

1. Install DevEco Studio 6.0.1 (it bundles the HarmonyOS SDK API 21, hvigor, ohpm, the JBR and `hdc`). Default
   Windows location: `C:\Program Files\Huawei\DevEco Studio` (the machine checked on 2026-11-16 has build
   `DS-243.24978.46.36.601251`).
2. Before the first launch, or with DevEco Studio closed, set the region to China (section 3). The region decides
   which services the IDE offers, including the local emulator.
3. Launch DevEco Studio, accept the SDK licenses and sign in with a Huawei ID (top right, or
   File > Settings > Huawei ID). Downloading emulator images needs the sign-in.
4. Command-line builds need these variables (PowerShell syntax):

   ```powershell
   $env:DEVECO_SDK_HOME = 'C:\Program Files\Huawei\DevEco Studio\sdk'
   $env:PATH = 'C:\Program Files\Huawei\DevEco Studio\jbr\bin;' +
     'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains;' + $env:PATH
   ```

   `hdc.exe` lives in `sdk\default\openharmony\toolchains`.
5. hvigor rejects a project path with spaces or non-ASCII characters. This repository lives under
   `C:\Users\Chen Yilong\OneDrive - AUT University\Documents\GitHub\…` (ASCII since 2026-11-17, when the folder
   `文档` was renamed `Documents`, but still with spaces), so mirror `harmonyos/` to an ASCII path without spaces (for example
   `C:\cylbuild\harmonyos`), then open that folder in DevEco Studio or run
   `hvigorw assembleHap --mode module -p module=entry@default -p product=default` there.
6. Run `ohpm install` in the project root (DevEco Studio does it on Sync) before the first build.

## 2. Emulator prerequisites

All of them must hold, or the Device Manager shows no local emulator or the emulator does not start.

| Prerequisite | How to check | How to fix |
| :--- | :--- | :--- |
| 64-bit Windows 10 or 11 (or a Mac with Apple silicon) | `winver` | Use a supported host |
| CPU virtualization (Intel VT-x or AMD-V) enabled in the BIOS or UEFI | Task Manager > Performance > CPU: "Virtualization: Enabled" | Enable it in the firmware settings |
| Windows features Hyper-V, Windows Hypervisor Platform and Virtual Machine Platform on | `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` prints `True` | Administrator PowerShell: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All,HypervisorPlatform,VirtualMachinePlatform -All`, then restart |
| Enough memory and disk: 16 GB RAM at least (32 GB or more recommended), tens of GB free for the SDK and the system image | Task Manager | Free memory or disk space |
| Signed in to DevEco Studio with a Huawei ID | Avatar at the top right | Sign in |
| Region set to China (`CN`) | Section 3 | Section 3 |
| Device Manager privacy statement accepted | `deviceManager.xml` has `isConfirmPrivacyStatement` `true` | Accept it the first time the Device Manager opens |

When a hypervisor is running, `Win32_Processor.VirtualizationFirmwareEnabled` reports `False`. That is expected:
check `HypervisorPresent` instead. The machine checked on 2026-11-16 has `HypervisorPresent = True` and 64 GB RAM.

## 3. Region: China in country.region.xml

The developer is in New Zealand, and the region chosen at the first launch was `NZ`. DevEco Studio offers the local
emulator only when the region is China, so the region must be `CN`. Editing the file is the reliable way to change
it after the first launch:

- Windows: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`
- macOS: `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`

Steps:

1. Close DevEco Studio. It can write its settings back on exit and undo the edit.
2. Back up the file (this machine keeps the original as `country.region.xml.bak-NZ`).
3. Make sure the file has exactly this content:

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

4. Check it. Each command must print the `CN` line:

   ```powershell
   Select-String -Path "$env:APPDATA\Huawei\DevEcoStudio6.0\options\country.region.xml" -Pattern '<countryregion name="CN"/>'
   ```

   ```sh
   grep '<countryregion name="CN"/>' "$APPDATA/Huawei/DevEcoStudio6.0/options/country.region.xml"
   ```

5. Start DevEco Studio and check again. If the value went back to another region, the IDE was still running
   during the edit: repeat from step 1.

Status on this machine (checked 2026-11-16): the file says `<countryregion name="CN"/>`.

## 4. Create and start the emulator

1. Tools > Device Manager > Local Emulator > New Emulator.
2. Choose the phone Mate 70 Pro with HarmonyOS 6.0.1 (API 21) and download the system image (`phone_all_x86` on
   Windows). Images go to `%LOCALAPPDATA%\Huawei\Sdk\system-image`, emulator instances to
   `%LOCALAPPDATA%\Huawei\Emulator\deployed`. A download in progress leaves a lock in
   `%LOCALAPPDATA%\Huawei\Sdk\.temp`. Let it finish; do not delete the lock while DevEco Studio runs.
3. Start the emulator, then check it with `hdc list targets` (it prints a device such as `127.0.0.1:5555`).
4. Install and run: `hdc install <path>\entry-default-unsigned.hap`, or Run in DevEco Studio. Run the hypium tests
   from DevEco Studio or with the test HAP.

### No signing for the emulator (rule, 2026-11-16)

Emulator runs and tests need no signing. Keep `signingConfigs` empty in `harmonyos/build-profile.json5`, ignore the
hvigor note "If needed, configure the signingConfigs", and install the unsigned HAPs directly:

```powershell
$hdc = 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe'
& $hdc install -r C:\cylbuild\harmonyos\entry\build\default\outputs\default\entry-default-unsigned.hap
& $hdc install -r C:\cylbuild\harmonyos\entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap
& $hdc shell aa test -b com.cyl.search.harmonyos -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 15000
```

Do not ask for a signing certificate, a profile or automatic signing before an emulator run. Signing is needed only
for a real device or a release, and is out of scope until the user asks for it.

## Troubleshooting

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Device Manager has no Local Emulator tab, or no images to download | Region is not `CN`, or not signed in | Section 3, then sign in |
| Region goes back to `NZ` | DevEco Studio was running during the edit | Close it, edit again, check |
| Emulator fails to start: virtualization or Hyper-V error | Virtualization or Windows features off | Section 2, then restart |
| `hdc list targets` prints `[Empty]` | Emulator not booted, or a second `hdc` server from another SDK | Wait for the home screen; run `hdc kill`, then `hdc start` from the DevEco toolchains folder |
| hvigor: path error | Spaces or non-ASCII characters in the project path | Mirror to an ASCII path (section 1, step 5) |
| `DEVECO_SDK_HOME` error | Variable not set in this shell | Section 1, step 4 |

Report the host OS version, DevEco Studio build, emulator model, and HarmonyOS version and API level with every
HarmonyOS run or screenshot (`AGENTS.md`, "Screenshots of builds and CI/CD").
