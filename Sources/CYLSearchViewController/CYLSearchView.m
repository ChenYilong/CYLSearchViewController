#import "CYLSearchView.h"
#import "CYLSearchResources.h"

static NSString *const CYLSearchSuggestionCellIdentifier = @"CYLSearchSuggestionCell";

@interface CYLSearchView () <CYLSearchBarViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *pageView;
@property (nonatomic, strong) UIControl *scrimView;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *filteredSuggestions;
@property (nonatomic, assign, readwrite, getter=isSearchOpen) BOOL searchOpen;
@property (nonatomic, assign) BOOL suggestionsVisible;
@property (nonatomic, assign) CGFloat keyboardOverlap;
@end

@implementation CYLSearchView

@synthesize dividerColor = _dividerColor;
@synthesize suggestionTextColor = _suggestionTextColor;
@synthesize suggestionImageTintColor = _suggestionImageTintColor;

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
    _suggestions = @[];
    _filteredSuggestions = @[];
    _animationDuration = 0.25;
    _closesOnSubmit = YES;
    _suggestionLineBreakMode = NSLineBreakByWordWrapping;
    _suggestionImage = [UIImage systemImageNamed:@"magnifyingglass"];
    self.hidden = YES;
    self.backgroundColor = UIColor.clearColor;

    _scrimView = [[UIControl alloc] init];
    _scrimView.isAccessibilityElement = NO;
    [_scrimView addTarget:self action:@selector(closeSearch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_scrimView];

    _pageView = [[UIView alloc] init];
    _pageView.backgroundColor = UIColor.systemBackgroundColor;
    _pageView.clipsToBounds = YES;
    [self addSubview:_pageView];

    _searchBarView = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
    _searchBarView.navigationIcon = CYLSearchBarNavigationIconArrow;
    _searchBarView.fieldBackgroundColor = UIColor.clearColor;
    _searchBarView.delegate = self;
    [_pageView addSubview:_searchBarView];

    _dividerView = [[UIView alloc] init];
    _dividerView.isAccessibilityElement = NO;
    [_pageView addSubview:_dividerView];

    _suggestionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _suggestionsTableView.dataSource = self;
    _suggestionsTableView.delegate = self;
    _suggestionsTableView.rowHeight = UITableViewAutomaticDimension;
    _suggestionsTableView.estimatedRowHeight = 48;
    _suggestionsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _suggestionsTableView.backgroundColor = UIColor.clearColor;
    _suggestionsTableView.accessibilityLabel = [CYLSearchResources localizedStringForKey:@"search.suggestions"];
    _suggestionsTableView.hidden = YES;
    [_suggestionsTableView registerClass:UITableViewCell.class forCellReuseIdentifier:CYLSearchSuggestionCellIdentifier];
    [_pageView addSubview:_suggestionsTableView];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(cyl_keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(cyl_keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    [self cyl_applyStyle];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark Style

- (UIColor *)dividerColor { return _dividerColor ?: UIColor.separatorColor; }
- (void)setDividerColor:(UIColor *)color { _dividerColor = color; [self cyl_applyStyle]; }
- (UIColor *)suggestionTextColor { return _suggestionTextColor ?: UIColor.labelColor; }
- (void)setSuggestionTextColor:(UIColor *)color { _suggestionTextColor = color; [self.suggestionsTableView reloadData]; }
- (UIColor *)suggestionImageTintColor { return _suggestionImageTintColor ?: UIColor.secondaryLabelColor; }
- (void)setSuggestionImageTintColor:(UIColor *)color { _suggestionImageTintColor = color; [self.suggestionsTableView reloadData]; }
- (void)setSuggestionImage:(UIImage *)image { _suggestionImage = image; [self.suggestionsTableView reloadData]; }
- (void)setSuggestionLineBreakMode:(NSLineBreakMode)mode { _suggestionLineBreakMode = mode; [self.suggestionsTableView reloadData]; }
- (void)setSuggestionCellConfiguration:(void (^)(UITableViewCell *, NSString *, NSUInteger))configuration {
    _suggestionCellConfiguration = [configuration copy];
    [self.suggestionsTableView reloadData];
}
- (void)setSuggestionBackgroundColor:(UIColor *)color {
    _suggestionBackgroundColor = color;
    self.suggestionsTableView.backgroundColor = color ?: UIColor.clearColor;
    [self.suggestionsTableView reloadData];
}
- (void)setScrimColor:(UIColor *)color { _scrimColor = color; [self cyl_applyStyle]; }

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    // The page carries the background; the view itself only shows the scrim.
    [super setBackgroundColor:UIColor.clearColor];
    self.pageView.backgroundColor = backgroundColor ?: UIColor.systemBackgroundColor;
}

- (void)cyl_applyStyle {
    self.dividerView.backgroundColor = self.dividerColor;
    self.scrimView.backgroundColor = self.scrimColor ?: UIColor.clearColor;
    [self setNeedsLayout];
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
    if (contentView) {
        [self.pageView insertSubview:contentView belowSubview:self.suggestionsTableView];
    }
    [self setNeedsLayout];
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    UIEdgeInsets safe = self.safeAreaInsets;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat barHeight = self.searchBarView.intrinsicContentSize.height;
    CGFloat dividerHeight = 1 / MAX(1, self.traitCollection.displayScale);
    CGFloat top = safe.top + barHeight + dividerHeight;
    CGFloat bottom = CGRectGetHeight(bounds);
    // With a scrim, the page is only as tall as its content and the host shows through below it; without one, the
    // page fills the view.
    CGFloat pageHeight = bottom;
    if (self.scrimColor && !self.contentView) {
        [self.suggestionsTableView layoutIfNeeded];
        CGFloat listHeight = self.suggestionsVisible ? self.suggestionsTableView.contentSize.height : 0;
        pageHeight = MIN(bottom, top + listHeight);
    }
    self.pageView.frame = CGRectMake(0, 0, width, pageHeight);
    // The scrim lies only below the page, so nothing sits behind the search bar.
    self.scrimView.frame = CGRectMake(0, pageHeight, width, MAX(0, bottom - pageHeight));
    self.scrimView.hidden = !self.scrimColor || pageHeight >= bottom;
    self.searchBarView.frame = CGRectMake(safe.left, safe.top, width - safe.left - safe.right, barHeight);
    self.dividerView.frame = CGRectMake(0, safe.top + barHeight, width, dividerHeight);
    CGRect below = CGRectMake(safe.left, top, width - safe.left - safe.right, MAX(0, pageHeight - top));
    self.contentView.frame = below;
    self.suggestionsTableView.frame = below;
    UIEdgeInsets insets = self.suggestionsTableView.contentInset;
    insets.bottom = MAX(self.keyboardOverlap - (bottom - pageHeight), safe.bottom);
    self.suggestionsTableView.contentInset = insets;
    self.suggestionsTableView.verticalScrollIndicatorInsets = insets;
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    [self setNeedsLayout];
}

- (void)cyl_keyboardChanged:(NSNotification *)notification {
    if (!self.window) return;
    CGRect keyboard = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect local = [self convertRect:keyboard fromCoordinateSpace:self.window.screen.coordinateSpace];
    self.keyboardOverlap = MAX(0, CGRectGetMaxY(self.bounds) - CGRectGetMinY(local));
    [self setNeedsLayout];
}

- (void)cyl_keyboardHidden:(NSNotification *)notification {
    self.keyboardOverlap = 0;
    [self setNeedsLayout];
}

#pragma mark Opening and closing

- (void)installInView:(UIView *)view {
    if (self.superview != view) {
        [view addSubview:self];
    }
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view bringSubviewToFront:self];
}

- (UIView *)cyl_defaultHostView {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) return window.rootViewController.view ?: window;
        }
    }
    return nil;
}

