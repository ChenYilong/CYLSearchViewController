import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { common } from '@kit.AbilityKit';
import {
  CYLMenuFoldControlContent as CYLTagFoldContent,
  CYLMenuFoldControlPosition as CYLTagFoldPosition,
  CYLMenuSelectionMode,
  CYLTagListState
} from '@cyl/classifymenu';
import { CYLPlaceholderActions, CYLPlaceholderStackViewModel } from 'cylplaceholder';
import {
  CYLMenuFoldControl,
  CYLMenuFoldControlContent,
  CYLMenuFoldControlPosition,
  CYLSearchBarView,
  CYLSearchResources,
  CYLSearchSuggestionCache,
  CYLSearchSuggestionCachePolicy,
  CYLSearchView,
  CYLSearchViewDataSource
} from 'cylsearch';

function context(): common.Context {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext();
}

@Builder
function accessoryBuilder() {
}

@Builder
function launchBuilder(searchView: CYLSearchView) {
}

// A cache of the app's own (the interface), to see that the core announces its changes.
class CYLOwnCache implements CYLSearchSuggestionCache {
  queries: string[] = [];

  cachedQueries(): string[] {
    return this.queries.slice();
  }

  addQuery(query: string): void {
    this.queries = [query].concat(this.queries.filter((value: string) => value !== query));
  }

  removeQuery(query: string): void {
    this.queries = this.queries.filter((value: string) => value !== query);
  }

  removeAllQueries(): void {
    this.queries = [];
  }
}

class CYLKeywordSource implements CYLSearchViewDataSource {
  searchViewResultsForQuery = (_: CYLSearchView, query: string): Object[] => {
    const results: Object[] = [];
    ['Helps', 'Health'].filter((keyword: string) => keyword.toLowerCase().includes(query.toLowerCase()))
      .forEach((keyword: string) => {
        results.push(keyword);
      });
    return results;
  };
  searchViewConfigureResultCell = (_: CYLSearchView, result: Object): string => result as string;
}

function launchView(name: string): CYLSearchView {
  const view = new CYLSearchView();
  view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.sandboxFile;
  view.suggestionCacheName = name;
  view.closesOnSubmit = false;
  view.suggestions = ['Helps', 'Health', 'Liver'];
  view.showsSuggestionsLaunchView = true;
  view.showSearchIn(context(), false);
  view.historyStore?.removeAllQueries();
  return view;
}

/**
 * Merge phase 5 (docs/qmui-search-controller.md, "Merge phase 5 log: HarmonyOS"): one implementation per concept.
 */
