import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { common } from '@kit.AbilityKit';
import {
  CYLMultiSearchView,
  CYLSearchBarItem,
  CYLSearchController,
  CYLSearchResultsDataSource,
  CYLSearchResultsViewController,
  CYLSearchBarView,
  CYLSearchPlaceholderKind,
  CYLSearchPlaceholderView,
  CYLSearchResources,
  CYLSearchSuggestionCachePolicy,
  CYLSearchSuggestionStore,
  CYLSearchView,
  CYLMenuFoldControl,
  CYLMenuFoldControlPosition,
  cylFoldedTagCount
} from 'cylsearch';

function context(): common.Context {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext();
}

export default function cylSearchCoreTest() {
  describe('CYLSearchCore', () => {
    it('cacheKeepsNewestFirstWithoutDuplicates', 0, () => {
      const store = new CYLSearchSuggestionStore(context(), CYLSearchSuggestionCachePolicy.database, 'hypium');
      store.removeAllQueries();
      store.addQuery('Swift');
      store.addQuery('Kotlin');
      store.addQuery(' Swift ');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["Swift","Kotlin"]');
      store.removeQuery('Swift');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["Kotlin"]');
      store.removeAllQueries();
    });

    it('cacheHonorsMaximumCountAndIgnoresBlank', 0, () => {
      const store = new CYLSearchSuggestionStore(context(), CYLSearchSuggestionCachePolicy.sandboxFile, 'hypium');
      store.removeAllQueries();
      store.maximumCount = 2;
      store.addQuery('a');
      store.addQuery('   ');
      store.addQuery('b');
      store.addQuery('c');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["c","b"]');
      store.removeAllQueries();
    });

    it('noCachePolicyGivesNoCache', 0, () => {
      expect(CYLSearchSuggestionStore.cache(context(), CYLSearchSuggestionCachePolicy.none, 'hypium'))
        .assertUndefined();
    });

    it('localizedStringFollowsLanguage', 0, () => {
      expect(CYLSearchResources.localizedString(context(), 'placeholder.empty', 'zh-Hans')).assertEqual('暂无数据');
      expect(CYLSearchResources.localizedString(context(), 'no.such.key', 'en')).assertEqual('no.such.key');
    });

    it('placeholderKindsHaveViews', 0, () => {
      expect(CYLSearchPlaceholderView.withKind(CYLSearchPlaceholderKind.noResults) !== undefined).assertTrue();
      expect(CYLSearchPlaceholderView.withKind(CYLSearchPlaceholderKind.error) !== undefined).assertTrue();
    });

    it('handleBackPressOnlyWhenOpen', 0, () => {
      const view = new CYLSearchView();
      expect(view.handleBackPress()).assertFalse();
      view.showSearch(false);
      expect(view.isSearchOpen).assertTrue();
      expect(view.handleBackPress()).assertTrue();
      expect(view.isSearchOpen).assertFalse();
    });

    it('controllerHandleBackPressOnlyWhenPresented', 0, async () => {
      const source: CYLSearchResultsDataSource = {
        searchResultsViewControllerResultsForQuery: () => [],
        searchResultsViewControllerConfigureCell: (_: CYLSearchResultsViewController, result: Object) => `${result}`
      };
      const controller = new CYLSearchController(source);
      let cancelled = false;
      controller.delegate = { searchControllerDidCancel: () => { cancelled = true; } };
      expect(controller.handleBackPress()).assertFalse();
      controller.animationDuration = 0;
      controller.showInViewController();
      expect(controller.isPresented).assertTrue();
      expect(controller.handleBackPress()).assertTrue();
      expect(controller.isPresented).assertFalse();
      // The Cancel callback runs when the hide animation finishes.
      await new Promise<void>((resolve) => setTimeout(resolve, 600));
      expect(cancelled).assertTrue();
    });

    it('multiSearchHandleBackPressCompletesTyping', 0, () => {
      const view = new CYLMultiSearchView();
      expect(view.handleBackPress()).assertFalse();
      view.search();
      view.typedText = 'Swift';
      expect(view.handleBackPress()).assertTrue();
      expect(view.isInSearchMode).assertFalse();
      expect(JSON.stringify(view.completedSearchTexts)).assertEqual('["Swift"]');
    });

    // Kotlin parity (android/merged/cylsearch): the checks below follow CYLSearchView.kt, CYLSearchBarView.kt,
    // CYLSearchSuggestionCache.kt and CYLMultiSearchView.kt.
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

    it('cacheKeepsAtLeastOneQuery', 0, () => {
      const store = new CYLSearchSuggestionStore(context(), CYLSearchSuggestionCachePolicy.database, '');
      store.removeAllQueries();
      store.maximumCount = 0;
      store.addQuery('Swift');
      expect(JSON.stringify(store.cachedQueries())).assertEqual('["Swift"]');
      store.removeAllQueries();
    });

    it('multiSearchSelectsTheNextItemAfterRemoval', 0, () => {
      const view = new CYLMultiSearchView();
      view.addSearchText('Swift');
      view.addSearchText('Kotlin');
      view.search();
      expect(view.selectedIndex).assertEqual(-1);
      view.completeSearch();
      view.removeItemAtIndex(0);
      expect(view.selectedIndex).assertEqual(0);
    });

    it('searchBarKeepsItemsInOrder', 0, () => {
      const bar = new CYLSearchBarView();
      bar.addItem(CYLSearchBarItem.divider());
      bar.addItem(CYLSearchBarItem.textItem('Search', () => {}));
      expect(bar.items.length).assertEqual(2);
    });

    it('foldedTagCountLeavesRoomForAnInlineControl', 0, () => {
      // Rows of 100 vp, spacing 10: tags of 45 fit two per row.
      const widths: number[] = [45, 45, 45, 45, 45];
      // Everything fits in 3 rows: no control needed.
      expect(cylFoldedTagCount(widths, 100, 3, 10, 40)).assertEqual(5);
      // 2 rows hold 4 tags, but the inline control (40) must follow the last visible tag: 3 tags and the control.
      expect(cylFoldedTagCount(widths, 100, 2, 10, 40)).assertEqual(3);
      // A control on its own row (width 0 in the flow) leaves all 4.
      expect(cylFoldedTagCount(widths, 100, 2, 10, 0)).assertEqual(4);
      // 0 rows or no layout yet: every tag.
      expect(cylFoldedTagCount(widths, 100, 0, 10, 40)).assertEqual(5);
      expect(cylFoldedTagCount(widths, 0, 2, 10, 40)).assertEqual(5);
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
      const first = new CYLSearchSuggestionStore(context(), CYLSearchSuggestionCachePolicy.database, 'CYLDatabaseTest');
      first.removeAllQueries();
      first.addQuery('Swift');
      first.addQuery('Kotlin');
      expect(JSON.stringify(first.cachedQueries())).assertEqual('["Kotlin","Swift"]');
      await first.whenStored();
      // A second store reads the same table in the background.
      const second = new CYLSearchSuggestionStore(context(), CYLSearchSuggestionCachePolicy.database, 'CYLDatabaseTest');
      await second.whenStored();
      expect(second.isLoaded).assertTrue();
      expect(JSON.stringify(second.cachedQueries())).assertEqual('["Kotlin","Swift"]');
      second.removeAllQueries();
      await second.whenStored();
    });
  });
}
