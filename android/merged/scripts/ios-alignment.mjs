#!/usr/bin/env node
// Builds the Android-core-to-iOS table (docs/ios-api-alignment.md, between the generated markers).
//
// Rows: every public Kotlin declaration (classes, interfaces, objects, enum entries, functions, properties) of
//   A. this project's Android core, android/merged/cylsearch (com.cyl.search);
//   B. CollectionViewClassifyMenu's Android library (com.cyl.classifymenu), the tag views the search uses, from the
//      pinned checkout android/merged/.cyl-deps/CollectionViewClassifyMenu.
// Column 3, the iOS counterpart, is found (1) in docs/android-api-alignment.md (the iOS-to-Android table, read in
// reverse), (2) as a declaration of the same name in the iOS sources (Sources/CYLSearchBar for A,
// CollectionViewClassifyMenu's Class folder for B), (3) for B, in the sub-repository's own generated Android-to-iOS
// table (its docs/android-ios-api.md, 100/100 there), or (4) in MANUAL below; otherwise it is TODO.
// Score = rows not TODO / rows x 100 (rule "API parity tables", AGENTS.md).
//
// Usage: node android/merged/scripts/ios-alignment.mjs [--check]
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const DOC = join(ROOT, 'docs', 'ios-api-alignment.md');
const REVERSE = join(ROOT, 'docs', 'android-api-alignment.md');
const BEGIN = '<!-- ios-alignment:begin -->';
const END = '<!-- ios-alignment:end -->';
const MENU = join(ROOT, 'android', 'merged', '.cyl-deps', 'CollectionViewClassifyMenu');
// The commit of the CollectionViewClassifyMenu checkout the table was measured against (it may differ from the pin).
let MENU_COMMIT = 'unknown commit';
try {
  MENU_COMMIT = execFileSync('git', ['-C', MENU, 'log', '-1', '--format=%h %cs'], { encoding: 'utf8' }).trim();
} catch { /* no checkout */ }

const SECTIONS = [
  {
    title: 'A. CYLSearchViewController: `android/merged/cylsearch` → `Sources/CYLSearchBar`',
    kotlin: join(ROOT, 'android', 'merged', 'cylsearch', 'src', 'main', 'kotlin', 'com', 'cyl', 'search'),
    ios: [join(ROOT, 'Sources', 'CYLSearchBar')],
  },
  {
    title: `B. CollectionViewClassifyMenu (tag views): \`com.cyl.classifymenu\` → its iOS library (measured at \`${MENU_COMMIT}\`)`,
    kotlin: join(MENU, 'android', 'merged', 'library', 'src', 'main', 'java', 'com', 'cyl', 'classifymenu'),
    ios: [join(MENU, 'CollectionViewClassifyMenu', 'Class'), join(MENU, 'TagCollectionView', 'TagCollectionView')],
    table: join(MENU, 'docs', 'android-ios-api.md'),
  },
];

