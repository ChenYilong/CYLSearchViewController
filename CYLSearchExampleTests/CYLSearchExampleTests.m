#import <XCTest/XCTest.h>
#import "CYLSearchExample-Swift.h"
#import <CYLTabBarController/CYLTabBarController.h>
#import <CYLAnimatedItem/CYLAnimatedItemView.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#import <CollectionViewClassifyMenu/CollectionViewClassifyMenu-umbrella.h>

@interface CYLSearchItemRecorder : NSObject <CYLSearchBarViewDelegate>
@property (nonatomic, strong) NSMutableArray<CYLSearchBarItem *> *items;
@end

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
 * Records the parity events of CYLSearchBarView (one field and several searches) and CYLSearchView, and refuses
 * submissions while `refuseSubmit` is YES.
 */
@interface CYLParityRecorder : NSObject <CYLSearchBarViewDelegate, CYLSearchViewDelegate>
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
- (void)searchBarView:(CYLSearchBarView *)view textDidChange:(NSString *)text atIndex:(NSInteger)index { [self.events addObject:[NSString stringWithFormat:@"typed %ld %@", (long)index, text]]; }
- (void)searchBarView:(CYLSearchBarView *)view didCompleteSearch:(NSString *)text atIndex:(NSInteger)index { [self.events addObject:[NSString stringWithFormat:@"complete %ld %@", (long)index, text]]; }
- (void)searchBarView:(CYLSearchBarView *)view didRemoveSearchAtIndex:(NSInteger)index { [self.events addObject:[NSString stringWithFormat:@"removed %ld", (long)index]]; }
- (void)searchBarView:(CYLSearchBarView *)view didSelectSearch:(NSString *)text atIndex:(NSInteger)index { [self.events addObject:[NSString stringWithFormat:@"selected %ld %@", (long)index, text]]; }
@end

/*!
 * Results for CYLSearchView: @[@42] for an empty query (the Issue #1317 page lists everything then), @[@42, @7] for
 * "4", nothing for any other query. Also the delegate that records the selected result.
 */
@interface CYLSearchNumberDataSource : NSObject <CYLSearchViewDataSource, CYLSearchViewDelegate>
@property (nonatomic, strong) id selectedResult;
@property (nonatomic, assign) NSUInteger queryCount;
@end

@implementation CYLSearchNumberDataSource

- (NSArray *)searchView:(CYLSearchView *)searchView resultsForQuery:(NSString *)query
{
    self.queryCount++;
    if (query.length == 0) return @[@42];
    return [query isEqualToString:@"4"] ? @[@42, @7] : @[];
}

- (void)searchView:(CYLSearchView *)searchView configureResultCell:(UITableViewCell *)cell withResult:(id)result
{
    cell.textLabel.text = [result description];
}

- (void)searchView:(CYLSearchView *)searchView didSelectResult:(id)result
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
 * The text fields of the searches of a bar in CYLSearchBarModeMultiple, in order (the bar's own field excluded).
 */
static NSArray<UITextField *> *CYLSearchFields(CYLSearchBarView *bar)
{
    NSMutableArray<UITextField *> *fields = [NSMutableArray array];
    __block void (^visit)(UIView *);
    __block __weak void (^weakVisit)(UIView *);
    weakVisit = visit = ^(UIView *view) {
        if ([view isKindOfClass:UITextField.class] && view != bar.textField) [fields addObject:(UITextField *)view];
        for (UIView *subview in view.subviews) weakVisit(subview);
    };
    visit(bar);
    visit = nil;
    return fields;
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

- (void)setUp
{
    [super setUp];
    // The suggestion cache persists by design (a local database, docs/core-todo.md): every test starts from an empty
    // default cache and an empty example cache, so a query submitted by one test never shows in another.
    for (NSString *name in @[@"CYLSearchView", @"MaterialSearchView"]) {
        CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
        searchView.suggestionCacheName = name;
        [searchView.suggestionCache removeAllQueries];
    }
}

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
    [controller reloadResults];
    XCTAssertEqual(controller.searchResults.count, 0);
    NSPredicate *placeholder = [NSPredicate predicateWithBlock:^BOOL(UIView *view, NSDictionary *bindings) {
        return [view.accessibilityIdentifier isEqualToString:@"CYLSearchEmptyState"];
    }];
    XCTAssertEqual([controller.tableView.subviews filteredArrayUsingPredicate:placeholder].count, 1);
    controller.searchController.searchBar.text = @"";
    [controller reloadResults];
    XCTAssertEqual([controller.tableView.subviews filteredArrayUsingPredicate:placeholder].count, 0);

    UIBarButtonItem *toggle = controller.navigationItem.rightBarButtonItem;
    [UIApplication.sharedApplication sendAction:toggle.action to:toggle.target from:toggle forEvent:nil];
    XCTAssertTrue(controller.navigationItem.hidesSearchBarWhenScrolling);
    XCTAssertEqualObjects(toggle.title, [CYLSearchResources localizedStringForKey:@"repro.on"]);
    XCTAssertTrue(controller.overlaySearchView.resultsDataSource == source, @"the overlay searches the same data");
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
    // The empty states themselves are CYLTableViewPlaceHolder's CYLPlaceholderView (the former CYLSearchPlaceholderView).
    NSArray<NSNumber *> *styles = @[@(CYLPlaceholderStyleEmpty), @(CYLPlaceholderStyleNoResults), @(CYLPlaceholderStyleError)];
    NSArray<NSNumber *> *messages = @[@(CYLPlaceholderMessageEmpty), @(CYLPlaceholderMessageNoResults), @(CYLPlaceholderMessageError)];
    for (NSUInteger index = 0; index < styles.count; index++) {
        CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:styles[index].integerValue message:messages[index].integerValue];
        XCTAssertNotNil(view.imageView.image);
        XCTAssertGreaterThan(view.textLabel.text.length, 0);
    }
}

