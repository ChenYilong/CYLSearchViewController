#!/usr/bin/env python3
"""Builds the iOS-to-Android API table (docs/android-api-alignment.md, between the generated markers).

Each public declaration of Sources/CYLSearchViewController/*.swift (types, enum cases, properties, methods,
initializers and protocol requirements) is one row: the iOS API, the upstream counterparts its doc comment names
(the projects merged in android/merged), the Kotlin counterpart in the cylsearch module, and the status. A row is
DONE only when the Kotlin declaration is found in the module's sources; rows that are UIKit protocol conformances are
N/A. Prints the score: (DONE + N/A) / rows x 100.

Usage: python3 android/merged/scripts/api-alignment.py [--check] [--only=CYLSearchView,CYLSearchBarView]
"""
import os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
SWIFT = os.path.join(ROOT, 'Sources', 'CYLSearchViewController')
KOTLIN = os.path.join(ROOT, 'android', 'merged', 'cylsearch', 'src', 'main', 'kotlin', 'com', 'cyl', 'search')
DOC = os.path.join(ROOT, 'docs', 'android-api-alignment.md')
BEGIN, END = '<!-- api-alignment:begin -->', '<!-- api-alignment:end -->'

# Swift names whose Kotlin counterpart has another name (Kotlin property and method conventions, Android types).
RENAMES = {
    'searchOpen': 'isSearchOpen', 'presented': 'isPresented', 'inSearchMode': 'isInSearchMode',
    'install(in:)': 'installInView', 'attach(to:)': 'attachToMenuItem', 'show(in:)': 'showInViewController',
    'hide(_:)': 'hide', 'imageName(for:)': 'imageNameForStyle', 'image(named:)': 'imageNamed',
    'localizedString(forKey:)': 'localizedString', 'localizedString(forKey:language:)': 'localizedString',
    'selectItem(at:)': 'selectItemAtIndex', 'removeItem(at:)': 'removeItemAtIndex',
    'addSearchText(_:)': 'addSearchText', 'setText(_:submit:)': 'setText', 'setQuery(_:submit:)': 'setQuery',
    'setIconified(_:animated:)': 'setIconified', 'showSearch(animated:)': 'showSearch',
    'closeSearch(animated:)': 'closeSearch', 'updateSearchResults(for:)': 'updateSearchResults',
    'resourceBundle': 'resourceBundle',
}
# Kotlin constructors that stand for Swift initializers: a regex on the class's file.
INITIALIZERS = {
    ('CYLSearchPlaceholderView', 'init(kind:)'): (r'constructor\(context: Context, kind: CYLSearchPlaceholderKind\)', 'constructor(context, kind)'),
    ('CYLSearchPlaceholderView', 'init(style:message:)'): (r'constructor\(context: Context, style: CYLSearchPlaceholderStyle, message:', 'constructor(context, style, message)'),
    ('CYLSearchPlaceholderView', 'init(style:text:)'): (r'constructor\(context: Context, style: CYLSearchPlaceholderStyle, text:', 'constructor(context, style, text)'),
    ('CYLSearchPlaceholderView', 'init(image:message:)'): (r'constructor\(context: Context, image: Drawable\?, message:', 'constructor(context, image, message)'),
    ('CYLSearchPlaceholderView', 'init(image:text:)'): (r'class CYLSearchPlaceholderView\(context: Context, image: Drawable\?, text: String\)', 'constructor(context, image, text)'),
    ('CYLSearchController', 'init(searchDataSource:)'): (r'constructor\(searchDataSource: CYLSearchResultsDataSource\)', 'constructor(searchDataSource)'),
    ('CYLSearchResultsViewController', 'init(searchDataSource:)'): (r'constructor\(searchDataSource: CYLSearchResultsDataSource\)', 'constructor(searchDataSource)'),
}
# init(coder:): a view's Kotlin counterpart is the XML constructor; a fragment's is the no-argument constructor the
# system uses to recreate it.
CODER = {
    'CYLMultiSearchView': (r'class CYLMultiSearchView @JvmOverloads constructor\(\s*context: Context,\s*attrs: AttributeSet\?', 'constructor(context, attrs) (XML)'),
    'CYLSearchBarView': (r'class CYLSearchBarView @JvmOverloads constructor\(\s*context: Context,\s*attrs: AttributeSet\?', 'constructor(context, attrs) (XML)'),
    'CYLSearchView': (r'class CYLSearchView @JvmOverloads constructor\(\s*context: Context,\s*attrs: AttributeSet\?', 'constructor(context, attrs) (XML)'),
    'CYLSearchController': (r'class CYLSearchController\(\) : Fragment\(\)', 'no-argument constructor (fragment recreation)'),
    'CYLSearchResultsViewController': (r'open class CYLSearchResultsViewController\(\) : Fragment\(\)', 'no-argument constructor (fragment recreation)'),
}
# UIKit overrides: (Kotlin regex in the class's file or None, Android counterpart, status when found).
OVERRIDES = {
    'init(frame:)': (r'@JvmOverloads constructor\(\s*context: Context,', 'constructor(context)', 'DONE'),
    'init(nibName:bundle:)': (None, 'not available on iOS either (`@available(*, unavailable)`)', 'N/A'),
    'init(style:)': (None, 'not available on iOS either (`@available(*, unavailable)`)', 'N/A'),
    'encodeRestorableState(with:)': (r'override fun onSaveInstanceState\(\)', '`onSaveInstanceState()`', 'DONE'),
    'decodeRestorableState(with:)': (r'override fun onRestoreInstanceState\(', '`onRestoreInstanceState(state)`', 'DONE'),
    'becomeFirstResponder()': (r'override fun requestFocus\(', '`requestFocus()`', 'DONE'),
    'resignFirstResponder()': (r'override fun clearFocus\(\)', '`clearFocus()`', 'DONE'),
    'backgroundColor': (r'override fun setBackgroundColor\(', '`setBackgroundColor(color)` (the page)', 'DONE'),
    'accessibilityPerformEscape()': (r'OnBackPressedCallback', 'the back key closes the search (`OnBackPressedCallback`)', 'DONE'),
    'layoutSubviews()': (None, 'framework override (Android lays out with its layout classes)', 'N/A'),
    'intrinsicContentSize': (None, 'framework override (Android: measured height, `minimumHeight`)', 'N/A'),
    'sizeThatFits(_:)': (None, 'framework override (Android: `onMeasure`)', 'N/A'),
    'traitCollectionDidChange(_:)': (None, 'framework override (Android recreates views on configuration changes)', 'N/A'),
    'tintColorDidChange()': (None, 'framework override (Android has no inherited tint)', 'N/A'),
    'safeAreaInsetsDidChange()': (None, 'framework override (Android: window insets listener)', 'N/A'),
    'viewDidLoad()': (None, 'framework override (Android: `onViewCreated`)', 'N/A'),
}
# UIKit protocol conformances: public in Swift only because the protocol requires it.
CONFORMANCE = re.compile(r'^(textField|textFieldShouldReturn|textFieldShouldBeginEditing|textFieldDidBeginEditing|'
                         r'textFieldDidEndEditing|tableView|searchBarView\w*)\(')
