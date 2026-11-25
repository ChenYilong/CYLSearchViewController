import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  CYLMenuFoldControl,
  CYLMenuFoldControlContent,
  CYLMenuFoldControlPosition,
  CYLSearchComponent,
  CYLSearchSuggestionCachePolicy,
  CYLSearchSuggestionStyle,
  CYLSearchView
} from 'cylsearch';
import {
  CYLDemoNavBar,
  cylDemoText,
  CYLDemoRoute,
  CYLMaterialSampleParam,
  CYLSnackbar,
  CYLSnackbarView,
  CYL_PLUS_OVERHANG
} from '../common/DemoCommon';
import { CYLDemoTagMenuView, CYLDemoTagRow, CYLDemoTagSection } from '../common/DemoTagMenu';
import { CYLSpeechRecognizer } from '../common/SpeechRecognizer';

/**
 * The sample screens of MiguelCatalan/MaterialSearchView (iOS `CYLMaterialSearchSample`).
 */
export enum CYLMaterialSearchSample {
  standard = 0,
  themed = 1,
  voice = 2,
  sticky = 3,
  tabs = 4,
  inputType = 5
}

const SAMPLE_KEYS: string[] = ['demo.port.default', 'demo.port.themed', 'demo.port.voice', 'demo.port.sticky',
  'demo.port.tab', 'demo.port.inputType'];

/**
 * `R.array.query_suggestions` of the sample.
 */
export const CYL_MATERIAL_SUGGESTIONS: string[] = [
  'A very very long suggestion that would span multiple lines.', 'Android', 'iOS', 'SCALA', 'Ruby',
  'JavaScript', 'C#', 'Python', 'C', 'C++', 'PHP', 'Go', 'Perl', 'Bash', 'Lua', 'R', 'TCL', 'Haskell',
  'Objective C', 'Swift', 'Kotlin', 'jQuery', 'Development', 'Web', 'Ajax', 'Test', 'Testing', 'CookBook',
  'Beagle', 'VMware', 'Less.js', 'IDE', 'Arduino', 'Xamarin', 'UI', 'Microsoft', 'Application', 'Development',
  'JUnit', 'SQL', 'Beagle'
];

/**
 * Port of MaterialSearchView's sample `MainActivity` (iOS `CYLMaterialSearchMenuViewController`): one row per sample.
 * The Tag style tab shows the same menu with `tags` (suggestions as tags, the keyboard down on show).
 */
@ComponentV2
export struct MaterialMenuView {
  @Require @Param stack: NavPathStack;
  @Param tags: boolean = false;
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private samples: number[] = [0, 1, 2, 3, 4, 5];

  // One titled section, a glass tag per sample (docs/instructions/example-demos.md).
  private tagSections(): CYLDemoTagSection[] {
    const rows: CYLDemoTagRow[] = this.samples.map((sample: number): CYLDemoTagRow => {
      const row: CYLDemoTagRow = { title: cylDemoText(this.context, SAMPLE_KEYS[sample]), subtitle: '', image: undefined };
      return row;
    });
    return [new CYLDemoTagSection('MaterialSearchView', rows)];
  }

  build() {
    Column() {
      CYLDemoNavBar({
        title: 'MaterialSearchView',
        showsBack: this.showsBack,
        barColor: Color.Transparent,
        onBack: () => this.onBack()
      })
      Scroll() {
        CYLDemoTagMenuView({
          sections: this.tagSections(),
          tagId: 'CYLDemoMaterialTags',
          onSelect: (section: number, item: number) => {
            const param: CYLMaterialSampleParam = { sample: item, tags: this.tags, focusesSearchFieldOnShow: !this.tags && AppStorage.get<number>('CYLDebugNoFocus') !== 1 };
            this.stack.pushPath({ name: CYLDemoRoute.materialSample, param: param });
          }
        })
      }
      .margin({ bottom: CYL_PLUS_OVERHANG })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
      // A gradient page (docs/instructions/example-demos.md rule 7); the tag list draws no background, so the glass sits on it.
      .linearGradient({ angle: 135, colors: [['#7FB7FF', 0.0], ['#FF9EC7', 0.5], ['#FFC27A', 1.0]] })
  }
}

/**
 * The menu pushed from the ports list.
 */
@ComponentV2
export struct MaterialMenuPage {
  @Require @Param stack: NavPathStack;

