#import <XCTest/XCTest.h>
#import "CYLSearchExample-Swift.h"
#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchBarDemoViewController.h"
#import "CYLSearchExampleAppDelegate.h"
#import <CYLTabBarController/CYLTabBarController.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLSearchExampleTests : XCTestCase
@end

@interface CYLSearchBarRecorder : NSObject <CYLSearchBarViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@end

@implementation CYLSearchBarRecorder
- (instancetype)init { if ((self = [super init])) { _events = [NSMutableArray array]; } return self; }
- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text { [self.events addObject:[@"text " stringByAppendingString:text]]; }
- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView { [self.events addObject:@"search"]; }
- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView { [self.events addObject:@"cancel"]; }
@end

/*!
 * Records the parity events of CYLSearchBarView, CYLSearchView and CYLMultiSearchView, and refuses submissions
 * while `refuseSubmit` is YES.
 */
@interface CYLParityRecorder : NSObject <CYLSearchBarViewDelegate, CYLSearchViewDelegate, CYLMultiSearchViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@property (nonatomic, assign) BOOL refuseSubmit;
@property (nonatomic, assign) BOOL handleSubmit;
@property (nonatomic, assign) BOOL refuseEditing;
@end

@implementation CYLParityRecorder
- (instancetype)init { if ((self = [super init])) { _events = [NSMutableArray array]; } return self; }
- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView { [self.events addObject:[@"search " stringByAppendingString:searchBarView.text ?: @""]]; }
- (BOOL)searchBarView:(CYLSearchBarView *)searchBarView shouldSubmitText:(NSString *)text { return !self.refuseSubmit; }
- (void)searchBarViewNavigationButtonClicked:(CYLSearchBarView *)searchBarView { [self.events addObject:@"navigation"]; }
- (BOOL)searchBarViewShouldBeginEditing:(CYLSearchBarView *)searchBarView { return !self.refuseEditing; }
- (void)searchBarViewDidTapWhileNotEditable:(CYLSearchBarView *)searchBarView { [self.events addObject:@"tapped"]; }
- (void)searchBarViewVoiceButtonClicked:(CYLSearchBarView *)searchBarView { [self.events addObject:@"voice"]; }
- (void)searchBarView:(CYLSearchBarView *)searchBarView didChangeIconified:(BOOL)iconified { [self.events addObject:iconified ? @"iconified" : @"expanded"]; }
- (void)searchViewDidShow:(CYLSearchView *)searchView { [self.events addObject:@"shown"]; }
- (void)searchViewDidClose:(CYLSearchView *)searchView { [self.events addObject:@"closed"]; }
- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text { [self.events addObject:[@"change " stringByAppendingString:text]]; }
- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text { [self.events addObject:[@"submit " stringByAppendingString:text]]; return self.handleSubmit; }
- (void)searchView:(CYLSearchView *)searchView didSelectSuggestion:(NSString *)suggestion atIndex:(NSUInteger)index { [self.events addObject:[NSString stringWithFormat:@"suggestion %lu %@", (unsigned long)index, suggestion]]; }
- (void)multiSearchView:(CYLMultiSearchView *)view textDidChange:(NSString *)text atIndex:(NSUInteger)index { [self.events addObject:[NSString stringWithFormat:@"typed %lu %@", (unsigned long)index, text]]; }
- (void)multiSearchView:(CYLMultiSearchView *)view didCompleteSearch:(NSString *)text atIndex:(NSUInteger)index { [self.events addObject:[NSString stringWithFormat:@"complete %lu %@", (unsigned long)index, text]]; }
- (void)multiSearchView:(CYLMultiSearchView *)view didRemoveItemAtIndex:(NSUInteger)index { [self.events addObject:[NSString stringWithFormat:@"removed %lu", (unsigned long)index]]; }
- (void)multiSearchView:(CYLMultiSearchView *)view didSelectItem:(NSString *)text atIndex:(NSUInteger)index { [self.events addObject:[NSString stringWithFormat:@"selected %lu %@", (unsigned long)index, text]]; }
@end

@interface CYLSearchNumberDataSource : NSObject <CYLSearchResultsDataSource>
@property (nonatomic, strong) NSNumber *selectedResult;
@end

@implementation CYLSearchNumberDataSource

- (NSArray *)searchResultsViewController:(CYLSearchResultsViewController *)controller resultsForQuery:(NSString *)query
{
    return query.length ? @[] : @[@42];
}

- (void)searchResultsViewController:(CYLSearchResultsViewController *)controller configureCell:(UITableViewCell *)cell withResult:(id)result
{
    cell.textLabel.text = [result description];
}

- (void)searchResultsViewController:(CYLSearchResultsViewController *)controller didSelectResult:(id)result
{
    self.selectedResult = result;
}

@end

@interface CYLSearchImmediateRefresh : NSObject <CYLSearchExampleRefreshing>
@property (nonatomic, assign) NSUInteger refreshCount;
@end

@implementation CYLSearchImmediateRefresh

- (void)reloadWithCompletion:(void (^)(NSError * _Nullable))completion
{
    self.refreshCount++;
    completion(nil);
}

@end

@interface CYLSearchOverlayDelegate : NSObject <CYLSearchControllerDelegate>
@property (nonatomic, assign) NSUInteger cancelCount;
@end

@implementation CYLSearchOverlayDelegate
- (void)searchControllerDidCancel:(CYLSearchController *)controller
{
    self.cancelCount++;
}
@end

@interface CYLSearchTestNavigationController : UINavigationController
@property (nonatomic, strong) UIViewController *lastPushedController;
@end

@implementation CYLSearchTestNavigationController
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.lastPushedController = viewController;
    [super pushViewController:viewController animated:NO];
}
@end

/*!
 * A window in the host app's scene: with the scene lifecycle, a window without a scene is never shown, and the
 * search bars of its navigation items are never installed.
 */
static UIWindow *CYLTestWindow(CGRect frame)
{
    UIWindowScene *scene = nil;
    for (UIScene *candidate in UIApplication.sharedApplication.connectedScenes) {
        if ([candidate isKindOfClass:UIWindowScene.class]) { scene = (UIWindowScene *)candidate; break; }
    }
    UIWindow *window = scene ? [[UIWindow alloc] initWithWindowScene:scene] : [[UIWindow alloc] initWithFrame:frame];
    window.frame = frame;
    return window;
}

/*!
 * What a navigation-item search controller shows: its search bar, or on iOS 26, where the navigation bar hosts the
 * field without the bar, the search text field.
 */