UPSTREAM = re.compile(r'\((?:[^()]*?)(lapism|MiguelCatalan|MaterialSearchView|MultiSearchView|iammert|Android|yechaoa|'
                      r'cjj|MaterialSearchBar|NavigationIconCompat)[^()]*\)')


def kotlin_sources():
    # --only=A,B counts only those Kotlin files (to replay the score after each added class).
    only = next((a.split('=', 1)[1].split(',') for a in sys.argv if a.startswith('--only=')), None)
    return {name[:-3]: open(os.path.join(KOTLIN, name), encoding='utf-8').read() for name in os.listdir(KOTLIN)
            if name.endswith('.kt') and (only is None or name[:-3] in only)}


def declared(sources, name):
    pattern = re.compile(r'\b(class|interface|object|enum class|fun|val|var)\s+(`?)' + re.escape(name) + r'\b|^\s+' + re.escape(name) + r'\s*[,(]?$', re.M)
    return any(pattern.search(text) for text in sources.values())


def selector_name(selector):
    parts = [p for p in selector.split(':') if p]
    return parts[0] + (parts[1][0].upper() + parts[1][1:] if len(parts) > 1 else '')


def parse_swift():
    rows = []
    for file in sorted(os.listdir(SWIFT)):
        if not file.endswith('.swift'):
            continue
        lines = open(os.path.join(SWIFT, file), encoding='utf-8').read().split('\n')
        owner, kind, comment, objc = None, None, [], None
        for line in lines:
            stripped = line.strip()
            if stripped.startswith('/**') or stripped.startswith('*') or stripped.startswith('*/'):
                comment.append(stripped.lstrip('/*').strip())
                continue
            m = re.match(r'@objc\((\S+)\)', stripped)
            if m:
                objc = m.group(1)
            note = ' '.join(comment)
            # A comment belongs to the next declaration; an attribute line alone (`@objc(name)`) keeps it.
            comment_now = note
            if stripped and not re.fullmatch(r'@\w+(\(.*\))?', stripped):
                comment = []
            m = re.match(r'^(?:@objc\(\S+\)\s*)?(open|public)\s+(?:final\s+)?(class|protocol|enum)\s+(\w+)', stripped)
            if m and not line.startswith(' '):
                owner, kind = m.group(3), m.group(2)
                rows.append((owner, owner, kind, comment_now, None))
                objc = None
                continue
            if owner is None or not line.startswith('    ') or line.startswith('        '):
                continue
            if kind == 'enum':
                m = re.match(r'case (\w+)', stripped)
                if m:
                    rows.append((owner, owner + '.' + m.group(1), 'case', comment_now, m.group(1)[0].upper() + m.group(1)[1:]))
                continue
            if kind == 'protocol':
                m = re.match(r'(?:optional )?func (\w+)', stripped)
                if m:
                    selector = objc or m.group(1)
                    rows.append((owner, ('-' + selector) if objc else m.group(1), 'requirement', comment_now, selector_name(selector)))
                    objc = None
                continue
            m = re.match(r'^(?:@objc(?:\(\S+\))?\s+)*(?:@discardableResult\s+)?(?:override\s+)?(open|public)\s+(.*)$', stripped)
            if not m or 'private(set)' in stripped and False:
                continue
            body = m.group(2).split(' {')[0].split(' =')[0].strip()
            pm = re.match(r'(?:private\(set\)\s+)?(?:weak\s+)?(?:static\s+)?(?:let|var)\s+(\w+)', body)
            fm = re.match(r'(?:static\s+)?func\s+(\w+)\((.*?)\)', body)
            im = re.match(r'(?:convenience\s+|required\s+)*init\??\((.*?)\)', body)
            if pm:
                name = pm.group(1)
                rows.append((owner, name, 'property', comment_now, RENAMES.get(name, name)))
            elif fm:
                labels = ''.join((a.strip().split(' ')[0].split(':')[0]) + ':' for a in fm.group(2).split(',') if a.strip())
                swift = f'{fm.group(1)}({labels})'
                rows.append((owner, swift, 'method', comment_now, RENAMES.get(swift, fm.group(1))))
            elif im:
                labels = ''.join((a.strip().split(' ')[0].split(':')[0]) + ':' for a in im.group(1).split(',') if a.strip())
                rows.append((owner, f'init({labels})', 'initializer', comment_now, None))
            objc = None
    return rows


