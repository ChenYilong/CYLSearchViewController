#import "CYLSearchBarView.h"
#import "CYLSearchResources.h"

static CGFloat const CYLSearchBarIconSize = 18;
static CGFloat const CYLSearchBarSpacing = 8;
static CGFloat const CYLSearchBarMinimumTextShare = 0.4;
static CGFloat const CYLSearchBarMaximumCancelShare = 0.3;
static CGFloat const CYLSearchBarMinimumScale = 0.5;
static CGFloat const CYLSearchBarMinimumAccessoryScale = 0.25;

@interface CYLSearchBarView () <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, assign) BOOL cyl_animatingExpansion;
@end

@implementation CYLSearchBarView

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize fieldBackgroundColor = _fieldBackgroundColor;
@synthesize searchIconTintColor = _searchIconTintColor;
@synthesize cancelButtonTitle = _cancelButtonTitle;
@synthesize navigationAccessibilityLabel = _navigationAccessibilityLabel;
@synthesize voiceImage = _voiceImage;
@synthesize submitImage = _submitImage;
@synthesize cursorColor = _cursorColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (void)cyl_commonInit {
    _fieldHeight = 36;
    _contentInsets = UIEdgeInsetsMake(6, 12, 6, 12);
    _fieldCornerRadius = -1;
    _cancelButtonEndsEditing = YES;
    _trailingAccessoryViews = @[];
    _searchIcon = [UIImage systemImageNamed:@"magnifyingglass"];

    _fieldView = [[UIView alloc] init];
    [self addSubview:_fieldView];
    _searchIconView = [[UIImageView alloc] initWithImage:_searchIcon];
    _searchIconView.contentMode = UIViewContentModeScaleAspectFit;
    _searchIconView.isAccessibilityElement = NO;
    [_fieldView addSubview:_searchIconView];
    _textField = [[UITextField alloc] init];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.adjustsFontForContentSizeCategory = YES;
    // The placeholder is not a label: it disappears once there is text.
    _textField.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.field"];
    [_textField addTarget:self action:@selector(cyl_textChanged) forControlEvents:UIControlEventEditingChanged];
    [_fieldView addSubview:_textField];
    // The placeholder is drawn by this label at the full font size and cut off with an ellipsis when it does not
    // fit: UITextField's own placeholder shrinks to a quarter of the size at large Dynamic Type sizes. The text
    // field keeps the placeholder (in a clear color) for VoiceOver.
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _placeholderLabel.isAccessibilityElement = NO;
    _placeholderLabel.userInteractionEnabled = NO;
    [_fieldView addSubview:_placeholderLabel];
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(0, 4, 0, 4);
    _cancelButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    _cancelButton.hidden = YES;
    [_cancelButton addTarget:self action:@selector(cyl_cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.showsLargeContentViewer = YES;
    [self addSubview:_cancelButton];

    _animationDuration = 0.3;
    _navigationButton = [self cyl_iconButtonWithAction:@selector(cyl_navigationTapped)];
    _navigationButton.hidden = YES;
    [self addSubview:_navigationButton];
    _voiceButton = [self cyl_iconButtonWithAction:@selector(cyl_voiceTapped)];
    _voiceButton.hidden = YES;
    _voiceButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.voice"];
    [_fieldView addSubview:_voiceButton];
    _submitButton = [self cyl_iconButtonWithAction:@selector(cyl_submitTapped)];
    _submitButton.hidden = YES;
    _submitButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.submit"];
    [_fieldView addSubview:_submitButton];
    _clearButton = [self cyl_iconButtonWithAction:@selector(cyl_clearTapped)];
    _clearButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.clear"];
    _clearButton.frame = CGRectMake(0, 0, 30, 30);
    _iconButton = [self cyl_iconButtonWithAction:@selector(cyl_iconTapped)];
    _iconButton.hidden = YES;
    _iconButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.field"];
    [_iconButton setImage:_searchIcon forState:UIControlStateNormal];
    [self addSubview:_iconButton];
    [self addInteraction:[[UILargeContentViewerInteraction alloc] init]];
    [self cyl_updateButtonImages];
    [self cyl_applyStyle];
}

- (UIButton *)cyl_iconButtonWithAction:(SEL)action {
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(4, 4, 4, 4);
    UIButton *button = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.showsLargeContentViewer = YES;
    button.pointerInteractionEnabled = YES;
    return button;
}

#pragma mark Properties

- (NSString *)text { return self.textField.text; }
- (void)setText:(NSString *)text {
    self.textField.text = text;
    [self cyl_textStateChanged];
}

- (void)setText:(NSString *)text submit:(BOOL)submit {
    self.text = text;
    if (submit) {
        [self submit];
    }
}

- (BOOL)submit {
    NSString *text = self.textField.text ?: @"";
    if ([text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(searchBarView:shouldSubmitText:)]
        && ![self.delegate searchBarView:self shouldSubmitText:text]) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(searchBarViewSearchButtonClicked:)]) {
        [self.delegate searchBarViewSearchButtonClicked:self];
    }
    return YES;
}

