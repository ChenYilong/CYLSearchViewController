import { useState } from 'react';
import { useColorScheme, type ViewProps } from 'react-native';
import CylsearchBarViewNative, {
  type NativeProps as NativeSearchBarProps,
} from './CylsearchBarViewNativeComponent';
import CylsearchTagListViewNative, {
  type NativeProps as TagListProps,
} from './CylsearchTagListViewNativeComponent';
import CylsearchViewNative, {
  type NativeProps as SearchViewProps,
} from './CylsearchViewNativeComponent';

export type { SearchViewProps, TagListProps };

/**
 * One element after the text of a search bar (iOS and Android `CYLSearchBarItem`, like the FlatDesign tab bar's
 * items). The field stays; the bar only appends items.
 */
export type CYLSearchBarItem = {
  /** "icon" (36-point touch area), "divider" (skipped by screen readers) or "text" (a "Search" button). */
  style: 'icon' | 'divider' | 'text';
  /** The text of a text item, and the screen reader label of an icon item. */
  title?: string;
  /** `camera`, `mic`, `search` or `back` (drawn by the core), else an app image (iOS asset or SF Symbol, Android drawable). */
  image?: string;
  /** A test identifier of the item view. */
  accessibilityIdentifier?: string;
  /** False dims the item and ignores taps. */
  isEnabled?: boolean;
  /** Each tap toggles the selected state on the native side. */
  isSelectable?: boolean;
  /** The selected state. */
  isSelected?: boolean;
  /** The badge text; "" draws a dot. */
  badgeValue?: string;
  /** Called on each tap with the selected state after the tap. */
  onPress?: (selected: boolean) => void;
};

/**
 * The search bar's props: the native props, with `items` in place of their JSON.
 */
export type SearchBarProps = Omit<NativeSearchBarProps, 'itemsJSON' | 'onItemSelect'> & {
  /** The items appended after the text, in order. */
  items?: CYLSearchBarItem[];
  /** An item was tapped, with its index, after the item's own `onPress`. */
  onItemSelect?: (item: CYLSearchBarItem, index: number, selected: boolean) => void;
};

/**
 * The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`): its search bar at the top,
 * the suggestions (a list or tags, the cached queries first) and CYLTableViewPlaceHolder's placeholders. Show it as a
 * full screen and leave it in `onClose`.
 */
export function CYLSearchView(props: SearchViewProps) {
  const scheme = useColorScheme();
  return <CylsearchViewNative colorScheme={scheme === 'dark' ? 'dark' : 'light'} {...props} />;
}

/**
 * The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`): the field, then the appended
 * `items`. Give it a height (about 48).
 */
export function CYLSearchBarView({ items = [], onItemSelect, ...props }: SearchBarProps) {
  const scheme = useColorScheme();
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const itemsJSON = JSON.stringify(items.map(({ onPress, ...values }) => values));
  return (
    <CylsearchBarViewNative
      colorScheme={scheme === 'dark' ? 'dark' : 'light'}
      {...props}
      itemsJSON={itemsJSON}
      onItemSelect={(event) => {
        const { index, selected } = event.nativeEvent;
        const item = items[index];
        if (!item) return;
        item.onPress?.(selected);
        onItemSelect?.(item, index, selected);
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
