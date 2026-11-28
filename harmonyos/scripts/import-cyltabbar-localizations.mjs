// Copies the translations of CYLTabBarController's string table into the HarmonyOS resources, keeping only the
// texts this project uses (user, 2026-11-16: "本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。").
//
// CYLTabBarController keys its table by the English text (CYLTabBarController.bundle/<lang>.lproj/
// CYLTabBarController.strings). A string of ours is kept when its English text (base/element/string.json) is the
// English text of an entry there; its translations go to <module>/src/main/resources/<language>/element/string.json.
// The four languages curated from iOS (en, ja, zh-Hans, zh-Hant) are never overwritten.
//
// Usage: node harmonyos/scripts/import-cyltabbar-localizations.mjs [path to CYLTabBarController]
//        (default: the sibling folder ../CYLTabBarController)
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repository = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const tabBar = process.argv[2] ?? join(repository, '..', 'CYLTabBarController');
const bundle = join(tabBar, 'CYLTabBarController', 'Resources', 'CYLTabBarController.bundle');
const modules = ['cylsearch', 'entry'];
const curated = new Set(['en', 'ja', 'zh-Hans', 'zh-Hant']);

if (!existsSync(bundle)) {
  console.error(`No CYLTabBarController string table at ${bundle}`);
  process.exit(1);
}

function table(language) {
  const text = readFileSync(join(bundle, `${language}.lproj`, 'CYLTabBarController.strings'), 'utf8');
  const map = new Map();
  for (const m of text.matchAll(/^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";/gm)) {
    map.set(m[1], m[2].replace(/\\"/g, '"').replace(/\\n/g, '\n'));
  }
  return map;
}

// The HarmonyOS qualifier of an iOS language: the language code, a region after an underscore (pt-BR -> pt_BR).
const qualifier = (language) => language.replace('-', '_');

const english = table('en');
const keyOfEnglish = new Map();
for (const [key, value] of english) {
  keyOfEnglish.set(value, key);
}
const languages = readdirSync(bundle)
  .filter((name) => name.endsWith('.lproj'))
  .map((name) => name.slice(0, -'.lproj'.length))
  .filter((language) => !curated.has(language))
  .sort();

let written = 0;
for (const module of modules) {
  const resources = join(repository, 'harmonyos', module, 'src', 'main', 'resources');
  const ours = JSON.parse(readFileSync(join(resources, 'base', 'element', 'string.json'), 'utf8')).string;
  const used = ours.filter((item) => keyOfEnglish.has(item.value));
  console.log(`${module}: ${used.length} of ${ours.length} strings are in CYLTabBarController's table: ` +
    used.map((item) => `${item.name} ("${item.value}")`).join(', '));
  for (const language of languages) {
    const translations = table(language);
    const items = [];
    for (const item of used) {
      const value = translations.get(keyOfEnglish.get(item.value));
      if (value !== undefined && value.length > 0) {
        items.push({ name: item.name, value });
      }
    }
    if (items.length === 0) {
      continue;
    }
    const folder = join(resources, qualifier(language), 'element');
    mkdirSync(folder, { recursive: true });
    writeFileSync(join(folder, 'string.json'), JSON.stringify({ string: items }, null, 2) + '\n');
    written++;
  }
}
console.log(`${languages.length} languages; ${written} string.json files written`);