- (void)testIndependentPlaceholderStylesAndMessages
{
    // CYLTableViewPlaceHolder's CYLPlaceholderView: every style has its own image, every message its own text.
    NSArray<NSNumber *> *messages = @[@(CYLPlaceholderMessageEmpty), @(CYLPlaceholderMessageNoResults),
                                      @(CYLPlaceholderMessageNoInternet), @(CYLPlaceholderMessageError)];
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    for (NSInteger style = 0; style < CYLPlaceholderStyleCount; style++) {
        NSString *name = [CYLPlaceholderView imageNameForStyle:style];
        XCTAssertNotNil(name);
        XCTAssertFalse([names containsObject:name]);
        [names addObject:name];
        XCTAssertNotNil([CYLPlaceholderView imageForStyle:style], @"%@", name);
        for (NSNumber *message in messages) {
            CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:style message:message.integerValue];
            XCTAssertNotNil(view.imageView.image);
            XCTAssertEqualObjects(view.textLabel.text, [CYLPlaceholderView localizedTextForMessage:message.integerValue]);
        }
    }
    UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
    CYLPlaceholderView *both = [[CYLPlaceholderView alloc] initWithImage:image text:@"Custom"];
    XCTAssertEqual(both.imageView.image, image);
    XCTAssertEqualObjects(both.textLabel.text, @"Custom");
    XCTAssertEqualObjects([[[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleError text:@"Custom"] textLabel].text, @"Custom");
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
    XCTAssertEqual([menu tableView:menu.tableView numberOfRowsInSection:0], 6, @"reproduction, styles, search bar, ports of other libraries, the SVGA tab bar in SwiftUI, contact tags");
    [menu tableView:menu.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewController *gallery = (UITableViewController *)navigation.lastPushedController;
    XCTAssertNotEqual(gallery, menu);
    [gallery loadViewIfNeeded];
    XCTAssertEqual([gallery numberOfSectionsInTableView:gallery.tableView], CYLPlaceholderStyleCount + 1);
    for (NSInteger section = 0; section <= CYLPlaceholderStyleCount; section++) {
        NSInteger count = [gallery tableView:gallery.tableView numberOfRowsInSection:section];
        XCTAssertEqual(count, section == CYLPlaceholderStyleCount ? 3 : 4);
        for (NSInteger row = 0; row < count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [gallery tableView:gallery.tableView didSelectRowAtIndexPath:indexPath];
            UIViewController *detail = navigation.lastPushedController;
            XCTAssertNotEqual(detail, gallery);
            XCTAssertTrue([detail.view.subviews.firstObject isKindOfClass:CYLPlaceholderView.class]);
            [navigation popViewControllerAnimated:NO];
        }
    }
}

- (void)testSearchViewShowsResultsOfItsDataSource
{
    // docs/search-core-merge.md, "Results behavior": with a results data source and a query, resultsTableView lists the
    // results instead of the suggestions; reloadResults asks again; no result shows the empty-results placeholder.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    CYLSearchNumberDataSource *source = [CYLSearchNumberDataSource new];
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicyNone;
    searchView.animationDuration = 0;
    searchView.suggestions = @[@"42 apples", @"Kotlin"];
    searchView.resultsDataSource = source;
    searchView.delegate = source;
    [searchView showSearchInViewController:host animated:NO];
    XCTAssertTrue(searchView.superview == host.view);
    XCTAssertTrue(searchView.isSearchOpen);
    XCTAssertTrue(searchView.resultsTableView.hidden, @"an empty query shows the suggestions, not the results");
    XCTAssertEqual(searchView.searchResults.count, 0u);

    [searchView setQuery:@"4" submit:NO];
    [searchView layoutIfNeeded];
    XCTAssertFalse(searchView.resultsTableView.hidden);
    XCTAssertTrue(searchView.suggestionsTableView.hidden, @"the results replace the suggestions");
    XCTAssertEqualObjects(searchView.searchResults, (@[@42, @7]));
    XCTAssertEqual([searchView.resultsTableView numberOfRowsInSection:0], 2);
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(searchView.resultsTableView.frame), CGRectGetMaxY(searchView.searchBarView.frame));
    NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [searchView tableView:searchView.resultsTableView cellForRowAtIndexPath:first];
    XCTAssertEqualObjects(cell.textLabel.text, @"42");
    [searchView tableView:searchView.resultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    XCTAssertEqualObjects(source.selectedResult, @7);

    NSUInteger queries = source.queryCount;
    [searchView reloadResults];
    XCTAssertEqual(source.queryCount, queries + 1, @"reloadResults asks the data source again");

    searchView.showsEmptyResultsPlaceholder = YES;
    [searchView setQuery:@"zzz" submit:NO];
    [searchView layoutIfNeeded];
    XCTAssertEqual(searchView.searchResults.count, 0u);
    XCTAssertNotNil(searchView.emptyResultsView);
    XCTAssertFalse(searchView.emptyResultsView.hidden, @"no result shows the placeholder");
    [searchView setQuery:@"4" submit:NO];
    XCTAssertTrue(searchView.emptyResultsView.hidden);

    // Focus alone changes nothing below the search bar.
    NSArray *before = @[@(searchView.resultsTableView.hidden), searchView.searchResults];
    [searchView.searchBarView.textField becomeFirstResponder];
    [searchView.searchBarView.textField resignFirstResponder];
    XCTAssertEqualObjects((@[@(searchView.resultsTableView.hidden), searchView.searchResults]), before);

    // Without a data source the suggestions come back.
    searchView.resultsDataSource = nil;
    [searchView setQuery:@"Kot" submit:NO];
    XCTAssertTrue(searchView.resultsTableView.hidden);
    XCTAssertEqualObjects(searchView.filteredSuggestions, @[@"Kotlin"]);

    XCTestExpectation *closed = [self expectationWithDescription:@"closeSearchAnimated:completion: calls back"];
    [searchView closeSearchAnimated:NO completion:^{
        XCTAssertFalse(searchView.isSearchOpen);
        [closed fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTestExpectation *already = [self expectationWithDescription:@"An already closed search calls back at once"];
    [searchView closeSearchAnimated:YES completion:^{ [already fulfill]; }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    window.hidden = YES;
}

- (void)testSearchViewRefreshWrapsThePullToRefresh
{
    // The only refresh API of the core: refreshHandler on resultsTableView, and the class methods for another table.
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    XCTAssertNil(searchView.resultsTableView.cyl_header, @"no pull-to-refresh by default");
    XCTAssertFalse(searchView.isRefreshing);
    __block NSUInteger calls = 0;
    searchView.refreshHandler = ^{ calls++; };
    XCTAssertNotNil(searchView.resultsTableView.cyl_header, @"a handler installs the header");
    XCTAssertTrue([searchView.resultsTableView.cyl_header isKindOfClass:CYLRefreshNormalHeader.class]);
    searchView.resultsTableView.cyl_header.refreshingBlock();
    XCTAssertEqual(calls, 1u, @"the header calls the handler");
    [searchView beginRefreshing];
    XCTAssertTrue(searchView.isRefreshing);
    [searchView endRefreshing];
    // The header may hold its result for its finishDuration before it is idle again.
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return !searchView.isRefreshing;
    }] evaluatedWithObject:searchView handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    searchView.refreshHandler = nil;
    XCTAssertNil(searchView.resultsTableView.cyl_header, @"nil removes the header");

    // The class methods on a table of the app (the Issue #1317 page).
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 390, 600) style:UITableViewStylePlain];
    __block NSUInteger tableCalls = 0;
    [CYLSearchView setRefreshHandler:^{ tableCalls++; } forScrollView:table];
    XCTAssertNotNil(table.cyl_header);
    table.cyl_header.refreshingBlock();
    XCTAssertEqual(tableCalls, 1u);
    [CYLSearchView beginRefreshingInScrollView:table];
    XCTAssertTrue([CYLSearchView isRefreshingInScrollView:table]);
    [CYLSearchView endRefreshingInScrollView:table];
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return ![CYLSearchView isRefreshingInScrollView:table];
    }] evaluatedWithObject:table handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    [CYLSearchView setRefreshHandler:nil forScrollView:table];
    XCTAssertNil(table.cyl_header);
    XCTAssertFalse([CYLSearchView isRefreshingInScrollView:table], @"no header: not refreshing");
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