export default function cylSearchMergeTest() {
  describe('CYLSearchMerge', () => {
    it('suggestionAreaIsTheClassifyMenuTagList', 0, () => {
      const view = new CYLSearchView();
      view.suggestions = ['Helps', 'Maintain', 'Liver'];
      view.showsSuggestionsLaunchView = true;
      const list: CYLTagListState = view.suggestionsTagView;
      expect(list.tags.map((tag) => tag.title).join(',')).assertEqual('Helps,Maintain,Liver');
      expect(list.foldControl.position).assertEqual(CYLTagFoldPosition.tail);
      expect(list.foldControl.content).assertEqual(CYLTagFoldContent.icon);
      expect(list.defaultVisibleRows).assertEqual(2);
      expect(list.selectionMode).assertEqual(CYLMenuSelectionMode.none);
      expect(list.showsSectionHeaders).assertFalse();
      expect(list.isScrollEnabled).assertFalse();
      // The titles follow the filter.
      view.setQuery('Li', false);
      expect(list.tags.map((tag) => tag.title).join(',')).assertEqual('Liver');
    });

    it('oldFoldControlTypesForwardToTheTagList', 0, () => {
      const view = new CYLSearchView();
      view.suggestions = ['A', 'B'];
      view.showsSuggestionsLaunchView = true;
      view.suggestionsFoldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.bottom,
        CYLMenuFoldControlContent.title);
      expect(view.suggestionsTagView.foldControl.position).assertEqual(CYLTagFoldPosition.footer);
      expect(view.suggestionsTagView.foldControl.content).assertEqual(CYLTagFoldContent.title);
      view.suggestionsFoldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.none);
      expect(view.suggestionsTagView.foldControl.position).assertEqual(CYLTagFoldPosition.none);
      view.suggestionsFoldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.inline);
      expect(view.suggestionsTagView.foldControl.position).assertEqual(CYLTagFoldPosition.tail);
      view.suggestionsFoldedRowCount = 3;
      expect(view.suggestionsTagView.defaultVisibleRows).assertEqual(3);
      expect(view.suggestionsFoldedRowCount).assertEqual(3);
      expect(view.suggestionsFolded).assertTrue();
      view.suggestionsFolded = false;
      expect(view.suggestionsTagView.isSectionExpanded(0)).assertTrue();
      expect(view.suggestionsFolded).assertFalse();
    });

    it('aTappedLaunchTagSubmits', 0, () => {
      const view = launchView('hypiumMergeTag');
      const revision = view.historyRevision;
      view.suggestionsTagView.tapItem({ section: 0, item: 1 });
      expect(view.query).assertEqual('Health');
      expect(JSON.stringify(view.historyStore?.cachedQueries())).assertEqual('["Health"]');
      expect(view.historyRevision).assertEqual(revision + 1);
      // The history now shows under its header, as tags.
      view.setQuery('', false);
      expect(view.showsCachedQueries).assertTrue();
      expect(view.suggestionsTagView.tags.map((tag) => tag.title).join(',')).assertEqual('Health');
      view.historyStore?.removeAllQueries();
    });

    it('aTappedTagOutsideTheLaunchContentOnlyFillsTheField', 0, () => {
      const view = launchView('hypiumMergeTagField');
      view.setQuery('He', false);
      view.suggestionsTagView.tapItem({ section: 0, item: 0 });
      expect(view.query).assertEqual('Helps');
      expect(view.historyStore?.cachedQueries().length).assertEqual(0);
    });

    it('launchContentAndCustomLaunchViewReplaceEachOther', 0, () => {
      const view = new CYLSearchView();
      expect(view.showsSuggestionsLaunchView).assertFalse();
      view.showsSuggestionsLaunchView = true;
      expect(view.showsSuggestionsForEmptyQuery).assertTrue();
      view.launchView = wrapBuilder(launchBuilder);
      expect(view.showsSuggestionsLaunchView).assertFalse();
      expect(view.showsLaunchView).assertTrue();
      view.showsSuggestionsLaunchView = true;
      expect(view.launchView === undefined).assertTrue();
      expect(view.showsLaunchView).assertFalse();
    });

    it('oneScrimOverlayAndDimmingColorForwardsToIt', 0, () => {
      const view = new CYLSearchView();
      view.dimmingColor = '#80000000';
      expect(view.scrimColor).assertEqual('#80000000');
      view.scrimColor = '#40FF0000';
      expect(view.dimmingColor).assertEqual('#40FF0000');
      expect(view.showsDimming).assertTrue();
      // The suggestion area covers the scrim, as a launch view does.
      view.showsSuggestionsLaunchView = true;
      expect(view.showsDimming).assertFalse();
    });

    it('oneHistorySignalForEveryViewOfTheCache', 0, () => {
      const first = launchView('hypiumMergeSignal');
      const second = launchView('hypiumMergeSignal');
      const revision = second.historyRevision;
      first.setQuery('Liver', true);
      expect(second.historyRevision).assertEqual(revision + 1);
      second.setQuery('', false);
      expect(second.filteredSuggestions.join(',')).assertEqual('Liver');
      second.clearSuggestionCache();
      expect(first.historyStore?.cachedQueries().length).assertEqual(0);
      // A listener that stops is not told again.
      let told = 0;
      const stop = CYLSearchResources.observeHistory(() => first.historyStore, () => {
        told += 1;
      });
      first.setQuery('Helps', true);
      expect(told).assertEqual(1);
      stop();
      first.setQuery('Health', true);
      expect(told).assertEqual(1);
      first.clearSuggestionCache();
    });

    it('aCacheOfYourOwnIsAnnouncedOnceBySubmitAndClear', 0, () => {
      const view = new CYLSearchView();
      const cache = new CYLOwnCache();
      view.historyStore = cache;
      view.closesOnSubmit = false;
      view.showSearch(false);
      const revision = view.historyRevision;
      view.setQuery('Swift', true);
      expect(view.historyRevision).assertEqual(revision + 1);
      expect(cache.queries.join(',')).assertEqual('Swift');
      view.clearSuggestionCache();
      expect(view.historyRevision).assertEqual(revision + 2);
    });

    it('noResultsTextShowsAndHidesTheEmptyView', 0, () => {
      const view = new CYLSearchView();
      view.resultsDataSource = new CYLKeywordSource();
      view.noResultsText = 'No matching results';
      view.showSearch(false);
      view.setQuery('zzz', false);
      expect(view.isEmptyViewShowing).assertTrue();
      expect(view.emptyView.text).assertEqual('No matching results');
      const placeholder = view.emptyView.placeholder as CYLPlaceholderStackViewModel;
      expect(placeholder.placeholderView.text).assertEqual('No matching results');
      const revision = view.emptyView.revision;
      view.setQuery('zzzz', false);
      // The same text keeps the same placeholder.
      expect(view.emptyView.revision).assertEqual(revision);
      view.setQuery('Hel', false);
      expect(view.isEmptyViewShowing).assertFalse();
      view.setQuery('', false);
      expect(view.isEmptyViewShowing).assertFalse();
    });

    it('theEmptyViewIsOnePlaceholderWithTextHintAndButton', 0, () => {
      const view = new CYLSearchView();
      view.showSearch(false);
      view.setQuery('zzz', false);
      let taps = 0;
      view.showEmptyView('Nothing', 'Try another word', 'Retry', () => {
        taps += 1;
      });
      const placeholder = view.emptyView.placeholder as CYLPlaceholderStackViewModel;
      expect(placeholder.entries.length).assertEqual(3);
      expect(placeholder.placeholderView.text).assertEqual('Nothing');
      expect(placeholder.performAction(CYLPlaceholderActions.Retry)).assertTrue();
      expect(taps).assertEqual(1);
      view.showEmptyView('Nothing');
      expect((view.emptyView.placeholder as CYLPlaceholderStackViewModel).entries.length).assertEqual(1);
    });

    it('accessoryNamesOfTheQMUIPortForwardToTheIOSNames', 0, () => {
      const bar = new CYLSearchBarView();
      const builder = wrapBuilder(accessoryBuilder);
      bar.leadingAccessoryView = builder;
      expect(bar.leadingView === builder).assertTrue();
      bar.trailingAccessoryView = builder;
      expect(bar.trailingAccessoryViews === builder).assertTrue();
      bar.setShowsLeadingAccessoryView(false, false);
      expect(bar.showsLeadingView).assertFalse();
      expect(bar.showsLeadingAccessoryView).assertFalse();
      bar.setShowsTrailingAccessoryView(false, false);
      expect(bar.showsTrailingAccessoryViews).assertFalse();
      expect(bar.showsTrailingAccessoryView).assertFalse();
      bar.setShowsLeadingView(true, false);
      expect(bar.showsLeadingAccessoryView).assertTrue();
      bar.setShowsTrailingAccessoryViews(true, false);
      expect(bar.showsTrailingAccessoryView).assertTrue();
      bar.leadingView = undefined;
      expect(bar.leadingAccessoryView === undefined).assertTrue();
    });

    it('highlightAndSwipeOptionsDefaultOffLikeIOS', 0, () => {
      const view = new CYLSearchView();
      expect(view.highlightsResultMatches).assertFalse();
      expect(view.resultMatchHighlightColor === undefined).assertTrue();
      expect(view.supportsSwipeToDismissSearch).assertFalse();
      expect(view.noResultsText === undefined).assertTrue();
      view.highlightsResultMatches = true;
      view.resultMatchHighlightColor = '#FF0000';
      view.supportsSwipeToDismissSearch = true;
      expect(view.highlightsResultMatches && view.supportsSwipeToDismissSearch).assertTrue();
      expect(view.resultMatchHighlightColor).assertEqual('#FF0000');
    });
  });
}
