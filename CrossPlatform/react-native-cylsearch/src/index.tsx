import { useState } from 'react';
import { useColorScheme, type ViewProps } from 'react-native';
import CylsearchBarViewNative, {
  type NativeProps as NativeSearchBarProps,
} from './CylsearchBarViewNativeComponent';
import CylsearchTagListViewNative, {
  type NativeProps as TagListProps,
} from './CylsearchTagListViewNativeComponent';
import CylsearchPlaceholderViewNative, {
  type NativeProps as PlaceholderProps,
} from './CylsearchPlaceholderViewNativeComponent';
import CylsearchViewNative, {
  type NativeProps as NativeSearchViewProps,
} from './CylsearchViewNativeComponent';

import {
  cylSearchBarItemsJSON,
  cylSearchBarSelectedItem,
  cylSearchViewShowsResults,
  type CYLSearchBarItem,
  type CYLSearchBarMode,
} from './CYLSearchProps';

export type { TagListProps, PlaceholderProps, CYLSearchBarItem, CYLSearchBarMode };

/**
 * The search page's props: the native props, `showsResults` defaulting to whether `results` is given.
 */
export type SearchViewProps = NativeSearchViewProps;

/**
 * The search bar's props: the native props, with `items` in place of their JSON.
 */
export type SearchBarProps = Omit<NativeSearchBarProps, 'itemsJSON' | 'onItemSelect' | 'mode'> & {
  /**
   * One field (`single`, the default) or several searches side by side (`multiple`).
   */
  mode?: CYLSearchBarMode;
  /**
   * The items appended after the text, in order.
   */
  items?: CYLSearchBarItem[];
  /**
   * An item was tapped, with its index, after the item's own `onPress`.
   */
  onItemSelect?: (item: CYLSearchBarItem, index: number, selected: boolean) => void;
};

/**
 * The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`): its search bar at the top,
 * the suggestions (a list or tags, the cached queries first), the `results` of the current query with pull-to-refresh
 * (`refreshEnabled`, `onRefresh`, `refreshing`) and CYLTableViewPlaceHolder's placeholders. Show it as a full screen
 * and leave it in `onClose`.
 */
export function CYLSearchView({ showsResults, ...props }: SearchViewProps) {
  const scheme = useColorScheme();
  return (
    <CylsearchViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      showsResults={cylSearchViewShowsResults(showsResults, props.results)}
    />
  );
}

/**
 * The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`): the field, then the appended
 * `items`, or several searches side by side with `mode="multiple"` (`searches`, `onCompleteSearch`, `onRemoveSearch`,
 * `onSelectSearch`). Give it a height (about 48).
 */
export function CYLSearchBarView({ items = [], onItemSelect, ...props }: SearchBarProps) {
  const scheme = useColorScheme();
  return (
    <CylsearchBarViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      itemsJSON={cylSearchBarItemsJSON(items)}
      onItemSelect={(event) => {
        const { index, selected } = event.nativeEvent;
        const item = cylSearchBarSelectedItem(items, index, selected);
        if (item) onItemSelect?.(item, index, selected);
      }}
    />
  );
}

/**
 * CollectionViewClassifyMenu's tag list (the view of the tag style): it takes the height its tags need, folded to two
 * rows behind a chevron by default.
 */
export function CYLTagListView({ style, onHeightChange, ...props }: TagListProps & ViewProps) {
  const scheme = useColorScheme();
  const [height, setHeight] = useState(44);
  return (
    <CylsearchTagListViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      style={[{ height }, style]}
      onHeightChange={(event) => {
        setHeight(event.nativeEvent.height);
        onHeightChange?.(event);
      }}
    />
  );
}

/**
 * CYLTableViewPlaceHolder's placeholder (`CYLPlaceholderView`): the image of `placeholderStyle` ("empty", "noResults",
 * "personOff", …) above `text`, at its content size (give it a height or let flex size it).
 */
export function CYLPlaceholderView(props: PlaceholderProps & ViewProps) {
  const scheme = useColorScheme();
  return <CylsearchPlaceholderViewNative colorScheme={scheme === 'dark' ? 'dark' : 'light'} {...props} />;
}