- (UIColor *)cursorColor { return _cursorColor ?: self.tintColor; }
- (void)setCursorColor:(UIColor *)color { _cursorColor = color; self.textField.tintColor = color; }

- (void)showKeyboard { [self.textField becomeFirstResponder]; }
- (void)hideKeyboard { [self.textField resignFirstResponder]; }

- (UIKeyboardType)keyboardType { return self.textField.keyboardType; }
- (void)setKeyboardType:(UIKeyboardType)type { self.textField.keyboardType = type; [self.textField reloadInputViews]; }
- (UIReturnKeyType)returnKeyType { return self.textField.returnKeyType; }
- (void)setReturnKeyType:(UIReturnKeyType)type { self.textField.returnKeyType = type; [self.textField reloadInputViews]; }
- (UITextAutocapitalizationType)autocapitalizationType { return self.textField.autocapitalizationType; }
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type { self.textField.autocapitalizationType = type; }
- (BOOL)isSecureTextEntry { return self.textField.isSecureTextEntry; }
- (void)setSecureTextEntry:(BOOL)secure { self.textField.secureTextEntry = secure; }
- (UITextAutocorrectionType)autocorrectionType { return self.textField.autocorrectionType; }
- (void)setAutocorrectionType:(UITextAutocorrectionType)type { self.textField.autocorrectionType = type; }

- (void)setMaximumTextLength:(NSUInteger)length {
    _maximumTextLength = length;
    if (length > 0 && self.textField.text.length > length) {
        self.text = [self.textField.text substringToIndex:length];
    }
}

- (void)setNavigationIcon:(CYLSearchBarNavigationIcon)icon { _navigationIcon = icon; [self cyl_updateButtonImages]; }
- (void)setNavigationImage:(UIImage *)image { _navigationImage = image; [self cyl_updateButtonImages]; }
- (NSString *)navigationAccessibilityLabel {
    if (_navigationAccessibilityLabel) return _navigationAccessibilityLabel;
    return [CYLSearchResources localizedStringForKey:self.navigationIcon == CYLSearchBarNavigationIconSearch ? @"search.field" : @"search.back"];
}
- (void)setNavigationAccessibilityLabel:(NSString *)label { _navigationAccessibilityLabel = [label copy]; [self cyl_updateButtonImages]; }
- (void)setNavigationBackgroundColor:(UIColor *)color { _navigationBackgroundColor = color; [self cyl_updateButtonImages]; }
- (void)setNavigationShadowOpacity:(CGFloat)opacity { _navigationShadowOpacity = MIN(1, MAX(0, opacity)); [self cyl_updateButtonImages]; }
- (void)setShowsVoiceButton:(BOOL)shows { _showsVoiceButton = shows; [self setNeedsLayout]; }
- (void)setShowsSubmitButton:(BOOL)shows { _showsSubmitButton = shows; [self setNeedsLayout]; }
- (UIImage *)voiceImage { return _voiceImage ?: [UIImage systemImageNamed:@"mic"]; }
- (void)setVoiceImage:(UIImage *)image { _voiceImage = image; [self cyl_updateButtonImages]; }
- (UIImage *)submitImage { return _submitImage ?: [UIImage systemImageNamed:@"arrow.forward.circle.fill"]; }
- (void)setSubmitImage:(UIImage *)image { _submitImage = image; [self cyl_updateButtonImages]; }

