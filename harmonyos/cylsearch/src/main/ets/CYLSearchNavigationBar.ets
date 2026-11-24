import { CYLSearchBarView, CYL_SEARCH_NAVIGATION_BAR_HEIGHT, CYL_SEARCH_NAVIGATION_FIELD_HEIGHT } from './CYLSearchBarView';

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * The insets of a search bar that sits in a navigation bar: 4 above and below the field, none at the sides (the page's
 * 16 vp margin is the inset that lines the bar up with the tag lists; iOS `holding(_:)`).
 */
function cylSearchNavigationContentInsets(): number[] {
  return [4, 0, 4, 0];
}

/**
 * Whether the navigation bar pops its page when the back button is tapped: never, the host decides (iOS
 * `navigationBar(_:shouldPop:)`).
 */
function cylSearchNavigationShouldPop(): boolean {
  return false;
}

// MARK: - Pure logic (end)

/**
 * Where a bar sits (iOS `UIBarPosition`).
 */
export enum CYLSearchBarPosition {
  /**
   * No position.
   */
  any = 0,
  /**
   * At the bottom edge.
   */
  bottom = 1,
  /**
   * At the top edge.
   */
  top = 2,
  /**
   * Attached to the top edge: its background extends under the status bar.
   */
  topAttached = 3
}

/**
 * The navigation bar the core makes for a page that has none, holding the search bar as its title (iOS
 * `CYLSearchNavigationBar`). `CYLSearchNavigationPage` draws it: it is the page's title bar, `standardHeight` high,
 * with the back button before the bar when `showsBackButton` is on.
 */
export class CYLSearchNavigationBar {
  /**
   * The height of the navigation bar, in vp: ArkUI's default title bar, 56 (iOS: 44 pt below the status bar).
   */
  static readonly standardHeight: number = CYL_SEARCH_NAVIGATION_BAR_HEIGHT;
  /**
   * The search bar that is the bar's title.
   */
  readonly searchBarView: CYLSearchBarView;
  /**
   * Whether the bar has the back button of a second-level page before the search bar.
   */
  readonly showsBackButton: boolean;
  /**
   * Whether the core made the bar (the page had no navigation bar) or the page's own bar holds the search bar.
   */
  readonly createdByCore: boolean;
  /**
   * Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never pops, the host
   * decides.
   */
  backHandler: (() => void) | undefined = undefined;

  /**
   * A navigation bar around `searchBarView`.
   */
  constructor(searchBarView: CYLSearchBarView, showsBackButton: boolean = false, createdByCore: boolean = true) {
    this.searchBarView = searchBarView;
    this.showsBackButton = showsBackButton;
    this.createdByCore = createdByCore;
  }

  /**
   * A navigation bar holding `searchBarView` as its title, with the bar set up for it (a 36 vp field, no side inset of
   * its own). With `showsBackButton` the bar has the back button of a second-level page before it; a tap calls
   * `backHandler`. The bridges use it as the content of their native view (iOS `holding(_:)` and
   * `holding(_:showsBackButton:)`).
   */
  static holding(searchBarView: CYLSearchBarView, showsBackButton: boolean = false): CYLSearchNavigationBar {
    CYLSearchNavigationBar.prepare(searchBarView);
    return new CYLSearchNavigationBar(searchBarView, showsBackButton, true);
  }

  /**
   * The back button was tapped: the host's `backHandler` runs and the bar stays; returns false, the answer of
   * `navigationBar(_:shouldPop:)`.
   */
  navigationBar(): boolean {
    this.backHandler?.();
    return cylSearchNavigationShouldPop();
  }

  /**
   * Attached to the top edge: the background extends under the status bar (iOS `position(for:)`).
   */
  position(): CYLSearchBarPosition {
    return CYLSearchBarPosition.topAttached;
  }

  /**
   * Puts `searchBarView` into the navigation bar of its page and returns that bar; a navigation bar always exists
   * afterwards. With `hostsNavigationBar` (the page has its own, such as a `NavDestination` title) the bar becomes its
   * title and `createdByCore` is false. Without one the core makes a `CYLSearchNavigationBar`, which
   * `CYLSearchNavigationPage` draws at the top of the page. The field becomes 36 vp high with no side inset of its
   * own, which fits the bar (iOS `embedInNavigationBar(of:)`).
   */
  static embedInNavigationBar(searchBarView: CYLSearchBarView, hostsNavigationBar: boolean): CYLSearchNavigationBar {
    CYLSearchNavigationBar.prepare(searchBarView);
    return new CYLSearchNavigationBar(searchBarView, false, !hostsNavigationBar);
  }

  private static prepare(searchBarView: CYLSearchBarView): void {
    const insets = cylSearchNavigationContentInsets();
    searchBarView.fieldHeight = CYL_SEARCH_NAVIGATION_FIELD_HEIGHT;
    searchBarView.contentInsets = { top: insets[0], left: insets[1], bottom: insets[2], right: insets[3] };
  }
}
