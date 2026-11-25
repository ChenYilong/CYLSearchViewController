import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { BackHandler, Image, Platform, Pressable, ScrollView, Settings, StatusBar, StyleSheet, Switch, Text, useColorScheme, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { CYLSearchBarView, CYLSearchView, CYLTagListView, type CYLSearchBarHandle } from 'react-native-cylsearch';
import { CYLTabBar, type CYLTabBarItem, type CYLTabBarPlusButton } from 'react-native-cyltabbar';
import discoverData from './search-discover.json';
import { ContactTagsDemo } from './ContactTagsDemo';
import { SearchBarStylesDemo } from './SearchBarStylesDemo';
import { SearchControllerDemo } from './SearchControllerDemo';

/**
 * The suggestions of MaterialSearchView's Default sample, as in the iOS, Android and Flutter examples.
 */
const SUGGESTIONS = [
  'A very very long suggestion that would span multiple lines.', 'Android', 'iOS', 'SCALA', 'Ruby', 'JavaScript', 'C#',
  'Python', 'C', 'C++', 'PHP', 'Go', 'Perl', 'Bash', 'Lua', 'R', 'TCL', 'Haskell', 'Objective C', 'Swift', 'Kotlin',
  'jQuery', 'Development', 'Web', 'Ajax', 'Test', 'Testing', 'CookBook', 'Beagle', 'VMware', 'Less.js', 'IDE', 'Arduino',
  'Xamarin', 'UI', 'Microsoft', 'Application', 'JUnit', 'SQL',
];

type Demo = {
  label: string;
  style?: 'list' | 'tags';
  query?: string;
  scenario?: 'noSearchResults' | 'noContent';
  focuses?: boolean;
  /**
   * Lists the matching languages as results (the core's `resultsDataSource`) with pull-to-refresh.
   */
  results?: boolean;
  /**
   * CollectionViewClassifyMenu's contact tags example on CYLSearchViewController (iOS Examples row 6).
   */
  contactTags?: boolean;
  /**
   * The QMUI replicas: "Search controller" (QDSearchViewController) and "Search bar styles" (QDSearchBarViewController).
   */
  qmui?: 'controller' | 'styles';
  /**
   * Starts the contact tags demo without tags (the placeholders; iOS `-CYLContactTagsEmpty YES`).
   */
  emptyTags?: boolean;
};

type Tab = { key: string; title: string; description: string; demos: Demo[] };

/**
 * One tab per kind of demo, as the Flutter example (the plus button's search bar demo and Discover are their own).
 */
/** The key of each demo button's text in `search-discover.json` (the demo's English label is its identity). */
const DEMO_LABEL_KEYS: Record<string, string> = {"Open search": "demo.openSearch", "Results with pull to refresh": "demo.resultsRefresh", "Search controller": "demo.searchController", "Search bar styles": "demo.searchBarStyles", "Contact tags (CollectionViewClassifyMenu)": "demo.contactTags", "Contact tags without tags": "demo.contactTagsEmpty", "No matching results": "demo.noMatch", "No content": "demo.noContent"};

const TABS: Tab[] = [
  {
    key: 'list',
    title: 'List style',
    description: 'Suggestions as a list, filtered as you type; or results of each query, pulled down to refresh.',
    demos: [{ label: 'Open search' }, { label: 'Results with pull to refresh', results: true },
      { label: 'Search controller', qmui: 'controller' }, { label: 'Search bar styles', qmui: 'styles' }],
  },
  {
    key: 'tags',
    title: 'Tag style',
    description: 'The same suggestions as tags (CollectionViewClassifyMenu); the keyboard waits for a tap.',
    demos: [{ label: 'Open search', style: 'tags', focuses: false }, { label: 'Contact tags (CollectionViewClassifyMenu)', contactTags: true },
      { label: 'Contact tags without tags', contactTags: true, emptyTags: true }],
  },
  {
    key: 'empty',
    title: 'Empty results',
    description: "A query without a match shows a CYLTableViewPlaceHolder placeholder.",
    demos: [
      { label: 'No matching results', query: 'zzz' },
      { label: 'No content', query: 'zzz', scenario: 'noContent' },
    ],
  },
];

/**
 * The colors of the light or dark scheme, so the example follows the system as the native views do.
 */
function usePalette() {
  const dark = useColorScheme() === 'dark';
  // A gradient page (docs/instructions/example-demos.md rule 7): the tag lists draw no background, so the glass tags sit on it.
  const page = { backgroundColor: dark ? '#1B1F5E' : '#7FB7FF', backgroundImage: dark ? 'linear-gradient(135deg, #1B1F5E, #5B2A86, #0F6E7A)' : 'linear-gradient(135deg, #7FB7FF, #FF9EC7, #FFC27A)' };
  return { page, background: dark ? '#000000' : '#FFFFFF', text: dark ? '#FFFFFF' : '#000000', secondary: dark ? '#AAAAAA' : '#666666' };
}

export default function App() {
  const dark = useColorScheme() === 'dark';
  return (
    <SafeAreaProvider>
      {/* Dark status bar icons on the light pages (light ones in dark mode): the app draws edge to edge, so the status
          bar is transparent over the page; the theme alone left white icons on white (Android). */}
      <StatusBar barStyle={dark ? 'light-content' : 'dark-content'} />
      <Screens />
    </SafeAreaProvider>
  );
}

/**
 * The tab bar: the three sample tabs and Discover, as in the native and Flutter examples; the plus button opens the
 * search bar page and rises above the bar (AGENTS.md, "Raised plus button").
 */
const TAB_KEYS = ['list', 'tags', 'empty', 'discover'];
// Rive tab icons: each tab plays an artboard of CYLTabBarController's icons.riv (its state machine input "active"), as
// CYLTabBarController's example-rive; the symbol stays as the image before the file loads. The file comes from the pinned
// CYLTabBarController checkout (vendor/, scripts/fetch-cyltabbar.sh), copied into the iOS app by a build phase and read
// from the Android assets; it is not committed here (no licence of its own).
function riveTab(item: CYLTabBarItem, artboard: string): CYLTabBarItem {
  return {
    ...item,
    CYLTabBarRiveFilePath: 'icons.riv',
    // tint 'title': the icon takes the tab's title color (gray, the selected color when selected), as a template image;
    // icons.riv draws light strokes for a dark bar (CYLTabBarController B12).
    CYLTabBarAnimationOptions: { artboard, stateMachine: `${artboard}_Interactivity`, input: 'active', tint: 'title' },
    CYLTabBarRiveSize: '{28, 28}',
  };
}
function tabItems(text: Record<string, string>): CYLTabBarItem[] {
  return [
  riveTab({ title: text['tab.list'], image: 'system:list.bullet', selectedImage: 'system:list.bullet', identifier: 'list' }, 'CHAT'),
  riveTab({ title: text['tab.tags'], image: 'system:tag', selectedImage: 'system:tag.fill', identifier: 'tags' }, 'BELL'),
  riveTab({ title: text['tab.empty'], image: 'system:magnifyingglass', selectedImage: 'system:magnifyingglass', identifier: 'empty' }, 'SEARCH'),
  riveTab({ title: text['tab.discover'], image: 'system:sparkle.magnifyingglass', selectedImage: 'system:sparkle.magnifyingglass', identifier: 'discover' }, 'USER'),
  ];
}
// SVGA tab icons (the SVGA counterpart of the Rive scene, as the iOS, native Android, Flutter and HarmonyOS examples):
// CYLTabBarController plays CYLTabBarSVGAFilePath through the app's SVGA player (Android: SVGAPlayer-Android; iOS: the
// CYLAnimatedItem/SVGA subspec). The files are the iOS example's CYLSearchExample/SVGA (see NOTICE.md there), read from the
// Android assets and copied into the iOS app.
function svgaTab(item: CYLTabBarItem, file: string): CYLTabBarItem {
  return { ...item, CYLTabBarSVGAFilePath: file, CYLTabBarSVGASize: '{28, 28}' };
}
function svgaTabItems(text: Record<string, string>): CYLTabBarItem[] {
  return [
  svgaTab({ title: text['tab.list'], image: 'system:list.bullet', selectedImage: 'system:list.bullet', identifier: 'list' }, 'tab_list.svga'),
  svgaTab({ title: text['tab.tags'], image: 'system:tag', selectedImage: 'system:tag.fill', identifier: 'tags' }, 'tab_chat.svga'),
  svgaTab({ title: text['tab.empty'], image: 'system:magnifyingglass', selectedImage: 'system:magnifyingglass', identifier: 'empty' }, 'tab_search.svga'),
  svgaTab({ title: text['tab.discover'], image: 'system:sparkle.magnifyingglass', selectedImage: 'system:sparkle.magnifyingglass', identifier: 'discover' }, 'tab_profile.svga'),
  ];
}

function plusButton(text: Record<string, string>): CYLTabBarPlusButton {
  return {
  title: text['tab.searchBar'],
  // A 52 pt green PNG: `imageSize` would redraw an SF Symbol into a black bitmap.
  image: require('./assets/plus-button.png'),
  // No size, center or title alignment here: CYLTabBarController's core lays the raised plus button out (2026-11-17).
  identifier: 'plus',
  pageIdentifier: 'plus',
  };
}

function Screens() {
  const palette = usePalette();
  const text = discoverStrings();
  // `-initialTab discover` (an iOS launch argument, read through Settings) opens a tab directly, for screenshots.
  const [tab, setTab] = useState<string>(() => (Platform.OS === 'ios' && typeof Settings.get('initialTab') === 'string' ? Settings.get('initialTab') : 'list'));
  // `-initialDemo controller|styles` (an iOS launch argument) opens a QMUI replica directly, for screenshots.
  const [open, setOpen] = useState<Demo | null>(() => {
    const initial = Platform.OS === 'ios' ? Settings.get('initialDemo') : undefined;
    return initial === 'controller' || initial === 'styles' ? { label: initial, qmui: initial } : null;
  });
  // Where the tab icons come from (iOS CYLDemoTabIconSource: 2 SVGA; the button on the sample pages switches it).
  // The Discover page is always a second-level page (a back button in its navigation bar): it opens on the entry page at
  // once, the back button returns to the entry (owner's rule for every example).
  // The tab whose second-level search page is pushed (null: every tab shows its first-level page with the whole search bar).
  const [searchTab, setSearchTab] = useState<string | null>(null);
  useEffect(() => {
    const subscription = BackHandler.addEventListener("hardwareBackPress", () => {
      if (searchTab === null) return false;
      setSearchTab(null);
      return true;
    });
    return () => subscription.remove();
  }, [searchTab]);
  const [iconSource, setIconSource] = useState<'rive' | 'svga'>(() => (Platform.OS === 'ios' && Number(Settings.get('CYLDemoTabIconSource')) === 2 ? 'svga' : 'rive'));
  if (open?.qmui) {
    return (
      <SafeAreaView style={[styles.fill, palette.page]} edges={['top', 'bottom']}>
        {open.qmui === 'controller' ? <SearchControllerDemo onClose={() => setOpen(null)} /> : <SearchBarStylesDemo onClose={() => setOpen(null)} />}
      </SafeAreaView>
    );
  }
  if (open?.results) {
    return (
      <SafeAreaView style={[styles.fill, palette.page]} edges={['top', 'bottom']}>
        <ResultsDemo onClose={() => setOpen(null)} />
      </SafeAreaView>
    );
  }
  if (open?.contactTags) {
    return <ContactTagsDemo onClose={() => setOpen(null)} latency={2} empty={open.emptyTags ?? false} />;
  }
  if (open) {
    return (
      <SafeAreaView style={[styles.fill, palette.page]} edges={['top', 'bottom']}>
        <CYLSearchView
          style={styles.fill}
          suggestions={SUGGESTIONS}
          suggestionStyle={open.style ?? 'list'}
          placeholder="Search"
          query={open.query}
          showsEmptyResultsPlaceholder
          emptyResultsScenario={open.scenario ?? 'noSearchResults'}
          suggestionCachePolicy="database"
          suggestionCacheName="ReactNativeExample"
          focusesSearchFieldOnShow={open.focuses ?? true}
          suggestionsFoldControlPosition="inline"
          suggestionsFoldControlContent="icon"
          suggestionsFoldedRowCount={2}
          onClose={() => setOpen(null)}
        />
      </SafeAreaView>
    );
  }
  const current = TABS.find((item) => item.key === tab);
  return (
    <SafeAreaView style={[styles.fill, palette.page]} edges={['top', 'left', 'right']}>
      <View style={styles.fill}>
        {tab === 'bar' ? <SearchBarDemo /> : searchTab !== null ? <DiscoverDemo tabKey={searchTab} onBack={() => setSearchTab(null)} /> : (
          <>
            {/* First-level page: the tab's own WHOLE search bar in the navigation bar; a tap pushes the second-level page. */}
            <FirstLevelBar tabKey={tab} onOpen={() => setSearchTab(tab)} />
            {tab === 'discover' ? <DiscoverEntry /> : current ? (
          <ScrollView contentContainerStyle={styles.pageList}>
            <Text style={[styles.title, styles.block, { color: palette.text }]}>{text[`tab.${current.key}`] ?? current.title}</Text>
            {/* The demos as ClassifyMenu's tag list (docs/instructions/example-demos.md): glass board and tags over the gradient
                page, wrapping titles, a 3-row fold whose control is the last tag (icon only), a long press shows the description. */}
            <CYLTagListView backgroundStyle="liquidGlass"
              tags={current.demos.map((demo) => text[DEMO_LABEL_KEYS[demo.label] ?? ''] ?? demo.label)}
              tagIds={current.demos.map((demo) => demo.label)}
              tagSubtitles={current.demos.map(() => text[`tab.${current.key}.description`] ?? current.description)}
              sectionTitle={text[`tab.${current.key}`] ?? current.title}
              titleMaxLines={0}
              foldControlPosition="inline"
              foldControlContent="icon"
              foldedRowCount={3}
              onTagSelect={(event) => setOpen(current.demos[event.nativeEvent.index] ?? null)}
            />
            <CYLTagListView backgroundStyle="liquidGlass"
              tags={[iconSource === 'rive' ? text['demo.tabIconsRive'] ?? '' : text['demo.tabIconsSvga'] ?? '']}
              sectionTitle={text['demo.tabIcons'] ?? 'Tab icons'}
              titleMaxLines={0}
              foldControlPosition="inline"
              foldControlContent="icon"
              foldedRowCount={3}
              onTagSelect={() => setIconSource(iconSource === 'rive' ? 'svga' : 'rive')}
            />
          </ScrollView>
            ) : null}
          </>
        )}
      </View>
      {/* CYLTabBarController's tab bar (react-native-cyltabbar): four tabs and a raised plus button for the search bar. */}
      <CYLTabBar
        key={iconSource}
        style={styles.tabBar}
        items={iconSource === 'svga' ? svgaTabItems(text) : tabItems(text)}
        plusButton={{ ...plusButton(text), titleColor: palette.text }}
        tapAnimation="scale"
        selectedIndex={tab === 'bar' ? -1 : TAB_KEYS.indexOf(tab)}
        onTabSelect={(index) => setTab(index < 0 ? 'bar' : TAB_KEYS[index] ?? 'list')}
      />
    </SafeAreaView>
  );
}

/**
 * The search page with results: each query lists the matching languages through the core's results list (instead of
 * the suggestions); pulling the list down refreshes it (the core's refresh API, CYLTableViewPlaceHolder's header).
 */
function ResultsDemo({ onClose }: { onClose: () => void }) {
  const [query, setQuery] = useState('');
  const [refreshCount, setRefreshCount] = useState(0);
  const [refreshing, setRefreshing] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const results = useMemo(() => {
    const text = query.trim().toLowerCase();
    if (!text) return [];
    const matches = SUGGESTIONS.filter((item) => item.toLowerCase().includes(text));
    // Each refresh rotates the list, so the reload is visible.
    const shift = matches.length > 0 ? refreshCount % matches.length : 0;
    return [...matches.slice(shift), ...matches.slice(0, shift)];
  }, [query, refreshCount]);
  const refresh = useCallback(() => {
    setRefreshing(true);
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      setRefreshCount((count) => count + 1);
      // Every completion path ends the refresh.
      setRefreshing(false);
    }, 1000);
  }, []);
  useEffect(() => () => { if (timer.current) clearTimeout(timer.current); }, []);
  return (
    <CYLSearchView
      style={styles.fill}
      suggestions={SUGGESTIONS}
      placeholder="Search"
      showsEmptyResultsPlaceholder
      suggestionCachePolicy="none"
      results={results}
      refreshEnabled
      refreshing={refreshing}
      onRefresh={refresh}
      onTextChange={(event) => setQuery(event.nativeEvent.text)}
      onSelectResult={(event) => setQuery(event.nativeEvent.result)}
      onClose={onClose}
    />
  );
}

