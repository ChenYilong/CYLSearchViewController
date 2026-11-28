// CYLSearchNavigationBar.swift for the mini program: the navigation bar that holds the search bar. `<cyl-search-navigation-bar>`
// draws it (below the status bar, clear of the capsule menu button); this class is its state and the measured widths.
'use strict';

const { cylNavigationMetrics, cylNavigationBarWidthsFrom } = require('./CYLSearchResources');

/**
 * A navigation bar that holds a search bar as its title (iOS `CYLSearchNavigationBar`).
 */
// First-level navigation bar (owner directive 2026-11-26, docs/instructions/example-demos.md rule 10): the pure state
// machine of the back button and the bar width. The names are the cross-platform ones (iOS mirrors them).

/** The width of the back button's slot when fully shown (px), and the side inset of the bar without / with it. */
const CYL_BACK_SLOT_WIDTH = 32;
const CYL_TITLE_INSET_HIDDEN = 16;
const CYL_TITLE_INSET_SHOWN = 6;

/**
 * What a request to show or hide the back button does: 0 nothing (already as requested), 1 applies at once, 2 applies
 * animated. Asking for the state the button has is a no-op, so a push and an onShow that both ask do not animate twice.
 */
function cylBackButtonRequest(currentlyShown, wantsShown, animated) {
  if (Boolean(currentlyShown) === Boolean(wantsShown)) return 0;
  return animated ? 2 : 1;
}

/** The progress (0 hidden, 1 shown) clamped to its range; NaN is 0. */
function cylBackButtonProgress(progress) {
  if (!(progress > 0)) return 0;
  return progress > 1 ? 1 : progress;
}

/** The width of the back button's slot at `progress`. */
function cylBackSlotWidth(progress) {
  return CYL_BACK_SLOT_WIDTH * cylBackButtonProgress(progress);
}

/** The leading inset of the bar at `progress`: 16 hidden, 6 shown. */
function cylTitleLeadingInset(progress) {
  return CYL_TITLE_INSET_HIDDEN + (CYL_TITLE_INSET_SHOWN - CYL_TITLE_INSET_HIDDEN) * cylBackButtonProgress(progress);
}

/**
 * The width the search bar gets in a title bar of `containerWidth` (inside the safe area, `trailing` px kept free for the
 * menu button) at `progress`: the whole width at 0, narrower by the back slot and the smaller inset at 1. The component
 * lays the bar out with flex and CSS transitions; this is the same arithmetic, for tests and for hosts that measure.
 */
function cylBarWidth(containerWidth, progress, trailing = CYL_TITLE_INSET_HIDDEN) {
  return Math.max(0, containerWidth - cylTitleLeadingInset(progress) - trailing - cylBackSlotWidth(progress));
}

/**
 * What a tap on the bar does: 0 the bar edits as usual, 1 the tap is a push (back button in, then `firstleveltap` and the
 * navigation), 2 nothing (a first-level bar whose back button is already shown: the push is under way).
 */
function cylFirstLevelTapAction(pushesOnTap, backButtonShown) {
  if (!pushesOnTap) return 0;
  return backButtonShown ? 2 : 1;
}

/** Whether the back button belongs to the page that is shown: the first-level (root) page has none, a pushed page has one. */
function cylBackButtonWantedFor(isRootPage) {
  return !isRootPage;
}

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
    /** True on a first-level page: a tap on the bar is a push (back button in, then `onFirstLevelTap`). */
    this.pushesOnTap = false;
    /** Called after the back button started to come in; push the second-level page here. */
    this.onFirstLevelTap = undefined;
    /** How far the back button is shown, 0 to 1 (the component animates it with a CSS transition). */
    this.backButtonProgress = 0;
    /** Whether the last change was asked animated. */
    this.backButtonAnimated = false;
  }

  /**
   * Brings the back button in on the left; the bar narrows to make room. Asking twice is a no-op.
   */
  showBackButton(animated = true) {
    this.setBackButton(true, animated);
  }

  /**
   * Takes the back button out; the bar grows back to its full width.
   */
  hideBackButton(animated = true) {
    this.setBackButton(false, animated);
  }

  setBackButton(shown, animated) {
    const request = cylBackButtonRequest(this.showsBackButton, shown, animated);
    if (request === 0) return;
    this.showsBackButton = shown;
    this.backButtonAnimated = request === 2;
    this.backButtonProgress = shown ? 1 : 0;
  }

  /**
   * The tap of a first-level bar: back button in, then `onFirstLevelTap`; nothing for another bar or a push under way.
   */
  firstLevelTapped() {
    if (cylFirstLevelTapAction(this.pushesOnTap, this.showsBackButton) !== 1) return;
    this.showBackButton(true);
    if (typeof this.onFirstLevelTap === 'function') this.onFirstLevelTap();
  }

  /**
   * Keeps the back button in step with the page that is shown (the component calls it from the page's onShow).
   */
  syncBackButton(isRootPage, animated) {
    this.setBackButton(cylBackButtonWantedFor(isRootPage), animated);
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

module.exports = {
  CYLSearchNavigationBar,
  CYL_BACK_SLOT_WIDTH,
  cylBackButtonRequest,
  cylBackButtonProgress,
  cylBackSlotWidth,
  cylTitleLeadingInset,
  cylBarWidth,
  cylFirstLevelTapAction,
  cylBackButtonWantedFor,
};