- (void)setClearImage:(UIImage *)image {
    _clearImage = image;
    if (image) {
        self.textField.clearButtonMode = UITextFieldViewModeNever;
        self.textField.rightView = self.clearButton;
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
    } else {
        self.textField.rightView = nil;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    [self cyl_updateButtonImages];
    [self cyl_textStateChanged];
}

- (BOOL)cyl_showsNavigationButton {
    return !self.leadingView && (self.navigationImage || self.navigationIcon != CYLSearchBarNavigationIconNone);
}

- (UIView *)cyl_effectiveLeadingView {
    return self.leadingView ?: (self.cyl_showsNavigationButton ? self.navigationButton : nil);
}

- (NSArray<UIView *> *)cyl_effectiveAccessoryViews {
    NSMutableArray<UIView *> *views = [self.trailingAccessoryViews mutableCopy];
    BOOL hasText = self.textField.text.length > 0;
    if (self.showsVoiceButton && !hasText) [views addObject:self.voiceButton];
    if (self.showsSubmitButton && hasText) [views addObject:self.submitButton];
    return views;
}

- (void)cyl_updateButtonImages {
    UIImage *navigation = self.navigationImage;
    if (!navigation && self.navigationIcon == CYLSearchBarNavigationIconArrow) navigation = [UIImage systemImageNamed:@"chevron.backward"];
    if (!navigation && self.navigationIcon == CYLSearchBarNavigationIconSearch) navigation = [UIImage systemImageNamed:@"magnifyingglass"];
    UIButtonConfiguration *configuration = self.navigationButton.configuration;
    configuration.image = navigation;
    configuration.background.backgroundColor = self.navigationBackgroundColor ?: UIColor.clearColor;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    self.navigationButton.configuration = configuration;
    self.navigationButton.layer.shadowOpacity = self.navigationShadowOpacity;
    self.navigationButton.layer.shadowRadius = 3;
    self.navigationButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.navigationButton.accessibilityLabel = self.navigationAccessibilityLabel;
    self.navigationButton.largeContentTitle = self.navigationAccessibilityLabel;
    [self.voiceButton setImage:self.voiceImage forState:UIControlStateNormal];
    [self.submitButton setImage:self.submitImage forState:UIControlStateNormal];
    [self.clearButton setImage:self.clearImage forState:UIControlStateNormal];
    [self.iconButton setImage:self.searchIcon forState:UIControlStateNormal];
    [self setNeedsLayout];
}

#pragma mark Iconified

- (void)setIconPosition:(CYLSearchBarIconPosition)position {
    _iconPosition = position;
    [self setNeedsLayout];
}

- (void)setIconified:(BOOL)iconified {
    [self setIconified:iconified animated:NO];
}

- (void)setIconifiedByDefault:(BOOL)iconifiedByDefault {
    _iconifiedByDefault = iconifiedByDefault;
    if (iconifiedByDefault && !self.textField.isFirstResponder && self.textField.text.length == 0) {
        [self setIconified:YES animated:NO];
    }
}

- (void)setIconified:(BOOL)iconified animated:(BOOL)animated {
    if (_iconified == iconified) {
        if (!iconified && animated) [self.textField becomeFirstResponder];
        return;
    }
    _iconified = iconified;
    if (iconified) [self.textField resignFirstResponder];
    if (!animated || self.animationDuration <= 0 || !self.window) {
        [self cyl_applyIconifiedVisibility];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        if (!iconified && animated) [self.textField becomeFirstResponder];
        [self cyl_notifyIconified];
        return;
    }
    [self layoutIfNeeded];
    CGRect iconFrame = self.iconButton.frame;
    self.cyl_animatingExpansion = YES;
    self.fieldView.hidden = NO;
    self.iconButton.hidden = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGRect fieldFrame = self.fieldView.frame;
    CGPoint center = [self convertPoint:CGPointMake(CGRectGetMidX(iconFrame), CGRectGetMidY(iconFrame)) toView:self.fieldView];
    CGFloat radius = hypot(MAX(center.x, CGRectGetWidth(fieldFrame) - center.x), MAX(center.y, CGRectGetHeight(fieldFrame) - center.y));
    CGFloat iconRadius = MAX(CGRectGetWidth(iconFrame), CGRectGetHeight(iconFrame)) / 2;
    if (self.expansionAnimation == CYLSearchBarExpansionAnimationCircularReveal) {
        CAShapeLayer *mask = [CAShapeLayer layer];
        UIBezierPath *small = [UIBezierPath bezierPathWithArcCenter:center radius:iconRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        UIBezierPath *large = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        mask.path = (iconified ? small : large).CGPath;
        self.fieldView.layer.mask = mask;
        CABasicAnimation *reveal = [CABasicAnimation animationWithKeyPath:@"path"];
        reveal.fromValue = (__bridge id)(iconified ? large : small).CGPath;
        reveal.toValue = (__bridge id)(iconified ? small : large).CGPath;
        reveal.duration = self.animationDuration;
        reveal.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [mask addAnimation:reveal forKey:@"reveal"];
    } else {
        self.fieldView.frame = iconified ? fieldFrame : iconFrame;
        self.fieldView.alpha = iconified ? 1 : 0;
    }
    self.iconButton.alpha = iconified ? 0 : 1;
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.expansionAnimation == CYLSearchBarExpansionAnimationFade) {
            self.fieldView.frame = iconified ? iconFrame : fieldFrame;
            self.fieldView.alpha = iconified ? 0 : 1;
        }
        self.iconButton.alpha = iconified ? 1 : 0;
    } completion:^(BOOL finished) {
        self.cyl_animatingExpansion = NO;
        self.fieldView.layer.mask = nil;
        self.fieldView.alpha = 1;
        self.iconButton.alpha = 1;
        [self cyl_applyIconifiedVisibility];
        [self setNeedsLayout];
        if (!iconified) [self.textField becomeFirstResponder];
        [self cyl_notifyIconified];
    }];
}

