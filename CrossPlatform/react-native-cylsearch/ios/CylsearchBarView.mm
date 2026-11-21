#import "CylsearchBarView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchBarView () <CYLSearchBarViewDelegate>
@end

/*!
 * CYLSearchBarView filling the component; with `editingBar`, the core's editing bar
 * (CYLSearchBarView `editingBarWithPlaceholder:actionTitle:`), whose submit is sent as `onEditingSubmit`.
 */
@implementation CylsearchBarView {
  CYLSearchBarView *_bar;
  NSString *_itemsJSON;
  NSArray<NSString *> *_searches;
  BOOL _applyingSearches;
  NSString *_actionTitle;
  NSString *_textProp;
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

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchBarViewProps const>(props);
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
  _bar.fieldShadowOpacity = p.fieldShadowOpacity;
  _bar.searchBarStyle = [CYLRNString(p.searchBarStyle) isEqualToString:@"bordered"] ? CYLSearchBarStyleBordered : CYLSearchBarStylePlain;
  // An editing bar keeps the core's own setup: no magnifier, its action button always shown.
  if (!_bar.isEditingBar) {
    _bar.showsCancelButton = p.showsCancelButton;
    _bar.searchIcon = p.showsSearchIcon ? [UIImage systemImageNamed:@"magnifyingglass"] : nil;
  }
  // Rebuilt only when JavaScript sends other items, so a re-render keeps the native selection.
  NSString *itemsJSON = CYLRNString(p.itemsJSON) ?: @"";
  if (![itemsJSON isEqualToString:_itemsJSON ?: @""]) {
    _itemsJSON = itemsJSON;
    [_bar removeAllItems];
    NSData *data = [itemsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *values = data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    for (id value in [values isKindOfClass:[NSArray class]] ? values : @[]) {
      if ([value isKindOfClass:[NSDictionary class]]) {
        [_bar addItem:[CYLSearchBarItem itemWithDictionary:value]];
      }
    }
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
  [super updateProps:props oldProps:oldProps];
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

- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)->onCancel(CylsearchBarViewEventEmitter::OnCancel{});
  }
}

@end
