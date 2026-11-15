// Checks, without an emulator, that the HarmonyOS resources are a 1:1 copy of the iOS ones (AGENTS.md, "HarmonyOS:
// API and example 1:1 with iOS"): every iOS string in en, ja, zh-Hans and zh-Hant, with the same text, and every
// placeholder image. The names follow harmonyos/scripts/import-ios-resources.py.
// Usage: node harmonyos/scripts/check-ios-parity.mjs   (exit code 1 when something is missing or different)
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const bundle = join(root, 'Resources', 'CYLSearchViewController.bundle');
const example = join(root, 'CYLSearchExample');
const library = join(root, 'harmonyos', 'cylsearch', 'src', 'main', 'resources');
const app = join(root, 'harmonyos', 'entry', 'src', 'main', 'resources');
const languages = { en: 'base', ja: 'ja_JP', 'zh-Hans': 'zh_CN', 'zh-Hant': 'zh_TW' };

function iosStrings(path) {
  const text = readFileSync(path, 'utf8').replace(/^﻿/, '');
  const pairs = [];
  for (const m of text.matchAll(/^"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";/gm)) {
    pairs.push([m[1], m[2].replace(/\\"/g, '"').replace(/\\n/g, '\n')]);
  }
  return pairs;
}

function harmonyStrings(path) {
  const map = new Map();
  if (!existsSync(path)) {
    return map;
  }
  for (const item of JSON.parse(readFileSync(path, 'utf8')).string) {
    map.set(item.name, item.value);
  }
  return map;
}

const problems = [];
let checked = 0;

// iOS format specifiers in HarmonyOS form, as the import does: %@ -> %s, %ld / %lu / %u -> %d (positions kept).
function harmonyFormat(value) {
  return value.replace(/%(\d+\$)?@/g, (_, p) => `%${p ?? ''}s`)
    .replace(/%(\d+\$)?l{0,2}[du]/g, (_, p) => `%${p ?? ''}d`);
}

function compare(pairs, target, nameOf, where) {
  for (const [key, iosValue] of pairs) {
    const value = harmonyFormat(iosValue);
    checked++;
    const name = nameOf(key);
    if (!target.has(name)) {
      problems.push(`${where}: missing ${name} (iOS "${key}")`);
    } else if (target.get(name) !== value) {
      problems.push(`${where}: ${name} is "${target.get(name)}", iOS "${key}" is "${value}"`);
    }
  }
}

for (const [ios, harmony] of Object.entries(languages)) {
  const lib = harmonyStrings(join(library, harmony, 'element', 'string.json'));
  compare(iosStrings(join(bundle, `${ios}.lproj`, 'CYLSearchViewController.strings')), lib,
    (key) => 'cyl_' + key.replaceAll('.', '_'), `cylsearch/${harmony}`);
  const entry = harmonyStrings(join(app, harmony, 'element', 'string.json'));
  for (const name of ['CYLSearchTabs', 'CYLSearchDiscover']) {
    compare(iosStrings(join(example, `${name}.bundle`, `${ios}.lproj`, `${name}.strings`)), entry,
      (key) => key.replaceAll('.', '_'), `entry/${harmony}`);
  }
}

const snake = (name) => name.replace(/(?<!^)(?=[A-Z])/g, '_').toLowerCase();
const images = new Set();
for (const file of readdirSync(bundle)) {
  const m = /^CYLSearch(\w+?)(@2x)?\.png$/.exec(file);
  if (m) {
    images.add(`cyl_search_${snake(m[1])}.png`);
  }
}
for (const image of images) {
  checked++;
  if (!existsSync(join(library, 'base', 'media', image))) {
    problems.push(`cylsearch/base/media: missing ${image}`);
  }
}

for (const problem of problems) {
  console.log(problem);
}
console.log(`checked ${checked}: ${checked - problems.length} match, ${problems.length} problem(s)`);
process.exit(problems.length === 0 ? 0 : 1);
