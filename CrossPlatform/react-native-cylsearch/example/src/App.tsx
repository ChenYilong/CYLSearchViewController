import { useMemo, useRef, useState } from 'react';
import { Platform, Pressable, ScrollView, Settings, StyleSheet, Text, useColorScheme, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { CYLSearchBarView, CYLSearchView, CYLTagListView } from 'react-native-cylsearch';
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
};

type Tab = { key: string; title: string; description: string; demos: Demo[] };

/**
 * One tab per kind of demo, as the Flutter example (the plus button's search bar demo and Discover are their own).
 */
const TABS: Tab[] = [
  { key: 'list', title: 'List style', description: 'Suggestions as a list, filtered as you type.', demos: [{ label: 'Open search' }] },
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

function Screens() {
  const palette = usePalette();
  // `-initialTab discover` (an iOS launch argument, read through Settings) opens a tab directly, for screenshots.
  const [tab, setTab] = useState<string>(() => (Platform.OS === 'ios' && typeof Settings.get('initialTab') === 'string' ? Settings.get('initialTab') : 'list'));
  const [open, setOpen] = useState<Demo | null>(null);
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
    <SafeAreaView style={[styles.fill, { backgroundColor: palette.background }]}>
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
      {/* Each tab is its own accessibility element (a "tablist" container hid them from iOS accessibility). */}
      <View style={styles.tabs}>
        {[...TABS.map((item) => ({ key: item.key, title: item.title })), { key: 'bar', title: 'Search bar' }, { key: 'discover', title: 'Discover' }].map((item) => (
          <Pressable key={item.key} accessible accessibilityRole="tab" accessibilityLabel={item.title} accessibilityState={{ selected: tab === item.key }} style={styles.tab} onPress={() => setTab(item.key)}>
            <Text style={[styles.tabText, tab === item.key && styles.tabSelected]}>{item.title}</Text>
          </Pressable>
        ))}
      </View>
    </SafeAreaView>
  );
}

/**
 * The native search bar inline, its text and search shown below.
 */
function SearchBarDemo() {
  const palette = usePalette();
  const [status, setStatus] = useState('Text: ');
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
  tabs: { flexDirection: 'row', borderTopWidth: StyleSheet.hairlineWidth, borderColor: '#ccc' },
  tab: { flex: 1, alignItems: 'center', paddingVertical: 10 },
  tabText: { fontSize: 11, color: '#888' },
  tabSelected: { color: '#007AFF', fontWeight: '600' },
});
