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
 * CYLSearchBarView filling the component.
 */
@implementation CylsearchBarView {
  CYLSearchBarView *_bar;
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
  _bar.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  _bar.placeholder = CYLRNString(p.placeholder);
  NSString *text = CYLRNString(p.text);
  if (text.length > 0 && ![text isEqualToString:_bar.text ?: @""]) {
    _bar.text = text;
  }
  _bar.showsCancelButton = p.showsCancelButton;
  _bar.fieldShadowOpacity = p.fieldShadowOpacity;
  [super updateProps:props oldProps:oldProps];
}

#pragma mark - CYLSearchBarViewDelegate

- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchBarViewEventEmitter const>(_eventEmitter)
        ->onTextChange(CylsearchBarViewEventEmitter::OnTextChange{.text = std::string(text.UTF8String ?: "")});
  }
}

- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView
{
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
