import { common } from '@kit.AbilityKit';
import {
  CYLConfiguredTabBarItem,
  CYLPlusButton,
  CYLPlusButtonPageIndex,
  CYLTabBarConfiguration,
  CYLTabBarConfigurationResult,
  CYLTabBarController,
  CYLTabBarItemAttributes
} from 'cyltabbar';
import { cylAppText, CYLDemoRoute, CYLMaterialSampleParam, CYLPlaceholderDetailParam } from '../common/DemoCommon';
import { SearchExamplePage, SearchExampleView } from '../demos/SearchExample';
import { ExamplesMenuView, PlaceholderDetailPage, PlaceholderGalleryPage } from '../demos/ExamplesMenu';
import { PortsMenuPage, SearchBarDemoPage, SearchBarDemoView } from '../demos/SearchBarDemo';
import { MaterialMenuPage, MaterialMenuView, MaterialSamplePage } from '../demos/MaterialSearch';
import { LapismPage, MultiSearchDemoPage, RevealPage, YechaoaPage } from '../demos/Ports';
import { DiscoverView } from '../demos/Discover';

/**
 * The tab icons of CYLTabBarConfiguration.json ("system:<SF Symbol>"), drawn in the unselected and selected colors
 * of UITabBar; a selected image name carries "#selected" (see `cylMarkSelectedImages`).
 */
function cylTabImage(name: string): ResourceStr | undefined {
  const selected = name.endsWith('#selected');
  const symbol = name.replace('#selected', '').replace('system:', '');
  const images: Record<string, Resource[]> = {
    'magnifyingglass': [$r('app.media.tab_magnifyingglass_normal'), $r('app.media.tab_magnifyingglass_selected')],
    'list.bullet': [$r('app.media.tab_list_bullet_normal'), $r('app.media.tab_list_bullet_selected')],
    'tag': [$r('app.media.tab_tag_normal'), $r('app.media.tab_tag_selected')],
    'tag.fill': [$r('app.media.tab_tag_fill_normal'), $r('app.media.tab_tag_fill_selected')],
    'sparkle.magnifyingglass': [$r('app.media.tab_sparkle_magnifyingglass_normal'),
      $r('app.media.tab_sparkle_magnifyingglass_selected')],
    'plus.circle.fill': [$r('app.media.tab_plus_circle_fill_normal'), $r('app.media.tab_plus_circle_fill_selected')]
  };
  const pair = images[symbol];
  return pair === undefined ? undefined : pair[selected ? 1 : 0];
}

// Selected images are tinted on iOS; the resolver only gets a name, so the selected names are marked.
function cylMarkSelectedImages(configuration: Record<string, Object>): void {
  const items = configuration['CYLTabBarControllerTabBarItemsAttributes'] as Record<string, Object>[] | undefined;
  items?.forEach((item: Record<string, Object>) => {
    const selected = item['CYLTabBarItemSelectedImage'];
    if (typeof selected === 'string') {
      item['CYLTabBarItemSelectedImage'] = selected + '#selected';
    }
  });
}

/**
 * The example app (iOS `CYLSearchExampleAppDelegate`): CYLTabBarController (its HarmonyOS library `cyltabbar`, pinned
 * in harmonyos/oh-package.json5) configured by the iOS example's CYLTabBarConfiguration.json, with Search, Examples,
 * the plus button (Search bar page), Tag style and Discover; the titles come from the CYLSearchTabs table, and each
 * page lives in its own navigation stack, as the iOS pages live in navigation controllers.
 */
@Entry
@Component
struct Index {
  @State selectedIndex: number = 0;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private items: CYLConfiguredTabBarItem[] = [];
  private plusButton: CYLPlusButton | undefined = undefined;
  private result: CYLTabBarConfigurationResult | undefined = undefined;
  private stacks: Record<string, NavPathStack> = {};

  aboutToAppear(): void {
    CYLTabBarConfiguration.imageResolver = cylTabImage;
    try {
      const configuration = CYLTabBarConfiguration.configurationWithRawFile(this.context, 'CYLTabBarConfiguration.json');
      cylMarkSelectedImages(configuration);
      this.result = CYLTabBarConfiguration.resultWithConfiguration(configuration, '1.0.0', false);
      // CYLTabBarLocalizationTableName "CYLSearchTabs": the titles are keys of that table.
      this.items = this.result.items.map((item: CYLConfiguredTabBarItem) => {
        const title = typeof item.title === 'string' ? cylAppText(this.context, item.title.replace('.', '_')) : item.title;
        const localized: CYLConfiguredTabBarItem = {
          title: title,
          image: item.image,
          selectedImage: item.selectedImage,
          identifier: item.identifier,
          pageIdentifier: item.pageIdentifier,
          titlePositionAdjustment: item.titlePositionAdjustment
        };
        return localized;
      });
      // CYLTabBarControllerPlusButton: a selectable plus button with its own page.
      const plus = configuration['CYLTabBarControllerPlusButton'] as Record<string, Object> | undefined;
      if (plus !== undefined) {
        this.plusButton = {
          image: cylTabImage(plus['CYLTabBarItemImage'] as string) ?? '',
          selectedImage: cylTabImage((plus['CYLTabBarItemImage'] as string) + '#selected'),
          title: cylAppText(this.context, (plus['CYLTabBarItemTitle'] as string).replace('.', '_')),
          identifier: plus['CYLTabBarItemPageIdentifier'] as string,
          // The raised plus button of the iOS example (and its mini program copy): 56 vp, its top above the bar (the
          // title stays aligned with the tab titles; AGENTS.md, "Example layer, raised plus button").
          imageSize: 56,
          selectable: true
        };
      }
    } catch (error) {
      console.error(`CYLTabBarConfiguration.json: ${JSON.stringify(error)}`);
    }
    // `aa start ... --pi CYLDemoTab 1` selects that tab, for screenshots (iOS `-CYLDemoTab 1`).
    const tab = AppStorage.get<number>('CYLDemoTab');
    if (tab !== undefined && tab >= 0 && tab < this.items.length) {
      this.selectedIndex = tab;
    }
  }

