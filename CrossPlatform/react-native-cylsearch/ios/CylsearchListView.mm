#import "CylsearchListView.h"
#import "CYLRNSearchSupport.h"
#import "CYLRNSearchResults.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchListView () <RCTCylsearchListViewViewProtocol, CYLSearchViewDelegate, UITableViewDataSource, UITableViewDelegate>
@end

/*!
 * The list with a search bar and its search: the rows under a bar, and the core's `CYLSearchView` as the search. A tap on the
 * bar opens it; its suggestion area is the launch area (the history, else `suggestions`, as folded tags with the title and
 * the clear button), `scrimColor` the dimming, the results come from the one data source both components use
 * (`CYLRNSearchResults`) and the highlight is the core's option. The bar above the rows is a `CYLSearchBarView` too.
 */
@implementation CylsearchListView {
  UIView *_container;
  UITableView *_table;
  CYLSearchBarView *_headerBar;
  CYLSearchView *_searchView;
  CYLRNSearchResults *_results;
  NSArray<NSString *> *_rows;
  NSString *_noResultsText;
  BOOL _showsSearchBar;
  BOOL _hidesSearchBarInitially;
  BOOL _scrolledInitially;
  NSString *_updatedText;
  id _historyObserver;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchListViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchListViewProps>();
    _props = defaultProps;
    _rows = @[];
    _results = [CYLRNSearchResults new];
    _results.resultsQuery = @"";
    _container = [[UIView alloc] initWithFrame:self.bounds];
    _table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _table.dataSource = self;
    _table.delegate = self;
    _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_container addSubview:_table];
    _headerBar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 56)];
    _headerBar.placeholder = @"";
    [_headerBar applyDefaultAppearance];
    // The bar above the rows only starts the search: a tap anywhere on it opens the page, whose bar takes the typing.
    _headerBar.userInteractionEnabled = NO;
    UIView *header = [[UIView alloc] initWithFrame:_headerBar.frame];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [header addSubview:_headerBar];
    header.isAccessibilityElement = NO;
    [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSearch)]];
    _headerBar.isAccessibilityElement = YES;
    _headerBar.accessibilityTraits = UIAccessibilityTraitSearchField;
    _table.tableHeaderView = header;
    _showsSearchBar = YES;
    _searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    _searchView.delegate = self;
    _searchView.resultsDataSource = _results;
    // The bar of the page is Cancel-style, as a UISearchBar that is active: no back arrow.
    _searchView.searchBarView.navigationIcon = CYLSearchBarNavigationIconNone;
    _searchView.searchBarView.showsCancelButton = YES;
    [_searchView.searchBarView applyDefaultAppearance];
    // The page stays open after a submit: JavaScript decides what a submitted query does.
    _searchView.closesOnSubmit = NO;
    // A tapped tag submits, as the return key does.
    _searchView.submitsOnSuggestionSelection = YES;
    _searchView.showsEmptySuggestionsPlaceholder = NO;
    [_searchView installInView:_container];
    self.contentView = _container;
    __weak __typeof(self) weakSelf = self;
    // The history signal of the core's store: any change of the history this search keeps.
    _historyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"CYLSearchSuggestionStoreDidChange"
                                                                        object:nil
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
      [weakSelf historyChanged];
    }];
  }
  return self;
}

- (void)dealloc
{
  if (_historyObserver) {
    [[NSNotificationCenter defaultCenter] removeObserver:_historyObserver];
  }
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTCylsearchListViewHandleCommand(self, commandName, args);
}

/*!
 * The `setActive` command (`CYLSearchView.setActive(_:animated:)`).
 */
- (void)setActive:(BOOL)active animated:(BOOL)animated
{
  [_searchView setActive:active animated:animated];
}

/*!
 * The `clearHistory` command: the launch area's clear button.
 */
- (void)clearHistory
{
  [_searchView clearSuggestionCache];
}

- (void)openSearch
{
  [_searchView setActive:YES animated:YES];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchListViewProps const>(props);
  _container.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  NSString *placeholder = CYLRNString(p.placeholder);
  if (placeholder.length > 0) {
    _searchView.searchBarView.placeholder = placeholder;
    _headerBar.placeholder = placeholder;
    _headerBar.accessibilityLabel = placeholder;
  }
  _headerBar.centersPlaceholder = p.centersPlaceholder;
  _searchView.searchBarView.centersPlaceholder = p.centersPlaceholder;
  [self updateRows:CYLRNStrings(p.rows) showsSearchBar:p.showsSearchBar hidesInitially:p.hidesSearchBarInitially];
  // Results, the highlight and the empty view.
  _results.results = CYLRNStrings(p.results);
  _results.resultsQuery = CYLRNString(p.resultsQuery);
  _searchView.highlightsResultMatches = p.highlightsResultMatches;
  _searchView.resultMatchHighlightColor = CYLRNColor(CYLRNString(p.resultMatchHighlightColor));
  _noResultsText = CYLRNString(p.noResultsText);
  _searchView.showsEmptyResultsPlaceholder = _noResultsText.length > 0;
  [_searchView reloadResults];
  // The launch area: the core's suggestion area, shown while the text is empty when there is something to launch with.
  _searchView.suggestions = CYLRNStrings(p.suggestions);
  CYLRNApplySuggestionCache(_searchView, CYLRNString(p.suggestionCachePolicy), CYLRNString(p.suggestionCacheName), @"CylsearchListView",
                            CYLSearchSuggestionCachePolicyNone);
  _searchView.showsSuggestionsForEmptyQuery = p.suggestions.size() > 0 || _searchView.suggestionCachePolicy != CYLSearchSuggestionCachePolicyNone;
  _searchView.submitsOnSuggestionSelection = p.submitsOnSuggestionSelection;
  _searchView.scrimColor = CYLRNColor(CYLRNString(p.scrimColor));
  _searchView.supportsSwipeToDismissSearch = p.supportsSwipeToDismissSearch;
  [self applyNoResultsText];
  [super updateProps:props oldProps:oldProps];
}