// Counterparts with another name or shape, found by reading both sides: "Kotlin row key" -> "iOS counterpart".
// A. Android stand-ins for UIKit types map to the UIKit type the iOS API takes; B. Swift names of the tag library.
const MANUAL = {
  // A. CYLSearchViewController
  'CYLMultiSearchView.fontSize': '`CYLMultiSearchView.font` (`UIFont.pointSize`)',
  'CYLSearchBarView.fontSize': '`CYLSearchBarView.font` (`UIFont.pointSize`)',
  CYLSearchBarItemState: '`UIControl.State` (`CYLSearchBarItem.setTitleTextAttributes(_:for:)`; Android stand-in)',
  'CYLSearchBarItemState.Normal': '`UIControl.State.normal`',
  'CYLSearchBarItemState.Selected': '`UIControl.State.selected`',
  'CYLSearchBarItemState.Disabled': '`UIControl.State.disabled`',
  CYLSearchBarItemTextAttributes: '`[NSAttributedString.Key: Any]` (`CYLSearchBarItem.setTitleTextAttributes(_:for:)`, `setBadgeTextAttributes(_:for:)`; Android stand-in)',
  CYLTextAutocapitalizationType: '`UITextAutocapitalizationType` (`CYLSearchBarView.autocapitalizationType`, `CYLMultiSearchView.autocapitalizationType`; Android stand-in)',
  'CYLTextAutocapitalizationType.None': '`UITextAutocapitalizationType.none`',
  'CYLTextAutocapitalizationType.Words': '`UITextAutocapitalizationType.words`',
  'CYLTextAutocapitalizationType.Sentences': '`UITextAutocapitalizationType.sentences`',
  'CYLTextAutocapitalizationType.AllCharacters': '`UITextAutocapitalizationType.allCharacters`',
  CYLTextAutocorrectionType: '`UITextAutocorrectionType` (`CYLSearchBarView.autocorrectionType`; Android stand-in)',
  'CYLTextAutocorrectionType.Default': '`UITextAutocorrectionType.default`',
  'CYLTextAutocorrectionType.No': '`UITextAutocorrectionType.no`',
  'CYLTextAutocorrectionType.Yes': '`UITextAutocorrectionType.yes`',
  CYLLineBreakMode: '`NSLineBreakMode` (`CYLSearchView.suggestionLineBreakMode`; Android stand-in)',
  'CYLLineBreakMode.WordWrapping': '`NSLineBreakMode.byWordWrapping`',
  'CYLLineBreakMode.CharWrapping': '`NSLineBreakMode.byCharWrapping`',
  'CYLLineBreakMode.Clipping': '`NSLineBreakMode.byClipping`',
  'CYLLineBreakMode.TruncatingHead': '`NSLineBreakMode.byTruncatingHead`',
  'CYLLineBreakMode.TruncatingTail': '`NSLineBreakMode.byTruncatingTail`',
  'CYLLineBreakMode.TruncatingMiddle': '`NSLineBreakMode.byTruncatingMiddle`',
  CYLSearchSuggestionCell: 'the `CYLSearchView` suggestion row: a `UITableViewCell` (reuse identifier `CYLSearchSuggestionCell`) with a `UIListContentConfiguration` (icon and text)',
  // Name matching found CYLSearchPlaceholderView's imageView / textLabel; iOS has no suggestion cell class.
  'CYLSearchSuggestionCell.imageView': 'the suggestion row\'s `UIListContentConfiguration.image` (`CYLSearchView.suggestionImage`)',
  'CYLSearchSuggestionCell.textLabel': 'the suggestion row\'s `UIListContentConfiguration.text` (the suggestion)',
  'CYLSearchView.pageBackgroundColor': '`CYLSearchView.backgroundColor` (the page background; the view itself only shows the scrim)',
  // B. CollectionViewClassifyMenu: Swift names of the Objective-C selectors the Android API mirrors
  Kind: '`CYLMenuIconDrawable.Kind` → the bundle images `cyl_fold_chevron` (CHEVRON_DOWN), `cyl_tag_plus` (PLUS), `cyl_more` (ELLIPSIS)',
  'CYLTag.styleWithBaseStyle': '`CYLTag.style(basedOn:)`',
  'CYLTagColors.styleByApplyingToStyle': '`CYLTagColors.styleByApplying(to:)`',
  'CYLTagListView.addTagsWithTitles': '`CYLTagListView.addTags(withTitles:)`',
  'CYLTagListView.removeTagAtIndex': '`CYLTagListView.removeTag(at:)`',
  'CYLTagListView.deleteItemAtIndexPath': '`CYLTagListView.deleteItem(at:)`',
  'CYLTagListView.tagButtonAtIndexPath': '`CYLTagListView.tagButton(at:)`',
  'CYLTagListView.reordering': '`CYLTagListView.isReordering`',
  'CYLTagListView.setTagsWithTitles': '`CYLTagListView.setTags(withTitles:colors:)`',
  'CYLTagListView.addTagWithTitle': '`CYLTagListView.addTag(withTitle:)`',
  'CYLTagListView.insertTagWithTitle': '`CYLTagListView.insertTag(withTitle:at:)`',
  'CYLTagListView.removeTagsAtIndexes': '`CYLTagListView.removeTags(at:)`',
  'CYLTagListView.toggleSelectionOfItemAtIndexPath': '`CYLTagListView.toggleSelection(at:)`',
  'CYLTagListView.selectItemAtIndexPath': '`CYLTagListView.selectItem(at:)`',
  'CYLTagListView.deselectItemAtIndexPath': '`CYLTagListView.deselectItem(at:)`',
  'CYLTagListView.numberOfRowsInSection': '`CYLTagListView.numberOfRows(inSection:)`',
  'CYLTagListView.numberOfVisibleItemsInSection': '`CYLTagListView.numberOfVisibleItems(inSection:)`',
  'CYLTagListView.scrollToSection': '`CYLTagListView.scroll(toSection:animated:)`',
  'CYLTagListView.scrollToItemAtIndexPath': '`CYLTagListView.scrollToItem(at:animated:)`',
  'CYLMenuConfigurationException.domain': '`CYLMenuConfigurationError.errorDomain` (`"CYLMenuConfigurationErrorDomain"`)',
  tagListViewWithConfigurationFile: '`CYLTagListView(configurationFile:)` (`throws`)',
  // B. Objective-C globals that the sub-repository's Swift migration turned into Swift members (its own table still
  // names the Objective-C ones, which no longer exist at the measured commit).
  CYLMenuColorFromString: '`UIColor.cylMenuColor(from:)`',
  CYLMenuLocalizedStringForKey: '`CYLMenuLocalizedString(_:)`',
  CYLMenuImage: '`CYLMenuResources.image(named:)`',
  CYLScaledSystemFont: '`CYLTagMetrics.scaledSystemFont(ofSize:traitCollection:)`',
  CYLTagHeightForFont: '`CYLTagMetrics.tagHeight(for:minimumHeight:)`',
  CYLTagTitleFontForTraitCollection: '`CYLTagMetrics.titleFont(for:)`',
  CYLMenuAnimationURLWithOptions: '`URL.cylAddingAnimationOptions(_:)`',
  'CYLTagGroup.firstRowCount': '`CYLTagGroup.cellCountsPerRow.first` (computed on iOS, stored on Android)',
  'CYLFilterParamsTool.filterParamsArray': '`CYLMultipleFilterController.selectedIndexPaths()` / `setSelectedIndexPaths(_:)` (index paths instead of flags)',
};

