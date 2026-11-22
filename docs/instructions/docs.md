# Documentation, screenshots and parity tables (tag: `docs`)

Details of the `docs` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## API parity tables (added 2026-11-17)

- A parity table compares two platforms (or two libraries). Column 1: an API or feature of the source; column 2: what
  it does; column 3: the counterpart on the target, `TODO` by default.
- Score: (rows whose column 3 is not `TODO`) / rows × 100. No `TODO` in column 3 is 100; all `TODO` is 0.
- Loop until 100: (1) search the existing code to match each `TODO` row with its counterpart; (2) score; (3) resolve
  the remaining `TODO` rows one by one, each becoming the name of its implementation; (4) score again; repeat.
- Implement in the core first (rule "Fix issues in the core first"), then use the example to show the usage, copying
  the source platform's example. Keep the logic and the API names the same on both platforms.
- When one direction reaches 100, make the reverse table the same way.
- Tables: [docs/ios-api-alignment.md](../ios-api-alignment.md) (Android core → iOS),
  [docs/android-api-alignment.md](../android-api-alignment.md) (iOS → Android). Skill: `cyl-api-parity`.

## API parity tables (added 2026-11-17) (instructions.md wording)

- Compare two platforms with a table: column 1 an API or feature, column 2 its description, column 3 the counterpart
  (`TODO` by default). Score = rows not `TODO` / rows × 100 (no `TODO` = 100, all `TODO` = 0).
- Search the code to match `TODO` rows, score, resolve the rest one by one (core first, then the example), score, and
  repeat until 100; then make the reverse table. Full rule: `AGENTS.md`, "API parity tables"; skill `cyl-api-parity`.

## Screenshots of builds and CI/CD

- **Where they go.** Every screenshot, local build and run screenshots and CI/CD screenshots alike (a GitHub Actions
  run, a job log, an artifact), is committed to this repository and shown in the related document in `docs/`, with
  the image in `docs/assets/` and the shortest relative link. When no document fits, create one.
- **Clear originals.** Use the original pixels (`xcrun simctl io <device> screenshot`, an emulator's own capture,
  a full-resolution browser capture); crop to the detail, never scale below the original size.
- **Labels.** Next to every screenshot (its caption or table row) write:
  - the platform: iOS, Android, Flutter, React Native, HarmonyOS or mini program;
  - the environment: the host OS version and build, the simulator or emulator (device and OS version), and the
    platform SDK version (Xcode and iOS SDK; Android SDK and API level; Flutter SDK; React Native; HarmonyOS SDK and
    API version; the mini program base library);
  - this repository's version number or commit link;
  - the date and time it was taken, with the time zone.
- **Key milestones.** Take and publish screenshots at key milestones: when a `TODO` or `Linux` note can be removed,
  when a pull request can be merged, or when the result works as expected with no known bug and no open issue.
- **README.** At such a milestone, when the result is as expected, update the screenshot section of `README.md`
  (create it if missing) with the latest images and the labels above. Show the key details, cropped; capture the
  full screen only when it is needed. Combine several details into one stitched image
  (`scripts/stitch-screenshots.swift`), laid out in this order of preference:
  1. stacked top to bottom, one image per row (easiest to read on a phone);
  2. two columns over several rows;
  3. one horizontal row of at most three images.

  Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

### Stitched screenshots: layout, header and footer (added 2026-11-18)

- Prompt, verbatim: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。 更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行"
- Prompt, English: stitched screenshots are vertical; they get a header and a footer that never overlap or cover the
  screenshots, with the key information in English (platform, simulator and its OS version, host OS version, IDE
  version, purpose of the test, and so on), in the style of the example the user attached. Prefer one column over
  several rows; when that column is taller than one screen of an ordinary phone, use two columns over several rows.
- **Layout** (replaces the order of preference above):
  1. one column, several rows, stacked top to bottom;
  2. when that one column would be taller than one phone screen, two columns over several rows (left to right, then
     top to bottom). One phone screen is the height of one full screenshot of the device under test (for example
     2622 px for an iPhone 17 Pro or iPhone 18 Pro simulator, 2400 px for a 1080 x 2400 Android phone); for crops of
     the full screen width, the script uses the cell width x 19.5 / 9;
  3. never one horizontal row of more than three images.