- (void)testOverlayOpensACYLSearchViewWithTheSameData
{
    // "Overlay" of the Issue #1317 page (was CYLSearchController): a CYLSearchView over the navigation controller.
    CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
    CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    [controller loadViewIfNeeded];
    CYLSearchView *overlay = controller.overlaySearchView;
    CYLParityRecorder *recorder = [CYLParityRecorder new];
    overlay.delegate = recorder;
    overlay.animationDuration = 0;
    UIBarButtonItem *open = controller.navigationItem.leftBarButtonItem;
    [UIApplication.sharedApplication sendAction:open.action to:open.target from:open forEvent:nil];
    XCTAssertTrue(overlay.isSearchOpen);
    XCTAssertTrue(overlay.superview == navigation.view);
    [overlay setQuery:@"1" submit:NO];
    XCTAssertGreaterThan(overlay.searchResults.count, 0u);
    XCTAssertFalse(overlay.resultsTableView.hidden);
    [overlay.searchBarView.navigationButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertFalse(overlay.isSearchOpen, @"the back arrow closes it");
    XCTAssertEqualObjects(recorder.events.lastObject, @"closed");
    window.hidden = YES;
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
    // Search, Examples, the plus page, Tag style and Discover (docs/tag-view-suggestions.md).
    XCTAssertEqual(pages.count, 5);
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
        XCTAssertTrue([titles containsObject:@"Tag style"], @"%@", titles);
        XCTAssertTrue([titles containsObject:@"Discover"], @"%@", titles);
        XCTAssertEqualObjects(CYLExternPlusButton.accessibilityLabel, @"Search bar");
    }
    // Every language has exactly the keys of en (the tab titles, then the SVGA demo's texts), not a fixed count.
    NSString *(^tablePath)(NSString *) = ^NSString *(NSString *code) {
        return [NSBundle.mainBundle pathForResource:@"CYLSearchTabs" ofType:@"strings" inDirectory:[NSString stringWithFormat:@"CYLSearchTabs.bundle/%@.lproj", code]];
    };
    NSDictionary *english = [NSDictionary dictionaryWithContentsOfFile:tablePath(@"en")];
    XCTAssertNotNil(english[@"tab.search"]);
    for (NSString *code in @[@"en", @"zh-Hans", @"zh-Hant", @"ja"]) {
        NSString *path = tablePath(code);
        NSDictionary *table = path ? [NSDictionary dictionaryWithContentsOfFile:path] : nil;
        XCTAssertEqualObjects([NSSet setWithArray:table.allKeys], [NSSet setWithArray:english.allKeys], @"%@ has every key", code);
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

    // CYLSearchBarView of the discover page (the "Discover" tab, copied from CollectionViewClassifyMenu), which draws
    // it in place of the navigation bar.
    UIViewController *discover = [CYLSuggestionDemoPages discoverViewController];
    navigation = [[UINavigationController alloc] initWithRootViewController:discover];
    window.rootViewController = navigation;
    for (UIContentSizeCategory size in sizes) {
        if (@available(iOS 17.0, *)) {
            window.traitOverrides.preferredContentSizeCategory = size;
        }
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        [navigation.view setNeedsLayout];
        [navigation.view layoutIfNeeded];
        CYLSearchBarView *bar = (CYLSearchBarView *)[discover.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", CYLSearchBarView.class]].firstObject;
        XCTAssertNotNil(bar.window);
        NSArray *covered = CYLViewsCoveredByView(bar, nil);
        XCTAssertEqual(covered.count, 0, @"discover at %@: %@", size, covered);
    }
    if (@available(iOS 17.0, *)) {
        window.traitOverrides.preferredContentSizeCategory = UIContentSizeCategoryLarge;
    }

    // The overlay (a CYLSearchView over the results page's navigation controller) is a page of its own: inside that
    // page its search bar covers no view, with results shown.
    results = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    navigation = [[UINavigationController alloc] initWithRootViewController:results];
    window.rootViewController = navigation;
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    [window layoutIfNeeded];
    CYLSearchView *overlay = results.overlaySearchView;
    overlay.animationDuration = 0;
    [overlay showSearchInViewController:navigation animated:NO];
    [overlay setQuery:@"1" submit:NO];
    [overlay layoutIfNeeded];
    XCTAssertNotNil(overlay.searchBarView.window, @"the overlay's search bar is shown");
    NSArray *overlayCovered = CYLViewsCoveredByView(overlay.searchBarView, overlay);
    XCTAssertEqual(overlayCovered.count, 0, @"overlay: %@", overlayCovered);
    [overlay closeSearchAnimated:NO];

    // A CYLSearchBarView in CYLSearchBarModeMultiple, with searches.
    CYLSearchBarView *multi = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
    multi.mode = CYLSearchBarModeMultiple;
    UIViewController *multiHost = [UIViewController new];
    multiHost.edgesForExtendedLayout = UIRectEdgeNone;
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:multiHost];
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    multi.frame = CGRectMake(8, 16, CGRectGetWidth(multiHost.view.bounds) - 16, multi.intrinsicContentSize.height);
    [multiHost.view addSubview:multi];
    [multi addSearch:@"Rive"];
    [multi addSearch:@"Lottie"];
    [multi layoutIfNeeded];
    NSArray *multiCovered = CYLViewsCoveredByView(multi, nil);
    XCTAssertEqual(multiCovered.count, 0, @"multiple searches: %@", multiCovered);
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

- (void)testSearchBarViewMultipleModeFlow
{
    // CYLSearchBarModeMultiple (was CYLMultiSearchView, iammert MultiSearchView): add, type, complete, select and
    // remove searches, each reported to the bar's delegate.
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 375, 56)];
    CYLParityRecorder *recorder = [CYLParityRecorder new];
    bar.delegate = recorder;
    bar.animationDuration = 0;
    XCTAssertEqual(bar.mode, CYLSearchBarModeSingle);
    [bar beginNewSearch];
    XCTAssertFalse(bar.isEditingNewSearch, @"nothing happens in the single mode");
    [bar addSearch:@"ignored"];
    XCTAssertEqual(bar.searches.count, 0u);

    bar.mode = CYLSearchBarModeMultiple;
    [bar layoutIfNeeded];
    XCTAssertTrue(bar.fieldView.hidden, @"the single field is hidden");
    XCTAssertFalse(bar.newSearchButton.hidden);
    XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, 56);
    XCTAssertFalse(bar.isEditingNewSearch);
    XCTAssertEqual(bar.selectedSearchIndex, NSNotFound);

    // A short search is dropped, as in MultiSearchView (3 characters).
    [bar beginNewSearch];
    XCTAssertTrue(bar.isEditingNewSearch);
    XCTAssertEqual(bar.searches.count, 1u);
    [bar completeSearch];
    XCTAssertEqual(bar.searches.count, 0u);
    XCTAssertEqual(bar.selectedSearchIndex, NSNotFound);
    XCTAssertFalse([recorder.events.lastObject hasPrefix:@"complete"], @"a dropped search is not reported");

    // Typing reports the index; completing selects the new search.
    [bar beginNewSearch];
    UITextField *field = CYLSearchFields(bar).lastObject;
    XCTAssertNotNil(field);
    field.text = @"Rive";
    [field sendActionsForControlEvents:UIControlEventEditingChanged];
    XCTAssertEqualObjects(recorder.events.lastObject, @"typed 0 Rive");
    [bar completeSearch];
    XCTAssertEqualObjects(recorder.events.lastObject, @"complete 0 Rive");
    XCTAssertEqual(bar.selectedSearchIndex, 0);

    [bar addSearch:@"Lottie"];
    [bar addSearch:@"PAG"];
    XCTAssertEqualObjects(bar.searches, (@[@"Rive", @"Lottie", @"PAG"]));
    XCTAssertEqual(bar.selectedSearchIndex, 2);
    [bar selectSearchAtIndex:0];
    XCTAssertEqualObjects(recorder.events.lastObject, @"selected 0 Rive");
    XCTAssertEqual(bar.selectedSearchIndex, 0);

    // Removing the selected search selects the next one, or the previous one at the end.
    [bar removeSearchAtIndex:0];
    XCTAssertEqualObjects(recorder.events.lastObject, @"removed 0");
    XCTAssertEqualObjects(bar.searches, (@[@"Lottie", @"PAG"]));
    XCTAssertEqual(bar.selectedSearchIndex, 0);
    [bar selectSearchAtIndex:1];
    [bar removeSearchAtIndex:1];
    XCTAssertEqual(bar.selectedSearchIndex, 0);
    [bar removeSearchAtIndex:7];
    XCTAssertEqual(bar.searches.count, 1u, @"an index out of range is ignored");

    // The bar's text style and length limit apply to the searches.
    bar.maximumTextLength = 4;
    [bar beginNewSearch];
    field = CYLSearchFields(bar).lastObject;
    XCTAssertFalse([field.delegate textField:field shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"12345"]);
    bar.placeholder = @"Category";
    XCTAssertEqualObjects(field.attributedPlaceholder.string, @"Category");
    XCTAssertEqualObjects(bar.newSearchButton.accessibilityLabel, [CYLSearchResources localizedStringForKey:@"multisearch.add"]);
    [bar.newSearchButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertFalse(bar.isEditingNewSearch, @"the button completes the search being typed");

    // Back to one field.
    bar.mode = CYLSearchBarModeSingle;
    [bar layoutIfNeeded];
    XCTAssertFalse(bar.fieldView.hidden);
    XCTAssertTrue(bar.newSearchButton.superview.hidden);
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
            if ([view isKindOfClass:CYLSearchBarView.class]) [bars addObject:view];
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
        // The search item opens the search in place of the navigation bar (docs/search-api-comparison.md, "Default"):
        // the navigation bar hides, the search bar takes its place, and the bar comes back when the search closes.
        UIBarButtonItem *item = sample.navigationItem.rightBarButtonItem;
        XCTAssertEqual(item.target, sample, @"the search item opens the search");
        [UIApplication.sharedApplication sendAction:item.action to:item.target from:item forEvent:nil];
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        XCTAssertTrue(searchView.isSearchOpen, @"row %ld opens the search", (long)row);
        XCTAssertTrue(navigation.navigationBarHidden, @"row %ld: the search bar takes the navigation bar's place", (long)row);
        [searchView closeSearchAnimated:NO];
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        XCTAssertFalse(navigation.navigationBarHidden, @"row %ld: the navigation bar comes back", (long)row);
        [navigation popToRootViewControllerAnimated:NO];
    }
    window.hidden = YES;
}

- (void)testEmptyResultsShowTheCYLTableViewPlaceHolderPlaceholder
{
    // docs/sub-repositories.md: a query that matches no suggestion shows CYLTableViewPlaceHolder's placeholder, in both
    // suggestion styles, only when showsEmptyResultsPlaceholder is on.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    searchView.suggestions = @[@"Android", @"Kotlin", @"Swift"];
    [searchView installInView:host.view];
    [searchView showSearchAnimated:NO];
    [searchView setQuery:@"zzz" submit:NO];
    XCTAssertNil(searchView.emptyResultsView, @"off by default");
    searchView.showsEmptyResultsPlaceholder = YES;
    for (NSNumber *style in @[@(CYLSearchSuggestionStyleList), @(CYLSearchSuggestionStyleTags)]) {
        searchView.suggestionStyle = style.integerValue;
        [searchView setQuery:@"zzz" submit:NO];
        [searchView layoutIfNeeded];
        XCTAssertNotNil(searchView.emptyResultsView, @"style %@", style);
        XCTAssertFalse(searchView.emptyResultsView.hidden, @"no match shows the placeholder, style %@", style);
        XCTAssertEqual(searchView.emptyResultsView.scenario, CYLPlaceholderScenarioNoSearchResults);
        XCTAssertGreaterThan(CGRectGetHeight(searchView.emptyResultsView.frame), 0);
        [searchView setQuery:@"swi" submit:NO];
        XCTAssertTrue(searchView.emptyResultsView.hidden, @"a match hides it, style %@", style);
        [searchView setQuery:@"" submit:NO];
        XCTAssertTrue(searchView.emptyResultsView.hidden, @"an empty query hides it, style %@", style);
    }
    searchView.emptyResultsScenario = CYLPlaceholderScenarioNoContent;
    [searchView setQuery:@"zzz" submit:NO];
    XCTAssertEqual(searchView.emptyResultsView.scenario, CYLPlaceholderScenarioNoContent, @"the scenario is a parameter");
    window.hidden = YES;
}