function files(dir, exts) {
  if (!existsSync(dir)) return [];
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...files(p, exts));
    else if (exts.some((e) => name.endsWith(e))) out.push(p);
  }
  return out.sort();
}

// The first sentence of the KDoc right above line i.
function kdoc(lines, i) {
  let j = i - 1;
  while (j >= 0 && /^\s*@/.test(lines[j])) j--; // annotations
  if (j < 0 || !/\*\/\s*$/.test(lines[j])) return '';
  const end = j;
  while (j >= 0 && !/\/\*\*/.test(lines[j])) j--;
  if (j < 0) return '';
  const text = lines.slice(j, end + 1).join(' ')
    .replace(/\/\*\*|\*\//g, ' ').replace(/^\s*\*\s?/gm, ' ').replace(/\s+\*\s/g, ' ')
    .replace(/\[(EN|CN)\]/g, ' ').replace(/\s+/g, ' ').trim();
  const sentence = (text.match(/^.*?[.。](\s|$)/) || [text])[0].trim();
  return sentence.replace(/\|/g, '\\|').slice(0, 180);
}

const MODIFIERS = /\b(private|internal|protected)\b/;
const DECL = /^(\s*)((?:@\w+(?:\([^)]*\))?\s+)*)((?:(?:public|open|abstract|final|data|enum|sealed|inline|value|annotation|inner|lateinit|const|operator|infix|suspend|override|companion|fun)\s+)*)(class|interface|object|fun|var|val)\s+(?:<[^>]+>\s+)?(?:([\w.]+)\.)?(`?\w+`?)/;

