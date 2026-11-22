import { describe, expect, it, jest } from '@jest/globals';

jest.mock('../CylsearchBarViewNativeComponent', () => 'CylsearchBarView');
jest.mock('../CylsearchViewNativeComponent', () => 'CylsearchView');
jest.mock('../CylsearchListViewNativeComponent', () => ({
  __esModule: true,
  default: 'CylsearchListView',
  Commands: { setActive: jest.fn(), clearHistory: jest.fn() },
}));
jest.mock(
  '../CylsearchTagListViewNativeComponent',
  () => 'CylsearchTagListView'
);

import {
  cylAccessoriesJSON,
  cylAccessoryJSON,
  cylBarForwards,
  cylFontJSON,
  cylListForwards,
  cylAppearanceJSON,
  cylInsetsArray,
  cylResultsForQuery,
  cylSplitMatch,
  cylSearchBarItemsJSON,
  cylSearchBarSelectedItem,
  cylSearchViewShowsResults,
  cylSearchViewSuggestionStyle,
  type CYLSearchBarItem,
} from '../CYLSearchProps';
import * as CYLSearch from '../index';

describe('CYLSearchBarView items', () => {
  it('sends the items without their handlers', () => {
    const items: CYLSearchBarItem[] = [
      {
        style: 'icon',
        image: 'camera',
        title: 'Search by image',
        onPress: () => {},
      },
      { style: 'divider' },
      { style: 'text', title: 'Search', isSelectable: true, badgeValue: '' },
    ];
    expect(JSON.parse(cylSearchBarItemsJSON(items))).toEqual([
      { style: 'icon', image: 'camera', title: 'Search by image' },
      { style: 'divider' },
      { style: 'text', title: 'Search', isSelectable: true, badgeValue: '' },
    ]);
  });

  it('calls the tapped item with its selected state', () => {
    const onPress = jest.fn();
    const items: CYLSearchBarItem[] = [
      { style: 'divider' },
      { style: 'icon', image: 'mic', onPress },
    ];
    expect(cylSearchBarSelectedItem(items, 1, true)).toBe(items[1]);
    expect(onPress).toHaveBeenCalledWith(true);
    expect(cylSearchBarSelectedItem(items, 5, false)).toBeUndefined();
  });
});

describe('CYLSearchView results', () => {
  it('lists results only when they are given, unless showsResults says otherwise', () => {
    expect(cylSearchViewShowsResults(undefined, undefined)).toBe(false);
    expect(cylSearchViewShowsResults(undefined, [])).toBe(true);
    expect(cylSearchViewShowsResults(false, ['Swift'])).toBe(false);
    expect(cylSearchViewShowsResults(true, undefined)).toBe(true);
  });
});

describe('CYLSearchView suggestion style', () => {
  it('shows tags unless the app asks for the list', () => {
    expect(cylSearchViewSuggestionStyle(undefined)).toBe('tags');
    expect(cylSearchViewSuggestionStyle('tags')).toBe('tags');
    expect(cylSearchViewSuggestionStyle('list')).toBe('list');
  });
});

describe('QMUI search bar options', () => {
  it('sends margins as [top, left, bottom, right], none as an empty list', () => {
    expect(cylInsetsArray({ left: 32, right: 32 })).toEqual([0, 32, 0, 32]);
    expect(cylInsetsArray({ left: -16 })).toEqual([0, -16, 0, 0]);
    expect(cylInsetsArray(undefined)).toEqual([]);
  });

  it('sends an accessory as a 30 point square unless it says otherwise', () => {
    expect(
      JSON.parse(
        cylAccessoryJSON({
          kind: 'square',
          color: '#FF3B30',
          label: 'Accessory',
        })
      )
    ).toEqual({
      kind: 'square',
      size: 30,
      color: '#FF3B30',
      label: 'Accessory',
    });
    expect(
      JSON.parse(cylAccessoryJSON({ kind: 'square', size: 40 })).size
    ).toBe(40);
    expect(cylAccessoryJSON(undefined)).toBe('');
  });

  it('sends the appearance values that are set', () => {
    expect(
      JSON.parse(
        cylAppearanceJSON({ tintColor: '#0068F8', fieldCornerRadius: -1 })
      )
    ).toEqual({ tintColor: '#0068F8', fieldCornerRadius: -1 });
    expect(cylAppearanceJSON(undefined)).toBe('');
  });
});