def upstream_of(comment):
    found = []
    for m in re.finditer(r'\(([^()]*)\)', comment):
        text = m.group(1)
        if '`' in text and not text.lstrip().startswith(('`-', 'the ', 'a ', 'an ')):
            found.append(text.strip())
    return '; '.join(found)


def main():
    sources = kotlin_sources()
    table = ['| iOS API | Upstream counterpart (named in the iOS doc comment) | Android (`cylsearch`) | Status |',
             '| :--- | :--- | :--- | :--- |']
    done = na = todo = 0
    current = None
    for owner, swift, kind, comment, kotlin in parse_swift():
        if owner != current:
            current = owner
        upstream = upstream_of(comment).replace('|', '\\|') or '—'
        status, android = 'TODO', '—'
        if kind in ('class', 'protocol', 'enum'):
            android = owner
            status = 'DONE' if declared(sources, owner) else 'TODO'
            swift = f'**{kind} `{owner}`**'
        elif (swift if kind != 'initializer' or swift != 'init(coder:)' else None) in OVERRIDES and (owner, swift) not in INITIALIZERS:
            pattern, android, found = OVERRIDES[swift]
            status = found if pattern is None or re.search(pattern, sources.get(owner, '')) else 'TODO'
            swift = f'`{owner}.{swift}`'
        elif kind == 'initializer' and swift == 'init(coder:)':
            pattern, android = CODER.get(owner, (None, '—'))
            status = 'DONE' if pattern and re.search(pattern, sources.get(owner, '')) else 'TODO'
            swift = f'`{owner}.{swift}`'
        elif kind == 'initializer':
            pattern, android = INITIALIZERS.get((owner, swift), (None, '—'))
            status = 'DONE' if pattern and re.search(pattern, sources.get(owner, '')) else 'TODO'
            swift = f'`{owner}.{swift}`'
        elif kind == 'method' and CONFORMANCE.match(swift) and owner in ('CYLSearchBarView', 'CYLSearchView', 'CYLMultiSearchView'):
            status, android = 'N/A', 'internal listener (UIKit protocol conformance)'
            swift = f'`{owner}.{swift}`'
        elif kind == 'case':
            android = f'`{owner}.{kotlin}`'
            status = 'DONE' if re.search(r'^\s+' + kotlin + r'\b', sources.get(owner if owner in sources else '', ''), re.M) or any(
                re.search(r'enum class ' + owner + r'[^{]*\{[^}]*\b' + kotlin + r'\b', t, re.S) for t in sources.values()) else 'TODO'
            swift = f'`{swift}`'
        else:
            android = f'`{owner}.{kotlin}`'
            status = 'DONE' if declared(sources, kotlin) else 'TODO'
            swift = f'`{owner}.{swift}`'
        done += status == 'DONE'
        na += status == 'N/A'
        todo += status == 'TODO'
        table.append(f'| {swift} | {upstream} | {android} | {status} |')
    total = done + na + todo
    score = (done + na) * 100 // total if total else 0
    summary = f'Rows: {total}; DONE {done}, N/A {na}, TODO {todo}; score {score}/100.'
    block = BEGIN + '\n' + summary + '\n\n' + '\n'.join(table) + '\n' + END
    doc = open(DOC, encoding='utf-8').read()
    doc = re.sub(re.escape(BEGIN) + '.*?' + re.escape(END), lambda _: block, doc, flags=re.S)
    if '--check' not in sys.argv:
        open(DOC, 'w', encoding='utf-8').write(doc)
    print(summary)


if __name__ == '__main__':
    main()
