#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchBarView;

@protocol CYLSearchBarViewDelegate <NSObject>
@optional
- (void)searchBarViewDidBeginEditing:(CYLSearchBarView *)searchBarView;
- (void)searchBarViewDidEndEditing:(CYLSearchBarView *)searchBarView;
- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text;
/// The keyboard's Search key.
- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView;
- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView;
@end

/// A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the
/// field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel
/// button. Use it as a navigation item's title view, a header, or anywhere in a layout.
///
///     CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
///     bar.placeholder = @"主播昵称/直播间ID/神曲名";
///     bar.showsCancelButton = YES;
///     bar.backgroundColor = UIColor.systemOrangeColor;
///     bar.fieldBackgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
@interface CYLSearchBarView : UIView

@property (nonatomic, weak, nullable) id<CYLSearchBarViewDelegate> delegate;
@property (nonatomic, strong, readonly) UITextField *textField;
/// The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
@property (nonatomic, strong, readonly) UIView *fieldView;
@property (nonatomic, strong, readonly) UIImageView *searchIconView;
@property (nonatomic, strong, readonly) UIButton *cancelButton;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *placeholder;
/// The text font, the body text style by default. A custom font is scaled with Dynamic Type (`UIFontMetrics`).
@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, strong, null_resettable) UIColor *textColor;
/// nil uses the placeholder gray.
@property (nonatomic, strong, nullable) UIColor *placeholderColor;

#pragma mark Field
/// Height of the field, 36 by default; it grows when the scaled text needs more room (large Dynamic Type sizes).
/// The bar is this tall plus `contentInsets`. VoiceOver reads the field as "Search" (`search.field`) unless
/// `textField.accessibilityLabel` is set.
@property (nonatomic, assign) CGFloat fieldHeight;
/// Space around the field (and the Cancel button), {6, 12, 6, 12} by default.
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong, null_resettable) UIColor *fieldBackgroundColor;
/// Negative (the default) makes a capsule.
@property (nonatomic, assign) CGFloat fieldCornerRadius;
@property (nonatomic, strong, nullable) UIColor *fieldBorderColor;
@property (nonatomic, assign) CGFloat fieldBorderWidth;
/// A soft shadow under the field; 0 (the default) for none.
@property (nonatomic, assign) CGFloat fieldShadowOpacity;
/// nil hides the magnifier; the SF Symbol "magnifyingglass" by default.
@property (nonatomic, strong, nullable) UIImage *searchIcon;
@property (nonatomic, strong, null_resettable) UIColor *searchIconTintColor;

#pragma mark Accessory views
/// Views inside the field after the text, in order, sized with -sizeThatFits: (or their intrinsic size).
@property (nonatomic, copy) NSArray<UIView *> *trailingAccessoryViews;
/// A view before the field, such as a back button.
@property (nonatomic, strong, nullable) UIView *leadingView;

#pragma mark Cancel button
/// NO by default.
@property (nonatomic, assign) BOOL showsCancelButton;
/// Localized "Cancel" by default.
@property (nonatomic, copy, null_resettable) NSString *cancelButtonTitle;
/// Taps on Cancel also end editing and clear nothing. YES by default.
@property (nonatomic, assign) BOOL cancelButtonEndsEditing;

@end

NS_ASSUME_NONNULL_END
