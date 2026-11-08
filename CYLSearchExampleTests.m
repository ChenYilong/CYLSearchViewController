#import <XCTest/XCTest.h>
#import "CYLSearchExampleViewController.h"
#import <CYLSearchViewController/CYLSearchController.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLSearchExampleTests : XCTestCase
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
    XCTAssertEqualObjects(toggle.title, @"Repro: ON");
    [UIApplication.sharedApplication sendAction:toggle.action to:toggle.target from:toggle forEvent:nil];
    XCTAssertFalse(controller.navigationItem.hidesSearchBarWhenScrolling);
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

@end