/**
 * The native search bar inline, its text and search shown below; then the same bar in multiple mode, several searches
 * side by side.
 */
function SearchBarDemo() {
  const palette = usePalette();
  const [status, setStatus] = useState('Text: ');
  const [searches, setSearches] = useState<string[]>(['Swift', 'Kotlin']);
  const [multipleStatus, setMultipleStatus] = useState('Searches: Swift, Kotlin');
  return (
    <View style={styles.page}>
      <Text style={[styles.title, { color: palette.text }]}>{discoverStrings()['tab.searchBar']}</Text>
      <CYLSearchBarView
        style={styles.bar}
        placeholder="Streamer, room ID or song"
        showsCancelButton
        fieldShadowOpacity={0.12}
        onTextChange={(event) => setStatus(`Text: ${event.nativeEvent.text}`)}
        onSubmit={(event) => setStatus(`Searched: ${event.nativeEvent.text}`)}
        onCancel={() => setStatus('Text: ')}
      />
      <Text style={[styles.body, { color: palette.text }]}>{status}</Text>
      <Text accessibilityRole="header" style={[styles.section, { color: palette.text }]}>Multiple searches</Text>
      {/* mode="multiple": the magnifier starts a search, a completed search becomes an entry; tap one to select it. */}
      <CYLSearchBarView
        style={styles.bar}
        mode="multiple"
        placeholder="Search"
        searches={searches}
        onTextChange={(event) => setMultipleStatus(`Typing search ${event.nativeEvent.index + 1}: ${event.nativeEvent.text}`)}
        onCompleteSearch={(event) => {
          const { text } = event.nativeEvent;
          setMultipleStatus(`Completed: ${text}`);
          setSearches((items) => [...items, text]);
        }}
        onSelectSearch={(event) => setMultipleStatus(`Selected: ${event.nativeEvent.text}`)}
        onRemoveSearch={(event) => {
          const { index } = event.nativeEvent;
          setMultipleStatus(`Removed search ${index + 1}`);
          setSearches((items) => items.filter((_, i) => i !== index));
        }}
      />
      <Text style={[styles.body, { color: palette.text }]}>{multipleStatus}</Text>
    </View>
  );
}

