#import "CYLMultiSearchView.h"
#import "CYLSearchResources.h"

static CGFloat const CYLMultiSearchItemPadding = 12;
static CGFloat const CYLMultiSearchRemoveSize = 28;
static CGFloat const CYLMultiSearchIndicatorHeight = 2;

/*!
 * One search: its text field, and a remove button shown while it is selected.
 */
@interface CYLMultiSearchItemView : UIView
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, assign) BOOL editing;
@end

@implementation CYLMultiSearchItemView
@end

@interface CYLMultiSearchView () <UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSMutableArray<CYLMultiSearchItemView *> *items;
@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;
@property (nonatomic, assign, readwrite, getter=isInSearchMode) BOOL inSearchMode;
@end

@implementation CYLMultiSearchView

@synthesize placeholder = _placeholder;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize placeholderColor = _placeholderColor;
@synthesize searchImage = _searchImage;
@synthesize removeImage = _removeImage;

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
    _items = [NSMutableArray array];
    _selectedIndex = NSNotFound;
    _minimumTextLength = 3;
    _returnKeyType = UIReturnKeySearch;
    _keyboardType = UIKeyboardTypeDefault;
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _unselectedItemAlpha = 0.5;
    _searchFieldWidth = 160;
    _animationDuration = 0.25;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    [self addSubview:_scrollView];

    _indicatorView = [[UIView alloc] init];
    _indicatorView.hidden = YES;
    _indicatorView.isAccessibilityElement = NO;
    [_scrollView addSubview:_indicatorView];

    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    _searchButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    _searchButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"multisearch.add"];
    _searchButton.showsLargeContentViewer = YES;
    [_searchButton addTarget:self action:@selector(cyl_searchTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_searchButton];
    [self addInteraction:[[UILargeContentViewerInteraction alloc] init]];
    [self cyl_applyStyle];
}

#pragma mark Properties

- (NSArray<NSString *> *)searchTexts {
    NSMutableArray<NSString *> *texts = [NSMutableArray arrayWithCapacity:self.items.count];
    for (CYLMultiSearchItemView *item in self.items) {
        [texts addObject:item.textField.text ?: @""];
    }
    return texts;
}

- (NSString *)placeholder { return _placeholder ?: [CYLSearchResources localizedStringForKey:@"search.field"]; }
- (void)setPlaceholder:(NSString *)placeholder { _placeholder = [placeholder copy]; [self cyl_applyStyle]; }
- (UIFont *)font { return _font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:self.traitCollection]; }
- (void)setFont:(UIFont *)font { _font = font; [self cyl_applyStyle]; [self invalidateIntrinsicContentSize]; }
- (UIColor *)textColor { return _textColor ?: UIColor.labelColor; }
- (void)setTextColor:(UIColor *)color { _textColor = color; [self cyl_applyStyle]; }
- (UIColor *)placeholderColor { return _placeholderColor ?: UIColor.placeholderTextColor; }
- (void)setPlaceholderColor:(UIColor *)color { _placeholderColor = color; [self cyl_applyStyle]; }
- (UIImage *)searchImage { return _searchImage ?: [UIImage systemImageNamed:@"magnifyingglass"]; }
- (void)setSearchImage:(UIImage *)image { _searchImage = image; [self cyl_applyStyle]; }
- (UIImage *)removeImage { return _removeImage ?: [UIImage systemImageNamed:@"xmark.circle.fill"]; }
- (void)setRemoveImage:(UIImage *)image { _removeImage = image; [self cyl_applyStyle]; }
- (void)setIndicatorColor:(UIColor *)color { _indicatorColor = color; [self cyl_applyStyle]; }
- (void)setUnselectedItemAlpha:(CGFloat)alpha { _unselectedItemAlpha = MIN(1, MAX(0, alpha)); [self cyl_applyStyle]; }
- (void)setSearchFieldWidth:(CGFloat)width { _searchFieldWidth = MAX(44, width); [self setNeedsLayout]; }
- (void)setReturnKeyType:(UIReturnKeyType)type { _returnKeyType = type; [self cyl_applyStyle]; }
- (void)setKeyboardType:(UIKeyboardType)type { _keyboardType = type; [self cyl_applyStyle]; }
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type { _autocapitalizationType = type; [self cyl_applyStyle]; }

- (void)cyl_applyStyle {
    UIColor *accent = self.indicatorColor ?: self.tintColor;
    self.indicatorView.backgroundColor = accent;
    UIButtonConfiguration *configuration = self.searchButton.configuration;
    configuration.image = self.searchImage;
    self.searchButton.configuration = configuration;
    self.searchButton.tintColor = accent;
    for (NSUInteger index = 0; index < self.items.count; index++) {
        [self cyl_styleItem:self.items[index] selected:index == self.selectedIndex];
    }
    [self setNeedsLayout];
}

