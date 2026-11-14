import {
  CYLMenuFoldControl,
  CYLSearchBarComponent,
  CYLSearchBarItem,
  CYLSearchBarStyle,
  CYLSearchBarView,
  CYLSearchBarViewDelegate,
  CYLSearchComponent,
  CYLSearchSuggestionStyle,
  CYLSearchView
} from 'cylsearch';

/**
 * The Discover page, as in the iOS, Android, Flutter and React Native examples: the search bar with the camera, a
 * divider and Search appended inside its bordered capsule (core `CYLSearchBarItem`), recent searches as tags folded to
 * two rows behind the chevron, and a search page that opens over it.
 */
@Entry
@ComponentV2
struct Index {
  private bar: CYLSearchBarView = new CYLSearchBarView();
  private searchView: CYLSearchView = new CYLSearchView();
  @Local message: string = '';
  @Local recent: string[] = ['Swift concurrency', 'SwiftUI animations', 'Adapting to iOS 26 Liquid Glass',
    'Kotlin coroutines', 'Flutter plugins'];
  private typed: string = '';

  aboutToAppear(): void {
    this.bar.searchBarStyle = CYLSearchBarStyle.bordered;
    this.bar.searchIcon = undefined;
    this.bar.fieldHeight = 46;
    this.bar.fieldShadowOpacity = 0.06;
    this.bar.contentInsets = { top: 6, left: 12, bottom: 6, right: 12 };
    this.bar.itemTintColor = $r('sys.color.font_primary');
    this.bar.addItem(CYLSearchBarItem.iconItem($r('sys.symbol.camera'), 'Search by image', () => {
      this.message = 'Image search is not available in this demo';
    }));
    this.bar.addItem(CYLSearchBarItem.divider());
    const search = CYLSearchBarItem.textItem('Search', () => {
      this.search(this.typed);
    });
    search.itemAccessibilityIdentifier = 'CYLSearchDiscoverSearchButton';
    this.bar.addItem(search);
    const delegate: CYLSearchBarViewDelegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        this.typed = text;
      },
      searchBarViewSearchButtonClicked: (_: CYLSearchBarView) => {
        this.search(this.typed);
      }
    };
    this.bar.delegate = delegate;

    this.searchView.installInView(this.getUIContext().getHostContext() as Context);
    this.searchView.suggestions = ['Swift', 'SwiftUI', 'Kotlin', 'Flutter', 'React Native', 'HarmonyOS'];
    this.searchView.suggestionStyle = CYLSearchSuggestionStyle.tags;
    this.searchView.suggestionsFoldControl = new CYLMenuFoldControl();
    this.searchView.suggestionsFoldedRowCount = 2;
    this.searchView.showsEmptyResultsPlaceholder = true;
    this.searchView.suggestionCacheName = 'HarmonyOSExample';
    this.searchView.searchBarView.placeholder = 'Search';
  }

  private search(text: string): void {
    const query = text.trim();
    if (query.length === 0) {
      return;
    }
    this.recent = [query].concat(this.recent.filter((item: string) => item !== query));
    this.message = `Searching: ${query}`;
  }

  build() {
    Stack() {
      Column() {
        Text($r('app.string.discover_title'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, top: 24, bottom: 8 })
        CYLSearchBarComponent({ searchBarView: this.bar })
        Row() {
          Text('Recent searches').fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)
          Text('Open search')
            .fontSize(16)
            .fontColor($r('sys.color.brand'))
            .onClick(() => {
              this.searchView.showSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 24, bottom: 8 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.recent, (item: string) => {
            Text(item)
              .fontSize(15)
              .height(34)
              .padding({ left: 14, right: 14 })
              .margin({ right: 8, bottom: 8 })
              .borderRadius(17)
              .border({ width: 1, color: $r('sys.color.comp_divider') })
              .onClick(() => {
                this.search(item);
              })
          }, (item: string) => item)
        }
        .padding({ left: 16, right: 16 })
        .constraintSize({ maxHeight: 76 })
        .clip(true)
        Text(this.message)
          .fontSize(16)
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')
          .padding(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)

      CYLSearchComponent({ searchView: this.searchView })
    }
    .width('100%')
    .height('100%')
  }
}
