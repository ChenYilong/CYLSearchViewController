import {
  useImperativeHandle,
  useRef,
  useState,
  type ElementRef,
  type Ref,
} from 'react';
import { useColorScheme, type ViewProps } from 'react-native';
import CylsearchBarViewNative, {
  Commands as BarCommands,
  type NativeProps as NativeSearchBarProps,
} from './CylsearchBarViewNativeComponent';
import CylsearchListViewNative, {
  Commands as ListCommands,
  type NativeProps as NativeListProps,
} from './CylsearchListViewNativeComponent';
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
  cylAccessoryJSON,
  cylAppearanceJSON,
  cylInsetsArray,
  cylSearchBarItemsJSON,
  cylSearchBarSelectedItem,
  cylSearchViewShowsResults,
  cylSearchViewSuggestionStyle,
  type CYLEdgeInsets,
  type CYLSearchBarAccessory,
  type CYLSearchBarAppearance,
  type CYLSearchBarItem,
  type CYLSearchBarMode,
} from './CYLSearchProps';

export type {
  TagListProps,
  PlaceholderProps,
  CYLSearchBarItem,
  CYLSearchBarMode,
  CYLEdgeInsets,
  CYLSearchBarAccessory,
  CYLSearchBarAppearance,
};
export {
  cylAccessoryJSON,
  cylAppearanceJSON,
  cylInsetsArray,
  cylResultsForQuery,
  cylSplitMatch,
} from './CYLSearchProps';

/**
 * The search page's props: the native props, `showsResults` defaulting to whether `results` is given.
 */
export type SearchViewProps = NativeSearchViewProps;

/**
 * The search bar's props: the native props, with `items` in place of their JSON.
 */
export type SearchBarProps = Omit<
  NativeSearchBarProps,
  | 'itemsJSON'
  | 'onItemSelect'
  | 'mode'
  | 'fieldMargins'
  | 'searchingFieldMargins'
  | 'cancelMargins'
  | 'searchingCancelMargins'
  | 'leadingAccessoryJSON'
  | 'trailingAccessoryJSON'
  | 'showsLeadingAccessory'
  | 'showsTrailingAccessory'
  | 'appearanceJSON'
> & {
  /**
   * The field's margins at rest and while searching (`textFieldMargins` / `textFieldMarginsProvider(bar, active)`).
   */
  fieldMargins?: CYLEdgeInsets;
  searchingFieldMargins?: CYLEdgeInsets;
  /**
   * Cancel's margins at rest and while searching (`cancelButtonMarginsProvider(bar, active)`).
   */
  cancelMargins?: CYLEdgeInsets;
  searchingCancelMargins?: CYLEdgeInsets;
  /**
   * The views beside the field (`leadingAccessoryView`, `trailingAccessoryView`); give the spec to have the view and
   * `showsLeadingAccessory` / `showsTrailingAccessory` to show it, animated unless `animatesChanges` is false.
   */
  leadingAccessory?: CYLSearchBarAccessory;
  trailingAccessory?: CYLSearchBarAccessory;
  showsLeadingAccessory?: boolean;
  showsTrailingAccessory?: boolean;
  /**
   * `CYLSearchBarAppearance` values.
   */
  appearance?: CYLSearchBarAppearance;
  /**
   * The handle: `setActive(true)` starts the search (focus, the keyboard rises), `setActive(false)` ends it.
   */
  ref?: Ref<CYLSearchBarHandle>;
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
  onItemSelect?: (
    item: CYLSearchBarItem,
    index: number,
    selected: boolean
  ) => void;
};

/**
 * The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`): its search bar at the top,
 * the suggestions (a list or tags, the cached queries first), the `results` of the current query with pull-to-refresh
 * (`refreshEnabled`, `onRefresh`, `refreshing`) and CYLTableViewPlaceHolder's placeholders. Show it as a full screen
 * and leave it in `onClose`.
 */
