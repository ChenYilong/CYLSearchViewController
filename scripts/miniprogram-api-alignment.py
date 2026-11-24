#!/usr/bin/env python3
"""Builds the iOS-to-WeChat-Mini-Program API table (docs/miniprogram-api-alignment.md, between the generated markers).

One row per public declaration of Sources/CYLSearchBar/*.swift, parsed as for the Android and HarmonyOS
tables: the iOS API, its doc comment, and the mini program counterpart in
CrossPlatform/wechat-miniprogram-cylsearch/src/core (CommonJS, ported from the HarmonyOS models). A row is filled when
the core declares the counterpart under the HarmonyOS name: the class, the enum case, or the member (a method, a
getter, a field set in the constructor, or a static). UIKit-only rows take the HarmonyOS N/A reasons, worded for the
mini program; rows that HarmonyOS fills with a component parameter name the mini program component instead
(COMPONENT). A third column written by hand is kept. Score: rows not TODO / rows x 100.

Usage: python3 scripts/miniprogram-api-alignment.py [--check]
"""
import importlib.util, os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DOC = os.path.join(ROOT, 'docs', 'miniprogram-api-alignment.md')
CORE = os.path.join(ROOT, 'CrossPlatform', 'wechat-miniprogram-cylsearch', 'src', 'core')
BEGIN, END = '<!-- miniprogram-api-alignment:begin -->', '<!-- miniprogram-api-alignment:end -->'

spec = importlib.util.spec_from_file_location('harmonyos_alignment', os.path.join(ROOT, 'scripts', 'harmonyos-api-alignment.py'))
harmony = importlib.util.module_from_spec(spec)
spec.loader.exec_module(harmony)
android = harmony.android

