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
  CYLSearchView
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

    it('searchBarKeepsItemsInOrder', 0, () => {
      const bar = new CYLSearchBarView();
      bar.addItem(CYLSearchBarItem.divider());
      bar.addItem(CYLSearchBarItem.textItem('Search', () => {}));
      expect(bar.items.length).assertEqual(2);
    });
  });
}