- (void)cyl_styleItem:(CYLMultiSearchItemView *)item selected:(BOOL)selected {
    UITextField *field = item.textField;
    field.font = self.font;
    field.adjustsFontForContentSizeCategory = YES;
    field.textColor = self.textColor;
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                  attributes:@{NSForegroundColorAttributeName: self.placeholderColor, NSFontAttributeName: self.font}];
    field.returnKeyType = self.returnKeyType;
    field.keyboardType = self.keyboardType;
    field.autocapitalizationType = self.autocapitalizationType;
    field.alpha = selected || item.editing ? 1 : self.unselectedItemAlpha;
    [item.removeButton setImage:self.removeImage forState:UIControlStateNormal];
    item.removeButton.tintColor = UIColor.secondaryLabelColor;
    item.removeButton.hidden = !selected || item.editing;
    // VoiceOver: a completed search reads as a selectable button with its position.
    NSUInteger index = [self.items indexOfObject:item];
    if (!item.editing && index != NSNotFound) {
        field.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        field.accessibilityValue = [NSString localizedStringWithFormat:[CYLSearchResources localizedStringForKey:@"multisearch.item"], (unsigned long)index + 1, (unsigned long)self.items.count];
    } else {
        field.accessibilityTraits = UIAccessibilityTraitNone;
        field.accessibilityValue = nil;
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self cyl_applyStyle];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self cyl_applyStyle];
    [self invalidateIntrinsicContentSize];
}

#pragma mark Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(56, ceil(self.font.lineHeight) + 24 + CYLMultiSearchIndicatorHeight));
}

- (CGFloat)cyl_widthOfItem:(CYLMultiSearchItemView *)item selected:(BOOL)selected {
    if (item.editing) return self.searchFieldWidth;
    CGFloat textWidth = ceil([item.textField.text ?: @"" sizeWithAttributes:@{NSFontAttributeName: self.font}].width);
    return textWidth + CYLMultiSearchItemPadding * 2 + (selected ? CYLMultiSearchRemoveSize : 0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonSide = MIN(MAX(44, height), height);
    self.searchButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - buttonSide, 0, buttonSide, height);
    self.scrollView.frame = CGRectMake(0, 0, MAX(0, CGRectGetWidth(self.bounds) - buttonSide), height);
    CGFloat x = 0;
    CGFloat itemHeight = height - CYLMultiSearchIndicatorHeight;
    for (NSUInteger index = 0; index < self.items.count; index++) {
        CYLMultiSearchItemView *item = self.items[index];
        BOOL selected = index == self.selectedIndex;
        CGFloat width = [self cyl_widthOfItem:item selected:selected];
        item.frame = CGRectMake(x, 0, width, itemHeight);
        CGFloat removeWidth = item.removeButton.hidden ? 0 : CYLMultiSearchRemoveSize;
        item.textField.frame = CGRectMake(CYLMultiSearchItemPadding, 0, MAX(0, width - CYLMultiSearchItemPadding * 2 - removeWidth), itemHeight);
        item.removeButton.frame = CGRectMake(width - CYLMultiSearchItemPadding - CYLMultiSearchRemoveSize + 6, floor((itemHeight - 44) / 2), 44, 44);
        if (selected || item.editing) {
            self.indicatorView.frame = CGRectMake(x + CYLMultiSearchItemPadding, itemHeight, MAX(0, width - CYLMultiSearchItemPadding * 2), CYLMultiSearchIndicatorHeight);
        }
        x += width;
    }
    self.indicatorView.hidden = self.selectedIndex == NSNotFound && !self.inSearchMode;
    self.scrollView.contentSize = CGSizeMake(x, height);
}

- (void)cyl_scrollToItem:(CYLMultiSearchItemView *)item animated:(BOOL)animated {
    [self layoutIfNeeded];
    [self.scrollView scrollRectToVisible:item.frame animated:animated];
}

#pragma mark Actions

- (void)cyl_searchTapped {
    if (self.inSearchMode) {
        [self completeSearch];
    } else {
        [self search];
    }
}

- (CYLMultiSearchItemView *)cyl_newItem {
    CYLMultiSearchItemView *item = [[CYLMultiSearchItemView alloc] init];
    item.textField = [[UITextField alloc] init];
    item.textField.delegate = self;
    item.textField.accessibilityLabel = self.placeholder;
    [item.textField addTarget:self action:@selector(cyl_textChanged:) forControlEvents:UIControlEventEditingChanged];
    [item addSubview:item.textField];
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    item.removeButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    item.removeButton.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"multisearch.remove"];
    item.removeButton.showsLargeContentViewer = YES;
    [item.removeButton addTarget:self action:@selector(cyl_removeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [item addSubview:item.removeButton];
    [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_itemTapped:)]];
    return item;
}

- (void)search {
    if (self.inSearchMode) return;
    self.inSearchMode = YES;
    self.selectedIndex = NSNotFound;
    CYLMultiSearchItemView *item = [self cyl_newItem];
    item.editing = YES;
    [self.items addObject:item];
    [self.scrollView addSubview:item];
    [self cyl_applyStyle];
    item.alpha = 0;
    [self cyl_scrollToItem:item animated:YES];
    [UIView animateWithDuration:self.animationDuration animations:^{
        item.alpha = 1;
    } completion:^(BOOL finished) {
        [item.textField becomeFirstResponder];
    }];
    if (!self.window) [item.textField becomeFirstResponder];
}

