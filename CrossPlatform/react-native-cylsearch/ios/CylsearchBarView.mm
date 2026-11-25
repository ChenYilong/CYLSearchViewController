#import "CylsearchBarView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchBarView () <CYLSearchBarViewDelegate, RCTCylsearchBarViewViewProtocol>
@end

/*!
 * CYLSearchBarView filling the component; with `editingBar`, the core's editing bar
 * (CYLSearchBarView `editingBarWithPlaceholder:actionTitle:`), whose submit is sent as `onEditingSubmit`.
 */
@implementation CylsearchBarView {
  CYLSearchBarView *_bar;
  CYLSearchNavigationBar *_navigationBar;
  BOOL _navigationBarShowsBackButton;
  NSString *_itemsJSON;
  NSArray<NSString *> *_searches;
  BOOL _applyingSearches;
  NSString *_actionTitle;
  NSString *_textProp;
  // What was applied last, so a re-render keeps what the native bar changed itself (the show states animate from the second one).
  NSString *_appearanceKey;
  NSString *_leadingJSON;
  NSString *_trailingJSON;
  NSNumber *_shownCancel;
  NSNumber *_shownLeading;
  NSNumber *_shownTrailing;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchBarViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchBarViewProps>();
    _props = defaultProps;
    _bar = [[CYLSearchBarView alloc] initWithFrame:self.bounds];
    _bar.delegate = self;
    self.contentView = _bar;
  }
  return self;
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTCylsearchBarViewHandleCommand(self, commandName, args);
}

/*!
 * The `setActive` command: the field takes the focus (the keyboard rises) or gives it up.
 */
- (void)setActive:(BOOL)active
{
  if (active) {
    [_bar showKeyboard];
  } else {
    [_bar hideKeyboard];
  }
}

/*!
 * The `restartItemAnimation` command: plays the animation of the item at `index` again from the start.
 */
