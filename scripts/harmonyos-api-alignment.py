#!/usr/bin/env python3
"""Builds the iOS-to-HarmonyOS API table (docs/harmonyos-api-alignment.md, between the generated markers).

One row per public declaration of Sources/CYLSearchViewController/*.swift, parsed as for the Android table
(android/merged/scripts/api-alignment.py): the iOS API, its doc comment, and the HarmonyOS counterpart. The third
column is TODO by default; it is kept from the current document, so replace a row's TODO with the HarmonyOS API (or
`N/A: <reason>`) when it is implemented and run this script again. Score: rows not TODO / rows x 100.

Usage: python3 scripts/harmonyos-api-alignment.py [--check]
"""
import importlib.util, os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DOC = os.path.join(ROOT, 'docs', 'harmonyos-api-alignment.md')
BEGIN, END = '<!-- harmonyos-api-alignment:begin -->', '<!-- harmonyos-api-alignment:end -->'

spec = importlib.util.spec_from_file_location('android_alignment', os.path.join(ROOT, 'android', 'merged', 'scripts', 'api-alignment.py'))
android = importlib.util.module_from_spec(spec)
spec.loader.exec_module(android)


def label(owner, swift, kind):
    if kind in ('class', 'protocol', 'enum'):
        return f'**{kind} `{owner}`**'
    return f'`{swift}`' if kind == 'case' else f'`{owner}.{swift}`'


def existing(doc):
    # The third column of rows already in the document, by their first column.
    kept = {}
    for line in doc.split('\n'):
        cells = [c.strip() for c in re.split(r'(?<!\\)\|', line)[1:-1]]
        if len(cells) == 3 and cells[0] not in ('iOS public API', ':---'):
            kept[cells[0]] = cells[2]
    return kept


def main():
    doc = open(DOC, encoding='utf-8').read()
    kept = existing(doc)
    table = ['| iOS public API | Doc comment | HarmonyOS |', '| :--- | :--- | :--- |']
    done = total = 0
    for owner, swift, kind, comment, _ in android.parse_swift():
        first = label(owner, swift, kind)
        note = re.sub(r'\s+', ' ', comment).replace('|', '\\|').strip() or '—'
        if len(note) > 240:
            note = note[:237].rstrip() + '…'
        third = kept.get(first, 'TODO')
        total += 1
        done += third != 'TODO'
        table.append(f'| {first} | {note} | {third} |')
    score = done * 100 // total if total else 0
    summary = f'Rows: {total}; implemented or N/A {done}, TODO {total - done}; score {score}/100.'
    block = BEGIN + '\n' + summary + '\n\n' + '\n'.join(table) + '\n' + END
    doc = re.sub(re.escape(BEGIN) + '.*?' + re.escape(END), lambda _: block, doc, flags=re.S)
    if '--check' not in sys.argv:
        open(DOC, 'w', encoding='utf-8').write(doc)
    print(summary)


if __name__ == '__main__':
    main()