export function CYLSearchView({ showsResults, suggestionStyle, ...props }: SearchViewProps) {
  const scheme = useColorScheme();
  return (
    <CylsearchViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      suggestionStyle={cylSearchViewSuggestionStyle(suggestionStyle)}
      showsResults={cylSearchViewShowsResults(showsResults, props.results)}
    />
  );
}

/**
 * The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`): the field, then the appended
 * `items`, or several searches side by side with `mode="multiple"` (`searches`, `onCompleteSearch`, `onRemoveSearch`,
 * `onSelectSearch`). Give it a height (about 48).
 */
export function CYLSearchBarView({
  items = [],
  onItemSelect,
  fieldMargins,
  searchingFieldMargins,
  cancelMargins,
  searchingCancelMargins,
  leadingAccessory,
  trailingAccessory,
  showsLeadingAccessory,
  showsTrailingAccessory,
  appearance,
  ref,
  ...props
}: SearchBarProps) {
  const scheme = useColorScheme();
  const native = useRef<ElementRef<typeof CylsearchBarViewNative>>(null);
  useImperativeHandle(ref, () => ({
    setActive: (active: boolean) => {
      if (native.current) BarCommands.setActive(native.current, active);
    },
  }));
  return (
    <CylsearchBarViewNative
      ref={native}
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      fieldMargins={cylInsetsArray(fieldMargins)}
      searchingFieldMargins={cylInsetsArray(searchingFieldMargins)}
      cancelMargins={cylInsetsArray(cancelMargins)}
      searchingCancelMargins={cylInsetsArray(searchingCancelMargins)}
      leadingAccessoryJSON={cylAccessoryJSON(leadingAccessory)}
      trailingAccessoryJSON={cylAccessoryJSON(trailingAccessory)}
      showsLeadingAccessory={showsLeadingAccessory}
      showsTrailingAccessory={showsTrailingAccessory}
      appearanceJSON={cylAppearanceJSON(appearance)}
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
export function CYLTagListView({
  style,
  onHeightChange,
  ...props
}: TagListProps & ViewProps) {
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
  return (
    <CylsearchPlaceholderViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
    />
  );
}
/**
 * What a `CYLSearchBarView` ref offers.
 */
export type CYLSearchBarHandle = {
  /**
   * Starts (focus, the keyboard rises) or ends the search from code (`isActive`).
   */
  setActive: (active: boolean) => void;
};

/**
 * What a `CYLSearchListView` ref offers.
 */
export type CYLSearchListHandle = {
  /**
   * Starts or ends the search from code (`setActive(_:animated:)`).
   */
  setActive: (active: boolean, animated?: boolean) => void;
  /**
   * Removes every query of the history (the launch view's clear button).
   */
  clearHistory: () => void;
};

/**
 * The props of the list with a search bar: the native props, with `ref`.
 */
export type SearchListProps = NativeListProps & {
  ref?: Ref<CYLSearchListHandle>;
};

/**
 * The list of CYLSearchViewController whose first item is the search bar (iOS `CYLSearchTableViewController`, Android
 * `CYLSearchListView`) with its search: the `rows`, the `results` of the text (answer `onUpdateResults`), a launch view
 * (`launchTitle`, history and tags), dimming, the empty view, the presentation events, `setActive`, the history and
 * its change event, swipe to dismiss, and the snapping of a bar above a short list (`snapsHeaderSearchBar`). Android
 * only for now: on iOS it waits for the merge of these members into the base classes (docs/qmui-search-controller.md).
 */
export function CYLSearchListView({ ref, ...props }: SearchListProps) {
  const scheme = useColorScheme();
  const native = useRef<ElementRef<typeof CylsearchListViewNative>>(null);
  useImperativeHandle(ref, () => ({
    setActive: (active: boolean, animated = true) => {
      if (native.current)
        ListCommands.setActive(native.current, active, animated);
    },
    clearHistory: () => {
      if (native.current) ListCommands.clearHistory(native.current);
    },
  }));
  return (
    <CylsearchListViewNative
      ref={native}
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
    />
  );
}