function kotlinRows(dir) {
  const rows = [];
  for (const file of files(dir, ['.kt'])) {
    const lines = readFileSync(file, 'utf8').replace(/\r\n/g, '\n').split('\n');
    const stack = []; // { name, depth, kind, private }
    let depth = 0;
    let inComment = false;
    let pendingEnum = null;
    lines.forEach((raw, i) => {
      let line = raw;
      if (inComment) { if (line.includes('*/')) { inComment = false; line = line.slice(line.indexOf('*/') + 2); } else return; }
      if (/^\s*\/\*/.test(line) && !line.includes('*/')) { inComment = true; return; }
      if (/^\s*(\/\/|\*)/.test(line)) return;
      const owner = stack.length ? stack[stack.length - 1] : null;
      const hidden = stack.some((s) => s.private);
      // Enum entries: the first lines of an enum class body, NAME, NAME(args) or NAME { … }.
      if (owner && owner.kind === 'enum' && depth === owner.depth + 1 && owner.entries) {
        const entries = line.replace(/\/\/.*$/, '').trim();
        if (/^[A-Za-z_]\w*(\s*\([^)]*\))?\s*[,;]?\s*(,\s*[A-Za-z_]\w*(\s*\([^)]*\))?\s*)*[,;]?$/.test(entries) && entries.length) {
          for (const m of entries.matchAll(/([A-Za-z_]\w*)(\s*\([^)]*\))?/g)) {
            if (!hidden) rows.push({ key: `${owner.name}.${m[1]}`, kind: 'case', name: m[1], owner: owner.name, desc: kdoc(lines, i) });
          }
          if (entries.endsWith(';')) owner.entries = false;
        } else if (entries.length) {
          owner.entries = false;
        }
      }
      const m = DECL.exec(line);
      if (m && depth === (owner ? owner.depth + 1 : 0)) {
        const mods = m[3] || '';
        const kind = m[4];
        const name = m[6].replace(/`/g, '');
        const isPrivate = MODIFIERS.test(line.slice(0, line.indexOf(kind)));
        const isOverride = /\boverride\b/.test(mods);
        if (kind === 'class' || kind === 'interface' || kind === 'object') {
          const isEnum = /\benum\b/.test(mods);
          const isCompanion = /\bcompanion\b/.test(mods);
          const label = isCompanion ? (owner ? owner.name : name) : name;
          if (!isPrivate && !hidden && !isCompanion) {
            rows.push({ key: name, kind: isEnum ? 'enum' : kind, name, owner: owner ? owner.name : '', desc: kdoc(lines, i), type: true });
          }
          pendingEnum = { name: label, kind: isEnum ? 'enum' : kind, private: isPrivate, entries: isEnum };
        } else if (!isPrivate && !isOverride && !hidden && owner) {
          rows.push({ key: `${owner.name}.${name}`, kind, name, owner: owner.name, desc: kdoc(lines, i) });
        } else if (!isPrivate && !isOverride && !hidden && !owner && kind === 'fun') {
          rows.push({ key: name, kind, name, owner: '', desc: kdoc(lines, i) });
        }
      }
      for (const ch of line.replace(/"(?:\\.|[^"\\])*"/g, '""').replace(/'(?:\\.|[^'\\])'/g, "''").replace(/\/\/.*$/, '')) {
        if (ch === '{') {
          depth++;
          if (pendingEnum) { stack.push({ ...pendingEnum, depth: depth - 1 }); pendingEnum = null; }
        } else if (ch === '}') {
          depth--;
          if (stack.length && stack[stack.length - 1].depth === depth) stack.pop();
        }
      }
      if (pendingEnum && !/[({]\s*$/.test(line) && !line.includes('(') && !line.trim().endsWith(',')) pendingEnum = null;
    });
  }
  // One row per key (overloads share a row).
  const seen = new Map();
  for (const r of rows) if (!seen.has(r.key)) seen.set(r.key, r);
  return [...seen.values()];
}

// Kotlin "Class.member" -> iOS API, read from the iOS-to-Android table.
function reverseMap() {
  const map = new Map();
  if (!existsSync(REVERSE)) return map;
  for (const line of readFileSync(REVERSE, 'utf8').split(/\r?\n/)) {
    const c = line.split(' | ');
    if (c.length < 4 || !line.startsWith('| ') || c[3].trim() === 'Android (`cylsearch`)') continue;
    const ios = c[0].slice(2).trim();
    for (const k of c[2].matchAll(/`([\w.]+)/g)) {
      if (!map.has(k[1])) map.set(k[1], ios);
    }
    const plain = c[2].trim();
    if (/^\w+$/.test(plain) && !map.has(plain)) map.set(plain, ios);
  }
  return map;
}