- (void)restartItemAnimation:(NSInteger)index
{
  if (index >= 0 && index < (NSInteger)_bar.items.count) {
    [_bar.items[index] restartAnimation];
  }
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchBarViewProps const>(props);
  if (_navigationBar && (!p.embedsInNavigationBar || _navigationBarShowsBackButton != (BOOL)p.showsBackButton)) {
    // A recycled view (Fabric reuses the Discover bar's view for another field) or new props: no navigation bar, or
    // the other back button. Start again from a plain bar, as at init; the lines below embed it again when asked.
    _navigationBar.backHandler = nil;
    _navigationBar = nil;
    [self useEditingBar:NO placeholder:nil actionTitle:nil];
  }
  if (p.embedsInNavigationBar && !_navigationBar) {
    // The page's search bar always sits in a navigation bar: the core's, with the bar as its title view, and the back
    // button of a second-level page when asked (a tap goes to JavaScript, which closes the page).
    _navigationBar = [CYLSearchNavigationBar navigationBarHoldingSearchBar:_bar showsBackButton:p.showsBackButton];
    _navigationBarShowsBackButton = p.showsBackButton;
    __weak __typeof(self) weakSelf = self;
    _navigationBar.backHandler = ^{
      __strong __typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf && strongSelf->_eventEmitter) {
        std::static_pointer_cast<CylsearchBarViewEventEmitter const>(strongSelf->_eventEmitter)
            ->onBackButtonTap(CylsearchBarViewEventEmitter::OnBackButtonTap{.tapped = true});
      }
    };
    self.contentView = _navigationBar;
  }
  NSString *actionTitle = CYLRNString(p.actionTitle);
  if ((BOOL)p.editingBar != _bar.isEditingBar) {
    [self useEditingBar:p.editingBar placeholder:CYLRNString(p.placeholder) actionTitle:actionTitle];
  } else if (_bar.isEditingBar && actionTitle.length > 0 && ![actionTitle isEqualToString:_actionTitle ?: @""]) {
    _bar.cancelButtonTitle = actionTitle;
  }
  _actionTitle = actionTitle;
  _bar.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  _bar.placeholder = CYLRNString(p.placeholder);
  NSString *text = CYLRNString(p.text);
  if (text.length > 0 && ![text isEqualToString:_bar.text ?: @""]) {
    _bar.text = text;
  }
  // An editing bar given a new title (the host's answer to `onRenameRequest`) takes focus with the title selected, so
  // the rename is typed at once, as the iOS example's `beginRenaming` does.
  if (_bar.isEditingBar && text.length > 0 && ![text isEqualToString:_textProp ?: @""]) {
    CYLSearchBarView *bar = _bar;
    dispatch_async(dispatch_get_main_queue(), ^{
      [bar showKeyboard];
      [bar.textField selectAll:nil];
    });
  }
  _textProp = text;
  _bar.focusesOnAppear = p.focusesOnAppear;
  // The core's default search button: shown unless JavaScript hides it; with a JavaScript handler a tap sends onSearchButtonTap.
  _bar.showsSearchButton = p.showsSearchButton;
  CYLSearchBarSearchButtonStyle buttonStyle = [CYLRNString(p.searchButtonStyle) isEqualToString:@"icon"] ? CYLSearchBarSearchButtonStyleIcon : CYLSearchBarSearchButtonStyleText;
  if (_bar.searchButtonStyle != buttonStyle) {
    _bar.searchButtonStyle = buttonStyle;
  }
  NSString *buttonTitle = CYLRNString(p.searchButtonTitle);
  if (buttonTitle.length == 0) {
    buttonTitle = nil;
  }
  if (![(_bar.searchButtonTitle ?: @"") isEqualToString:(buttonTitle ?: @"")]) {
    _bar.searchButtonTitle = buttonTitle;
  }
  if (p.hasSearchButtonHandler) {
    __weak CylsearchBarView *weakSelf = self;
    _bar.searchButtonHandler = ^(CYLSearchBarView *view) {
      CylsearchBarView *strongSelf = weakSelf;
      if (strongSelf && strongSelf->_eventEmitter) {
        std::static_pointer_cast<CylsearchBarViewEventEmitter const>(strongSelf->_eventEmitter)
            ->onSearchButtonTap(CylsearchBarViewEventEmitter::OnSearchButtonTap{.text = std::string((view.text ?: @"").UTF8String)});
      }
    };
  } else {
    _bar.searchButtonHandler = nil;
  }
  if (p.navigationFieldStyle) {
    // The core's one navigation field look (bordered capsule, soft shadow, no magnifier, opaque fill).
    [_bar applyNavigationFieldStyle];
  } else {
    _bar.fieldShadowOpacity = p.fieldShadowOpacity;
    _bar.searchBarStyle = [CYLRNString(p.searchBarStyle) isEqualToString:@"bordered"] ? CYLSearchBarStyleBordered : CYLSearchBarStylePlain;
  }
  // An editing bar keeps the core's own setup: no magnifier, its action button always shown.
  if (!_bar.isEditingBar) {
    // Cancel changes with an animation from the second change on (`setShowsCancelButton(_:animated:)`).
    if (_shownCancel == nil || _shownCancel.boolValue != (BOOL)p.showsCancelButton) {
      [_bar setShowsCancelButton:p.showsCancelButton animated:p.animatesChanges && _shownCancel != nil];
      _shownCancel = @(p.showsCancelButton);
    }
    if (!p.navigationFieldStyle) {
      _bar.searchIcon = p.showsSearchIcon ? [UIImage systemImageNamed:@"magnifyingglass"] : nil;
    }
  }
  // Rebuilt only when JavaScript sends other items, so a re-render keeps the native selection.
  NSString *itemsJSON = CYLRNString(p.itemsJSON) ?: @"";
  if (![itemsJSON isEqualToString:_itemsJSON ?: @""]) {
    _itemsJSON = itemsJSON;
    NSData *data = [itemsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *values = data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    NSMutableArray<NSDictionary *> *dictionaries = [NSMutableArray array];
    for (id value in [values isKindOfClass:[NSArray class]] ? values : @[]) {
      if ([value isKindOfClass:[NSDictionary class]]) {
        [dictionaries addObject:value];
      }
    }
    // A change of animationLoops or animationSpeed alone keeps the items (the core's setItemsWithDictionaries:).
    [_bar setItemsWithDictionaries:dictionaries];
  }
  CYLSearchBarMode mode = [CYLRNString(p.mode) isEqualToString:@"multiple"] ? CYLSearchBarModeMultiple : CYLSearchBarModeSingle;
  BOOL modeChanged = mode != _bar.mode;
  _bar.mode = mode;
  _bar.minimumTextLength = (NSUInteger)MAX(0, p.minimumTextLength);
  // Replaced only when JavaScript sends another list (or turns "multiple" on), so a re-render keeps the searches
  // typed natively.
  NSArray<NSString *> *searches = CYLRNStrings(p.searches);
  if (modeChanged || ![searches isEqualToArray:_searches ?: @[]]) {
    _searches = searches;
    [self applySearches:searches];
  }
  [self applyStyleProps:p];
  [super updateProps:props oldProps:oldProps];
}