- (void)completeSearch {
    if (!self.inSearchMode) return;
    self.inSearchMode = NO;
    CYLMultiSearchItemView *item = self.items.lastObject;
    item.editing = NO;
    [item.textField resignFirstResponder];
    NSString *text = item.textField.text ?: @"";
    if (text.length < self.minimumTextLength || text.length == 0) {
        [self cyl_removeItem:item notify:NO];
        return;
    }
    NSUInteger index = self.items.count - 1;
    self.selectedIndex = index;
    [self cyl_animateLayout];
    if ([self.delegate respondsToSelector:@selector(multiSearchView:didCompleteSearch:atIndex:)]) {
        [self.delegate multiSearchView:self didCompleteSearch:text atIndex:index];
    }
}

- (void)addSearchText:(NSString *)text {
    if (text.length == 0) return;
    if (self.inSearchMode) [self completeSearch];
    CYLMultiSearchItemView *item = [self cyl_newItem];
    item.textField.text = self.maximumTextLength > 0 && text.length > self.maximumTextLength ? [text substringToIndex:self.maximumTextLength] : text;
    [self.items addObject:item];
    [self.scrollView addSubview:item];
    self.selectedIndex = self.items.count - 1;
    [self cyl_applyStyle];
    [self cyl_scrollToItem:item animated:NO];
}

- (void)selectItemAtIndex:(NSUInteger)index {
    if (index >= self.items.count || self.items[index].editing) return;
    if (self.inSearchMode) [self completeSearch];
    if (index >= self.items.count) return;
    self.selectedIndex = index;
    [self cyl_animateLayout];
    [self cyl_scrollToItem:self.items[index] animated:YES];
    if ([self.delegate respondsToSelector:@selector(multiSearchView:didSelectItem:atIndex:)]) {
        [self.delegate multiSearchView:self didSelectItem:self.items[index].textField.text ?: @"" atIndex:index];
    }
}

- (void)removeItemAtIndex:(NSUInteger)index {
    if (index >= self.items.count) return;
    [self cyl_removeItem:self.items[index] notify:YES];
}

- (void)cyl_removeItem:(CYLMultiSearchItemView *)item notify:(BOOL)notify {
    NSUInteger index = [self.items indexOfObject:item];
    if (index == NSNotFound) return;
    if (item.editing) self.inSearchMode = NO;
    [item.textField resignFirstResponder];
    [item removeFromSuperview];
    [self.items removeObjectAtIndex:index];
    // As in MultiSearchView: the next item is selected, or the previous one when the last item went away.
    if (self.items.count == 0) {
        self.selectedIndex = NSNotFound;
    } else if (self.selectedIndex == index || self.selectedIndex == NSNotFound) {
        self.selectedIndex = MIN(index, self.items.count - 1);
    } else if (self.selectedIndex > index) {
        self.selectedIndex -= 1;
    }
    [self cyl_animateLayout];
    if (notify && [self.delegate respondsToSelector:@selector(multiSearchView:didRemoveItemAtIndex:)]) {
        [self.delegate multiSearchView:self didRemoveItemAtIndex:index];
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.selectedIndex == NSNotFound ? self.searchButton : self.items[self.selectedIndex].textField);
}

- (void)cyl_animateLayout {
    [self cyl_applyStyle];
    if (!self.window || self.animationDuration <= 0) {
        [self layoutIfNeeded];
        return;
    }
    [UIView animateWithDuration:self.animationDuration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)cyl_itemTapped:(UITapGestureRecognizer *)recognizer {
    NSUInteger index = [self.items indexOfObject:(CYLMultiSearchItemView *)recognizer.view];
    if (index != NSNotFound && index != self.selectedIndex) [self selectItemAtIndex:index];
}

- (void)cyl_removeTapped:(UIButton *)button {
    [self removeItemAtIndex:[self.items indexOfObject:(CYLMultiSearchItemView *)button.superview]];
}

- (void)cyl_textChanged:(UITextField *)field {
    NSUInteger index = [self.items indexOfObjectPassingTest:^BOOL(CYLMultiSearchItemView *item, NSUInteger idx, BOOL *stop) {
        return item.textField == field;
    }];
    if (index == NSNotFound) return;
    [self setNeedsLayout];
    if ([self.delegate respondsToSelector:@selector(multiSearchView:textDidChange:atIndex:)]) {
        [self.delegate multiSearchView:self textDidChange:field.text ?: @"" atIndex:index];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Only the search being typed is editable; a tap on a completed one selects it.
    CYLMultiSearchItemView *item = (CYLMultiSearchItemView *)textField.superview;
    if (!item.editing) {
        NSUInteger index = [self.items indexOfObject:item];
        if (index != NSNotFound && index != self.selectedIndex) [self selectItemAtIndex:index];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self completeSearch];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.maximumTextLength == 0 || string.length == 0) return YES;
    return textField.text.length - range.length + string.length <= self.maximumTextLength;
}

@end
