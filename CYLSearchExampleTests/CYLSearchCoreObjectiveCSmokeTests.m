//
//  CYLSearchCoreObjectiveCSmokeTests.m
//  CYLSearchExampleTests
//
//  The Objective-C smoke test of the Swift core's public API (docs/swift-migration.md, step 4): the example's tests
//  are Swift; this file keeps checking that Objective-C callers see the core through its generated header.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
@import CYLTableViewPlaceHolder;

/*!
 * A search controller delegate written in Objective-C: it records the strings and has no rows.
 */
@interface CYLSearchControllerSmokeDelegate : NSObject <CYLSearchControllerDelegate>
@property(nonatomic, copy) NSArray<NSString *> *strings;
@end

@implementation CYLSearchControllerSmokeDelegate

- (void)searchController:(CYLSearchController *)searchController updateResultsForSearchString:(NSString *)searchString
{
    self.strings = [(self.strings ?: @[]) arrayByAddingObject:searchString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

@end

/*!
 * One class that conforms to the four delegate and data source protocols of the core with every method (the API fence,
 * phase 0 of the merge refactor in docs/qmui-search-controller.md).
 */
@interface CYLSearchFenceProtocols : NSObject <CYLSearchBarViewDelegate, CYLSearchViewDelegate, CYLSearchViewDataSource, CYLSearchControllerDelegate>
@end

@implementation CYLSearchFenceProtocols

- (BOOL)searchBarViewShouldBeginEditing:(CYLSearchBarView * _Nonnull)searchBarView
{
    return YES;
}

- (void)searchBarViewDidTapWhileNotEditable:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarViewDidBeginEditing:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarViewDidEndEditing:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView textDidChange:(NSString * _Nonnull)text
{
}

- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarViewNavigationButtonClicked:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (void)searchBarViewVoiceButtonClicked:(CYLSearchBarView * _Nonnull)searchBarView
{
}

- (BOOL)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView shouldSubmitText:(NSString * _Nonnull)text
{
    return YES;
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView didChangeIconified:(BOOL)iconified
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView didSelectItem:(CYLSearchBarItem * _Nonnull)item
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView textDidChange:(NSString * _Nonnull)text atIndex:(NSInteger)index
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView didCompleteSearch:(NSString * _Nonnull)text atIndex:(NSInteger)index
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView didRemoveSearchAtIndex:(NSInteger)index
{
}

- (void)searchBarView:(CYLSearchBarView * _Nonnull)searchBarView didSelectSearch:(NSString * _Nonnull)text atIndex:(NSInteger)index
{
}

- (void)searchViewDidShow:(CYLSearchView * _Nonnull)searchView
{
}

- (void)searchViewDidClose:(CYLSearchView * _Nonnull)searchView
{
}

- (void)searchView:(CYLSearchView * _Nonnull)searchView textDidChange:(NSString * _Nonnull)text
{
}

- (BOOL)searchView:(CYLSearchView * _Nonnull)searchView didSubmitText:(NSString * _Nonnull)text
{
    return YES;
}

- (void)searchView:(CYLSearchView * _Nonnull)searchView didChangeFocus:(BOOL)focused
{
}

- (void)searchView:(CYLSearchView * _Nonnull)searchView didSelectSuggestion:(NSString * _Nonnull)suggestion atIndex:(NSUInteger)index
{
}

- (void)searchViewVoiceButtonClicked:(CYLSearchView * _Nonnull)searchView
{
}

- (void)searchViewNavigationButtonClicked:(CYLSearchView * _Nonnull)searchView
{
}

- (void)searchView:(CYLSearchView * _Nonnull)searchView didSelectResult:(id _Nonnull)result
{
}

- (NSArray * _Nonnull)searchView:(CYLSearchView * _Nonnull)searchView resultsForQuery:(NSString * _Nonnull)query
{
    return @[];
}

- (void)searchView:(CYLSearchView * _Nonnull)searchView configureResultCell:(UITableViewCell * _Nonnull)cell withResult:(id _Nonnull)result
{
}

- (void)searchController:(CYLSearchController * _Nonnull)searchController updateResultsForSearchString:(NSString * _Nonnull)searchString
{
}

- (void)willPresentSearchController:(CYLSearchController * _Nonnull)searchController
{
}

- (void)didPresentSearchController:(CYLSearchController * _Nonnull)searchController
{
}

- (void)willDismissSearchController:(CYLSearchController * _Nonnull)searchController
{
}

- (void)didDismissSearchController:(CYLSearchController * _Nonnull)searchController
{
}

- (void)searchController:(CYLSearchController * _Nonnull)searchController didLoadSearchResultsTableView:(UITableView * _Nonnull)tableView
{
}

- (void)searchController:(CYLSearchController * _Nonnull)searchController willShowEmptyView:(UIView * _Nonnull)emptyView
{
}

@end

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

- (void)testSearchTableViewControllerFromObjectiveC
{
    CYLSearchTableViewController *screen = [[CYLSearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    screen.showsSearchBar = YES;
    screen.hidesSearchBarWhenEmptyViewShowing = YES;
    screen.hidesSearchBarInitially = NO;
    XCTAssertNil(screen.searchController, @"nothing before the view loads");
    [screen loadViewIfNeeded];
    XCTAssertNotNil(screen.searchController);
    XCTAssertEqual(screen.tableView.tableHeaderView, screen.searchBar);
    [screen showEmptyViewWithText:@"None" detailText:nil];
    XCTAssertTrue(screen.isEmptyViewShowing);
    XCTAssertNil(screen.tableView.tableHeaderView);
    [screen hideEmptyView];
    XCTAssertEqual(screen.tableView.tableHeaderView, screen.searchBar);
    screen.showsSearchBar = NO;
    XCTAssertNil(screen.searchBar);
    XCTAssertNil(screen.searchController);
}

- (void)testSearchControllerFromObjectiveC
{
    XCTAssertEqualObjects(NSStringFromClass(CYLSearchController.class), @"CYLSearchController");
    XCTAssertTrue([CYLSearchController.class isSubclassOfClass:UIViewController.class]);
    UITableViewController *contents = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:contents];
    UIWindowScene *scene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes.allObjects firstObject];
    UIWindow *window = scene ? [[UIWindow alloc] initWithWindowScene:scene] : [[UIWindow alloc] init];
    window.frame = CGRectMake(0, 0, 402, 874);
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    [contents loadViewIfNeeded];

    CYLSearchController *search = [[CYLSearchController alloc] initWithContentsViewController:contents];
    CYLSearchControllerSmokeDelegate *delegate = [[CYLSearchControllerSmokeDelegate alloc] init];
    search.searchResultsDelegate = delegate;
    UIView *launchView = [[UIView alloc] init];
    search.launchView = launchView;
    search.dimmingColor = UIColor.blackColor;
    search.supportsSwipeToDismissSearch = YES;
    search.hidesNavigationBarDuringPresentation = NO;
    search.alwaysShowsSearchResultsController = NO;
    search.forwardsAppearanceFromContentsViewController = YES;
    [search installSearchBarAsHeaderOf:contents.tableView];
    // The history hook: the built-in store of CYLSearchResources, set as the controller's historyStore.
    id<CYLSearchSuggestionCache> history = [CYLSearchResources suggestionCacheWithPolicy:CYLSearchSuggestionCachePolicyUserDefaults name:@"CYLObjectiveCSmoke"];
    XCTAssertNotNil(history);
    search.historyStore = history;
    XCTAssertEqual(search.historyStore, history);
    [history removeAllQueries];
    XCTAssertTrue([search.searchBar isKindOfClass:CYLSearchBar.class]);
    XCTAssertEqual(contents.tableView.tableHeaderView, search.searchBar);
    XCTAssertEqual(search.launchView, launchView);
    XCTAssertEqualObjects(search.dimmingColor, UIColor.blackColor);
    XCTAssertTrue(search.supportsSwipeToDismissSearch);
    XCTAssertFalse(search.isActive);

    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    [search setActive:YES animated:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.6]];
    XCTAssertTrue(search.isActive);
    XCTAssertEqualObjects(delegate.strings.firstObject, @"");
    search.searchBar.text = @"Obj";
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    XCTAssertEqualObjects(delegate.strings.lastObject, @"Obj");
    [search showEmptyViewWithText:@"None" detailText:nil buttonTitle:nil buttonAction:nil];
    XCTAssertTrue(search.isEmptyViewShowing);
    [search hideEmptyView];
    XCTAssertGreaterThan(search.searchBarMaxY, 0);
    [search setActive:NO animated:NO];
    XCTAssertFalse(search.isActive);

    CYLSearchController *withTable = [[CYLSearchController alloc] initWithContentsViewController:contents resultsTableViewStyle:UITableViewStyleGrouped];
    XCTAssertNotNil(withTable.tableView);
    CYLSearchController *withResults = [[CYLSearchController alloc] initWithContentsViewController:contents resultsViewController:[[UIViewController alloc] init]];
    XCTAssertNil(withResults.tableView);
    [withResults installInNavigationItem:contents.navigationItem];
    XCTAssertEqual(contents.navigationItem.searchController, withResults.searchController);
    window.rootViewController = nil;
    window.hidden = YES;
}

- (void)testResourcesFromObjectiveC
{
    XCTAssertGreaterThan([CYLSearchResources localizedStringForKey:@"search.cancel"].length, 0u);
    XCTAssertEqualObjects([CYLSearchResources localizedStringForKey:@"search.cancel" language:@"zh-Hans"], @"取消");
}


#pragma mark - API fence (docs/qmui-search-controller.md, "Merge design", phase 0)

/*
 * Every @objc member of the seven classes, the four protocols and the seven enums, taken from the generated header:
 * properties are read and written back, methods and initializers are named by a selector that must exist (undeclared
 * selectors are errors in this region) and answer respondsToSelector:. Removing or renaming a member breaks the build.
 */
#pragma clang diagnostic push
#pragma clang diagnostic error "-Wundeclared-selector"

- (void)testSearchBarViewObjectiveCMembersAreFenced
{
    CYLSearchBarView *bar = [[CYLSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    { __typeof__(bar.delegate) value1 = bar.delegate; bar.delegate = value1; }
    (void)bar.textField;
    (void)bar.fieldView;
    (void)bar.searchIconView;
    (void)bar.cancelButton;
    (void)bar.placeholderLabel;
    (void)bar.navigationButton;
    (void)bar.voiceButton;
    (void)bar.submitButton;
    (void)bar.iconButton;
    { __typeof__(bar.text) value2 = bar.text; bar.text = value2; }
    { __typeof__(bar.placeholder) value3 = bar.placeholder; bar.placeholder = value3; }
    { __typeof__(bar.font) value4 = bar.font; bar.font = value4; }
    { __typeof__(bar.textColor) value5 = bar.textColor; bar.textColor = value5; }
    { __typeof__(bar.placeholderColor) value6 = bar.placeholderColor; bar.placeholderColor = value6; }
    { __typeof__(bar.cursorColor) value7 = bar.cursorColor; bar.cursorColor = value7; }
    { __typeof__(bar.fieldHeight) value8 = bar.fieldHeight; bar.fieldHeight = value8; }
    { __typeof__(bar.contentInsets) value9 = bar.contentInsets; bar.contentInsets = value9; }
    { __typeof__(bar.fieldBackgroundColor) value10 = bar.fieldBackgroundColor; bar.fieldBackgroundColor = value10; }
    { __typeof__(bar.fieldCornerRadius) value11 = bar.fieldCornerRadius; bar.fieldCornerRadius = value11; }
    { __typeof__(bar.fieldBorderColor) value12 = bar.fieldBorderColor; bar.fieldBorderColor = value12; }
    { __typeof__(bar.fieldBorderWidth) value13 = bar.fieldBorderWidth; bar.fieldBorderWidth = value13; }
    { __typeof__(bar.fieldShadowOpacity) value14 = bar.fieldShadowOpacity; bar.fieldShadowOpacity = value14; }
    { __typeof__(bar.searchIcon) value15 = bar.searchIcon; bar.searchIcon = value15; }
    { __typeof__(bar.searchIconTintColor) value16 = bar.searchIconTintColor; bar.searchIconTintColor = value16; }
    { __typeof__(bar.trailingAccessoryViews) value17 = bar.trailingAccessoryViews; bar.trailingAccessoryViews = value17; }
    (void)bar.items;
    (void)bar.itemViews;
    { __typeof__(bar.itemTintColor) value18 = bar.itemTintColor; bar.itemTintColor = value18; }
    { __typeof__(bar.searchBarStyle) value19 = bar.searchBarStyle; bar.searchBarStyle = value19; }
    { __typeof__(bar.fieldBackgroundImage) value20 = bar.fieldBackgroundImage; bar.fieldBackgroundImage = value20; }
    (void)bar.selectedItem;
    (void)bar.selectedIndex;
    { __typeof__(bar.leadingView) value21 = bar.leadingView; bar.leadingView = value21; }
    { __typeof__(bar.showsCancelButton) value22 = bar.showsCancelButton; bar.showsCancelButton = value22; }
    // Merge phase 1: the knobs CYLSearchBarView shares with CYLSearchBar.
    { __typeof__(bar.centersPlaceholder) valueP1a = bar.centersPlaceholder; bar.centersPlaceholder = valueP1a; }
    { __typeof__(bar.textFieldMarginsProvider) valueP1b = bar.textFieldMarginsProvider; bar.textFieldMarginsProvider = valueP1b; }
    { __typeof__(bar.cancelButtonMarginsProvider) valueP1c = bar.cancelButtonMarginsProvider; bar.cancelButtonMarginsProvider = valueP1c; }
    { __typeof__(bar.cancelButtonFont) valueP1d = bar.cancelButtonFont; bar.cancelButtonFont = valueP1d; }
    { __typeof__(bar.appearanceStyle) valueP1e = bar.appearanceStyle; bar.appearanceStyle = valueP1e; }
    { __typeof__(bar.showsLeadingView) valueP1f = bar.showsLeadingView; bar.showsLeadingView = valueP1f; }
    { __typeof__(bar.showsTrailingAccessoryViews) valueP1g = bar.showsTrailingAccessoryViews; bar.showsTrailingAccessoryViews = valueP1g; }
    [bar applyDefaultAppearance];
    [bar setShowsCancelButton:YES animated:NO];
    [bar setShowsLeadingView:YES animated:NO];
    [bar setShowsTrailingAccessoryViews:YES animated:NO];
    { __typeof__(bar.cancelButtonTitle) value23 = bar.cancelButtonTitle; bar.cancelButtonTitle = value23; }
    { __typeof__(bar.cancelButtonEndsEditing) value24 = bar.cancelButtonEndsEditing; bar.cancelButtonEndsEditing = value24; }
    { __typeof__(bar.clearsTextOnCancel) value25 = bar.clearsTextOnCancel; bar.clearsTextOnCancel = value25; }
    (void)bar.isEditingBar;
    { __typeof__(bar.editingSubmitHandler) value26 = bar.editingSubmitHandler; bar.editingSubmitHandler = value26; }
    { __typeof__(bar.clearsTextOnEndEditing) value27 = bar.clearsTextOnEndEditing; bar.clearsTextOnEndEditing = value27; }
    { __typeof__(bar.navigationIcon) value28 = bar.navigationIcon; bar.navigationIcon = value28; }
    { __typeof__(bar.navigationImage) value29 = bar.navigationImage; bar.navigationImage = value29; }
    { __typeof__(bar.navigationAccessibilityLabel) value30 = bar.navigationAccessibilityLabel; bar.navigationAccessibilityLabel = value30; }
    { __typeof__(bar.navigationBackgroundColor) value31 = bar.navigationBackgroundColor; bar.navigationBackgroundColor = value31; }
    { __typeof__(bar.navigationShadowOpacity) value32 = bar.navigationShadowOpacity; bar.navigationShadowOpacity = value32; }
    { __typeof__(bar.navigationHandler) value33 = bar.navigationHandler; bar.navigationHandler = value33; }
    { __typeof__(bar.showsVoiceButton) value34 = bar.showsVoiceButton; bar.showsVoiceButton = value34; }
    { __typeof__(bar.voiceImage) value35 = bar.voiceImage; bar.voiceImage = value35; }
    { __typeof__(bar.showsSubmitButton) value36 = bar.showsSubmitButton; bar.showsSubmitButton = value36; }
    { __typeof__(bar.submitImage) value37 = bar.submitImage; bar.submitImage = value37; }
    { __typeof__(bar.clearImage) value38 = bar.clearImage; bar.clearImage = value38; }
    { __typeof__(bar.keyboardType) value39 = bar.keyboardType; bar.keyboardType = value39; }
    { __typeof__(bar.returnKeyType) value40 = bar.returnKeyType; bar.returnKeyType = value40; }
    { __typeof__(bar.autocapitalizationType) value41 = bar.autocapitalizationType; bar.autocapitalizationType = value41; }
    { __typeof__(bar.autocorrectionType) value42 = bar.autocorrectionType; bar.autocorrectionType = value42; }
    { __typeof__(bar.secureTextEntry) value43 = bar.secureTextEntry; bar.secureTextEntry = value43; }
    { __typeof__(bar.maximumTextLength) value44 = bar.maximumTextLength; bar.maximumTextLength = value44; }
    { __typeof__(bar.iconified) value45 = bar.iconified; bar.iconified = value45; }
    { __typeof__(bar.iconifiedByDefault) value46 = bar.iconifiedByDefault; bar.iconifiedByDefault = value46; }
    { __typeof__(bar.expansionAnimation) value47 = bar.expansionAnimation; bar.expansionAnimation = value47; }
    { __typeof__(bar.iconPosition) value48 = bar.iconPosition; bar.iconPosition = value48; }
    { __typeof__(bar.animationDuration) value49 = bar.animationDuration; bar.animationDuration = value49; }
    { __typeof__(bar.mode) value50 = bar.mode; bar.mode = value50; }
    (void)bar.searches;
    (void)bar.selectedSearchIndex;
    (void)bar.isEditingNewSearch;
    (void)bar.newSearchButton;
    { __typeof__(bar.minimumTextLength) value51 = bar.minimumTextLength; bar.minimumTextLength = value51; }
    { __typeof__(bar.searchIndicatorColor) value52 = bar.searchIndicatorColor; bar.searchIndicatorColor = value52; }
    { __typeof__(bar.unselectedSearchAlpha) value53 = bar.unselectedSearchAlpha; bar.unselectedSearchAlpha = value53; }
    { __typeof__(bar.searchFieldWidth) value54 = bar.searchFieldWidth; bar.searchFieldWidth = value54; }
    { __typeof__(bar.newSearchImage) value55 = bar.newSearchImage; bar.newSearchImage = value55; }
    { __typeof__(bar.removeSearchImage) value56 = bar.removeSearchImage; bar.removeSearchImage = value56; }
    (void)bar.intrinsicContentSize;
    XCTAssertTrue([bar respondsToSelector:@selector(addItem:)], @"CYLSearchBarView addItem:");
    XCTAssertTrue([bar respondsToSelector:@selector(insertItem:atIndex:)], @"CYLSearchBarView insertItem:atIndex:");
    XCTAssertTrue([bar respondsToSelector:@selector(addItemWithStyle:title:image:index:handler:)], @"CYLSearchBarView addItemWithStyle:title:image:index:handler:");
    XCTAssertTrue([bar respondsToSelector:@selector(removeItem:)], @"CYLSearchBarView removeItem:");
    XCTAssertTrue([bar respondsToSelector:@selector(removeAllItems)], @"CYLSearchBarView removeAllItems");
    XCTAssertTrue([bar respondsToSelector:@selector(hasItemOfStyle:)], @"CYLSearchBarView hasItemOfStyle:");
    XCTAssertTrue([CYLSearchBarView respondsToSelector:@selector(editingBarWithPlaceholder:actionTitle:)], @"CYLSearchBarView editingBarWithPlaceholder:actionTitle:");
    XCTAssertTrue([bar respondsToSelector:@selector(pinToKeyboardInView:)], @"CYLSearchBarView pinToKeyboardInView:");
    XCTAssertTrue([bar respondsToSelector:@selector(beginNewSearch)], @"CYLSearchBarView beginNewSearch");
    XCTAssertTrue([bar respondsToSelector:@selector(completeSearch)], @"CYLSearchBarView completeSearch");
    XCTAssertTrue([bar respondsToSelector:@selector(addSearch:)], @"CYLSearchBarView addSearch:");
    XCTAssertTrue([bar respondsToSelector:@selector(selectSearchAtIndex:)], @"CYLSearchBarView selectSearchAtIndex:");
    XCTAssertTrue([bar respondsToSelector:@selector(removeSearchAtIndex:)], @"CYLSearchBarView removeSearchAtIndex:");
    XCTAssertTrue([bar respondsToSelector:@selector(initWithFrame:)], @"CYLSearchBarView initWithFrame:");
    XCTAssertTrue([bar respondsToSelector:@selector(initWithCoder:)], @"CYLSearchBarView initWithCoder:");
    XCTAssertTrue([bar respondsToSelector:@selector(setText:submit:)], @"CYLSearchBarView setText:submit:");
    XCTAssertTrue([bar respondsToSelector:@selector(submit)], @"CYLSearchBarView submit");
    XCTAssertTrue([bar respondsToSelector:@selector(showKeyboard)], @"CYLSearchBarView showKeyboard");
    XCTAssertTrue([bar respondsToSelector:@selector(hideKeyboard)], @"CYLSearchBarView hideKeyboard");
    XCTAssertTrue([bar respondsToSelector:@selector(setIconified:animated:)], @"CYLSearchBarView setIconified:animated:");
    XCTAssertTrue([bar respondsToSelector:@selector(encodeRestorableStateWithCoder:)], @"CYLSearchBarView encodeRestorableStateWithCoder:");
    XCTAssertTrue([bar respondsToSelector:@selector(decodeRestorableStateWithCoder:)], @"CYLSearchBarView decodeRestorableStateWithCoder:");
    XCTAssertTrue([bar respondsToSelector:@selector(traitCollectionDidChange:)], @"CYLSearchBarView traitCollectionDidChange:");
    XCTAssertTrue([bar respondsToSelector:@selector(tintColorDidChange)], @"CYLSearchBarView tintColorDidChange");
    XCTAssertTrue([bar respondsToSelector:@selector(sizeThatFits:)], @"CYLSearchBarView sizeThatFits:");
    XCTAssertTrue([bar respondsToSelector:@selector(layoutSubviews)], @"CYLSearchBarView layoutSubviews");
    XCTAssertTrue([bar respondsToSelector:@selector(textFieldShouldBeginEditing:)], @"CYLSearchBarView textFieldShouldBeginEditing:");
    XCTAssertTrue([bar respondsToSelector:@selector(textFieldShouldReturn:)], @"CYLSearchBarView textFieldShouldReturn:");
    XCTAssertTrue([bar respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)], @"CYLSearchBarView textField:shouldChangeCharactersInRange:replacementString:");
    XCTAssertTrue([bar respondsToSelector:@selector(textFieldDidBeginEditing:)], @"CYLSearchBarView textFieldDidBeginEditing:");
    XCTAssertTrue([bar respondsToSelector:@selector(textFieldDidEndEditing:)], @"CYLSearchBarView textFieldDidEndEditing:");
    XCTAssertTrue([bar respondsToSelector:@selector(becomeFirstResponder)], @"CYLSearchBarView becomeFirstResponder");
    XCTAssertTrue([bar respondsToSelector:@selector(resignFirstResponder)], @"CYLSearchBarView resignFirstResponder");
}

- (void)testSearchBarItemObjectiveCMembersAreFenced
{
    CYLSearchBarItem *item = [[CYLSearchBarItem alloc] initWithTitle:@"Item" image:nil];
    (void)item.style;
    { __typeof__(item.title) value57 = item.title; item.title = value57; }
    { __typeof__(item.image) value58 = item.image; item.image = value58; }
    { __typeof__(item.selectedImage) value59 = item.selectedImage; item.selectedImage = value59; }
    { __typeof__(item.animatedImage) value60 = item.animatedImage; item.animatedImage = value60; }
    { __typeof__(item.animationURL) value61 = item.animationURL; item.animationURL = value61; }
    { __typeof__(item.imageSize) value62 = item.imageSize; item.imageSize = value62; }
    { __typeof__(item.itemAccessibilityLabel) value63 = item.itemAccessibilityLabel; item.itemAccessibilityLabel = value63; }
    { __typeof__(item.itemAccessibilityIdentifier) value64 = item.itemAccessibilityIdentifier; item.itemAccessibilityIdentifier = value64; }
    { __typeof__(item.isEnabled) value65 = item.isEnabled; item.isEnabled = value65; }
    { __typeof__(item.isSelectable) value66 = item.isSelectable; item.isSelectable = value66; }
    { __typeof__(item.isSelected) value67 = item.isSelected; item.isSelected = value67; }
    { __typeof__(item.tintColor) value68 = item.tintColor; item.tintColor = value68; }
    { __typeof__(item.backgroundColor) value69 = item.backgroundColor; item.backgroundColor = value69; }
    { __typeof__(item.selectedBackgroundColor) value70 = item.selectedBackgroundColor; item.selectedBackgroundColor = value70; }
    { __typeof__(item.contentInsets) value71 = item.contentInsets; item.contentInsets = value71; }
    { __typeof__(item.imagePositionAdjustment) value72 = item.imagePositionAdjustment; item.imagePositionAdjustment = value72; }
    { __typeof__(item.titlePositionAdjustment) value73 = item.titlePositionAdjustment; item.titlePositionAdjustment = value73; }
    { __typeof__(item.badgeValue) value74 = item.badgeValue; item.badgeValue = value74; }
    { __typeof__(item.badgeColor) value75 = item.badgeColor; item.badgeColor = value75; }
    { __typeof__(item.badgeSize) value76 = item.badgeSize; item.badgeSize = value76; }
    { __typeof__(item.badgeContentInsets) value77 = item.badgeContentInsets; item.badgeContentInsets = value77; }
    { __typeof__(item.badgePositionAdjustment) value78 = item.badgePositionAdjustment; item.badgePositionAdjustment = value78; }
    { __typeof__(item.handler) value79 = item.handler; item.handler = value79; }
    (void)item.searchBarView;
    (void)item.index;
    (void)item.itemView;
    XCTAssertTrue([item respondsToSelector:@selector(initWithStyle:title:image:)], @"CYLSearchBarItem initWithStyle:title:image:");
    XCTAssertTrue([item respondsToSelector:@selector(initWithTitle:image:)], @"CYLSearchBarItem initWithTitle:image:");
    XCTAssertTrue([item respondsToSelector:@selector(initWithTitle:image:selectedImage:)], @"CYLSearchBarItem initWithTitle:image:selectedImage:");
    XCTAssertTrue([CYLSearchBarItem respondsToSelector:@selector(iconItemWithImage:title:handler:)], @"CYLSearchBarItem iconItemWithImage:title:handler:");
    XCTAssertTrue([CYLSearchBarItem respondsToSelector:@selector(textItemWithTitle:handler:)], @"CYLSearchBarItem textItemWithTitle:handler:");
    XCTAssertTrue([CYLSearchBarItem respondsToSelector:@selector(dividerItem)], @"CYLSearchBarItem dividerItem");
    XCTAssertTrue([CYLSearchBarItem respondsToSelector:@selector(itemWithDictionary:)], @"CYLSearchBarItem itemWithDictionary:");
    XCTAssertTrue([item respondsToSelector:@selector(setTitleTextAttributes:forState:)], @"CYLSearchBarItem setTitleTextAttributes:forState:");
    XCTAssertTrue([item respondsToSelector:@selector(titleTextAttributesForState:)], @"CYLSearchBarItem titleTextAttributesForState:");
    XCTAssertTrue([item respondsToSelector:@selector(setBadgeTextAttributes:forState:)], @"CYLSearchBarItem setBadgeTextAttributes:forState:");
    XCTAssertTrue([item respondsToSelector:@selector(badgeTextAttributesForState:)], @"CYLSearchBarItem badgeTextAttributesForState:");
    XCTAssertTrue([item respondsToSelector:@selector(actualBadgeSuperView)], @"CYLSearchBarItem actualBadgeSuperView");
    XCTAssertTrue([item respondsToSelector:@selector(init)], @"CYLSearchBarItem init");
    XCTAssertTrue([CYLSearchBarItem respondsToSelector:@selector(new)], @"CYLSearchBarItem new");
}

- (void)testSearchViewObjectiveCMembersAreFenced
{
    CYLSearchView *sv = [[CYLSearchView alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    { __typeof__(sv.delegate) value80 = sv.delegate; sv.delegate = value80; }
    (void)sv.searchBarView;
    (void)sv.dividerView;
    (void)sv.suggestionsTableView;
    (void)sv.suggestionsTagView;
    { __typeof__(sv.suggestionsFoldControl) value81 = sv.suggestionsFoldControl; sv.suggestionsFoldControl = value81; }
    { __typeof__(sv.suggestionsFoldedRowCount) value82 = sv.suggestionsFoldedRowCount; sv.suggestionsFoldedRowCount = value82; }
    { __typeof__(sv.suggestionStyle) value83 = sv.suggestionStyle; sv.suggestionStyle = value83; }
    { __typeof__(sv.showsEmptyResultsPlaceholder) value84 = sv.showsEmptyResultsPlaceholder; sv.showsEmptyResultsPlaceholder = value84; }
    { __typeof__(sv.emptyResultsScenario) value85 = sv.emptyResultsScenario; sv.emptyResultsScenario = value85; }
    (void)sv.emptyResultsView;
    { __typeof__(sv.resultsDataSource) value86 = sv.resultsDataSource; sv.resultsDataSource = value86; }
    (void)sv.resultsTableView;
    (void)sv.searchResults;
    { __typeof__(sv.highlightsResultMatches) valueP3a = sv.highlightsResultMatches; sv.highlightsResultMatches = valueP3a; }
    { __typeof__(sv.resultMatchHighlightColor) valueP3b = sv.resultMatchHighlightColor; sv.resultMatchHighlightColor = valueP3b; }
    { __typeof__(sv.isActive) valueP3c = sv.isActive; sv.isActive = valueP3c; }
    { __typeof__(sv.supportsSwipeToDismissSearch) valueP3d = sv.supportsSwipeToDismissSearch; sv.supportsSwipeToDismissSearch = valueP3d; }
    { __typeof__(sv.refreshHandler) value87 = sv.refreshHandler; sv.refreshHandler = value87; }
    (void)sv.isRefreshing;
    { __typeof__(sv.dividerColor) value88 = sv.dividerColor; sv.dividerColor = value88; }
    { __typeof__(sv.contentView) value89 = sv.contentView; sv.contentView = value89; }
    { __typeof__(sv.scrimColor) value90 = sv.scrimColor; sv.scrimColor = value90; }
    { __typeof__(sv.suggestions) value91 = sv.suggestions; sv.suggestions = value91; }
    { __typeof__(sv.suggestionFilter) value92 = sv.suggestionFilter; sv.suggestionFilter = value92; }
    { __typeof__(sv.showsSuggestionsForEmptyQuery) value93 = sv.showsSuggestionsForEmptyQuery; sv.showsSuggestionsForEmptyQuery = value93; }
    (void)sv.filteredSuggestions;
    { __typeof__(sv.suggestionImage) value94 = sv.suggestionImage; sv.suggestionImage = value94; }
    { __typeof__(sv.suggestionImageTintColor) value95 = sv.suggestionImageTintColor; sv.suggestionImageTintColor = value95; }
    { __typeof__(sv.suggestionBackgroundColor) value96 = sv.suggestionBackgroundColor; sv.suggestionBackgroundColor = value96; }
    { __typeof__(sv.suggestionTextColor) value97 = sv.suggestionTextColor; sv.suggestionTextColor = value97; }
    { __typeof__(sv.suggestionLineBreakMode) value98 = sv.suggestionLineBreakMode; sv.suggestionLineBreakMode = value98; }
    { __typeof__(sv.submitsOnSuggestionSelection) value99 = sv.submitsOnSuggestionSelection; sv.submitsOnSuggestionSelection = value99; }
    { __typeof__(sv.suggestionCellConfiguration) value100 = sv.suggestionCellConfiguration; sv.suggestionCellConfiguration = value100; }
    { __typeof__(sv.suggestionCachePolicy) value101 = sv.suggestionCachePolicy; sv.suggestionCachePolicy = value101; }
    { __typeof__(sv.suggestionCacheName) value102 = sv.suggestionCacheName; sv.suggestionCacheName = value102; }
    { __typeof__(sv.suggestionCache) value103 = sv.suggestionCache; sv.suggestionCache = value103; }
    (void)sv.suggestionCacheHeaderView;
    { __typeof__(sv.showsSuggestionCacheHeader) value104 = sv.showsSuggestionCacheHeader; sv.showsSuggestionCacheHeader = value104; }
    (void)sv.suggestionCacheTitleLabel;
    (void)sv.clearSuggestionCacheButton;
    { __typeof__(sv.showsEmptySuggestionsPlaceholder) value105 = sv.showsEmptySuggestionsPlaceholder; sv.showsEmptySuggestionsPlaceholder = value105; }
    { __typeof__(sv.emptySuggestionsScenario) value106 = sv.emptySuggestionsScenario; sv.emptySuggestionsScenario = value106; }
    (void)sv.emptySuggestionsView;
    { __typeof__(sv.focusesSearchFieldOnShow) value107 = sv.focusesSearchFieldOnShow; sv.focusesSearchFieldOnShow = value107; }
    (void)sv.isSearchOpen;
    { __typeof__(sv.animationDuration) value108 = sv.animationDuration; sv.animationDuration = value108; }
    { __typeof__(sv.closesOnSubmit) value109 = sv.closesOnSubmit; sv.closesOnSubmit = value109; }
    { __typeof__(sv.query) value110 = sv.query; sv.query = value110; }
    { __typeof__(sv.backgroundColor) value111 = sv.backgroundColor; sv.backgroundColor = value111; }
    XCTAssertTrue([sv respondsToSelector:@selector(beginRefreshing)], @"CYLSearchView beginRefreshing");
    XCTAssertTrue([sv respondsToSelector:@selector(endRefreshing)], @"CYLSearchView endRefreshing");
    XCTAssertTrue([CYLSearchView respondsToSelector:@selector(setRefreshHandler:forScrollView:)], @"CYLSearchView setRefreshHandler:forScrollView:");
    XCTAssertTrue([CYLSearchView respondsToSelector:@selector(beginRefreshingInScrollView:)], @"CYLSearchView beginRefreshingInScrollView:");
    XCTAssertTrue([CYLSearchView respondsToSelector:@selector(endRefreshingInScrollView:)], @"CYLSearchView endRefreshingInScrollView:");
    XCTAssertTrue([CYLSearchView respondsToSelector:@selector(isRefreshingInScrollView:)], @"CYLSearchView isRefreshingInScrollView:");
    XCTAssertTrue([sv respondsToSelector:@selector(initWithFrame:)], @"CYLSearchView initWithFrame:");
    XCTAssertTrue([sv respondsToSelector:@selector(initWithCoder:)], @"CYLSearchView initWithCoder:");
    XCTAssertTrue([sv respondsToSelector:@selector(layoutSubviews)], @"CYLSearchView layoutSubviews");
    XCTAssertTrue([sv respondsToSelector:@selector(safeAreaInsetsDidChange)], @"CYLSearchView safeAreaInsetsDidChange");
    XCTAssertTrue([sv respondsToSelector:@selector(installInView:)], @"CYLSearchView installInView:");
    XCTAssertTrue([sv respondsToSelector:@selector(showSearch)], @"CYLSearchView showSearch");
    XCTAssertTrue([sv respondsToSelector:@selector(showSearchAnimated:)], @"CYLSearchView showSearchAnimated:");
    XCTAssertTrue([sv respondsToSelector:@selector(setActive:animated:)], @"CYLSearchView setActive:animated:");
    XCTAssertTrue([sv respondsToSelector:@selector(showSearchInViewController:animated:)], @"CYLSearchView showSearchInViewController:animated:");
    XCTAssertTrue([sv respondsToSelector:@selector(closeSearch)], @"CYLSearchView closeSearch");
    XCTAssertTrue([sv respondsToSelector:@selector(closeSearchAnimated:)], @"CYLSearchView closeSearchAnimated:");
    XCTAssertTrue([sv respondsToSelector:@selector(closeSearchAnimated:completion:)], @"CYLSearchView closeSearchAnimated:completion:");
    XCTAssertTrue([sv respondsToSelector:@selector(encodeRestorableStateWithCoder:)], @"CYLSearchView encodeRestorableStateWithCoder:");
    XCTAssertTrue([sv respondsToSelector:@selector(decodeRestorableStateWithCoder:)], @"CYLSearchView decodeRestorableStateWithCoder:");
    XCTAssertTrue([sv respondsToSelector:@selector(accessibilityPerformEscape)], @"CYLSearchView accessibilityPerformEscape");
    XCTAssertTrue([sv respondsToSelector:@selector(attachToBarButtonItem:)], @"CYLSearchView attachToBarButtonItem:");
    XCTAssertTrue([sv respondsToSelector:@selector(setQuery:submit:)], @"CYLSearchView setQuery:submit:");
    XCTAssertTrue([sv respondsToSelector:@selector(showSuggestions)], @"CYLSearchView showSuggestions");
    XCTAssertTrue([sv respondsToSelector:@selector(reloadResults)], @"CYLSearchView reloadResults");
    XCTAssertTrue([sv respondsToSelector:@selector(dismissSuggestions)], @"CYLSearchView dismissSuggestions");
    XCTAssertTrue([sv respondsToSelector:@selector(clearSuggestionCache)], @"CYLSearchView clearSuggestionCache");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarView:textDidChange:)], @"CYLSearchView searchBarView:textDidChange:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewSearchButtonClicked:)], @"CYLSearchView searchBarViewSearchButtonClicked:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewNavigationButtonClicked:)], @"CYLSearchView searchBarViewNavigationButtonClicked:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewVoiceButtonClicked:)], @"CYLSearchView searchBarViewVoiceButtonClicked:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewCancelButtonClicked:)], @"CYLSearchView searchBarViewCancelButtonClicked:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewDidBeginEditing:)], @"CYLSearchView searchBarViewDidBeginEditing:");
    XCTAssertTrue([sv respondsToSelector:@selector(searchBarViewDidEndEditing:)], @"CYLSearchView searchBarViewDidEndEditing:");
    XCTAssertTrue([sv respondsToSelector:@selector(tableView:numberOfRowsInSection:)], @"CYLSearchView tableView:numberOfRowsInSection:");
    XCTAssertTrue([sv respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], @"CYLSearchView tableView:cellForRowAtIndexPath:");
    XCTAssertTrue([sv respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)], @"CYLSearchView tableView:didSelectRowAtIndexPath:");
}

