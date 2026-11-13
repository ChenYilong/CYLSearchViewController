import { useState } from 'react';
import { useColorScheme, type ViewProps } from 'react-native';
import CylsearchBarViewNative, {
  type NativeProps as SearchBarProps,
} from './CylsearchBarViewNativeComponent';
import CylsearchTagListViewNative, {
  type NativeProps as TagListProps,
} from './CylsearchTagListViewNativeComponent';
import CylsearchViewNative, {
  type NativeProps as SearchViewProps,
} from './CylsearchViewNativeComponent';

export type { SearchBarProps, SearchViewProps, TagListProps };

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
 * The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`). Give it a height (about 48).
 */
export function CYLSearchBarView(props: SearchBarProps) {
  const scheme = useColorScheme();
  return <CylsearchBarViewNative colorScheme={scheme === 'dark' ? 'dark' : 'light'} {...props} />;
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