  private stack(identifier: string): NavPathStack {
    if (this.stacks[identifier] === undefined) {
      this.stacks[identifier] = new NavPathStack();
    }
    return this.stacks[identifier];
  }

  private currentIdentifier(): string {
    if (this.selectedIndex === CYLPlusButtonPageIndex) {
      return this.plusButton?.identifier ?? 'plus';
    }
    return this.items[this.selectedIndex]?.pageIdentifier ?? '';
  }

  @Builder
  route(name: string, param: Object) {
    if (name === CYLDemoRoute.reproduction) {
      SearchExamplePage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.styles) {
      PlaceholderGalleryPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.placeholderDetail) {
      PlaceholderDetailPage({ stack: this.stack(this.currentIdentifier()), param: param as CYLPlaceholderDetailParam })
    } else if (name === CYLDemoRoute.searchBar) {
      SearchBarDemoPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.ports) {
      PortsMenuPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.materialMenu) {
      MaterialMenuPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.materialSample) {
      MaterialSamplePage({ stack: this.stack(this.currentIdentifier()), param: param as CYLMaterialSampleParam })
    } else if (name === CYLDemoRoute.lapism) {
      LapismPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.yechaoa) {
      YechaoaPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.reveal) {
      RevealPage({ stack: this.stack(this.currentIdentifier()) })
    } else if (name === CYLDemoRoute.multiSearch) {
      MultiSearchDemoPage({ stack: this.stack(this.currentIdentifier()) })
    }
  }

  // The page providers of CYLTabBarPageRegistry, by CYLTabBarItemPageIdentifier.
  @Builder
  rootPage(identifier: string) {
    if (identifier === 'search') {
      SearchExampleView()
    } else if (identifier === 'examples') {
      ExamplesMenuView({ stack: this.stack(identifier) })
    } else if (identifier === 'plus') {
      SearchBarDemoView()
    } else if (identifier === 'tagStyle') {
      MaterialMenuView({ stack: this.stack(identifier), tags: true })
    } else if (identifier === 'discover') {
      DiscoverView()
    }
  }

  @Builder
  page(index: number, identifier: string) {
    Navigation(this.stack(index === CYLPlusButtonPageIndex ? identifier : (this.items[index]?.pageIdentifier ?? identifier))) {
      this.rootPage(index === CYLPlusButtonPageIndex ? identifier : (this.items[index]?.pageIdentifier ?? identifier))
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.route)
    // The raised plus button rises above the bar; the page ends above it, so it never covers page content (AGENTS.md,
    // "Example layer, raised plus button").
    .padding({ bottom: this.plusOverhang() })
  }

  // How far the plus button rises above the bar: cyltabbar puts its image right above the title, whose top is
  // tabBarHeight - 17, so a 56 vp image in the 49 vp bar rises 56 - 32 = 24 vp.
  private plusOverhang(): number {
    const tabBarHeight = 49;
    return Math.max(0, (this.plusButton?.imageSize ?? 0) - (tabBarHeight - 17));
  }

  build() {
    Column() {
      CYLTabBarController({
        tabBarItemsAttributes: this.items as CYLTabBarItemAttributes[],
        plusButton: this.plusButton,
        selectedIndex: $selectedIndex,
        tintColor: '#007AFF',
        unselectedColor: '#8E8E93',
        tabBarBackgroundColor: $r('sys.color.background_primary'),
        titlePositionAdjustment: this.result?.titlePositionAdjustment ?? { horizontal: 0, vertical: 0 },
        pageBuilder: (index: number, identifier: string) => {
          this.page(index, identifier)
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  // The system Back gesture: a search page closes first (each page handles it), then the tab's stack pops.
  onBackPress(): boolean {
    const stack = this.stack(this.currentIdentifier());
    if (stack.size() > 0) {
      stack.pop();
      return true;
    }
    return false;
  }
}
