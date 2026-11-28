> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# React Native example: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CrossPlatform/react-native-cylsearch/.yarnrc.yml` | 4 |
| `CrossPlatform/react-native-cylsearch/example/android/app/build.gradle` | 132 |
| `CrossPlatform/react-native-cylsearch/example/android/app/src/main/AndroidManifest.xml` | 30 |
| `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainActivity.kt` | 22 |
| `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainApplication.kt` | 27 |
| `CrossPlatform/react-native-cylsearch/example/android/build.gradle` | 31 |
| `CrossPlatform/react-native-cylsearch/example/android/gradle.properties` | 48 |
| `CrossPlatform/react-native-cylsearch/example/android/settings.gradle` | 23 |
| `CrossPlatform/react-native-cylsearch/example/app.json` | 4 |
| `CrossPlatform/react-native-cylsearch/example/babel.config.js` | 12 |
| `CrossPlatform/react-native-cylsearch/example/Gemfile` | 17 |
| `CrossPlatform/react-native-cylsearch/example/index.js` | 11 |
| `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/AppDelegate.swift` | 11 |
| `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/SceneDelegate.swift` | 56 |
| `CrossPlatform/react-native-cylsearch/example/ios/Podfile` | 67 |
| `CrossPlatform/react-native-cylsearch/example/jest.config.js` | 3 |
| `CrossPlatform/react-native-cylsearch/example/metro.config.js` | 30 |
| `CrossPlatform/react-native-cylsearch/example/package.json` | 43 |
| `CrossPlatform/react-native-cylsearch/example/react-native.config.js` | 21 |
| `CrossPlatform/react-native-cylsearch/example/src/App.tsx` | 595 |
| `CrossPlatform/react-native-cylsearch/example/src/ContactTagsDemo.tsx` | 352 |
| `CrossPlatform/react-native-cylsearch/example/src/SearchBarStylesDemo.tsx` | 201 |
| `CrossPlatform/react-native-cylsearch/example/src/SearchControllerDemo.tsx` | 123 |
| `CrossPlatform/react-native-cylsearch/example/vite.config.mjs` | 17 |

## `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainActivity.kt`

- L8 `class MainActivity : ReactActivity()`

## `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainApplication.kt`

- L10 `class MainApplication : Application(), ReactApplication`

## `CrossPlatform/react-native-cylsearch/example/android/gradle.properties`

Project-wide Gradle settings. IDE (e.g. Android Studio) users: Gradle settings configured through the IDE *will override* any settings specified in this file. For more details on how to configure your build environment visit http://www.gradle.org/docs/current/userguide/build_environment.html Specifies the JVM arguments used for the daemon process. The setting is particularly useful for tweaking me

## `CrossPlatform/react-native-cylsearch/example/babel.config.js`

- L5 `const root = path.resolve(__dirname, '..');`

## `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/AppDelegate.swift`

- L4 `class AppDelegate: UIResponder, UIApplicationDelegate`

## `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/SceneDelegate.swift`

- L6 `class SceneDelegate: RCTDefaultReactNativeFactoryDelegate, UIWindowSceneDelegate`

## `CrossPlatform/react-native-cylsearch/example/ios/Podfile`

Resolve react_native_pods.rb with node to allow for hoisting

## `CrossPlatform/react-native-cylsearch/example/metro.config.js`

- L5 `const root = path.resolve(__dirname, '..');`
- L13 `const config = withMetroConfig(getDefaultConfig(__dirname),` — Metro configuration https://facebook.github.io/metro/docs/configuration @type {import('metro-config').MetroConfig}
- L22 `const tabBar = path.resolve(__dirname, 'vendor/CYLTabBarController/CrossPlatform/react-native-cyltabbar');` — CYLTabBarController's tab bar is not part of this monorepo (vendor/, scripts/fetch-cyltabbar.sh): Metro reads its TypeScript sources directly instead of its unbuilt `lib/`.
- L24 `const resolveRequest = config.resolver.resolveRequest;`

## `CrossPlatform/react-native-cylsearch/example/src/App.tsx`

The suggestions of MaterialSearchView's Default sample, as in the iOS, Android and Flutter examples.