- (void)cyl_applyIconifiedVisibility {
    self.fieldView.hidden = self.iconified;
    self.iconButton.hidden = !self.iconified;
    self.cancelButton.hidden = self.iconified || !self.showsCancelButton;
    UIView *leading = [self cyl_effectiveLeadingView];
    leading.hidden = self.iconified;
    self.navigationButton.hidden = self.iconified || !self.cyl_showsNavigationButton;
}

- (void)cyl_notifyIconified {
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.iconified ? self.iconButton : self.textField);
    if ([self.delegate respondsToSelector:@selector(searchBarView:didChangeIconified:)]) {
        [self.delegate searchBarView:self didChangeIconified:self.iconified];
    }
}

#pragma mark State restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.textField.text ?: @"" forKey:@"CYLSearchBarText"];
    [coder encodeBool:self.textField.isFirstResponder forKey:@"CYLSearchBarEditing"];
    [coder encodeBool:self.iconified forKey:@"CYLSearchBarIconified"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    NSString *text = [coder decodeObjectOfClass:NSString.class forKey:@"CYLSearchBarText"];
    if (text) self.text = text;
    if ([coder containsValueForKey:@"CYLSearchBarIconified"]) [self setIconified:[coder decodeBoolForKey:@"CYLSearchBarIconified"] animated:NO];
    if ([coder decodeBoolForKey:@"CYLSearchBarEditing"]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self.textField becomeFirstResponder]; });
    }
}


