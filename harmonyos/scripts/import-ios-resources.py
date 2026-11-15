#!/usr/bin/env python3
"""Copies the iOS resources into the HarmonyOS library and example, so HarmonyOS shows the same texts, images and data.

- Resources/CYLSearchViewController.bundle/<lang>.lproj/CYLSearchViewController.strings -> cylsearch string.json
  (`search.cancel` -> `cyl_search_cancel`, the name CYLSearchResources.localizedString reads); existing names are kept.
- The placeholder images (CYLSearch<Name>[@2x].png) -> cylsearch media `cyl_search_<name>.png`.
- CYLSearchExample/CYLSearchTabs.bundle and CYLSearchDiscover.bundle strings -> entry string.json (`tab.search` ->
  `tab_search`); search-discover.json -> entry rawfile `discover/<qualifier>.json`; discover-hot.png -> entry media.
Formats: `%@` -> `%s`, `%ld` / `%lu` -> `%d` (positional `%1$lu` -> `%1$d`).
Run: python3 harmonyos/scripts/import-ios-resources.py
"""
import json, os, re, shutil

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
BUNDLE = os.path.join(ROOT, 'Resources', 'CYLSearchViewController.bundle')
EXAMPLE = os.path.join(ROOT, 'CYLSearchExample')
LIB = os.path.join(ROOT, 'harmonyos', 'cylsearch', 'src', 'main', 'resources')
ENTRY = os.path.join(ROOT, 'harmonyos', 'entry', 'src', 'main', 'resources')
LANGS = {'en': 'base', 'ja': 'ja_JP', 'zh-Hans': 'zh_CN', 'zh-Hant': 'zh_TW'}
# CYLTableViewPlaceHolder's CYLRefreshNormalHeader texts (its CYLRefresh.bundle; the mini program's cyl-refresh locales),
# for the example's pull to refresh: idle, pulling, refreshing, last update, today, no record.
REFRESH = {
    'en': ['Pull down to refresh', 'Release to refresh', 'Loading...', 'Last update: ', 'Today', 'No record'],
    'ja': ['下に引っ張って更新', '離すと更新', '更新中...', '最終更新：', '今日', '記録なし'],
    'zh-Hans': ['下拉可以刷新', '松开立即刷新', '正在刷新数据中...', '最后更新：', '今天', '无记录'],
    'zh-Hant': ['下拉可以刷新', '鬆開立即刷新', '正在刷新數據中...', '最後更新：', '今天', '無記錄'],
}
# The microphone permission reason of the Voice sample (iOS NSSpeechRecognitionUsageDescription / NSMicrophoneUsageDescription).
MICROPHONE = {'en': 'Turns your spoken query into text in the Voice sample.', 'ja': '音声サンプルで話した検索語をテキストにします。',
              'zh-Hans': '在语音示例中把你说出的搜索词转成文字。', 'zh-Hant': '在語音範例中把你說出的搜尋詞轉成文字。'}
REFRESH_NAMES = ['refresh_idle', 'refresh_pulling', 'refresh_refreshing', 'refresh_last_time', 'refresh_today',
                 'refresh_none_last_date']


def strings(path):
    text = open(path, encoding='utf-8').read()
    out = []
    for key, value in re.findall(r'^"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";', text, re.M):
        value = value.replace('\\"', '"').replace('\\n', '\n')
        value = re.sub(r'%(\d+\$)?@', lambda m: '%' + (m.group(1) or '') + 's', value)
        value = re.sub(r'%(\d+\$)?l[du]', lambda m: '%' + (m.group(1) or '') + 'd', value)
        out.append((key, value))
    return out


def write(path, items):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'string': [{'name': n, 'value': v} for n, v in items]}, f, ensure_ascii=False, indent=2)
        f.write('\n')


def read(path):
    if not os.path.exists(path):
        return []
    return [(s['name'], s['value']) for s in json.load(open(path, encoding='utf-8'))['string']]


def snake(name):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()


def main():
    for lang, q in LANGS.items():
        # The library: every iOS key, the existing names kept.
        path = os.path.join(LIB, q, 'element', 'string.json')
        items = dict(read(path))
        for key, value in strings(os.path.join(BUNDLE, lang + '.lproj', 'CYLSearchViewController.strings')):
            items.setdefault('cyl_' + key.replace('.', '_'), value)
        write(path, sorted(items.items()))
        # The example: the app's own names, then the tabs and the discover page.
        path = os.path.join(ENTRY, q, 'element', 'string.json')
        own = [(n, v) for n, v in read(path) if n in ('module_desc', 'EntryAbility_desc', 'EntryAbility_label')]
        if not own:
            own = read(os.path.join(ENTRY, 'base', 'element', 'string.json'))
            own = [(n, v) for n, v in own if n in ('module_desc', 'EntryAbility_desc', 'EntryAbility_label')]
        items = dict(own)
        for bundle in ('CYLSearchTabs', 'CYLSearchDiscover'):
            for key, value in strings(os.path.join(EXAMPLE, bundle + '.bundle', lang + '.lproj', bundle + '.strings')):
                items[key.replace('.', '_')] = value
        items.update(zip(REFRESH_NAMES, REFRESH[lang]))
        items['microphone_reason'] = MICROPHONE[lang]
        write(path, list(items.items()))
        lproj = os.path.join(EXAMPLE, 'CYLSearchDiscover.bundle', lang + '.lproj')
        raw = os.path.join(ENTRY, 'rawfile', 'discover')
        os.makedirs(raw, exist_ok=True)
        shutil.copyfile(os.path.join(lproj, 'search-discover.json'), os.path.join(raw, q + '.json'))
        media = os.path.join(ENTRY, q, 'media')
        os.makedirs(media, exist_ok=True)
        shutil.copyfile(os.path.join(lproj, 'discover-hot@3x.png'), os.path.join(media, 'discover_hot.png'))
    media = os.path.join(LIB, 'base', 'media')
    os.makedirs(media, exist_ok=True)
    count = 0
    for name in sorted(os.listdir(BUNDLE)):
        m = re.match(r'CYLSearch(\w+?)(@2x)?\.png$', name)
        if m:
            shutil.copyfile(os.path.join(BUNDLE, name), os.path.join(media, 'cyl_search_' + snake(m.group(1)) + '.png'))
            count += 1
    for extra in ('LICENSE.material-design-icons', 'LICENSE.placeholder-third-party', 'NOTICE', 'ICON-SOURCES'):
        shutil.copyfile(os.path.join(BUNDLE, extra), os.path.join(ROOT, 'harmonyos', 'cylsearch', extra))
    print('strings', len(LANGS), 'languages; placeholder images', count)


if __name__ == '__main__':
    main()