static UIView *CYLVisibleSearchView(UISearchBar *searchBar)
{
    return searchBar.window ? searchBar : searchBar.searchTextField;
}

/*!
 * Views that `view` covers: visible views under `root` (its window when nil) whose frames intersect `view`'s frame
 * in window coordinates, after clipping by ancestors that clip their bounds. Not counted: `view`'s subviews, the
 * views that contain it, system bar backgrounds, and plain leaf views that draw nothing. Counted: labels, images, controls, text, scroll views, view controllers'
 * views, and leaf views with a background, contents or a border. Each entry is "<class> <frame> in <superview>".
 */
static NSArray<NSString *> *CYLViewsCoveredByView(UIView *view, UIView *root)
{
    UIWindow *window = view.window;
    if (!window) return @[@"not in a window"];
    CGRect frame = CGRectInset([view convertRect:view.bounds toView:window], 0.5, 0.5);
    NSMutableSet<NSValue *> *ancestors = [NSMutableSet set];
    for (UIView *parent = view.superview; parent; parent = parent.superview) {
        [ancestors addObject:[NSValue valueWithNonretainedObject:parent]];
    }
    NSMutableArray<NSString *> *covered = [NSMutableArray array];
    __block void (^visit)(UIView *);
    __block __weak void (^weakVisit)(UIView *);
    weakVisit = visit = ^(UIView *candidate) {
        if (candidate == view || candidate.hidden || candidate.alpha <= 0.01) return;
        NSString *name = NSStringFromClass(candidate.class);
        if ([name containsString:@"BarBackground"]) return;
        BOOL content = [candidate isKindOfClass:UILabel.class] || [candidate isKindOfClass:UIControl.class]
            || [candidate isKindOfClass:UITextView.class] || [candidate isKindOfClass:UIScrollView.class]
            || [candidate.nextResponder isKindOfClass:UIViewController.class];
        if ([candidate isKindOfClass:UIImageView.class]) content = ((UIImageView *)candidate).image != nil;
        if (!content && candidate.subviews.count == 0 && ![name hasPrefix:@"_"]) {
            content = CGColorGetAlpha(candidate.backgroundColor.CGColor) > 0.01 || candidate.layer.contents || candidate.layer.borderWidth > 0;
        }
        if (content && ![ancestors containsObject:[NSValue valueWithNonretainedObject:candidate]]) {
            // Only the part left visible by ancestors that clip (a scroll view hides what lies outside it).
            CGRect other = [candidate convertRect:candidate.bounds toView:window];
            for (UIView *clip = candidate.superview; clip && clip != window; clip = clip.superview) {
                if (clip.clipsToBounds) other = CGRectIntersection(other, [clip convertRect:clip.bounds toView:window]);
            }
            if (!CGRectIsNull(other) && CGRectGetWidth(other) > 0 && CGRectGetHeight(other) > 0 && CGRectIntersectsRect(frame, other)) {
                [covered addObject:[NSString stringWithFormat:@"%@ %@ in %@", name, NSStringFromCGRect(other), NSStringFromClass(candidate.superview.class)]];
            }
        }
        for (UIView *subview in candidate.subviews) weakVisit(subview);
    };
    for (UIView *subview in (root ?: window).subviews) visit(subview);
    visit = nil;
    return covered;
}

@implementation CYLSearchExampleTests

- (void)testLocalPodsConfigureSearchAndRefresh
{
    CYLSearchExampleDataSource *source = [[CYLSearchExampleDataSource alloc] init];
    CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source
                                                                                                 refreshProvider:source];
    [controller loadViewIfNeeded];
    XCTAssertFalse(controller.navigationItem.hidesSearchBarWhenScrolling);
    XCTAssertNotNil(controller.tableView.cyl_header);
    XCTAssertEqual(controller.searchResults.count, 40);
    controller.searchController.searchBar.text = @"not a result";
    [controller reloadSearchResults];
    XCTAssertEqual(controller.searchResults.count, 0);
    NSPredicate *placeholder = [NSPredicate predicateWithBlock:^BOOL(UIView *view, NSDictionary *bindings) {
        return [view.accessibilityIdentifier isEqualToString:@"CYLSearchEmptyState"];
    }];
    XCTAssertEqual([controller.tableView.subviews filteredArrayUsingPredicate:placeholder].count, 1);
    controller.searchController.searchBar.text = @"";
    [controller reloadSearchResults];
    XCTAssertEqual([controller.tableView.subviews filteredArrayUsingPredicate:placeholder].count, 0);

    UIBarButtonItem *toggle = controller.navigationItem.rightBarButtonItem;
    [UIApplication.sharedApplication sendAction:toggle.action to:toggle.target from:toggle forEvent:nil];
    XCTAssertTrue(controller.navigationItem.hidesSearchBarWhenScrolling);
    XCTAssertEqualObjects(toggle.title, [CYLSearchResources localizedStringForKey:@"repro.on"]);
    [UIApplication.sharedApplication sendAction:toggle.action to:toggle.target from:toggle forEvent:nil];
    XCTAssertFalse(controller.navigationItem.hidesSearchBarWhenScrolling);
}

- (void)testPackagedResourcesAndLocalization
{
    NSBundle *bundle = CYLSearchResources.resourceBundle;
    XCTAssertNotNil(bundle);
    XCTAssertNotNil([CYLSearchResources imageNamed:@"CYLSearchEmpty"]);
    XCTAssertNotNil([CYLSearchResources imageNamed:@"CYLSearchNoResults"]);
    XCTAssertNotNil([CYLSearchResources imageNamed:@"CYLSearchError"]);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.search" language:@"en"], @"No matching results");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.search" language:@"zh-Hans"], @"没有匹配的结果");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.search" language:@"zh-Hant"], @"沒有符合的結果");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.search" language:@"ja"], @"一致する結果がありません");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.search" language:@"xx-XX"], @"No matching results");
    for (NSNumber *kind in @[@(CYLSearchPlaceholderKindEmpty), @(CYLSearchPlaceholderKindNoResults), @(CYLSearchPlaceholderKindError)]) {
        CYLSearchPlaceholderView *view = [[CYLSearchPlaceholderView alloc] initWithKind:kind.integerValue];
        XCTAssertNotNil(view.imageView.image);
        XCTAssertGreaterThan(view.textLabel.text.length, 0);
    }
}