- (void)testSearchBarObjectiveCMembersAreFenced
{
    CYLSearchBar *sb = [[CYLSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    { __typeof__(sb.appearanceStyle) value112 = sb.appearanceStyle; sb.appearanceStyle = value112; }
    { __typeof__(sb.usedAsTableHeaderView) value113 = sb.usedAsTableHeaderView; sb.usedAsTableHeaderView = value113; }
    { __typeof__(sb.centersPlaceholder) value114 = sb.centersPlaceholder; sb.centersPlaceholder = value114; }
    { __typeof__(sb.placeholderColor) value115 = sb.placeholderColor; sb.placeholderColor = value115; }
    { __typeof__(sb.textColor) value116 = sb.textColor; sb.textColor = value116; }
    { __typeof__(sb.font) value117 = sb.font; sb.font = value117; }
    { __typeof__(sb.textFieldMargins) value118 = sb.textFieldMargins; sb.textFieldMargins = value118; }
    { __typeof__(sb.textFieldMarginsProvider) value119 = sb.textFieldMarginsProvider; sb.textFieldMarginsProvider = value119; }
    (void)sb.cyl_cancelButton;
    { __typeof__(sb.cancelButtonFont) value120 = sb.cancelButtonFont; sb.cancelButtonFont = value120; }
    { __typeof__(sb.cancelButtonMarginsProvider) value121 = sb.cancelButtonMarginsProvider; sb.cancelButtonMarginsProvider = value121; }
    { __typeof__(sb.alwaysEnablesCancelButton) value122 = sb.alwaysEnablesCancelButton; sb.alwaysEnablesCancelButton = value122; }
    (void)sb.backgroundView;
    (void)sb.segmentedControl;
    (void)sb.searchController;
    { __typeof__(sb.leadingAccessoryView) value123 = sb.leadingAccessoryView; sb.leadingAccessoryView = value123; }
    { __typeof__(sb.showsLeadingAccessoryView) value124 = sb.showsLeadingAccessoryView; sb.showsLeadingAccessoryView = value124; }
    { __typeof__(sb.leadingAccessoryViewMargins) value125 = sb.leadingAccessoryViewMargins; sb.leadingAccessoryViewMargins = value125; }
    { __typeof__(sb.trailingAccessoryView) value126 = sb.trailingAccessoryView; sb.trailingAccessoryView = value126; }
    { __typeof__(sb.showsTrailingAccessoryView) value127 = sb.showsTrailingAccessoryView; sb.showsTrailingAccessoryView = value127; }
    { __typeof__(sb.trailingAccessoryViewMargins) value128 = sb.trailingAccessoryViewMargins; sb.trailingAccessoryViewMargins = value128; }
    { __typeof__(sb.placeholder) value129 = sb.placeholder; sb.placeholder = value129; }
    { __typeof__(sb.text) value130 = sb.text; sb.text = value130; }
    { __typeof__(sb.barTintColor) value131 = sb.barTintColor; sb.barTintColor = value131; }
    XCTAssertTrue([sb respondsToSelector:@selector(initWithFrame:)], @"CYLSearchBar initWithFrame:");
    XCTAssertTrue([sb respondsToSelector:@selector(initWithCoder:)], @"CYLSearchBar initWithCoder:");
    XCTAssertTrue([sb respondsToSelector:@selector(applyDefaultAppearance)], @"CYLSearchBar applyDefaultAppearance");
    XCTAssertTrue([sb respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)], @"CYLSearchBar setBackgroundImage:forBarPosition:barMetrics:");
    XCTAssertTrue([sb respondsToSelector:@selector(didMoveToWindow)], @"CYLSearchBar didMoveToWindow");
    XCTAssertTrue([sb respondsToSelector:@selector(layoutSubviews)], @"CYLSearchBar layoutSubviews");
    XCTAssertTrue([sb respondsToSelector:@selector(setShowsLeadingAccessoryView:animated:)], @"CYLSearchBar setShowsLeadingAccessoryView:animated:");
    XCTAssertTrue([sb respondsToSelector:@selector(setShowsTrailingAccessoryView:animated:)], @"CYLSearchBar setShowsTrailingAccessoryView:animated:");
    XCTAssertTrue([CYLSearchBar respondsToSelector:@selector(textFieldBackgroundImageWithColor:)], @"CYLSearchBar textFieldBackgroundImageWithColor:");
    XCTAssertTrue([CYLSearchBar respondsToSelector:@selector(backgroundImageWithColor:borderColor:)], @"CYLSearchBar backgroundImageWithColor:borderColor:");
}

- (void)testSearchBarAppearanceObjectiveCMembersAreFenced
{
    CYLSearchBarAppearance *app = [[CYLSearchBarAppearance alloc] init];
    { __typeof__(app.font) value132 = app.font; app.font = value132; }
    { __typeof__(app.textColor) value133 = app.textColor; app.textColor = value133; }
    { __typeof__(app.placeholderColor) value134 = app.placeholderColor; app.placeholderColor = value134; }
    { __typeof__(app.placeholder) value135 = app.placeholder; app.placeholder = value135; }
    { __typeof__(app.cancelTitle) value136 = app.cancelTitle; app.cancelTitle = value136; }
    { __typeof__(app.tintColor) value137 = app.tintColor; app.tintColor = value137; }
    { __typeof__(app.searchIconImage) value138 = app.searchIconImage; app.searchIconImage = value138; }
    { __typeof__(app.clearIconImage) value139 = app.clearIconImage; app.clearIconImage = value139; }
    { __typeof__(app.textFieldBackgroundColor) value140 = app.textFieldBackgroundColor; app.textFieldBackgroundColor = value140; }
    { __typeof__(app.textFieldBackgroundImage) value141 = app.textFieldBackgroundImage; app.textFieldBackgroundImage = value141; }
    { __typeof__(app.textFieldBorderColor) value142 = app.textFieldBorderColor; app.textFieldBorderColor = value142; }
    { __typeof__(app.textFieldCornerRadius) value143 = app.textFieldCornerRadius; app.textFieldCornerRadius = value143; }
    { __typeof__(app.barBackgroundImage) value144 = app.barBackgroundImage; app.barBackgroundImage = value144; }
    { __typeof__(app.barBackgroundColor) value145 = app.barBackgroundColor; app.barBackgroundColor = value145; }
    { __typeof__(app.barBorderColor) value146 = app.barBorderColor; app.barBorderColor = value146; }
    { __typeof__(app.hidesBarBackground) value147 = app.hidesBarBackground; app.hidesBarBackground = value147; }
    XCTAssertTrue([CYLSearchBarAppearance respondsToSelector:@selector(defaultAppearance)], @"CYLSearchBarAppearance defaultAppearance");
    XCTAssertTrue([app respondsToSelector:@selector(init)], @"CYLSearchBarAppearance init");
    XCTAssertTrue([app respondsToSelector:@selector(copyWithZone:)], @"CYLSearchBarAppearance copyWithZone:");
}

- (void)testSearchControllerObjectiveCMembersAreFenced
{
    CYLSearchController *sc = [[CYLSearchController alloc] initWithContentsViewController:[[UIViewController alloc] init]];
    { __typeof__(sc.searchResultsDelegate) value148 = sc.searchResultsDelegate; sc.searchResultsDelegate = value148; }
    (void)sc.searchController;
    (void)sc.searchResultsController;
    (void)sc.searchBar;
    (void)sc.tableView;
    { __typeof__(sc.launchView) value149 = sc.launchView; sc.launchView = value149; }
    { __typeof__(sc.showsSuggestionsLaunchView) value160 = sc.showsSuggestionsLaunchView; sc.showsSuggestionsLaunchView = value160; }
    { __typeof__(sc.suggestions) value161 = sc.suggestions; sc.suggestions = value161; }
    { __typeof__(sc.dimmingColor) value150 = sc.dimmingColor; sc.dimmingColor = value150; }
    { __typeof__(sc.isActive) value151 = sc.isActive; sc.isActive = value151; }
    (void)sc.isSearchOpen;
    { __typeof__(sc.highlightsResultMatches) valueP3e = sc.highlightsResultMatches; sc.highlightsResultMatches = valueP3e; }
    { __typeof__(sc.resultMatchHighlightColor) valueP3f = sc.resultMatchHighlightColor; sc.resultMatchHighlightColor = valueP3f; }
    { __typeof__(sc.hidesNavigationBarDuringPresentation) value152 = sc.hidesNavigationBarDuringPresentation; sc.hidesNavigationBarDuringPresentation = value152; }
    { __typeof__(sc.alwaysShowsSearchResultsController) value153 = sc.alwaysShowsSearchResultsController; sc.alwaysShowsSearchResultsController = value153; }
    { __typeof__(sc.forwardsAppearanceFromContentsViewController) value154 = sc.forwardsAppearanceFromContentsViewController; sc.forwardsAppearanceFromContentsViewController = value154; }
    { __typeof__(sc.supportsSwipeToDismissSearch) value155 = sc.supportsSwipeToDismissSearch; sc.supportsSwipeToDismissSearch = value155; }
    (void)sc.swipeGestureRecognizer;
    (void)sc.searchBarMaxY;
    { __typeof__(sc.prefersStatusBarHiddenProvider) value156 = sc.prefersStatusBarHiddenProvider; sc.prefersStatusBarHiddenProvider = value156; }
    { __typeof__(sc.preferredStatusBarStyleProvider) value157 = sc.preferredStatusBarStyleProvider; sc.preferredStatusBarStyleProvider = value157; }
    (void)sc.isEmptyViewShowing;
    { __typeof__(sc.historyStore) value158 = sc.historyStore; sc.historyStore = value158; }
    { __typeof__(sc.snapsHeaderSearchBar) value159 = sc.snapsHeaderSearchBar; sc.snapsHeaderSearchBar = value159; }
    XCTAssertTrue([CYLSearchController respondsToSelector:@selector(historyDidChangeNotification)], @"CYLSearchController historyDidChangeNotification");
    XCTAssertTrue([sc respondsToSelector:@selector(initWithContentsViewController:resultsViewController:)], @"CYLSearchController initWithContentsViewController:resultsViewController:");
    XCTAssertTrue([sc respondsToSelector:@selector(initWithContentsViewController:resultsTableViewStyle:)], @"CYLSearchController initWithContentsViewController:resultsTableViewStyle:");
    XCTAssertTrue([sc respondsToSelector:@selector(initWithContentsViewController:)], @"CYLSearchController initWithContentsViewController:");
    XCTAssertTrue([sc respondsToSelector:@selector(initWithCoder:)], @"CYLSearchController initWithCoder:");
    XCTAssertTrue([sc respondsToSelector:@selector(viewDidLoad)], @"CYLSearchController viewDidLoad");
    XCTAssertTrue([sc respondsToSelector:@selector(setActive:animated:)], @"CYLSearchController setActive:animated:");
    XCTAssertTrue([sc respondsToSelector:@selector(showSearchAnimated:)], @"CYLSearchController showSearchAnimated:");
    XCTAssertTrue([sc respondsToSelector:@selector(closeSearchAnimated:)], @"CYLSearchController closeSearchAnimated:");
    XCTAssertTrue([sc respondsToSelector:@selector(installSearchBarAsHeaderOf:)], @"CYLSearchController installSearchBarAsHeaderOf:");
    XCTAssertTrue([sc respondsToSelector:@selector(installInNavigationItem:)], @"CYLSearchController installInNavigationItem:");
    XCTAssertTrue([sc respondsToSelector:@selector(showEmptyViewWithText:detailText:buttonTitle:buttonAction:)], @"CYLSearchController showEmptyViewWithText:detailText:buttonTitle:buttonAction:");
    XCTAssertTrue([sc respondsToSelector:@selector(showEmptyViewWithScenario:)], @"CYLSearchController showEmptyViewWithScenario:");
    XCTAssertTrue([sc respondsToSelector:@selector(hideEmptyView)], @"CYLSearchController hideEmptyView");
    XCTAssertTrue([sc respondsToSelector:@selector(updateSearchResultsForSearchController:)], @"CYLSearchController updateSearchResultsForSearchController:");
    XCTAssertTrue([sc respondsToSelector:@selector(willPresentSearchController:)], @"CYLSearchController willPresentSearchController:");
    XCTAssertTrue([sc respondsToSelector:@selector(didPresentSearchController:)], @"CYLSearchController didPresentSearchController:");
    XCTAssertTrue([sc respondsToSelector:@selector(willDismissSearchController:)], @"CYLSearchController willDismissSearchController:");
    XCTAssertTrue([sc respondsToSelector:@selector(didDismissSearchController:)], @"CYLSearchController didDismissSearchController:");
    XCTAssertTrue([sc respondsToSelector:@selector(initWithNibName:bundle:)], @"CYLSearchController initWithNibName:bundle:");
    XCTAssertTrue([sc respondsToSelector:@selector(gestureRecognizerShouldBegin:)], @"CYLSearchController gestureRecognizerShouldBegin:");
    XCTAssertTrue([sc respondsToSelector:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)], @"CYLSearchController gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:");
}