/*!
 * The style options, members of `CYLSearchBarView`: `appearanceStyle` (the default appearance and the values of
 * `appearanceStyleJSON`), `centersPlaceholder`, the colors, `textFieldMarginsProvider` and `cancelButtonMarginsProvider`
 * (from the margins at rest and while searching), `cancelButtonFont`, `leadingView`, `trailingAccessoryViews` and their
 * animated show states. The appearance goes first, so the colors set after it win.
 */
- (void)applyStyleProps:(CylsearchBarViewProps const &)p
{
  NSString *appearanceJSON = CYLRNString(p.appearanceStyleJSON);
  NSString *appearanceKey = [NSString stringWithFormat:@"%d|%@", (int)p.usesDefaultAppearance, appearanceJSON];
  if (![appearanceKey isEqualToString:_appearanceKey ?: @""]) {
    _appearanceKey = appearanceKey;
    NSDictionary *values = [CYLRNJSON(appearanceJSON) isKindOfClass:[NSDictionary class]] ? CYLRNJSON(appearanceJSON) : @{};
    if (p.usesDefaultAppearance || values.count > 0) {
      CYLSearchBarAppearance *appearance = p.usesDefaultAppearance ? [CYLSearchBarAppearance.defaultAppearance copy] : [CYLSearchBarAppearance new];
      NSDictionary<NSString *, NSString *> *colors = @{@"textColor": @"textColor", @"placeholderColor": @"placeholderColor", @"tintColor": @"tintColor",
                                                       @"fieldBackgroundColor": @"textFieldBackgroundColor"};
      for (NSString *key in colors) {
        UIColor *color = [values[key] isKindOfClass:[NSString class]] ? CYLRNColor(values[key]) : nil;
        if (color) {
          [appearance setValue:color forKey:colors[key]];
        }
      }
      if ([values[@"cancelTitle"] isKindOfClass:[NSString class]] && [values[@"cancelTitle"] length] > 0) {
        appearance.cancelTitle = values[@"cancelTitle"];
      }
      if ([values[@"fieldCornerRadius"] isKindOfClass:[NSNumber class]]) {
        appearance.textFieldCornerRadius = [values[@"fieldCornerRadius"] doubleValue];
      }
      if ([values[@"fontSize"] isKindOfClass:[NSNumber class]]) {
        appearance.font = [UIFont systemFontOfSize:[values[@"fontSize"] doubleValue]];
      }
      _bar.appearanceStyle = appearance;
    } else {
      _bar.appearanceStyle = nil;
    }
  }
  // The appearance may carry a placeholder of its own; the prop wins.
  if (p.placeholder.length() > 0) {
    _bar.placeholder = CYLRNString(p.placeholder);
  }
  UIColor *placeholderColor = CYLRNColor(CYLRNString(p.placeholderColor));
  if (placeholderColor) {
    _bar.placeholderColor = placeholderColor;
  }
  UIColor *textColor = CYLRNColor(CYLRNString(p.textColor));
  if (textColor) {
    _bar.textColor = textColor;
  }
  _bar.centersPlaceholder = p.centersPlaceholder;
  _bar.textFieldMarginsProvider = [self marginsProviderAtRest:p.fieldMargins searching:p.searchingFieldMargins];
  _bar.cancelButtonMarginsProvider = [self marginsProviderAtRest:p.cancelMargins searching:p.searchingCancelMargins];
  NSDictionary *fontSpec = [CYLRNJSON(CYLRNString(p.cancelButtonFontJSON)) isKindOfClass:[NSDictionary class]] ? CYLRNJSON(CYLRNString(p.cancelButtonFontJSON)) : nil;
  if (fontSpec) {
    NSString *weight = [fontSpec[@"weight"] isKindOfClass:[NSString class]] ? fontSpec[@"weight"] : @"";
    UIFontWeight fontWeight = [weight isEqualToString:@"bold"] ? UIFontWeightBold : [weight isEqualToString:@"semibold"] ? UIFontWeightSemibold
        : [weight isEqualToString:@"medium"] ? UIFontWeightMedium : UIFontWeightRegular;
    CGFloat size = [fontSpec[@"size"] isKindOfClass:[NSNumber class]] ? [fontSpec[@"size"] doubleValue] : 17;
    _bar.cancelButtonFont = [UIFont systemFontOfSize:size weight:fontWeight];
  } else {
    _bar.cancelButtonFont = nil;
  }
  NSString *leadingJSON = CYLRNString(p.leadingViewJSON);
  if (![leadingJSON isEqualToString:_leadingJSON ?: @""]) {
    _leadingJSON = leadingJSON;
    _bar.leadingView = CYLRNSquare(CYLRNJSON(leadingJSON));
  }
  NSString *trailingJSON = CYLRNString(p.trailingAccessoryViewsJSON);
  if (![trailingJSON isEqualToString:_trailingJSON ?: @""]) {
    _trailingJSON = trailingJSON;
    NSMutableArray<UIView *> *views = [NSMutableArray array];
    id specs = CYLRNJSON(trailingJSON);
    for (id spec in [specs isKindOfClass:[NSArray class]] ? specs : @[]) {
      UIView *view = CYLRNSquare(spec);
      if (view) {
        [views addObject:view];
      }
    }
    _bar.trailingAccessoryViews = views;
  }
  if (_shownLeading == nil || _shownLeading.boolValue != (BOOL)p.showsLeadingView) {
    [_bar setShowsLeadingView:p.showsLeadingView animated:p.animatesChanges && _shownLeading != nil];
    _shownLeading = @(p.showsLeadingView);
  }
  if (_shownTrailing == nil || _shownTrailing.boolValue != (BOOL)p.showsTrailingAccessoryViews) {
    [_bar setShowsTrailingAccessoryViews:p.showsTrailingAccessoryViews animated:p.animatesChanges && _shownTrailing != nil];
    _shownTrailing = @(p.showsTrailingAccessoryViews);
  }
}