- (void)testIndependentPlaceholderStylesAndMessages
{
    NSArray<NSString *> *keys = @[@"placeholder.empty", @"placeholder.search", @"placeholder.error", @"placeholder.network"];
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    for (NSInteger style = 0; style < CYLSearchPlaceholderStyleCount; style++) {
        NSString *name = [CYLSearchPlaceholderView imageNameForStyle:style];
        XCTAssertFalse([names containsObject:name]);
        [names addObject:name];
        XCTAssertNotNil([CYLSearchResources imageNamed:name]);
        for (NSInteger message = 0; message < 4; message++) {
            CYLSearchPlaceholderView *view = [[CYLSearchPlaceholderView alloc] initWithStyle:style message:message];
            XCTAssertNotNil(view.imageView.image);
            XCTAssertEqualObjects(view.textLabel.text, [CYLSearchResources localizedStringForKey:keys[message]]);
            view.frame = CGRectMake(0, 0, 320, 480);
            [view layoutIfNeeded];
            XCTAssertEqualWithAccuracy(CGRectGetWidth(view.imageView.frame), 80, 0.1);
        }
    }
    UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
    CYLSearchPlaceholderView *both = [[CYLSearchPlaceholderView alloc] initWithImage:image text:@"Custom"];
    XCTAssertEqual(both.imageView.image, image);
    XCTAssertEqualObjects(both.textLabel.text, @"Custom");
    XCTAssertEqualObjects([[[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleError text:@"Custom"] textLabel].text, @"Custom");
    XCTAssertEqual([[[CYLSearchPlaceholderView alloc] initWithImage:image message:CYLSearchPlaceholderMessageEmpty] imageView].image, image);
    XCTAssertThrowsSpecificNamed([[CYLSearchPlaceholderView alloc] initWithStyle:999 message:CYLSearchPlaceholderMessageEmpty], NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed([[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleEmpty message:999], NSException, NSInvalidArgumentException);
}

- (void)testPlaceholderMessagesAreLocalized
{
    NSDictionary<NSString *, NSString *> *expected = @{
        @"en": @"Check your internet connection",
        @"zh-Hans": @"请检查网络连接",
        @"zh-Hant": @"請檢查網路連線",
        @"ja": @"インターネット接続を確認してください",
        @"xx-XX": @"Check your internet connection"
    };
    for (NSString *language in expected) {
        XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"placeholder.network" language:language], expected[language]);
    }
}

- (void)testPlaceholderGalleryNavigation
{
    CYLSearchDemoMenuViewController *menu = [[CYLSearchDemoMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    CYLSearchTestNavigationController *navigation = [[CYLSearchTestNavigationController alloc] initWithRootViewController:menu];
    [menu loadViewIfNeeded];
    XCTAssertEqual(menu.navigationController, navigation);
    XCTAssertEqual([menu tableView:menu.tableView numberOfRowsInSection:0], 4, @"reproduction, styles, search bar, ports of other libraries");
    [menu tableView:menu.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewController *gallery = (UITableViewController *)navigation.lastPushedController;
    XCTAssertNotEqual(gallery, menu);
    [gallery loadViewIfNeeded];
    XCTAssertEqual([gallery numberOfSectionsInTableView:gallery.tableView], CYLSearchPlaceholderStyleCount + 1);
    for (NSInteger section = 0; section <= CYLSearchPlaceholderStyleCount; section++) {
        NSInteger count = [gallery tableView:gallery.tableView numberOfRowsInSection:section];
        XCTAssertEqual(count, section == CYLSearchPlaceholderStyleCount ? 3 : 4);
        for (NSInteger row = 0; row < count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [gallery tableView:gallery.tableView didSelectRowAtIndexPath:indexPath];
            UIViewController *detail = navigation.lastPushedController;
            XCTAssertNotEqual(detail, gallery);
            XCTAssertTrue([detail.view.subviews.firstObject isKindOfClass:CYLSearchPlaceholderView.class]);
            [navigation popViewControllerAnimated:NO];
        }
    }
}

- (void)testGenericDataSourceConfiguresAndSelectsResults
{
    CYLSearchNumberDataSource *source = [CYLSearchNumberDataSource new];
    CYLSearchResultsViewController *controller = [[CYLSearchResultsViewController alloc] initWithSearchDataSource:source];
    [controller loadViewIfNeeded];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertEqualObjects(cell.textLabel.text, @"42");
    [controller tableView:controller.tableView didSelectRowAtIndexPath:indexPath];
    XCTAssertEqualObjects(source.selectedResult, @42);
    controller.searchController.searchBar.text = @"empty";
    [controller reloadSearchResults];
    XCTAssertEqual(controller.searchResults.count, 0);
}

- (void)testRefreshBlockDoesNotRetainController
{
    __weak CYLSearchExampleViewController *weakController;
    CYLRefreshHeader *header;
    @autoreleasepool {
        CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
        CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source
                                                                                                     refreshProvider:source];
        [controller loadViewIfNeeded];
        header = controller.tableView.cyl_header;
        weakController = controller;
    }
    XCTAssertNil(weakController);
    XCTAssertNotNil(header.refreshingBlock);
    header.refreshingBlock();
}

- (void)testRefreshReloadsSearchResults
{
    CYLSearchNumberDataSource *source = [CYLSearchNumberDataSource new];
    CYLSearchImmediateRefresh *refresh = [CYLSearchImmediateRefresh new];
    CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source
                                                                                                 refreshProvider:refresh];
    [controller loadViewIfNeeded];
    XCTAssertEqual(controller.searchResults.count, 1);
    controller.searchController.searchBar.text = @"empty";
    controller.tableView.cyl_header.refreshingBlock();
    XCTestExpectation *finished = [self expectationWithDescription:@"Refresh completion updates the search results"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqual(refresh.refreshCount, 1);
        XCTAssertEqual(controller.searchResults.count, 0);
        [finished fulfill];
    });
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testAnimatedSearchOverlayUsesInjectedDataAndRemovesItsChild
{
    CYLSearchNumberDataSource *source = [CYLSearchNumberDataSource new];
    CYLSearchController *overlay = [[CYLSearchController alloc] initWithSearchDataSource:source];
    UIViewController *host = [UIViewController new];
    [host loadViewIfNeeded];
    [overlay showInViewController:host];
    XCTAssertTrue(overlay.isPresented);
    XCTAssertEqual(host.childViewControllers.count, 1);
    XCTAssertEqual(overlay.resultsViewController.searchResults.count, 1);
    XCTAssertEqualObjects(overlay.navigationItem.searchController, overlay.resultsViewController.searchController);
    XCTestExpectation *removed = [self expectationWithDescription:@"Overlay removed"];
    [overlay hide:^{
        XCTAssertFalse(overlay.isPresented);
        XCTAssertEqual(host.childViewControllers.count, 0);
        [removed fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTestExpectation *alreadyHidden = [self expectationWithDescription:@"Already hidden completion"];
    [overlay hide:^{ [alreadyHidden fulfill]; }];
    [self waitForExpectationsWithTimeout:2 handler:nil];

    CYLSearchOverlayDelegate *delegate = [CYLSearchOverlayDelegate new];
    overlay.delegate = delegate;
    [overlay showInViewController:host];
    XCTAssertTrue(overlay.isPresented);
    UIBarButtonItem *cancel = overlay.navigationItem.leftBarButtonItem;
    [UIApplication.sharedApplication sendAction:cancel.action to:cancel.target from:cancel forEvent:nil];
    XCTestExpectation *cancelled = [self expectationWithDescription:@"Cancel notifies delegate after dismissal"];
    [overlay hide:^{
        XCTAssertFalse(overlay.isPresented);
        XCTAssertEqual(delegate.cancelCount, 1);
        XCTAssertEqual(host.childViewControllers.count, 0);
        [cancelled fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSearchBarViewLayoutStyleAndEvents
{
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 375, 48)];
    CYLSearchBarRecorder *recorder = [[CYLSearchBarRecorder alloc] init];
    bar.delegate = recorder;
    bar.placeholder = @"主播昵称/直播间ID/神曲名";
    XCTAssertEqualObjects(bar.textField.placeholder, @"主播昵称/直播间ID/神曲名");
    XCTAssertEqual(bar.intrinsicContentSize.height, 48);
    XCTAssertTrue(bar.cancelButton.hidden);

    bar.showsCancelButton = YES;
    bar.cancelButtonTitle = @"取消";
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeSystem];
    [camera setImage:[UIImage systemImageNamed:@"camera"] forState:UIControlStateNormal];
    bar.trailingAccessoryViews = @[camera];
    bar.fieldCornerRadius = 4;
    [bar layoutIfNeeded];
    XCTAssertFalse(bar.cancelButton.hidden);
    XCTAssertEqualObjects(bar.cancelButton.configuration.attributedTitle.string, @"取消");
    CGFloat titleWidth = [@"取消" sizeWithAttributes:@{NSFontAttributeName: bar.font}].width;
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(bar.cancelButton.frame), titleWidth, @"the whole title fits");
    XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.fieldView.frame), CGRectGetMinX(bar.cancelButton.frame));
    XCTAssertTrue(camera.superview == bar.fieldView);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.textField.frame), CGRectGetMinX(camera.frame));
    XCTAssertEqual(bar.fieldView.layer.cornerRadius, 4);
    bar.fieldCornerRadius = -1;
    [bar layoutIfNeeded];
    XCTAssertEqual(bar.fieldView.layer.cornerRadius, 18, @"a capsule");

    bar.text = @"IDG";
    XCTAssertEqualObjects(bar.textField.text, @"IDG");
    [bar.textField sendActionsForControlEvents:UIControlEventEditingChanged];
    [bar.textField.delegate textFieldShouldReturn:bar.textField];
    [bar.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    NSArray *expected = @[@"text IDG", @"search", @"cancel"];
    XCTAssertEqualObjects(recorder.events, expected);

    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    bar.leadingView = back;
    [bar layoutIfNeeded];
    XCTAssertLessThanOrEqual(CGRectGetMaxX(back.frame), CGRectGetMinX(bar.fieldView.frame) + 0.5);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.cancel" language:@"zh-Hans"], @"取消");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.cancel" language:@"en"], @"Cancel");
}