- **Header**: a band of its own above every screenshot, never drawn on a screenshot. Bold, red (#FF3B30) on white,
  English, one or two lines:
  1. the platform and the OS version of the simulator or emulator (iOS 27.2, Android API 37, HarmonyOS API 21, WeChat
     base library 3.6.6) and the device ("iPhone 18 Pro sim", "Medium Phone emulator", "Mate 70 Pro emulator");
  2. the IDE or SDK version (Xcode 27.2 (27B52), Android Studio and Android SDK, Flutter 3.47.9, React Native,
     DevEco Studio, WeChat DevTools);
  3. the host OS version (macOS 27.3, Windows 11) when it matters for the result;
  4. the code under test: the library and its commit (CYLTabBarController dcbfdec6), this repository's commit, the
     branch;
  5. the date (and time with its time zone when several runs are compared);
  6. the purpose: what the image proves, in a few words ("Rive tags at rest (no play)").
  Example, from the user's image: "iOS 27.2, iPhone 17 Pro sim, Xcode 27.2, CYLTabBarController dcbfdec6 (ef1d0313),
  feat/harmony, 2026-11-18. Rive tags at rest (no play)".
  The image: [docs/assets/screenshot-style-example-ios27.2-rive-tags-20261118.png](../assets/screenshot-style-example-ios27.2-rive-tags-20261118.png).
- **Captions**: every panel has a short caption in its own band right above it, bold red: the state or the step and
  its timing ("launch, no play"), with a measured result when there is one ("11 s later, 0 changed pixels").
- **Footer**: a band of its own below every screenshot, bold dark gray: the result or verdict (pass / fail, bug
  number), and what is not in the header but needed to reproduce (file names, launch arguments, the test or command).
- **Never overlap**: the header, the captions and the footer never cover any pixel of a screenshot; screenshots keep
  their original pixels (cropped, never enlarged); everything written on the image is English.
- **Tool**: `swift scripts/stitch-screenshots.swift --header "<line 1>\n<line 2>" --footer "<result>" --out
  docs/assets/<name>.png "<shot 1>.png=<caption 1>" "<shot 2>.png=<caption 2>"`. `--columns auto` (the default)
  applies the layout rule; `--screen-height <px>` sets one screen when the images are not full-width crops.

### Screenshot labels are enforced (added 2026-11-18)

User's request (2026-11-18): "检查为什么没有应用新增的截图Label规范，并强化该策略保证以后截图必须遵循该规范，避免再出现该问题。"
(find out why the new screenshot label rule was not applied, and make every future screenshot follow it).

Why it was missed (2026-11-17/18, the Windows session): the header and footer rule landed mid-session from another
session and nothing made the session re-read it; the older "Labels" rule was applied only in part (platform, device,
pins, but no host OS, SDK or IDE version, time zone); the only tool ran on macOS; and nothing checked a screenshot
before it was committed. So, from now on:

- **Every screenshot, not only stitched ones.** Every image committed to `docs/assets` goes through a stitching tool
  with `--header` and `--footer` (one image is a one-panel stitch). The raw capture may be kept in `docs/assets/raw/`
  as the tool's input; documents link the labelled PNG.
- **A tool on every host.** macOS: `swift scripts/stitch-screenshots.swift`; Windows:
  `powershell -ExecutionPolicy Bypass -File scripts/stitch-screenshots.ps1 -Header "..." -Footer "..." -Out
  docs/assets/<name>.png "<shot>.png=<caption>"` (same layout and look). Both require a header and a footer and write
  them into the PNG as its "Description" text (`CYL header: ... | CYL footer: ...`).
- **The check.** `sh scripts/check-screenshot-labels.sh` (staged images) or `... BASE HEAD` fails when an added
  `docs/assets` image is not a PNG, has no header and footer, is shown by no Markdown file, or the line that shows it
  has no date (YYYY-MM-DD) and commit. Run it before every commit that adds an image (commit readiness); CI runs it
  on every pull request and push that touches `docs/assets` (`.github/workflows/screenshot-labels.yml`).
- **The label line in the document**: on the same line as the image link, the platform, device and OS version,
  SDK / IDE version, host OS, the library commits, the date with time and time zone.
- **Rules change mid-session.** At the start of each task, pull and read what changed in the rules since the session
  began (`git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills`), and apply it to the task.
- **Scoring.** A task with an unlabelled screenshot cannot pass (`cyl-task-start`).

## Screenshots of builds and CI/CD (instructions.md wording)

- Commit every screenshot (local builds and runs, CI/CD runs) and show it in the related `docs/` document (images in
  `docs/assets/`; create a document when none fits). Use clear original pixels, cropped to the detail.
- Label each one with the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program), the environment
  (host OS version, simulator or emulator and its OS version, platform SDK version), this repository's version or
  commit link, and the date and time with the time zone.