/** The discover demo's texts for the device language (en, ja, zh-Hans, zh-Hant), English when it is not held. */
function discoverLanguage() {
  // iOS: the user's preferred language (Hermes' Intl follows the app's own localizations, English here); elsewhere Intl.
  const preferred = Platform.OS === 'ios' ? (Settings.get('AppleLanguages') as string[] | undefined)?.[0] : undefined;
  const tag = preferred ?? Intl.DateTimeFormat().resolvedOptions().locale;
  return /^zh-(Hant|TW|HK|MO)/.test(tag) ? 'zh-Hant' : tag.startsWith('zh') ? 'zh-Hans' : tag.slice(0, 2);
}

/** The localized hot icon (iOS discover-hot.png of the same .lproj; @2x and @3x beside it), English when not held. */
const ENGLISH_HOT_ICON = { source: require('./assets/discover/discover-hot-en.png') as number };
const HOT_ICONS: Record<string, { source: number }> = {
  en: ENGLISH_HOT_ICON,
  ja: { source: require('./assets/discover/discover-hot-ja.png') },
  'zh-Hans': { source: require('./assets/discover/discover-hot-zh-Hans.png') },
  'zh-Hant': { source: require('./assets/discover/discover-hot-zh-Hant.png') },
};

function hotIconForLanguage() {
  return HOT_ICONS[discoverLanguage()] ?? ENGLISH_HOT_ICON;
}