- (NSString *)placeholder { return self.textField.placeholder; }
- (void)setPlaceholder:(NSString *)placeholder {
    self.textField.placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self cyl_applyStyle];
}

- (UIFont *)font {
    // A custom font is used as given: UIKit refuses to scale a font from UIFontMetrics twice.
    return _font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:self.traitCollection];
}

/// `fieldHeight`, or taller when the scaled text needs it.
- (CGFloat)cyl_effectiveFieldHeight {
    return MAX(self.fieldHeight, ceil(self.font.lineHeight + 12));
}
- (void)setFont:(UIFont *)font { _font = font; [self cyl_applyStyle]; }
- (UIColor *)textColor { return _textColor ?: [UIColor labelColor]; }
- (void)setTextColor:(UIColor *)textColor { _textColor = textColor; [self cyl_applyStyle]; }
- (void)setPlaceholderColor:(UIColor *)placeholderColor { _placeholderColor = placeholderColor; [self cyl_applyStyle]; }
- (UIColor *)fieldBackgroundColor { return _fieldBackgroundColor ?: [UIColor tertiarySystemFillColor]; }
- (void)setFieldBackgroundColor:(UIColor *)color { _fieldBackgroundColor = color; [self cyl_applyStyle]; }
- (UIColor *)searchIconTintColor { return _searchIconTintColor ?: [UIColor secondaryLabelColor]; }
- (void)setSearchIconTintColor:(UIColor *)color { _searchIconTintColor = color; [self cyl_applyStyle]; }
- (void)setFieldBorderColor:(UIColor *)color { _fieldBorderColor = color; [self cyl_applyStyle]; }
- (void)setFieldBorderWidth:(CGFloat)width { _fieldBorderWidth = MAX(0, width); [self cyl_applyStyle]; }
- (void)setFieldShadowOpacity:(CGFloat)opacity { _fieldShadowOpacity = MIN(1, MAX(0, opacity)); [self cyl_applyStyle]; }
- (void)setFieldCornerRadius:(CGFloat)radius { _fieldCornerRadius = radius; [self setNeedsLayout]; }
- (void)setSearchIcon:(UIImage *)searchIcon { _searchIcon = searchIcon; self.searchIconView.image = searchIcon; [self cyl_updateButtonImages]; }

