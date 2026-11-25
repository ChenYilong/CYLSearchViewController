import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'discover_page.dart';
import 'example_texts.dart';

/// The look of the search bar of one tab: every tab root owns its bar, in its own style (CYLTabBarController owns the tabs).
class CYLTabBarLook {
  /// Creates a look.
  const CYLTabBarLook({
    this.navigationFieldStyle = false,
    this.searchBarStyle = CYLSearchBarStyle.plain,
    this.showsSearchIcon = true,
    this.fieldShadowOpacity = 0,
    this.centersPlaceholder = false,
    this.camera = false,
  });

  /// The core navigation field preset (Discover look).
  final bool navigationFieldStyle;

  /// The fixed look of the bar when [navigationFieldStyle] is off.
  final CYLSearchBarStyle searchBarStyle;

  /// The magnifier at the start of the field.
  final bool showsSearchIcon;

  /// The field's shadow.
  final double fieldShadowOpacity;

  /// The placeholder is centered until the field is edited.
  final bool centersPlaceholder;

  /// A camera button inside the capsule before the default search button (which is then the round icon style).
  final bool camera;
}

/// One look per tab, in the order of the tabs: List style, Tag style, Empty results, Discover (the reference recording).
const List<CYLTabBarLook> cylTabBarLooks = <CYLTabBarLook>[
  CYLTabBarLook(navigationFieldStyle: true),
  CYLTabBarLook(searchBarStyle: CYLSearchBarStyle.bordered),
  CYLTabBarLook(centersPlaceholder: true),
  CYLTabBarLook(searchBarStyle: CYLSearchBarStyle.bordered, showsSearchIcon: false, fieldShadowOpacity: 0.06, camera: true),
];

/// The look of `tab`.
CYLTabBarLook cylTabBarLookOf(int tab) => cylTabBarLooks[tab.clamp(0, cylTabBarLooks.length - 1)];

/// Pushes the second-level search page of `tab` (recent and popular tag lists). A short cross fade: the second page's bar is the
/// same bar, so it looks like the first-level bar stays and only its back button and width change.
void cylPushSearchPage(BuildContext context, int tab) {
  Navigator.of(context).push(PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => CYLSearchDiscoverPage(tab: tab),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  ));
}

/// The app bar of a first-level page: the WHOLE search bar of the tab in the navigation bar slot, full width inside the safe area.
/// A tap on the field makes the native core bring the back button in and shrink the bar, and pushes [cylPushSearchPage].
/// The page sets no width.
PreferredSizeWidget cylFirstLevelAppBar(BuildContext context, {required int tab}) {
  final look = cylTabBarLookOf(tab);
  void push() => cylPushSearchPage(context, tab);
  return PreferredSize(
    preferredSize: const Size.fromHeight(44),
    child: SafeArea(
      child: CYLSearchBarView(
        placeholder: cylExampleText('Search'),
        navigationFieldStyle: look.navigationFieldStyle,
        searchBarStyle: look.searchBarStyle,
        showsSearchIcon: look.showsSearchIcon,
        fieldShadowOpacity: look.fieldShadowOpacity,
        centersPlaceholder: look.centersPlaceholder,
        embedsInNavigationBar: true,
        pushesOnTap: true,
        onFirstLevelTap: push,
        // The core's default search button (no item of ours): the round black icon on the camera tab (the reference recording), text on the others.
        searchButtonStyle: look.camera ? CYLSearchBarSearchButtonStyle.icon : CYLSearchBarSearchButtonStyle.text,
        searchButtonHandler: (_) => push(),
        items: <CYLSearchBarItem>[
          if (look.camera) ...<CYLSearchBarItem>[
            CYLSearchBarItem.icon(image: 'camera', title: 'Camera', animationURL: 'search_camera.json', onTap: (_) => push()),
          ],
        ],
      ),
    ),
  );
}