- (void)testEmptyResultsPlaceholderStaysAboveTheKeyboard
{
    // docs/core-todo.md, "the empty-results placeholder sits under the keyboard": the placeholders take the same bottom
    // keyboard inset as the lists, so a placeholder centres in the part of the page the keyboard leaves visible.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    searchView.suggestions = @[@"Android", @"Kotlin", @"Swift"];
    searchView.showsEmptyResultsPlaceholder = YES;
    [searchView installInView:host.view];
    [searchView showSearchAnimated:NO];
    [searchView setQuery:@"zzz" submit:NO];
    [searchView layoutIfNeeded];
    CGFloat fullHeight = CGRectGetHeight(searchView.emptyResultsView.frame);
    CGRect keyboard = CGRectMake(0, 874 - 336, 402, 336);
    CGRect screenKeyboard = [window convertRect:keyboard toCoordinateSpace:window.screen.coordinateSpace];
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillChangeFrameNotification object:nil
                                                    userInfo:@{UIKeyboardFrameEndUserInfoKey: [NSValue valueWithCGRect:screenKeyboard]}];
    [searchView layoutIfNeeded];
    CGRect placeholder = [searchView.emptyResultsView convertRect:searchView.emptyResultsView.bounds toView:window];
    XCTAssertLessThanOrEqual(CGRectGetMaxY(placeholder), CGRectGetMinY(keyboard) + 0.5, @"the placeholder ends at the keyboard");
    XCTAssertLessThan(CGRectGetHeight(searchView.emptyResultsView.frame), fullHeight);
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillHideNotification object:nil userInfo:nil];
    [searchView layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(searchView.emptyResultsView.frame), fullHeight, 0.5, @"the keyboard gone, full height again");
    window.hidden = YES;
}

- (void)testContactTagsDemoSearchesCreatesAndKeepsItsStrings
{
    // Edits are saved in the demo's cache: start from the bundled data.
    [NSClassFromString(@"CYLContactTagsDemo") performSelector:@selector(resetCache)];
    [self addTeardownBlock:^{ [NSClassFromString(@"CYLContactTagsDemo") performSelector:@selector(resetCache)]; }];
    // docs/CYLTabBarController-Integration.md, "the contact tags example": the Examples row opens Edit Remarks; its
    // editor searches with CYLSearchBarView ("ios" finds "iOS ..." and offers "+ New tag: ios"), creates and selects a
    // tag; the bundle has the same tags and strings in every language.
    Class demo = NSClassFromString(@"CYLContactTagsDemo");
    XCTAssertNotNil(demo);
    NSString *title = [demo performSelector:@selector(rowTitle)];
    XCTAssertFalse([title hasPrefix:@"contactTags."], @"the row title is localized: %@", title);
    UIViewController *remark = [demo performSelector:@selector(viewController)];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:remark];
    [window makeKeyAndVisible];
    [remark.view layoutIfNeeded];
    id editor = [remark performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor view] layoutIfNeeded];
    BOOL hasSearchBar = NO;
    for (UIView *subview in [editor view].subviews) {
        hasSearchBar = hasSearchBar || [subview isKindOfClass:CYLSearchBarView.class];
    }
    XCTAssertTrue(hasSearchBar, @"the editor searches with CYLSearchBarView");
    NSInteger sections = [editor numberOfSectionsInMenu];
    XCTAssertEqual(sections, 2, @"Recent and My Tags");
    NSInteger mine = [editor menuNumberOfItemsInSection:1];
    [editor performSelector:@selector(setQuery:) withObject:@"ios"];
    XCTAssertEqual([editor numberOfSectionsInMenu], 1, @"Search Results");
    NSInteger results = [editor menuNumberOfItemsInSection:0];
    XCTAssertGreaterThanOrEqual(results, 2, @"a match and the create item");
    NSString *first = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertTrue([first.lowercaseString containsString:@"ios"], @"%@", first);
    XCTAssertEqual([editor menuItemTypeAtIndexPath:[NSIndexPath indexPathForItem:results - 1 inSection:0]], CYLMenuItemTypeCreate);
    [editor performSelector:@selector(createTagNamed:) withObject:@"Swift Search"];
    XCTAssertEqual([editor numberOfSectionsInMenu], 2, @"creating leaves the search");
    XCTAssertEqual([editor menuNumberOfItemsInSection:1], mine + 1, @"the new tag is in My Tags");
    NSBundle *bundle = [NSBundle bundleWithURL:[NSBundle.mainBundle URLForResource:@"CYLContactTags" withExtension:@"bundle"]];
    NSSet *keys = nil;
    for (NSString *language in @[@"en", @"ja", @"zh-Hans", @"zh-Hant"]) {
        NSString *lproj = [bundle pathForResource:language ofType:@"lproj"];
        NSDictionary *strings = [NSDictionary dictionaryWithContentsOfFile:[lproj stringByAppendingPathComponent:@"CYLContactTags.strings"]];
        NSData *json = [NSData dataWithContentsOfFile:[lproj stringByAppendingPathComponent:@"contact-tags.json"]];
        NSDictionary *data = json ? [NSJSONSerialization JSONObjectWithData:json options:0 error:nil] : nil;
        XCTAssertEqual([data[@"tags"] count], 47u, @"%@", language);
        XCTAssertGreaterThan(strings.count, 0u, @"%@", language);
        if (keys) XCTAssertEqualObjects([NSSet setWithArray:strings.allKeys], keys, @"same keys in %@", language);
        keys = [NSSet setWithArray:strings.allKeys];
    }
    [remark dismissViewControllerAnimated:NO completion:nil];
    window.hidden = YES;
}

- (void)testContactTagsDemoShowsCYLPlaceholderViewWhenEmpty
{
    // Edits are saved in the demo's cache: start from the bundled data.
    [NSClassFromString(@"CYLContactTagsDemo") performSelector:@selector(resetCache)];
    [self addTeardownBlock:^{ [NSClassFromString(@"CYLContactTagsDemo") performSelector:@selector(resetCache)]; }];
    // docs/CYLTabBarController-Integration.md, "CYLPlaceholderView in the contact tags example": a search without a
    // match and an empty tag list show CYLTableViewPlaceHolder's placeholder; a match or a tag hides it.
    UIViewController *remark = [NSClassFromString(@"CYLContactTagsDemo") performSelector:@selector(viewController)];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:remark];
    [window makeKeyAndVisible];
    [remark.view layoutIfNeeded];
    id editor = [remark performSelector:@selector(editTagsAnimated:) withObject:@NO];
    UIView *editorView = [editor view];
    [editorView layoutIfNeeded];
    UIView *(^placeholder)(void) = ^UIView * {
        NSMutableArray<UIView *> *views = [NSMutableArray arrayWithObject:editorView];
        while (views.count) {
            UIView *view = views.firstObject;
            [views removeObjectAtIndex:0];
            if ([view.accessibilityIdentifier isEqualToString:@"CYLContactTagsPlaceholder"] && !view.superview.hidden) return view;
            [views addObjectsFromArray:view.subviews];
        }
        return nil;
    };
    XCTAssertNil(placeholder(), @"tags shown: no placeholder");
    [editor performSelector:@selector(setQuery:) withObject:@"zzzz"];
    [editorView layoutIfNeeded];
    UIView *noMatch = placeholder();
    XCTAssertTrue([noMatch isKindOfClass:CYLPlaceholderView.class], @"no match shows CYLPlaceholderView");
    XCTAssertEqual([editor menuNumberOfItemsInSection:0], 1, @"+ New tag: zzzz stays above it");
    XCTAssertGreaterThan(CGRectGetHeight(noMatch.frame), 0);
    [editor performSelector:@selector(setQuery:) withObject:@"ios"];
    XCTAssertNil(placeholder(), @"a match hides it");
    [editor performSelector:@selector(setQuery:) withObject:@""];
    NSInteger mine = [editor numberOfSectionsInMenu] - 1;
    while ([editor menuNumberOfItemsInSection:mine] > 1) {
        NSString *tag = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]];
        [editor performSelector:@selector(deleteTag:) withObject:tag];
        mine = [editor numberOfSectionsInMenu] - 1;
    }
    [editorView layoutIfNeeded];
    XCTAssertTrue([placeholder() isKindOfClass:CYLPlaceholderView.class], @"no tags shows CYLPlaceholderView");
    [editor performSelector:@selector(createTagNamed:) withObject:@"Family"];
    XCTAssertNil(placeholder(), @"a new tag hides it");
    [remark dismissViewControllerAnimated:NO completion:nil];
    // Edit Remarks: a contact without tags shows the placeholder below "Tags"; tags hide it.
    UIView *(^remarkPlaceholder)(void) = ^UIView * {
        for (UIView *view in remark.view.subviews) {
            if ([view.accessibilityIdentifier isEqualToString:@"CYLContactRemarkEmptyTags"] && !view.hidden) return view;
        }
        return nil;
    };
    XCTAssertNil(remarkPlaceholder(), @"the demo contact has tags");
    [remark performSelector:@selector(updateTags:) withObject:@[]];
    [remark.view layoutIfNeeded];
    UIView *emptyTags = remarkPlaceholder();
    XCTAssertTrue([emptyTags isKindOfClass:CYLPlaceholderView.class], @"no tags shows CYLPlaceholderView");
    XCTAssertGreaterThan(CGRectGetHeight(emptyTags.frame), 0);
    XCTAssertTrue(emptyTags.accessibilityTraits & UIAccessibilityTraitButton, @"VoiceOver: it opens the editor");
    [remark performSelector:@selector(updateTags:) withObject:@[@"Family"]];
    XCTAssertNil(remarkPlaceholder(), @"a tag hides it");
    window.hidden = YES;
}