- (void)showSearch {
    [self showSearchAnimated:YES];
}

- (void)showSearchAnimated:(BOOL)animated {
    if (!self.superview) {
        UIView *host = [self cyl_defaultHostView];
        if (!host) return;
        [self installInView:host];
    }
    [self.superview bringSubviewToFront:self];
    if (self.searchOpen) {
        [self.searchBarView showKeyboard];
        return;
    }
    self.searchOpen = YES;
    self.hidden = NO;
    self.accessibilityViewIsModal = YES;
    [self cyl_refilter];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.searchBarView showKeyboard];
    void (^finish)(BOOL) = ^(BOOL finished) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.searchBarView.textField);
        if ([self.delegate respondsToSelector:@selector(searchViewDidShow:)]) {
            [self.delegate searchViewDidShow:self];
        }
    };
    if (!animated || self.animationDuration <= 0) {
        self.alpha = 1;
        finish(YES);
        return;
    }
    self.alpha = 0;
    self.pageView.transform = CGAffineTransformMakeTranslation(0, -12);
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
        self.pageView.transform = CGAffineTransformIdentity;
    } completion:finish];
}

- (void)closeSearch {
    [self closeSearchAnimated:YES];
}

- (void)closeSearchAnimated:(BOOL)animated {
    if (!self.searchOpen) return;
    self.searchOpen = NO;
    [self.searchBarView hideKeyboard];
    void (^finish)(BOOL) = ^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        self.pageView.transform = CGAffineTransformIdentity;
        self.accessibilityViewIsModal = NO;
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        if ([self.delegate respondsToSelector:@selector(searchViewDidClose:)]) {
            [self.delegate searchViewDidClose:self];
        }
    };
    if (!animated || self.animationDuration <= 0) {
        finish(YES);
        return;
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
        self.pageView.transform = CGAffineTransformMakeTranslation(0, -12);
    } completion:finish];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.query ?: @"" forKey:@"CYLSearchViewQuery"];
    [coder encodeBool:self.searchOpen forKey:@"CYLSearchViewOpen"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    NSString *query = [coder decodeObjectOfClass:NSString.class forKey:@"CYLSearchViewQuery"];
    if (query) [self setQuery:query submit:NO];
    if ([coder decodeBoolForKey:@"CYLSearchViewOpen"]) [self showSearchAnimated:NO];
}

