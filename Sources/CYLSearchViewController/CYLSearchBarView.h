#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchBarView;

/*!
 * The icon of the navigation button before the field (lapism `NavigationIconCompat`).
 */
typedef NS_ENUM(NSInteger, CYLSearchBarNavigationIcon) {
    /*!
     * No navigation button.
     */
    CYLSearchBarNavigationIconNone,
    /*!
     * A back arrow (`chevron.backward`).
     */
    CYLSearchBarNavigationIconArrow,
    /*!
     * A magnifier (`magnifyingglass`).
     */
    CYLSearchBarNavigationIconSearch,
};

/*!
 * How the field opens and closes when `iconified` changes with animation.
 */
typedef NS_ENUM(NSInteger, CYLSearchBarExpansionAnimation) {
    /*!
     * The field grows from the icon and fades in.
     */
    CYLSearchBarExpansionAnimationFade,
    /*!
     * A circle grows from the icon until it uncovers the whole field (Material circular reveal).
     */
    CYLSearchBarExpansionAnimationCircularReveal,
};

@protocol CYLSearchBarViewDelegate <NSObject>
@optional
/*!
 * Asks whether a tap may start editing. Return NO to use the bar as a button that opens another search page
 * (lapism `MaterialSearchBar.setOnClickListener`); `-searchBarViewDidTapWhileNotEditable:` is called instead.
 */
- (BOOL)searchBarViewShouldBeginEditing:(CYLSearchBarView *)searchBarView;
/*!
 * The bar was tapped while `-searchBarViewShouldBeginEditing:` refused editing.
 */
- (void)searchBarViewDidTapWhileNotEditable:(CYLSearchBarView *)searchBarView;
- (void)searchBarViewDidBeginEditing:(CYLSearchBarView *)searchBarView;
- (void)searchBarViewDidEndEditing:(CYLSearchBarView *)searchBarView;
- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text;
/*!
 * The keyboard's Search key.
 */
- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView;
- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView;
/*!
 * The navigation button before the field (`navigationIcon`, `navigationImage`).
 */
- (void)searchBarViewNavigationButtonClicked:(CYLSearchBarView *)searchBarView;
/*!
 * The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to
 * `-setText:submit:`.
 */
- (void)searchBarViewVoiceButtonClicked:(CYLSearchBarView *)searchBarView;
/*!
 * Asks whether the query may be submitted (the Search key, the submit button or `-setText:submit:` with YES).
 * Return NO to keep it. Without this method, every non-empty query is submitted.
 */
- (BOOL)searchBarView:(CYLSearchBarView *)searchBarView shouldSubmitText:(NSString *)text;
/*!
 * The field opened or closed (`iconified`).
 */
- (void)searchBarView:(CYLSearchBarView *)searchBarView didChangeIconified:(BOOL)iconified;
@end

/*!
 * A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the
 * field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel
 * button. Use it as a navigation item's title view, a header, or anywhere in a layout.
 *
 *     CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
 *     bar.placeholder = @"主播昵称/直播间ID/神曲名";
 *     bar.showsCancelButton = YES;
 *     bar.backgroundColor = UIColor.systemOrangeColor;
 *     bar.fieldBackgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
 */
@interface CYLSearchBarView : UIView

@property (nonatomic, weak, nullable) id<CYLSearchBarViewDelegate> delegate;
@property (nonatomic, strong, readonly) UITextField *textField;
/*!
 * The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
 */
@property (nonatomic, strong, readonly) UIView *fieldView;
@property (nonatomic, strong, readonly) UIImageView *searchIconView;
@property (nonatomic, strong, readonly) UIButton *cancelButton;
/*!
 * Draws the placeholder at the text's font size, cut off with an ellipsis when it does not fit (UITextField's own
 * placeholder shrinks at large Dynamic Type sizes). Hidden while there is text. Read-only styling hook; set the
 * text with `placeholder`.
 */
@property (nonatomic, strong, readonly) UILabel *placeholderLabel;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *placeholder;
/*!
 * The text font, the body text style by default. Pass a font from `UIFontMetrics` (or a text style) so that a
 * custom font follows Dynamic Type; it is not scaled again here.
 */
@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, strong, null_resettable) UIColor *textColor;
/*!
 * nil uses the placeholder gray.
 */
@property (nonatomic, strong, nullable) UIColor *placeholderColor;
/*!
 * The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default.
 */
@property (nonatomic, strong, null_resettable) UIColor *cursorColor;

#pragma mark Field
/*!
 * Height of the field, 36 by default; it grows when the scaled text needs more room (large Dynamic Type sizes).
 * The bar is this tall plus `contentInsets`. VoiceOver reads the field as "Search" (`search.field`) unless
 * `textField.accessibilityLabel` is set.
 */
@property (nonatomic, assign) CGFloat fieldHeight;
/*!
 * Space around the field (and the Cancel button), {6, 12, 6, 12} by default.
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong, null_resettable) UIColor *fieldBackgroundColor;
/*!
 * Negative (the default) makes a capsule.
 */
@property (nonatomic, assign) CGFloat fieldCornerRadius;
@property (nonatomic, strong, nullable) UIColor *fieldBorderColor;
@property (nonatomic, assign) CGFloat fieldBorderWidth;
/*!
 * A soft shadow under the field; 0 (the default) for none.
 */
@property (nonatomic, assign) CGFloat fieldShadowOpacity;
/*!
 * nil hides the magnifier; the SF Symbol "magnifyingglass" by default.
 */
