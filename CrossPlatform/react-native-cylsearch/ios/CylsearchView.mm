#import "CylsearchView.h"
#import "CYLRNSearchSupport.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchView () <CYLSearchViewDelegate>
@end

/*!
 * CYLSearchView, open from the start: React Native leaves the screen in `onClose`.
 */
@implementation CylsearchView {
  UIView *_container;
  CYLSearchView *_searchView;
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
  NSDictionary<NSString *, NSNumber *> *policies = @{
    @"none": @(CYLSearchSuggestionCachePolicyNone), @"database": @(CYLSearchSuggestionCachePolicyDatabase),
    @"userDefaults": @(CYLSearchSuggestionCachePolicyUserDefaults), @"sandboxFile": @(CYLSearchSuggestionCachePolicySandboxFile)
  };
  CYLSearchSuggestionCachePolicy policy = (CYLSearchSuggestionCachePolicy)(policies[CYLRNString(p.suggestionCachePolicy)] ?: @(CYLSearchSuggestionCachePolicyDatabase)).integerValue;
  NSString *cacheName = CYLRNString(p.suggestionCacheName).length > 0 ? CYLRNString(p.suggestionCacheName) : @"CYLSearchView";
  if (policy != _searchView.suggestionCachePolicy || ![cacheName isEqualToString:_searchView.suggestionCacheName]) {
    _searchView.suggestionCacheName = cacheName;
    _searchView.suggestionCachePolicy = policy;
  }
  _searchView.focusesSearchFieldOnShow = p.focusesSearchFieldOnShow;
  _searchView.suggestionsFoldControl = CYLRNFoldControl(CYLRNString(p.suggestionsFoldControlPosition), CYLRNString(p.suggestionsFoldControlContent));
  _searchView.suggestionsFoldedRowCount = (NSUInteger)MAX(0, p.suggestionsFoldedRowCount);
  [super updateProps:props oldProps:oldProps];
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

- (void)searchViewDidClose:(CYLSearchView *)searchView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchViewEventEmitter const>(_eventEmitter)->onClose(CylsearchViewEventEmitter::OnClose{});
  }
}

@end