// Kotlin "Class.member" -> iOS API, read from a sub-repository's own Android-to-iOS table
// (rows "| `Android API` | description | iOS API |"; TODO rows are skipped).
function tableMap(path) {
  const map = new Map();
  if (!path || !existsSync(path)) return map;
  for (const line of readFileSync(path, 'utf8').split(/\r?\n/)) {
    const m = /^\| `([\w.]+)` \| .*? \| (.+) \|$/.exec(line);
    if (!m || m[2].trim() === 'TODO') continue;
    if (!map.has(m[1])) map.set(m[1], m[2].trim());
  }
  return map;
}

function iosIndex(dirs) {
  const text = dirs.flatMap((d) => files(d, ['.swift', '.h'])).filter((f) => !/Tests?\b|Demo|Example/i.test(f))
    .map((f) => readFileSync(f, 'utf8')).join('\n');
  return text;
}

function iosMatch(row, index) {
  const n = row.name;
  const esc = n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const patterns = row.type
    ? [new RegExp(`(class|struct|enum|protocol|@interface|@protocol|typedef NS_(?:ENUM|OPTIONS)\\(\\w+,)\\s*${esc}\\b`)]
    : row.kind === 'case'
      ? [new RegExp(`\\bcase\\s+${esc}\\b`), new RegExp(`\\bcase\\s+${esc[0].toLowerCase()}${esc.slice(1)}\\b`), new RegExp(`\\b${row.owner}${esc[0].toUpperCase()}${esc.slice(1)}\\b`), new RegExp(`\\b${esc}\\b\\s*[,=]`)]
      : [
        new RegExp(`(func|var|let)\\s+${esc}\\b`),
        new RegExp(`@property[^;]*\\b${esc}\\s*;`),
        new RegExp(`@property[^;]*getter=${esc}\\b`),
        new RegExp(`^[-+]\\s*\\([^)]*\\)\\s*${esc}\\b`, 'm'),
      ];
  for (const p of patterns) if (p.test(index)) return row.type ? n : (row.owner ? `${row.owner}.${n}` : n);
  return null;
}

