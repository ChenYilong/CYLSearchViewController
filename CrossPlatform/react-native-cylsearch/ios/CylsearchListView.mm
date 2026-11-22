#import "CylsearchListView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchListView () <RCTCylsearchListViewViewProtocol>
@end

/*!
 * The list with a search bar and its search (Android: `CYLSearchListView` and `CYLSearchView`).
 *
 * TODO (waiting for the iOS merge, docs/qmui-search-controller.md): the owner folds the QMUI members (launch view, dimming,
 * will / did present and dismiss, setActive, empty view, history change, swipe to dismiss, snapping, the centred
 * placeholder, margins and animated accessories) into the base classes `CYLSearchBarView` and `CYLSearchView`;
 * `CYLSearchBar` and `CYLSearchController` stay the UIKit adapter for `UISearchController` and `navigationItem` and are not
 * hosted in a React Native view. Until those members exist in the base, this view draws nothing and sends no event: the
 * props and events keep their names (src/CylsearchListViewNativeComponent.ts) so JavaScript does not change, and the
 * example's iOS screens compose the same behaviour from the bridged `CylsearchBarView` and `CylsearchTagListView`.
 */
@implementation CylsearchListView

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchListViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchListViewProps>();
    _props = defaultProps;
  }
  return self;
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTCylsearchListViewHandleCommand(self, commandName, args);
}

// TODO (waiting for the iOS merge): `CYLSearchView.setActive(_:animated:)`.
- (void)setActive:(BOOL)active animated:(BOOL)animated
{
}

// TODO (waiting for the iOS merge): the history store's `removeAllQueries`.
- (void)clearHistory
{
}

@end
