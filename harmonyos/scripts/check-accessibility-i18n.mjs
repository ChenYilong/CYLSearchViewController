// Checks the HarmonyOS library for screen-reader and localization gaps, without an emulator.
//   1. No English text written in the library's UI code: Text(...), .accessibilityText(...),
//      .accessibilityDescription(...) and string defaults of titles and labels take a resource.
//   2. Every element with .onClick has a screen-reader label: .accessibilityText, a Text child, or a group label
//      within the 30 lines before it.
//   3. Every $r('app.string.<name>') used by the library or the example exists in base and in the four languages
//      curated from iOS (ja_JP, zh_CN, zh_TW; base is English).
// Usage: node harmonyos/scripts/check-accessibility-i18n.mjs   (exit code 1 when a problem is found)
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const harmonyos = join(dirname(fileURLToPath(import.meta.url)), '..');
const library = join(harmonyos, 'cylsearch', 'src', 'main');
const example = join(harmonyos, 'entry', 'src', 'main');
const curated = ['base', 'ja_JP', 'zh_CN', 'zh_TW'];
const problems = [];

function etsFiles(folder) {
  const files = [];
  for (const entry of readdirSync(folder, { withFileTypes: true })) {
    const path = join(folder, entry.name);
    if (entry.isDirectory()) {
      files.push(...etsFiles(path));
    } else if (entry.name.endsWith('.ets')) {
      files.push(path);
    }
  }
  return files;
}

function names(module, qualifier) {
  const path = join(module, 'resources', qualifier, 'element', 'string.json');
  return existsSync(path) ? new Set(JSON.parse(readFileSync(path, 'utf8')).string.map((s) => s.name)) : new Set();
}

// 1 and 2: the library's UI code.
const literal = /(?:\bText|\.accessibilityText|\.accessibilityDescription)\(\s*(?:[^)]*\?\s*)?'([^']*[A-Za-z][^']*)'/;
const titleDefault = /(?:Title|Label|title|label)\s*:\s*string\s*=\s*'([^']*[A-Za-z][^']*)'/;
let clicks = 0;
// The whole HarmonyOS code: the library and the example (AGENTS.md, "HarmonyOS: screen readers and localization").
for (const file of [...etsFiles(join(library, 'ets')), ...etsFiles(join(example, 'ets'))]) {
  const lines = readFileSync(file, 'utf8').split('\n');
  const short = file.slice(harmonyos.length + 1).replaceAll('\\', '/');
  lines.forEach((line, i) => {
    if (/^\s*(\*|\/\/)/.test(line)) {
      return;
    }
    const text = literal.exec(line) ?? titleDefault.exec(line);
    if (text) {
      problems.push(`${short}:${i + 1}: English text "${text[1]}" in the UI; use a string resource`);
    }
    if (line.includes('.onClick(')) {
      clicks++;
      const before = lines.slice(Math.max(0, i - 30), i).join('\n');
      if (!/accessibilityText|\bText\(/.test(before)) {
        problems.push(`${short}:${i + 1}: a tappable element with no screen-reader label`);
      }
    }
  });
}

// 3: the string resources used in code exist in every curated language.
const libraryNames = curated.map((q) => names(library, q));
const exampleNames = curated.map((q) => names(example, q));
let used = 0;
for (const [folder, own] of [[library, libraryNames], [example, exampleNames]]) {
  for (const file of etsFiles(join(folder, 'ets'))) {
    const short = file.slice(harmonyos.length + 1).replaceAll('\\', '/');
    for (const m of readFileSync(file, 'utf8').matchAll(/\$r\('app\.string\.([A-Za-z0-9_]+)'\)/g)) {
      used++;
      curated.forEach((qualifier, i) => {
        // The example can use the library's strings: a HAR's resources are merged into the app.
        if (!own[i].has(m[1]) && !libraryNames[i].has(m[1])) {
          problems.push(`${short}: app.string.${m[1]} missing in ${qualifier}`);
        }
      });
    }
  }
}

for (const problem of problems) {
  console.log(problem);
}
console.log(`tappable elements ${clicks}, string resources used ${used}: ${problems.length} problem(s)`);
process.exit(problems.length === 0 ? 0 : 1);