- (void)testSearchBarViewSupportsVoiceOverAndDynamicType
{
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 375, 48)];
    // The field keeps a spoken name when the placeholder is gone; the magnifier is decorative.
    XCTAssertEqualObjects(bar.textField.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"search.field"]);
    XCTAssertFalse(bar.searchIconView.isAccessibilityElement);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.field" language:@"zh-Hant"], @"搜尋");
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.field" language:@"ja"], @"検索");

    // A scaled font is used as given (not scaled twice), and the field grows instead of clipping the text.
    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    XCTAssertEqual(bar.intrinsicContentSize.height, 48, @"36 pt is enough at the default size");
    UIFont *scaled = [[UIFontMetrics defaultMetrics] scaledFontForFont:[UIFont systemFontOfSize:16] compatibleWithTraitCollection:large];
    bar.font = scaled;
    XCTAssertEqual(bar.font, scaled);
    XCTAssertGreaterThan(bar.intrinsicContentSize.height, 48, @"the field grows with large text");
    bar.fieldHeight = 10;
    XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, ceil(bar.font.lineHeight + 12) + 12, @"never shorter than the text");

    // At the largest size the text keeps 40% of the bar: Cancel and a large accessory are drawn smaller instead.
    bar.fieldHeight = 36;
    bar.showsCancelButton = YES;
    bar.cancelButtonTitle = @"Cancel";
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeSystem];
    [camera setImage:[UIImage systemImageNamed:@"camera" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:64]] forState:UIControlStateNormal];
    bar.trailingAccessoryViews = @[camera];
    bar.frame = CGRectMake(0, 0, 390, bar.intrinsicContentSize.height);
    [bar layoutIfNeeded];
    CGFloat available = 390 - bar.contentInsets.left - bar.contentInsets.right;
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(bar.textField.frame), floor(available * 0.4) - 1);
    XCTAssertLessThanOrEqual(CGRectGetWidth(bar.cancelButton.frame), floor(available * 0.3) + 0.5);
    XCTAssertLessThan(camera.transform.a, 1, @"the camera is drawn smaller");
    XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.textField.frame), CGRectGetMinX(camera.frame) + 0.5);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(camera.frame), CGRectGetWidth(bar.fieldView.bounds));
    XCTAssertEqualObjects(bar.cancelButton.accessibilityLabel, @"Cancel", @"VoiceOver reads the whole title");

    // The placeholder keeps the text's size at large sizes (cut off with an ellipsis, never shrunk), hides while
    // there is text, and stays on the text field for VoiceOver.
    bar.placeholder = @"主播昵称/直播间ID/神曲名";
    [bar layoutIfNeeded];
    XCTAssertEqual(bar.placeholderLabel.font.pointSize, bar.font.pointSize);
    XCTAssertFalse(bar.placeholderLabel.adjustsFontSizeToFitWidth);
    XCTAssertEqual(bar.placeholderLabel.lineBreakMode, NSLineBreakByTruncatingTail);
    XCTAssertEqualObjects(bar.placeholderLabel.text, @"主播昵称/直播间ID/神曲名");
    XCTAssertEqualObjects(bar.textField.placeholder, @"主播昵称/直播间ID/神曲名", @"VoiceOver still gets the placeholder");
    XCTAssertTrue(CGRectContainsRect(CGRectInset(bar.textField.frame, -0.5, -0.5), bar.placeholderLabel.frame));
    XCTAssertFalse(bar.placeholderLabel.hidden);
    bar.text = @"IDG";
    XCTAssertTrue(bar.placeholderLabel.hidden);
    bar.text = nil;
    XCTAssertFalse(bar.placeholderLabel.hidden);
}