/** The discover demo's sample data (recent searches and topics) for the device language, English when not held. */
function discoverContent() {
  const all: Record<string, { recentSearches: string[]; discover: { title: string; icon?: string }[] }> = discoverData.data;
  return all[discoverLanguage()] ?? all.en ?? { recentSearches: [], discover: [] };
}

/** The topics of `page` (the pages wrap around the pool): `discoverCount` records, each with its own hot mark. */
function topicsOnPage(page: number) {
  const pool = discoverContent().discover;
  const count = discoverData.discoverCount;
  const pages = count > 0 ? Math.floor(pool.length / count) : 0;
  if (pages === 0) {
    return [];
  }
  const start = (page % pages) * count;
  return pool.slice(start, start + count);
}

/** The page after `page`, cyclically: refresh shows the next page, so the hot topic (one per page) moves every time. */
function nextPage(page: number) {
  const count = discoverData.discoverCount;
  const pages = count > 0 ? Math.floor(discoverContent().discover.length / count) : 0;
  return pages > 0 ? (page + 1) % pages : 0;
}

function discoverStrings() {
  const language = discoverLanguage();
  const all: Record<string, Record<string, string>> = discoverData.strings;
  return { ...all.en, ...all[language] } as Record<string, string>;
}

/**
 * The discover demo (iOS CYLSearchDiscoverViewController, Android CYLSearchDiscoverFragment, the Flutter discover
 * page): the native search bar, the recent searches as native tags (folded behind a chevron), topics in two columns.
 */
