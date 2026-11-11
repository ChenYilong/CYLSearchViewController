#import "CYLSearchBarView.h"
#import "CYLSearchResources.h"

static CGFloat const CYLSearchBarIconSize = 18;
static CGFloat const CYLSearchBarSpacing = 8;
static CGFloat const CYLSearchBarMinimumTextShare = 0.4;
static CGFloat const CYLSearchBarMaximumCancelShare = 0.3;
static CGFloat const CYLSearchBarMinimumScale = 0.5;

@interface CYLSearchBarView () <UITextFieldDelegate>
@end

@implementation CYLSearchBarView

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize fieldBackgroundColor = _fieldBackgroundColor;
@synthesize searchIconTintColor = _searchIconTintColor;
@synthesize cancelButtonTitle = _cancelButtonTitle;

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
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(0, 4, 0, 4);
    _cancelButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    _cancelButton.hidden = YES;
    [_cancelButton addTarget:self action:@selector(cyl_cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.showsLargeContentViewer = YES;
    [self addSubview:_cancelButton];
    [self addInteraction:[[UILargeContentViewerInteraction alloc] init]];
    [self cyl_applyStyle];
}

#pragma mark Properties

- (NSString *)text { return self.textField.text; }
- (void)setText:(NSString *)text { self.textField.text = text; }

- (NSString *)placeholder { return self.textField.placeholder; }
- (void)setPlaceholder:(NSString *)placeholder {
    self.textField.placeholder = placeholder;
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
- (void)setSearchIcon:(UIImage *)searchIcon { _searchIcon = searchIcon; self.searchIconView.image = searchIcon; [self setNeedsLayout]; }

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
    [self setNeedsLayout];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    _showsCancelButton = showsCancelButton;
    self.cancelButton.hidden = !showsCancelButton;
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
    if (self.placeholderColor && self.textField.placeholder) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder
                                                                               attributes:@{NSForegroundColorAttributeName: self.placeholderColor,
                                                                                            NSFontAttributeName: self.font}];
    }
    self.fieldView.backgroundColor = self.fieldBackgroundColor;
    self.fieldView.layer.borderColor = [self.fieldBorderColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    self.fieldView.layer.borderWidth = self.fieldBorderColor ? self.fieldBorderWidth : 0;
    self.fieldView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.fieldView.layer.shadowOpacity = self.fieldShadowOpacity;
    self.fieldView.layer.shadowRadius = 6;
    self.fieldView.layer.shadowOffset = CGSizeMake(0, 2);
    self.searchIconView.tintColor = self.searchIconTintColor;
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
    if (self.leadingView) {
        CGSize size = CYLSearchBarFittingSize(self.leadingView, MAX(fieldHeight, 44));
        size.width = MAX(size.width, 44);
        self.leadingView.frame = CGRectMake(leading - 8, floor((height - size.height) / 2), size.width, size.height);
        leading += size.width - 8 + 2;
    }
    // At large text sizes the text keeps at least this share of the bar; Cancel and the accessory views shrink first.
    CGFloat available = MAX(0, trailing - leading);
    CGFloat minimumTextWidth = MAX(44, floor(available * CYLSearchBarMinimumTextShare));
    if (self.showsCancelButton) {
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
    self.fieldView.frame = field;
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
    NSArray<UIView *> *accessories = self.trailingAccessoryViews;
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
    CGFloat accessoryScale = accessoriesWidth > room && accessoriesWidth > 0 ? MAX(CYLSearchBarMinimumScale, room / accessoriesWidth) : 1;
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
}

#pragma mark Events

- (void)cyl_textChanged {
    if ([self.delegate respondsToSelector:@selector(searchBarView:textDidChange:)]) {
        [self.delegate searchBarView:self textDidChange:self.textField.text ?: @""];
    }
}

- (void)cyl_cancel {
    if (self.cancelButtonEndsEditing) {
        [self.textField resignFirstResponder];
    }
    if ([self.delegate respondsToSelector:@selector(searchBarViewCancelButtonClicked:)]) {
        [self.delegate searchBarViewCancelButtonClicked:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewSearchButtonClicked:)]) {
        [self.delegate searchBarViewSearchButtonClicked:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewDidBeginEditing:)]) {
        [self.delegate searchBarViewDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewDidEndEditing:)]) {
        [self.delegate searchBarViewDidEndEditing:self];
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

@end