  build() {
    NavDestination() {
      MaterialMenuView({ stack: this.stack, showsBack: true, onBack: () => this.stack.pop() })
    }
    .hideTitleBar(true)
  }
}

/**
 * One sample screen (iOS `CYLMaterialSearchSampleViewController`): a bar with a search item that opens a
 * `CYLSearchView` over the bar with the sample's suggestions; a submitted query shows "Query: …" in a snackbar and
 * closes the search, as `onQueryTextSubmit` returning false does.
 */
@ComponentV2
export struct MaterialSamplePage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLMaterialSampleParam;
  @Local showsNavigationBar: boolean = true;
  @Local tab: number = 0;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private searchView: CYLSearchView = new CYLSearchView();
  private snackbar: CYLSnackbar = new CYLSnackbar();
  private speech: CYLSpeechRecognizer = new CYLSpeechRecognizer();

  private title(): string {
    return cylDemoText(this.context, SAMPLE_KEYS[this.param.sample]);
  }

  aboutToAppear(): void {
    const sample = this.param.sample as CYLMaterialSearchSample;
    const colored = sample === CYLMaterialSearchSample.themed || sample === CYLMaterialSearchSample.voice;
    const bar = this.searchView.searchBarView;
    this.searchView.installInView(this.context);
    // searchView.setVoiceSearch, setCursorDrawable, setEllipsize, setSuggestions and the two listeners.
    bar.showsVoiceButton = sample === CYLMaterialSearchSample.voice;
    bar.cursorColor = colored ? Color.White : $r('app.color.system_pink');
    bar.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
    this.searchView.suggestionLineBreakMode = sample === CYLMaterialSearchSample.standard ||
      sample === CYLMaterialSearchSample.inputType ? TextOverflow.Ellipsis : TextOverflow.None;
    this.searchView.suggestions = sample === CYLMaterialSearchSample.sticky ? [] : CYL_MATERIAL_SUGGESTIONS;
    this.searchView.suggestionStyle = this.param.tags ? CYLSearchSuggestionStyle.tags : CYLSearchSuggestionStyle.list;
    // The tags end with the fold chevron, two rows while folded, as on the Discover page.
    this.searchView.suggestionsFoldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.inline,
      CYLMenuFoldControlContent.icon);
    this.searchView.suggestionsFoldedRowCount = 2;
    // A query that matches nothing shows the "no search results" state.
    this.searchView.showsEmptyResultsPlaceholder = true;
    // Submitted queries are cached in the core's database, one cache for these samples.
    this.searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.database;
    this.searchView.suggestionCacheName = 'MaterialSearchView';
    this.searchView.focusesSearchFieldOnShow = this.param.focusesSearchFieldOnShow;
    bar.isSecureTextEntry = sample === CYLMaterialSearchSample.inputType;
    if (colored) {
      // The colored theme: white text on the primary color.
      this.searchView.backgroundColor = $r('app.color.system_indigo');
      bar.textColor = Color.White;
      bar.placeholderColor = 'rgba(255, 255, 255, 0.7)';
      bar.searchIconTintColor = Color.White;
      bar.fieldBackgroundColor = 'rgba(255, 255, 255, 0.15)';
      this.searchView.suggestionTextColor = Color.White;
      this.searchView.suggestionImageTintColor = 'rgba(255, 255, 255, 0.8)';
      this.searchView.dividerColor = 'rgba(255, 255, 255, 0.3)';
    }
    this.searchView.delegate = {
      // The navigation bar comes back when the search closes.
      searchViewDidClose: () => {
        this.showsNavigationBar = true;
      },
      searchViewDidSubmitText: (_: CYLSearchView, text: string) => {
        this.snackbar.show(cylDemoText(this.context, 'demo.port.query', text));
        return false;
      },
      searchViewVoiceButtonClicked: (view: CYLSearchView) => {
        // REQUEST_VOICE + onActivityResult: the first result becomes the query, without submitting it.
        view.searchBarView.placeholder = cylDemoText(this.context, 'demo.port.listening');
        this.speech.recognize(this.context as common.UIAbilityContext, (text?: string) => {
          view.searchBarView.placeholder = undefined;
          if (text !== undefined && text.length > 0) {
            view.setQuery(text, false);
          } else {
            this.snackbar.show(cylDemoText(this.context, 'demo.port.voiceUnavailable'));
          }
        });
      }
    };
  }

  // The search item: the whole search bar takes the navigation bar's place.
  private openSearch(): void {
    hilog.info(0x0000, 'testTag', 'openSearch debugQuery=%{public}s', String(AppStorage.get<string>('CYLDebugQuery')));
    this.showsNavigationBar = false;
    this.searchView.showSearch();
    // Debug: `--pi CYLDebugQuery e` sets the query without typing (no keyboard), so the suggestions list can be swiped in tests.
    const debugQuery = AppStorage.get<string>('CYLDebugQuery');
    if (debugQuery !== undefined && debugQuery.length > 0) {
      // After the open state is drawn and the search field exists, so the text is not lost.
      setTimeout(() => {
        this.searchView.setQuery(debugQuery, false);
        hilog.info(0x0000, 'testTag', 'CYLDebugQuery applied %{public}s', debugQuery);
      }, 600);
    }
  }

  aboutToDisappear(): void {
    if (this.searchView.isSearchOpen) {
      this.searchView.closeSearch(false);
    }
  }

  @Builder
  content() {
    if (this.param.sample === CYLMaterialSearchSample.sticky) {
      // StickyActivity: a long list scrolls under the sticky bar.
      List() {
        ForEach(Array.from<number, number>({ length: 60 }, (_: number, i: number) => i + 1), (i: number) => {
          ListItem() {
            Text(cylDemoText(this.context, 'demo.port.item', i)).fontSize(17).padding({ left: 16, right: 16, top: 10, bottom: 10 })
          }
        }, (i: number) => `${i}`)
      }
      .contentEndOffset(CYL_PLUS_OVERHANG)
      .layoutWeight(1)
    } else if (this.param.sample === CYLMaterialSearchSample.tabs) {
      // TabActivity: three pages under tabs.
      Column({ space: 24 }) {
        Row() {
          ForEach([1, 2, 3], (page: number) => {
            Text(cylDemoText(this.context, 'demo.port.page', page))
              .fontSize(14)
              .layoutWeight(1)
              .height(32)
              .textAlign(TextAlign.Center)
              .borderRadius(7)
              .backgroundColor(this.tab === page - 1 ? $r('sys.color.background_primary') : Color.Transparent)
              .onClick(() => {
                this.tab = page - 1;
              })
          }, (page: number) => `${page}`)
        }
        .padding(2)
        .borderRadius(9)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        Text(cylDemoText(this.context, 'demo.port.page', this.tab + 1)).fontSize(22).width('100%').textAlign(TextAlign.Center)
      }
      .padding(16)
      Blank()
    } else {
      Text(this.title()).fontSize(22).width('100%').textAlign(TextAlign.Center).layoutWeight(1)
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (this.showsNavigationBar) {
            CYLDemoNavBar({
              title: this.title(),
              showsBack: true,
              rightSymbol: $r('sys.symbol.magnifyingglass'),
              rightLabel: cylDemoText(this.context, 'demo.port.open'),
              rightId: 'CYLMaterialOpenSearch',
              onBack: () => this.stack.pop(),
              onRight: () => this.openSearch()
            })
          } else {
            Row().height(44)
          }
          this.content()
        }
        .width('100%')
        .height('100%')
        CYLSearchComponent({ searchView: this.searchView })
        CYLSnackbarView({ snackbar: this.snackbar })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .onBackPressed(() => this.searchView.handleBackPress())
  }
}
