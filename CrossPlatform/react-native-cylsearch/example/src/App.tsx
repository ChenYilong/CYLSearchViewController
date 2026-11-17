import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Platform, Pressable, ScrollView, Settings, StyleSheet, Text, useColorScheme, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { CYLSearchBarView, CYLSearchView, CYLTagListView } from 'react-native-cylsearch';
import { CYLTabBar, type CYLTabBarItem, type CYLTabBarPlusButton } from 'react-native-cyltabbar';
import discoverData from './search-discover.json';

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
};

type Tab = { key: string; title: string; description: string; demos: Demo[] };

/**
 * One tab per kind of demo, as the Flutter example (the plus button's search bar demo and Discover are their own).
 */
const TABS: Tab[] = [
  {
    key: 'list',
    title: 'List style',
    description: 'Suggestions as a list, filtered as you type; or results of each query, pulled down to refresh.',
    demos: [{ label: 'Open search' }, { label: 'Results with pull to refresh', results: true }],
  },
  {
    key: 'tags',
    title: 'Tag style',
    description: 'The same suggestions as tags (CollectionViewClassifyMenu); the keyboard waits for a tap.',
    demos: [{ label: 'Open search', style: 'tags', focuses: false }],
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
  return { background: dark ? '#000000' : '#FFFFFF', text: dark ? '#FFFFFF' : '#000000', secondary: dark ? '#AAAAAA' : '#666666' };
}

export default function App() {
  return (
    <SafeAreaProvider>
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
const TAB_ITEMS: CYLTabBarItem[] = [
  riveTab({ title: 'List style', image: 'system:list.bullet', selectedImage: 'system:list.bullet', identifier: 'list' }, 'CHAT'),
  riveTab({ title: 'Tag style', image: 'system:tag', selectedImage: 'system:tag.fill', identifier: 'tags' }, 'BELL'),
  riveTab({ title: 'Empty results', image: 'system:magnifyingglass', selectedImage: 'system:magnifyingglass', identifier: 'empty' }, 'SEARCH'),
  riveTab({ title: 'Discover', image: 'system:sparkle.magnifyingglass', selectedImage: 'system:sparkle.magnifyingglass', identifier: 'discover' }, 'USER'),
];
const PLUS_BUTTON: CYLTabBarPlusButton = {
  title: 'Search bar',
  // A 52 pt green PNG: `imageSize` would redraw an SF Symbol into a black bitmap.
  image: require('./assets/plus-button.png'),
  // No size, center or title alignment here: CYLTabBarController's core lays the raised plus button out (2026-11-17).
  identifier: 'plus',
  pageIdentifier: 'plus',
};

function Screens() {
  const palette = usePalette();
  // `-initialTab discover` (an iOS launch argument, read through Settings) opens a tab directly, for screenshots.
  const [tab, setTab] = useState<string>(() => (Platform.OS === 'ios' && typeof Settings.get('initialTab') === 'string' ? Settings.get('initialTab') : 'list'));
  const [open, setOpen] = useState<Demo | null>(null);
  if (open?.results) {
    return (
      <SafeAreaView style={[styles.fill, { backgroundColor: palette.background }]} edges={['top', 'bottom']}>
        <ResultsDemo onClose={() => setOpen(null)} />
      </SafeAreaView>
    );
  }
  if (open) {
    return (
      <SafeAreaView style={[styles.fill, { backgroundColor: palette.background }]} edges={['top', 'bottom']}>
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
    <SafeAreaView style={[styles.fill, { backgroundColor: palette.background }]} edges={['top', 'left', 'right']}>
      <View style={styles.fill}>
        {tab === 'bar' ? <SearchBarDemo /> : tab === 'discover' ? <DiscoverDemo /> : current ? (
          <View style={styles.page}>
            <Text style={[styles.title, { color: palette.text }]}>{current.title}</Text>
            <Text style={[styles.body, { color: palette.text }]}>{current.description}</Text>
            {current.demos.map((demo) => (
              <Pressable key={demo.label} accessibilityRole="button" style={styles.button} onPress={() => setOpen(demo)}>
                <Text style={styles.buttonText}>{demo.label}</Text>
              </Pressable>
            ))}
          </View>
        ) : null}
      </View>
      {/* CYLTabBarController's tab bar (react-native-cyltabbar): four tabs and a raised plus button for the search bar. */}
      <CYLTabBar
        style={styles.tabBar}
        items={TAB_ITEMS}
        plusButton={{ ...PLUS_BUTTON, titleColor: palette.text }}
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
      <Text style={[styles.title, { color: palette.text }]}>Search bar</Text>
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

/**
 * The discover demo (iOS CYLSearchDiscoverViewController, Android CYLSearchDiscoverFragment, the Flutter discover
 * page): the native search bar, the recent searches as native tags (folded behind a chevron), topics in two columns.
 */
function DiscoverDemo() {
  const palette = usePalette();
  const [recent, setRecent] = useState<string[]>(discoverData.recentSearches);
  const [offset, setOffset] = useState(0);
  const [barText, setBarText] = useState('');
  const typed = useRef('');
  const [message, setMessage] = useState('');
  const topics = useMemo(() => {
    const pool = discoverData.discover;
    return Array.from({ length: Math.min(discoverData.discoverCount, pool.length) }, (_, i) => pool[(offset + i) % pool.length])
      .filter((topic): topic is (typeof pool)[number] => topic !== undefined);
  }, [offset]);
  const search = (text: string) => {
    const query = text.trim();
    if (!query) return;
    setRecent((items) => [query, ...items.filter((item) => item !== query)]);
    setBarText(query);
    setMessage(`Searching: ${query}`);
  };
  return (
    <ScrollView contentContainerStyle={styles.page}>
      <Text style={[styles.title, { color: palette.text }]}>Discover</Text>
      {/* The field stays; the camera, a divider and the Search button are items appended inside its bordered capsule. */}
      <CYLSearchBarView
        style={styles.bar}
        text={barText}
        searchBarStyle="bordered"
        showsSearchIcon={false}
        fieldShadowOpacity={0.06}
        onTextChange={(event) => { typed.current = event.nativeEvent.text; }}
        onSubmit={(event) => search(event.nativeEvent.text)}
        items={[
          { style: 'icon', image: 'camera', title: 'Search by image', onPress: () => setMessage('Image search is not available in this demo') },
          { style: 'divider' },
          { style: 'text', title: 'Search', accessibilityIdentifier: 'CYLSearchDiscoverSearchButton', onPress: () => search(typed.current) },
        ]}
      />
      <View style={styles.header}>
        <Text accessibilityRole="header" style={[styles.section, { color: palette.text }]}>Recent searches</Text>
        <Pressable accessibilityRole="button" accessibilityLabel="Clear recent searches" onPress={() => { setRecent([]); setMessage('Recent searches cleared'); }}>
          <Text style={styles.action}>Clear</Text>
        </Pressable>
      </View>
      {recent.length > 0 ? (
        <CYLTagListView tags={recent} foldControlPosition="inline" foldControlContent="icon" foldedRowCount={2} onTagSelect={(event) => search(event.nativeEvent.title)} />
      ) : null}
      <View style={styles.header}>
        <Text accessibilityRole="header" style={[styles.section, { color: palette.text }]}>Discover</Text>
        <Pressable accessibilityRole="button" accessibilityLabel="Refresh topics" onPress={() => setOffset((value) => value + discoverData.discoverCount)}>
          <Text style={styles.action}>Refresh</Text>
        </Pressable>
      </View>
      <View style={styles.grid}>
        {topics.map((topic) => (
          <Pressable key={topic.title} accessibilityRole="button" style={styles.topic} onPress={() => search(topic.title)}>
            <Text numberOfLines={1} style={[styles.body, { color: palette.text }]}>{topic.title}{topic.icon === 'hot' ? '  HOT' : ''}</Text>
          </Pressable>
        ))}
      </View>
      {message ? <Text style={[styles.message, { color: palette.secondary }]}>{message}</Text> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  page: { padding: 16, gap: 12 },
  title: { fontSize: 22, fontWeight: '600' },
  body: { fontSize: 16 },
  button: { alignSelf: 'flex-start', backgroundColor: '#44608E', borderRadius: 20, paddingHorizontal: 18, paddingVertical: 10 },
  buttonText: { color: 'white', fontSize: 15, fontWeight: '600' },
  bar: { height: 52 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 },
  section: { fontSize: 17, fontWeight: '600' },
  action: { fontSize: 15, color: '#007AFF' },
  grid: { flexDirection: 'row', flexWrap: 'wrap' },
  topic: { width: '50%', paddingVertical: 10, paddingRight: 8 },
  message: { fontSize: 14, color: '#666' },
  // In the layout flow under the page: the bar takes its own height, the bottom safe area included.
  tabBar: { alignSelf: 'stretch' },
});
