#import <XCTest/XCTest.h>
#import "CYLSearchExampleViewController.h"
#import "CYLSearchDemoMenuViewController.h"
#import <CYLSearchViewController/CYLSearchController.h>
#import <CYLSearchViewController/CYLSearchResources.h>
#import <CYLSearchViewController/CYLSearchPlaceholderView.h>
#import <CYLSearchViewController/CYLSearchBarView.h>
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
    XCTAssertEqual([menu tableView:menu.tableView numberOfRowsInSection:0], 2);
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
}

@end