- (void)testContactTagsManageEditsInPlaceSavesAndOpensContacts
{
    // docs/CYLTabBarController-Integration.md, "editing in the contact tags example": Manage switches CollectionViewClassifyMenu's
    // tag list into editing mode in place (delete buttons, dragging, the add control); a drag is saved and comes back
    // when the screen opens again; a tag opens its contacts, and a tag nobody has shows CYLTableViewPlaceHolder's
    // placeholder there.
    Class demo = NSClassFromString(@"CYLContactTagsDemo");
    [demo performSelector:@selector(resetCache)];
    [self addTeardownBlock:^{ [demo performSelector:@selector(resetCache)]; }];
    UIViewController *remark = [demo performSelector:@selector(viewController)];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:remark];
    [window makeKeyAndVisible];
    [remark.view layoutIfNeeded];
    id editor = [remark performSelector:@selector(editTagsAnimated:) withObject:@NO];
    UIView *editorView = [editor view];
    [editorView layoutIfNeeded];
    XCTAssertNotNil([editor navigationController], @"the editor can push the contacts page");
    NSInteger mine = [editor numberOfSectionsInMenu] - 1;
    NSInteger items = [editor menuNumberOfItemsInSection:mine];
    XCTAssertEqual([editor menuItemTypeAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:mine]], CYLMenuItemTypeCreate);
    XCTAssertFalse([[editor valueForKey:@"isManaging"] boolValue]);

    [editor performSelector:@selector(toggleManaging)];
    XCTAssertTrue([[editor valueForKey:@"isManaging"] boolValue], @"Manage enters the list's editing mode");
    XCTAssertEqual([editor numberOfSectionsInMenu] - 1, mine, @"no page change: the same sections");
    XCTAssertEqual([editor menuNumberOfItemsInSection:mine], items - 1, @"the editing bar replaces + New Tag");
    CYLSearchBarView *editingBar = [editor valueForKey:@"editingBar"];
    XCTAssertTrue(editingBar.isEditingBar);
    XCTAssertFalse(editingBar.hidden, @"Manage shows the editing bar above the keyboard");
    XCTAssertTrue([editor menuSectionAllowsEditing:mine]);
    XCTAssertFalse(mine > 0 && [editor menuSectionAllowsEditing:0], @"Recent does not take part");
    [editorView layoutIfNeeded];
    BOOL addControl = NO;
    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithObject:editorView];
    while (views.count) {
        UIView *view = views.firstObject;
        [views removeObjectAtIndex:0];
        addControl = addControl || [NSStringFromClass(view.class) hasSuffix:@"CYLTagListAddItemView"];
        [views addObjectsFromArray:view.subviews];
    }
    XCTAssertFalse(addControl, @"the list's own field gives way to the editing bar");

    NSString *first = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]];
    NSString *second = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:mine]];
    [editor menuMoveItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine] toIndexPath:[NSIndexPath indexPathForItem:1 inSection:mine]];
    XCTAssertEqualObjects([editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]], second);

    UIViewController *contacts = [editor performSelector:@selector(showContactsWithTag:) withObject:first];
    [contacts.view layoutIfNeeded];
    XCTAssertTrue([NSStringFromClass(contacts.class) hasSuffix:@"CYLContactListViewController"], @"%@", contacts.class);
    XCTAssertGreaterThan([(UITableViewController *)contacts tableView:[(UITableViewController *)contacts tableView] numberOfRowsInSection:0], 0, @"%@ has contacts", first);
    [editor performSelector:@selector(createTagNamed:) withObject:@"Nobody Yet"];
    UITableViewController *empty = (UITableViewController *)[editor performSelector:@selector(showContactsWithTag:) withObject:@"Nobody Yet"];
    [empty.view layoutIfNeeded];
    BOOL placeholder = NO;
    for (UIView *view in empty.tableView.subviews) {
        placeholder = placeholder || [view isKindOfClass:CYLPlaceholderView.class];
        for (UIView *inner in view.subviews) placeholder = placeholder || [inner.accessibilityIdentifier isEqualToString:@"CYLContactListEmpty"];
        placeholder = placeholder || [view.accessibilityIdentifier isEqualToString:@"CYLContactListEmpty"];
    }
    XCTAssertEqual([empty tableView:empty.tableView numberOfRowsInSection:0], 0);
    XCTAssertTrue(placeholder, @"a tag without contacts shows CYLTableViewPlaceHolder's placeholder");
    [remark dismissViewControllerAnimated:NO completion:nil];

    // Opened again, as after a relaunch: the saved order and the new tag come back.
    UIViewController *again = [demo performSelector:@selector(viewController)];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:again];
    [again.view layoutIfNeeded];
    id editor2 = [again performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor2 view] layoutIfNeeded];
    NSInteger mine2 = [editor2 numberOfSectionsInMenu] - 1;
    XCTAssertEqualObjects([editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine2]], second, @"the drag was saved");
    XCTAssertEqualObjects([editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:mine2]], first);
    NSInteger count2 = [editor2 menuNumberOfItemsInSection:mine2];
    XCTAssertEqualObjects([editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:count2 - 2 inSection:mine2]], @"Nobody Yet", @"the new tag was saved");
    [again dismissViewControllerAnimated:NO completion:nil];
    window.hidden = YES;
}

- (void)testContactTagsUploadSyncAndLoadTheServerCopy
{
    // docs/CYLTabBarController-Integration.md, "network sync in the contact tags example": leaving Manage uploads cache A
    // to the simulated server (cache B); Sync simulates another device (a new tag, the first two swapped) and pulls it;
    // opening again shows the server's data after the cache (CollectionViewClassifyMenu's cache-then-network default).
    Class demo = NSClassFromString(@"CYLContactTagsDemo");
    [demo performSelector:@selector(resetCache)];
    [NSUserDefaults.standardUserDefaults setDouble:0 forKey:@"CYLContactTagsServerLatency"];
    [self addTeardownBlock:^{
        [demo performSelector:@selector(resetCache)];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@"CYLContactTagsServerLatency"];
    }];
    void (^spin)(void) = ^{
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    };
    // The upload and the sync finish on the main queue a moment later (the HUD's zero latency); a slow runner needs more
    // than a fixed wait, so poll for the result (up to 15 s).
    BOOL (^waitUntil)(BOOL (^)(void)) = ^BOOL(BOOL (^condition)(void)) {
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15];
        while (!condition() && [deadline timeIntervalSinceNow] > 0) {
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        return condition();
    };
    UIViewController *remark = [demo performSelector:@selector(viewController)];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:remark];
    [window makeKeyAndVisible];
    [remark.view layoutIfNeeded];
    id editor = [remark performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor view] layoutIfNeeded];
    spin();
    NSInteger mine = [editor numberOfSectionsInMenu] - 1;
    NSString *first = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]];
    NSString *second = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:mine]];
    NSString *third = [editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:mine]];

    [editor performSelector:@selector(toggleManaging)];
    [editor menuMoveItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:mine] toIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]];
    [editor performSelector:@selector(toggleManaging)];
    CYLTagListStore *serverCopy = [[CYLTagListStore alloc] initWithPolicy:CYLTagListCachePolicySandboxFile name:@"CYLContactTagsServer"];
    waitUntil(^BOOL{
        NSArray<NSString *> *titles = [serverCopy cachedTitlesForSection:@"mine"];
        return titles.count >= 3 && [titles.firstObject isEqualToString:third];
    });
    NSArray<NSString *> *uploaded = [serverCopy cachedTitlesForSection:@"mine"];
    XCTAssertGreaterThanOrEqual(uploaded.count, 3u, @"the upload reached B");
    XCTAssertEqualObjects([uploaded subarrayWithRange:NSMakeRange(0, MIN((NSUInteger)3, uploaded.count))], (@[third, first, second]), @"leaving Manage uploads the new order to B");

    NSInteger count = [editor menuNumberOfItemsInSection:mine];
    [editor performSelector:@selector(syncFromOtherDevices)];
    waitUntil(^BOOL{ return [editor menuNumberOfItemsInSection:mine] == count + 1; });
    XCTAssertEqual([editor menuNumberOfItemsInSection:mine], count + 1, @"another device added a tag");
    XCTAssertEqualObjects([editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine]], first, @"and swapped the first two");
    XCTAssertEqualObjects([editor menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:mine]], third);
    [remark dismissViewControllerAnimated:NO completion:nil];

    // The server changes again behind this device's back; opening shows cache A, then B.
    NSMutableArray<CYLTagListCacheItem *> *serverItems = [[serverCopy cachedItemsForSection:@"mine"] mutableCopy];
    [serverItems exchangeObjectAtIndex:0 withObjectAtIndex:2];
    [serverCopy saveItems:serverItems forSection:@"mine"];
    NSArray<NSString *> *server = [serverItems valueForKey:@"title"];
    UIViewController *again = [demo performSelector:@selector(viewController)];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:again];
    [again.view layoutIfNeeded];
    id editor2 = [again performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor2 view] layoutIfNeeded];
    spin();
    waitUntil(^BOOL{
        NSInteger section = [editor2 numberOfSectionsInMenu] - 1;
        return [[editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]] isEqualToString:server[0]];
    });
    NSInteger mine2 = [editor2 numberOfSectionsInMenu] - 1;
    XCTAssertEqualObjects([editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine2]], server[0], @"the server's data replaces the cache");
    CYLTagListStore *local = [[CYLTagListStore alloc] initWithPolicy:CYLTagListCachePolicyDatabase name:@"CYLContactTags"];
    XCTAssertEqualObjects([local cachedTitlesForSection:@"mine"], server, @"and is saved to cache A");
    [again dismissViewControllerAnimated:NO completion:nil];
    window.hidden = YES;
}