- (void)testSearchBarDemoRow
{
    CYLSearchDemoMenuViewController *menu = [[CYLSearchDemoMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    CYLSearchTestNavigationController *navigation = [[CYLSearchTestNavigationController alloc] initWithRootViewController:menu];
    [menu loadViewIfNeeded];
    NSIndexPath *row = [NSIndexPath indexPathForRow:2 inSection:0];
    XCTAssertEqualObjects([menu tableView:menu.tableView cellForRowAtIndexPath:row].textLabel.text, [CYLSearchResources localizedStringForKey:@"demo.searchBar"]);
    [menu tableView:menu.tableView didSelectRowAtIndexPath:row];
    UIViewController *demo = navigation.lastPushedController;
    demo.view.frame = CGRectMake(0, 0, 390, 844);
    [demo.view layoutIfNeeded];
    CYLSearchBarView *bar = (CYLSearchBarView *)[demo.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", CYLSearchBarView.class]].firstObject;
    UILabel *status = (UILabel *)[demo.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", UILabel.class]].firstObject;
    XCTAssertNotNil(bar);
    XCTAssertEqualObjects(bar.placeholder, [CYLSearchResources localizedStringForKey:@"demo.searchBar.placeholder"]);
    XCTAssertFalse(bar.cancelButton.hidden);
    UIView *camera = bar.trailingAccessoryViews.firstObject;
    XCTAssertEqualObjects(camera.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"demo.searchBar.camera"]);
    XCTAssertGreaterThan(CGRectGetWidth(bar.frame), 0);
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(status.frame), CGRectGetMaxY(bar.frame));

    bar.text = @"IDG";
    [bar.textField sendActionsForControlEvents:UIControlEventEditingChanged];
    XCTAssertEqualObjects(status.text, ([NSString stringWithFormat:[CYLSearchResources localizedStringForKey:@"demo.searchBar.text"], @"IDG"]));
    [bar.textField.delegate textFieldShouldReturn:bar.textField];
    XCTAssertEqualObjects(status.text, ([NSString stringWithFormat:[CYLSearchResources localizedStringForKey:@"demo.searchBar.searched"], @"IDG"]));
    [bar.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(bar.text, @"");

    NSDictionary<NSString *, NSString *> *titles = @{@"en": @"Search bar", @"zh-Hans": @"搜索栏", @"zh-Hant": @"搜尋列", @"ja": @"検索バー"};
    for (NSString *language in titles) {
        XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"demo.searchBar" language:language], titles[language]);
    }
}

- (void)testTabBarComesFromTheConfigurationFile
{
    UIViewController *root = [CYLSearchExampleAppDelegate rootViewController];
    XCTAssertTrue([root isKindOfClass:CYLTabBarController.class], @"CYLTabBarConfiguration.json is read");
    CYLTabBarController *tabBarController = (CYLTabBarController *)root;
    [tabBarController loadViewIfNeeded];
    XCTAssertTrue([tabBarController hasPlusButton]);
    XCTAssertTrue([tabBarController hasPlusChildViewController], @"the plus page ID resolves to a child");
    NSArray<UIViewController *> *pages = tabBarController.viewControllers;
    XCTAssertEqual(pages.count, 3);
    NSArray<Class> *roots = @[CYLSearchExampleViewController.class, CYLSearchBarDemoViewController.class, CYLSearchDemoMenuViewController.class];
    for (Class rootClass in roots) {
        NSUInteger index = [pages indexOfObjectPassingTest:^BOOL(UIViewController *page, NSUInteger idx, BOOL *stop) {
            return [page isKindOfClass:UINavigationController.class]
                && [((UINavigationController *)page).viewControllers.firstObject isKindOfClass:rootClass];
        }];
        XCTAssertNotEqual(index, NSNotFound, @"%@ sits in a navigation controller", rootClass);
    }
    // Loading a page does not rename its tab: the tab titles come from the file, page titles go to navigationItem.
    NSArray<NSString *> *fileTitles = [pages valueForKeyPath:@"tabBarItem.title"];
    for (UIViewController *page in pages) {
        [((UINavigationController *)page).viewControllers.firstObject loadViewIfNeeded];
    }
    XCTAssertEqualObjects([pages valueForKeyPath:@"tabBarItem.title"], fileTitles);
    // VoiceOver reads the plus button by its title from the file.
    XCTAssertGreaterThan(CYLExternPlusButton.accessibilityLabel.length, 0);
    XCTAssertTrue(CYLExternPlusButton.isAccessibilityElement || CYLExternPlusButton.accessibilityLabel.length > 0);
    // The titles are keys translated from CYLSearchTabs.bundle.
    NSString *language = [NSBundle.mainBundle.preferredLocalizations.firstObject hasPrefix:@"zh"] ? nil : @"en";
    if (language) {
        NSArray<NSString *> *titles = [pages valueForKeyPath:@"tabBarItem.title"];
        XCTAssertTrue([titles containsObject:@"Search"], @"%@", titles);
        XCTAssertTrue([titles containsObject:@"Examples"], @"%@", titles);
        XCTAssertEqualObjects(CYLExternPlusButton.accessibilityLabel, @"Search bar");
    }
    for (NSString *code in @[@"en", @"zh-Hans", @"zh-Hant", @"ja"]) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"CYLSearchTabs" ofType:@"strings" inDirectory:[NSString stringWithFormat:@"CYLSearchTabs.bundle/%@.lproj", code]];
        NSDictionary *table = path ? [NSDictionary dictionaryWithContentsOfFile:path] : nil;
        XCTAssertEqual(table.count, 3, @"%@ has every key", code);
    }
}