/*!
 * The margins provider (`textFieldMarginsProvider(bar, active)`) of the margins at rest and while searching; nil for none.
 */
- (nullable UIEdgeInsets (^)(CYLSearchBarView *, BOOL))marginsProviderAtRest:(const std::vector<double> &)rest searching:(const std::vector<double> &)searching
{
  if (rest.empty() && searching.empty()) {
    return nil;
  }
  UIEdgeInsets restInsets = CYLRNInsets(rest);
  UIEdgeInsets searchingInsets = CYLRNInsets(searching);
  BOOL hasSearching = !searching.empty();
  return ^UIEdgeInsets(CYLSearchBarView *bar, BOOL active) {
    return active && hasSearching ? searchingInsets : restInsets;
  };
}

/*!
 * Swaps in the core's editing bar (or a search bar again): its submit goes to `onEditingSubmit` with the trimmed text,
 * and the field is cleared for the next name.
 */
- (void)useEditingBar:(BOOL)editing placeholder:(NSString *)placeholder actionTitle:(NSString *)actionTitle
{
  [_bar removeFromSuperview];
  _itemsJSON = nil;
  _textProp = nil;
  _searches = nil;
  _appearanceKey = nil;
  _leadingJSON = nil;
  _trailingJSON = nil;
  _shownCancel = nil;
  _shownLeading = nil;
  _shownTrailing = nil;
  if (editing) {
    _bar = [CYLSearchBarView editingBarWithPlaceholder:placeholder
                                           actionTitle:actionTitle.length > 0 ? actionTitle : NSLocalizedString(@"Done", nil)];
    __weak __typeof(self) weakSelf = self;
    _bar.editingSubmitHandler = ^(CYLSearchBarView *bar, NSString *text) {
      [weakSelf emitEditingSubmit:text];
      bar.text = @"";
    };
  } else {
    _bar = [[CYLSearchBarView alloc] initWithFrame:self.bounds];
  }
  _bar.delegate = self;
  self.contentView = _bar;
}

