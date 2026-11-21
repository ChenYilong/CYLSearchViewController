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

/*!
 * CYLSearchBar and CYLSearchBarAppearance are visible from Objective-C with the names of the design
 * (docs/qmui-search-controller.md): properties, blocks, accessory methods and the two class methods; the Cancel button is
 * cyl_cancelButton (UISearchBar answers cancelButton itself).
 */
- (void)testSearchBarFromObjectiveC
{
    XCTAssertEqualObjects(NSStringFromClass(CYLSearchBar.class), @"CYLSearchBar");
    XCTAssertEqualObjects(NSStringFromClass(CYLSearchBarAppearance.class), @"CYLSearchBarAppearance");
    XCTAssertTrue([CYLSearchBar.class isSubclassOfClass:UISearchBar.class]);

    CYLSearchBar *bar = [[CYLSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    bar.usedAsTableHeaderView = YES;
    bar.centersPlaceholder = YES;
    bar.placeholderColor = UIColor.redColor;
    bar.textColor = UIColor.blueColor;
    bar.font = [UIFont systemFontOfSize:15];
    bar.textFieldMargins = UIEdgeInsetsMake(0, 4, 0, 4);
    bar.textFieldMarginsProvider = ^UIEdgeInsets(CYLSearchBar *searchBar, BOOL active) { return active ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 8, 0, 8); };
    bar.cancelButtonFont = [UIFont boldSystemFontOfSize:15];
    bar.cancelButtonMarginsProvider = ^UIEdgeInsets(CYLSearchBar *searchBar, BOOL active) { return UIEdgeInsetsZero; };
    bar.alwaysEnablesCancelButton = NO;
    XCTAssertFalse(bar.alwaysEnablesCancelButton);
    XCTAssertTrue(bar.centersPlaceholder);
    XCTAssertEqualObjects(bar.placeholderColor, UIColor.redColor);
    XCTAssertEqual(bar.textFieldMargins.left, 4);
    XCTAssertEqual(bar.textFieldMarginsProvider(bar, NO).left, 8);

    UIView *leading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIView *trailing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    bar.leadingAccessoryView = leading;
    bar.trailingAccessoryView = trailing;
    bar.leadingAccessoryViewMargins = UIEdgeInsetsMake(0, 8, 0, 0);
    bar.trailingAccessoryViewMargins = UIEdgeInsetsMake(0, 0, 0, 8);
    [bar setShowsLeadingAccessoryView:NO animated:NO];
    bar.showsTrailingAccessoryView = NO;
    XCTAssertFalse(bar.showsLeadingAccessoryView);
    XCTAssertFalse(bar.showsTrailingAccessoryView);
    XCTAssertEqual(bar.leadingAccessoryView, leading);

    XCTAssertNil(bar.cyl_cancelButton);
    XCTAssertNil(bar.searchController);
    XCTAssertNil(bar.segmentedControl);
    [bar applyDefaultAppearance];
    CYLSearchBarAppearance *style = [CYLSearchBarAppearance.defaultAppearance copy];
    style.tintColor = UIColor.orangeColor;
    style.placeholder = @"Objective-C";
    bar.appearanceStyle = style;
    XCTAssertEqualObjects(bar.placeholder, @"Objective-C");
    XCTAssertNotNil([CYLSearchBar textFieldBackgroundImageWithColor:UIColor.grayColor]);
    XCTAssertNil([CYLSearchBar backgroundImageWithColor:nil borderColor:nil]);
    XCTAssertNotNil([CYLSearchBar backgroundImageWithColor:nil borderColor:UIColor.grayColor]);
}

- (void)testResourcesFromObjectiveC
{
    XCTAssertGreaterThan([CYLSearchResources localizedStringForKey:@"search.cancel"].length, 0u);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.cancel" language:@"zh-Hans"], @"取消");
}

@end