- (void)testContactTagsRenameKeepsTheTagIDAndItsContacts
{
    // docs/CYLTabBarController-Integration.md, "renaming in the contact tags example": in Manage, the pencil renames a
    // tag; its id (the primary key) stays, so its contacts stay; the new name is saved to cache A, uploaded to the server
    // (cache B) when Manage ends, and shown again after reopening.
    Class demo = NSClassFromString(@"CYLContactTagsDemo");
    [demo performSelector:@selector(resetCache)];
    [NSUserDefaults.standardUserDefaults setDouble:0 forKey:@"CYLContactTagsServerLatency"];
    [self addTeardownBlock:^{
        [demo performSelector:@selector(resetCache)];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@"CYLContactTagsServerLatency"];
    }];
    void (^spin)(void) = ^{
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    };
    // The upload and the sync finish on the main queue a moment later (the HUD's zero latency); a slow runner needs more
    // than a fixed wait, so poll for the result (up to 15 s).
    BOOL (^waitUntil)(BOOL (^)(void)) = ^BOOL(BOOL (^condition)(void)) {
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15];
        while (!condition() && [deadline timeIntervalSinceNow] > 0) {
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        return condition();
    };
    UIViewController *remark = [demo performSelector:@selector(viewController)];
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:remark];
    [window makeKeyAndVisible];
    [remark.view layoutIfNeeded];
    id editor = [remark performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor view] layoutIfNeeded];
    spin();
    NSInteger mine = [editor numberOfSectionsInMenu] - 1;
    NSIndexPath *first = [NSIndexPath indexPathForItem:0 inSection:mine];
    NSString *tagID = [editor menuIdentifierForItemAtIndexPath:first];
    XCTAssertEqualObjects(tagID, @"t01", @"tags are keyed by id");
    UITableViewController *before = (UITableViewController *)[editor performSelector:@selector(showContactsWithTag:) withObject:tagID];
    NSInteger contacts = [before tableView:before.tableView numberOfRowsInSection:0];
    XCTAssertGreaterThan(contacts, 0);

    [editor performSelector:@selector(toggleManaging)];
    [editor performSelector:@selector(renameTagWithID:toTitle:) withObject:tagID withObject:@"Home Folks"];
    XCTAssertEqualObjects([editor menuTitleForItemAtIndexPath:first], @"Home Folks", @"renamed in place");
    XCTAssertEqualObjects([editor menuIdentifierForItemAtIndexPath:first], tagID, @"the id stays");
    UITableViewController *after = (UITableViewController *)[editor performSelector:@selector(showContactsWithTag:) withObject:tagID];
    XCTAssertEqual([after tableView:after.tableView numberOfRowsInSection:0], contacts, @"the contacts are bound to the id");
    XCTAssertTrue([after.title hasPrefix:@"Home Folks"], @"%@", after.title);
    CYLTagListStore *local = [[CYLTagListStore alloc] initWithPolicy:CYLTagListCachePolicyDatabase name:@"CYLContactTags"];
    CYLTagListCacheItem *saved = [local cachedItemsForSection:@"mine"].firstObject;
    XCTAssertEqualObjects(saved.identifier, tagID, @"cache A keeps the id");
    XCTAssertEqualObjects(saved.title, @"Home Folks", @"with the new name");

    [editor performSelector:@selector(toggleManaging)];
    CYLTagListStore *serverCopy = [[CYLTagListStore alloc] initWithPolicy:CYLTagListCachePolicySandboxFile name:@"CYLContactTagsServer"];
    waitUntil(^BOOL{ return [serverCopy cachedItemsForSection:@"mine"].firstObject != nil; });
    XCTAssertEqualObjects([serverCopy cachedItemsForSection:@"mine"].firstObject, saved, @"leaving Manage uploads it to B");
    [remark dismissViewControllerAnimated:NO completion:nil];

    UIViewController *again = [demo performSelector:@selector(viewController)];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:again];
    [again.view layoutIfNeeded];
    id editor2 = [again performSelector:@selector(editTagsAnimated:) withObject:@NO];
    [[editor2 view] layoutIfNeeded];
    spin();
    NSInteger mine2 = [editor2 numberOfSectionsInMenu] - 1;
    XCTAssertEqualObjects([editor2 menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:mine2]], @"Home Folks", @"the name comes back");
    [again dismissViewControllerAnimated:NO completion:nil];
    window.hidden = YES;
}

