//
//  CYLSearchViewControllerTests.m
//  CYLSearchViewControllerTests
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/29.
//  Copyright (c) 2015年 http://weibo.com/luohanchenyilong/. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CYLSearchMainViewController.h"

@interface CYLSearchTestDataProvider : NSObject <CYLSearchDataProviding>
@end

@implementation CYLSearchTestDataProvider

- (NSArray<NSString *> *)searchResultsForQuery:(NSString *)query
{
    return @[@"Test result"];
}

- (void)reloadSearchResultsWithCompletion:(CYLSearchReloadCompletion)completion
{
    completion(nil);
}

@end

@interface CYLSearchViewControllerTests : XCTestCase
@end

@implementation CYLSearchViewControllerTests

- (void)testSearchRefreshReproductionPinsSearchBarByDefault
{
    CYLSearchMainViewController *viewController =
        [[CYLSearchMainViewController alloc] initWithDataProvider:[[CYLSearchTestDataProvider alloc] init]];

    [viewController loadViewIfNeeded];

    XCTAssertNotNil(viewController.navigationItem.searchController);
    XCTAssertFalse(viewController.navigationItem.hidesSearchBarWhenScrolling);
    XCTAssertNotNil(viewController.tableView.cyl_header);
    XCTAssertEqual([viewController tableView:viewController.tableView numberOfRowsInSection:0], 1);
}

@end
