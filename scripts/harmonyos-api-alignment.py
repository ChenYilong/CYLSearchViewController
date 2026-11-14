#!/usr/bin/env python3
"""Builds the iOS-to-HarmonyOS API table (docs/harmonyos-api-alignment.md, between the generated markers).

One row per public declaration of Sources/CYLSearchViewController/*.swift, parsed as for the Android table
(android/merged/scripts/api-alignment.py): the iOS API, its doc comment, and the HarmonyOS counterpart. The third
column is TODO by default. A row is filled when the ArkTS sources (harmonyos/cylsearch/src/main/ets) declare the
counterpart: the type, the enum case, or the member inside the type's body, under the same name as on Android. A
row that is UIKit only gets `N/A: <reason>` from the rules below. A third column written by hand in the document is
kept. Score: rows not TODO / rows x 100.

Usage: python3 scripts/harmonyos-api-alignment.py [--check]
"""
import importlib.util, os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DOC = os.path.join(ROOT, 'docs', 'harmonyos-api-alignment.md')
BEGIN, END = '<!-- harmonyos-api-alignment:begin -->', '<!-- harmonyos-api-alignment:end -->'

spec = importlib.util.spec_from_file_location('android_alignment', os.path.join(ROOT, 'android', 'merged', 'scripts', 'api-alignment.py'))
android = importlib.util.module_from_spec(spec)
spec.loader.exec_module(android)


ETS = os.path.join(ROOT, 'harmonyos', 'cylsearch', 'src', 'main', 'ets')

# UIKit-only API: no counterpart in ArkUI, where a component is declared, not laid out or archived by hand.
NOT_APPLICABLE = {
    'init(coder:)': 'no archives in ArkUI (the state is restored with `decodeRestorableState`)',
    'init(nibName:bundle:)': 'not available on iOS either (`@available(*, unavailable)`)',
    'init(style:)': 'not available on iOS either (`@available(*, unavailable)`)',
    'layoutSubviews()': 'ArkUI lays a component out from its declaration',
    'sizeThatFits(_:)': 'ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height)',
    'traitCollectionDidChange(_:)': 'system colors (`sys.color.*`) follow the color mode by themselves',
    'actualBadgeSuperView()': 'ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView`',
}
# View objects iOS exposes for customization: ArkUI has none; the component draws them from the model's properties.
VIEW_OBJECTS = {
    ('CYLSearchBarView', n) for n in ('fieldView', 'searchIconView', 'cancelButton', 'placeholderLabel',
                                      'navigationButton', 'voiceButton', 'submitButton', 'iconButton')
} | {('CYLSearchBarItem', 'itemView'), ('CYLSearchBarItemView', 'imageView'), ('CYLSearchBarItemView', 'titleLabel'),
     ('CYLSearchBarItemView', 'badgeLabel')}