/** One search bar look per tab (CYLTabBarController owns the tabs, each tab root owns its bar): the same props on both levels. */
const TAB_LOOKS: Record<string, { navigationFieldStyle?: boolean; searchBarStyle?: string; showsSearchIcon?: boolean; fieldShadowOpacity?: number; centersPlaceholder?: boolean; camera?: boolean }> = {
  list: { navigationFieldStyle: true },
  tags: { searchBarStyle: 'bordered' },
  empty: { centersPlaceholder: true },
  discover: { searchBarStyle: 'bordered', showsSearchIcon: false, fieldShadowOpacity: 0.06, camera: true },
};

/**
 * The first-level page's search bar: the WHOLE bar in the navigation bar, full width inside the safe area (no back button).
 * A tap on the field does not edit: the native core brings the back button in (animated), shrinks the bar, and sends
 * `onFirstLevelTap`, where the page pushes the second-level search page. The page sets no width.
 */
function FirstLevelBar({ tabKey, onOpen }: { tabKey: string; onOpen: () => void }) {
  const look = TAB_LOOKS[tabKey] ?? {};
  const text = discoverStrings();
  return (
    <CYLSearchBarView
      style={styles.discoverBar}
      placeholder={text['discover.search']}
      navigationFieldStyle={look.navigationFieldStyle}
      searchBarStyle={look.searchBarStyle}
      showsSearchIcon={look.showsSearchIcon}
      fieldShadowOpacity={look.fieldShadowOpacity}
      centersPlaceholder={look.centersPlaceholder}
      embedsInNavigationBar
      pushesOnTap
      onFirstLevelTap={onOpen}
      items={[
        ...(look.camera ? [{ style: 'icon' as const, image: 'camera', title: text['discover.imageSearch'], animationURL: 'search_camera.json', onPress: onOpen }, { style: 'divider' as const }] : []),
        { style: 'text', title: text['discover.search'], accessibilityIdentifier: 'CYLSearchFirstLevelSearchButton', onPress: onOpen },
      ]}
    />
  );
}

