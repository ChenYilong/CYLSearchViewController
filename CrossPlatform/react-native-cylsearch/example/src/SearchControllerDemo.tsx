import { useMemo, useState } from 'react';
import {
  FlatList,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';
import {
  CYLSearchBarView,
  CYLSearchListView,
  CYLTagListView,
  cylSplitMatch,
} from 'react-native-cylsearch';

/**
 * The keywords of QDSearchViewController (QMUIDemo_iOS), as in the iOS and Android examples.
 */
export const KEYWORDS = [
  'Helps',
  'Maintain',
  'Liver',
  'Health',
  'Function',
  'Supports',
  'Healthy',
  'Fat',
  'Metabolism',
  'Nuturally',
];

/**
 * The eight suggestions of the launch view while there is no history (QDRecentSearchView).
 */
export const SUGGESTIONS = KEYWORDS.slice(0, 8);

/**
 * The rows each matching keyword gets in the results (QDSearchViewController: `matches.count * 20`).
 */
export const ROWS_PER_MATCH = 20;

/**
 * The keywords that contain the text (case sensitive, QMUI's `range(of:)`); none for an empty text.
 */
export function matches(text: string): string[] {
  return text.length === 0
    ? []
    : KEYWORDS.filter((keyword) => keyword.includes(text));
}

/**
 * The results of a text: every matching keyword ROWS_PER_MATCH times.
 */
export function resultsFor(text: string): string[] {
  return matches(text).flatMap((keyword) =>
    Array.from({ length: ROWS_PER_MATCH }, () => keyword)
  );
}

/**
 * The "Search controller" screen: a replica of QMUI's QDSearchViewController (QMUIDemo_iOS). Ten keywords in a list whose
 * first item is the search bar. The search shows the recent searches while the text is empty (the history keeps the
 * submitted queries, with a clear button), the matching keywords (twenty rows each) with the match in the tint color,
 * "No matching results" when nothing matches, and ends with a swipe from the edge.
 *
 * Android: the core's `CYLSearchListView` and `CYLSearchView` through `CYLSearchListView` (react-native-cylsearch). iOS:
 * example-only composition of the bridged `CYLSearchBarView` and `CYLTagListView` until the iOS merge puts the launch view, the
 * results and the events into the base classes (TODO, docs/qmui-search-controller.md).
 */
export function SearchControllerDemo({ onClose }: { onClose: () => void }) {
  return (
    <View style={styles.fill}>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Back"
        onPress={onClose}
        style={styles.back}
      >
        <Text style={styles.backText}>Back</Text>
      </Pressable>
      {Platform.OS === 'android' ? (
        <AndroidController />
      ) : (
        <ComposedController />
      )}
    </View>
  );
}

function AndroidController() {
  const [text, setText] = useState('');
  const [results, setResults] = useState<string[]>([]);
  const [status, setStatus] = useState('Events: none');
  const note = (event: string) =>
    setStatus(
      (previous) =>
        `Events: ${event} | ${previous.replace('Events: ', '').split(' | ')[0]}`
    );
  return (
    <>
      <Text accessibilityLabel="Event status" style={styles.status}>
        {status}
      </Text>
      <CYLSearchListView
        style={styles.fill}
        rows={KEYWORDS}
        placeholder="Search"
        results={results}
        resultsQuery={text}
        emptyViewText="No matching results"
        launchTitle="Recent searches"
        launchSuggestions={SUGGESTIONS}
        launchLabel="Recent searches"
        clearHistoryLabel="Clear recent searches"
        historyPolicy="userDefaults"
        historyName="CYLSearchControllerDemoRN"
        supportsSwipeToDismissSearch
        onUpdateResults={(event) => {
          const next = event.nativeEvent.text;
          setText(next);
          setResults(resultsFor(next));
          note(`update "${next}"`);
        }}
        onWillPresent={() => note('willPresent')}
        onDidPresent={() => note('didPresent')}
        onWillDismiss={() => note('willDismiss')}
        onDidDismiss={() => note('didDismiss')}
        onHistoryChange={(event) =>
          note(`history "${event.nativeEvent.query}"`)
        }
        onSelectRow={(event) => note(`row ${event.nativeEvent.row}`)}
        onSelectResult={(event) => note(`result ${event.nativeEvent.result}`)}
      />
    </>
  );
}

function ComposedController() {
  const dark = useColorScheme() === 'dark';
  const [text, setText] = useState('');
  const [history, setHistory] = useState<string[]>([]);
  const found = useMemo(() => resultsFor(text), [text]);
  const color = dark ? '#FFFFFF' : '#000000';
  const submit = (query: string) => {
    const trimmed = query.trim();
    if (trimmed)
      setHistory((items) => [
        trimmed,
        ...items.filter((item) => item !== trimmed),
      ]);
  };
  const tags = history.length > 0 ? history : SUGGESTIONS;
  return (
    <View style={styles.fill}>
      <CYLSearchBarView
        style={styles.bar}
        placeholder="Search"
        showsCancelButton={text.length > 0}
        onTextChange={(event) => setText(event.nativeEvent.text)}
        onSubmit={(event) => submit(event.nativeEvent.text)}
        onCancel={() => setText('')}
      />
      {text.length === 0 ? (
        <View style={styles.launch}>
          <View style={styles.launchHeader}>
            <Text
              accessibilityRole="header"
              style={[styles.launchTitle, { color }]}
            >
              Recent searches
            </Text>
            {history.length > 0 ? (
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="Clear recent searches"
                onPress={() => setHistory([])}
              >
                <Text style={styles.action}>Clear</Text>
              </Pressable>
            ) : null}
          </View>
          <CYLTagListView tags={tags} foldControlPosition="none" />
          <FlatList
            data={KEYWORDS}
            keyExtractor={(item) => item}
            renderItem={({ item }) => (
              <Text style={[styles.row, { color }]}>{item}</Text>
            )}
          />
        </View>
      ) : found.length === 0 ? (
        <Text style={[styles.empty, { color }]}>No matching results</Text>
      ) : (
        <FlatList
          data={found}
          keyExtractor={(_, index) => String(index)}
          renderItem={({ item }) => {
            const { before, match, after } = cylSplitMatch(item, text);
            return (
              <Text style={[styles.row, { color }]}>
                {before}
                <Text style={styles.match}>{match}</Text>
                {after}
              </Text>
            );
          }}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  back: { alignSelf: 'flex-start', paddingHorizontal: 16, paddingVertical: 8 },
  backText: { color: '#007AFF', fontSize: 17 },
  status: {
    paddingHorizontal: 16,
    paddingBottom: 4,
    fontSize: 12,
    color: '#888888',
  },
  bar: { height: 56 },
  launch: { flex: 1, padding: 26 },
  launchHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  launchTitle: { fontSize: 14 },
  action: { fontSize: 15, color: '#007AFF' },
  row: { fontSize: 17, paddingVertical: 16, paddingHorizontal: 16 },
  match: { color: '#0068F8' },
  empty: { fontSize: 17, textAlign: 'center', marginTop: 48 },
});