@property (nonatomic, strong, nullable) UIImage *searchIcon;
@property (nonatomic, strong, null_resettable) UIColor *searchIconTintColor;

#pragma mark Accessory views
/*!
 * Views inside the field after the text, in order, sized with -sizeThatFits: (or their intrinsic size).
 */
@property (nonatomic, copy) NSArray<UIView *> *trailingAccessoryViews;
/*!
 * A view before the field, such as a back button.
 */
@property (nonatomic, strong, nullable) UIView *leadingView;

#pragma mark Cancel button
/*!
 * NO by default.
 */
@property (nonatomic, assign) BOOL showsCancelButton;
/*!
 * Localized "Cancel" by default.
 */
@property (nonatomic, copy, null_resettable) NSString *cancelButtonTitle;
/*!
 * Taps on Cancel also end editing and clear nothing. YES by default.
 */
@property (nonatomic, assign) BOOL cancelButtonEndsEditing;
/*!
 * Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default.
 */
@property (nonatomic, assign) BOOL clearsTextOnCancel;
/*!
 * Ending editing also clears the text (lapism `setTextClearOnClearFocus`). NO by default.
 */
@property (nonatomic, assign) BOOL clearsTextOnEndEditing;

#pragma mark Navigation button

/*!
 * The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and
 * `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`.
 */
@property (nonatomic, strong, readonly) UIButton *navigationButton;
/*!
 * A built-in navigation icon. `CYLSearchBarNavigationIconNone` by default.
 */
@property (nonatomic, assign) CYLSearchBarNavigationIcon navigationIcon;
/*!
 * A custom navigation icon; it wins over `navigationIcon`.
 */
@property (nonatomic, strong, nullable) UIImage *navigationImage;
/*!
 * What VoiceOver reads for the navigation button. Defaults to "Back" for the arrow and "Search" for the magnifier.
 */
@property (nonatomic, copy, null_resettable) NSString *navigationAccessibilityLabel;
/*!
 * A circle drawn behind the navigation icon. Nil (none) by default.
 */
@property (nonatomic, strong, nullable) UIColor *navigationBackgroundColor;
/*!
 * The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default.
 */
@property (nonatomic, assign) CGFloat navigationShadowOpacity;
/*!
 * Called on taps on the navigation button, after the delegate.
 */
@property (nonatomic, copy, nullable) void (^navigationHandler)(CYLSearchBarView *searchBarView);

#pragma mark Voice, submit and clear buttons

/*!
 * A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`.
 */
@property (nonatomic, strong, readonly) UIButton *voiceButton;
/*!
 * Shows `voiceButton` while the text is empty. NO by default.
 */
@property (nonatomic, assign) BOOL showsVoiceButton;
/*!
 * The voice button's icon. `mic` by default.
 */
@property (nonatomic, strong, null_resettable) UIImage *voiceImage;
/*!
 * A submit button inside the field, shown while there is text; it submits the query like the Search key.
 */
@property (nonatomic, strong, readonly) UIButton *submitButton;
/*!
 * Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). NO by default.
 */
@property (nonatomic, assign) BOOL showsSubmitButton;
/*!
 * The submit button's icon. `arrow.forward.circle.fill` by default.
 */
@property (nonatomic, strong, null_resettable) UIImage *submitImage;
/*!
 * A custom clear button icon, shown while editing with text. Nil keeps the system clear button.
 */
@property (nonatomic, strong, nullable) UIImage *clearImage;

#pragma mark Keyboard

/*!
 * The keyboard type (Android `inputType`). `UIKeyboardTypeDefault` by default.
 */
@property (nonatomic, assign) UIKeyboardType keyboardType;
/*!
 * The return key (Android `imeOptions`). `UIReturnKeySearch` by default.
 */
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
/*!
 * Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default.
 */
@property (nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;
/*!
 * Automatic correction. `UITextAutocorrectionTypeDefault` by default.
 */
@property (nonatomic, assign) UITextAutocorrectionType autocorrectionType;
/*!
 * The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default.
 */
@property (nonatomic, assign) NSUInteger maximumTextLength;

#pragma mark Iconified

/*!
 * Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens
 * the field and starts editing. NO by default.
 */
@property (nonatomic, assign, getter=isIconified) BOOL iconified;
/*!
 * When YES, the field closes back to its icon when editing ends with no text (Android
 * `setIconifiedByDefault`). NO by default.
 */
@property (nonatomic, assign) BOOL iconifiedByDefault;
/*!
 * The button shown while `iconified` is YES. VoiceOver reads it as "Search".
 */
@property (nonatomic, strong, readonly) UIButton *iconButton;
/*!
 * How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default.
 */
@property (nonatomic, assign) CYLSearchBarExpansionAnimation expansionAnimation;
/*!
 * The length of the opening and closing animations, in seconds. 0.3 by default.
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/*!
 * Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing.
 */
- (void)setIconified:(BOOL)iconified animated:(BOOL)animated;

#pragma mark Text and keyboard

/*!
 * Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped
 * (MaterialSearchView `setQuery`, lapism `setTextQuery`).
 */
- (void)setText:(nullable NSString *)text submit:(BOOL)submit;
/*!
 * Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls
 * `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it.
 */
- (BOOL)submit;
/*!
 * Starts editing and shows the keyboard.
 */
- (void)showKeyboard;
/*!
 * Ends editing and hides the keyboard.
 */
- (void)hideKeyboard;

@end

NS_ASSUME_NONNULL_END