- L14 `const SUGGESTIONS = [` — The suggestions of MaterialSearchView's Default sample, as in the iOS, Android and Flutter examples.
- L21 `type Demo =`
- L45 `type Tab = { key: string; title: string; description: string; demos: Demo[] };`
- L51 `const DEMO_LABEL_KEYS: Record<string, string> = {"Open search": "demo.openSearch", "Results with pull to refresh": "demo.resultsRefresh", "Search controller": "demo.searchController", "Search bar styl` — The key of each demo button's text in `search-discover.json` (the demo's English label is its identity).
- L53 `const TABS: Tab[] = [`
- L82 `function usePalette()` — The colors of the light or dark scheme, so the example follows the system as the native views do.
- L89 `export default function App()`
- L105 `const TAB_KEYS = ['list', 'tags', 'empty', 'discover'];` — The tab bar: the three sample tabs and Discover, as in the native and Flutter examples; the plus button opens the search bar page and rises above the bar (AGENTS.md, "Raised plus button").
- L110 `function riveTab(item: CYLTabBarItem, artboard: string): CYLTabBarItem` — Rive tab icons: each tab plays an artboard of CYLTabBarController's icons.riv (its state machine input "active"), as CYLTabBarController's example-rive; the symbol stays as the image before the file loads. The file comes from the pinned CYLTabBarController che
- L120 `function tabItems(text: Record<string, string>): CYLTabBarItem[]`
- L132 `function svgaTab(item: CYLTabBarItem, file: string): CYLTabBarItem` — SVGA tab icons (the SVGA counterpart of the Rive scene, as the iOS, native Android, Flutter and HarmonyOS examples): CYLTabBarController plays CYLTabBarSVGAFilePath through the app's SVGA player (Android: SVGAPlayer-Android; iOS: the CYLAnimatedItem/SVGA subsp
- L135 `function svgaTabItems(text: Record<string, string>): CYLTabBarItem[]`
- L144 `function plusButton(text: Record<string, string>): CYLTabBarPlusButton`
- L155 `function Screens()`
- L267 `function ResultsDemo({ onClose }: { onClose: () => void })` — The search page with results: each query lists the matching languages through the core's results list (instead of the suggestions); pulling the list down refreshes it (the core's refresh API, CYLTableViewPlaceHolder's header).
- L312 `function SearchBarDemo()` — The native search bar inline, its text and search shown below; then the same bar in multiple mode, several searches side by side.
- L356 `function discoverLanguage()` — The discover demo's texts for the device language (en, ja, zh-Hans, zh-Hant), English when it is not held.
- L365 `const HOT_ICONS: Record<string, { source: number }> =`
- L372 `function hotIconForLanguage()`
- L377 `function discoverContent()` — The discover demo's sample data (recent searches and topics) for the device language, English when not held.
- L383 `function topicsOnPage(page: number)` — The topics of `page` (the pages wrap around the pool): `discoverCount` records, each with its own hot mark.
- L395 `function nextPage(page: number)` — The page after `page`, cyclically: refresh shows the next page, so the hot topic (one per page) moves every time.
- L401 `function discoverStrings()`
- L412 `const TAB_LOOKS: Record<string, { navigationFieldStyle?: boolean; searchBarStyle?: string; showsSearchIcon?: boolean; fieldShadowOpacity?: number; centersPlaceholder?: boolean; camera?: boolean }> =` — One search bar look per tab (CYLTabBarController owns the tabs, each tab root owns its bar): the same props on both levels.
- L424 `function FirstLevelBar({ tabKey, onOpen }: { tabKey: string; onOpen: () => void })` — The first-level page's search bar: the WHOLE bar in the navigation bar, full width inside the safe area (no back button). A tap on the field does not edit: the native core brings the back button in (animated), shrinks the bar, and sends `onFirstLevelTap`, wher
- L449 `function DiscoverEntry()` — The entry of the Discover tab: a one-row page that opens the Discover page (iOS `CYLSearchDiscoverEntryViewController`).
- L470 `function DiscoverDemo({ tabKey, onBack }: { tabKey: string; onBack: () => void })`
- L575 `const styles = StyleSheet.create(`

## `CrossPlatform/react-native-cylsearch/example/src/ContactTagsDemo.tsx`

- L16 `type Tag = { id: string; title: string };` — The contact tags demo (iOS CYLContactRemarkViewController, CYLContactTagEditorViewController, CYLContactListViewController): Edit Remarks, Edit Tags with this library's search bar and CollectionViewClassifyMenu's tag lists (ids, selection, Manage with crosses 
- L17 `type Contact = { name: string; tags: string[] };`
- L19 `const GREEN = '#07C160';`
- L20 `const LINK = '#576B95';`
- L22 `function text(key: string, ...args: (string | number)[]): string`
- L29 `class Store` — The user's tags (iOS CYLContactTagStore), keyed by id.
- L83 `function makeStore(empty: boolean)`
- L88 `function HUD({ hud }: { hud: { status: string; done: boolean } | null })` — A HUD as CYLPlaceholderHUD shows it: a spinner or a check mark above a status.
- L100 `export function ContactTagsDemo({ onClose, empty = false, latency = 5 }: { onClose: () => void; empty?: boolean; latency?: number })`
- L159 `function Bar({ title, onBack, right }: { title: string; onBack: () => void; right?: React.ReactNode })`
- L169 `function Editor({ store, latency, initial, onCancel, onDone, onContacts }:`
- L315 `const styles = StyleSheet.create(`

## `CrossPlatform/react-native-cylsearch/example/src/SearchBarStylesDemo.tsx`

- L18 `const COLORS = [`
- L30 `function accessory(index: number): CYLSearchBarAccessory` — A 30 x 30 stroked rounded square in one of QDSearchBarViewController's colors.
- L46 `export function SearchBarStylesDemo({ onClose }: { onClose: () => void })` — The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController (QMUIDemo_iOS). Sections Placeholder, Layout and AccessoryView drive one search bar: a centered placeholder, a changed (long) placeholder, margins of the field at rest (32) and of Ca
- L174 `const styles = StyleSheet.create(`

## `CrossPlatform/react-native-cylsearch/example/src/SearchControllerDemo.tsx`

The keywords of QDSearchViewController (QMUIDemo_iOS), as in the iOS and Android examples.

- L8 `export const KEYWORDS = [` — The keywords of QDSearchViewController (QMUIDemo_iOS), as in the iOS and Android examples.
- L24 `export const SUGGESTIONS = KEYWORDS.slice(0, 8);` — The eight suggestions of the launch view while there is no history (QDRecentSearchView).
- L29 `export const ROWS_PER_MATCH = 20;` — The rows each matching keyword gets in the results (QDSearchViewController: `matches.count * 20`).
- L34 `export function matches(text: string): string[]` — The keywords that contain the text (case sensitive, QMUI's `range(of:)`); none for an empty text.
- L43 `export function resultsFor(text: string): string[]` — The results of a text: every matching keyword ROWS_PER_MATCH times.
- L58 `export function SearchControllerDemo({ onClose }: { onClose: () => void })` — The "Search controller" screen: a replica of QMUI's QDSearchViewController (QMUIDemo_iOS). Ten keywords in a list whose first item is the search bar. The search shows the core's launch area while the text is empty (the recent searches the history keeps, else t
- L113 `const styles = StyleSheet.create(`
