#import <UIKit/UIKit.h>
#import "CYLSearchBarView.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchView;

/*!
 * Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button.
 */
@protocol CYLSearchViewDelegate <NSObject>
@optional
/*!
 * The search view finished opening (MaterialSearchView `onSearchViewShown`).
 */
- (void)searchViewDidShow:(CYLSearchView *)searchView;
/*!
 * The search view finished closing (MaterialSearchView `onSearchViewClosed`).
 */
- (void)searchViewDidClose:(CYLSearchView *)searchView;
/*!
 * The query changed (`onQueryTextChange`).
 */
- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text;
/*!
 * The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open;
 * return NO (or leave this method out) to let the search view close.
 */
- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text;
/*!
 * The field started or stopped editing (lapism `OnFocusChangeListener`).
 */
- (void)searchView:(CYLSearchView *)searchView didChangeFocus:(BOOL)focused;
/*!
 * A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is
 * submitted when `submitsOnSuggestionSelection` is YES.
 */
- (void)searchView:(CYLSearchView *)searchView didSelectSuggestion:(NSString *)suggestion atIndex:(NSUInteger)index;
/*!
 * The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`.
 */
- (void)searchViewVoiceButtonClicked:(CYLSearchView *)searchView;
/*!
 * The navigation button (the back arrow by default) was tapped. Without this method it closes the search view.
 */
- (void)searchViewNavigationButtonClicked:(CYLSearchView *)searchView;
@end

/*!
 * A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list
 * of suggestions filtered as you type, and an optional content view of yours below (MiguelCatalan and lapism
 * `MaterialSearchView`). The page is opaque, so the bar never covers a view of the host.
 *
 *     CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
 *     searchView.suggestions = @[@"Android", @"iOS", @"SwiftUI"];
 *     searchView.delegate = self;
 *     [searchView attachToBarButtonItem:self.navigationItem.rightBarButtonItem];
 *     [searchView showSearch];
 */
@interface CYLSearchView : UIView

/*!
 * Receives the events of the search view.
 */
@property (nonatomic, weak, nullable) id<CYLSearchViewDelegate> delegate;
/*!
 * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
 */
@property (nonatomic, strong, readonly) CYLSearchBarView *searchBarView;
/*!
 * The line under the search bar.
 */
@property (nonatomic, strong, readonly) UIView *dividerView;
/*!
 * The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it.
 */
@property (nonatomic, strong, null_resettable) UIColor *dividerColor;
/*!
 * The table that lists the suggestions.
 */
@property (nonatomic, strong, readonly) UITableView *suggestionsTableView;
/*!
 * A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a
 * history, anything. Nil by default.
 */
@property (nonatomic, strong, nullable) UIView *contentView;
/*!
 * The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself
 * uses `backgroundColor`, `systemBackgroundColor` by default.
 */
@property (nonatomic, strong, nullable) UIColor *scrimColor;

#pragma mark Suggestions

/*!
 * The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
 */
@property (nonatomic, copy) NSArray<NSString *> *suggestions;
/*!
 * Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test.
 * An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES.
 */
@property (nonatomic, copy, nullable) BOOL (^suggestionFilter)(NSString *suggestion, NSString *query);
/*!
 * Lists every suggestion while the query is empty. NO by default.
 */
@property (nonatomic, assign) BOOL showsSuggestionsForEmptyQuery;
/*!
 * The suggestions that match the current query, in their original order.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *filteredSuggestions;
/*!
 * The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil
 * shows none.
 */
@property (nonatomic, strong, nullable) UIImage *suggestionImage;
/*!
 * The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background.
 */
@property (nonatomic, strong, nullable) UIColor *suggestionBackgroundColor;
/*!
 * The color of the suggestion text. `labelColor` by default.
 */
@property (nonatomic, strong, null_resettable) UIColor *suggestionTextColor;
/*!
 * How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole
 * text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis.
 */
@property (nonatomic, assign) NSLineBreakMode suggestionLineBreakMode;
/*!
 * Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the
 * person can edit it.
 */
@property (nonatomic, assign) BOOL submitsOnSuggestionSelection;
/*!
 * Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional.
 */
@property (nonatomic, copy, nullable) void (^suggestionCellConfiguration)(UITableViewCell *cell, NSString *suggestion, NSUInteger index);

#pragma mark Opening and closing

/*!
 * YES while the search view is open (MaterialSearchView `isSearchOpen`).
 */
@property (nonatomic, readonly, getter=isSearchOpen) BOOL searchOpen;
/*!
 * The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;
/*!
 * Closes the search view after a submitted query that the delegate did not handle. YES by default.
 */
@property (nonatomic, assign) BOOL closesOnSubmit;

/*!
 * Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key
 * window's root view when the search view has no superview.
 */
- (void)installInView:(UIView *)view;
/*!
 * Opens the search view with animation and starts editing (`showSearch`).
 */
- (void)showSearch;
/*!
 * Opens the search view and starts editing (`showSearch(animate)`).
 */
- (void)showSearchAnimated:(BOOL)animated;
/*!
 * Closes the search view with animation and ends editing (`closeSearch`).
 */
- (void)closeSearch;
/*!
 * Closes the search view and ends editing.
 */
- (void)closeSearchAnimated:(BOOL)animated;
/*!
 * Makes a bar button item open the search view (`setMenuItem`).
 */
- (void)attachToBarButtonItem:(UIBarButtonItem *)item;

#pragma mark Query and suggestions

/*!
 * The current query (lapism `getTextQuery`).
 */
@property (nonatomic, copy, nullable) NSString *query;
/*!
 * Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`).
 */
- (void)setQuery:(nullable NSString *)query submit:(BOOL)submit;
/*!
 * Lists the suggestions that match the current query (`showSuggestions`).
 */
- (void)showSuggestions;
/*!
 * Hides the suggestions (`dismissSuggestions`).
 */
- (void)dismissSuggestions;

@end

NS_ASSUME_NONNULL_END
