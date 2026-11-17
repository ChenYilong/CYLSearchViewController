# react-native-cylsearch

CYLSearchViewController (iOS) and its Android port as React Native Fabric components

## Installation


```sh
npm install react-native-cylsearch
```


## Usage

The components follow the classes of the native search core (`CYLSearchBar`: iOS `Sources/CYLSearchBar`, Android
`com.cyl.search`, see `docs/search-core-merge.md` in the repository):

| Component | Native class | Main props and events |
| :--- | :--- | :--- |
| `CYLSearchBarView` | `CYLSearchBarView` | `placeholder`, `text`, `items`, `mode` (`single` or `multiple`), `searches`, `onTextChange` (text, index), `onSubmit`, `onCompleteSearch`, `onRemoveSearch`, `onSelectSearch` |
| `CYLSearchView` | `CYLSearchView` | `suggestions`, `suggestionStyle`, `results` (shown through the core's `resultsDataSource`), `onSelectResult`, `refreshEnabled`, `refreshing`, `onRefresh`, `onClose` |
| `CYLTagListView` | CollectionViewClassifyMenu `CYLTagListView` | `tags`, `foldControlPosition`, `onTagSelect` |

```tsx
import { CYLSearchBarView, CYLSearchView } from 'react-native-cylsearch';

<CYLSearchBarView style={{ height: 52 }} mode="multiple" searches={['Swift']} onCompleteSearch={(e) => {}} />

<CYLSearchView
  style={{ flex: 1 }}
  results={results}
  onTextChange={(e) => setQuery(e.nativeEvent.text)}
  refreshEnabled
  refreshing={refreshing}
  onRefresh={() => {
    setRefreshing(true);
    reload().finally(() => setRefreshing(false));
  }}
  onClose={goBack}
/>
```

The empty-results placeholder and the pull-to-refresh header come from CYLTableViewPlaceHolder through the core; the
package depends on no other search library.

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