# Rows HarmonyOS fills with an ArkUI component parameter: the mini program component that takes their place.
COMPONENT = {
    ('CYLSearchBarView', 'trailingAccessoryViews'): '`<cyl-search-bar>` slot `trailing` (multiple slots)',
    ('CYLSearchBarView', 'leadingView'): '`<cyl-search-bar>` slot `leading`',
    ('CYLSearchBarItemView', 'init(item:)'): '`<cyl-search-bar>` draws each item of `items` (`CYLSearchBarItem.itemDictionary()`)',
    ('CYLSearchBarItemView', None): '`<cyl-search-bar-item>` (component)',
    ('CYLSearchBarItemView', 'item'): '`<cyl-search-bar-item item="…">` (its `item` property)',
    ('CYLSearchView', 'suggestionCacheTitleLabel'): '`CYLSearchView.suggestionCacheTitle`',
    ('CYLSearchView', 'clearSuggestionCacheButton'): '`CYLSearchView.clearSuggestionCache()` (the header button calls it)',
    # The merged CYLSearchBar core (docs/search-core-merge.md).
    ('CYLSearchView', 'emptyResultsView'): '`<cyl-search>` `emptyResultsView()` (the `cyl-placeholder` of CYLTableViewPlaceHolder)',
    ('CYLSearchView', 'emptySuggestionsView'): '`<cyl-search>` `emptySuggestionsView()` (the `cyl-placeholder` of CYLTableViewPlaceHolder)',
    ('CYLSearchView', 'resultsTableView'): '`<cyl-search>` results list, drawn from `results` / `setResultsDataSource()` inside `cyl-refresh`',
    ('CYLSearchView', 'install(in:)'): '`<cyl-search inline>` (drawn in place, always open)',
    ('CYLSearchBarView', 'pinToKeyboard(in:)'): '`<cyl-search-bar pinsToKeyboard>` (fixed at the page\'s bottom, lifted by `wx.onKeyboardHeightChange`)',
    ('CYLSearchBarView', 'autocorrectionType'): 'N/A: the mini program `<input>` has no autocorrection trait',
    ('CYLSearchBarView', 'tintColorDidChange()'): 'N/A: no inherited tint in the mini program (`searchIndicatorColor` and the colors are properties)',
    ('CYLSearchView', 'safeAreaInsetsDidChange()'): 'N/A: `<cyl-search>` reads the safe area from the navigation metrics (`CYLSearchResources`)',
    ('CYLSearchBarView', 'textField'): 'N/A: the mini program has no view objects; `<cyl-search-bar>` draws its `<input>` from the properties',
    ('CYLSearchBarView', 'itemViews'): 'N/A: the mini program has no view objects; `<cyl-search-bar>` draws each item of `items` with `<cyl-tag-button>`',
    ('CYLSearchBarItem', 'itemView'): 'N/A: the mini program has no view objects; `<cyl-search-bar>` draws the item with CollectionViewClassifyMenu\'s `<cyl-tag-button>` from `CYLSearchBarItem.tagButtonProperties()`',
    ('CYLSearchBarItem', 'actualBadgeSuperView()'): 'N/A: the mini program has no view objects; the badge is drawn by the item\'s `<cyl-tag-button>`',
    ('CYLSearchBarView', 'newSearchButton'): 'N/A: the mini program has no view objects; `<cyl-search-bar mode="multiple">` draws it',
    ('CYLSearchView', 'dividerView'): 'N/A: the mini program has no view objects; `<cyl-search>` draws the divider (`dividerColor`)',
    ('CYLSearchView', 'suggestionsTableView'): 'N/A: the mini program has no view objects; `<cyl-search>` draws the suggestions list',
    ('CYLSearchView', 'suggestionsTagView'): 'N/A: the mini program has no view objects; `<cyl-search>` draws the tags (`suggestionsFoldControl`)',
    # The QMUI search port (CYLSearchBar, CYLSearchController, CYLSearchTableViewController, CYLSearchNavigationBar).
    ('CYLSearchBar', 'cancelButton'): 'N/A: the mini program has no view objects; `<cyl-search-bar>` draws the Cancel button (`cancelButtonTitle`, `cancelButtonFont`, `cancelButtonMarginsProvider`)',
    ('CYLSearchBar', 'backgroundView'): 'N/A: the mini program has no view objects; the bar background is CSS (`CYLSearchBarAppearance.styles(…).bar`)',
    ('CYLSearchBar', 'segmentedControl'): 'N/A: the mini program has no scope bar; `<cyl-search-bar>` has no segmented control (a page draws its own scope `<view>`)',
    ('CYLSearchBar', 'leadingAccessoryView'): '`<cyl-search-bar>` slot `leading`',
    ('CYLSearchBar', 'trailingAccessoryView'): '`<cyl-search-bar>` slot `trailing` (multiple slots)',
    ('CYLSearchController', 'searchController'): 'N/A: no `UISearchController` in the mini program; `CYLSearchController.searchView` (a `CYLSearchView`) is the system controller\'s place',
    ('CYLSearchController', 'searchResultsController'): 'N/A: the mini program has no view controllers; `<cyl-search>` draws the results inside `cyl-refresh`',
    ('CYLSearchController', 'tableView'): 'N/A: the mini program has no view objects; `<cyl-search>` draws the results list from `CYLSearchView.searchResults`',
    ('CYLSearchController', 'hidesNavigationBarDuringPresentation'): '`<cyl-search coversNavigationBar>` (the overlay reaches under the custom navigation bar)',
    ('CYLSearchController', 'forwardsAppearanceFromContentsViewController'): 'N/A: the mini program has no view controller appearance callbacks; the page\'s `onShow` / `onHide` are its own',
    ('CYLSearchController', 'swipeGestureRecognizer'): 'N/A: the mini program has no gesture recognizers; `<cyl-search>` reads the touch events and asks `cylEdgeSwipeBegins` / `CYLSearchController.gestureRecognizerShouldBegin`',
    ('CYLSearchController', 'prefersStatusBarHiddenProvider'): 'N/A: the mini program page cannot hide the status bar per presentation (`navigationBarTextStyle` of the page config is static)',
    ('CYLSearchController', 'preferredStatusBarStyleProvider'): 'N/A: the status bar style of a mini program page is the static `navigationBarTextStyle` of its config',
    ('CYLSearchController', 'install(in:)'): '`<cyl-search inline>` (drawn in place, always open)',
    ('CYLSearchController', 'showEmptyView(scenario:)'): '`CYLSearchController.showEmptyViewForScenario`',
    ('CYLSearchNavigationBar', 'position(for:)'): 'N/A: WeChat\'s custom navigation bar always reaches under the status bar (`<cyl-search-navigation-bar>` pads by `statusBarHeight`)',
    ('CYLSearchNavigationBar', 'embedInNavigationBar(of:)'): '`<cyl-search-navigation-bar>` (a page with `"navigationStyle": "custom"` declares it; a page cannot be given a bar at run time)',
    ('CYLSearchTableViewController', 'searchController(_:updateResultsFor:)'): '`CYLSearchTableViewController.searchControllerUpdateResultsFor`',
    ('CYLSearchTableViewController', 'showEmptyView(scenario:)'): '`CYLSearchTableViewController.showEmptyViewForScenario`',
    ('CYLSearchView', 'suggestionCacheHeaderView'): 'N/A: the mini program has no view objects; `<cyl-search>` draws the cache header',
}