// A bare name taken from a sub-repository's table must exist in the iOS sources it was measured against: that table
// can lag behind its own Swift migration (renamed or removed Objective-C names). Prose cells and UIKit / Foundation /
// Core Graphics names pass; a name is found as declared, in its Swift spelling (`isX`, a lowercased enum case), as an
// `@objc(name)` selector, or as the Objective-C name of a Swift enum case (`CYLFooBar` for case `bar` of `CYLFoo`).
function existsInIOS(ios, index) {
  if (!/^[\w.]+$/.test(ios)) return true;
  if (/^(UI|NS|CG|CA)[A-Z]/.test(ios)) return true;
  const esc = (x) => x.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const declared = (n) => new RegExp(`\\b(class|struct|enum|protocol|extension|typealias|func|var|let|case|@interface|@protocol)\\s+${esc(n)}\\b|@objc\\(${esc(n)}[:)]|NS_(?:ENUM|OPTIONS)\\(\\w+,\\s*${esc(n)}\\)`).test(index);
  const [owner, member] = ios.includes('.') ? ios.split('.', 2) : [null, ios];
  if (owner && !declared(owner)) return false;
  const m = member;
  if (declared(m) || declared(m[0].toLowerCase() + m.slice(1)) || declared(`is${m[0].toUpperCase()}${m.slice(1)}`)) return true;
  // Objective-C name of a Swift enum case: an enum name that prefixes it, then the case.
  for (const e of index.matchAll(/\benum\s+(CYL\w+)/g)) {
    if (m.startsWith(e[1]) && m.length > e[1].length) {
      const rest = m.slice(e[1].length);
      if (declared(rest[0].toLowerCase() + rest.slice(1))) return true;
    }
  }
  return false;
}

function build() {
  const reverse = reverseMap();
  const unverified = [];
  let total = 0;
  let matched = 0;
  const parts = [];
  for (const section of SECTIONS) {
    const rows = kotlinRows(section.kotlin);
    const index = iosIndex(section.ios);
    const table = tableMap(section.table);
    let ok = 0;
    const body = rows.map((r) => {
  const fromTable = table.get(r.key);
      const tableOk = fromTable !== undefined && existsInIOS(fromTable.replace(/^`|`$/g, ''), index);
      if (fromTable !== undefined && !tableOk && MANUAL[r.key] === undefined) unverified.push(`${r.key} -> ${fromTable}`);
      const ios = MANUAL[r.key] ?? (tableOk ? fromTable : undefined) ?? reverse.get(r.key) ?? (r.type ? reverse.get(r.name) : undefined) ?? iosMatch(r, index);
      if (ios) ok++;
      const label = r.type ? `**${r.kind} \`${r.name}\`**` : `\`${r.key}\``;
      const iosCell = ios ? (/^[\w.():]+$/.test(ios) ? `\`${ios}\`` : ios) : 'TODO'; // only a bare name gets backticks
      return `| ${label} | ${r.desc || '—'} | ${iosCell} |`;
    });
    total += rows.length;
    matched += ok;
    parts.push(`### ${section.title}\n\nRows: ${rows.length}; matched ${ok}, TODO ${rows.length - ok}; score ${rows.length ? Math.floor(ok / rows.length * 100) : 100}/100.\n\n| Android API or feature | Description | iOS counterpart |\n| :--- | :--- | :--- |\n${body.join('\n')}\n`);
  }
  const score = total ? Math.floor(matched / total * 100) : 100;
  const head = `Rows: ${total}; matched ${matched}, TODO ${total - matched}; score ${score}/100 (generated by \`android/merged/scripts/ios-alignment.mjs\`).\n`;
  if (unverified.length) console.error(`Not found in the iOS sources (sub-repository table entries dropped):\n  ${unverified.join('\n  ')}`);
  return { text: `${BEGIN}\n${head}\n${parts.join('\n')}${END}`, score, total, matched };
}

const { text, score, total, matched } = build();
let doc = readFileSync(DOC, 'utf8').replace(/\r\n/g, '\n');
if (doc.includes(BEGIN)) {
  doc = doc.slice(0, doc.indexOf(BEGIN)) + text + doc.slice(doc.indexOf(END) + END.length);
} else {
  doc = `${doc.trimEnd()}\n\n## Table\n\n${text}\n`;
}
if (process.argv.includes('--check')) {
  const current = readFileSync(DOC, 'utf8').replace(/\r\n/g, '\n');
  if (current !== doc) { console.error('docs/ios-api-alignment.md is out of date: run the script'); process.exit(1); }
} else {
  writeFileSync(DOC, doc);
}
console.log(`rows ${total}, matched ${matched}, score ${score}/100`);