/*!
 * The rows, the bar above them (`showsSearchBar`) and, once, the scroll that hides it (`hidesSearchBarInitially`).
 */
- (void)updateRows:(NSArray<NSString *> *)rows showsSearchBar:(BOOL)shows hidesInitially:(BOOL)hides
{
  BOOL rowsChanged = ![rows isEqualToArray:_rows];
  _rows = rows;
  if (shows != _showsSearchBar || _table.tableHeaderView == nil) {
    _showsSearchBar = shows;
    _table.tableHeaderView = shows ? _headerBar.superview : nil;
  }
  _hidesSearchBarInitially = hides;
  if (rowsChanged) {
    [_table reloadData];
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  if (_hidesSearchBarInitially && _showsSearchBar && !_scrolledInitially && _table.bounds.size.height > 0) {
    _scrolledInitially = YES;
    _table.contentOffset = CGPointMake(0, _headerBar.superview.bounds.size.height - _table.adjustedContentInset.top);
  }
}

/*!
 * The empty view's text (`noResultsText`): the placeholder's title, without its hint, once the placeholder exists.
 */
- (void)applyNoResultsText
{
  if (_noResultsText.length == 0) {
    return;
  }
  CYLPlaceholderStackView *placeholder = _searchView.emptyResultsView;
  placeholder.titleLabel.text = _noResultsText;
  placeholder.hintLabel.text = nil;
  placeholder.hintLabel.hidden = YES;
}

/*!
 * `onHistoryChange` with the newest query (empty after a clear) when the history this search keeps changed.
 */
- (void)historyChanged
{
  if (!_eventEmitter || _searchView.suggestionCachePolicy == CYLSearchSuggestionCachePolicyNone) {
    return;
  }
  NSString *query = [_searchView.suggestionCache cachedQueries].firstObject ?: @"";
  std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)
      ->onHistoryChange(CylsearchListViewEventEmitter::OnHistoryChange{.query = std::string(query.UTF8String ?: "")});
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  _searchView.resultsDataSource = _results;
  _results.results = @[];
  [_searchView closeSearchAnimated:NO];
  _rows = @[];
  _scrolledInitially = NO;
  [_table reloadData];
}

#pragma mark - Rows

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return (NSInteger)_rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CylsearchRow"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CylsearchRow"];
  cell.textLabel.text = _rows[(NSUInteger)indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)
        ->onSelectRow(CylsearchListViewEventEmitter::OnSelectRow{.row = std::string(_rows[(NSUInteger)indexPath.row].UTF8String ?: ""), .index = (int)indexPath.row});
  }
}

#pragma mark - CYLSearchViewDelegate

- (void)searchViewWillShow:(CYLSearchView *)searchView
{
  if (_eventEmitter) {
    auto emitter = std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter);
    emitter->onWillPresent(CylsearchListViewEventEmitter::OnWillPresent{});
    // The text is empty when the search opens: JavaScript answers with the results of "" too.
    emitter->onUpdateResults(CylsearchListViewEventEmitter::OnUpdateResults{.text = ""});
  }
  _updatedText = @"";
}

- (void)searchViewDidShow:(CYLSearchView *)searchView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)->onDidPresent(CylsearchListViewEventEmitter::OnDidPresent{});
  }
}

- (void)searchViewWillClose:(CYLSearchView *)searchView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)->onWillDismiss(CylsearchListViewEventEmitter::OnWillDismiss{});
  }
}

- (void)searchViewDidClose:(CYLSearchView *)searchView
{
  // A closed search starts empty the next time, as the controller's does.
  searchView.query = nil;
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)->onDidDismiss(CylsearchListViewEventEmitter::OnDidDismiss{});
  }
}

/*!
 * `onUpdateResults` with `text`, once for each text.
 */
- (void)emitUpdateResults:(NSString *)text
{
  _updatedText = text;
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)
        ->onUpdateResults(CylsearchListViewEventEmitter::OnUpdateResults{.text = std::string(text.UTF8String ?: "")});
  }
}

- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text
{
  [self emitUpdateResults:text];
  // The placeholder appears after the results reload: set its text on the next turn of the run loop.
  dispatch_async(dispatch_get_main_queue(), ^{
    [self applyNoResultsText];
  });
}

- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text
{
  // A tapped tag sets the text in code, which sends no `textDidChange`: JavaScript still has to answer with its results.
  if (![text isEqualToString:_updatedText ?: @""]) {
    [self emitUpdateResults:text];
  }
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)
        ->onSubmit(CylsearchListViewEventEmitter::OnSubmit{.text = std::string(text.UTF8String ?: "")});
  }
  return YES;
}

- (void)searchView:(CYLSearchView *)searchView didSelectResult:(id)result
{
  NSUInteger index = [searchView.searchResults indexOfObject:result];
  if (_eventEmitter && [result isKindOfClass:[NSString class]]) {
    std::static_pointer_cast<CylsearchListViewEventEmitter const>(_eventEmitter)
        ->onSelectResult(CylsearchListViewEventEmitter::OnSelectResult{
            .result = std::string(((NSString *)result).UTF8String ?: ""), .index = index == NSNotFound ? -1 : (int)index});
  }
}

@end
