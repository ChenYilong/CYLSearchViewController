#!/usr/bin/env python3
"""Copies the core strings of the Android library into the HarmonyOS library's resources.

android/merged/cylsearch/src/main/res/values[-<lang>]/cyl_search_strings.xml -> harmonyos/cylsearch/src/main/resources/
<qualifier>/element/string.json, for the keys the core uses (cyl_search_*, cyl_placeholder_*, cyl_multisearch_*), so
every platform shows the same texts. Run: python3 harmonyos/scripts/import-android-strings.py
"""
import json, os, re
from xml.sax.saxutils import unescape

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
RES = os.path.join(ROOT, 'android', 'merged', 'cylsearch', 'src', 'main', 'res')
OUT = os.path.join(ROOT, 'harmonyos', 'cylsearch', 'src', 'main', 'resources')
QUALIFIERS = {'values': 'base', 'values-b+zh+Hans': 'zh_CN', 'values-b+zh+Hant': 'zh_TW', 'values-ja': 'ja_JP'}
PREFIXES = ('cyl_search_', 'cyl_placeholder_', 'cyl_multisearch_')


def main():
    for folder, qualifier in QUALIFIERS.items():
        text = open(os.path.join(RES, folder, 'cyl_search_strings.xml'), encoding='utf-8').read()
        strings = []
        for name, value in re.findall(r'<string name="([^"]+)"[^>]*>(.*?)</string>', text, re.S):
            if name.startswith(PREFIXES):
                value = unescape(value).replace("\\'", "'").replace('\\"', '"')
                value = re.sub(r'%(\d+\$)?s', lambda m: '%' + (m.group(1) or '') + 's', value)
                strings.append({'name': name, 'value': value})
        target = os.path.join(OUT, qualifier, 'element')
        os.makedirs(target, exist_ok=True)
        with open(os.path.join(target, 'string.json'), 'w', encoding='utf-8') as f:
            json.dump({'string': strings}, f, ensure_ascii=False, indent=2)
            f.write('\n')
        print(qualifier, len(strings))


if __name__ == '__main__':
    main()