- (void)emitEditingSubmit:(NSString *)text
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onEditingSubmit(CylsearchBarViewEventEmitter::OnEditingSubmit{.text = std::string(text.UTF8String ?: "")});
  }
}

/*!
 * Replaces the native searches ("multiple" mode) without sending remove events back to JavaScript.
 */
- (void)applySearches:(NSArray<NSString *> *)searches
{
  // The list JavaScript keeps from the events is already on screen: nothing to rebuild.
  if (_bar.mode != CYLSearchBarModeMultiple || [searches isEqualToArray:_bar.searches]) {
    return;
  }
  _applyingSearches = YES;
  for (NSInteger index = (NSInteger)_bar.searches.count - 1; index >= 0; index--) {
    [_bar removeSearchAtIndex:index];
  }
  for (NSString *search in searches) {
    [_bar addSearch:search];
  }
  _applyingSearches = NO;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  _searches = nil;
  _itemsJSON = nil;
  _appearanceKey = nil;
  _leadingJSON = nil;
  _trailingJSON = nil;
  _shownCancel = nil;
  _shownLeading = nil;
  _shownTrailing = nil;
  [self applySearches:@[]];
  [_bar removeAllItems];
}

#pragma mark - CYLSearchBarViewDelegate

- (void)searchBarView:(CYLSearchBarView *)searchBarView didSelectItem:(CYLSearchBarItem *)item
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onItemSelect(CylsearchBarViewEventEmitter::OnItemSelect{.index = (int)item.index, .selected = (bool)item.isSelected});
  }
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text
{
  [self emitTextChange:text index:-1];
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text atIndex:(NSInteger)index
{
  [self emitTextChange:text index:index];
}

/*!
 * `onTextChange` with the index of the search being typed, -1 in "single" mode.
 */
- (void)emitTextChange:(NSString *)text index:(NSInteger)index
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onTextChange(CylsearchBarViewEventEmitter::OnTextChange{.text = std::string(text.UTF8String ?: ""), .index = (int)index});
  }
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView didCompleteSearch:(NSString *)text atIndex:(NSInteger)index
{
  if (_eventEmitter && !_applyingSearches) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onCompleteSearch(CylsearchBarViewEventEmitter::OnCompleteSearch{.text = std::string(text.UTF8String ?: ""), .index = (int)index});
  }
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView didRemoveSearchAtIndex:(NSInteger)index
{
  if (_eventEmitter && !_applyingSearches) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onRemoveSearch(CylsearchBarViewEventEmitter::OnRemoveSearch{.index = (int)index});
  }
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView didSelectSearch:(NSString *)text atIndex:(NSInteger)index
{
  if (_eventEmitter && !_applyingSearches) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onSelectSearch(CylsearchBarViewEventEmitter::OnSelectSearch{.text = std::string(text.UTF8String ?: ""), .index = (int)index});
  }
}

- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView
{
  // An editing bar reports its submit through `onEditingSubmit` and keeps the keyboard up for the next name.
  if (searchBarView.isEditingBar) {
    return;
  }
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onSubmit(CylsearchBarViewEventEmitter::OnSubmit{.text = std::string((searchBarView.text ?: @"").UTF8String)});
  }
  [searchBarView hideKeyboard];
}

- (void)searchBarViewDidBeginEditing:(CYLSearchBarView *)searchBarView
{
  [self emitActive:YES];
}

- (void)searchBarViewDidEndEditing:(CYLSearchBarView *)searchBarView
{
  [self emitActive:NO];
}

/*!
 * `onActiveChange`: the field gained or lost the focus.
 */
- (void)emitActive:(BOOL)active
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)->onActiveChange(CylsearchBarViewEventEmitter::OnActiveChange{.active = (bool)active});
  }
}

- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)->onCancel(CylsearchBarViewEventEmitter::OnCancel{});
  }
}

@end