- (void)testSearchTableViewControllerObjectiveCMembersAreFenced
{
    CYLSearchTableViewController *tvc = [[CYLSearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    { __typeof__(tvc.showsSearchBar) value160 = tvc.showsSearchBar; tvc.showsSearchBar = value160; }
    (void)tvc.searchController;
    (void)tvc.searchBar;
    { __typeof__(tvc.hidesSearchBarWhenEmptyViewShowing) value161 = tvc.hidesSearchBarWhenEmptyViewShowing; tvc.hidesSearchBarWhenEmptyViewShowing = value161; }
    { __typeof__(tvc.hidesSearchBarInitially) value162 = tvc.hidesSearchBarInitially; tvc.hidesSearchBarInitially = value162; }
    (void)tvc.isEmptyViewShowing;
    XCTAssertTrue([tvc respondsToSelector:@selector(viewDidLoad)], @"CYLSearchTableViewController viewDidLoad");
    XCTAssertTrue([tvc respondsToSelector:@selector(viewWillAppear:)], @"CYLSearchTableViewController viewWillAppear:");
    XCTAssertTrue([tvc respondsToSelector:@selector(viewDidLayoutSubviews)], @"CYLSearchTableViewController viewDidLayoutSubviews");
    XCTAssertTrue([tvc respondsToSelector:@selector(setUpSearchBar)], @"CYLSearchTableViewController setUpSearchBar");
    XCTAssertTrue([tvc respondsToSelector:@selector(searchController:updateResultsForSearchString:)], @"CYLSearchTableViewController searchController:updateResultsForSearchString:");
    XCTAssertTrue([tvc respondsToSelector:@selector(showEmptyViewWithText:detailText:)], @"CYLSearchTableViewController showEmptyViewWithText:detailText:");
    XCTAssertTrue([tvc respondsToSelector:@selector(showEmptyViewWithScenario:)], @"CYLSearchTableViewController showEmptyViewWithScenario:");
    XCTAssertTrue([tvc respondsToSelector:@selector(hideEmptyView)], @"CYLSearchTableViewController hideEmptyView");
    XCTAssertTrue([tvc respondsToSelector:@selector(initWithStyle:)], @"CYLSearchTableViewController initWithStyle:");
    XCTAssertTrue([tvc respondsToSelector:@selector(initWithNibName:bundle:)], @"CYLSearchTableViewController initWithNibName:bundle:");
    XCTAssertTrue([tvc respondsToSelector:@selector(initWithCoder:)], @"CYLSearchTableViewController initWithCoder:");
}

- (void)testEnumsKeepEveryCaseFromObjectiveC
{
    NSArray<NSNumber *> *searchBarExpansionAnimation = @[@(CYLSearchBarExpansionAnimationFade), @(CYLSearchBarExpansionAnimationCircularReveal)];
    XCTAssertEqual(searchBarExpansionAnimation.count, 2u);
    NSArray<NSNumber *> *searchBarIconPosition = @[@(CYLSearchBarIconPositionTrailing), @(CYLSearchBarIconPositionCenter), @(CYLSearchBarIconPositionLeading)];
    XCTAssertEqual(searchBarIconPosition.count, 3u);
    NSArray<NSNumber *> *searchBarItemStyle = @[@(CYLSearchBarItemStyleIcon), @(CYLSearchBarItemStyleDivider), @(CYLSearchBarItemStyleText)];
    XCTAssertEqual(searchBarItemStyle.count, 3u);
    NSArray<NSNumber *> *searchBarMode = @[@(CYLSearchBarModeSingle), @(CYLSearchBarModeMultiple)];
    XCTAssertEqual(searchBarMode.count, 2u);
    NSArray<NSNumber *> *searchBarNavigationIcon = @[@(CYLSearchBarNavigationIconNone), @(CYLSearchBarNavigationIconArrow), @(CYLSearchBarNavigationIconSearch)];
    XCTAssertEqual(searchBarNavigationIcon.count, 3u);
    NSArray<NSNumber *> *searchBarStyle = @[@(CYLSearchBarStylePlain), @(CYLSearchBarStyleBordered)];
    XCTAssertEqual(searchBarStyle.count, 2u);
    NSArray<NSNumber *> *searchSuggestionStyle = @[@(CYLSearchSuggestionStyleList), @(CYLSearchSuggestionStyleTags)];
    XCTAssertEqual(searchSuggestionStyle.count, 2u);
}

- (void)testProtocolsKeepEveryMethodFromObjectiveC
{
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewShouldBeginEditing:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewShouldBeginEditing:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewDidTapWhileNotEditable:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewDidTapWhileNotEditable:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewDidBeginEditing:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewDidBeginEditing:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewDidEndEditing:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewDidEndEditing:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:textDidChange:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:textDidChange:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewSearchButtonClicked:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewSearchButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewCancelButtonClicked:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewCancelButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewNavigationButtonClicked:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewNavigationButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarViewVoiceButtonClicked:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarViewVoiceButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:shouldSubmitText:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:shouldSubmitText:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:didChangeIconified:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:didChangeIconified:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:didSelectItem:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:didSelectItem:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:textDidChange:atIndex:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:textDidChange:atIndex:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:didCompleteSearch:atIndex:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:didCompleteSearch:atIndex:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:didRemoveSearchAtIndex:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:didRemoveSearchAtIndex:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchBarViewDelegate), @selector(searchBarView:didSelectSearch:atIndex:), NO, YES).name, NULL, @"CYLSearchBarViewDelegate searchBarView:didSelectSearch:atIndex:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewWillShow:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewWillShow:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewWillClose:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewWillClose:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewDidShow:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewDidShow:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewDidClose:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewDidClose:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchView:textDidChange:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchView:textDidChange:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchView:didSubmitText:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchView:didSubmitText:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchView:didChangeFocus:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchView:didChangeFocus:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchView:didSelectSuggestion:atIndex:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchView:didSelectSuggestion:atIndex:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewVoiceButtonClicked:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewVoiceButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchViewNavigationButtonClicked:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchViewNavigationButtonClicked:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDelegate), @selector(searchView:didSelectResult:), NO, YES).name, NULL, @"CYLSearchViewDelegate searchView:didSelectResult:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDataSource), @selector(searchView:resultsForQuery:), YES, YES).name, NULL, @"CYLSearchViewDataSource searchView:resultsForQuery:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchViewDataSource), @selector(searchView:configureResultCell:withResult:), YES, YES).name, NULL, @"CYLSearchViewDataSource searchView:configureResultCell:withResult:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(searchController:updateResultsForSearchString:), YES, YES).name, NULL, @"CYLSearchControllerDelegate searchController:updateResultsForSearchString:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(willPresentSearchController:), NO, YES).name, NULL, @"CYLSearchControllerDelegate willPresentSearchController:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(didPresentSearchController:), NO, YES).name, NULL, @"CYLSearchControllerDelegate didPresentSearchController:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(willDismissSearchController:), NO, YES).name, NULL, @"CYLSearchControllerDelegate willDismissSearchController:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(didDismissSearchController:), NO, YES).name, NULL, @"CYLSearchControllerDelegate didDismissSearchController:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(searchController:didLoadSearchResultsTableView:), NO, YES).name, NULL, @"CYLSearchControllerDelegate searchController:didLoadSearchResultsTableView:");
    XCTAssertNotEqual(protocol_getMethodDescription(@protocol(CYLSearchControllerDelegate), @selector(searchController:willShowEmptyView:), NO, YES).name, NULL, @"CYLSearchControllerDelegate searchController:willShowEmptyView:");
    CYLSearchFenceProtocols *dummy = [[CYLSearchFenceProtocols alloc] init];
    XCTAssertTrue([dummy conformsToProtocol:@protocol(CYLSearchBarViewDelegate)]);
    XCTAssertTrue([dummy conformsToProtocol:@protocol(CYLSearchViewDelegate)]);
    XCTAssertTrue([dummy conformsToProtocol:@protocol(CYLSearchViewDataSource)]);
    XCTAssertTrue([dummy conformsToProtocol:@protocol(CYLSearchControllerDelegate)]);
}

#pragma clang diagnostic pop

@end