- (void)testSearchBarNeverCoversTheViewControllersView
{
    CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
    CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    for (NSNumber *hides in @[@NO, @YES]) {
        controller.navigationItem.hidesSearchBarWhenScrolling = hides.boolValue;
        [navigation.view setNeedsLayout];
        [navigation.view layoutIfNeeded];
        UIView *searchBar = CYLVisibleSearchView(controller.searchController.searchBar);
        CGRect searchBarFrame = [searchBar convertRect:searchBar.bounds toView:window];
        CGRect viewFrame = [controller.view convertRect:controller.view.bounds toView:window];
        XCTAssertGreaterThanOrEqual(CGRectGetMinY(viewFrame), CGRectGetMaxY(navigation.navigationBar.frame) - 0.5, @"hides %@", hides);
        if (!hides.boolValue) XCTAssertNotNil(searchBar.window, @"the pinned search bar is shown");
        if (!searchBar.hidden && searchBar.window && CGRectGetHeight(searchBarFrame) > 0) {
            XCTAssertFalse(CGRectIntersectsRect(CGRectInset(searchBarFrame, 0, 0.5), viewFrame), @"hides %@: %@ / %@", hides, NSStringFromCGRect(searchBarFrame), NSStringFromCGRect(viewFrame));
        }
    }
    window.hidden = YES;
}

- (void)testSearchBarsCoverNoView
{
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    NSArray<UIContentSizeCategory> *sizes = @[UIContentSizeCategoryLarge, UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

    // The navigation-item search bar of the results screen, with the bar pinned and hiding on scroll.
    CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
    CYLSearchExampleViewController *results = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:results];
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    for (NSNumber *hides in @[@NO, @YES]) {
        results.navigationItem.hidesSearchBarWhenScrolling = hides.boolValue;
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
        [navigation.view setNeedsLayout];
        [navigation.view layoutIfNeeded];
        UIView *searchBar = CYLVisibleSearchView(results.searchController.searchBar);
        if (!hides.boolValue) XCTAssertNotNil(searchBar.window, @"the pinned search bar is shown");
        if (searchBar.window && !searchBar.hidden) {
            NSArray *covered = CYLViewsCoveredByView(searchBar, nil);
            XCTAssertEqual(covered.count, 0, @"results, hides %@: %@", hides, covered);
        }
    }

    // CYLSearchBarView on the search bar demo page, at the default and the largest text size.
    CYLSearchBarDemoViewController *demo = [CYLSearchBarDemoViewController new];
    navigation = [[UINavigationController alloc] initWithRootViewController:demo];
    window.rootViewController = navigation;
    for (UIContentSizeCategory size in sizes) {
        if (@available(iOS 17.0, *)) {
            window.traitOverrides.preferredContentSizeCategory = size;
        }
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        [navigation.view setNeedsLayout];
        [navigation.view layoutIfNeeded];
        CYLSearchBarView *bar = (CYLSearchBarView *)[demo.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", CYLSearchBarView.class]].firstObject;
        XCTAssertNotNil(bar.window);
        NSArray *covered = CYLViewsCoveredByView(bar, nil);
        XCTAssertEqual(covered.count, 0, @"demo at %@: %@", size, covered);
    }
    if (@available(iOS 17.0, *)) {
        window.traitOverrides.preferredContentSizeCategory = UIContentSizeCategoryLarge;
    }

    // The overlay is a page of its own over its host: inside that page its search bar covers no view.
    UIViewController *host = [UIViewController new];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:host];
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    [window layoutIfNeeded];
    CYLSearchController *overlay = [[CYLSearchController alloc] initWithSearchDataSource:source];
    [overlay showInViewController:host];
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.6]];
    [overlay.navigationController.view layoutIfNeeded];
    UIView *overlayBar = CYLVisibleSearchView(overlay.navigationItem.searchController.searchBar);
    XCTAssertNotNil(overlayBar.window, @"the overlay's search bar is shown");
    if (overlayBar.window && !overlayBar.hidden) {
        NSArray *covered = CYLViewsCoveredByView(overlayBar, overlay.navigationController.view);
        XCTAssertEqual(covered.count, 0, @"overlay: %@", covered);
    }
    window.hidden = YES;
}