# Counterparts that are not a member of the model class (the component's builder parameters, struct parameters), and
# UIKit lifecycle or text traits ArkUI has no equivalent for.
MANUAL = {
    ('CYLSearchBarView', 'trailingAccessoryViews'): '`CYLSearchBarComponent.trailingAccessoryViews` (a `@BuilderParam`)',
    ('CYLSearchBarView', 'leadingView'): '`CYLSearchBarComponent.leadingView` (a `@BuilderParam`)',
    ('CYLSearchBarItemView', 'init(item:)'): '`CYLSearchBarItemView({ item })` (the `@Param item`)',
    ('CYLSearchBarItemView', 'intrinsicContentSize'): 'N/A: ArkUI measures `CYLSearchBarItemView` from its content (36 vp minimum)',
    ('CYLSearchBarView', 'autocapitalizationType'): 'N/A: ArkUI `TextInput` has no capitalization trait',
    ('CYLSearchBarView', 'autocorrectionType'): 'N/A: ArkUI `TextInput` has no autocorrection trait',
    ('CYLMultiSearchView', 'autocapitalizationType'): 'N/A: ArkUI `TextInput` has no capitalization trait',
    ('CYLMultiSearchView', 'searchButton'): 'N/A: ArkUI has no view objects; `CYLMultiSearchComponent` draws it (`searchImage`)',
    ('CYLMultiSearchView', 'tintColorDidChange()'): 'N/A: system colors follow the theme by themselves (`indicatorColor` overrides)',
    ('CYLSearchController', 'viewDidLoad()'): 'N/A: ArkUI components have no load phase (`CYLSearchOverlayComponent.build`)',
    ('CYLSearchController', 'viewDidLayoutSubviews()'): 'N/A: the overlay is laid out below the safe area by ArkUI, never over the page it hides',
    ('CYLSearchResultsViewController', 'viewDidLoad()'): 'N/A: ArkUI components have no load phase (`CYLSearchResultsComponent.build`)',
    ('CYLSearchResultsViewController', 'viewDidLayoutSubviews()'): 'N/A: `CYLSearchResultsComponent` lays the bar above the list in one column, never over it',
    ('CYLSearchView', 'safeAreaInsetsDidChange()'): 'N/A: ArkUI keeps the page inside the safe area by itself',
    ('CYLSearchView', 'dividerView'): 'N/A: ArkUI has no view objects; `CYLSearchComponent` draws the divider (`dividerColor`)',
    ('CYLSearchView', 'suggestionsTableView'): 'N/A: ArkUI has no view objects; `CYLSearchComponent` draws the list (`suggestionCellConfiguration`)',
    ('CYLSearchView', 'suggestionsTagView'): 'N/A: ArkUI has no view objects; `CYLSearchComponent` draws the tags (`suggestionsFoldControl`)',
    ('CYLSearchView', 'suggestionCacheHeaderView'): 'N/A: ArkUI has no view objects; `CYLSearchComponent.cacheHeader` draws it',
    ('CYLSearchView', 'suggestionCacheTitleLabel'): '`CYLSearchView.suggestionCacheTitle`',
    ('CYLSearchView', 'clearSuggestionCacheButton'): '`CYLSearchView.clearSuggestionCache()` (the header button calls it)',
    ('CYLSearchPlaceholderView', 'imageView'): '`CYLSearchPlaceholderView.image`',
    ('CYLSearchPlaceholderView', 'textLabel'): '`CYLSearchPlaceholderView.text`',
}


def ets_sources():
    texts = []
    if os.path.isdir(ETS):
        for name in sorted(os.listdir(ETS)):
            if name.endswith('.ets'):
                texts.append(open(os.path.join(ETS, name), encoding='utf-8').read())
    return '\n'.join(texts)


def body_of(sources, owner):
    # The text of `class|interface|enum|struct <owner> ... {` up to the closing brace in column 0.
    m = re.search(r'^(?:export\s+)?(?:class|interface|enum|struct)\s+' + re.escape(owner) + r'\b.*?^\}', sources, re.M | re.S)
    return m.group(0) if m else None


def detect(sources, owner, swift, kind, kotlin):
    body = body_of(sources, owner)
    if (owner, swift) in MANUAL:
        return MANUAL[(owner, swift)]
    if kind in ('class', 'protocol', 'enum'):
        return f'`{owner}`' if body else None
    if swift in NOT_APPLICABLE:
        return 'N/A: ' + NOT_APPLICABLE[swift]
    if (owner, swift) in VIEW_OBJECTS:
        return 'N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties'
    if kind == 'method' and android.CONFORMANCE.match(swift):
        return 'N/A: a UIKit protocol conformance (ArkUI reports the same events to the model)'
    if body is None:
        return None
    if kind == 'case':
        name = swift.split('.')[-1]
        return f'`{owner}.{name}`' if re.search(r'^\s+' + re.escape(name) + r'\b\s*(=|,|$)', body, re.M) else None
    if kind == 'initializer':
        return f'`new {owner}(…)`' if re.search(r'^\s+constructor\(', body, re.M) else None
    name = (kotlin or swift).split('(')[0]
    for candidate in dict.fromkeys([name, swift.split('(')[0]]):
        if re.search(r'^\s+(?:@\w+\s+)*(?:static\s+|readonly\s+|private\s+)*(?:get\s+|set\s+)?' + re.escape(candidate) + r'\b\s*[(:?=<]', body, re.M):
            return f'`{owner}.{candidate}`'
    return None


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
    sources = ets_sources()
    for owner, swift, kind, comment, kotlin in android.parse_swift():
        first = label(owner, swift, kind)
        note = re.sub(r'\s+', ' ', comment).replace('|', '\\|').strip() or '—'
        if len(note) > 240:
            note = note[:237].rstrip() + '…'
        third = kept.get(first, 'TODO')
        if third == 'TODO' or third.startswith('`') or third.startswith('N/A: '):
            third = detect(sources, owner, swift, kind, kotlin) or 'TODO'
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
