//
//  CYLSearchCoreObjectiveCSmokeTests.m
//  CYLSearchExampleTests
//
//  The Objective-C smoke test of the Swift core's public API (docs/swift-migration.md, step 4): the example's tests
//  are Swift; this file keeps checking that Objective-C callers see the core through its generated header.
//

#import <XCTest/XCTest.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>

/*!
 * Calls the core's main types from Objective-C: CYLSearchBarView, CYLSearchView and CYLSearchResources.
 */
@interface CYLSearchCoreObjectiveCSmokeTests : XCTestCase
@end

@implementation CYLSearchCoreObjectiveCSmokeTests

- (void)testSearchBarViewFromObjectiveC
{
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    bar.placeholder = @"Search";
    bar.text = @"IDG";
    bar.showsCancelButton = YES;
    bar.cancelButtonTitle = @"Cancel";
    bar.fieldBackgroundColor = UIColor.secondarySystemBackgroundColor;
    bar.navigationIcon = CYLSearchBarNavigationIconNone;
    [bar layoutIfNeeded];
    XCTAssertEqualObjects(bar.text, @"IDG");
    XCTAssertEqualObjects(bar.placeholder, @"Search");
    XCTAssertNotNil(bar.textField);
    XCTAssertFalse(bar.cancelButton.hidden);
    XCTAssertGreaterThan([bar sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)].height, 0);
}

- (void)testSearchViewFromObjectiveC
{
    CYLSearchView *searchView = [[CYLSearchView alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    searchView.suggestionCacheName = @"CYLSearchCoreObjectiveCSmokeTests";
    searchView.suggestions = @[@"Swift", @"Objective-C"];
    searchView.showsSuggestionCacheHeader = NO;
    [searchView clearSuggestionCache];
    searchView.searchBarView.text = @"Swift";
    [searchView searchBarView:searchView.searchBarView textDidChange:@"Swift"];
    XCTAssertEqual([searchView.suggestionsTableView numberOfRowsInSection:0], 1);
    [searchView searchBarViewSearchButtonClicked:searchView.searchBarView];
    XCTAssertEqualObjects(searchView.suggestionCache.cachedQueries.firstObject, @"Swift");
    [searchView clearSuggestionCache];
    XCTAssertEqual(searchView.suggestionCache.cachedQueries.count, 0u);
}

- (void)testResourcesFromObjectiveC
{
    XCTAssertGreaterThan([CYLSearchResources localizedStringForKey:@"search.cancel"].length, 0u);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.cancel" language:@"zh-Hans"], @"取消");
}

@end