- (void)setFieldHeight:(CGFloat)fieldHeight {
    _fieldHeight = MAX(0, fieldHeight);
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setTrailingAccessoryViews:(NSArray<UIView *> *)views {
    for (UIView *view in _trailingAccessoryViews) {
        [view removeFromSuperview];
    }
    _trailingAccessoryViews = [views copy] ?: @[];
    for (UIView *view in _trailingAccessoryViews) {
        [self.fieldView addSubview:view];
    }
    [self setNeedsLayout];
}

- (void)setLeadingView:(UIView *)leadingView {
    [_leadingView removeFromSuperview];
    _leadingView = leadingView;
    if (leadingView) {
        [self addSubview:leadingView];
    }
    [self cyl_applyIconifiedVisibility];
    [self setNeedsLayout];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    _showsCancelButton = showsCancelButton;
    self.cancelButton.hidden = !showsCancelButton || self.iconified;
    [self setNeedsLayout];
}

- (NSString *)cancelButtonTitle {
    return _cancelButtonTitle ?: [CYLSearchResources localizedStringForKey:@"search.cancel"];
}

- (void)setCancelButtonTitle:(NSString *)title {
    _cancelButtonTitle = [title copy];
    [self cyl_applyStyle];
}

- (void)cyl_applyStyle {
    self.textField.font = self.font;
    self.textField.textColor = self.textColor;
    NSString *placeholder = self.placeholderLabel.text;
    if (placeholder.length > 0) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                               attributes:@{NSForegroundColorAttributeName: UIColor.clearColor,
                                                                                            NSFontAttributeName: self.font}];
    }
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.textColor = self.placeholderColor ?: UIColor.placeholderTextColor;
    [self cyl_updatePlaceholderVisibility];
    self.fieldView.backgroundColor = self.fieldBackgroundColor;
    self.fieldView.layer.borderColor = [self.fieldBorderColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    self.fieldView.layer.borderWidth = self.fieldBorderColor ? self.fieldBorderWidth : 0;
    self.fieldView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.fieldView.layer.shadowOpacity = self.fieldShadowOpacity;
    self.fieldView.layer.shadowRadius = 6;
    self.fieldView.layer.shadowOffset = CGSizeMake(0, 2);
    self.searchIconView.tintColor = self.searchIconTintColor;
    self.iconButton.tintColor = self.searchIconTintColor;
    self.voiceButton.tintColor = self.searchIconTintColor;
    self.clearButton.tintColor = self.searchIconTintColor;
    // A configuration updates the title at once (a legacy button could keep drawing the previous one).
    UIButtonConfiguration *configuration = self.cancelButton.configuration ?: [UIButtonConfiguration plainButtonConfiguration];
    configuration.attributedTitle = [[NSAttributedString alloc] initWithString:self.cancelButtonTitle attributes:@{NSFontAttributeName: self.font}];
    configuration.titleLineBreakMode = NSLineBreakByClipping;
    self.cancelButton.configuration = configuration;
    // The title may be drawn smaller to fit; VoiceOver and the large content viewer still get the whole title.
    self.cancelButton.accessibilityLabel = self.cancelButtonTitle;
    self.cancelButton.largeContentTitle = self.cancelButtonTitle;
    [self setNeedsLayout];
}

- (void)cyl_setCancelTitleFont:(UIFont *)font {
    UIButtonConfiguration *configuration = self.cancelButton.configuration;
    UIFont *current = [configuration.attributedTitle attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    if (!configuration || configuration.attributedTitle.length == 0 || [current isEqual:font]) {
        return;
    }
    configuration.attributedTitle = [[NSAttributedString alloc] initWithString:self.cancelButtonTitle attributes:@{NSFontAttributeName: font}];
    self.cancelButton.configuration = configuration;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self cyl_applyStyle];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self invalidateIntrinsicContentSize];
    }
}

#pragma mark Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, [self cyl_effectiveFieldHeight] + self.contentInsets.top + self.contentInsets.bottom);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.intrinsicContentSize.height);
}