- (void)testSearchBarViewParityOptions
{
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 375, 56)];
    CYLParityRecorder *recorder = [CYLParityRecorder new];
    bar.delegate = recorder;

    // Navigation button (lapism NavigationIconCompat): hidden by default, shown for an icon, read by VoiceOver.
    [bar layoutIfNeeded];
    XCTAssertTrue(bar.navigationButton.hidden);
    bar.navigationIcon = CYLSearchBarNavigationIconArrow;
    [bar layoutIfNeeded];
    XCTAssertFalse(bar.navigationButton.hidden);
    XCTAssertEqualObjects(bar.navigationButton.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"search.back"]);
    XCTAssertGreaterThan(CGRectGetMinX(bar.fieldView.frame), CGRectGetMaxX(bar.navigationButton.frame) - 8, @"the field starts after the button");
    [bar.navigationButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(recorder.events.lastObject, @"navigation");

    // Voice while empty, submit while there is text (MaterialSearchView showVoice, SearchView isSubmitButtonEnabled).
    bar.showsVoiceButton = YES;
    bar.showsSubmitButton = YES;
    [bar layoutIfNeeded];
    XCTAssertFalse(bar.voiceButton.hidden);
    XCTAssertTrue(bar.submitButton.hidden);
    [bar.voiceButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(recorder.events.lastObject, @"voice");
    bar.text = @"rive";
    [bar layoutIfNeeded];
    XCTAssertTrue(bar.voiceButton.hidden);
    XCTAssertFalse(bar.submitButton.hidden);
    [bar.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(recorder.events.lastObject, @"search rive");

    // setText:submit: and the delegate's veto (setQuery / setTextQuery).
    [bar setText:@"lottie" submit:YES];
    XCTAssertEqualObjects(recorder.events.lastObject, @"search lottie");
    recorder.refuseSubmit = YES;
    XCTAssertFalse([bar submit]);
    recorder.refuseSubmit = NO;
    [bar setText:@"   " submit:YES];
    XCTAssertEqualObjects(recorder.events.lastObject, @"search lottie", @"blank text is never submitted");

    // Keyboard options and the length limit (inputType, imeOptions, maxLength).
    bar.keyboardType = UIKeyboardTypeWebSearch;
    bar.returnKeyType = UIReturnKeyGo;
    XCTAssertEqual(bar.textField.keyboardType, UIKeyboardTypeWebSearch);
    XCTAssertEqual(bar.textField.returnKeyType, UIReturnKeyGo);
    bar.text = @"";
    bar.maximumTextLength = 3;
    XCTAssertTrue([bar.textField.delegate textField:bar.textField shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"abc"]);
    bar.text = @"abc";
    XCTAssertFalse([bar.textField.delegate textField:bar.textField shouldChangeCharactersInRange:NSMakeRange(3, 0) replacementString:@"d"]);
    bar.maximumTextLength = 2;
    XCTAssertEqualObjects(bar.text, @"ab");

    // Clear on cancel (setTextClearOnBackPressed) and a custom clear icon (setCloseIcon / setClearIcon).
    bar.showsCancelButton = YES;
    bar.clearsTextOnCancel = YES;
    [bar.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(bar.text, @"");
    bar.clearImage = [UIImage systemImageNamed:@"xmark"];
    XCTAssertEqual(bar.textField.clearButtonMode, UITextFieldViewModeNever);
    XCTAssertNotNil(bar.textField.rightView);

    // Iconified (SearchView setIconifiedByDefault / isIconified): only the icon button shows.
    bar.iconified = YES;
    [bar layoutIfNeeded];
    XCTAssertTrue(bar.fieldView.hidden);
    XCTAssertFalse(bar.iconButton.hidden);
    XCTAssertTrue(bar.cancelButton.hidden);
    XCTAssertEqualObjects(recorder.events.lastObject, @"iconified");
    XCTAssertEqualObjects(bar.iconButton.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"search.field"]);
    bar.iconPosition = CYLSearchBarIconPositionCenter;
    [bar layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMidX(bar.iconButton.frame), CGRectGetMidX(bar.bounds), 1, @"centered like a floating button");
    [bar setIconified:NO animated:NO];
    XCTAssertFalse(bar.fieldView.hidden);
    XCTAssertTrue(bar.iconButton.hidden);
    XCTAssertEqualObjects(recorder.events.lastObject, @"expanded");

    // State restoration (onSaveInstanceState / onRestoreInstanceState).
    bar.text = @"saved";
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [bar encodeRestorableStateWithCoder:archiver];
    [archiver finishEncoding];
    CYLSearchBarView *restored = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:archiver.encodedData error:NULL];
    unarchiver.requiresSecureCoding = NO;
    [restored decodeRestorableStateWithCoder:unarchiver];
    XCTAssertEqualObjects(restored.text, @"saved");

    // Cursor color (setCursorDrawable) and a bar that opens another page instead of editing (setOnClickListener).
    bar.cursorColor = UIColor.systemPinkColor;
    XCTAssertEqualObjects(bar.textField.tintColor, UIColor.systemPinkColor);
    CYLParityRecorder *button = [CYLParityRecorder new];
    button.refuseEditing = YES;
    bar.delegate = button;
    XCTAssertFalse([bar.textField.delegate textFieldShouldBeginEditing:bar.textField]);
    XCTAssertEqualObjects(button.events.lastObject, @"tapped");
}

- (void)testSearchViewSuggestionsOpenAndClose
{
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 390, 844));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    window.hidden = NO;
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    CYLParityRecorder *recorder = [CYLParityRecorder new];
    searchView.delegate = recorder;
    searchView.animationDuration = 0;
    searchView.suggestions = @[@"Android", @"iOS", @"Café", @"SwiftUI"];
    [searchView installInView:host.view];
    XCTAssertFalse(searchView.isSearchOpen);
    XCTAssertTrue(searchView.hidden);

    // A bar button item opens it (setMenuItem).
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:nil action:nil];
    [searchView attachToBarButtonItem:item];
    XCTAssertEqual(item.target, searchView);
    [UIApplication.sharedApplication sendAction:item.action to:item.target from:item forEvent:nil];
    XCTAssertTrue(searchView.isSearchOpen);
    XCTAssertFalse(searchView.hidden);
    XCTAssertEqualObjects(recorder.events.lastObject, @"shown");

    // Filtering: case- and diacritic-insensitive "contains", nothing for an empty query.
    [searchView setQuery:@"cafe" submit:NO];
    XCTAssertEqualObjects(searchView.filteredSuggestions, @[@"Café"]);
    [searchView setQuery:@"I" submit:NO];
    XCTAssertEqualObjects(searchView.filteredSuggestions, (@[@"Android", @"iOS", @"SwiftUI"]));
    XCTAssertEqual([searchView.suggestionsTableView numberOfRowsInSection:0], 3);
    [searchView setQuery:@"" submit:NO];
    XCTAssertEqual(searchView.filteredSuggestions.count, 0u);
    searchView.showsSuggestionsForEmptyQuery = YES;
    XCTAssertEqual(searchView.filteredSuggestions.count, 4u);
    searchView.suggestionFilter = ^BOOL(NSString *suggestion, NSString *query) { return [suggestion hasPrefix:query]; };
    [searchView setQuery:@"S" submit:NO];
    XCTAssertEqualObjects(searchView.filteredSuggestions, @[@"SwiftUI"]);
    [searchView dismissSuggestions];
    XCTAssertTrue(searchView.suggestionsTableView.hidden);
    [searchView showSuggestions];
    XCTAssertFalse(searchView.suggestionsTableView.hidden);

    // Tapping a suggestion fills the field; submitting closes unless the delegate handles it.
    [searchView.suggestionsTableView.delegate tableView:searchView.suggestionsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(searchView.query, @"SwiftUI");
    XCTAssertTrue([recorder.events containsObject:@"suggestion 0 SwiftUI"]);
    recorder.handleSubmit = YES;
    [searchView setQuery:@"Swift" submit:YES];
    XCTAssertTrue(searchView.isSearchOpen, @"a handled query keeps it open");
    recorder.handleSubmit = NO;
    [searchView setQuery:@"Swift" submit:YES];
    XCTAssertFalse(searchView.isSearchOpen);
    XCTAssertEqualObjects(recorder.events.lastObject, @"closed");

    // Its own page: the bar covers no view of the page, and the page sits above the host.
    searchView.contentView = [[UILabel alloc] init];
    [searchView showSearchAnimated:NO];
    [searchView layoutIfNeeded];
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(searchView.contentView.frame), CGRectGetMaxY(searchView.searchBarView.frame));
    NSArray *covered = CYLViewsCoveredByView(searchView.searchBarView, searchView);
    XCTAssertEqual(covered.count, 0, @"%@", covered);
    XCTAssertTrue(searchView.accessibilityViewIsModal);
    // State restoration (onSaveInstanceState): the query and the open state come back.
    [searchView setQuery:@"kept" submit:NO];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [searchView encodeRestorableStateWithCoder:archiver];
    [archiver finishEncoding];
    [searchView closeSearchAnimated:NO];
    CYLSearchView *restored = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    restored.animationDuration = 0;
    [restored installInView:host.view];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:archiver.encodedData error:NULL];
    unarchiver.requiresSecureCoding = NO;
    [restored decodeRestorableStateWithCoder:unarchiver];
    XCTAssertEqualObjects(restored.query, @"kept");
    XCTAssertTrue(restored.isSearchOpen);
    [restored closeSearchAnimated:NO];
    window.hidden = YES;
}

