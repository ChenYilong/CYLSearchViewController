import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { common } from '@kit.AbilityKit';
import { CYLPlaceholderScenario } from 'cylplaceholder';
import { CYLColorKey, CYLImageIsSymbol, CYLTagButton } from '@cyl/classifymenu';
import {
  CYLMenuFoldControl,
  CYLMenuFoldControlPosition,
  CYLSearchBarItem,
  CYLSearchBarMode,
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

function wait(milliseconds: number): Promise<void> {
  return new Promise<void>((resolve) => setTimeout(resolve, milliseconds));
}

// The core's default store of a policy (private; created through CYLSearchResources, as CYLSearchView does).
function cache(policy: CYLSearchSuggestionCachePolicy, name: string): CYLSearchSuggestionCache {
  return CYLSearchResources.suggestionCache(context(), policy, name) as CYLSearchSuggestionCache;
}

// A data source of four languages, filtered by the query (case-insensitive).
function languages(): CYLSearchViewDataSource {
  const all: string[] = ['Swift', 'SwiftUI', 'Kotlin', 'ArkTS'];
  const source: CYLSearchViewDataSource = {
    searchViewResultsForQuery: (_: CYLSearchView, query: string): Object[] =>
    all.filter((item: string) => item.toLowerCase().includes(query.toLowerCase())),
    searchViewConfigureResultCell: (_: CYLSearchView, result: Object): string => `${result}`
  };
  return source;
}

export default function cylSearchCoreTest() {
  describe('CYLSearchCore', () => {
    it('cacheKeepsNewestFirstWithoutDuplicates', 0, () => {
      const store = cache(CYLSearchSuggestionCachePolicy.database, 'hypium');
      store.removeAllQueries();
      store.addQuery('Swift');
      store.addQuery('Kotlin');
      store.addQuery(' Swift ');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["Swift","Kotlin"]');
      store.removeQuery('Swift');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["Kotlin"]');
      store.removeAllQueries();
    });

    it('cacheIgnoresBlankQueries', 0, () => {
      const store = cache(CYLSearchSuggestionCachePolicy.sandboxFile, 'hypium');
      store.removeAllQueries();
      store.addQuery('a');
      store.addQuery('   ');
      store.addQuery('b');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["b","a"]');
      store.removeAllQueries();
    });

    it('noCachePolicyGivesNoCache', 0, () => {
      expect(CYLSearchResources.suggestionCache(context(), CYLSearchSuggestionCachePolicy.none, 'hypium'))
        .assertUndefined();
    });

    it('localizedStringFollowsLanguage', 0, () => {
      expect(CYLSearchResources.localizedString(context(), 'placeholder.empty', 'zh-Hans')).assertEqual('暂无数据');
      expect(CYLSearchResources.localizedString(context(), 'no.such.key', 'en')).assertEqual('no.such.key');
    });

    it('emptyResultsUseTheTableViewPlaceHolderScenario', 0, () => {
      const view = new CYLSearchView();
      view.suggestions = ['Swift'];
      view.showsEmptyResultsPlaceholder = true;
      view.setQuery('Kotlin', false);
      expect(view.showsEmptyResults).assertTrue();
      expect(view.emptyResultsView !== undefined).assertTrue();
      expect(view.emptyResultsView?.scenario).assertEqual(CYLPlaceholderScenario.NoSearchResults);
      view.emptyResultsScenario = CYLPlaceholderScenario.NoContent;
      expect(view.emptyResultsView?.scenario).assertEqual(CYLPlaceholderScenario.NoContent);
    });

    it('handleBackPressOnlyWhenOpen', 0, () => {
      const view = new CYLSearchView();
      expect(view.handleBackPress()).assertFalse();
      view.showSearch(false);
      expect(view.isSearchOpen).assertTrue();
      expect(view.handleBackPress()).assertTrue();
      expect(view.isSearchOpen).assertFalse();
    });

    it('closeSearchCallsItsCompletion', 0, () => {
      const view = new CYLSearchView();
      let closed = 0;
      let completions = 0;
      view.delegate = { searchViewDidClose: () => { closed++; } };
      // Not open: the completion runs at once, the delegate hears nothing.
      view.closeSearch(false, () => { completions++; });
      expect(completions).assertEqual(1);
      expect(closed).assertEqual(0);
      view.showSearchIn(context(), false);
      view.closeSearch(false, () => { completions++; });
      expect(completions).assertEqual(2);
      expect(closed).assertEqual(1);
    });

    it('resultsFollowTheQuery', 0, () => {
      const view = new CYLSearchView();
      let selected = '';
      view.delegate = { searchViewDidSelectResult: (_: CYLSearchView, result: Object) => { selected = `${result}`; } };
      view.resultsDataSource = languages();
      // An empty query asks nothing and shows the suggestions.
      expect(view.searchResults.length).assertEqual(0);
      expect(view.showsResults).assertFalse();
      view.setQuery('swi', false);
      expect(view.showsResults).assertTrue();
      expect(JSON.stringify(view.searchResults)).assertEqual('["Swift","SwiftUI"]');
      view.resultSelected(view.searchResults[1]);
      expect(selected).assertEqual('SwiftUI');
      // No result: the empty results placeholder covers the empty list.
      view.showsEmptyResultsPlaceholder = true;
      view.setQuery('rust', false);
      expect(view.searchResults.length).assertEqual(0);
      expect(view.showsEmptyResults).assertTrue();
      expect(view.emptyResultsView !== undefined).assertTrue();
    });

    it('reloadResultsAsksTheDataSourceAgain', 0, () => {
      const view = new CYLSearchView();
      let calls = 0;
      const source: CYLSearchViewDataSource = {
        searchViewResultsForQuery: (): Object[] => {
          calls++;
          return ['A'];
        },
        searchViewConfigureResultCell: (_: CYLSearchView, result: Object): string => `${result}`
      };
      view.resultsDataSource = source;
      view.setQuery('a', false);
      const before = calls;
      view.reloadResults();
      expect(calls).assertEqual(before + 1);
    });

    it('refreshHandlerAndStaticRefresh', 0, () => {
      const view = new CYLSearchView();
      expect(view.isRefreshing).assertFalse();
      view.refreshHandler = () => {
      };
      expect(view.refreshHandler !== undefined).assertTrue();
      // Off screen the refresh waits for its list (CYLRefresh `WillRefresh`), which counts as refreshing.
      view.beginRefreshing();
      expect(view.isRefreshing).assertTrue();
      view.refreshHandler = undefined;
      expect(view.isRefreshing).assertFalse();

      const scroller = new Scroller();
      expect(CYLSearchView.isRefreshingIn(scroller)).assertFalse();
      CYLSearchView.setRefreshHandler(() => {
      }, scroller);
      CYLSearchView.beginRefreshingIn(scroller);
      expect(CYLSearchView.isRefreshingIn(scroller)).assertTrue();
      CYLSearchView.setRefreshHandler(undefined, scroller);
      expect(CYLSearchView.isRefreshingIn(scroller)).assertFalse();
    });

    it('multipleModeCompletesOnBack', 0, () => {
      const bar = new CYLSearchBarView();
      bar.mode = CYLSearchBarMode.multiple;
      expect(bar.handleBackPress()).assertFalse();
      bar.beginNewSearch();
      expect(bar.isEditingNewSearch).assertTrue();
      bar.textChanged('Swift');
      expect(bar.handleBackPress()).assertTrue();
      expect(bar.isEditingNewSearch).assertFalse();
      expect(JSON.stringify(bar.searches)).assertEqual('["Swift"]');
      expect(bar.selectedSearchIndex).assertEqual(0);
    });

    it('multipleModeReportsItsEvents', 0, () => {
      const bar = new CYLSearchBarView();
      bar.mode = CYLSearchBarMode.multiple;
      const events: string[] = [];
      bar.delegate = {
        searchBarViewTextDidChange: () => {
          events.push('single');
        },
        searchBarViewTextDidChangeAtIndex: (_: CYLSearchBarView, text: string, index: number) => {
          events.push(`change ${index} ${text}`);
        },
        searchBarViewDidCompleteSearch: (_: CYLSearchBarView, text: string, index: number) => {
          events.push(`complete ${index} ${text}`);
        },
        searchBarViewDidSelectSearch: (_: CYLSearchBarView, text: string, index: number) => {
          events.push(`select ${index} ${text}`);
        },
        searchBarViewDidRemoveSearchAtIndex: (_: CYLSearchBarView, index: number) => {
          events.push(`remove ${index}`);
        }
      };
      bar.addSearch('Swift');
      bar.beginNewSearch();
      bar.textChanged('Kotlin');
      bar.completeSearch();
      bar.selectSearch(0);
      bar.removeSearch(0);
      expect(JSON.stringify(events)).assertEqual(
        '["change 1 Kotlin","complete 1 Kotlin","select 0 Swift","remove 0"]');
      expect(JSON.stringify(bar.searches)).assertEqual('["Kotlin"]');
      expect(bar.selectedSearchIndex).assertEqual(0);
    });

    it('multipleModeDropsShortSearchesAndSelectsTheNextAfterRemoval', 0, () => {
      const bar = new CYLSearchBarView();
      bar.mode = CYLSearchBarMode.multiple;
      bar.addSearch('Swift');
      bar.addSearch('Kotlin');
      bar.beginNewSearch();
      expect(bar.selectedSearchIndex).assertEqual(-1);
      bar.textChanged('ab');
      bar.completeSearch();
      expect(bar.searches.length).assertEqual(2);
      bar.removeSearch(0);
      expect(bar.selectedSearchIndex).assertEqual(0);
    });

    it('singleModeIgnoresNewSearches', 0, () => {
      const bar = new CYLSearchBarView();
      bar.beginNewSearch();
      expect(bar.isEditingNewSearch).assertFalse();
    });

    // Kotlin parity (android/merged/cylsearch): the checks below follow CYLSearchView.kt and CYLSearchBarView.kt.
    it('suggestionsFoldAccentsAndTrimTheQuery', 0, () => {
      const view = new CYLSearchView();
      view.suggestions = ['Café', 'Kotlin'];
      view.setQuery('cafe', false);
      expect(JSON.stringify(view.filteredSuggestions)).assertEqual('["Café"]');
      view.showsEmptyResultsPlaceholder = true;
      view.setQuery('   ', false);
      expect(view.showsEmptyResults).assertFalse();
    });

    it('setQueryReportsTheChangeOnceAndRefusesBlankSubmit', 0, () => {
      const view = new CYLSearchView();
      let changes = 0;
      let submits = 0;
      view.delegate = {
        searchViewTextDidChange: () => {
          changes++;
        },
        searchViewDidSubmitText: () => {
          submits++;
          return true;
        }
      };
      view.setQuery('Swift', false);
      view.setQuery('  ', true);
      expect(changes).assertEqual(2);
      expect(submits).assertEqual(0);
    });

    it('searchBarKeepsItemsInOrder', 0, () => {
      const bar = new CYLSearchBarView();
      bar.addItem(CYLSearchBarItem.divider());
      bar.addItem(CYLSearchBarItem.textItem('Search', () => {}));
      expect(bar.items.length).assertEqual(2);
    });

    it('searchBarItemsAreDrawnByTagButtons', 0, () => {
      const bar = new CYLSearchBarView();
      const camera = CYLSearchBarItem.iconItem($r('sys.symbol.camera'), 'Camera');
      camera.badgeValue = '3';
      camera.animationURL = 'asset:svga/tab_activity.svga';
      camera.tintColor = $r('sys.color.brand');
      const search = CYLSearchBarItem.textItem('Search');
      bar.addItem(camera);
      bar.addItem(CYLSearchBarItem.divider());
      bar.addItem(search);
      const views: CYLTagButton[] = bar.itemViews;
      expect(views.length).assertEqual(3);
      expect(views[0] === camera.itemView).assertTrue();
      const icon = camera.reloadItemView(undefined);
      expect(icon.title === undefined).assertTrue();
      expect(CYLImageIsSymbol(icon.image)).assertTrue();
      expect(icon.badgeValue).assertEqual('3');
      expect(icon.animationURL).assertEqual('asset:svga/tab_activity.svga');
      expect(icon.accessibilityLabel).assertEqual('Camera');
      expect(CYLColorKey(icon.style.iconColor(0))).assertEqual(CYLColorKey($r('sys.color.brand')));
      expect(icon.style.normalAppearance.borderWidth).assertEqual(0);
      expect(icon.intrinsicSize().width >= 36).assertTrue();
      const text = search.reloadItemView(undefined);
      expect(text.title).assertEqual('Search');
      expect(text.badgeValue === undefined).assertTrue();
      expect(views[1].title === undefined && views[1].image === undefined).assertTrue();
    });

    it('foldControlPositionNone', 0, () => {
      const view = new CYLSearchView();
      view.suggestionsFoldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.none);
      expect(view.suggestionsFoldControl.position).assertEqual(CYLMenuFoldControlPosition.none);
      expect(new CYLMenuFoldControl().position).assertEqual(CYLMenuFoldControlPosition.inline);
    });

    it('clearSuggestionCacheWithoutContextDoesNotThrow', 0, () => {
      const view = new CYLSearchView();
      view.clearSuggestionCache();
      expect(view.filteredSuggestions.length).assertEqual(0);
    });

    it('databasePolicyKeepsQueriesInSQLite', 0, async () => {
      const first = cache(CYLSearchSuggestionCachePolicy.database, 'CYLDatabaseTest');
      first.removeAllQueries();
      first.addQuery('Swift');
      first.addQuery('Kotlin');
      expect(JSON.stringify(first.cachedQueries())).assertEqual('["Kotlin","Swift"]');
      // The database writes in the background, in order.
      await wait(1000);
      let loaded = false;
      const second = CYLSearchResources.suggestionCache(context(), CYLSearchSuggestionCachePolicy.database,
        'CYLDatabaseTest', () => {
          loaded = true;
        }) as CYLSearchSuggestionCache;
      await wait(1000);
      expect(loaded).assertTrue();
      expect(JSON.stringify(second.cachedQueries())).assertEqual('["Kotlin","Swift"]');
      second.removeAllQueries();
      await wait(500);
    });
  });
}
