#import "CylsearchView.h"
#import "CYLRNSearchSupport.h"
#import "CYLRNSearchResults.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchView () <CYLSearchViewDelegate>
@end

/*!
 * CYLSearchView, open from the start: React Native leaves the screen in `onClose`. It is the core's
 * `resultsDataSource` (the `results` prop, through the one data source of both components) and owns its `refreshHandler` (`onRefresh`).
 */
@implementation CylsearchView {
  UIView *_container;
  CYLSearchView *_searchView;
  CYLRNSearchResults *_results;
  BOOL _refreshing;
  BOOL _refreshFromProps;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchViewProps>();
    _props = defaultProps;
    _container = [[UIView alloc] initWithFrame:self.bounds];
    _results = [CYLRNSearchResults new];
    _searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    _searchView.delegate = self;
    // The page stays open after a submit: JavaScript decides what a submitted query does.
    _searchView.closesOnSubmit = NO;
    [_searchView installInView:_container];
    self.contentView = _container;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchViewProps const>(props);
  _container.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  _searchView.suggestions = CYLRNStrings(p.suggestions);
  _searchView.suggestionStyle = [CYLRNString(p.suggestionStyle) isEqualToString:@"tags"] ? CYLSearchSuggestionStyleTags : CYLSearchSuggestionStyleList;
  _searchView.searchBarView.placeholder = CYLRNString(p.placeholder);
  NSString *query = CYLRNString(p.query);
  if (query.length > 0 && ![query isEqualToString:_searchView.query ?: @""]) {
    _searchView.query = query;
  }
  _searchView.showsSuggestionsForEmptyQuery = p.showsSuggestionsForEmptyQuery;
  _searchView.submitsOnSuggestionSelection = p.submitsOnSuggestionSelection;
  _searchView.emptyResultsScenario = [CYLRNString(p.emptyResultsScenario) isEqualToString:@"noContent"]
      ? CYLPlaceholderScenarioNoContent : CYLPlaceholderScenarioNoSearchResults;
  _searchView.showsEmptyResultsPlaceholder = p.showsEmptyResultsPlaceholder;
  CYLRNApplySuggestionCache(_searchView, CYLRNString(p.suggestionCachePolicy), CYLRNString(p.suggestionCacheName), @"CYLSearchView",
                            CYLSearchSuggestionCachePolicyDatabase);
  _searchView.highlightsResultMatches = p.highlightsResultMatches;
  _searchView.resultMatchHighlightColor = CYLRNColor(CYLRNString(p.resultMatchHighlightColor));
  _searchView.focusesSearchFieldOnShow = p.focusesSearchFieldOnShow;
  _searchView.showsSuggestionCacheHeader = p.showsSuggestionCacheHeader;
  _searchView.suggestionsFoldControl = CYLRNFoldControl(CYLRNString(p.suggestionsFoldControlPosition), CYLRNString(p.suggestionsFoldControlContent));
  _searchView.suggestionsFoldedRowCount = (NSUInteger)MAX(0, p.suggestionsFoldedRowCount);
  [self updateResults:CYLRNStrings(p.results) shows:p.showsResults];
  [self updateRefreshEnabled:p.refreshEnabled refreshing:p.refreshing];
  [super updateProps:props oldProps:oldProps];
}

/*!
 * The `results` and `showsResults` props: the view is the core's data source while results are shown.
 */
- (void)updateResults:(NSArray<NSString *> *)results shows:(BOOL)shows
{
  BOOL changed = ![results isEqualToArray:_results.results];
  _results.results = results;
  id<CYLSearchViewDataSource> dataSource = shows ? _results : nil;
  if (_searchView.resultsDataSource != dataSource) {
    // Setting the data source queries it again.
    _searchView.resultsDataSource = dataSource;
  } else if (changed && shows) {
    [_searchView reloadResults];
  }
}

/*!
 * The `refreshEnabled` and `refreshing` props: the core's `refreshHandler`, `beginRefreshing` and `endRefreshing`.
 */
- (void)updateRefreshEnabled:(BOOL)enabled refreshing:(BOOL)refreshing
{
  BOOL newlyEnabled = enabled && !_searchView.refreshHandler;
  if (newlyEnabled) {
    __weak __typeof(self) weakSelf = self;
    _searchView.refreshHandler = ^{
      [weakSelf refreshStarted];
    };
  } else if (!enabled && _searchView.refreshHandler) {
    [_searchView endRefreshing];
    _searchView.refreshHandler = nil;
  }
  BOOL changed = refreshing != _refreshing;
  _refreshing = refreshing;
  if (refreshing && enabled && (changed || newlyEnabled) && !_searchView.isRefreshing) {
    // Started by JavaScript: the handler does not send `onRefresh` back.
    _refreshFromProps = YES;
    [_searchView beginRefreshing];
  } else if (!refreshing && changed && _searchView.isRefreshing) {
    [_searchView endRefreshing];
  }
}

/*!
 * The refresh handler: a pull sends `onRefresh`; a refresh started by the `refreshing` prop does not.
 */
- (void)refreshStarted
{
  if (_refreshFromProps) {
    _refreshFromProps = NO;
    return;
  }
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)->onRefresh(CylsearchViewEventEmitter::OnRefresh{});
  }
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  // Open once the view is on screen, so the keyboard (when focusesSearchFieldOnShow) can rise.
  if (self.window && !_searchView.isSearchOpen) {
    [_searchView showSearchAnimated:NO];
  }
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  [_searchView endRefreshing];
  _searchView.refreshHandler = nil;
  _searchView.resultsDataSource = nil;
  _results.results = @[];
  _refreshing = NO;
  _refreshFromProps = NO;
  [_searchView closeSearchAnimated:NO];
  _searchView.query = nil;
}

#pragma mark - CYLSearchViewDelegate

- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)
        ->onTextChange(CylsearchViewEventEmitter::OnTextChange{.text = std::string(text.UTF8String ?: "")});
  }
}

- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)
        ->onSubmit(CylsearchViewEventEmitter::OnSubmit{.text = std::string(text.UTF8String ?: "")});
  }
  return YES;
}

- (void)searchView:(CYLSearchView *)searchView didSelectSuggestion:(NSString *)suggestion atIndex:(NSUInteger)index
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)
        ->onSuggestionSelect(CylsearchViewEventEmitter::OnSuggestionSelect{
            .suggestion = std::string(suggestion.UTF8String ?: ""), .index = (int)index});
  }
}

- (void)searchView:(CYLSearchView *)searchView didSelectResult:(id)result
{
  NSUInteger index = [searchView.searchResults indexOfObject:result];
  if (_eventEmitter && [result isKindOfClass:[NSString class]]) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)
        ->onSelectResult(CylsearchViewEventEmitter::OnSelectResult{
            .result = std::string(((NSString *)result).UTF8String ?: ""), .index = index == NSNotFound ? -1 : (int)index});
  }
}

- (void)searchViewDidClose:(CYLSearchView *)searchView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)->onClose(CylsearchViewEventEmitter::OnClose{});
  }
}


@end