- (void)testMultiSearchViewFlow
{
    CYLMultiSearchView *multi = [[CYLMultiSearchView alloc] initWithFrame:CGRectMake(0, 0, 375, 56)];
    CYLParityRecorder *recorder = [CYLParityRecorder new];
    multi.delegate = recorder;
    multi.animationDuration = 0;
    XCTAssertFalse(multi.isInSearchMode);

    // A short search is dropped, as in MultiSearchView (3 characters).
    [multi search];
    XCTAssertTrue(multi.isInSearchMode);
    XCTAssertEqual(multi.searchTexts.count, 1u);
    [multi completeSearch];
    XCTAssertEqual(multi.searchTexts.count, 0u);
    XCTAssertEqual(multi.selectedIndex, NSNotFound);

    // Typing reports the index; completing selects the new item.
    [multi search];
    UITextField *field = [[[multi valueForKey:@"items"] lastObject] valueForKey:@"textField"];
    field.text = @"Rive";
    [field sendActionsForControlEvents:UIControlEventEditingChanged];
    XCTAssertEqualObjects(recorder.events.lastObject, @"typed 0 Rive");
    [multi completeSearch];
    XCTAssertEqualObjects(recorder.events.lastObject, @"complete 0 Rive");
    XCTAssertEqual(multi.selectedIndex, 0u);

    [multi addSearchText:@"Lottie"];
    [multi addSearchText:@"PAG"];
    XCTAssertEqualObjects(multi.searchTexts, (@[@"Rive", @"Lottie", @"PAG"]));
    XCTAssertEqual(multi.selectedIndex, 2u);
    [multi selectItemAtIndex:0];
    XCTAssertEqualObjects(recorder.events.lastObject, @"selected 0 Rive");

    // Removing the selected item selects the next one, or the previous one at the end.
    [multi removeItemAtIndex:0];
    XCTAssertEqualObjects(recorder.events.lastObject, @"removed 0");
    XCTAssertEqualObjects(multi.searchTexts, (@[@"Lottie", @"PAG"]));
    XCTAssertEqual(multi.selectedIndex, 0u);
    [multi selectItemAtIndex:1];
    [multi removeItemAtIndex:1];
    XCTAssertEqual(multi.selectedIndex, 0u);

    // The text style (searchTextStyle) and the length limit.
    multi.maximumTextLength = 4;
    [multi search];
    field = [[[multi valueForKey:@"items"] lastObject] valueForKey:@"textField"];
    XCTAssertFalse([field.delegate textField:field shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"12345"]);
    multi.placeholder = @"Category";
    XCTAssertEqualObjects(field.attributedPlaceholder.string, @"Category");
    XCTAssertEqualObjects(multi.searchButton.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"multisearch.add"]);
}

- (void)testSwiftPortsOfOtherLibrariesLoad
{
    // Each Swift port (docs/search-api-comparison.md) opens in a window, and no visible search bar covers a view.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 390, 844));
    window.hidden = NO;
    NSArray<NSString *> *names = @[@"CYLSearchPortsViewController", @"CYLLapismSearchViewController",
                                   @"CYLMaterialSearchMenuViewController", @"CYLYechaoaSearchViewController",
                                   @"CYLRevealSearchViewController", @"CYLMultiSearchDemoViewController"];
    for (NSString *name in names) {
        Class class = NSClassFromString(name);
        XCTAssertNotNil(class, @"%@ is compiled into the app", name);
        UIViewController *controller = [class isSubclassOfClass:UITableViewController.class]
            ? [(UITableViewController *)[class alloc] initWithStyle:UITableViewStyleInsetGrouped] : [class new];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        window.rootViewController = navigation;
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
        [navigation.view layoutIfNeeded];
        XCTAssertNotNil(controller.view.window, @"%@ is shown", name);
        NSMutableArray<UIView *> *bars = [NSMutableArray array];
        NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:controller.view];
        while (queue.count) {
            UIView *view = queue.firstObject;
            [queue removeObjectAtIndex:0];
            if ([view isKindOfClass:CYLSearchBarView.class] || [view isKindOfClass:CYLMultiSearchView.class]) [bars addObject:view];
            [queue addObjectsFromArray:view.subviews];
        }
        for (UIView *bar in bars) {
            BOOL visible = bar.window && !bar.hidden && bar.alpha > 0.01;
            for (UIView *parent = bar.superview; parent && visible; parent = parent.superview) visible = !parent.hidden;
            if (!visible) continue;
            NSArray *covered = CYLViewsCoveredByView(bar, controller.view);
            XCTAssertEqual(covered.count, 0, @"%@: %@", name, covered);
        }
    }
    // The MaterialSearchView samples, one by one.
    Class menuClass = NSClassFromString(@"CYLMaterialSearchMenuViewController");
    UITableViewController *menu = [(UITableViewController *)[menuClass alloc] initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:menu];
    window.rootViewController = navigation;
    [menu loadViewIfNeeded];
    NSInteger samples = [menu tableView:menu.tableView numberOfRowsInSection:0];
    XCTAssertEqual(samples, 6, @"Default, Themed, Voice, Sticky, Tabs, Input type");
    for (NSInteger row = 0; row < samples; row++) {
        [menu tableView:menu.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.4]];
        UIViewController *sample = navigation.topViewController;
        XCTAssertNotEqual(sample, menu, @"row %ld opens a sample", (long)row);
        [sample loadViewIfNeeded];
        CYLSearchView *searchView = (CYLSearchView *)[sample.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", CYLSearchView.class]].firstObject;
        XCTAssertNotNil(searchView, @"row %ld has a search view", (long)row);
        XCTAssertEqual(sample.navigationItem.rightBarButtonItem.target, searchView, @"the search item opens it");
        [navigation popToRootViewControllerAnimated:NO];
    }
    window.hidden = YES;
}

@end
