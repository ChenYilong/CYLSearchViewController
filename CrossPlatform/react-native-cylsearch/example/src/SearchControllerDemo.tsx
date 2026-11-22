import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { CYLSearchListView } from 'react-native-cylsearch';

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
 * first item is the search bar. The search shows the core's launch area while the text is empty (the recent searches
 * the history keeps, else the eight suggestions, as tags; a tapped tag submits), the matching keywords (twenty rows
 * each) with the match highlighted, "No matching results" when nothing matches, and ends with a swipe from the edge.
 *
 * One `CYLSearchListView` on both platforms, configured through its API only: this screen builds no launch view, no
 * tags, no clear button, no highlight and no list of its own.
 */
export function SearchControllerDemo({ onClose }: { onClose: () => void }) {
  const [text, setText] = useState('');
  const [results, setResults] = useState<string[]>([]);
  const [status, setStatus] = useState('Events: none');
  const note = (event: string) =>
    setStatus(
      (previous) =>
        `Events: ${event} | ${previous.replace('Events: ', '').split(' | ')[0]}`
    );
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
      <Text accessibilityLabel="Event status" style={styles.status}>
        {status}
      </Text>
      <CYLSearchListView
        style={styles.fill}
        rows={KEYWORDS}
        placeholder="Search"
        results={results}
        resultsQuery={text}
        highlightsResultMatches
        noResultsText="No matching results"
        suggestions={SUGGESTIONS}
        suggestionCachePolicy="userDefaults"
        suggestionCacheName="CYLSearchControllerDemoRN"
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
        onSubmit={(event) => note(`submit "${event.nativeEvent.text}"`)}
        onHistoryChange={(event) =>
          note(`history "${event.nativeEvent.query}"`)
        }
        onSelectRow={(event) => note(`row ${event.nativeEvent.row}`)}
        onSelectResult={(event) => note(`result ${event.nativeEvent.result}`)}
      />
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
});
