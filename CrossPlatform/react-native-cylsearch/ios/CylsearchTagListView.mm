#import "CylsearchTagListView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchTagListView () <CYLMenuDelegate>
@end

/*!
 * CollectionViewClassifyMenu's CYLTagListView filling the component; it reports the height its tags need at the
 * component's width (`onHeightChange`), again after folding and unfolding.
 */
@implementation CylsearchTagListView {
  CYLTagListView *_tagListView;
  CGFloat _reportedHeight;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchTagListViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchTagListViewProps>();
    _props = defaultProps;
    _reportedHeight = -1;
    _tagListView = [[CYLTagListView alloc] initWithFoldControl:CYLRNFoldControl(@"inline", @"icon")];
    _tagListView.showsSectionHeaders = NO;
    _tagListView.menuDelegate = self;
    // The React Native screen shows through, as around any other view.
    CYLMenuStyle *style = [_tagListView.style copy];
    style.backgroundColor = UIColor.clearColor;
    _tagListView.style = style;
    __weak __typeof(self) weakSelf = self;
    _tagListView.tagClickHandler = ^(NSInteger index, CYLTag *tag) {
      [weakSelf emitTagSelectAtIndex:index title:tag.title ?: @""];
    };
    self.contentView = _tagListView;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchTagListViewProps const>(props);
  _tagListView.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  _tagListView.foldControl = CYLRNFoldControl(CYLRNString(p.foldControlPosition), CYLRNString(p.foldControlContent));
  _tagListView.defaultVisibleRows = (NSUInteger)MAX(0, p.foldedRowCount);
  [_tagListView setTagsWithTitles:CYLRNStrings(p.tags)];
  [super updateProps:props oldProps:oldProps];
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self reportHeight];
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height
{
  [self reportHeight];
}

- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section
{
  [self reportHeight];
}

- (void)reportHeight
{
  CGFloat width = CGRectGetWidth(self.bounds);
  if (width <= 0 || !_eventEmitter) {
    return;
  }
  CGFloat height = ceil([_tagListView heightThatFitsWidth:width]);
  if (height != _reportedHeight) {
    _reportedHeight = height;
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onHeightChange(CylsearchTagListViewEventEmitter::OnHeightChange{.height = height});
  }
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  _reportedHeight = -1;
  [self reportHeight];
}

- (void)emitTagSelectAtIndex:(NSInteger)index title:(NSString *)title
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onTagSelect(CylsearchTagListViewEventEmitter::OnTagSelect{.index = (int)index, .title = std::string(title.UTF8String)});
  }
}

@end
