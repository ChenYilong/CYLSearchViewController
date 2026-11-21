#!/usr/bin/env python3
"""The HarmonyOS scorecard: two tables scored together (docs/harmonyos-cross-platform.md).

Table 1: every iOS public API, second column its HarmonyOS implementation (taken from the third column of
docs/harmonyos-api-alignment.md, which scripts/harmonyos-api-alignment.py keeps in step with the Swift sources).
Table 2: every demo of the iOS example (CYLSearchExample), second column its HarmonyOS implementation (kept from the
document; `TODO` for a new row).
Score = rows of both tables whose second column is not `TODO` / all rows x 100. Every TODO removed is a full score.
Run: python3 scripts/harmonyos-scorecard.py [--check]   (--check prints the score without writing)
"""
import os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
API_DOC = os.path.join(ROOT, 'docs', 'harmonyos-api-alignment.md')
DOC = os.path.join(ROOT, 'docs', 'harmonyos-cross-platform.md')

# The demos of the iOS example, in the order the app shows them (CYLSearchExample/*).
DEMOS = [
    ('Tab bar: CYLTabBarController with Search, Examples, Tag style, Discover and the plus button (CYLTabBarConfiguration.json)', 'CYLSearchExampleAppDelegate.m'),
    ('Search tab: Issue #1317 reproduction, the search bar in the navigation bar over a list (UISearchController, the CYLSearchView refresh API; Overlay: a CYLSearchView with resultsDataSource)', 'CYLSearchExampleViewController.swift'),
    ('Search tab: pull to refresh with CYLTableViewPlaceHolder\'s CYLRefreshNormalHeader', 'CYLSearchExampleViewController.swift'),
    ('Search tab: the empty state, the CYLPlaceholderView of CYLTableViewPlaceHolder, "No matching results"', 'CYLSearchExampleViewController.swift'),
    ('Examples tab: the menu (Search and refresh, Placeholder styles, Search bar, Ports)', 'CYLSearchDemoMenuViewController.m'),
    ('Placeholder styles: the 41 styles x 4 messages and the Custom section (text only, image only, both)', 'CYLSearchDemoMenuViewController.m'),
    ('Placeholder styles: the detail page with one CYLPlaceholderView (CYLTableViewPlaceHolder)', 'CYLSearchDemoMenuViewController.m'),
    ('Search bar page (plus button and Examples): CYLSearchBarView styles and appended items', 'CYLSearchBarDemoViewController.m'),
    ('Ports: the menu of five search libraries', 'CYLSearchPortsViewController.swift'),
    ('Port: lapism/search (MaterialSearchBar + MaterialSearchView)', 'CYLLapismSearchViewController.swift'),
    ('Port: MiguelCatalan/MaterialSearchView, the menu of six samples', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Default', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Themed', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Voice', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Sticky', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Tabs', 'CYLMaterialSearchMenuViewController.swift'),
    ('MaterialSearchView sample: Input type', 'CYLMaterialSearchMenuViewController.swift'),
    ('Port: yechaoa/MaterialDesign SearchViewActivity', 'CYLYechaoaSearchViewController.swift'),
    ('Port: android-cjj/MaterialSearchView circular reveal', 'CYLRevealSearchViewController.swift'),
    ('Port: iammert/MultiSearchView', 'CYLMultiSearchDemoViewController.swift'),
    ('Tag style tab: the six MaterialSearchView samples with tag suggestions, keyboard down on show', 'CYLSuggestionDemoPages.swift'),
    ('Discover tab: recent searches and discover topics copied from CollectionViewClassifyMenu', 'CYLSearchDiscoverViewController.swift'),
    ('Snackbar: a short message at the bottom (CYLSnackbar)', 'CYLSearchPortsViewController.swift'),
    ('Texts in English, Japanese, Simplified and Traditional Chinese', 'CYLSearchViewController.bundle'),
    ('Dark mode follows the system', 'CYLSearchExample'),
]


def cells(line):
    return [c.strip() for c in line.strip().strip('|').split(' | ')]


def api_rows():
    text = open(API_DOC, encoding='utf-8').read()
    body = text.split('<!-- harmonyos-api-alignment:begin -->')[1].split('<!-- harmonyos-api-alignment:end -->')[0]
    rows = []
    for line in body.splitlines():
        if line.startswith('| ') and not line.startswith('| iOS public API') and not line.startswith('| :'):
            c = cells(line)
            rows.append((c[0], c[2]))
    return rows


def kept_demos(text):
    kept = {}
    m = re.search(r'<!-- harmonyos-demos:begin -->(.*?)<!-- harmonyos-demos:end -->', text, re.S)
    if m:
        for line in m.group(1).splitlines():
            if line.startswith('| ') and not line.startswith('| iOS example demo') and not line.startswith('| :'):
                c = cells(line)
                kept[c[0]] = c[1]
    return kept


def table(header, rows):
    out = ['| %s | HarmonyOS implementation |' % header, '| :--- | :--- |']
    out += ['| %s | %s |' % r for r in rows]
    return '\n'.join(out)


def main():
    text = open(DOC, encoding='utf-8').read()
    kept = kept_demos(text)
    apis = api_rows()
    demos = [('%s (`%s`)' % (name, src), None) for name, src in DEMOS]
    demos = [(n, kept.get(n, 'TODO')) for n, _ in demos]
    todo_api = sum(1 for _, h in apis if h == 'TODO')
    todo_demo = sum(1 for _, h in demos if h == 'TODO')
    total = len(apis) + len(demos)
    done = total - todo_api - todo_demo
    score = done * 100 // total if done < total else 100
    summary = ('Score: %d/100 (%d of %d rows; API %d/%d, demos %d/%d; TODO left %d).'
               % (score, done, total, len(apis) - todo_api, len(apis), len(demos) - todo_demo, len(demos),
                  todo_api + todo_demo))
    if '--check' not in sys.argv:
        text = re.sub(r'<!-- harmonyos-score:begin -->.*?<!-- harmonyos-score:end -->',
                      lambda _: '<!-- harmonyos-score:begin -->\n' + summary + '\n<!-- harmonyos-score:end -->', text, flags=re.S)
        text = re.sub(r'<!-- harmonyos-api:begin -->.*?<!-- harmonyos-api:end -->',
                      lambda _: '<!-- harmonyos-api:begin -->\n' + table('iOS public API', apis) + '\n<!-- harmonyos-api:end -->', text, flags=re.S)
        text = re.sub(r'<!-- harmonyos-demos:begin -->.*?<!-- harmonyos-demos:end -->',
                      lambda _: '<!-- harmonyos-demos:begin -->\n' + table('iOS example demo', demos) + '\n<!-- harmonyos-demos:end -->', text, flags=re.S)
        open(DOC, 'w', encoding='utf-8', newline='\n').write(text)
    print(summary)


if __name__ == '__main__':
    main()
