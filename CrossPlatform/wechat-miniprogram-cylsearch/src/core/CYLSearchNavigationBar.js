// CYLSearchNavigationBar.swift for the mini program: the navigation bar that holds the search bar. `<cyl-search-navigation-bar>`
// draws it (below the status bar, clear of the capsule menu button); this class is its state and the measured widths.
'use strict';

const { cylNavigationMetrics, cylNavigationBarWidthsFrom } = require('./CYLSearchResources');

/**
 * A navigation bar that holds a search bar as its title (iOS `CYLSearchNavigationBar`).
 */
class CYLSearchNavigationBar {
  /**
   * The height of a navigation bar below the status bar, 44 px (WeChat measures its own: `cylNavigationMetrics()`).
   */
  static get standardHeight() {
    return 44;
  }

  /**
   * An empty bar (iOS `init(frame:)`).
   */
  constructor() {
    this.searchBarView = undefined;
    this.showsBackButton = false;
    /** Called when the back button is tapped; the bar never navigates, the host decides. */
    this.backHandler = undefined;
  }

  /**
   * A navigation bar holding `searchBarView` as its title, set up for it (a 36 px field, no side inset of its own); with
   * `showsBackButton` it has a back button on its leading side (iOS `holding(_:)` and `holding(_:showsBackButton:)`).
   */
  static holding(searchBarView, showsBackButton = false) {
    const bar = new CYLSearchNavigationBar();
    bar.searchBarView = searchBarView;
    bar.showsBackButton = !!showsBackButton;
    searchBarView.fieldHeight = cylNavigationMetrics().fieldHeight;
    searchBarView.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    return bar;
  }

  /**
   * The widths of the bar, from the window and menu button rectangles (leading, trailing, back button, the search bar's).
   */
  widths(window, menuButton) {
    return cylNavigationBarWidthsFrom(window, menuButton, this.showsBackButton);
  }

  /**
   * The back button was tapped (iOS `navigationBar(_:shouldPop:)`): `backHandler` runs and the bar keeps its items, so
   * it returns false.
   */
  navigationBar() {
    if (typeof this.backHandler === 'function') this.backHandler();
    return false;
  }
}

module.exports = { CYLSearchNavigationBar };