static CGSize CYLSearchBarFittingSize(UIView *view, CGFloat height) {
    CGSize size = [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)];
    if (size.width <= 0 || size.height <= 0) {
        size = view.intrinsicContentSize;
    }
    return CGSizeMake(MAX(0, size.width), MIN(height, MAX(0, size.height)));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets insets = self.contentInsets;
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat fieldHeight = MIN([self cyl_effectiveFieldHeight], MAX(0, height - insets.top - insets.bottom));
    CGFloat y = floor((height - fieldHeight) / 2);
    CGFloat leading = insets.left;
    CGFloat trailing = CGRectGetWidth(self.bounds) - insets.right;
    self.navigationButton.hidden = self.iconified || !self.cyl_showsNavigationButton;
    UIView *leadingView = [self cyl_effectiveLeadingView];
    if (leadingView) {
        CGSize size = CYLSearchBarFittingSize(leadingView, MAX(fieldHeight, 44));
        size.width = MAX(size.width, 44);
        size.height = MAX(size.height, MIN(44, height));
        leadingView.frame = CGRectMake(leading - 8, floor((height - size.height) / 2), size.width, size.height);
        leading += size.width - 8 + 2;
    }
    // Iconified: only the search button, at the trailing end.
    CGFloat iconSide = MIN(MAX(44, fieldHeight), height);
    CGFloat iconX = CGRectGetWidth(self.bounds) - insets.right - iconSide;
    if (self.iconPosition == CYLSearchBarIconPositionCenter) iconX = floor((CGRectGetWidth(self.bounds) - iconSide) / 2);
    if (self.iconPosition == CYLSearchBarIconPositionLeading) iconX = insets.left;
    self.iconButton.frame = CGRectMake(iconX, floor((height - iconSide) / 2), iconSide, iconSide);
    // At large text sizes the text keeps at least this share of the bar; Cancel and the accessory views shrink first.
    CGFloat available = MAX(0, trailing - leading);
    CGFloat minimumTextWidth = MAX(44, floor(available * CYLSearchBarMinimumTextShare));
    if (self.showsCancelButton && !self.iconified) {
        // The title's own width: a button's fitting size can lag behind a title or font set in the same pass.
        CGFloat titleWidth = ceil([self.cancelButtonTitle sizeWithAttributes:@{NSFontAttributeName: self.font}].width);
        CGFloat maximumWidth = MAX(44, floor(available * CYLSearchBarMaximumCancelShare));
        CGFloat width = MIN(MAX(44, titleWidth + 12), maximumWidth);
        CGFloat scale = titleWidth + 12 > width ? MAX(CYLSearchBarMinimumScale, (width - 12) / MAX(1, titleWidth)) : 1;
        [self cyl_setCancelTitleFont:[self.font fontWithSize:self.font.pointSize * scale]];
        self.cancelButton.frame = CGRectMake(trailing - width, y, width, fieldHeight);
        trailing -= width + CYLSearchBarSpacing;
    }
    CGRect field = CGRectMake(leading, y, MAX(0, trailing - leading), fieldHeight);
    if (!self.cyl_animatingExpansion || !self.fieldView.hidden) {
        self.fieldView.frame = field;
    }
    field = self.fieldView.frame;
    field.size = CGSizeMake(MAX(0, trailing - leading), fieldHeight);
    self.fieldView.layer.cornerRadius = self.fieldCornerRadius < 0 ? fieldHeight / 2 : self.fieldCornerRadius;

    CGFloat inner = MAX(10, MIN(14, fieldHeight / 3));
    CGFloat x = inner;
    if (self.searchIcon) {
        self.searchIconView.frame = CGRectMake(x, floor((fieldHeight - CYLSearchBarIconSize) / 2), CYLSearchBarIconSize, CYLSearchBarIconSize);
        x += CYLSearchBarIconSize + 6;
    } else {
        self.searchIconView.frame = CGRectZero;
    }
    CGFloat end = CGRectGetWidth(field) - inner;
    NSArray<UIView *> *accessories = [self cyl_effectiveAccessoryViews];
    self.voiceButton.hidden = ![accessories containsObject:self.voiceButton];
    self.submitButton.hidden = ![accessories containsObject:self.submitButton];
    NSMutableArray<NSValue *> *sizes = [NSMutableArray arrayWithCapacity:accessories.count];
    CGFloat accessoriesWidth = 0;
    for (UIView *view in accessories) {
        view.transform = CGAffineTransformIdentity;
        CGSize size = CYLSearchBarFittingSize(view, fieldHeight);
        [sizes addObject:[NSValue valueWithCGSize:size]];
        accessoriesWidth += size.width + CYLSearchBarSpacing;
    }
    // Views that would squeeze the text are drawn smaller (scaled as a whole, so a symbol keeps its shape).
    CGFloat room = MAX(0, end - x - minimumTextWidth);
    CGFloat accessoryScale = accessoriesWidth > room && accessoriesWidth > 0 ? MAX(CYLSearchBarMinimumAccessoryScale, room / accessoriesWidth) : 1;
    for (NSInteger index = (NSInteger)accessories.count - 1; index >= 0; index--) {
        UIView *view = accessories[index];
        CGSize size = sizes[index].CGSizeValue;
        CGFloat width = size.width * accessoryScale;
        view.bounds = CGRectMake(0, 0, size.width, size.height);
        view.center = CGPointMake(end - width / 2, fieldHeight / 2);
        view.transform = accessoryScale < 1 ? CGAffineTransformMakeScale(accessoryScale, accessoryScale) : CGAffineTransformIdentity;
        end -= width + CYLSearchBarSpacing * accessoryScale;
    }
    self.textField.frame = CGRectMake(x, 0, MAX(0, end - x), fieldHeight);
    CGRect textRect = [self.textField textRectForBounds:self.textField.bounds];
    self.placeholderLabel.frame = CGRectOffset(textRect, CGRectGetMinX(self.textField.frame), CGRectGetMinY(self.textField.frame));
}

