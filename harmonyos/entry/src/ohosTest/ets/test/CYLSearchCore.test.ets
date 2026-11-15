import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarItem,
  CYLSearchBarView,
  CYLSearchPlaceholderKind,
  CYLSearchPlaceholderView,
  CYLSearchResources,
  CYLSearchSuggestionCachePolicy,
  CYLSearchSuggestionStore
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

    it('searchBarKeepsItemsInOrder', 0, () => {
      const bar = new CYLSearchBarView();
      bar.addItem(CYLSearchBarItem.divider());
      bar.addItem(CYLSearchBarItem.textItem('Search', () => {}));
      expect(bar.items.length).assertEqual(2);
    });
  });
}