describe('merged names', () => {
  it('lets the iOS names win over the first QMUI port names', () => {
    expect(
      cylListForwards({
        noResultsText: 'None',
        emptyViewText: 'Old',
        dimmingColor: '#000000',
        launchSuggestions: ['a'],
        historyPolicy: 'userDefaults',
        historyName: 'old',
        suggestionCacheName: 'new',
      })
    ).toEqual({
      noResultsText: 'None',
      scrimColor: '#000000',
      suggestions: ['a'],
      suggestionCachePolicy: 'userDefaults',
      suggestionCacheName: 'new',
    });
  });

  it('answers the presentation events under both spellings, the core names first', () => {
    const willShow = jest.fn();
    const willPresent = jest.fn();
    const didClose = jest.fn();
    const forwards = cylListForwards({
      onWillShow: willShow,
      onWillPresent: willPresent,
      onDidClose: didClose,
    });
    expect(forwards.onWillPresent).toBe(willPresent);
    expect(forwards.onDidDismiss).toBe(didClose);
    expect(forwards.onDidPresent).toBeUndefined();
    expect(cylListForwards({ onWillShow: willShow }).onWillPresent).toBe(
      willShow
    );
  });

  it('forwards the first port accessory names to the iOS ones', () => {
    const forwards = cylBarForwards({
      leadingAccessory: { kind: 'square' },
      trailingAccessory: { kind: 'square', size: 20 },
      showsLeadingAccessory: true,
      showsTrailingAccessory: false,
      appearance: { tintColor: '#0068F8' },
    });
    expect(JSON.parse(forwards.leadingViewJSON).size).toBe(30);
    expect(JSON.parse(forwards.trailingAccessoryViewsJSON)).toEqual([
      { kind: 'square', size: 20 },
    ]);
    expect(forwards.showsLeadingView).toBe(true);
    expect(forwards.showsTrailingAccessoryViews).toBe(false);
    expect(JSON.parse(forwards.appearanceStyleJSON)).toEqual({
      tintColor: '#0068F8',
    });
    expect(forwards.cancelButtonFontJSON).toBe('');
  });

  it('sends the cancel button font and the views after the text', () => {
    expect(JSON.parse(cylFontJSON({ size: 17, weight: 'semibold' }))).toEqual({
      size: 17,
      weight: 'semibold',
    });
    expect(cylFontJSON(undefined)).toBe('');
    expect(cylAccessoriesJSON([])).toBe('');
    expect(cylAccessoriesJSON(undefined)).toBe('');
    expect(
      JSON.parse(
        cylAccessoriesJSON([{ kind: 'square' }, { kind: 'square', size: 10 }])
      )
    ).toEqual([
      { kind: 'square', size: 30 },
      { kind: 'square', size: 10 },
    ]);
  });
});

describe('search results of the list', () => {
  it('splits a result around the first match, case and diacritic insensitive', () => {
    expect(cylSplitMatch('Healthy', 'Health')).toEqual({
      before: '',
      match: 'Health',
      after: 'y',
    });
    expect(cylSplitMatch('Helps', 'hel')).toEqual({
      before: '',
      match: 'Hel',
      after: 'ps',
    });
    expect(cylSplitMatch('Liver', 'h')).toEqual({
      before: 'Liver',
      match: '',
      after: '',
    });
    expect(cylSplitMatch('Liver', '')).toEqual({
      before: 'Liver',
      match: '',
      after: '',
    });
  });

  it('keeps the text as written when an accent is typed or not', () => {
    expect(cylSplitMatch('Café au lait', 'cafe')).toEqual({
      before: '',
      match: 'Café',
      after: ' au lait',
    });
    expect(cylSplitMatch('Cafe au lait', 'CAFÉ')).toEqual({
      before: '',
      match: 'Cafe',
      after: ' au lait',
    });
    expect(cylSplitMatch('Crème brûlée', 'brule')).toEqual({
      before: 'Crème ',
      match: 'brûlé',
      after: 'e',
    });
  });

  it('shows only the results that belong to the text', () => {
    expect(cylResultsForQuery('He', 'He', ['Helps'])).toEqual(['Helps']);
    expect(cylResultsForQuery('Hea', 'He', ['Helps'])).toEqual([]);
  });
});

describe('exports', () => {
  it('has one component per core class plus the list, the tag list and the placeholder', () => {
    const components = Object.keys(CYLSearch).filter((name) =>
      /^CYL[A-Z][a-z]+(?:[A-Z][a-z]+)*View$/.test(name)
    );
    expect(components.sort()).toEqual([
      'CYLPlaceholderView',
      'CYLSearchBarView',
      'CYLSearchListView',
      'CYLSearchView',
      'CYLTagListView',
    ]);
  });
});