- (void)testEditingBarSubmitsAndRidesOnTheKeyboard
{
    // docs/core-todo.md, "the editing bar": the search bar's look as an edit field; its action button and the return key
    // submit; pinToKeyboardInView: ties it to the keyboard's top.
    CYLSearchBarView *bar = [CYLSearchBarView editingBarWithPlaceholder:@"Tag name" actionTitle:@"Add"];
    XCTAssertTrue(bar.isEditingBar);
    XCTAssertNil(bar.searchIcon, @"no magnifier");
    XCTAssertTrue(bar.showsCancelButton);
    XCTAssertEqualObjects(bar.cancelButtonTitle, @"Add", @"the trailing button is the action");
    XCTAssertEqualObjects(bar.placeholder, @"Tag name");
    __block NSString *submitted = nil;
    bar.editingSubmitHandler = ^(CYLSearchBarView *view, NSString *text) { submitted = text; };
    bar.text = @"   ";
    [bar.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertNil(submitted, @"empty text submits nothing");
    bar.text = @"  Book Club ";
    [bar.cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(submitted, @"Book Club", @"the action button submits the trimmed text");
    submitted = nil;
    bar.text = @"Hiking";
    XCTAssertFalse([bar textFieldShouldReturn:bar.textField]);
    XCTAssertEqualObjects(submitted, @"Hiking", @"so does the return key");

    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    [bar pinToKeyboardInView:host.view];
    [host.view layoutIfNeeded];
    XCTAssertEqual(bar.superview, host.view);
    BOOL pinned = NO;
    for (NSLayoutConstraint *constraint in host.view.constraints) {
        pinned = pinned || (constraint.firstItem == bar && constraint.firstAttribute == NSLayoutAttributeBottom
                            && constraint.secondItem == host.view.keyboardLayoutGuide && constraint.secondAttribute == NSLayoutAttributeTop);
    }
    XCTAssertTrue(pinned, @"the bar's bottom is the keyboard's top");
    XCTAssertEqualWithAccuracy(CGRectGetMaxY(bar.frame), CGRectGetMaxY(host.view.safeAreaLayoutGuide.layoutFrame), 0.5,
                               @"with the keyboard down, at the bottom of the safe area");
    window.hidden = YES;
}

- (void)testEverySuggestionCachePolicyKeepsSubmittedQueriesNewestFirst
{
    // docs/core-todo.md: each policy stores the queries newest first, moves a repeated query to the front, keeps at most
    // maximumCount and clears everything; separate names keep separate caches.
    // The built-in store is internal: a search view makes it from its policy and name.
    id<CYLSearchSuggestionCache> (^makeCache)(CYLSearchSuggestionCachePolicy, NSString *) = ^id<CYLSearchSuggestionCache>(CYLSearchSuggestionCachePolicy policy, NSString *name) {
        CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
        searchView.suggestionCachePolicy = policy;
        searchView.suggestionCacheName = name;
        return searchView.suggestionCache;
    };
    for (NSNumber *policy in @[@(CYLSearchSuggestionCachePolicyDatabase), @(CYLSearchSuggestionCachePolicyUserDefaults),
                               @(CYLSearchSuggestionCachePolicySandboxFile)]) {
        id<CYLSearchSuggestionCache> cache = makeCache(policy.integerValue, @"CYLTestCache");
        id<CYLSearchSuggestionCache> other = makeCache(policy.integerValue, @"CYLTestOther");
        [cache removeAllQueries];
        [other removeAllQueries];
        [(NSObject *)cache setValue:@3 forKey:@"maximumCount"];
        [cache addQuery:@"Swift"];
        [cache addQuery:@"Kotlin"];
        [cache addQuery:@"  "];
        [cache addQuery:@"Swift"];
        XCTAssertEqualObjects([cache cachedQueries], (@[@"Swift", @"Kotlin"]), @"policy %@", policy);
        [cache addQuery:@"Dart"];
        [cache addQuery:@"Rust"];
        XCTAssertEqualObjects([cache cachedQueries], (@[@"Rust", @"Dart", @"Swift"]), @"the oldest goes, policy %@", policy);
        XCTAssertEqualObjects([other cachedQueries], @[], @"names are separate, policy %@", policy);
        id<CYLSearchSuggestionCache> reopened = makeCache(policy.integerValue, @"CYLTestCache");
        XCTAssertEqualObjects([reopened cachedQueries], (@[@"Rust", @"Dart", @"Swift"]), @"persisted, policy %@", policy);
        [cache removeQuery:@"Dart"];
        XCTAssertEqualObjects([cache cachedQueries], (@[@"Rust", @"Swift"]), @"policy %@", policy);
        [cache removeAllQueries];
        XCTAssertEqualObjects([cache cachedQueries], @[], @"policy %@", policy);
    }
    XCTAssertNil(makeCache(CYLSearchSuggestionCachePolicyNone, @"CYLTestCache"));
}

- (void)testTheSearchViewCachesSubmittedQueriesAndClearsThemFromTheHeader
{
    // docs/core-todo.md: a submitted query is cached; an empty query lists the cache under a header whose delete button
    // clears it; an empty cache shows CYLTableViewPlaceHolder's placeholder.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    XCTAssertEqual(searchView.suggestionCachePolicy, CYLSearchSuggestionCachePolicyDatabase, @"a local database by default");
    searchView.suggestionCacheName = @"CYLTestSearchView";
    [searchView.suggestionCache removeAllQueries];
    searchView.suggestions = @[@"Android", @"Kotlin", @"Swift"];
    searchView.closesOnSubmit = NO;
    [searchView installInView:host.view];
    [searchView showSearchAnimated:NO];
    [searchView layoutIfNeeded];
    XCTAssertFalse(searchView.emptySuggestionsView.hidden, @"an empty cache shows the placeholder");
    XCTAssertTrue(searchView.suggestionCacheHeaderView.hidden);
    [searchView setQuery:@"Flutter" submit:YES];
    [searchView setQuery:@"Kotlin" submit:YES];
    [searchView setQuery:@"" submit:NO];
    [searchView layoutIfNeeded];
    XCTAssertEqualObjects(searchView.filteredSuggestions, (@[@"Kotlin", @"Flutter"]), @"the cache, newest first");
    XCTAssertFalse(searchView.suggestionCacheHeaderView.hidden, @"with its header");
    XCTAssertTrue(searchView.emptySuggestionsView.hidden);
    XCTAssertGreaterThan(CGRectGetHeight(searchView.suggestionCacheHeaderView.frame), 0);
    // 0.01: on a 3x screen the two edges are the same third of a point, apart by float rounding ("iPhone Duo").
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(searchView.suggestionsTableView.frame), CGRectGetMaxY(searchView.suggestionCacheHeaderView.frame) - 0.01,
                                @"the list starts under the header");
    [searchView setQuery:@"t" submit:NO];
    XCTAssertEqualObjects(searchView.filteredSuggestions, (@[@"Kotlin", @"Flutter", @"Swift"]), @"cached matches first, no repeats");
    [searchView setQuery:@"" submit:NO];
    [searchView.clearSuggestionCacheButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects([searchView.suggestionCache cachedQueries], @[]);
    XCTAssertFalse(searchView.emptySuggestionsView.hidden, @"cleared: the placeholder again");
    CYLSearchView *again = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    again.suggestionCacheName = @"CYLTestSearchView";
    [again.suggestionCache addQuery:@"Rust"];
    searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicyDatabase;
    [searchView setQuery:@"" submit:NO];
    XCTAssertEqualObjects(searchView.filteredSuggestions, @[@"Rust"], @"another view with the same name shares the cache");
    [again.suggestionCache removeAllQueries];
    searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicyNone;
    XCTAssertNil(searchView.suggestionCache);
    window.hidden = YES;
}

- (void)testFocusesSearchFieldOnShowDecidesWhenTheKeyboardAppears
{
    // docs/core-todo.md: YES (default) focuses the field when the search opens; NO leaves it unfocused until tapped.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    for (NSNumber *focuses in @[@YES, @NO]) {
        CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
        XCTAssertTrue(searchView.focusesSearchFieldOnShow, @"YES by default");
        searchView.focusesSearchFieldOnShow = focuses.boolValue;
        searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicyNone;
        [searchView installInView:host.view];
        [searchView showSearchAnimated:NO];
        XCTAssertEqual(searchView.searchBarView.textField.isFirstResponder, focuses.boolValue, @"focusesSearchFieldOnShow %@", focuses);
        [searchView closeSearchAnimated:NO];
        [searchView removeFromSuperview];
    }
    window.hidden = YES;
}

- (void)testFocusAloneChangesNothingBelowTheSearchBar
{
    // docs/core-todo.md, core behavior rule 1: focusing the field without typing, and losing focus, leave the list,
    // its header and the empty placeholder exactly as they were.
    UIWindow *window = CYLTestWindow(CGRectMake(0, 0, 402, 874));
    UIViewController *host = [UIViewController new];
    window.rootViewController = host;
    [window makeKeyAndVisible];
    for (NSArray<NSString *> *cached in @[@[@"Kotlin", @"Swift"], @[]]) {
        CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
        searchView.suggestionCacheName = @"CYLTestFocus";
        [searchView.suggestionCache removeAllQueries];
        for (NSString *query in cached.reverseObjectEnumerator) {
            [searchView.suggestionCache addQuery:query];
        }
        searchView.suggestions = @[@"Android", @"Kotlin", @"Swift"];
        searchView.focusesSearchFieldOnShow = NO;
        [searchView installInView:host.view];
        [searchView showSearchAnimated:NO];
        [searchView layoutIfNeeded];
        NSArray *(^snapshot)(void) = ^NSArray * {
            return @[searchView.filteredSuggestions, @(searchView.suggestionCacheHeaderView.hidden),
                     @(searchView.emptySuggestionsView == nil || searchView.emptySuggestionsView.hidden),
                     @(searchView.suggestionsTableView.hidden), NSStringFromCGRect(searchView.suggestionsTableView.frame)];
        };
        NSArray *before = snapshot();
        XCTAssertFalse(searchView.searchBarView.textField.isFirstResponder);
        [searchView.searchBarView.textField becomeFirstResponder];
        [searchView layoutIfNeeded];
        XCTAssertTrue(searchView.searchBarView.textField.isFirstResponder);
        XCTAssertEqualObjects(snapshot(), before, @"focus alone, cache %@", cached);
        [searchView.searchBarView.textField resignFirstResponder];
        [searchView layoutIfNeeded];
        XCTAssertEqualObjects(snapshot(), before, @"blur alone, cache %@", cached);
        [searchView.suggestionCache removeAllQueries];
        [searchView closeSearchAnimated:NO];
        [searchView removeFromSuperview];
    }
    window.hidden = YES;
}

- (void)testTagSuggestionsEndWithTheFoldButtonByDefault
{
    // docs/tag-view-suggestions.md, BUG TODO: the tag suggestions fold to two rows behind an inline chevron, and both
    // are parameters.
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectZero];
    XCTAssertEqual(searchView.suggestionsFoldControl.position, CYLMenuFoldControlPositionTail);
    XCTAssertEqual(searchView.suggestionsFoldControl.content, CYLMenuFoldControlContentIcon);
    XCTAssertEqual(searchView.suggestionsFoldedRowCount, 2u);
    XCTAssertEqual(searchView.suggestionsTagView.defaultVisibleRows, 2);
    searchView.suggestionsFoldControl = [[CYLMenuFoldControl alloc] initWithPosition:CYLMenuFoldControlPositionFooter content:CYLMenuFoldControlContentTitle];
    searchView.suggestionsFoldedRowCount = 3;
    XCTAssertEqual(searchView.suggestionsFoldControl.position, CYLMenuFoldControlPositionFooter);
    XCTAssertEqual(searchView.suggestionsTagView.defaultVisibleRows, 3);
}