def mini(text):
    # The HarmonyOS reason, worded for the mini program.
    for old, new in (('ArkUI `TextInput`', 'the mini program `<input>`'), ('ArkUI', 'the mini program'),
                     ('`CYLSearchBarComponent` / `CYLSearchBarItemView`', '`<cyl-search-bar>`'),
                     ('`CYLSearchBarComponent`', '`<cyl-search-bar>`'), ('`CYLSearchBarItemView`', '`<cyl-search-bar>`'),
                     ('`CYLMultiSearchComponent`', '`<cyl-multi-search>`'), ('`CYLSearchComponent.cacheHeader`', '`<cyl-search>`'),
                     ('`CYLSearchComponent`', '`<cyl-search>`'), ('`CYLSearchOverlayComponent.build`', '`<cyl-search>`'),
                     ('`CYLSearchResultsComponent.build`', '`<cyl-search-results>`'),
                     ('`CYLSearchResultsComponent`', '`<cyl-search-results>`'), ('vp', 'px'), ('`sys.color.*`', 'the page styles')):
        text = text.replace(old, new)
    return text


def sources():
    texts = []
    for name in sorted(os.listdir(CORE)):
        if name.endswith('.js') and not name.startswith('._'):
            texts.append(open(os.path.join(CORE, name), encoding='utf-8').read())
    return '\n'.join(texts)


def frozen_enum(text, owner):
    # A string-valued enum of the merged core: `const Owner = Object.freeze({ name: 'value', … });`.
    m = re.search(r'^const ' + re.escape(owner) + r'\s*=\s*Object\.freeze\(\{(.*?)^\}\);', text, re.M | re.S)
    return m.group(1) if m else None


def body_of(text, owner):
    m = re.search(r'^class ' + re.escape(owner) + r'\b.*?^\}', text, re.M | re.S)
    return m.group(0) if m else None


def has_member(text, owner, name):
    body = body_of(text, owner) or ''
    patterns = [
        r'^\s+(?:static\s+)?(?:async\s+)?(?:get\s+|set\s+)?' + re.escape(name) + r'\s*\(',   # method, getter, setter
        r'\bthis\.' + re.escape(name) + r'\s*=',                                            # field
    ]
    if any(re.search(p, body, re.M) for p in patterns):
        return True
    return re.search(r'^' + re.escape(owner) + r'\.' + re.escape(name) + r'\s*=', text, re.M) is not None  # static


def detect(text, owner, swift, kind, kotlin):
    if (owner, swift) in COMPONENT:
        return COMPONENT[(owner, swift)]
    manual = harmony.MANUAL.get((owner, swift))
    if manual and manual.startswith('N/A: '):
        return mini(manual)
    if kind in ('class', 'protocol'):
        return COMPONENT.get((owner, None)) or (f'`{owner}`' if body_of(text, owner) else None)
    if kind == 'enum':
        return f'`{owner}`' if (re.search(r'\bvar ' + re.escape(owner) + r'\b|\bexports\.' + re.escape(owner) + r'\s*=\s*\{', text)
                                or frozen_enum(text, owner) is not None) else None
    if swift in harmony.NOT_APPLICABLE:
        return 'N/A: ' + mini(harmony.NOT_APPLICABLE[swift])
    if (owner, swift) in harmony.VIEW_OBJECTS:
        return 'N/A: the mini program has no view objects; `<cyl-search-bar>` draws it from the properties'
    if kind == 'method' and android.CONFORMANCE.match(swift):
        return 'N/A: a UIKit protocol conformance (the components report the same events to the model)'
    if kind == 'case':
        name = swift.split('.')[-1]
        frozen = frozen_enum(text, owner)
        if frozen is not None and re.search(r'^\s*' + re.escape(name) + r'\s*:', frozen, re.M):
            return f'`{owner}.{name}`'
        return f'`{owner}.{name}`' if re.search(re.escape(owner) + r'\["' + re.escape(name) + r'"\]\s*=', text) else None
    if body_of(text, owner) is None:
        return None
    if kind == 'initializer':
        return f'`new {owner}(…)`' if re.search(r'^\s+constructor\(', body_of(text, owner), re.M) else None
    for candidate in dict.fromkeys([(kotlin or swift).split('(')[0], swift.split('(')[0]]):
        if has_member(text, owner, candidate):
            return f'`{owner}.{candidate}`'
    return None


def main():
    doc = open(DOC, encoding='utf-8').read()
    kept = harmony.existing(doc)
    table = ['| iOS public API | Doc comment | Mini program |', '| :--- | :--- | :--- |']
    done = total = 0
    text = sources()
    for owner, swift, kind, comment, kotlin in android.parse_swift():
        first = harmony.label(owner, swift, kind)
        note = re.sub(r'\s+', ' ', comment).replace('|', '\\|').strip() or '—'
        if len(note) > 240:
            note = note[:237].rstrip() + '…'
        third = kept.get(first, 'TODO')
        if third == 'TODO' or third.startswith('`') or third.startswith('N/A: '):
            third = detect(text, owner, swift, kind, kotlin) or 'TODO'
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
    if '--todo' in sys.argv:
        for line in table[2:]:
            if line.endswith('| TODO |'):
                print(line.split('|')[1].strip())


if __name__ == '__main__':
    main()
