import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { CYLSearchBarPreset, CYLSearchBarSearchButtonStyle, CYLSearchBarView, CYLSearchNavigationPage } from 'cylsearch';
import { cylAppText, CYLDemoRoute, CYLSearchSecondLevelParam } from '../common/DemoCommon';
import { CYLDiscoverTopic, cylLoadDiscoverData } from './Discover';

/**
 * A first-level search bar (owner directive 2026-11-26, example-demos rule 10): the core's preset for the tab, the tap
 * pushes the second-level search page. The page only names the preset, the placeholder and the push; the core brings the
 * back button in, narrows the bar and reverses both on the way back.
 */
export function cylFirstLevelBar(preset: CYLSearchBarPreset, placeholder: ResourceStr, stack: NavPathStack,
  searchButtonStyle?: CYLSearchBarSearchButtonStyle): CYLSearchBarView {
  const bar = new CYLSearchBarView();
  bar.applyPreset(preset);
  if (searchButtonStyle !== undefined) {
    bar.searchButtonStyle = searchButtonStyle; // opt-in; the core default is the icon style
  }
  bar.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  bar.placeholder = placeholder;
  bar.pushesOnTap = true;
  bar.onFirstLevelTap = () => {
    const param: CYLSearchSecondLevelParam = { preset: preset, searchButtonStyle: searchButtonStyle };
    stack.pushPath({ name: CYLDemoRoute.searchSecondLevel, param: param });
  };
  return bar;
}

/**
 * The second-level search page every first-level bar pushes: the same bar look (the tab's preset) with the back button
 * on the left, the keyboard up, and the Recently searched and Popular right now tag lists below. Tapping a tag searches it.
 */
@ComponentV2
export struct SearchSecondLevelPage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLSearchSecondLevelParam;
  @Local recent: string[] = [];
  @Local topics: CYLDiscoverTopic[] = [];
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private searchBar: CYLSearchBarView = new CYLSearchBarView();

  aboutToAppear(): void {
    const data = cylLoadDiscoverData(this.context);
    this.recent = data.recentSearches;
    this.topics = data.discover;
    const bar = this.searchBar;
    bar.applyPreset(this.param.preset as CYLSearchBarPreset);
    if (this.param.searchButtonStyle !== undefined) {
      bar.searchButtonStyle = this.param.searchButtonStyle as CYLSearchBarSearchButtonStyle;
    }
    bar.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    bar.placeholder = this.topics.length > 0 ? this.topics[0].title : cylAppText(this.context, 'discover_search');
    bar.focusesOnAppear = true; // the keyboard rises with the push
  }

  private search(title: string): void {
    this.searchBar.text = title;
    this.recent = [title].concat(this.recent.filter((item: string) => item !== title));
  }

  @Builder
  header(title: string) {
    Text(title)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
  }

  @Builder
  tags(titles: string[], id: string) {
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
      ForEach(titles, (title: string) => {
        Text(title)
          .fontSize(17)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '100%' })
          .height(36)
          .padding({ left: 12, right: 12 })
          .border({ width: 1, color: $r('sys.color.comp_divider') })
          .onClick(() => this.search(title))
      }, (title: string) => title)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 16 })
    .id(id)
  }

  @Builder
  content() {
    Scroll() {
      Column() {
        if (this.recent.length > 0) {
          this.header(cylAppText(this.context, 'discover_recent'))
          this.tags(this.recent, 'CYLSearchRecentTags')
        }
        this.header(cylAppText(this.context, 'discover_title'))
        this.tags(this.topics.map((topic: CYLDiscoverTopic) => topic.title), 'CYLSearchPopularTags')
      }
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    CYLSearchNavigationPage({ searchBarView: this.searchBar, showsBack: true, isDestination: true,
      onBack: () => this.stack.pop() }) {
      this.content()
    }
  }
}