- (BOOL)accessibilityPerformEscape {
    [self closeSearch];
    return YES;
}

- (void)attachToBarButtonItem:(UIBarButtonItem *)item {
    item.target = self;
    item.action = @selector(showSearch);
}

#pragma mark Query and suggestions

- (NSString *)query { return self.searchBarView.text; }
- (void)setQuery:(NSString *)query { [self setQuery:query submit:NO]; }

- (void)setQuery:(NSString *)query submit:(BOOL)submit {
    self.searchBarView.text = query;
    [self cyl_queryChanged:query ?: @""];
    if (submit) {
        [self.searchBarView submit];
    }
}

- (void)setSuggestions:(NSArray<NSString *> *)suggestions {
    _suggestions = [suggestions copy] ?: @[];
    [self cyl_refilter];
}

- (void)setSuggestionFilter:(BOOL (^)(NSString *, NSString *))filter {
    _suggestionFilter = [filter copy];
    [self cyl_refilter];
}

- (void)setShowsSuggestionsForEmptyQuery:(BOOL)shows {
    _showsSuggestionsForEmptyQuery = shows;
    [self cyl_refilter];
}

- (void)cyl_refilter {
    NSString *query = self.searchBarView.text ?: @"";
    NSString *trimmed = [query stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSMutableArray<NSString *> *matches = [NSMutableArray array];
    for (NSString *suggestion in self.suggestions) {
        BOOL match;
        if (trimmed.length == 0) {
            match = self.showsSuggestionsForEmptyQuery;
        } else if (self.suggestionFilter) {
            match = self.suggestionFilter(suggestion, query);
        } else {
            match = [suggestion rangeOfString:trimmed options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound;
        }
        if (match) [matches addObject:suggestion];
    }
    self.filteredSuggestions = matches;
    self.suggestionsVisible = matches.count > 0;
    [self cyl_updateSuggestionsVisibility];
}

- (void)showSuggestions {
    [self cyl_refilter];
}

- (void)dismissSuggestions {
    self.suggestionsVisible = NO;
    [self cyl_updateSuggestionsVisibility];
}

- (void)cyl_updateSuggestionsVisibility {
    self.suggestionsTableView.hidden = !self.suggestionsVisible;
    [self.suggestionsTableView reloadData];
    [self setNeedsLayout];
}

- (void)cyl_queryChanged:(NSString *)text {
    [self cyl_refilter];
    if ([self.delegate respondsToSelector:@selector(searchView:textDidChange:)]) {
        [self.delegate searchView:self textDidChange:text];
    }
}

#pragma mark CYLSearchBarViewDelegate

- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text {
    [self cyl_queryChanged:text];
}

- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView {
    NSString *text = searchBarView.text ?: @"";
    BOOL handled = [self.delegate respondsToSelector:@selector(searchView:didSubmitText:)] && [self.delegate searchView:self didSubmitText:text];
    if (!handled && self.closesOnSubmit) {
        [self closeSearch];
    } else {
        [self dismissSuggestions];
    }
}

- (void)searchBarViewNavigationButtonClicked:(CYLSearchBarView *)searchBarView {
    if ([self.delegate respondsToSelector:@selector(searchViewNavigationButtonClicked:)]) {
        [self.delegate searchViewNavigationButtonClicked:self];
    } else {
        [self closeSearch];
    }
}

- (void)searchBarViewVoiceButtonClicked:(CYLSearchBarView *)searchBarView {
    if ([self.delegate respondsToSelector:@selector(searchViewVoiceButtonClicked:)]) {
        [self.delegate searchViewVoiceButtonClicked:self];
    }
}

- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView {
    [self closeSearch];
}

- (void)searchBarViewDidBeginEditing:(CYLSearchBarView *)searchBarView {
    if ([self.delegate respondsToSelector:@selector(searchView:didChangeFocus:)]) {
        [self.delegate searchView:self didChangeFocus:YES];
    }
}

- (void)searchBarViewDidEndEditing:(CYLSearchBarView *)searchBarView {
    if ([self.delegate respondsToSelector:@selector(searchView:didChangeFocus:)]) {
        [self.delegate searchView:self didChangeFocus:NO];
    }
}

#pragma mark Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestionsVisible ? (NSInteger)self.filteredSuggestions.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLSearchSuggestionCellIdentifier forIndexPath:indexPath];
    NSString *suggestion = self.filteredSuggestions[(NSUInteger)indexPath.row];
    UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
    content.text = suggestion;
    content.textProperties.color = self.suggestionTextColor;
    content.textProperties.lineBreakMode = self.suggestionLineBreakMode;
    content.textProperties.numberOfLines = self.suggestionLineBreakMode == NSLineBreakByWordWrapping || self.suggestionLineBreakMode == NSLineBreakByCharWrapping ? 0 : 1;
    content.image = self.suggestionImage;
    content.imageProperties.tintColor = self.suggestionImageTintColor;
    cell.contentConfiguration = content;
    UIBackgroundConfiguration *background = [UIBackgroundConfiguration listPlainCellConfiguration];
    background.backgroundColor = self.suggestionBackgroundColor ?: UIColor.clearColor;
    cell.backgroundConfiguration = background;
    cell.accessibilityTraits |= UIAccessibilityTraitButton;
    if (self.suggestionCellConfiguration) {
        self.suggestionCellConfiguration(cell, suggestion, (NSUInteger)indexPath.row);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = (NSUInteger)indexPath.row;
    if (index >= self.filteredSuggestions.count) return;
    NSString *suggestion = self.filteredSuggestions[index];
    self.searchBarView.text = suggestion;
    if ([self.delegate respondsToSelector:@selector(searchView:didSelectSuggestion:atIndex:)]) {
        [self.delegate searchView:self didSelectSuggestion:suggestion atIndex:index];
    }
    if (self.submitsOnSuggestionSelection) {
        [self.searchBarView submit];
    } else {
        [self cyl_queryChanged:suggestion];
    }
}

@end
