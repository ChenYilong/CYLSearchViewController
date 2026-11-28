import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarAppearance,
  CYLSearchBarView,
  CYLSearchEdgeInsets,
  CYLSearchSuggestionCachePolicy,
  CYLSearchTableView,
  CYLSearchView
} from 'cylsearch';

function context(): common.Context {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext();
}

@Builder
function launchBuilder(searchView: CYLSearchView) {
}

function insets(left: number, right: number): CYLSearchEdgeInsets {
  const result: CYLSearchEdgeInsets = { top: 0, left: left, bottom: 0, right: right };
  return result;
}

export default function cylSearchQMUIPortTest() {
  describe('CYLSearchQMUIPort', () => {
    it('appearanceStyleAppliesTheDefaultStyle', 0, () => {
      const bar = new CYLSearchBarView();
      bar.appearanceStyle = CYLSearchBarAppearance.defaultAppearance;
      expect(bar.tintColor).assertEqual('#0068F8');
      expect(bar.fieldCornerRadius).assertEqual(-1);
      expect(bar.placeholder !== undefined).assertTrue();
      expect(bar.barBackgroundColor === undefined).assertTrue();
    });

    it('appearanceCopyIsIndependent', 0, () => {
      const style = CYLSearchBarAppearance.defaultAppearance.copy();
      style.tintColor = '#FF0000';
      style.hidesBarBackground = false;
      const bar = new CYLSearchBarView();
      bar.appearanceStyle = style;
      style.tintColor = '#00FF00';
      expect(bar.tintColor).assertEqual('#FF0000');
      expect(bar.appearanceStyle.tintColor).assertEqual('#FF0000');
      expect(CYLSearchBarAppearance.defaultAppearance.tintColor).assertEqual('#0068F8');
      expect(bar.barBackgroundColor !== undefined).assertTrue();
    });

    it('textFieldMarginsProviderWinsAndFollowsTheActiveState', 0, () => {
      const bar = new CYLSearchBarView();
      bar.textFieldMargins = insets(5, 5);
      expect(bar.resolvedTextFieldMargins.left).assertEqual(5);
      bar.textFieldMarginsProvider = (_: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets =>
      active ? insets(0, 0) : insets(32, 32);
      expect(bar.resolvedTextFieldMargins.left).assertEqual(32);
      bar.editingChanged(true);
      expect(bar.isActive).assertTrue();
      expect(bar.resolvedTextFieldMargins.left).assertEqual(0);
      bar.editingChanged(false);
      expect(bar.resolvedTextFieldMargins.right).assertEqual(32);
    });

    it('cancelButtonMarginsProviderAndAutomaticCancel', 0, () => {
      const bar = new CYLSearchBarView();
      bar.cancelButtonMarginsProvider = (_: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets =>
      active ? insets(-16, 0) : insets(0, 0);
      expect(bar.resolvedCancelButtonMargins.left).assertEqual(0);
      expect(bar.cancelButtonVisible).assertFalse();
      bar.automaticallyShowsCancelButton = true;
      bar.editingChanged(true);
      expect(bar.cancelButtonVisible).assertTrue();
      expect(bar.resolvedCancelButtonMargins.left).assertEqual(-16);
    });

    it('placeholderIsCenteredOnlyAtRest', 0, () => {
      const bar = new CYLSearchBarView();
      bar.placeholder = 'Search';
      bar.centersPlaceholder = true;
      expect(bar.placeholderCentered).assertTrue();
      bar.editingChanged(true);
      expect(bar.placeholderCentered).assertFalse();
      bar.editingChanged(false);
      bar.setText('a', false);
      expect(bar.placeholderCentered).assertFalse();
    });

    it('showsCancelAndAccessoriesEndInTheLastRequest', 0, () => {
      const bar = new CYLSearchBarView();
      bar.setShowsCancelButton(true, true);
      bar.setShowsCancelButton(false, true);
      bar.setShowsCancelButton(true, true);
      expect(bar.showsCancelButton).assertTrue();
      bar.setShowsLeadingAccessoryView(false, true);
      bar.setShowsLeadingAccessoryView(true, true);
      bar.setShowsLeadingAccessoryView(false, true);
      expect(bar.showsLeadingAccessoryView).assertFalse();
      bar.setShowsTrailingAccessoryView(false, false);
      expect(bar.showsTrailingAccessoryView).assertFalse();
    });

    it('updateResultsReportsEmptyTextOnShowAndEveryChange', 0, () => {
      const view = new CYLSearchView();
      const texts: string[] = [];
      view.delegate = { searchViewUpdateResults: (_: CYLSearchView, text: string) => { texts.push(text); } };
      view.showSearch(false);
      view.setQuery('Ha', false);
      view.setQuery('', false);
      expect(JSON.stringify(texts)).assertEqual('["","Ha",""]');
    });

    it('presentationCallbacksComeInOrderAndActiveFollows', 0, () => {
      const view = new CYLSearchView();
      const events: string[] = [];
      view.delegate = {
        searchViewWillShow: () => { events.push('willShow'); },
        searchViewDidShow: () => { events.push('didShow'); },
        searchViewWillClose: () => { events.push('willClose'); },
        searchViewDidClose: () => { events.push('didClose'); }
      };
      expect(view.isActive).assertFalse();
      view.setActive(true, false);
      expect(view.isActive).assertTrue();
      expect(view.searchBarView.isActive).assertTrue();
      view.setActive(false, false);
      expect(view.isActive).assertFalse();
      expect(view.searchBarView.hostIsActive).assertFalse();
      expect(events.join(',')).assertEqual('willShow,didShow,willClose,didClose');
    });

    it('emptyViewIsNotShownForEmptyTextAndHidesOnClose', 0, () => {
      const view = new CYLSearchView();
      view.showSearch(false);
      view.showEmptyView('No matching results');
      expect(view.isEmptyViewShowing).assertFalse();
      view.setQuery('zzz', false);
      view.showEmptyView('No matching results', 'detail');
      expect(view.isEmptyViewShowing).assertTrue();
      expect(view.emptyView.text).assertEqual('No matching results');
      view.hideEmptyView();
      expect(view.isEmptyViewShowing).assertFalse();
      view.showEmptyView('No matching results');
      view.closeSearch(false);
      expect(view.emptyView.isShowing).assertFalse();
    });

    it('submittedQueryGoesToTheHistoryAndTellsTheLaunchView', 0, () => {
      const view = new CYLSearchView();
      view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.sandboxFile;
      view.suggestionCacheName = 'hypiumQMUIPort';
      view.closesOnSubmit = false;
      view.showSearchIn(context(), false);
      view.historyStore?.removeAllQueries();
      const revision = view.historyRevision;
      const heard: string[] = [];
      view.delegate = { searchViewHistoryDidChange: (_: CYLSearchView, query: string) => { heard.push(query); } };
      view.setQuery('Swift', true);
      expect(view.historyRevision).assertEqual(revision + 1);
      expect(heard.join(',')).assertEqual('Swift');
      expect(JSON.stringify(view.historyStore?.cachedQueries())).assertEqual('["Swift"]');
      expect(view.isSearchOpen).assertTrue();
      view.clearSuggestionCache();
      expect(view.historyRevision).assertEqual(revision + 2);
      expect(view.historyStore?.cachedQueries().length).assertEqual(0);
    });

    it('launchViewShowsOnlyWhileTheQueryIsEmpty', 0, () => {
      const view = new CYLSearchView();
      expect(view.showsLaunchView).assertFalse();
      view.launchView = wrapBuilder(launchBuilder);
      expect(view.showsLaunchView).assertTrue();
      view.dimmingColor = '#80000000';
      // The launch view wins over the dimming.
      expect(view.showsDimming).assertFalse();
      view.setQuery('a', false);
      expect(view.showsLaunchView).assertFalse();
      view.launchView = undefined;
      view.setQuery('', false);
      expect(view.showsDimming).assertTrue();
    });

    it('tableViewHeaderRules', 0, () => {
      const table = new CYLSearchTableView();
      expect(table.showsHeader).assertFalse();
      table.showsSearchBar = true;
      expect(table.showsHeader).assertTrue();
      table.hidesSearchBarWhenEmptyViewShowing = true;
      table.showEmptyView('No matching results');
      expect(table.isEmptyViewShowing).assertTrue();
      expect(table.showsHeader).assertFalse();
      table.hideEmptyView();
      expect(table.showsHeader).assertTrue();
      expect(table.searchBarView.automaticallyShowsCancelButton).assertTrue();
      expect(table.searchBarView.clearsTextOnCancel).assertTrue();
    });
  });
}