- At key milestones (a `TODO` or `Linux` note can be removed, a PR can be merged, the result works with no known
  bug or open issue), update the screenshot section of `README.md` (create it if missing) with cropped key details
  stitched into one image: stacked top to bottom first, then two columns, then one row of at most three.
- Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.
- Full rule: `AGENTS.md`, "Screenshots of builds and CI/CD".
- Enforced (added 2026-11-18): every image committed to `docs/assets` (not only stitched ones) is made with
  `swift scripts/stitch-screenshots.swift` (macOS) or `scripts/stitch-screenshots.ps1` (Windows) with a header and a
  footer; the document line that links it carries the label (platform, device and OS, SDK / IDE, host OS, commits,
  date with time zone). `sh scripts/check-screenshot-labels.sh` must pass before every commit that adds an image; CI
  runs it too. Re-read rules changed since the session began at each task start. Full rule: `AGENTS.md`, "Screenshot
  labels are enforced".
- Stitched screenshots (added 2026-11-18, replaces the order above): one column over several rows; two columns over
  several rows when one column would be taller than one phone screen (one full screenshot of the device). A header
  above and a footer below, in bands of their own that never cover a screenshot, bold, English: header (red) with the
  platform, simulator or emulator and its OS version, IDE or SDK version, host OS when it matters, library and
  repository commits, branch, date, and the purpose; a red caption above each panel (state, timing, measured result);
  footer (dark gray) with the result and what is needed to reproduce. Example: "iOS 27.2, iPhone 17 Pro sim, Xcode
  27.2, CYLTabBarController dcbfdec6 (ef1d0313), feat/harmony, 2026-11-18. Rive tags at rest (no play)". Tool:
  `swift scripts/stitch-screenshots.swift --header ... --footer ... --out OUT.png IN.png=caption ...`. Full rule:
  `AGENTS.md`, "Stitched screenshots: layout, header and footer".

## Open pull requests and issues of projects we translate

When a document of this project links to another project's GitHub repository (not this project) because its code
is translated, ported or merged into ours (for example the Kotlin transcriptions in `android/`), the work covers
that project's open pull requests and open issues, not only its default branch. The same rule applies on every
platform (iOS, Android, Flutter, React Native, HarmonyOS, mini programs).

1. **Open pull requests.**
   - Translation not started yet: merge the project's open pull requests into the code you translate first.
   - Translation already done: translate each open pull request's changes separately and merge them into our
     translated code.
2. **Open issues table.** In the related `docs/` document (create one when none fits), list every open issue of
   that project in a table: first column the issue link, second column the issue description, third column the fix
   status, `TODO` by default. Record the date the list was read.
3. **Fix them in our code.** For each issue, find its counterpart in our code and try to fix it there; set the
   status to `DONE` with the commit (or `N/A` with the reason when the issue does not apply to our code, for example
   a feature we do not have).
4. **Score.** Score = issues `DONE` or `N/A` / all listed issues × 100. Score again after every fixed issue and
   continue until 100.
5. **Order.** When the translation has not started: merge the open pull requests, then work on the open issues;
   start translating once the issue score reaches 60; after translating, fix the remaining issues until 100. When
   the translation is done: translate and merge the open pull requests, then fix the issues on the translated code
   until 100.

## Open pull requests and issues of projects we translate (instructions.md wording)

- When a document links to another project's GitHub repository whose code we translate or port (for example
  `android/`), also take its open pull requests: merge them before translating, or translate and merge them when
  the translation is already done.
- List that project's open issues in a `docs/` table (issue link, description, fix status `TODO`), fix each one in
  our code (`DONE` with the commit, or `N/A` with the reason), and score after every fix until 100. A translation
  that has not started begins once the issue score reaches 60. Every platform follows this rule.
- Full rule: `AGENTS.md`, "Open pull requests and issues of projects we translate".
