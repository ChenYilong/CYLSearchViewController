#import "CYLRNSearchSupport.h"

/*!
 * The square's view: its intrinsic size is the spec's, because the bar sizes the views it holds.
 */
@interface CYLRNSquareView : UIView
@property (nonatomic) CGFloat side;
@end

@implementation CYLRNSquareView
- (CGSize)intrinsicContentSize
{
  return CGSizeMake(self.side, self.side);
}
- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(self.side, self.side);
}
@end

UIView *_Nullable CYLRNSquare(NSDictionary *_Nullable spec)
{
  if (![spec isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  CGFloat side = [spec[@"size"] isKindOfClass:[NSNumber class]] ? [spec[@"size"] doubleValue] : 30;
  CYLRNSquareView *view = [[CYLRNSquareView alloc] initWithFrame:CGRectMake(0, 0, side, side)];
  view.side = side;
  view.layer.cornerRadius = 6;
  view.layer.borderWidth = 3;
  view.layer.borderColor = (CYLRNColor([spec[@"color"] isKindOfClass:[NSString class]] ? spec[@"color"] : @"") ?: [UIColor systemBlueColor]).CGColor;
  view.isAccessibilityElement = YES;
  view.accessibilityLabel = [spec[@"label"] isKindOfClass:[NSString class]] ? spec[@"label"] : nil;
  return view;
}