#pragma mark Events

- (void)cyl_updatePlaceholderVisibility {
    self.placeholderLabel.hidden = self.textField.text.length > 0;
}

- (void)cyl_textStateChanged {
    [self cyl_updatePlaceholderVisibility];
    self.clearButton.hidden = self.textField.text.length == 0;
    [self setNeedsLayout];
}

- (void)cyl_textChanged {
    [self cyl_textStateChanged];
    if ([self.delegate respondsToSelector:@selector(searchBarView:textDidChange:)]) {
        [self.delegate searchBarView:self textDidChange:self.textField.text ?: @""];
    }
}

- (void)cyl_cancel {
    if (self.clearsTextOnCancel && self.textField.text.length > 0) {
        self.textField.text = @"";
        [self cyl_textChanged];
    }
    if (self.cancelButtonEndsEditing) {
        [self.textField resignFirstResponder];
    }
    if ([self.delegate respondsToSelector:@selector(searchBarViewCancelButtonClicked:)]) {
        [self.delegate searchBarViewCancelButtonClicked:self];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewShouldBeginEditing:)]
        && ![self.delegate searchBarViewShouldBeginEditing:self]) {
        if ([self.delegate respondsToSelector:@selector(searchBarViewDidTapWhileNotEditable:)]) {
            [self.delegate searchBarViewDidTapWhileNotEditable:self];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submit];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.maximumTextLength == 0) return YES;
    NSUInteger length = textField.text.length - range.length + string.length;
    return length <= self.maximumTextLength || string.length == 0;
}

- (void)cyl_navigationTapped {
    if ([self.delegate respondsToSelector:@selector(searchBarViewNavigationButtonClicked:)]) {
        [self.delegate searchBarViewNavigationButtonClicked:self];
    }
    if (self.navigationHandler) self.navigationHandler(self);
}

- (void)cyl_voiceTapped {
    if ([self.delegate respondsToSelector:@selector(searchBarViewVoiceButtonClicked:)]) {
        [self.delegate searchBarViewVoiceButtonClicked:self];
    }
}

- (void)cyl_submitTapped {
    [self submit];
}

- (void)cyl_clearTapped {
    self.textField.text = @"";
    [self cyl_textChanged];
}

- (void)cyl_iconTapped {
    [self setIconified:NO animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewDidBeginEditing:)]) {
        [self.delegate searchBarViewDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.clearsTextOnEndEditing && textField.text.length > 0) {
        textField.text = @"";
        [self cyl_textChanged];
    }
    if (self.iconifiedByDefault && textField.text.length == 0 && !self.iconified) {
        [self setIconified:YES animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(searchBarViewDidEndEditing:)]) {
        [self.delegate searchBarViewDidEndEditing:self];
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    // The text field holds the keyboard; the bar itself also gives up first responder as UIKit expects.
    BOOL resigned = [self.textField resignFirstResponder];
    return [super resignFirstResponder] && resigned;
}

@end