/** The entry of the Discover tab: a one-row page that opens the Discover page (iOS `CYLSearchDiscoverEntryViewController`). */
function DiscoverEntry() {
  const palette = usePalette();
  const title = discoverStrings()['discover.title'] ?? '';
  return (
    <ScrollView contentContainerStyle={styles.pageList}>
      <Text style={[styles.title, styles.block, { color: palette.text }]}>{title}</Text>
      {/* The entry cell as a tag of the glass tag list (docs/instructions/example-demos.md): titled section, tail control icon only. */}
      <CYLTagListView backgroundStyle="liquidGlass"
        tags={[title]}
        tagSubtitles={[title]}
        sectionTitle={title}
        titleMaxLines={0}
        foldControlPosition="inline"
        foldControlContent="icon"
        foldedRowCount={3}
        onTagSelect={() => undefined}
      />
    </ScrollView>
  );
}

function DiscoverDemo({ tabKey, onBack }: { tabKey: string; onBack: () => void }) {
  const look = TAB_LOOKS[tabKey] ?? {};
  const palette = usePalette();
  const barRef = useRef<CYLSearchBarHandle>(null);
  const [animationLoops, setAnimationLoops] = useState(false);
  const [animationSpeed, setAnimationSpeed] = useState(1);
  const text = discoverStrings();
  const hotIcon = hotIconForLanguage();
  const hotIconUri = Image.resolveAssetSource(hotIcon.source)?.uri ?? '';
  const [recent, setRecent] = useState<string[]>(() => discoverContent().recentSearches);
  const [page, setPage] = useState(0);
  const [barText, setBarText] = useState('');
  const typed = useRef('');
  const [message, setMessage] = useState('');
  const topics = useMemo(() => {
    return topicsOnPage(page);
  }, [page]);
  // The field's placeholder is the first topic (iOS `reloadLists`); the Search button searches it when nothing is typed.
  const placeholder = topics[0]?.title ?? text['discover.search'] ?? '';
  const search = (text: string) => {
    const query = text.trim();
    if (!query) return;
    setRecent((items) => [query, ...items.filter((item) => item !== query)]);
    setBarText(query);
    setMessage(`Searching: ${query}`);
  };
  return (
    <ScrollView contentContainerStyle={styles.discoverPage}>
      {/* The field stays; the camera, a divider and the Search button are items appended inside its bordered capsule. */}
      <CYLSearchBarView
        style={styles.discoverBar}
        text={barText}
        placeholder={placeholder}
        navigationFieldStyle={look.navigationFieldStyle}
        searchBarStyle={look.searchBarStyle}
        centersPlaceholder={look.centersPlaceholder}
        showsSearchIcon={look.showsSearchIcon}
        embedsInNavigationBar
        showsBackButton
        focusesOnAppear
        onBackButtonTap={onBack}
        fieldShadowOpacity={look.fieldShadowOpacity}
        onTextChange={(event) => { typed.current = event.nativeEvent.text; }}
        onSubmit={(event) => search(event.nativeEvent.text || placeholder)}
        ref={barRef}
        items={[
          // The camera button itself plays the animation (Animation demo rule): search_camera.json, the same Lottie file on every platform.
          ...(look.camera ? [{ style: 'icon' as const, image: 'camera', title: text['discover.imageSearch'], animationURL: 'search_camera.json', animationLoops, animationSpeed, onPress: () => setMessage(text['discover.imageSearchUnavailable'] ?? '') }, { style: 'divider' as const }] : []),
          { style: 'text', title: text['discover.search'], accessibilityIdentifier: 'CYLSearchDiscoverSearchButton', onPress: () => search(typed.current || placeholder) },
        ]}
      />
      {/* The native tag list brings its own section header (title and trash) and lines up with the bar: no custom header. */}
      {recent.length > 0 ? (
        <CYLTagListView backgroundStyle="liquidGlass"
          tags={recent}
          sectionTitle={text['discover.recent']}
          showsClearButton
          onClearButtonTap={() => { setRecent([]); setMessage(text['discover.cleared'] ?? ''); }}
          foldControlPosition="inline"
          foldControlContent="icon"
          foldedRowCount={2}
          onTagSelect={(event) => search(event.nativeEvent.title)}
        />
      ) : null}
      {/* The topics: CollectionViewClassifyMenu's tag list as a two-column grid, the hot icon after a hot topic. */}
      <CYLTagListView backgroundStyle="liquidGlass"
        tags={topics.map((topic) => topic.title)}
        columns={2}
        foldedRowCount={0}
        sectionTitle={text['discover.title']}
        showsRefreshButton
        onRefreshButtonTap={() => setPage((value) => nextPage(value))}
        tagImages={topics.map((topic) => (topic.icon === 'hot' ? hotIconUri : ''))}
        tagImageLabels={topics.map((topic) => (topic.icon === 'hot' ? text['discover.hot'] ?? '' : ''))}
        onTagSelect={(event) => search(event.nativeEvent.title)}
      />
      {/* Playback of the camera item (index 0 of `items`), the last block of the page options, outside the bar: loop, speed and restart. */}
      <View style={[styles.header, styles.block]}>
        <Text style={[styles.body, { color: palette.text }]}>{text['discover.animationLoops']}</Text>
        <Switch accessibilityLabel={text['discover.animationLoops']} value={animationLoops} onValueChange={setAnimationLoops} />
        <Pressable accessibilityRole="button" accessibilityLabel={`${text['discover.animationSpeed']} -`} onPress={() => setAnimationSpeed((value) => Math.max(0.25, value - 0.25))}>
          <Text style={styles.action}>-</Text>
        </Pressable>
        <Text accessibilityLabel={text['discover.animationSpeed']} accessibilityValue={{ text: `${animationSpeed}x` }} style={[styles.body, { color: palette.text }]}>{`${animationSpeed}x`}</Text>
        <Pressable accessibilityRole="button" accessibilityLabel={`${text['discover.animationSpeed']} +`} onPress={() => setAnimationSpeed((value) => Math.min(3, value + 0.25))}>
          <Text style={styles.action}>+</Text>
        </Pressable>
        <Pressable accessibilityRole="button" accessibilityLabel={text['discover.animationPlay']} onPress={() => barRef.current?.restartItemAnimation(0)}>
          <Text style={styles.action}>{text['discover.animationPlay']}</Text>
        </Pressable>
      </View>
      {message ? <Text style={[styles.message, styles.block, { color: palette.secondary }]}>{message}</Text> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  page: { padding: 16, gap: 12 },
  pageList: { paddingTop: 16, paddingBottom: 16, gap: 12 },
  title: { fontSize: 22, fontWeight: '600' },
  body: { fontSize: 16 },
  button: { alignSelf: 'flex-start', backgroundColor: '#44608E', borderRadius: 20, paddingHorizontal: 18, paddingVertical: 10 },
  buttonText: { color: 'white', fontSize: 15, fontWeight: '600' },
  bar: { height: 52 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 },
  section: { fontSize: 17, fontWeight: '600' },
  action: { fontSize: 15, color: '#007AFF' },
  // The page's own content: 16 pt blocks around its title and the playback row, a 56 pt bar edge to edge (the core aligns it).
  discoverPage: { paddingTop: 0, paddingBottom: 16, gap: 12 },
  // 44 pt, 4 pt more below: the first header starts 16 pt under the bar, as the iOS example measures.
  discoverBar: { height: 44, marginBottom: 4 },
  block: { paddingHorizontal: 16 },
  message: { fontSize: 14, color: '#666' },
  // In the layout flow under the page: the bar takes its own height, the bottom safe area included.
  tabBar: { alignSelf: 'stretch' },
});
