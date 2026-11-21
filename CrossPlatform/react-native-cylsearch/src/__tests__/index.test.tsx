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
  cylAccessoryJSON,
  cylAppearanceJSON,
  cylInsetsArray,
  cylResultsForQuery,
  cylSplitMatch,
  cylSearchBarItemsJSON,
  cylSearchBarSelectedItem,
  cylSearchViewShowsResults,
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

describe('search results of the list', () => {
  it('splits a result around the first match, case sensitive', () => {
    expect(cylSplitMatch('Healthy', 'Health')).toEqual({
      before: '',
      match: 'Health',
      after: 'y',
    });
    expect(cylSplitMatch('Helps', 'H')).toEqual({
      before: '',
      match: 'H',
      after: 'elps',
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
