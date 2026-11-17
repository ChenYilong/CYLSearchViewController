import { describe, expect, it, jest } from '@jest/globals';

jest.mock('../CylsearchBarViewNativeComponent', () => 'CylsearchBarView');
jest.mock('../CylsearchViewNativeComponent', () => 'CylsearchView');
jest.mock('../CylsearchTagListViewNativeComponent', () => 'CylsearchTagListView');

import {
  cylSearchBarItemsJSON,
  cylSearchBarSelectedItem,
  cylSearchViewShowsResults,
  type CYLSearchBarItem,
} from '../CYLSearchProps';
import * as CYLSearch from '../index';

describe('CYLSearchBarView items', () => {
  it('sends the items without their handlers', () => {
    const items: CYLSearchBarItem[] = [
      { style: 'icon', image: 'camera', title: 'Search by image', onPress: () => {} },
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
    const items: CYLSearchBarItem[] = [{ style: 'divider' }, { style: 'icon', image: 'mic', onPress }];
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

describe('exports', () => {
  it('has one component per core class plus the tag list', () => {
    expect(Object.keys(CYLSearch).sort()).toEqual(['CYLSearchBarView', 'CYLSearchView', 'CYLTagListView']);
  });
});