- (void)testSearchBarItemsFollowTheAnimatedItemDisplayPriority
{
    // The items' CYLTagButton is CYLTabBarController's CYLAnimatedItemView (docs/animated-icon-component.md; guide:
    // https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md): a
    // file that cannot play (here an unknown type) shows the static image, the component's placeholder only without
    // one, and a text item never grows an icon.
    NSURL *unknown = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"cyl-bar-item.unknown-type"]];
    [@"not an animation" writeToURL:unknown atomically:YES encoding:NSUTF8StringEncoding error:nil];
    UIImage *image = [UIImage systemImageNamed:@"camera"];
    CYLSearchBarItem *withImage = [[CYLSearchBarItem alloc] initWithStyle:CYLSearchBarItemStyleIcon title:@"Camera" image:image];
    withImage.animationURL = unknown;
    CYLTagButton *withImageView = withImage.itemView;
    withImageView.frame = CGRectMake(0, 0, 36, 36);
    [withImageView layoutIfNeeded];
    XCTAssertNil(withImageView.animationView);
    XCTAssertTrue(withImageView.imageView.image == image, @"The static image wins over the placeholder");
    XCTAssertFalse(withImageView.imageView.hidden);
    XCTAssertEqualObjects(withImageView.accessibilityLabel, @"Camera");

    CYLSearchBarItem *withoutImage = [[CYLSearchBarItem alloc] initWithStyle:CYLSearchBarItemStyleIcon title:@"Camera" image:nil];
    withoutImage.animationURL = unknown;
    CYLTagButton *withoutImageView = withoutImage.itemView;
    withoutImageView.frame = CGRectMake(0, 0, 36, 36);
    [withoutImageView layoutIfNeeded];
    if (CYLAnimatedItemView.defaultPlaceholderImage) {
        XCTAssertNotNil(withoutImageView.imageView.image, @"No static image: the component's placeholder");
        XCTAssertEqualWithAccuracy(CGRectGetWidth(withoutImageView.imageView.bounds), 20, 0.5, @"Sized like the item's icon");
    }
    [withoutImageView playAnimation];

    CYLSearchBarItem *text = [CYLSearchBarItem textItemWithTitle:@"Search" handler:nil];
    CYLTagButton *textView = text.itemView;
    [textView layoutIfNeeded];
    XCTAssertNil(textView.imageView.image, @"A text item without an icon shows no placeholder");
}

- (void)testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems
{
    // docs/search-bar-view.md, "Mimicking the tab bar's FlatDesign item-appending API": the field stays, the camera,
    // a divider and the Search button are items appended after the text.
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 390, 56)];
    CYLSearchItemRecorder *recorder = [[CYLSearchItemRecorder alloc] init];
    bar.delegate = recorder;
    __block NSInteger cameraTaps = 0;
    CYLSearchBarItem *camera = [CYLSearchBarItem iconItemWithImage:[UIImage systemImageNamed:@"camera"] title:@"Camera" handler:^(CYLSearchBarItem *item) {
        cameraTaps += 1;
    }];
    CYLSearchBarItem *divider = [CYLSearchBarItem dividerItem];
    CYLSearchBarItem *search = [CYLSearchBarItem textItemWithTitle:@"Search" handler:nil];
    XCTAssertEqual(camera.index, NSNotFound);
    XCTAssertFalse([bar hasItemOfStyle:CYLSearchBarItemStyleText]);
    [bar addItem:camera];
    [bar addItem:search];
    [bar insertItem:divider atIndex:1];
    XCTAssertEqualObjects(bar.items, (@[camera, divider, search]));
    XCTAssertEqual(search.index, 2);
    XCTAssertTrue(camera.searchBarView == bar);
    XCTAssertTrue([bar hasItemOfStyle:CYLSearchBarItemStyleText]);
    XCTAssertEqual(bar.itemViews.count, 3u);
    XCTAssertTrue(camera.itemView.superview == bar.fieldView);
    XCTAssertTrue([camera.itemView valueForKey:@"item"] == camera);
    XCTAssertTrue([camera actualBadgeSuperView] == camera.itemView);

    // Layout: in order after the text, inside the field, a 36 pt camera, a 1 pt divider skipped by VoiceOver.
    [bar layoutIfNeeded];
    CGRect cameraFrame = camera.itemView.frame;
    CGRect dividerFrame = divider.itemView.frame;
    CGRect searchFrame = search.itemView.frame;
    XCTAssertLessThanOrEqual(CGRectGetMaxX(bar.textField.frame), CGRectGetMinX(cameraFrame) + 0.5);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(cameraFrame), CGRectGetMinX(dividerFrame) + 0.5);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(dividerFrame), CGRectGetMinX(searchFrame) + 0.5);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(searchFrame), CGRectGetWidth(bar.fieldView.bounds) + 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(cameraFrame), 36, 0.5);
    XCTAssertFalse(divider.itemView.isAccessibilityElement);
    XCTAssertTrue(camera.itemView.isAccessibilityElement);
    XCTAssertEqualObjects(camera.itemView.accessibilityLabel, @"Camera");
    XCTAssertEqualObjects(((UILabel *)[search.itemView valueForKey:@"titleLabel"]).text, @"Search");

    // Each item is drawn by CollectionViewClassifyMenu's CYLTagButton: the item's title, icon, badge and animated icon.
    XCTAssertTrue([camera.itemView isKindOfClass:[CYLTagButton class]]);
    XCTAssertTrue([search.itemView isKindOfClass:[CYLTagButton class]]);
    XCTAssertEqualObjects(search.itemView.title, @"Search");
    XCTAssertNil(camera.itemView.title);
    XCTAssertTrue(camera.itemView.image == camera.image);
    camera.badgeValue = @"5";
    camera.badgeColor = UIColor.systemOrangeColor;
    XCTAssertEqualObjects(camera.itemView.badgeValue, @"5");
    XCTAssertEqualObjects(camera.itemView.badgeColor, UIColor.systemOrangeColor);
    XCTAssertEqualObjects(camera.itemView.accessibilityValue, @"5");
    camera.badgeValue = nil;
    camera.badgeColor = nil;
    NSURL *animationURL = [NSURL fileURLWithPath:@"/nonexistent/CYLSearchBarItemIcon.json"];
    camera.animationURL = animationURL;
    XCTAssertEqualObjects(camera.itemView.animationURL, animationURL);
    camera.animationURL = nil;
    XCTAssertNil(camera.itemView.animationURL);

    // Events: the delegate first, then the handler; a disabled item ignores taps; a selectable item toggles.
    [camera.itemView sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(cameraTaps, 1);
    XCTAssertEqualObjects(recorder.items, (@[camera]));
    camera.isEnabled = NO;
    [camera.itemView sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(cameraTaps, 1);
    camera.isEnabled = YES;
    camera.isSelectable = YES;
    XCTAssertNil(bar.selectedItem);
    XCTAssertEqual(bar.selectedIndex, NSNotFound);
    [camera.itemView sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertTrue(camera.isSelected);
    XCTAssertTrue(bar.selectedItem == camera);
    XCTAssertEqual(bar.selectedIndex, 0);

    // Badge, text attributes and tint.
    camera.badgeValue = @"3";
    [camera.itemView layoutIfNeeded];
    UILabel *badge = [camera.itemView valueForKey:@"badgeLabel"];
    XCTAssertFalse(badge.hidden);
    XCTAssertEqualObjects(badge.text, @"3");
    camera.badgeValue = nil;
    XCTAssertTrue(badge.hidden);
    [search setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.systemBlueColor} forState:UIControlStateNormal];
    XCTAssertEqualObjects([search titleTextAttributesForState:UIControlStateNormal][NSForegroundColorAttributeName], UIColor.systemBlueColor);
    bar.itemTintColor = UIColor.systemGreenColor;
    XCTAssertEqualObjects(((UIImageView *)[camera.itemView valueForKey:@"imageView"]).tintColor, UIColor.systemGreenColor);

    // The fixed bordered style, and removal.
    bar.searchBarStyle = CYLSearchBarStyleBordered;
    XCTAssertEqual(bar.fieldBorderWidth, 1);
    XCTAssertNotNil(bar.fieldBorderColor);
    [bar removeItem:divider];
    XCTAssertEqualObjects(bar.items, (@[camera, search]));
    XCTAssertNil(divider.searchBarView);
    XCTAssertNil(divider.itemView.superview);
    [bar addItemWithStyle:CYLSearchBarItemStyleDivider title:nil image:nil index:1 handler:nil];
    XCTAssertEqual(bar.items[1].style, CYLSearchBarItemStyleDivider);
    [bar removeAllItems];
    XCTAssertEqual(bar.items.count, 0u);

    // Plain values from the cross-platform wrappers (Flutter, React Native).
    CYLSearchBarItem *wrapped = [CYLSearchBarItem itemWithDictionary:@{@"style": @"icon", @"title": @"Camera", @"image": @"camera", @"accessibilityIdentifier": @"camera", @"isSelectable": @YES, @"badgeValue": @""}];
    XCTAssertEqual(wrapped.style, CYLSearchBarItemStyleIcon);
    XCTAssertNotNil(wrapped.image);
    XCTAssertEqualObjects(wrapped.itemAccessibilityIdentifier, @"camera");
    XCTAssertTrue(wrapped.isSelectable);
    XCTAssertEqualObjects(wrapped.badgeValue, @"");
    XCTAssertEqual([CYLSearchBarItem itemWithDictionary:@{@"style": @"divider"}].style, CYLSearchBarItemStyleDivider);
    CYLSearchBarItem *wrappedText = [CYLSearchBarItem itemWithDictionary:@{@"style": @"text", @"title": @"Search"}];
    XCTAssertEqual(wrappedText.style, CYLSearchBarItemStyleText);
}

@end

@implementation CYLSearchItemRecorder

- (void)searchBarView:(CYLSearchBarView *)searchBarView didSelectItem:(CYLSearchBarItem *)item
{
    if (!self.items) {
        self.items = [NSMutableArray array];
    }
    [self.items addObject:item];
}

@end
